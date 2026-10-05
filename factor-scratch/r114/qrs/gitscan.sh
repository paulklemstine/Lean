#!/bin/bash
cd /home/raver1975/lean
git rev-list --all > /tmp/allcommits.txt
echo "commits: $(wc -l < /tmp/allcommits.txt)"
n=0
while read h; do
  n=$((n+1))
  if git ls-tree -r --name-only "$h" 2>/dev/null | grep -q "r45/axis7"; then
    echo "FOUND r45/axis7 in commit $h"; break
  fi
  if [ $((n % 500)) -eq 0 ]; then echo "scanned $n"; fi
done < /tmp/allcommits.txt
echo "SCAN DONE (no FOUND line above = never committed)"
