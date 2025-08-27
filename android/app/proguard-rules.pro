# android/app/proguard-rules.pro

# Mantén anotaciones y clases de Firebase
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# (Flutter suele manejar el resto con el default proguard)
