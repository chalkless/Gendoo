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
UI  |  UI = C000588423

  - gene2refseqの中身より

\#tax_id|GeneID|status|RNA_nucleotide_accession.version|...||Symbol
--|---|--|---|---|--
9606|31|REVIEWED|NM_198836.2|...|ACACA
9606|31|REVIEWED|NM_198836.2|...|ACACA
9606|31|REVIEWED|NM_198836.2|...|ACACA

  - まとめ：ACACA protein, human → NM_198836 → 31
