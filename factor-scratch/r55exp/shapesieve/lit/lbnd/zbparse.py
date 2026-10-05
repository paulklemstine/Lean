import json,sys
f=sys.argv[1]
try: d=json.load(open(f))
except Exception as e:
    print("  PARSE FAIL:",e); print("  body:",open(f).read()[:300]); sys.exit()
r=d.get('result') or []
print("  hits:",len(r),"| status:",d.get('status'))
for x in r:
    t=x.get('title')
    t=t.get('title') if isinstance(t,dict) else t
    src=x.get('source') or {}
    au=[a.get('name') for a in (x.get('contributors',{}).get('authors') or [])]
    yr=''
    s=src.get('series') or []
    if s: yr=s[0].get('year','')
    b=src.get('book') or []
    if b: yr=b[0].get('year','')
    j=src.get('journal') or ''
    print("  *",(t or '').strip().replace('\n',' '))
    print("    zbMATH:",x.get('id'),"| yr:",yr,"| type:",(x.get('document_type') or {}).get('code'))
    print("    authors:",au)
