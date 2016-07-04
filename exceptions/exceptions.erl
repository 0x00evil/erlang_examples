-module(exceptions).
-compile(export_all).

whoa() ->
    try
        _A = "a",
        _B = "b",
        throw(up),
        a
    of
        a ->
            io:format("try successfully")
    catch
        Exception:Reason ->
            {caught, Exception, Reason}
    end.

im_impressed() ->
    try
        _A = "a",
        _B = "b",
        throw(up),
        a
    catch
        Exception:Reason ->
            {caught, Exception, Reason}
    end.
