#convert to keras

import onnx
from onnx_tf.backend import prepare
import tensorflow as tf
import os

# Define paths
onnx_model_dir = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\weights"  # ONNX model directory
onnx_model_path = os.path.join(onnx_model_dir, "model.onnx")  # Path to the ONNX model

# Ensure the directory exists
if not os.path.exists(onnx_model_path):
    raise FileNotFoundError(f"ONNX model not found at {onnx_model_path}")


tf_saved_model_dir = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\saved_model"
keras_saved_model_dir = r"C:\yolov5_env\WeedyRice_Classification\yolov5\runs\train-cls\exp\saved_model"

# Step 1: Convert ONNX to TensorFlow SavedModel
print("Loading ONNX model...")
onnx_model = onnx.load(onnx_model_path)
print("Converting ONNX to TensorFlow SavedModel...")
os.makedirs(tf_saved_model_dir, exist_ok=True)
tf_rep = prepare(onnx_model)
tf_rep.export_graph(tf_saved_model_dir)
print(f"TensorFlow SavedModel saved at {tf_saved_model_dir}!")

# Step 2: Load TensorFlow SavedModel
print("Loading TensorFlow SavedModel...")
loaded_model = tf.saved_model.load(tf_saved_model_dir)

# Inspect available outputs
print("Inspecting model signature...")
signatures = loaded_model.signatures["serving_default"]
print("Inputs:", signatures.structured_input_signature)
print("Outputs:", signatures.structured_outputs)

# Extract the correct output key
output_key = list(signatures.structured_outputs.keys())[0]  # Use the first available output key
print(f"Using output key: {output_key}")

# Define the wrapped model class
class WrappedModel(tf.keras.Model):
    def __init__(self, saved_model, output_key):
        super(WrappedModel, self).__init__()
        self.saved_model = saved_model
        self.model_function = saved_model.signatures["serving_default"]
        self.output_key = output_key

    def call(self, inputs):
        # Ensure inputs are properly passed
        outputs = self.model_function(inputs)
        return outputs[self.output_key]
    
    def get_config(self):
        # Define configuration for serialization
        return {"output_key": self.output_key}

    @classmethod
    def from_config(cls, config, custom_objects=None):
        # Recreate the model from the config (requires the saved_model to be passed externally)
        raise NotImplementedError("Loading this model requires the TensorFlow SavedModel.")

print("Converting to Keras model...")
keras_model = WrappedModel(loaded_model, output_key)

# Define a concrete input shape
sample_input = tf.random.uniform([1, 3, 224, 224])  # Match input size as per ONNX model
_ = keras_model(sample_input)  # Build the model by calling it with a sample input

# Save as Keras SavedModel
print("Saving as Keras SavedModel...")
os.makedirs(keras_saved_model_dir, exist_ok=True)
tf.keras.models.save_model(keras_model, keras_saved_model_dir, save_format="tf")
print(f"Keras SavedModel saved at {keras_saved_model_dir}!")
