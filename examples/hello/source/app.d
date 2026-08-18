import avalonia;
import std.stdio;

void main()
{
    init(ThemeMode.dark);

    auto win = new Window("avalonia-d", 420, 240);
    auto col = new Stack(Orientation.vertical);
    col.margin(24, 24, 24, 24);
    col.spacing = 12;

    col.add(new Text("Hello from D + Avalonia + ShadUI"));
    auto btn = new Button("Close");
    btn.onClick({
        writeln("clicked");
        // Closing is the window chrome for now; this proves the callback.
    });
    col.add(btn);

    win.content = col;
    win.run();
}
