#before and during convert to onnx

import os
import torch
from torchsummary import summary
import onnxruntime as ort
import numpy as np
import torch.nn.functional as F
from torchvision import transforms

# Define the model file path
model_path = r'C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\weights\best.pt'

# Define the paths for the input and logits files
pytorch_input_path = r'C:\yolov5_env\WeedyRice_Classification\yolov5\pytorch_input.pt'
pytorch_logits_path = r'C:\yolov5_env\WeedyRice_Classification\yolov5\pytorch_logits.pt'


# Define the directory and file path for the ONNX model
onnx_model_dir = r'C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\weights'
onnx_model_path = os.path.join(onnx_model_dir, "model.onnx")

# Define preprocessing identical to `predict.py`
preprocess = transforms.Compose([
    transforms.Resize((224, 224)),  # Match input size
    transforms.ToTensor(),          # Convert to PyTorch tensor
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])  # Example mean/std
])

# Step 1: Load the model
try:
    model_data = torch.load(model_path, map_location=torch.device('cpu'))
    model = model_data['model']
    model = model.float().to('cpu')  # Ensure model is in full precision and on CPU
    model.eval()  # Set model to evaluation mode
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    exit()

# Step 2: Inspect Metadata
print("\n--- Model Metadata ---")
if isinstance(model_data, dict):
    print(f"Keys in model file: {model_data.keys()}")

# Step 3: Model Summary
print("\n--- Model Summary ---")
try:
    dummy_input = torch.randn(1, 3, 224, 224).to(torch.device('cpu'))  # Ensure input is on CPU
    model.to('cpu')  # Ensure model is also on CPU
    summary(model, input_size=(3, 224, 224), device="cpu")  # Specify device explicitly
except Exception as e:
    print(f"Unable to summarize model: {e}")


# Step 4: Load Preprocessed Input and Logits
print("\n--- Loading PyTorch Preprocessed Input and Logits ---")
try:
    pytorch_input = torch.load(pytorch_input_path).to('cpu')  # Load and move to CPU
    pytorch_logits = torch.load(pytorch_logits_path).to('cpu')  # Load and move to CPU
    print("Preprocessed input and logits loaded successfully!")
except Exception as e:
    print(f"Error loading preprocessed input or logits: {e}")
    exit()

# Step 5: Export PyTorch Model to ONNX
try:
    torch.onnx.export(
        model,
        pytorch_input,  # Use preprocessed input
        onnx_model_path,
        export_params=True,
        opset_version=11,
        input_names=["input"],
        output_names=["output"]
    )
    print(f"Model exported to ONNX successfully at {onnx_model_path}!")
except Exception as e:
    print(f"Error exporting PyTorch model to ONNX: {e}")

# Step 6: Test ONNX Model
try:
    session = ort.InferenceSession(onnx_model_path)
    onnx_input = pytorch_input.numpy()
    onnx_output = session.run(None, {session.get_inputs()[0].name: onnx_input})
    onnx_logits = onnx_output[0]
    print("ONNX Model tested successfully!")
except Exception as e:
    print(f"Error testing ONNX model: {e}")
    exit()

# Step 7: Compare Outputs
print("\n--- Comparing PyTorch and ONNX Outputs ---")
try:
    # Compare Logits
    pytorch_logits_np = pytorch_logits.numpy()
    onnx_logits_np = onnx_logits
    logit_diff = np.abs(pytorch_logits_np - onnx_logits_np)
    print("Logit Differences:", logit_diff)

    # Compare Probabilities
    pytorch_probabilities = F.softmax(torch.tensor(pytorch_logits_np), dim=1).numpy()
    onnx_probabilities = F.softmax(torch.tensor(onnx_logits_np), dim=1).numpy()
    probability_diff = np.abs(pytorch_probabilities - onnx_probabilities)
    print("Probability Differences:", probability_diff)

    # Predicted Classes
    pytorch_pred_class = np.argmax(pytorch_probabilities, axis=1)
    onnx_pred_class = np.argmax(onnx_probabilities, axis=1)
    print("PyTorch Predicted Class:", pytorch_pred_class)
    print("ONNX Predicted Class:", onnx_pred_class)
    print("Do predicted classes match?", np.array_equal(pytorch_pred_class, onnx_pred_class))

    # Save intermediate outputs for further debugging if needed
    np.save("onnx_logits.npy", onnx_logits_np)
    np.save("pytorch_logits.npy", pytorch_logits_np)
except Exception as e:
    print(f"Error comparing outputs: {e}")

print("\n--- Analysis Complete ---")
