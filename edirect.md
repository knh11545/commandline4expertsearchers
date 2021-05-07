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


#### Where could I publish a protocol for a systematic review/scoping review/mapping review?

Journals in which many SR protocols are published may be particularly suitable for submission.

* Find PubMed records of protocols of systematic reviews.
* Extract the journal title.
* Group by journal, count records and sort by rank.

Date: 2021-05-07

```bash

esearch -db pubmed -query '("systematic review"[TI]) AND ("protocol"[TI])' | efetch -format xml > SR_protocols.xml

cat SR_protocols.xml | xtract -pattern PubmedArticle -element Journal/Title | sort-uniq-count-rank | head -10

```
Results:

```

1878    Medicine
1167    BMJ open
1071    Systematic reviews
503     JBI database of systematic reviews and implementation reports
127     JBI evidence synthesis
94      JMIR research protocols
23      Acta anaesthesiologica Scandinavica
21      Journal of advanced nursing
20      PloS one
19      HRB open research

```

How about soping review protocols?

```bash

esearch -db pubmed -query '("scoping review"[TI]) AND ("protocol"[TI])' | efetch -format xml | xtract -pattern PubmedArticle -element Journal/Title | sort-uniq-count-rank | head -10

```
Results:

```

340     BMJ open
132     Systematic reviews
131     JBI database of systematic reviews and implementation reports
120     JBI evidence synthesis
34      JMIR research protocols
8       HRB open research
4       Acta anaesthesiologica Scandinavica
3       F1000Research
3       International journal of environmental research and public health
3       Methods and protocols

```

And mapping review protocols?

```bash

esearch -db pubmed -query '("mapping review"[TI]) AND ("protocol"[TI])' | efetch -format xml | xtract -pattern PubmedArticle -element Journal/Title | sort-uniq-count-rank | head -10

```
Results:

```

1       Animal health research reviews
1       Laboratory animals
1       Systematic reviews

```
