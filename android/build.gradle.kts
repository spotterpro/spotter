import org.gradle.api.Project

// local.properties 파일에서 flutter.sdk 경로를 읽어오는 함수를 정의합니다.
fun getFlutterSdkPath(project: Project): String {
    val properties = java.util.Properties()
    val localPropertiesFile = project.rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { properties.load(it) }
    }
    val sdkPath = properties.getProperty("flutter.sdk")
    require(sdkPath != null) { "flutter.sdk not set in local.properties. Please run 'flutter config --android-studio-dir=<path>' or create the file manually." }
    return sdkPath
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // 카카오 네이티브 SDK 저장소
        maven { url = uri("https://devrepo.kakao.com/nexus/content/groups/public/") }
        // Flutter 로컬 저장소
        maven { url = uri("${getFlutterSdkPath(project)}/bin/cache/maven") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}