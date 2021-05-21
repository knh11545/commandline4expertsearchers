Command line tools for the expert searcher: Some applied library carpentry
==========================================================================

Author: Helge Knüttel

This repository started to give more information and code as a background for a poster presented at the [2020 conference](https://eahil2020.wordpress.com/) of [EAHIL](http://eahil.eu/) intended to happen in Lodz, Poland but was then held as an online event due to the COVID-19 pandemic. It is intendend that the use-cases and code sections will be extended in the future.

All stuff related to the actual poster incl. the [poster pdf](./poster/Poster_EAHIL_2020.pdf) and the [abstract](./poster/abstract_submitted.md) are found in the [poster](./poster/) folder.


[[_TOC_]]


## General

Medical librarians/information specialists providing mediated, systematic searches are dealing a lot with text data when developing search strategies, handling search results and documenting the search process. Dedicated software such as reference managers as wells as general word processors are usually employed in these tasks. Yet, a lot of manual work remains and many functions wanted are not or not well supported by these programs. Classic command line tools do not seem to be well known by many expert searchers nowadays but could be candidates for easier, semi-automated workflows. These tools are freely available or even already installed on many computers.

What do I mean by the term "command line" here?  

Two things, actually:

*  One of the [shell programs](https://en.wikipedia.org/wiki/Shell_(computing)) commonly used with Unix-like operating systems that provide the [command line interface](https://en.wikipedia.org/wiki/Command-line_interface) used to interact with the computer (e.g. [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))) and
*  a basic set of programs expected to exist on every such system. In particular, these are the the [GNU core utilities (Coreutils)](https://www.gnu.org/software/coreutils/) and the non-interactive text editor [sed](https://www.gnu.org/software/sed/).

### Tutorials for learning the command line

* [FLOSS Manuals: Command line](http://write.flossmanuals.net/command-line/introduction/): An introduction into using the command line.
* [Openning the software toolbox](https://www.gnu.org/software/coreutils/manual/coreutils.html#Opening-the-software-toolbox): The spirit of combining many small tools to acheive what you need.
* [Sh - the POSIX Shell ](https://www.grymoire.com/Unix/Sh.html): Specifics on the POSIC shell. Might help to create more portable scripts.



## Use cases

A number of typical tasks in systematic searching was identified where additional software support was wanted and a solution seemed feasible with limited resources. These tasks and the need arose from the author's own practice and communication with colleagues. Commands to be entered at the command line were developed that work on simple text files containing text data such as query strings, database accession numbers, search results and search strategies exported from search interfaces.

<!-- GitHub wil not render the Mermaid code (now in poster/use_cases.mermaid); show image instead. -->

![Graph of use cases](poster/mermaid-diagram.svg)

Some example files with bibliographic data are in the `test/data` folder, see the [README.md](test/data/README.md) file there.


### Checking search results

Search results are ususally exported from databases and then imported in to reference management software or other systematic review software. It is helpful to be able to do some basic data sanity checks on the structured text files that were exported due to a number of reasons. The export process may yield erroneous results especially when restrictions by the host interface force the expert searcher to download larger result sets in smaller chunks (a tedious and error-prone process). There may be duplicate records even when exporting from a single database (which stands in contrast to vendor's documentation). And some records may be corrupt or formatted in a way such that the import filter of reference management software fails.


#### Ovid MEDLINE and Ovid Embase

##### Count the records in a single export file

Export result are in a single file in Citavi (\*.ovd), Endnote (\*.cgi) or ReferenceManager (\*.ovd) format (Fields: _Complete Reference_). This works for ovd- and cgi-files:

```bash
grep --count "^DB  - Embase" myproject_EMBASE_2018-12-13_records-combined.ovd
```

**Result**:

```
3831
```


##### Count the records in a batch of export files

After exporting results in portions of the allowed maximum of 1,000 records count the records in each of the exported files:

```bash
for file in `find . -name 'myproject_EMBASE_2018-12-13_r*-*.cgi' -print` ; do echo $file;  grep "^DB  - Embase" $file | wc -l ; done
```

```
./myproject_EMBASE_2018-12-13_r0001-1000.ovd
1000
./myproject_EMBASE_2018-12-13_r1001-2000.ovd
1000
./myproject_EMBASE_2018-12-13_r2001-3000.ovd
1000
./myproject_EMBASE_2018-12-13_r3001-3831.ovd
831
```

**Result**: The individual files contain the expected numbers of records with a total of 3831 records.


##### Check for duplicate records in export files

Usually, in larger result sets there are duplicate records, i.e. records that carry identical accession numbers. This is in contrast to the database documentation ([MEDLINE](http://ospguides.ovid.com/OSPguides/medline.htm#UI), [Embase](http://ospguides.ovid.com/OSPguides/embase.htm#an)).  

First, we check for duplicates _in each export file_. Accession numbers are in the UI field in the export files for both MEDLINE and Embase:

```bash
for file in `find . -name 'myproject_EMBASE_2018-12-13_r*-*.ovd' -print` ; do echo $file;  grep "^UI  - " $file | sort | uniq | wc -l ; done
```

```
./myproject_EMBASE_2018-12-13_r0001-1000.ovd
983
./myproject_EMBASE_2018-12-13_r1001-2000.ovd
1000
./myproject_EMBASE_2018-12-13_r2001-3000.ovd
1000
./myproject_EMBASE_2018-12-13_r3001-3831.ovd
831
```

**Result**: 17 duplicate records were omitted when counting unique accession numbers in the first export file.  

Notice that the field names used in the export files are not necessarily the same as when searching the databases.  

Finally, we count the unique records _accross all export files_. This number of unique records should not be off to far from the total number of records, say at most a few dozen. If the unique records are below the total by 1,000 or more chances a high that we erroneously exported a chunk of records twice (and ommitted another chunck).

```bash
grep --no-filename "^UI  - " myproject_EMBASE_2018-12-13_r*-*.ovd | sort | uniq | wc -l
```

```
3813
```

**Result**: In the 3831 records of the search result there are 3813 unique records. We did not fail to export a chunk.



#### Web of Science (Core Collection)

Export format _Other reference software_, record content _Full record_.


##### Count the records in a single export file

```
grep --count "^ER$" test/data/WoS_other_reference_software_records_combined.txt
```

**Result**:

```
4012
```

##### Count the records in a batch of export files

After exporting a larger result set in portions of the allowed maximum of 500 records count the records in each export file:

```bash
for file in `find . -name 'WoS_other_reference_software_r*-*.txt' -print` ; do echo $file;  grep --count "^ER$" $file ; done
```

```
./test/data/WoS_other_reference_software_r0001-0500.txt
500
./test/data/WoS_other_reference_software_r0501-1000.txt
500
./test/data/WoS_other_reference_software_r1001-1500.txt
500
./test/data/WoS_other_reference_software_r1501-2000.txt
500
./test/data/WoS_other_reference_software_r2001-2500.txt
500
./test/data/WoS_other_reference_software_r2501-3000.txt
500
./test/data/WoS_other_reference_software_r3001-3500.txt
500
./test/data/WoS_other_reference_software_r3501-4000.txt
500
./test/data/WoS_other_reference_software_r4001-4012.txt
12
```

**Result**: The individual files contain the expected numbers of records with a total of 4012 records.

Then, we count the unique accession numbers of the records _accross all export files_. This number of unique records should be identical to the total number of records. If not chances a high that we erroneously exported a chunk of records twice (and ommitted another chunck).

```bash
grep --no-filename "^UT " test/data/WoS_other_reference_software_r*-*.txt | sort | uniq | wc -l
```

**Result**:

```
4012
```

**Result**: In the 4012 records of the search result there are 4012 unique records. We did not fail to export a chunk.



#### PubMed

Count the records in a single export file in PubMed format (was called MEDLINE format in legacy PubMed):

```bash
grep --count "^PMID- " test/data/PubMed_export.txt
```

**Result**:

```
1459
```

Count the records in an export file in XML format:

```bash
grep -c "^<PubmedArticle>$" medline.xml
```

**Result**:

```
1459
```


### Postprocessing search result for easier import

Unite search results that had to be exported in chunks into a single file. This saves time and is less prone to errors from repetitive import tasks.


#### Ovid MEDLINE and Ovid Embase

For the Ovid files we just need to concatenate the individual export files into a single one:

A reproducible example (with Open Access [test data](test/data/README.md) that can be redistributed):

```ovid
cat Embase_citavi_r*-*.ovd > Embase_citavi_records-combined.ovd
```

Check the generated file for completeness:

```bash
grep --count "^DB  - Embase" Embase_citavi_records-combined.ovd
```

Result:

```
3002
```

The same for the records exported in Endnote format:

```bash
cat Embase_endnote_r*-*.cgi > Embase_endnote_records-combined.cgi
grep --count "^DB  - Embase" Embase_endnote_records-combined.cgi
```

Result:

```
3002
```

Another example from an actual search with duplicate records in the export files (data not in this repository):

```bash
cat myproject_EMBASE_2018-12-13_r*-*.ovd > myproject_EMBASE_2018-12-13_records-combined.ovd
```

Check the generated file for completeness:

```bash
grep --count "^DB  - Embase" myproject_EMBASE_2018-12-13_records-combined.ovd
```

```
3831
```

**Result**: A total of 3831 records is in the generated file.

Count the unique records in the file:

```bash
grep "^UI  - " myproject_EMBASE_2018-12-13_records-combined.ovd | sort | uniq | wc -l
```

```
3813
```

**Result**: The expected numbers or records and of unique records are in the file. We are safe to import this file into the reference manager.


#### Web of Science

Web of Science allows to download no more than 500 records at a time. Therefore, it is particularly helpful to combine the export files.  

Export format:

* Other file format --> Record content: _Full Record_; File Format: _Other reference software_ (.txt-file)
* Endnote Desktop --> Record content: _Full Record_ (.ciw-file)

These formats are identical with the exception of a byte-mark at the beginning of the .txt-files.  

Web of Science export files contain a header and footer. As we need to take care of this we cannot just concatenate files as with other formats. But a [small skript](./bin/unite_wos_files) takes care of this:


```bash
unite_wos_files test/data/WoS_other_reference_software_r*.txt > test/data/WoS_other_reference_software_records_combined.txt
```

Then check the number of records in the new file as above.


### Building query strings

#### Known record searches by accession numbers or DOIs

Build queries from lists of accession numbers or DOIs. This comes in handy for

* removing records on the host that were found in earlier searches when updating searches, 
* removing records on the host that were already found in other databases (partial on-the-host deduplication), and
* known item searches for test sets with know relevant records in order to check search strategies.

For more details see below in the sections [Updating searches](#updating-searches) and [Build reusable scripts](#build-reusable-scripts).


#### Reverse the order of lines in search strategy

Search interfaces often show the lines in a search strategy such that the last search statement is on top. This order may persist in an exported search strategy (e.g. by copying from a browser window). But this order is inconvenient when the search strategy should be entered again into a search interface, possibly after some modifications. It is easy to reverse the order of lines with the `tac` tool (Mnemonic: This is the reverse of `cat`).

```bash
tac my_old_stategy.txt > stategy_with_lines_reversed.txt
```

When editing a file in the `vim` editor there basically are two options:

* Call `tac`, e.g. `:%!tac` for the wole buffer.
* Use vim's features: `:g/^/m0`

For more info see e.g. <https://vim.fandom.com/wiki/Reverse_order_of_lines>.


### Updating searches

The approach in general is to work with accession numbers of database records:

1. Extract the PMIDs from the export files of first search, 
2. construct a query string for these PMIDs (or several to do it in batches of say a 1,000),
3. run the update search,
4. search the records of the old search (using the query strings created as above),
5. NOT the old records out of the new search result.

Steps 1 and 2 are a matter of seconds when using command line tools.  

Examples are given here for PubMed and Ovid MEDLINE.  

Note: There are two scripts, [`extract_accession_numbers`](./bin/extract_accession_numbers) and [`an2query`](./bin/an2query) that make this much easier. See below in the section [Build reusable scripts](#build-reusable-scripts) for more information.


#### PubMed

Extract the PMIDs from the export files of the first search:

```bash
grep "^PMID- " pubmed-export-set.txt | sed -e 's/^PMID- //' > pubmed-export-set_pmid.txt
```

Construct a query string for these PMIDs (or several to do it in batches of say a 1,000). Steps: 

 * Pipe content of file with PMIDs to `sed` for processing.
 * Add '"' to beginning of each line of the input.
 * Add '"' and field specification to end of each line of the input.
   Whitespace at beginning or end of line will be deleted.
 * Add ' OR ' to end of each line except the last one.
 * Write result to a text file.

```bash
cat pubmed-export-set_pmid.txt | \
sed\
    -e 's/^\s*/"/' \
    -e "s/\s*$/\"\[UID\]/" \
    -e '$! s/$/ OR /' \
> pubmed-export-set_query.txt
```

#### Ovid MEDLINE

Extract the PMIDs from the export files of first search:

```bash
grep "^UI  - " myproject_MEDLINE_2018-04-25.cgi  | \
sed -e 's/^UI  - //' -e 's/\r//g' \
> myproject_MEDLINE_2018-04-25_uid.txt
```

Construct a query string for these PMIDs (or several to do it in batches of say a 1,000). Steps: 

 * Pipe content of file with PMIDs to `sed` for processing.
 * Delete empty lines or lines containig only whitespace.
 * Add '"' to beginning of each line of the input. Whitespace at the beginning of line will be deleted.
 * Add '"' to end of each line of the input. Whitespace at the end of line will be deleted.
 * Add ' OR ' to end of each line except the last one.
 * Add "(" to beginning of file
 * Add ")" and field specification to end of file
 * Write result to a text file.

```bash
cat myproject_MEDLINE_2018-04-25_uid.txt | \
sed\
    -e '/^\s*$/d' - | \
sed\
    -e 's/^\s*/"/' \
    -e 's/\s*$/"/' \
    -e '$! s/$/ OR /' | \
sed\
    -e '1 i (' \
    -e '\$ a ).ui.' \
> myproject_MEDLINE_2018-04-25_query.txt
```


### Documenting searches

#### Document database accession numbers

Extract accesion numbers of database records from exported search result. It may be helpful to document these result sets for various purposes, either just for internal use or better yet as a publicly available piece of research data with the published report. Publishing lists of accessions numbers will not infringe the copyright of database vendors which might be the case when publishing whole database records containing text.

Note: It is possible to use the [extract_accession_numbers](bin/extract_accession_numbers) script that makes this much easier, see [here](#build-reusable-scripts).

Extract PMIDs from Ovid MEDLINE export file into a text file:

```bash
grep "^UI  - " myproject_MEDLINE_2018-12-13_records-combined.ovd | sed -e 's/^UI  - //' -e 's/\r//g' > myproject_MEDLINE_2018-12-13_records-combined_pmid.txt
```

Extract Embase accession numbers from Ovid Embase export file into a text file:

```bash
grep "^UI  - " myproject_EMBASE_2018-12-13_records-combined.ovd | sed -e 's/^UI  - //' -e 's/\r//g' > myproject_EMBASE_2018-12-13_records-combined_uid.txt
```
These text files can also be used for deduplicating search results and especially so when running update searches.


#### Convert Ovid search history to table

Search history/startegy as exported from the host must go into the documentation. Editing this as a nicely formatted table in Word so that it easy to comprehend is a somewhat tedious and error prone process. Therefore, I use a [script](vim/ovd_search-history2tsv.vim) for the `vim`editor.

How to export the search strategy from Ovid: 

* Select a single record, click "Export".
* Format: _.txt_
* Fields: Dooes probably not matter. I leave it with my preferred value of _Complete Reference_.
* Include: _Search History_

Open the text file containing the search strategy in `vim` and then call the script with `:source vim/ovd_search-history2tsv.vim`. This will create a tsv-file the content of which can then easily be copied to e.g. Excel or Word. The script will remove any records following the search strategy and reformat in to a tab separated table while taking care of any annotations.

**TODO**: Work in progress: Do the same with `sed`  on the command line so that no `vim` is needed.


## Build reusable scripts

It is helpful to write down the commands that worked well in a shell script. Such a script is a convenient means to store the functionality for easy reuse. The gory details that are hard to remember are hidden away in the script. Some skripts are contained in the [bin ](./bin/) folder.

You get help on using the individual scripts with:

```bash
extract_accession_numbers --help

an2query --help

unite_wos_files --help

check_record_files --help
```


### Examples

Count the records in an exported search result by accession numbers:

```bash
cat Embase_endnote_records-combined.cgi | extract_accession_numbers --format ovid_embase | wc -l
```

Extract the accession numbers from an exported search result to a file for purposes of documentation and reuse:

```bash
cat Embase_endnote_records-combined.cgi | extract_accession_numbers --format ovid_embase > Embase_endnote_records-combined_uid.txt
```

Extract the accession numbers from an exported search result and build a database query to find these records:

For **Ovid Embase**:


```bash
cat Embase_endnote_records-combined.cgi | extract_accession_numbers --format ovid_embase | an2query --syntax ovid_embase --idtype an > query.txt
```

For **Cochrane Library** publications by Cochrane can be searched by `an` field. Trials with an accession number from CENTRAL can be searched without field specifications only (afaik):

```bash
cat test/data/Cochrane_Reviews_EndNote.ris | extract_accession_numbers --format cochrane_reviews_endnote_ris | an2query --syntax cochrane_library --idtype an > Cochrane_Reviews_query.txt

cat test/data/Cochrane_Trials_EndNote.ris | extract_accession_numbers --format cochrane_trials_endnote_ris | an2query --syntax cochrane_library --idtype none > Cochrane_Trials_query.txt
```

Find a set of records in the **Citavi** citation manager for batch manipulation:

```bash
extract_accession_numbers --format ovid_medline < MEDLINE_known-relevant-records-not-found-by-RCT-filter.ovd | an2query --syntax citavi --idtype pmid | xclip
```

The query string is sent to the system clipboard via the `xclip` tool so that it can be pasted directly into the Citavi quick search dialog. Here we use this to assign a specific group/category to the records. These records need to be checked further (which we will do in Citavi) for tuning a search strategy. Why were these known relevant records not being picked up by a search filter?

