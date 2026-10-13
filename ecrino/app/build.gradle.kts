plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

fun javaStringLiteral(value: String): String {
    val escaped = StringBuilder(value.length + 2)
    escaped.append('"')
    for (c in value) {
        when (c) {
            '\\' -> escaped.append("\\\\")
            '"' -> escaped.append("\\\"")
            '\n' -> escaped.append("\\n")
            '\r' -> escaped.append("\\r")
            '\t' -> escaped.append("\\t")
            else -> if (c.code < 0x20 || c.code == 0x7f) {
                escaped.append(String.format("\\u%04x", c.code))
            } else {
                escaped.append(c)
            }
        }
    }
    escaped.append('"')
    return escaped.toString()
}

android {
    namespace = "com.ecrino.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.ecrino.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"

        // Where order requests are delivered. Override per build without code changes.
        // Email fallback is always available; webhook is used when non-blank.
        buildConfigField("String", "ORDER_EMAIL", javaStringLiteral(project.findProperty("orderEmail")?.toString() ?: "yasinuzunow@gmail.com"))
        buildConfigField("String", "ORDER_WEBHOOK_URL", javaStringLiteral(project.findProperty("orderWebhookUrl")?.toString() ?: ""))

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.06.00")
    implementation(composeBom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.2")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.2")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.2")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    testImplementation("junit:junit:4.13.2")

    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
