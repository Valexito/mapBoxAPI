// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dev.parking"
    compileSdk = flutter.compileSdkVersion
    // Si no necesitas NDK, omite la línea. (Déjala comentada)
    // ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.dev.parking" // Debe coincidir con google-services.json
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        // Debug: sin shrink, sin minify (más rápido)
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }

        // Release: puedes activar shrink+minify (opcional)
        release {
            // Si todavía no firmas release, usa firma de debug para poder compilar
            signingConfig = signingConfigs.getByName("debug")

            // Activa optimización cuando estés listo
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Evita conflictos de META-INF cuando uses varias libs
    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // BOM centraliza versiones de Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.2.0"))

    // Solo lo que uses:
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Otras (opcional)
    // implementation("com.google.firebase:firebase-crashlytics")
    // implementation("com.google.firebase:firebase-messaging")

    // Multidex si tu app crece
    implementation("androidx.multidex:multidex:2.0.1")
}
