module avalonia.exception;

class AvaloniaException : Exception
{
    int code;

    this(int code, string msg, string file = __FILE__, size_t line = __LINE__)
    {
        this.code = code;
        super(msg, file, line);
    }
}
