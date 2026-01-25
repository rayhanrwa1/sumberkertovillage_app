plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sumberkerto_smart_village"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.sumberkerto_smart_village"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
        //     (project.findProperty("GOOGLE_MAPS_API_KEY") ?: "") as String
        manifestPlaceholders["AIzaSyCkymj5pLqGSbraogMIjOmgXMuqR583uUs"] =
            (project.findProperty("AIzaSyCkymj5pLqGSbraogMIjOmgXMuqR583uUs") ?: "") as String
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
