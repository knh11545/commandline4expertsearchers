## Use NLM's Entrez Direct (EDirect)

The [EDirect utilities](https://www.ncbi.nlm.nih.gov/books/NBK179288/) provided by [NLM's](https://www.nlm.nih.gov/) [NCBI](https://www.ncbi.nlm.nih.gov/) are a set of very powerful tools to be used at the Unix command line. They ...

**This is all still work in progress!**


### Retrieving search results from PubMed

The new PubMed no longer supports downloading records in XML format. But we can do this with [EDirect](https://www.ncbi.nlm.nih.gov/books/NBK179288/):


1. Save your search results as a list of PMIDs as a file, e.g. [pmid.txt](test/data/pmid.txt).
2. On the command line with bash run

```bash
cat pmid.txt | epost -db pubmed | efetch -format xml > medline.xml
```

This yields the records in XML format in the file medline.xml. This also works for large numbers of records. Downloading in PubMed format (called MEDLINE format in legacy PubMed) is possible, too:


```bash
cat pmid.txt | epost -db pubmed | efetch -format medline > medline.txt
```


### Searching for patterns that are not supported by search interfaces

#### Use command line tools like grep to post-process a selected number of records (from a more general search) that was downloaded

Example: Find PubMed records that contain information about equally contributing authors.

This information is not searchable in PubMed but the information is contained in the XML format of PubMed records. See [Equal Contribution for Authors in PubMed](https://www.nlm.nih.gov/pubs/techbull/so17/so17_contrib_equal_author_pubmed.html).

```bash
esearch -db pubmed -query "Regensburg[AD] AND 2018:2020[DP]" | efetch -format xml > regensburg_2018-2020.xml
cat regensburg_2018-2020.xml  | xtract -pattern PubmedArticle -element MedlineCitation/PMID | wc -l
# 4113
cat regensburg_2018-2020.xml  | xtract -pattern PubmedArticle -element MedlineCitation/PMID -block Author -element "@EqualContrib" | grep "[Y|N]" | cut -f 1 | wc -l
# 158
cat regensburg_2018-2020.xml  | xtract -pattern PubmedArticle -element MedlineCitation/PMID -block Author -element "@EqualContrib" | grep Y | cut -f 1 | wc -l
# 42
cat regensburg_2018-2020.xml  | xtract -pattern PubmedArticle -element MedlineCitation/PMID -block Author -element "@EqualContrib" | grep N | cut -f 1 | wc -l
# 122

```



#### Use local phrase searching using eDirect and a local copy of PubMed

**TODO**


### Search and analyze results


#### Where could I publish a protocol for a systematic review?

Journals in which many SR protocols are published may be particularly suitable for submission.

* Find PubMed records of protocols of systematic reviews.
* Extract the journal title.
* Group by journal, count records and sort by rank.

```bash

esearch -db pubmed -query '("systematic review"[TI]) AND ("protocol"[TI])' | efetch -format xml > SR_protocols.xml

cat SR_protocols.xml | xtract -pattern PubmedArticle -element Journal/Title | sort-uniq-count-rank | head -10

```
Results:

```
1253    Medicine
1022    BMJ open
1016    Systematic reviews
504     JBI database of systematic reviews and implementation reports
89      JBI evidence synthesis
81      JMIR research protocols
22      Acta anaesthesiologica Scandinavica
19      JBI library of systematic reviews
18      International journal of surgery protocols
18      Journal of advanced nursing
```


### Installation of Entrez Direct

Entrez Direct (EDirect) needs to be installed. This is easy with a Linux or Macintosh system where the prerequisites already are available (a bash shell and Perl). For my Windows 10 PC I found it easiest to go via [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows) and then use the [official NCBI/NLM Docker image for edirect](https://hub.docker.com/r/ncbi/edirect). 

Once Docker for Windows is installed and running open a PowerShell to pull the EDirect image (only once) and start it:

```{PowerShell}
docker pull ncbi/edirect
docker run -it --rm ncbi/edirect
```

To share a directory:

```bash
```

```bash
```


