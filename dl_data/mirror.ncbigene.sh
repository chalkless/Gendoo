#!/bin/bash

## Create local directory for download
# mkdir /share/data/gene/160110
# cd /share/data/gene/160110

lftp -e 'mirror --delete --only-newer --verbose --exclude ASN_BINARY/ /gene/DATA/; quit' ftp://ftp.ncbi.nlm.nih.gov/


