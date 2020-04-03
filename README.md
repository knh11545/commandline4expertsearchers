Command line tools for the expert searcher: Some applied library carpentry
==========================================================================

Author: Helge Knüttel

Towards a poster presentation at [EAHIL 2020](https://eahil2020.wordpress.com/).


## General

TODO: Should we cover editors such as vim?

https://www.gnu.org/software/coreutils/manual/coreutils.html#Opening-the-software-toolbox

## Use cases

### Retrieving search results

The new PubMed no longer supports downloading records in MEDLINE or XML format. But we can do this with [EDirect](https://www.ncbi.nlm.nih.gov/books/NBK179288/):


1. Save your search results as a list of PMIDs as a file, e.g. pmid.txt.
2. On the command line with bash run

```{bash}
cat pmid.txt | epost -db pubmed | efetch -format medline > medline.txt
```

This yields the records in MEDLINE format in the file medline.txt. This works for large numbers of records.

### Checking search results

### Comparing search results

The `comm` tool compares sorted files FILE1 and FILE2 line by line. We can use this to work on files containing accession numbers from search results.

See 

* https://catonmat.net/set-operations-in-unix-shell-simplified
* https://www.gnu.org/software/coreutils/manual/html_node/Set-operations.html



### Postprocessing search result for easier import

Unite search results that had to be exported in chunks.

See D:\dimdi\_templates\unite_wos_files.bash


#### Deduplicating search results (partially)

Split a RIS export file into records (with perl):

(From Perl Cookbook, Chapter 6.7. Reading Records with a Pattern Separator)

```{bash}
cat huge_CINAHL.ris | perl -e '{ local $/ = undef; @chunks = split(/\nER  -\s*\n/, <>); } print "I read ", scalar(@chunks), " c
hunks.\n";'
```
TODO: Load a list of PMIDs (DOIs or other such numbers) and remove matching records.

Auf dem Weg dahin: 

```{bash}
cat huge_CINAHL.ris | perl -e 'my $findme = "NLM31125709"; my $matches = 0; { local $/ = undef; @chunks = split(/\nER  -\s*\n/, <>); foreach (@chunks) { if (m/\Q$findme/) { print "Found ", $findme, "\n"; $matches++; } } } print "I read ", scalar(@chunks), " chunks.\nI found ", $matches, " matches\n";'
# Use \Q if $findme may contain special chars for a regexp
```

Auch die perl-Funktion grep ansehen, vielleicht kann man damit viele Pattern überprüfen?
Siehe die erste Antwort in <https://www.perlmonks.org/?node_id=391416>


### Building query strings

#### Reverse the order of lines in search strategy

Search interfaces often show the lines in a search strategy such that the last search statement is on top. This order may persist in an exported search strategy (e.g. by copying from a browser window). But this order is inconvenient when the search strategy should be entered again into a search interface, possibly after some modifications. It is easy to reverse the order of lines with the `tac` tool (Mnemonic: This is the reverse of `cat`).

```bash
tac my_old_stategy.txt > stategy_with_lines_reversed.txt
```

In vim there basically are two options:

* Call `tac`, e.g. `:%!tac` for the wole buffer.
* Use vim's features: `:g/^/m0`

For more info see <https://vim.fandom.com/wiki/Reverse_order_of_lines>.

### Updating searches

### Documenting searches

### Searching for patterns that are not supported by search interfaces

* Use command line tools like grep to post-process a selected number of records (from a more general search) that was downloaded
* Use local phrase searching using eDirect and a local copy of PubMed

### Build custom export formats

The new PubMed interface does not support the rich MEDLINE export format. Convert XML records to MEDLINE format?

## Installation of Entrez Direct

Entrez Direct (EDirect) needs to be installed. This is easy with a Linux or Macintosh system where the prerequisites already are available (a bash shell and Perl). For my Windows 10 PC I found it easiest to go via [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows) and then use the [official NCBI/NLM Docker image for edirect](https://hub.docker.com/r/ncbi/edirect). 

Once Docker for Windows is installed and running open a PowerShell to pull the EDirect image (only once) and start it:

```{PowerShell}
docker pull ncbi/edirect
docker run -it --rm ncbi/edirect
```

To share a directory:

```{bash}
```

```{bash}
```
