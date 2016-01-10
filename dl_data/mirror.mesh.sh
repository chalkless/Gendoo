#!/bin/bash

## Create local directory for download
# mkdir /share/data/mesh/2016
# cd /share/data/mesh/2016

# NLM requires licence agreement for downloading MeSH files.

lftp -e 'mirror --delete --only-newer --verbose --exclude ".*" --include ".*2016..*" /online/mesh/.asciimesh/; mirror --delete --only-newer --verbose --exclude ".*" --include mtrees2016.bin; quit' ftp://nlmpubs.nlm.nih.gov/

