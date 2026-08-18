using System.Collections.Concurrent;
using System.Runtime.InteropServices;
using System.Text;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Controls.Documents;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Controls.Primitives;
using Avalonia.Layout;
using Avalonia.Media;
using ShadUI;

namespace AvaloniaD.Host;

internal static class Host
{
    public const string Version = "0.1.0";

    private static readonly object Gate = new();
    private static readonly ConcurrentDictionary<ulong, object> Handles = new();
    private static ulong _next = 1;
    private static string _lastError = "";
    private static IntPtr _lastErrorUtf8 = Marshal.StringToCoTaskMemUTF8("");
    private static readonly IntPtr VersionUtf8 = Marshal.StringToCoTaskMemUTF8(Version);

    private static ClassicDesktopStyleApplicationLifetime? _lifetime;
    private static ThemeWatcher? _themeWatcher;
    private static bool _initialized;

    internal static int Fail(Exception ex)
    {
        SetError(ex.ToString());
        return -1;
    }

    internal static int Fail(int code, string message)
    {
        SetError(message);
        return code;
    }

    private static void SetError(string message)
    {
        _lastError = message ?? "";
        if (_lastErrorUtf8 != IntPtr.Zero)
            Marshal.FreeCoTaskMem(_lastErrorUtf8);
        _lastErrorUtf8 = Marshal.StringToCoTaskMemUTF8(_lastError);
    }

    internal static IntPtr VersionPtr() => VersionUtf8;

    internal static IntPtr LastErrorPtr() => _lastErrorUtf8;

    private static string? ReadUtf8(IntPtr ptr)
    {
        if (ptr == IntPtr.Zero)
            return "";
        return Marshal.PtrToStringUTF8(ptr);
    }

    private static ulong Store(object obj)
    {
        var id = Interlocked.Increment(ref _next);
        Handles[id] = obj;
        return id;
    }

    private static bool TryGet<T>(ulong id, out T value) where T : class
    {
        value = null!;
        if (!Handles.TryGetValue(id, out var obj) || obj is not T typed)
            return false;
        value = typed;
        return true;
    }

    internal static int Init(int themeMode)
    {
        lock (Gate)
        {
            if (_initialized)
                return Fail(-3, "avalonia-d already initialized");

            SetError("");

            var lifetime = new ClassicDesktopStyleApplicationLifetime
            {
                Args = [],
                ShutdownMode = ShutdownMode.OnMainWindowClose,
            };

            AppBuilder.Configure<Application>()
                .UsePlatformDetect()
                .WithInterFont()
                .AfterSetup(b =>
                {
                    var app = b.Instance ?? throw new InvalidOperationException("Avalonia Application missing after setup");
                    app.Styles.Add(new ShadTheme());
                    _themeWatcher = new ThemeWatcher(app);
                    _themeWatcher.Initialize();
                    _themeWatcher.SwitchTheme(ToThemeMode(themeMode));
                })
                .SetupWithLifetime(lifetime);

            _lifetime = lifetime;
            _initialized = true;
            return 0;
        }
    }

    internal static int Shutdown()
    {
        lock (Gate)
        {
            try
            {
                _lifetime?.Shutdown();
            }
            catch (Exception ex)
            {
                return Fail(ex);
            }
            finally
            {
                Handles.Clear();
                _lifetime = null;
                _themeWatcher = null;
                _initialized = false;
            }

            return 0;
        }
    }

    internal static int SwitchTheme(int themeMode)
    {
        if (!_initialized)
            return Fail(-2, "avalonia-d not initialized");
        try
        {
            _themeWatcher?.SwitchTheme(ToThemeMode(themeMode));
            return 0;
        }
        catch (Exception ex)
        {
            return Fail(ex);
        }
    }

    private static ThemeMode ToThemeMode(int themeMode) => themeMode switch
    {
        1 => ThemeMode.Light,
        2 => ThemeMode.Dark,
        _ => ThemeMode.System,
    };

