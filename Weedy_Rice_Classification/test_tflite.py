import tensorflow as tf
import numpy as np
import cv2
import os

# Paths
tflite_model_path = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\weights\model.tflite"
test_images_path = r"C:\yolov5_env\WeedyRice_Classification\test"  # Folder with test images
class_names = ["Cultivated Rice", "Weedy Rice"]  # Class names
ground_truth_labels = {"1.jpg": 1, "2.png": 1, "3.png": 1, "4.jpg": 0, "5.jpg": 0, "6.jpg": 0}  # Example labels

# Load the TFLite model
print("Loading TFLite model...")
interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Verify the input shape
expected_input_shape = input_details[0]['shape']  # Shape of input tensor
print(f"Expected input shape: {expected_input_shape}")

# Preprocessing function
def preprocess_image(image_path, img_size=(224, 224)):
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)  # Convert BGR to RGB
    img = cv2.resize(img, img_size)  # Resize to model input size
    img = img / 255.0  # Normalize to [0, 1]
    img = (img - np.array([0.485, 0.456, 0.406])) / np.array([0.229, 0.224, 0.225])  # Normalize with mean/std
    img = np.transpose(img, (2, 0, 1))  # Convert HWC to CHW
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img.astype(np.float32)

# Evaluate TFLite model
print("Evaluating TFLite model...")
correct_predictions = 0
total_predictions = 0

for img_file in os.listdir(test_images_path):
    img_path = os.path.join(test_images_path, img_file)
    if img_file.endswith((".jpg", ".png", ".jpeg")):
        print(f"\nProcessing image: {img_file}")

        # Preprocess the image
        input_data = preprocess_image(img_path)

        # Check the input shape
        print(f"Input tensor shape: {input_data.shape}")
        if input_data.shape != tuple(expected_input_shape):
            raise ValueError(f"Input shape mismatch. Expected: {expected_input_shape}, Got: {input_data.shape}")

        # Run inference
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        predictions = interpreter.get_tensor(output_details[0]['index'])[0]

        # Post-process predictions
        probabilities = tf.nn.softmax(predictions).numpy()
        predicted_class = np.argmax(probabilities)
        predicted_class_name = class_names[predicted_class]

        # Compare with ground truth
        ground_truth = ground_truth_labels[img_file]
        is_correct = predicted_class == ground_truth
        correct_predictions += int(is_correct)
        total_predictions += 1

        print(f"Logits: {predictions}")
        print(f"Probabilities: {probabilities}")
        print(f"Predicted Class: {predicted_class_name} ({probabilities[predicted_class]:.2f})")
        print(f"Ground Truth: {class_names[ground_truth]}")
        print(f"Correct: {is_correct}")

# Calculate accuracy
accuracy = correct_predictions / total_predictions if total_predictions > 0 else 0
print(f"\n--- Evaluation Complete ---")
print(f"Accuracy: {accuracy:.2%} ({correct_predictions}/{total_predictions})")
