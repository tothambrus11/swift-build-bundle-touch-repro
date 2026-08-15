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

Observed locally with Swift 6.4-dev (x86_64-unknown-windows-msvc) and in CI (see the
`Reproduce` workflow) with `swift-DEVELOPMENT-SNAPSHOT-2026-05-20-a` (Swift 6.5-dev, the
latest `main` snapshot with a Windows installer at the time of writing) on `windows-latest`.

The CI job `swiftbuild-windows` **fails while the bug is present**: it checks that
`hello.txt` and `Info.plist` are absent from the package root after the build. A second job
runs the same check with `--build-system native`; locally with 6.4-dev the native build
system does not leak the files, but on the 6.5-dev snapshot in CI it does as well.
