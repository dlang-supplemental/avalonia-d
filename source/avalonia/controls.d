module avalonia.controls;

import avalonia.exception;
import avalonia.ffi;
import core.memory : GC;
import std.string : toStringz;

private final class CallbackRoot
{
    void delegate() dg;

    this(void delegate() dg)
    {
        this.dg = dg;
    }
}

private extern (C) void trampoline(void* user) nothrow
{
    try
    {
        auto root = cast(CallbackRoot) user;
        if (root !is null && root.dg !is null)
            root.dg();
    }
    catch (Exception)
    {
    }
}

class Widget
{
    AvdHandle handle;
    private CallbackRoot[] roots;

    this(AvdHandle handle)
    {
        this.handle = checkHandle(handle, typeid(this).name);
    }

    void text(string value)
    {
        checkStatus(avd_set_text(handle, value.toStringz), "set_text");
    }

    string text()
    {
        char[4096] buf;
        auto n = avd_get_text(handle, buf.ptr, cast(int) buf.length);
        checkStatus(n, "get_text");
        return buf[0 .. n].idup;
    }

    void enabled(bool value)
    {
        checkStatus(avd_set_enabled(handle, value ? 1 : 0), "set_enabled");
    }

    void width(double value)
    {
        checkStatus(avd_set_width(handle, value), "set_width");
    }

    void height(double value)
    {
        checkStatus(avd_set_height(handle, value), "set_height");
    }

    void margin(double left, double top, double right, double bottom)
    {
        checkStatus(avd_set_margin(handle, left, top, right, bottom), "set_margin");
    }

    void padding(double left, double top, double right, double bottom)
    {
        checkStatus(avd_set_padding(handle, left, top, right, bottom), "set_padding");
    }

    void fontSize(double points)
    {
        checkStatus(avd_set_font_size(handle, points), "set_font_size");
    }

    void addClass(string className)
    {
        checkStatus(avd_add_class(handle, className.toStringz), "add_class");
    }

    protected void bindVoid(da_avd_on_click native, string what, void delegate() dg)
    {
        auto root = new CallbackRoot(dg);
        GC.addRoot(cast(void*) root);
        roots ~= root;
        checkStatus(native(handle, &trampoline, cast(void*) root), what);
    }
}

class Panel : Widget
{
    this(AvdHandle handle)
    {
        super(handle);
    }

    void add(Widget child)
    {
        checkStatus(avd_panel_add(handle, child.handle), "panel_add");
    }
}

class Window : Widget
{
    this(string title, int width = 800, int height = 600)
    {
        super(avd_window_new(title.toStringz, width, height));
    }

    void content(Widget child)
    {
        checkStatus(avd_window_set_content(handle, child.handle), "window_set_content");
    }

    void run()
    {
        checkStatus(avd_run(handle), "run");
    }
}

class Stack : Panel
{
    this(Orientation orientation = Orientation.vertical)
    {
        super(avd_stack_new(cast(int) orientation));
    }

    void spacing(double value)
    {
        checkStatus(avd_set_spacing(handle, value), "set_spacing");
    }
}

class Scroll : Panel
{
    this()
    {
        super(avd_scroll_new());
    }
}

class Button : Widget
{
    this(string label)
    {
        super(avd_button_new(label.toStringz));
    }

    void onClick(void delegate() dg)
    {
        bindVoid(avd_on_click, "on_click", dg);
    }
}

class Text : Widget
{
    this(string value)
    {
        super(avd_text_new(value.toStringz));
    }
}

class TextBox : Widget
{
    this(string value = "")
    {
        super(avd_textbox_new(value.toStringz));
    }

    void onChange(void delegate() dg)
    {
        bindVoid(avd_on_text_changed, "on_text_changed", dg);
    }
}

class CheckBox : Widget
{
    this(string label, bool isChecked = false)
    {
        super(avd_checkbox_new(label.toStringz, isChecked ? 1 : 0));
    }

    void checked(bool value)
    {
        checkStatus(avd_set_checked(handle, value ? 1 : 0), "set_checked");
    }

    bool checked()
    {
        auto v = avd_get_checked(handle);
        checkStatus(v, "get_checked");
        return v != 0;
    }

    void onChange(void delegate() dg)
    {
        bindVoid(avd_on_checked_changed, "on_checked_changed", dg);
    }
}

class Separator : Widget
{
    this(Orientation orientation = Orientation.horizontal)
    {
        super(avd_separator_new(cast(int) orientation));
    }
}

class Card : Panel
{
    this()
    {
        super(avd_card_new());
    }

    void header(Widget child)
    {
        checkStatus(avd_card_set_header(handle, child.handle), "card_set_header");
    }

    void footer(Widget child)
    {
        checkStatus(avd_card_set_footer(handle, child.handle), "card_set_footer");
    }
}

class CardTitle : Widget
{
    this(string value)
    {
        super(avd_card_title_new(value.toStringz));
    }
}

class CardDescription : Widget
{
    this(string value)
    {
        super(avd_card_description_new(value.toStringz));
    }
}
