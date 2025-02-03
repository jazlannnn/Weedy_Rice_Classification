# Keep all TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Don't warn about missing TensorFlow classes
-dontwarn org.tensorflow.**
