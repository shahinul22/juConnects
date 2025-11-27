buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // The classpath must be defined here for the app module to use it
        // Updated to the latest stable version 4.4.4
        classpath("com.google.gms:google-services:4.4.4")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// These are necessary for proper build organization in Flutter projects
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// The following line is generally not needed and can sometimes cause issues.
// I recommend commenting it out or removing it unless you know for sure you need it.
/*
subprojects {
    project.evaluationDependsOn(":app")
}
*/

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}