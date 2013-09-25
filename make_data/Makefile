out  = ./out
data = ./data

gene = ~/bio/data/gene/130110
mesh = ~/bio/data/mesh/2013
mesh_ver = 2013

taxid = 7091


${out}/id2name.${taxid}.tab: ${out}/gene_info.${taxid}.tab
	./810_GeneName/mk.id2name.pl $< > $@

${out}/gene_info.${taxid}.tab: ${gene}/gene_info.gz
	gunzip -c $< | egrep "^${taxid}	" > $@


${out}/accession2gene.${taxid}.tab: ${out}/gene2accession.${taxid}.tab ${out}/subst2accession.tab
	./120_fromSubst/make.accession2gene.pl $^ > $@

${out}/refseq2gene.${taxid}.tab: ${out}/gene2refseq.${taxid}.tab ${out}/subst2accession.tab
	./120_fromSubst/make.refseq2gene.pl $^ > $@

${out}/subst2accession.tab: ${mesh}/c${mesh_ver}.bin
	./120_fromSubst/ext.subst2accession.pl $< > $@

${out}/gene2accession.${taxid}.tab: ${gene}/gene2accession.gz
	gunzip -c $< | egrep "^${taxid}	" > $@

${out}/gene2refseq.${taxid}.tab: ${gene}/gene2refseq.gz
	gunzip -c $< | egrep "^${taxid}	" $< > $@


${out}/gene.id2pmid.gene2pmid.${taxid}.tab: ${out}/gene2pubmed.${taxid}.raw.tab
	perl -F"\t" -lane 'print join("\t", $$F[1], $$F[2], "G")' $< > $@

${out}/gene2pubmed.${taxid}.raw.tab: ${gene}/gene2pubmed.gz
	gunzip -c $< | egrep "^${taxid}	" $< > $@

