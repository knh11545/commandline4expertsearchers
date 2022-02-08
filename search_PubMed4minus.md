Search for CD21 negative in PubMed when negative is symbolized with a minus character
==============================================================================

Problem: PubMed converts the character `-` to a space, and therefore will retrieve articles on CD21 in general which means a large number of irrelevant records.

Approach: Search for records with "CD21", download the results and filter relevant records with command line tools.

* Search `CD21[tw]` (text words) in PubMed.
* Download the 2389 records (as of 2022-02-08) in PubMed format to a file `pubmed-CD21tw-set.txt`.
* Split the PubMed export file into a file for every record:


```bash 
mkdir records
cd records
cat ../pubmed-CD21tw-set.txt | csplit --elide-empty-files --prefix=record_ --digits=4 - '/^\s*$/' '{*}'
```

* Check the results: 

```bash 
ls -1 record_* | wc -l
```

* We now have 2389 files named `record_0000` etc. Each one contains a single PubMed record.
* Using `grep` we can search the files for a specific pattern. First, we search for just `CD21` (case-insensitive) to see what strings occur in the records. Filenames and matching lines are printed:

```bash 
grep  --ignore-case 'CD21' record_* | less
```

* Results:
  + `CD21(-)` should be searched for, too. Not just `CD21-`. Our search pattern will be `'CD21[(]*-'`.
  + The `-` can be a hyphen as in `CD21-independent` or in `CD21-positive`. We might want to exclude at least the latter from our results.
  + `CD21 low` and  `CD21low` are additional candidate string to search for in PubMed.
* We print any sequence of non-space characters that contains `CD21-` or `CD21(-`, sort (necessary for deduplication) and deduplicate this list. This way we can easier check the matched patters:
```bash 
grep --ignore-case --only-matching --no-filename '[^ ]*CD21[(]*-[^ ]*' record_* | sort | uniq | less
```

* We decide that we want to exclude a few other patterns for CD21-positive. We can do this with `grep -v`.
* We then extract the names of the matching files from the grep output using `cut`, keeping field 1 with the colon as field delimiter.
* We then deduplicate the list filenames. Files were printed with every matching line.
* Finally we write the list of matching files into a text file:

```bash 
grep --ignore-case --only-matching '[^ ]*CD21[(]*-[^ ]*' record_* | grep -v 'CD21-positive\|CD21-hyperpositive\|CD21-expressing\|CD21-overexpressed' | cut -f1 -d':' | sort | uniq > ../files_with_CD21negative.txt
```

* This file holds 286 filenames.
* We can now send the filenames to the `cat` command (using `xargs` as a helper to call cat for every filename) to write the contents of the individual files to a single file. This file `CD21negative_PubMed.txt` will then contain all matching records in PubMed format:

```bash 
cat ../files_with_CD21negative.txt | xargs cat > ../CD21negative_PubMed.txt
```

* As an alternative, we can just extract the PMIDs from the matching files:

```bash 
cat ../files_with_CD21negative.txt | xargs grep --no-filename '^PMID- ' | sed 's/PMID- //' > ../CD21negative_PMID.txt
```

