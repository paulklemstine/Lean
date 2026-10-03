#!/bin/bash
# usage: q.sh "search_query" max
Q="$1"; M="${2:-40}"
timeout 90 curl -sG 'https://export.arxiv.org/api/query' \
  --data-urlencode "search_query=$Q" \
  --data-urlencode "start=0" --data-urlencode "max_results=$M" \
  --data-urlencode "sortBy=submittedDate" --data-urlencode "sortOrder=descending" \
| python3 -c "
import sys,re,xml.etree.ElementTree as ET
ns={'a':'http://www.w3.org/2005/Atom','ar':'http://arxiv.org/schemas/atom'}
t=ET.parse(sys.stdin).getroot()
tot=t.find('{http://a9.com/-/spec/opensearch/1.1/}totalResults').text
print('TOTAL',tot)
for e in t.findall('a:entry',ns):
    i=e.find('a:id',ns).text.split('/abs/')[-1]
    d=e.find('a:published',ns).text[:10]
    ti=' '.join(e.find('a:title',ns).text.split())
    print(f'{i}\t{d}\t{ti}')
"
