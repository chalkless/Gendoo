# Gendoo
## データ構築
### NCBI Gene からのデータ取得
- ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/
  - gene2pubmed.gz
  - gene2refseq.gz
- gene2pubmed.gzの中身

\#tax_id|GeneID | PubMed_ID
--|---|--
9|1246500|9873079
9|1246501|9873079
9|1246502|9812361

- tax_idリスト

tax_id | 生物種
--|--
9606  |  human
10090  | mouse
10116  | rat

- human だけ抽出

`$ gunzip -c gene2pubmed.gz | grep "^9606    " > gene2pubmed.human.tab`

  - ちなみに 1,239,986 件（2017/11/27）
  - 35881 Gene IDs

### MeSHの取得
- ダウンロード：ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/ から

ファイル名  |  内容
--|--
d2018.bin  |  MeSHそのもの
c2018.bin  |  Substance Names。化合物などのリスト
  - q2018.binもあるが使わない

- Substance Names と Gene IDの対応付け
  - c2018.binの中身

項目  |  内容
--|--
NM  |  NM = ACACA protein, human
  |  ...
NO  |  NO = RefSeq NM_198836
  |  ...

  - gene2refseqの中身より

\#tax_id|GeneID|status|RNA_nucleotide_accession.version|RNA_nucleotide_gi|protein_accession.version|protein_gi|genomic_nucleotide_accession.version|genomic_nucleotide_gi|start_position_on_the_genomic_accession|end_position_on_the_genomic_accession|orientation|assembly|mature_peptide_accession.version|mature_peptide_gi|Symbol
--|--|--|--|--|--|--|--|--|--|--|--|--|--|--
9606|31|REVIEWED|NM_198836.2|631790826|NP_942133.1|38679967|NC_000017.11|568815581|37084991|37406821|-|Reference GRCh38.p7 Primary Assembly|-|-|ACACA
9606|31|REVIEWED|NM_198836.2|631790826|NP_942133.1|38679967|NC_018928.2|528476558|35476554|35798373|-|Alternate CHM1_1.1|-|-|ACACA
9606|31|REVIEWED|NM_198836.2|631790826|NP_942133.1|38679967|NT_187614.1|568815392|1320991|1645966|-|Reference GRCh38.p7 ALT_REF_LOCI_1|-|-|ACACA
