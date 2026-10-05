#!/bin/bash
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0 Safari/537.36"
q="$1"; out="$2"
curl -sL --max-time 120 -A "$UA" "http://export.arxiv.org/api/query?search_query=$q&max_results=20&sortBy=submittedDate&sortOrder=descending" -o "$out"
echo "bytes: $(stat -c%s $out)"
python3 -c "
import re,sys
s=open('$out').read()
n=0
for e in re.findall(r'<entry>(.*?)</entry>',s,re.S):
    t=re.sub(r'\s+',' ',re.search(r'<title>(.*?)</title>',e,re.S).group(1)).strip()
    i=re.search(r'<id>(.*?)</id>',e).group(1)
    d=re.search(r'<published>(.*?)</published>',e).group(1)[:10]
    print(d, i.rsplit('/',1)[-1], '|', t[:110]); n+=1
print('entries:',n)
"
