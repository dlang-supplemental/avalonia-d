# Agent notes — avalonia-d

Project facts for agents. Workstation/env facts live only in `$CODE_ROOT/MEMORIES.md`.

- Avalonia is .NET. This package does **not** bind Avalonia types 1:1. A C# host (`host/AvaloniaD.Host`) exports a small C ABI; D loads that native shim (DNNE) and wraps handles.
- High-level shadcn-style controls come from [ShadUI](https://github.com/accntech/shad-ui) (MIT, NuGet `ShadUI`), not a from-scratch clone. Fork that repo under dlang-supplemental **only** when a C# control change is required.
- `ShadUI.Window` has a **protected** constructor; the host subclasses it as `AvdWindow`.
- Build the host before `dub run`: `powershell -File tools/build-host.ps1`. Output lands in `native/<rid>/` (DNNE `AvaloniaD.HostNE.dll` plus managed deps).
- FFI aliases in `source/avalonia/ffi.d` **must** be `extern(C)`. D's default function-pointer ABI will NaN extra `double` arguments (Margin). Do not mark DNNE exports as `CallConvCdecl` on Windows x64.
- No prior D wrapper for Avalonia was found (GitHub / awesome-d / DUB, 2026-08).
