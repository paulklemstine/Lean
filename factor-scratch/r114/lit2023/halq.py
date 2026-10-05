import urllib.request,urllib.parse,json,re,time
def q(query,rows=80):
    u=("https://api.archives-ouvertes.fr/search/?"+urllib.parse.urlencode({
        'q':query,'fl':'title_s,uri_s,abstract_s,producedDate_s,authFullName_s',
        'wt':'json','rows':rows,'sort':'producedDateY_i desc'}))
    r=urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'Mozilla/5.0'}),timeout=90).read().decode('utf8','replace')
    d=json.loads(r)
    if 'response' not in d: return None,d
    return d['response']['numFound'],d['response']['docs']
QUERIES=[
 'title_t:"number field sieve"',
 'title_t:"factorization" AND (abs_t:"sieving" OR abs_t:"sieve")',
 'abs_t:"number field sieve" AND (abs_t:"sieving" OR abs_t:"sieve")',
 'title_t:"RSA" AND abs_t:"factorization"',
 'abs_t:"GNFS" OR abs_t:"general number field sieve"',
 'title_t:"sieving"',
 'abs_t:"RSA" AND abs_t:"record computation"',
]
seen=set()
for Q in QUERIES:
    n,docs=q(Q)
    print("="*70); print("Q:",Q,"-> numFound:",n)
    if not docs: continue
    for x in docs:
        y=str(x.get('producedDate_s','?'))
        ti=x['title_s'][0]
        if y[:4]>='2022' and (y,ti) not in seen:
            seen.add((y,ti))
            print(" ",y[:10],'|',ti[:92],'|',(x.get('uri_s') or '')[:60])
    time.sleep(2)
