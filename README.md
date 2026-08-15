# swift-build resource bundle "touch" copies bundle contents into CWD on Windows

On Windows, with the SwiftBuild build system, building a target that has resources
copies the top-level files of the generated resource bundle (`Info.plist` and every
resource file) into the current working directory.

## Reproduce

```
swift build --build-system swiftbuild
dir
```

`hello.txt` and `Info.plist` now sit in the package root.

## Cause

`swift build -v` shows the "Touch" step for the bundle:

```
Touch Repro_Foo.bundle
    cd C:\...\repro
    C:\WINDOWS\system32\cmd.exe /c copy /b C:\...\Products\Debug-windows\Repro_Foo.bundle +,,
```

`copy /b <file> +,,` is the cmd.exe idiom for updating a file's timestamp, but when the
argument is a *directory*, `copy` instead copies every file inside it into the current
directory. Since the command runs with the package root as CWD, the bundle contents
leak into the package.

Observed with Swift 6.4-dev (x86_64-unknown-windows-msvc). Does not happen with
`--build-system native`.
