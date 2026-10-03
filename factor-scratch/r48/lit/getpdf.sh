#!/bin/bash
# getpdf.sh 2503.00950 [v1]
ID="$1"; V="${2:-v1}"
timeout 180 curl -sL -A 'Mozilla/5.0 (X11; Linux x86_64)' -o "pdf/$ID.pdf" "https://arxiv.org/pdf/$ID$V" && pdftotext -layout "pdf/$ID.pdf" "pdf/$ID.txt" && echo "OK $ID pages=$(grep -c $'\f' pdf/$ID.txt) chars=$(wc -c <pdf/$ID.txt)"
