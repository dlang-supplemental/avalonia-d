module avalonia.ffi;

/**
 * Dynamic loader for the avalonia-d C ABI host (DNNE native shim).
 * ABI: include/avalonia_d.h
 */

import avalonia.exception;
import std.conv : to;
import std.exception : enforce;
import std.string : fromStringz, toStringz;

version (Windows)
{
    import core.sys.windows.winbase : FreeLibrary, GetProcAddress, LoadLibraryA;
    import core.sys.windows.windef : HMODULE;
}
else
{
    import core.sys.posix.dlfcn : RTLD_NOW, dlclose, dlerror, dlopen, dlsym;
}

alias AvdHandle = ulong;
enum AvdHandle invalidHandle = 0;

enum AvdStatus : int
{
    ok = 0,
    err = -1,
    notInit = -2,
    alreadyInit = -3,
    badHandle = -4,
    badType = -5,
    badUtf8 = -6,
    unsupported = -7,
}

enum ThemeMode : int
{
    system = 0,
    light = 1,
    dark = 2,
}

enum Orientation : int
{
    horizontal = 0,
    vertical = 1,
}

alias AvdVoidCb = extern (C) void function(void* user) nothrow;

private __gshared void* libHandle;
private __gshared bool loaded;

alias da_avd_version = extern (C) const(char)* function() nothrow @nogc;
alias da_avd_last_error = extern (C) const(char)* function() nothrow @nogc;
alias da_avd_init = extern (C) int function(int themeMode);
alias da_avd_shutdown = extern (C) int function();
alias da_avd_switch_theme = extern (C) int function(int themeMode);
alias da_avd_window_new = extern (C) ulong function(const(char)* title, int width, int height);
alias da_avd_stack_new = extern (C) ulong function(int orientation);
alias da_avd_scroll_new = extern (C) ulong function();
alias da_avd_button_new = extern (C) ulong function(const(char)* text);
alias da_avd_text_new = extern (C) ulong function(const(char)* text);
alias da_avd_textbox_new = extern (C) ulong function(const(char)* text);
alias da_avd_checkbox_new = extern (C) ulong function(const(char)* text, int isChecked);
alias da_avd_separator_new = extern (C) ulong function(int orientation);
alias da_avd_card_new = extern (C) ulong function();
alias da_avd_card_title_new = extern (C) ulong function(const(char)* text);
alias da_avd_card_description_new = extern (C) ulong function(const(char)* text);
alias da_avd_panel_add = extern (C) int function(ulong parent, ulong child);
alias da_avd_card_set_header = extern (C) int function(ulong card, ulong header);
alias da_avd_card_set_footer = extern (C) int function(ulong card, ulong footer);
alias da_avd_window_set_content = extern (C) int function(ulong window, ulong content);
alias da_avd_set_text = extern (C) int function(ulong handle, const(char)* text);
alias da_avd_get_text = extern (C) int function(ulong handle, char* buf, int cap);
alias da_avd_set_checked = extern (C) int function(ulong handle, int value);
alias da_avd_get_checked = extern (C) int function(ulong handle);
alias da_avd_set_enabled = extern (C) int function(ulong handle, int value);
alias da_avd_set_width = extern (C) int function(ulong handle, double width);
alias da_avd_set_height = extern (C) int function(ulong handle, double height);
alias da_avd_set_margin = extern (C) int function(ulong handle, double left, double top, double right, double bottom);
alias da_avd_set_padding = extern (C) int function(ulong handle, double left, double top, double right, double bottom);
alias da_avd_set_spacing = extern (C) int function(ulong handle, double spacing);
alias da_avd_set_font_size = extern (C) int function(ulong handle, double points);
alias da_avd_add_class = extern (C) int function(ulong handle, const(char)* className);
alias da_avd_on_click = extern (C) int function(ulong handle, AvdVoidCb cb, void* user);
alias da_avd_on_text_changed = extern (C) int function(ulong handle, AvdVoidCb cb, void* user);
alias da_avd_on_checked_changed = extern (C) int function(ulong handle, AvdVoidCb cb, void* user);
alias da_avd_run = extern (C) int function(ulong window);

__gshared da_avd_version avd_version;
__gshared da_avd_last_error avd_last_error;
__gshared da_avd_init avd_init;
__gshared da_avd_shutdown avd_shutdown;
__gshared da_avd_switch_theme avd_switch_theme;
__gshared da_avd_window_new avd_window_new;
__gshared da_avd_stack_new avd_stack_new;
__gshared da_avd_scroll_new avd_scroll_new;
__gshared da_avd_button_new avd_button_new;
__gshared da_avd_text_new avd_text_new;
__gshared da_avd_textbox_new avd_textbox_new;
__gshared da_avd_checkbox_new avd_checkbox_new;
__gshared da_avd_separator_new avd_separator_new;
__gshared da_avd_card_new avd_card_new;
__gshared da_avd_card_title_new avd_card_title_new;
__gshared da_avd_card_description_new avd_card_description_new;
__gshared da_avd_panel_add avd_panel_add;
__gshared da_avd_card_set_header avd_card_set_header;
__gshared da_avd_card_set_footer avd_card_set_footer;
__gshared da_avd_window_set_content avd_window_set_content;
__gshared da_avd_set_text avd_set_text;
__gshared da_avd_get_text avd_get_text;
__gshared da_avd_set_checked avd_set_checked;
__gshared da_avd_get_checked avd_get_checked;
__gshared da_avd_set_enabled avd_set_enabled;
__gshared da_avd_set_width avd_set_width;
__gshared da_avd_set_height avd_set_height;
__gshared da_avd_set_margin avd_set_margin;
__gshared da_avd_set_padding avd_set_padding;
__gshared da_avd_set_spacing avd_set_spacing;
__gshared da_avd_set_font_size avd_set_font_size;
__gshared da_avd_add_class avd_add_class;
__gshared da_avd_on_click avd_on_click;
__gshared da_avd_on_text_changed avd_on_text_changed;
__gshared da_avd_on_checked_changed avd_on_checked_changed;
__gshared da_avd_run avd_run;

