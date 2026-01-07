# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Shared Preferences
-keep class androidx.preference.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# General Android optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Aggressive optimization settings
-allowaccessmodification
-repackageclasses ''
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Remove unused resources
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn org.apache.**

# Shrink string resources
-adaptresourcefilenames **.properties,**.gif,**.jpg,**.png
-adaptresourcefilecontents **.properties,META-INF/MANIFEST.MF

# Remove debug information
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# Ignore warnings for missing classes that are not used
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Additional size optimizations
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# Remove unused native libraries
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**