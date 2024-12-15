#after convert to onnx

import torch
import os
import cv2
import numpy as np
import onnxruntime as ort
import torch.nn.functional as F


# Define paths
onnx_model_dir = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\weights"  # ONNX model directory
onnx_model_path = os.path.join(onnx_model_dir, "model.onnx")  # Path to the ONNX model

# Ensure the directory exists
if not os.path.exists(onnx_model_path):
    raise FileNotFoundError(f"ONNX model not found at {onnx_model_path}")

# Define paths
test_images_path = r"C:\yolov5_env\WeedyRice_Classification\test"  # Test images folder
class_names = ["Cultivated Rice", "Weedy Rice"]  # Class names

# Load ONNX model
print("Loading ONNX model...")
session = ort.InferenceSession(onnx_model_path)

# Preprocessing function
def preprocess_image(image_path, img_size=(224, 224)):
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, img_size)
    img = img / 255.0  # Normalize to [0, 1]
    img = (img - np.array([0.485, 0.456, 0.406])) / np.array([0.229, 0.224, 0.225])  # Normalize with mean/std
    img = np.transpose(img, (2, 0, 1))  # HWC to CHW
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img.astype(np.float32)


# Test ONNX model with test images
print("Testing ONNX model with test images...")
results = []
for img_file in os.listdir(test_images_path):
    img_path = os.path.join(test_images_path, img_file)
    if img_file.endswith((".jpg", ".png", ".jpeg")):
        print(f"\nProcessing image: {img_file}")

        # Preprocess image
        input_tensor = preprocess_image(img_path)

        # Run ONNX inference
        onnx_output = session.run(None, {session.get_inputs()[0].name: input_tensor})
        logits = onnx_output[0]

        # Post-process logits to probabilities
        probabilities = F.softmax(torch.tensor(logits), dim=1).numpy()[0]
        predicted_class = np.argmax(probabilities)
        predicted_class_name = class_names[predicted_class]

        # Save result
        results.append({
            "image": img_file,
            "logits": logits[0],
            "probabilities": probabilities,
            "predicted_class": predicted_class_name,
            "confidence": probabilities[predicted_class]
        })

        # Print results
        print(f"Logits: {logits[0]}")
        print(f"Probabilities: {probabilities}")
        print(f"Predicted Class: {predicted_class_name} ({probabilities[predicted_class]:.2f})")

# Summary of results
print("\n--- Summary of ONNX Model Predictions ---")
for res in results:
    print(f"Image: {res['image']}")
    print(f"  Predicted Class: {res['predicted_class']} (Confidence: {res['confidence']:.2f})")
    print(f"  Logits: {res['logits']}")
    print(f"  Probabilities: {res['probabilities']}")
