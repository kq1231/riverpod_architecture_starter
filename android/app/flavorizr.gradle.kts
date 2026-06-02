import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.starter.riverpod_architecture_starter.dev"
            resValue(type = "string", name = "app_name", value = "Riverpod Starter (Dev)")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.starter.riverpod_architecture_starter"
            resValue(type = "string", name = "app_name", value = "Riverpod Starter")
        }
    }

    buildFeatures.resValues = true
}