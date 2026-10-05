#!/bin/bash
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
try() { # $1 url, $2 out
  curl -sL --max-time 300 -A "$UA" -H "Accept: application/pdf,*/*" "$1" -o "$2" 2>/dev/null
  if head -c 5 "$2" 2>/dev/null | grep -q "%PDF"; then echo "OK $2 $(stat -c%s $2) bytes"; return 0; fi
  echo "  miss $1 ($(stat -c%s $2 2>/dev/null) b)"; return 1
}
for u in "https://export.arxiv.org/pdf/2505.15917v2" \
         "https://arxiv.org/pdf/2505.15917" \
         "https://export.arxiv.org/pdf/2505.15917"; do
  try "$u" gidney.pdf && break
  sleep 15
done