bool isLoaded()
{
    return loaded;
}

void loadLibrary(string libraryPath = null)
{
    if (loaded)
        return;

    auto path = libraryPath.length ? libraryPath : defaultLibraryName();
    libHandle = openLib(path);
    enforce(libHandle !is null, new AvaloniaException(AvdStatus.err,
            "failed to load avalonia-d host: " ~ path ~ extraDlError()));

    bindAll();
    loaded = true;
}

void unloadLibrary()
{
    if (!loaded)
        return;
    closeLib(libHandle);
    libHandle = null;
    loaded = false;
}

string lastError()
{
    if (avd_last_error is null)
        return "";
    auto p = avd_last_error();
    return p is null ? "" : p.fromStringz.idup;
}

void checkStatus(int code, string what)
{
    if (code >= 0)
        return;
    auto err = lastError();
    throw new AvaloniaException(code, what ~ " failed (" ~ to!string(code) ~ "): " ~ err);
}

AvdHandle checkHandle(AvdHandle h, string what)
{
    if (h != invalidHandle)
        return h;
    auto err = lastError();
    throw new AvaloniaException(AvdStatus.badHandle, what ~ " returned an invalid handle: " ~ err);
}

private void bindAll()
{
    bind(avd_version, "avd_version");
    bind(avd_last_error, "avd_last_error");
    bind(avd_init, "avd_init");
    bind(avd_shutdown, "avd_shutdown");
    bind(avd_switch_theme, "avd_switch_theme");
    bind(avd_window_new, "avd_window_new");
    bind(avd_stack_new, "avd_stack_new");
    bind(avd_scroll_new, "avd_scroll_new");
    bind(avd_button_new, "avd_button_new");
    bind(avd_text_new, "avd_text_new");
    bind(avd_textbox_new, "avd_textbox_new");
    bind(avd_checkbox_new, "avd_checkbox_new");
    bind(avd_separator_new, "avd_separator_new");
    bind(avd_card_new, "avd_card_new");
    bind(avd_card_title_new, "avd_card_title_new");
    bind(avd_card_description_new, "avd_card_description_new");
    bind(avd_panel_add, "avd_panel_add");
    bind(avd_card_set_header, "avd_card_set_header");
    bind(avd_card_set_footer, "avd_card_set_footer");
    bind(avd_window_set_content, "avd_window_set_content");
    bind(avd_set_text, "avd_set_text");
    bind(avd_get_text, "avd_get_text");
    bind(avd_set_checked, "avd_set_checked");
    bind(avd_get_checked, "avd_get_checked");
    bind(avd_set_enabled, "avd_set_enabled");
    bind(avd_set_width, "avd_set_width");
    bind(avd_set_height, "avd_set_height");
    bind(avd_set_margin, "avd_set_margin");
    bind(avd_set_padding, "avd_set_padding");
    bind(avd_set_spacing, "avd_set_spacing");
    bind(avd_set_font_size, "avd_set_font_size");
    bind(avd_add_class, "avd_add_class");
    bind(avd_on_click, "avd_on_click");
    bind(avd_on_text_changed, "avd_on_text_changed");
    bind(avd_on_checked_changed, "avd_on_checked_changed");
    bind(avd_run, "avd_run");
}

private void bind(T)(ref T dst, string name)
{
    dst = cast(T) lookup(name);
    enforce(dst !is null, new AvaloniaException(AvdStatus.err, "missing export: " ~ name));
}

private void* lookup(string name)
{
    version (Windows)
        return GetProcAddress(cast(HMODULE) libHandle, name.toStringz);
    else
        return dlsym(libHandle, name.toStringz);
}

private void* openLib(string path)
{
    version (Windows)
        return cast(void*) LoadLibraryA(path.toStringz);
    else
        return dlopen(path.toStringz, RTLD_NOW);
}

private void closeLib(void* h)
{
    if (h is null)
        return;
    version (Windows)
        FreeLibrary(cast(HMODULE) h);
    else
        dlclose(h);
}

private string extraDlError()
{
    version (Windows)
        return "";
    else
    {
        auto p = dlerror();
        return p is null ? "" : (": " ~ p.fromStringz.idup);
    }
}

string defaultLibraryName()
{
    version (Windows)
        return "AvaloniaD.HostNE.dll";
    else version (OSX)
        return "libAvaloniaD.HostNE.dylib";
    else
        return "libAvaloniaD.HostNE.so";
}
