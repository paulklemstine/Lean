#!/bin/bash
q="$1"
timeout 60 curl -skL "https://searx.be/search?q=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")&format=json" -H "User-Agent: Mozilla/5.0" -o /home/raver1975/lean/_sx.json
python3 - <<'PY'
import json
try:
    d=json.load(open('/home/raver1975/lean/_sx.json',errors='ignore'))
except Exception as e:
    print('ERR',e, open('/home/raver1975/lean/_sx.json',errors='ignore').read()[:300]); raise SystemExit
for r in d.get('results',[])[:12]:
    print('-',r.get('title','')[:110])
    print('  ',r.get('url','')[:170])
    c=(r.get('content') or '')[:220]
    print('   >',c)
PY
