plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Firebase Google Services Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.quiz_master"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    ndkVersion = "27.0.12077973"
    defaultConfig {
        applicationId = "com.example.quiz_master"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // Example Firebase SDK: Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Add more Firebase dependencies as needed, e.g.:
     implementation("com.google.firebase:firebase-auth")
     implementation("com.google.firebase:firebase-firestore")
}
