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

\#tax_id  | GeneID  | status  | RNA_nucleotide_accession.version  | ...  | Symbol
--|---|---|---|---|--
9606  | 31  | REVIEWED  | NM_198836  | ...  | ACACA
9606  | 31  | REVIEWED  | NM_198836  | ...  | ACACA
9606  | 31  | REVIEWED  | NM_198836  | ...  | ACACA

  - まとめ：ACACA protein, human → NM_198836 → Gene ID: 31
  - 参考：どのくらいの対応がつくのか（あくまで参考。数字は数え方によって微妙に変わる）

`$ grep "^NM = " c2018.bin | grep "\S, human$" | wc -l`

生物種  |  数
--|--
human  |  14342
mouse  |  10212
rat  |  5042

`$ grep "^NM = " c2018.bin | perl -lane 'if ($_ =~ /\S, (.*)/){ print $1}' | sort | uniq -c | sort -rn | head`

生物種  |  数
--|--
human  |  14306
mouse  |  10196
rat  |  5031
Arabidopsis  |  4987
S cerevisiae  |  3531
Drosophila  |  3224
E coli  |  2118
C elegans  |  2056
zebrafish  |  2018
Xenopus  |  1412

  - RefSeq に対応づくのは27239件
    - 普通は NO = RefSeq NM_028833 な記述
    - NO = a calcium-binding protein kinase; RefSeq NM_118496 という場合もある

`$ grep "^NO = " c2018.bin | grep RefSeq| wc -l`
