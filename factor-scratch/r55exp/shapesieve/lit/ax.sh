#!/bin/bash
# ax.sh <urlencoded search_query> [max]
timeout 60 curl -sSL "https://export.arxiv.org/api/query?search_query=$1&max_results=${2:-10}" \
 | python3 -c "
import sys,re
x=sys.stdin.read()
es=re.findall(r'<entry>.*?</entry>',x,re.S)
if not es: print('NO ENTRIES'); 
for e in es:
    def g(t):
        m=re.search('<'+t+'>(.*?)</'+t+'>',e,re.S); return re.sub(r'\s+',' ',m.group(1)).strip() if m else ''
    au=[re.sub(r'\s+',' ',a).strip() for a in re.findall(r'<name>(.*?)</name>',e,re.S)]
    print('ID:',g('id'))
    print('  TITLE:',g('title'))
    print('  AUTH:', '; '.join(au))
    print('  PUB:',g('published'),' UPD:',g('updated'))
    jr=re.search(r'<arxiv:journal_ref[^>]*>(.*?)</arxiv:journal_ref>',e,re.S)
    print('  JREF:',re.sub(r'\s+',' ',jr.group(1)).strip() if jr else 'NOT RETRIEVED')
    doi=re.search(r'<arxiv:doi[^>]*>(.*?)</arxiv:doi>',e,re.S)
    print('  DOI:',doi.group(1) if doi else 'NOT RETRIEVED')
    print()
"
