#!/bin/bash
timeout 60 curl -s -G "https://api.zbmath.org/v1/document/_search" --data-urlencode "search_string=$1" --data-urlencode "results_per_page=${2:-6}" | python3 -c "
import json,sys
d=json.load(sys.stdin)
st=d.get('status',{})
print('nr',st.get('nr_total_results'),'code',st.get('status_code'))
for r in d.get('result') or []:
    t=r.get('title'); ti=(t.get('title') if isinstance(t,dict) else t) or ''
    print(r.get('identifier'),'|',ti,'|',r.get('source'),'|',r.get('year'))
"
