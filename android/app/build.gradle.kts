plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase est obligatoire pour les notifications push : on échoue clairement
// si le fichier de configuration est absent.
if (!file("google-services.json").exists()) {
    throw GradleException(
        "android/app/google-services.json est introuvable. " +
                "Téléchargez-le depuis la console Firebase (package : com.example.traceur_app)."
    )
}
apply(plugin = "com.google.gms.google-services")

android {
    namespace = "com.example.traceur_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
237    }

    defaultConfig {
        applicationId = "com.example.traceur_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-installations")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}