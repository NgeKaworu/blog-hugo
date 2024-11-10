---
date: 2024-04-17T18:40:29+08:00
title: "So"
draft: true
---
```kotlin
tasks.whenTaskAdded { task ->
    if (task.name == 'mergeDebugNativeLibs') {
        task.doFirst {
            println("---------------find so files start-----------------")
            println("---------------find so files start-----------------")
            println("---------------find so files start-----------------")

            it.inputs.files.each { file ->
                printDir(new File(file.absolutePath))
            }

            println("---------------find so files end-----------------")
            println("---------------find so files end-----------------")
            println("---------------find so files end-----------------")
        }
    }
}

def printDir(File file) {
    if (file != null) {
        if (file.isDirectory()) {
            file.listFiles().each {
                printDir(it)
            }
        } else if (file.absolutePath.endsWith(".so")) {
            println("find so file: ${file.absolutePath}")
        }
    }
}
```