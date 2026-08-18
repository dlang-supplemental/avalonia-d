import avalonia;
import std.stdio;

void main()
{
    init(ThemeMode.dark);

    auto win = new Window("avalonia-d gallery", 560, 420);

    auto scroll = new Scroll();
    auto page = new Stack(Orientation.vertical);
    page.margin(24, 24, 24, 24);
    page.spacing = 16;

    auto heading = new Text("ShadUI from D");
    heading.fontSize = 24;
    page.add(heading);
    page.add(new Text("Avalonia stays primitive; these controls come from ShadUI (shadcn-inspired)."));

    auto card = new Card();
    card.header(new CardTitle("Sign in"));
    card.add(new CardDescription("A small form assembled from the C ABI host."));

    auto body = new Stack(Orientation.vertical);
    body.spacing = 10;
    body.margin(0, 8, 0, 8);

    auto name = new TextBox("ada@example.com");
    name.width = 320;
    body.add(new Text("Email"));
    body.add(name);

    auto remember = new CheckBox("Remember me", true);
    remember.onChange({
        writeln("remember=", remember.checked);
    });
    body.add(remember);
    card.add(body);

    auto actions = new Stack(Orientation.horizontal);
    actions.spacing = 8;
    auto ghost = new Button("Cancel");
    ghost.addClass("Ghost");
    auto primary = new Button("Continue");
    primary.onClick({
        writeln("continue as ", name.text);
    });
    actions.add(ghost);
    actions.add(primary);
    card.footer(actions);

    page.add(card);
    scroll.add(page);
    win.content = scroll;
    win.run();
}
