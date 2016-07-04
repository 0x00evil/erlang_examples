-module(scavenge_urls).
-export([urls2htmlFile/2, bin2urls/1]).
-import(lists, [reverse/1, reverse/2, map/2]).

urls2htmlFile(File, Urls) ->
    file:write(File, urls2html(Urls)).

bin2urls(Bin) ->
    gather_urls(binary_to_list(Bin), []).

urls2html(Urls) ->
    [h1("Urls"), make_list(Urls)].

h1(Title) ->
    ["<h1>", Title, "</h1>"].

make_list(L) ->
    ["<ul>\n",
     map(fun(I) -> ["<li>", I, "</li>"] end, L),
     "</ul>\n"].
