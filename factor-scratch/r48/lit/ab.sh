#!/bin/bash
IDS="$*"
timeout 120 curl -sG 'https://export.arxiv.org/api/query' \
  --data-urlencode "id_list=$IDS" --data 'max_results=40' \
| python3 -c "
import sys,xml.etree.ElementTree as ET
ns={'a':'http://www.w3.org/2005/Atom'}
t=ET.parse(sys.stdin).getroot()
for e in t.findall('a:entry',ns):
    i=e.find('a:id',ns).text.split('/abs/')[-1]
    d=e.find('a:published',ns).text[:10]
    ti=' '.join(e.find('a:title',ns).text.split())
    su=' '.join(e.find('a:summary',ns).text.split())
    au=', '.join(x.find('a:name',ns).text for x in e.findall('a:author',ns))[:120]
    print('='*100); print(f'{i}  {d}  {ti}'); print(f'AUTHORS: {au}'); print(su)
"
