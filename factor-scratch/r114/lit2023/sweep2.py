import urllib.request, urllib.parse, re, json, time, sys
QUERIES = [
 'abs:"factorization" AND abs:"tensor network"',
 'abs:"quantum annealing" AND abs:"factoring"',
 'abs:"Shor" AND abs:"resource estimate"',
 'abs:"factoring" AND abs:"logical qubit"',
 'abs:"cryptanalysis" AND abs:"RSA"',
 'abs:"RSA" AND abs:"private exponent" AND abs:"bits"',
 'abs:"post-quantum" AND abs:"RSA" AND abs:"migration"',
 'abs:"continued fraction" AND abs:"factoring" AND cat:cs.CR',
 'abs:"factorial" AND abs:"factoring" AND cat:cs.CR',
 'abs:"modular composition"',
 'abs:"multivariate" AND abs:"polynomial" AND cat:cs.CR',
 'abs:"Kaltofen" OR abs:"Shoup" AND cat:cs.CR',
 'abs:"triangular number" AND abs:"RSA"',
 'abs:"small roots" AND abs:"polynomial" AND cat:cs.CR',
 'abs:"Thue" AND abs:"polynomial" AND cat:cs.CR',
 'abs:"cryptographic" AND abs:"index calculus"',
 'abs:"subexponential" AND abs:"composite" AND cat:cs.CR',
 'abs:"ECM" AND abs:"stage 2"',
 'abs:"factorial" AND abs:"modular" AND cat:cs.CR',
 'abs:"Williams p+1" OR abs:"p+1 method" AND cat:cs.CR',
 'abs:"Lenstra" AND abs:"elliptic curve" AND cat:cs.CR',
 'abs:"rational" AND abs:"map" AND abs:"factorization" AND cat:cs.CR',
 'abs:"lattice" AND abs:"RSA" AND abs:"small secret"',
 'abs:"prime" AND abs:"generation" AND abs:"candidate sieves" AND cat:cs.CR',
]
UA={'User-Agent':'Mozilla/5.0'}
out={}
try: out=json.load(open('sweep.json'))
except: pass
for q in QUERIES:
    for start in (0,50):
        url=("http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)
             +f"&start={start}&max_results=50&sortBy=submittedDate&sortOrder=descending")
        got=False
        for attempt in range(4):
            try:
                r=urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=60).read().decode('utf8','replace')
                got=True; break
            except Exception as e:
                print("ERR",q,start,attempt,e,file=sys.stderr); time.sleep(30)
        if not got: break
        ents=re.findall(r'<entry>(.*?)</entry>',r,re.S)
        if not ents: break
        for e in ents:
            aid=re.search(r'<id>http://arxiv.org/abs/([\d.]+)v?\d*</id>',e)
            ti=re.search(r'<title>(.*?)</title>',e,re.S)
            pub=re.search(r'<published>(\d{4})',e)
            su=re.search(r'<summary>(.*?)</summary>',e,re.S)
            au=re.findall(r'<name>(.*?)</name>',e)
            if not aid: continue
            b=aid.group(1)
            if pub and pub.group(1)<'2022': continue
            out[b]=dict(title=re.sub(r'\s+',' ',ti.group(1)).strip() if ti else '',
                        year=pub.group(1) if pub else '', q=q, authors=au[:6],
                        abstract=re.sub(r'\s+',' ',su.group(1)).strip() if su else '')
        time.sleep(6)
json.dump(out,open('sweep.json','w'),indent=1)
print("TOTAL:",len(out))
