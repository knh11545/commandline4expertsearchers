EBSCOhost
==============================================================================


## Document a search history from EBSCOhost

EBSCOhost does not provide a text-only format of a search history. Here is what I do to document a search history. This works with my Firefox browser.

1. Click _Search History_ underneath the search form to display it if not already shown.
2. Click _Print Search History_ link above the search history.
3. A new browser window with a printer-friendly HTML-version of the search history will open.
4. Type `Ctrl-S` to save the file. Choose _Text Files (*.txt;*.text)_ as format and save to a file. 

In this text file there is some irrelevant header stuff followed by the search history in kind of a tabular format followed by some irrelevant footer. The search history is in a tab-separated format but with an unpredictable number of line breaks in the search statements. Editing this manually is a hassle. I edit this file in the `vim` editor to create a clean tab-separated format:

6. Go to the search history section in the file.
7. Hit `vip` in normal mode (*v*isually select *i*nner *p*aragraph) to select the entire search history.
8. Join all lines belonging to a single search: `:'<,'>v/^S\d\+ ^I\|^# ^I/normal kJ`
  * `'<,'>` in the visual selection,
  * `v` in all lines NOT matching (reverse of `g` command) the following pattern
    + `^S\d\+ ^I` line starts with S, digit(s), blank and tab character (shown as `^I`) OR (`|`)
    + `^# ^I` line starts with a hash character, a blank and a tab,
  * in normal mode go one line up `k` and join `J` the line below.
9. Done.

