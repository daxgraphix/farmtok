# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line numbers, uncomment this to hide the original
# source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase rules
-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }
-keep class org.postgrest.** { *; }
-keep class io.github.jan.supabase.** { *; }

# Hive rules
-keep class * extends com.google.gson.TypeAdapter
-keep class * extends com.google.gson.TypeAdapterFactory
-keep class * implements java.io.Serializable { *; }
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault
-keepclassmembers, allowshrinking, allowobfuscation class * {
    @org.jetbrains.annotations.NotNull <methods>;
}
-keepclassmembers, allowshrinking, allowobfuscation class * {
    @org.jetbrains.annotations.Nullable <methods>;
}
-keepclassmembers, allowshrinking, allowobfuscation class * {
    @androidx.annotation.Nullable <methods>;
}
-keepclassmembers, allowshrinking, allowobfuscation class * {
    @androidx.annotation.NonNull <methods>;
}
-keep @org.jetbrains.annotations.NotNull class *
-keep @org.jetbrains.annotations.Nullable class *
-keep @androidx.annotation.Nullable class *
-keep @androidx.annotation.NonNull class *

# Google ML Kit rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Dio rules
-keep class dio.** { *; }
-keep class com.google.gson.** { *; }

# Flutter Local Notifications rules
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat** { *; }

# Camera rules
-keep class io.flutter.plugins.camera.** { *; }
-keep class androidx.camera.** { *; }

# Flutter Image Compress rules
-keep class com.fluttercandies.** { *; }

# Flutter Secure Storage rules
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# HTTP Certificate Pinning rules
-keep class diefferson.http_certificate_pinning.** { *; }

# Google Fonts (if needed)
-keep class com.google.android.gms.fonts.** { *; }

# Additional rules from missing_rules.txt
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions