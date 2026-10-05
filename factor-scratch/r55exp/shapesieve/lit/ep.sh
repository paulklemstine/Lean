#!/bin/bash
timeout 60 curl -sSL -G "https://eprint.iacr.org/search" --data-urlencode "q=$1" -o /tmp/epq.html
python3 -c "
import re,html
x=open('/tmp/epq.html',encoding='utf-8',errors='replace').read()
x=re.sub(r'<script.*?</script>','',x,flags=re.S)
# entries
for m in re.finditer(r'href=\"(/[0-9]{4}/[0-9]+)\"[^>]*>(.*?)</a>',x,re.S):
    ti=re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>','',m.group(2)))).strip()
    print(m.group(1),'|',ti[:110])
"
