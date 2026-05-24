plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---- BLOCO NOVO: Lê as configurações do arquivo key.properties ----
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}
// ------------------------------------------------------------------

android {
    // 1. ALTERE AQUI: Coloque o ID único do seu aplicativo (sem o "example")
    namespace = "com.ravel.regenerar" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ---- BLOCO NOVO: Configura a assinatura com a sua chave ----
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    // -------------------------------------------------------------

    defaultConfig {
        // 2. ALTERE AQUI TAMBÉM: Deve ser exatamente igual ao namespace acima
        applicationId = "com.ravel.regenerar"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ALTERADO: Agora aponta para a configuração de "release" que criamos acima, não mais para "debug"
            signingConfig = signingConfigs.getByName("release")
            
            minifyEnabled = true
            shrinkResources = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}