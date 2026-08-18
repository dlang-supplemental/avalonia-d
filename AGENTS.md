# Agent notes — avalonia-d

Project facts for agents. Workstation/env facts live only in `$CODE_ROOT/MEMORIES.md`.

- Avalonia is .NET. This package does **not** bind Avalonia types 1:1. A C# host (`host/AvaloniaD.Host`) exports a small C ABI; D loads that native shim (DNNE) and wraps handles.
- High-level shadcn-style controls come from [ShadUI](https://github.com/accntech/shad-ui) (MIT, NuGet `ShadUI`), not a from-scratch clone. Fork that repo under dlang-supplemental **only** when a C# control change is required.
- `ShadUI.Window` has a **protected** constructor; the host subclasses it as `AvdWindow`.
- Build the host before `dub run`: `powershell -File tools/build-host.ps1`. Output lands in `native/<rid>/` (DNNE shim plus managed deps). CI RIDs: `win-x64`, `win-arm64`, `linux-x64`, `linux-arm64`, `osx-arm64` (no macOS x64).
- FFI aliases in `source/avalonia/ffi.d` **must** be `extern(C)`. D's default function-pointer ABI will NaN extra `double` arguments (Margin). Do not mark DNNE exports as `CallConvCdecl` on Windows x64.
- First public label: **0.1.0+avalonia.12** (git tag `v0.1.0`). Avalonia 12 is the peer axis; do not bump product major solely because Avalonia’s major moved.
- DUB install is `dub add avalonia-d` / `~>0.1.0`. Do not publish a fake `0.x` version on the registry.
