#!/bin/bash
q=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$1")
timeout 60 curl -skL "https://www.bing.com/search?q=$q&count=20" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" -o /home/raver1975/lean/_bing.html
python3 - <<'PY'
import re,html
t=open('/home/raver1975/lean/_bing.html',errors='ignore').read()
print('LEN',len(t))
blocks=re.findall(r'<li class="b_algo".*?</li>',t,re.S)
print('N blocks',len(blocks))
for b in blocks[:12]:
    m=re.search(r'<h2>.*?<a[^>]+href="([^"]+)"[^>]*>(.*?)</a>',b,re.S)
    if not m: continue
    url=html.unescape(m.group(1)); ti=re.sub(r'\s+',' ',re.sub(r'<[^>]+>','',html.unescape(m.group(2)))).strip()
    sn=re.search(r'<p class="b_lineclamp[^"]*">(.*?)</p>',b,re.S) or re.search(r'<p>(.*?)</p>',b,re.S)
    snip=re.sub(r'\s+',' ',re.sub(r'<[^>]+>','',html.unescape(sn.group(1)))).strip() if sn else ''
    print('-',ti[:120]); print('  ',url[:170]); print('   >',snip[:250])
PY
