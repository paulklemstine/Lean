#!/bin/bash
timeout 60 curl -sSL -G "https://eprint.iacr.org/search" --data-urlencode "q=$1" -o /tmp/epq2.html
python3 -c "
import re,html
x=open('/tmp/epq2.html',encoding='utf-8',errors='replace').read()
x=re.sub(r'<script.*?</script>','',x,flags=re.S)
t=html.unescape(re.sub(r'<[^>]+>',' ',x))
t=re.sub(r'\s+',' ',t)
if 'No results' in t: print('NO RESULTS'); raise SystemExit
# find result block
i=t.find('Sort by relevance')
seg=t[i:] if i>0 else t
j=seg.find('Close')
print(seg[:3000 if j<0 else min(j+200,3000)])
"
