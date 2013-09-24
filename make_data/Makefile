data = ./data
gene = ~/bio/data/gene/130110


taxid = 7091


gene.id2pmid.gene2pmid.${taxid}.tab: gene2pubmed.${taxid}.raw.tab
	perl -F"\t" -lane 'print join("\t", $$F[1], $$F[2], "G")' < ${data}/$< > ${data}/$@

gene2pubmed.${taxid}.raw.tab: gene2pubmed
	egrep "^${taxid}	" ${data}/$< > ${data}/$@

gene2pubmed: ${gene}/gene2pubmed.gz
	gunzip -c $< > ${data}/$@