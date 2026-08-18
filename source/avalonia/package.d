module avalonia;

/**
 * D bindings for Avalonia via a C ABI host, with ShadUI (shadcn-inspired) controls.
 *
 * Avalonia is a .NET UI framework. This package loads a DNNE native shim
 * (`AvaloniaD.HostNE`) that hosts CoreCLR, Avalonia, and ShadUI, then wraps
 * opaque handles in idiomatic D types.
 */

public import avalonia.controls;
public import avalonia.exception;
public import avalonia.ffi : AvdHandle, AvdStatus, Orientation, ThemeMode,
    defaultLibraryName, invalidHandle, isLoaded, lastError, loadLibrary, unloadLibrary;

import avalonia.ffi;
import std.file : exists, getcwd, thisExePath;
import std.path : buildPath, dirName;

/// Load the native host from an explicit path, or search common locations.
void load(string libraryPath = null)
{
    if (libraryPath.length)
    {
        loadLibrary(libraryPath);
        return;
    }

    foreach (c; candidatePaths())
    {
        if (exists(c))
        {
            loadLibrary(c);
            return;
        }
    }

    loadLibrary(defaultLibraryName());
}

/// Unload the native host.
void unload()
{
    unloadLibrary();
}

/// Start Avalonia + ShadUI. Must be called before creating widgets.
void init(ThemeMode theme = ThemeMode.dark)
{
    if (!isLoaded)
        load();
    checkStatus(avd_init(cast(int) theme), "init");
}

/// Switch ShadUI theme after init.
void switchTheme(ThemeMode theme)
{
    checkStatus(avd_switch_theme(cast(int) theme), "switch_theme");
}

/// Host package version string from the C ABI.
string hostVersion()
{
    if (!isLoaded)
        load();
    auto p = avd_version();
    import std.string : fromStringz;
    return p is null ? "" : p.fromStringz.idup;
}

private string[] candidatePaths()
{
    version (Windows)
        enum shim = "AvaloniaD.HostNE.dll";
    else version (OSX)
        enum shim = "libAvaloniaD.HostNE.dylib";
    else
        enum shim = "libAvaloniaD.HostNE.so";

    version (Windows)
        enum rid = "win-x64";
    else version (OSX)
        enum rid = "osx-arm64";
    else
        enum rid = "linux-x64";

    string[] starts;
    try
        starts ~= dirName(thisExePath());
    catch (Exception)
    {
    }
    starts ~= getcwd();

    string[] paths;
    foreach (start; starts)
    {
        auto dir = start;
        foreach (_; 0 .. 8)
        {
            paths ~= buildPath(dir, shim);
            paths ~= buildPath(dir, "native", rid, shim);
            paths ~= buildPath(dir, "native", shim);
            auto parent = dirName(dir);
            if (parent == dir)
                break;
            dir = parent;
        }
    }
    return paths;
}

unittest
{
    import std.file : exists, getcwd;
    import std.path : buildPath;

    string lib;
    foreach (c; candidatePaths())
    {
        if (exists(c))
        {
            lib = c;
            break;
        }
    }
    if (lib.length == 0)
        return;

    load(lib);
    scope (exit)
        unload();

    auto v = hostVersion();
    assert(v.length > 0);

    init(ThemeMode.dark);
    scope (exit)
        avd_shutdown();

    auto win = avd_window_new("avalonia-d-test", 320, 200);
    assert(win != invalidHandle);
}
