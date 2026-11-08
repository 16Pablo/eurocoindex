## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## App & Plugins
-keep class com.pablo.eurocoindex.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class dev.fluttercommunity.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }

## Supresión de advertencias en optimización R8
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
