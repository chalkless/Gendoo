out  = ./out
data = ./data

gene = ~/bio/data/gene/130110
mesh = ~/bio/data/mesh/2013
mesh_ver = 2013

taxid = 7091


.PHONY: all
all: name mesh category


.PHONY: mesh
mesh: ${out}/mesh.term2tree.${mesh_ver}.tab

.PHONY: name
name: ${out}/id2name.${taxid}.tab

.PHONY: category
category: ${out}/gene.id2pmid.${taxid}.category.tab

.PHONY: pmid
pmid: ${out}/gene.id2pmid.gene2pmid.${taxid}.tab


# Make MeSH ID table
${out}/mesh.term2tree.${mesh_ver}.tab: ${mesh}/d${mesh_ver}.bin
	./910_arrangeMeSH/make.term2tree.pl $< > $@

# Make Gene Name Table
${out}/id2name.${taxid}.tab: ${out}/gene_info.${taxid}.tab
	./810_GeneName/mk.id2name.pl $< > $@

${out}/gene_info.${taxid}.tab: ${gene}/gene_info.gz
	gunzip -c $< | egrep "^${taxid}	" > $@


${out}/gene.id2pmid.${taxid}.category.tab: ${out}/gene.id2pmid.${taxid}.tab ${out}/gene_info.${taxid}.tab
	./320_devType/devType.gene.pl $^
	touch $@

${out}/gene.id2pmid.${taxid}.tab: ${out}/gene.id2pmid.all.${taxid}.tab
	./310_pmid2mesh/format.pair2each.pl $< > $@

# Merging id2pmid files
${out}/gene.id2pmid.all.${taxid}.tab: ${out}/gene.id2pmid.gene2pmid.${taxid}.tab
	cat $^ | perl -F"\t" -lane 'print join("\t", $$F[0], $$F[1])' | egrep -v "\-" | sort | uniq > $@


# Make PMID list from Substance Names
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


# Make PMID list from Entrez Gene Reference
${out}/gene.id2pmid.gene2pmid.${taxid}.tab: ${out}/gene2pubmed.${taxid}.raw.tab
	perl -F"\t" -lane 'print join("\t", $$F[1], $$F[2], "G")' $< > $@

${out}/gene2pubmed.${taxid}.raw.tab: ${gene}/gene2pubmed.gz
	gunzip -c $< | egrep "^${taxid}	" > $@

