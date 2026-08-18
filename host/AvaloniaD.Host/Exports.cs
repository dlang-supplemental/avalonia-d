using System.Runtime.InteropServices;

namespace AvaloniaD.Host;

public static unsafe class Exports
{
    [UnmanagedCallersOnly(EntryPoint = "avd_version")]
    public static IntPtr Version() => Host.VersionPtr();

    [UnmanagedCallersOnly(EntryPoint = "avd_last_error")]
    public static IntPtr LastError() => Host.LastErrorPtr();

    [UnmanagedCallersOnly(EntryPoint = "avd_init")]
    public static int Init(int themeMode)
    {
        try { return Host.Init(themeMode); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_shutdown")]
    public static int Shutdown()
    {
        try { return Host.Shutdown(); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_switch_theme")]
    public static int SwitchTheme(int themeMode)
    {
        try { return Host.SwitchTheme(themeMode); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_window_new")]
    public static ulong WindowNew(IntPtr title, int width, int height)
    {
        try { return Host.WindowNew(title, width, height); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_stack_new")]
    public static ulong StackNew(int orientation)
    {
        try { return Host.StackNew(orientation); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_scroll_new")]
    public static ulong ScrollNew()
    {
        try { return Host.ScrollNew(); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_button_new")]
    public static ulong ButtonNew(IntPtr text)
    {
        try { return Host.ButtonNew(text); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_text_new")]
    public static ulong TextNew(IntPtr text)
    {
        try { return Host.TextNew(text); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_textbox_new")]
    public static ulong TextBoxNew(IntPtr text)
    {
        try { return Host.TextBoxNew(text); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_checkbox_new")]
    public static ulong CheckBoxNew(IntPtr text, int isChecked)
    {
        try { return Host.CheckBoxNew(text, isChecked); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_separator_new")]
    public static ulong SeparatorNew(int orientation)
    {
        try { return Host.SeparatorNew(orientation); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_card_new")]
    public static ulong CardNew()
    {
        try { return Host.CardNew(); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_card_title_new")]
    public static ulong CardTitleNew(IntPtr text)
    {
        try { return Host.CardTitleNew(text); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_card_description_new")]
    public static ulong CardDescriptionNew(IntPtr text)
    {
        try { return Host.CardDescriptionNew(text); }
        catch (Exception ex) { Host.Fail(ex); return 0; }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_panel_add")]
    public static int PanelAdd(ulong parent, ulong child)
    {
        try { return Host.PanelAdd(parent, child); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_card_set_header")]
    public static int CardSetHeader(ulong card, ulong header)
    {
        try { return Host.CardSetHeader(card, header); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_card_set_footer")]
    public static int CardSetFooter(ulong card, ulong footer)
    {
        try { return Host.CardSetFooter(card, footer); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_window_set_content")]
    public static int WindowSetContent(ulong window, ulong content)
    {
        try { return Host.WindowSetContent(window, content); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_text")]
    public static int SetText(ulong handle, IntPtr text)
    {
        try { return Host.SetText(handle, text); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_get_text")]
    public static int GetText(ulong handle, IntPtr buf, int cap)
    {
        try { return Host.GetText(handle, buf, cap); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_checked")]
    public static int SetChecked(ulong handle, int value)
    {
        try { return Host.SetChecked(handle, value); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_get_checked")]
    public static int GetChecked(ulong handle)
    {
        try { return Host.GetChecked(handle); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_enabled")]
    public static int SetEnabled(ulong handle, int value)
    {
        try { return Host.SetEnabled(handle, value); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_width")]
    public static int SetWidth(ulong handle, double width)
    {
        try { return Host.SetWidth(handle, width); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_height")]
    public static int SetHeight(ulong handle, double height)
    {
        try { return Host.SetHeight(handle, height); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_margin")]
    public static int SetMargin(ulong handle, double left, double top, double right, double bottom)
    {
        try { return Host.SetMargin(handle, left, top, right, bottom); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_padding")]
    public static int SetPadding(ulong handle, double left, double top, double right, double bottom)
    {
        try { return Host.SetPadding(handle, left, top, right, bottom); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_spacing")]
    public static int SetSpacing(ulong handle, double spacing)
    {
        try { return Host.SetSpacing(handle, spacing); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_set_font_size")]
    public static int SetFontSize(ulong handle, double points)
    {
        try { return Host.SetFontSize(handle, points); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_add_class")]
    public static int AddClass(ulong handle, IntPtr className)
    {
        try { return Host.AddClass(handle, className); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_on_click")]
    public static int OnClick(ulong handle, IntPtr cb, IntPtr user)
    {
        try { return Host.OnClick(handle, cb, user); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_on_text_changed")]
    public static int OnTextChanged(ulong handle, IntPtr cb, IntPtr user)
    {
        try { return Host.OnTextChanged(handle, cb, user); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_on_checked_changed")]
    public static int OnCheckedChanged(ulong handle, IntPtr cb, IntPtr user)
    {
        try { return Host.OnCheckedChanged(handle, cb, user); }
        catch (Exception ex) { return Host.Fail(ex); }
    }

    [UnmanagedCallersOnly(EntryPoint = "avd_run")]
    public static int Run(ulong window)
    {
        try { return Host.Run(window); }
        catch (Exception ex) { return Host.Fail(ex); }
    }
}
