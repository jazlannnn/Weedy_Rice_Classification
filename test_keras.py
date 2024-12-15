#check keras model accuracy

import tensorflow as tf
import numpy as np
import cv2
import os

# Path to SavedModel
saved_model_dir = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\saved_model"
test_images_path = r"C:\yolov5_env\WeedyRice_Classification\test"  # Test images folder
class_names = ["Cultivated Rice", "Weedy Rice"]  # Class names

# Load the SavedModel
print("Loading TensorFlow SavedModel...")
model = tf.saved_model.load(saved_model_dir)
infer = model.signatures["serving_default"]

# Inspect available outputs
print("Inspecting model signature...")
print("Inputs:", infer.structured_input_signature)
print("Outputs:", infer.structured_outputs)

# Dynamically determine the output key
output_key = list(infer.structured_outputs.keys())[0]  # Pick the first available output key
print(f"Using output key: {output_key}")

# Preprocessing function
def preprocess_image(image_path, img_size=(224, 224)):
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, img_size)
    img = img / 255.0  # Normalize to [0, 1]
    img = (img - np.array([0.485, 0.456, 0.406])) / np.array([0.229, 0.224, 0.225])  # Normalize
    img = np.transpose(img, (2, 0, 1))  # Change to channels-first format
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img.astype(np.float32)

# Test images
print("Testing SavedModel with test images...")
for img_file in os.listdir(test_images_path):
    img_path = os.path.join(test_images_path, img_file)
    if img_file.endswith((".jpg", ".png", ".jpeg")):
        print(f"\nProcessing image: {img_file}")
        
        # Preprocess image
        input_tensor = preprocess_image(img_path)

        # Run inference
        predictions = infer(tf.convert_to_tensor(input_tensor))[output_key].numpy()[0]

        # Post-process logits to probabilities
        probabilities = tf.nn.softmax(predictions).numpy()
        predicted_class = np.argmax(probabilities)
        predicted_class_name = class_names[predicted_class]

        print(f"Logits: {predictions}")
        print(f"Probabilities: {probabilities}")
        print(f"Predicted Class: {predicted_class_name} ({probabilities[predicted_class]:.2f})")
