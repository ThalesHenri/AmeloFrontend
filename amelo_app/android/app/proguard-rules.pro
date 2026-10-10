# Mantém a classe principal do app
-keep class br.com.amelo.app.MainActivity { *; }

# Mantém o Flutter e suas dependências funcionando com ofuscação
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keepattributes *Annotation*,Signature

# Ignora dependências opcionais da Google Play (já que o APK é distribuído externamente)
-dontwarn com.google.android.play.core.**