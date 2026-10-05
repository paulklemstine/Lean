#!/bin/bash
# $1 = arxiv id, $2 = outname
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
for attempt in 1 2 3; do
  curl -sL --max-time 300 -A "$UA" "https://arxiv.org/pdf/$1" -o "$2"
  if head -c 5 "$2" | grep -q "%PDF"; then echo "OK $2 ($(stat -c%s $2) bytes)"; exit 0; fi
  echo "attempt $attempt failed, sleeping"; sleep 20
done
echo "FAIL $2"; head -c 300 "$2"
