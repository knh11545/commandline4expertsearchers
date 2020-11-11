" ovd_search-history2tsv.vim
"
" vim script to convert a text file with a search history as exported
" from Ovid into a TSV file, i.e. a tabular format that can easily be imported
" into Excel, Word etc.
"
" Usage: :source ovd_search-history2tsv.vim
"
" Author: Helge Knüttel, helge.knuettel@ur.de
" Date: 2018-12-13
"
"
" Set filename of TSV file
let tsv_file = expand('%:r') . ".tsv"
" Save as TSV file
" Beware: We will overwrite an existing file!
exec 'saveas!' tsv_file

"
" Convert search history to TSV 
"

" Remove carriage returns
%s/\r//
" Tab after statement number
%s/^\(\d\+\) \{5\}/\1\t/
" Put number of records into separate column
g/^\d\+\t/ s/ (\(\d\+\))$/\t\1\t/
" Move annotations in [] at the end of search statements to a separate column
" at the end of line
g/^\d\+\t/ s/\[\(.*\)\]\(.*\)/\2\1/
g/^\d\+\t/ s/$/\t/
" Put Annotations on separate lines into a column
g/^Annotation: /,/^\d\+\t/-1 join
g/^Annotation: /-1 join
%s/\tAnnotation: /\t/
" Add column names
" An empty line above makes later copying easier.
g/^1\t/-1 put _
" You can safely comment/delete one of the following two lines
g/^1\t/ normal OSuchschritt	Suchbefehl	Trefferzahl	Bemerkung 1	Bemerkung 2
g/^1\t/ normal OStatement identifier	Search statement	Record count	Annotation 1	Annotation 2

" Remove all records after the search history
g/^<1>$/ normal dG

" We leave it up to the user to write the altered file
