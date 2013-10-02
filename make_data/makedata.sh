#!/bin/bash

# makedata.sh
# Nakazato T.
# '13-10-01-Tue.    Ver. 0      Original: Makefile


### Settings
echo "*** Settings ***"
gene="/opt/data/gene/130110"
mesh="/opt/data/mesh/2013"

mesh_ver="2013"

out="./out"

### Usage
usage_exit() {
    echo "Usage: makedata.sh [-t|--taxon] taxonid ..."
    exit 1
}


### set Argument
#OPT=`getopt -o t:g:m:y:o:d: --long taxonid:,gene:,mesh:,year:,out:,data: -- "$@"`
#; [ $? != 0 ] && usage_exit
#eval set -- "$OPT"
#echo "$@" ### debug
#while true
while getopts "t:g:m:y:o:d:" opts
do
    case $opts in
	t)
	    taxid=$2
	    ;;
	g)
	    gene=$2
	    ;;
	--)
	    break
	    ;;
	*)
	    usage_exit
	    ;;
    esac
done


cd ${out}

### Make gene name list
echo "*** Gene Name List ***"
gunzip -c ${gene}/gene_info.gz | egrep "^${taxid}	" > gene_info.${taxid}.tab
../810_GeneName/mk.id2name.pl gene_info.${taxid}.tab > id2name.${taxid}.tab

### Make MeSH ID table
echo "*** MeSH Tree ***"
../910_arrangeMeSH/make.term2tree.pl ${mesh}/d${mesh_ver}.bin > mesh.term2tree.${mesh_ver}.tab

### Make Gene-PMID pairs
echo "*** Gene-PMID pairs ***"
## from reference in Entrez Gene
gunzip -c ${gene}/gene2pubmed.gz | egrep "^${taxid}	" > gene2pubmed.${taxid}.raw.tab
perl -F"\t" -lane 'print join("\t", $F[1], $F[2], "G")' gene2pubmed.${taxid}.raw.tab > gene.id2pmid.ref.${taxid}.tab

## Subst + RefSeq/GenBank -> Entrez Gene
gunzip -c ${gene}/gene2refseq.gz | egrep "^${taxid}	" > gene2refseq.${taxid}.tab
gunzip -c ${gene}/gene2accession.gz | egrep "^${taxid}	" > gene2accession.${taxid}.tab
../120_fromSubst/ext.subst2accession.pl ${mesh}/c${mesh_ver}.bin > subst2accession.tab
../120_fromSubst/make.refseq2gene.pl gene2accession.${taxid}.tab subst2accession.tab > refseq2gene.${taxid}.tab
../120_fromSubst/make.accession2gene.pl gene2refseq.${taxid}.tab subst2accession.tab > accession2gene.${taxid}.tab
# to be continued

### Merge id2pmid files
cat gene.id2pmid.ref.${taxid}.tab | perl -F"\t" -lane 'print join("\t", $F[0], $F[1])' | egrep -v "\-" | sort | uniq > gene.id2pmid.all.${taxid}.tab

## Change style
../310_pmid2mesh/format.pair2each.pl gene.id2pmid.all.${taxid}.tab > gene.id2pmid.pair.${taxid}.tab

## Devide id2pmid by types (coding/other)
../320_devType/devType.gene.pl gene.id2pmid.pair.${taxid}.tab gene_info.${taxid}.tab

## id2pmid -> id2mesh
echo "*** PMID -> MeSH ***"
genetype=("coding" "other")
for eachtype in "${genetype[@]}"; do
    eachfile="gene.id2pmid.pair.${taxid}.${eachtype}.tab";
    echo ${eachfile};
    ../310_pmid2mesh/fetch.pair2mesh.pl ${eachfile} > `echo ${eachfile} | sed -e "s/pmid.pair/mesh/"`;
done

## Devide id2mesh by MeSH category
echo "* Devide by category *"
for eachtype in "${genetype[@]}"; do
    eachfile="gene.id2mesh.${taxid}.${eachtype}.tab";
    ../330_devCategory/devCategory.pl ${eachfile} mesh.term2tree.${mesh_ver}.tab;
done


## Preparing score calculation
echo "*** Preparing score calculation ***"
category=("A" "B" "C" "D" "F" "G" "S")
for eachtype in "${genetype[@]}"; do
    for eachcat in "${category[@]}" ; do
	eachfile="gene.id2mesh.${taxid}.${eachtype}.${eachcat}.tab";
	echo ${eachfile}
	sort ${eachfile} | uniq | perl -F"\t" -lane 'print join("\t", $F[1], $F[2])' | sort | uniq | perl -F"\t" -lane 'print $F[1]' | sort | uniq -c | sort -rn | ../lib/sort2tab.pl > ${eachfile%tab}meshfreq.tab;
	sort ${eachfile} | uniq | perl -F"\t" -lane 'print join("\t", $F[0], $F[1])' | sort | uniq | perl -F"\t" -lane 'print $F[0]' | sort | uniq -c | sort -rn | ../lib/sort2tab.pl > ${eachfile%tab}genefreq.tab;
	sort ${eachfile} | uniq | perl -F"\t" -lane 'print join("\t", $F[0], $F[2])' | sort | uniq -c | ../lib/sort2tab.pl > ${eachfile%tab}pairfreq.tab;
	echo -n "${eachtype}.${eachcat}	" >> ${taxid}.pmid.total.txt;
	perl -F"\t" -lane 'print $F[2]' $eachfile | wc -l >> ${taxid}.pmid.total.txt;
    done
done

## Calculating score
echo "*** calculating scores... ***"
for nm in gene.id2mesh.${taxid}.*.?.pairfreq.tab; do
    ../410_CalcScore/calcScore.pl $nm > ${nm%pairfreq.tab}score.pre.tab 2> ${nm%pairfreq.tab}score.log;
    tgt=$(echo $nm | sed -e "s/id2mesh/score/; s/pairfreq.//; s/tab/pre.tab/");
    sort -k 2gr ${nm%pairfreq.tab}score.pre.tab > $tgt;

    ../430_MeSHterm2id/mesh.term2id.pl $tgt mesh.term2tree.${mesh_ver}.tab > ${tgt%pre.tab}tab;
done