    internal static ulong WindowNew(IntPtr title, int width, int height)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            var win = new AvdWindow
            {
                Title = ReadUtf8(title) ?? "Avalonia",
                Width = width > 0 ? width : 800,
                Height = height > 0 ? height : 600,
            };
            return Store(win);
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong StackNew(int orientation)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            var stack = new StackPanel
            {
                Orientation = orientation == 0 ? Orientation.Horizontal : Orientation.Vertical,
                Spacing = 8,
            };
            return Store(stack);
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong ScrollNew()
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new ScrollViewer
            {
                HorizontalScrollBarVisibility = ScrollBarVisibility.Disabled,
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
            });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong ButtonNew(IntPtr text)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            var btn = new Button { Content = ReadUtf8(text) ?? "" };
            btn.Classes.Add("Primary");
            return Store(btn);
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong TextNew(IntPtr text)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new TextBlock { Text = ReadUtf8(text) ?? "", TextWrapping = TextWrapping.Wrap });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong TextBoxNew(IntPtr text)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new TextBox { Text = ReadUtf8(text) ?? "" });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong CheckBoxNew(IntPtr text, int isChecked)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new CheckBox
            {
                Content = ReadUtf8(text) ?? "",
                IsChecked = isChecked != 0,
            });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong SeparatorNew(int orientation)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new Separator
            {
                Width = orientation == 0 ? double.NaN : 1,
                Height = orientation == 0 ? 1 : double.NaN,
            });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong CardNew()
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new Card { HasShadow = true });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong CardTitleNew(IntPtr text)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new CardTitle { Content = ReadUtf8(text) ?? "" });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static ulong CardDescriptionNew(IntPtr text)
    {
        if (!_initialized)
        {
            Fail(-2, "avalonia-d not initialized");
            return 0;
        }

        try
        {
            return Store(new CardDescription { Content = ReadUtf8(text) ?? "" });
        }
        catch (Exception ex)
        {
            Fail(ex);
            return 0;
        }
    }

    internal static int PanelAdd(ulong parent, ulong child)
    {
        if (!TryGet<Control>(child, out var childCtl))
            return Fail(-4, "invalid child handle");

        if (TryGet<Panel>(parent, out var panel))
        {
            panel.Children.Add(childCtl);
            return 0;
        }

        if (TryGet<ContentControl>(parent, out var content) && content is not Card)
        {
            content.Content = childCtl;
            return 0;
        }

        if (TryGet<ScrollViewer>(parent, out var scroll))
        {
            scroll.Content = childCtl;
            return 0;
        }

        if (TryGet<Card>(parent, out var card))
        {
            card.Content = childCtl;
            return 0;
        }

        return Fail(-5, "parent cannot accept children");
    }

    internal static int CardSetHeader(ulong cardId, ulong headerId)
    {
        if (!TryGet<Card>(cardId, out var card))
            return Fail(-5, "handle is not a Card");
        if (!TryGet<object>(headerId, out var header))
            return Fail(-4, "invalid header handle");
        card.Header = header;
        return 0;
    }

    internal static int CardSetFooter(ulong cardId, ulong footerId)
    {
        if (!TryGet<Card>(cardId, out var card))
            return Fail(-5, "handle is not a Card");
        if (!TryGet<object>(footerId, out var footer))
            return Fail(-4, "invalid footer handle");
        card.Footer = footer;
        return 0;
    }

    internal static int WindowSetContent(ulong windowId, ulong contentId)
    {
        if (!TryGet<AvdWindow>(windowId, out var win))
            return Fail(-5, "handle is not a Window");
        if (!TryGet<Control>(contentId, out var content))
            return Fail(-4, "invalid content handle");
        win.Content = content;
        return 0;
    }

    internal static int SetText(ulong id, IntPtr text)
    {
        var value = ReadUtf8(text) ?? "";
        if (TryGet<TextBlock>(id, out var tb))
        {
            tb.Text = value;
            return 0;
        }

        if (TryGet<TextBox>(id, out var box))
        {
            box.Text = value;
            return 0;
        }

        if (TryGet<Button>(id, out var btn))
        {
            btn.Content = value;
            return 0;
        }

        if (TryGet<CheckBox>(id, out var cb))
        {
            cb.Content = value;
            return 0;
        }

        if (TryGet<ContentControl>(id, out var cc))
        {
            cc.Content = value;
            return 0;
        }

        if (TryGet<AvdWindow>(id, out var win))
        {
            win.Title = value;
            return 0;
        }

        return Fail(-5, "handle does not support text");
    }

    internal static int GetText(ulong id, IntPtr buf, int cap)
    {
        if (buf == IntPtr.Zero || cap <= 0)
            return Fail(-1, "invalid output buffer");

        string? text = null;
        if (TryGet<TextBlock>(id, out var tb))
            text = tb.Text;
        else if (TryGet<TextBox>(id, out var box))
            text = box.Text;
        else if (TryGet<Button>(id, out var btn))
            text = btn.Content?.ToString();
        else if (TryGet<CheckBox>(id, out var cb))
            text = cb.Content?.ToString();
        else if (TryGet<ContentControl>(id, out var cc) && cc.Content is string s)
            text = s;
        else if (TryGet<AvdWindow>(id, out var win))
            text = win.Title;

        if (text is null)
            return Fail(-5, "handle does not support text");

        var bytes = Encoding.UTF8.GetBytes(text);
        var n = Math.Min(bytes.Length, cap - 1);
        Marshal.Copy(bytes, 0, buf, n);
        Marshal.WriteByte(buf, n, 0);
        return n;
    }

    internal static int SetChecked(ulong id, int value)
    {
        if (!TryGet<CheckBox>(id, out var cb))
            return Fail(-5, "handle is not a CheckBox");
        cb.IsChecked = value != 0;
        return 0;
    }

    internal static int GetChecked(ulong id)
    {
        if (!TryGet<CheckBox>(id, out var cb))
            return Fail(-5, "handle is not a CheckBox");
        return cb.IsChecked == true ? 1 : 0;
    }

    internal static int SetEnabled(ulong id, int value)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        ctl.IsEnabled = value != 0;
        return 0;
    }

    internal static int SetWidth(ulong id, double width)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        ctl.Width = width;
        return 0;
    }

    internal static int SetHeight(ulong id, double height)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        ctl.Height = height;
        return 0;
    }

    internal static int SetMargin(ulong id, double l, double t, double r, double b)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        ctl.Margin = new Thickness(l, t, r, b);
        return 0;
    }

    internal static int SetPadding(ulong id, double l, double t, double r, double b)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        var pad = new Thickness(l, t, r, b);
        if (ctl is TemplatedControl tc)
            tc.Padding = pad;
        else if (ctl is Decorator dec)
            dec.Padding = pad;
        else
            return Fail(-5, "handle does not support padding");
        return 0;
    }

    internal static int SetSpacing(ulong id, double spacing)
    {
        if (!TryGet<StackPanel>(id, out var stack))
            return Fail(-5, "handle is not a StackPanel");
        stack.Spacing = spacing;
        return 0;
    }

    internal static int SetFontSize(ulong id, double points)
    {
        if (!TryGet<Control>(id, out var ctl))
            return Fail(-4, "invalid handle");
        ctl.SetValue(TextElement.FontSizeProperty, points);
        return 0;
    }

    internal static int AddClass(ulong id, IntPtr className)
    {
        if (!TryGet<StyledElement>(id, out var el))
            return Fail(-4, "invalid handle");
        var name = ReadUtf8(className);
        if (string.IsNullOrEmpty(name))
            return Fail(-6, "empty class name");
        if (!el.Classes.Contains(name))
            el.Classes.Add(name);
        return 0;
    }

    internal static unsafe int OnClick(ulong id, IntPtr cb, IntPtr user)
    {
        if (cb == IntPtr.Zero)
            return Fail(-1, "null callback");
        if (!TryGet<Button>(id, out var btn))
            return Fail(-5, "handle is not a Button");

        var fn = (delegate* unmanaged<IntPtr, void>)cb;
        btn.Click += (_, _) =>
        {
            try
            {
                fn(user);
            }
            catch
            {
                // Native callbacks must not throw across the ABI.
            }
        };
        return 0;
    }

    internal static unsafe int OnTextChanged(ulong id, IntPtr cb, IntPtr user)
    {
        if (cb == IntPtr.Zero)
            return Fail(-1, "null callback");
        if (!TryGet<TextBox>(id, out var box))
            return Fail(-5, "handle is not a TextBox");

        var fn = (delegate* unmanaged<IntPtr, void>)cb;
        box.TextChanged += (_, _) =>
        {
            try
            {
                fn(user);
            }
            catch
            {
            }
        };
        return 0;
    }

    internal static unsafe int OnCheckedChanged(ulong id, IntPtr cb, IntPtr user)
    {
        if (cb == IntPtr.Zero)
            return Fail(-1, "null callback");
        if (!TryGet<CheckBox>(id, out var box))
            return Fail(-5, "handle is not a CheckBox");

        var fn = (delegate* unmanaged<IntPtr, void>)cb;
        box.IsCheckedChanged += (_, _) =>
        {
            try
            {
                fn(user);
            }
            catch
            {
            }
        };
        return 0;
    }

    internal static int Run(ulong windowId)
    {
        if (!_initialized || _lifetime is null)
            return Fail(-2, "avalonia-d not initialized");
        if (!TryGet<AvdWindow>(windowId, out var win))
            return Fail(-5, "handle is not a Window");

        try
        {
            _lifetime.MainWindow = win;
            _lifetime.Start([]);
            return 0;
        }
        catch (Exception ex)
        {
            return Fail(ex);
        }
    }
}
