data = ./data


gene = ~/bio/data/gene/130110
mesh = ~/bio/data/mesh/2013
mesh_ver = 2013

taxid = 7091


${data}/accession2gene.${taxid}.tab: ${data}/gene2accession.${taxid}.tab ${data}/subst2accession.tab
	./120_fromSubst/make.accession2gene.pl $^ > $@

${data}/refseq2gene.${taxid}.tab: ${data}/gene2refseq.${taxid}.tab ${data}/subst2accession.tab
	./120_fromSubst/make.refseq2gene.pl $^ > $@

${data}/subst2accession.tab: ${mesh}/c${mesh_ver}.bin
	./120_fromSubst/ext.subst2accession.pl $< > $@

${data}/gene2accession.${taxid}.tab: ${gene}/gene2accession.gz
	gunzip -c $< | egrep "^${taxid}	" > $@

${data}/gene2refseq.${taxid}.tab: ${gene}/gene2refseq.gz
	gunzip -c $< | egrep "^${taxid}	" $< > $@


${data}/gene.id2pmid.gene2pmid.${taxid}.tab: ${data}/gene2pubmed.${taxid}.raw.tab
	perl -F"\t" -lane 'print join("\t", $$F[1], $$F[2], "G")' $< > $@

${data}/gene2pubmed.${taxid}.raw.tab: ${gene}/gene2pubmed.gz
	gunzip -c $< | egrep "^${taxid}	" $< > $@

