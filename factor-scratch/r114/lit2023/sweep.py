import urllib.request, urllib.parse, re, json, time, os, sys
QUERIES = [
 'abs:"integer factorization"',
 'abs:"factoring integers"',
 'abs:"factoring algorithm" AND cat:cs.CR',
 'abs:"factorization of integers"',
 'abs:"composite modulus" AND abs:"factoring"',
 'abs:"semiprime"',
 'abs:"Riemann zeta" AND abs:"factorization" AND cat:math.NT',
 'abs:"Pollard rho" OR abs:"Pollard rho method"',
 'abs:"quadratic sieve"',
 'abs:"special number field sieve"',
 'abs:"polynomial selection"',
 'abs:"Sieving problem" AND cat:cs.CR',
 'abs:"sieving problem"',
 'abs:"line sieving" OR abs:"lattice sieving" AND cat:cs.CR',
 'abs:"smoothness" AND abs:"factorization" AND cat:cs.CR',
 'abs:"ECM" AND abs:"factorization"',
 'abs:"elliptic curve method" AND abs:"factorization"',
 'abs:"class group" AND abs:"factoring" AND cat:cs.CR',
 'abs:"asymptotic complexity" AND abs:"factoring" AND cat:cs.CR',
 'abs:"GCD" AND abs:"subexponential"',
 'abs:"subexponential algorithm" AND cat:cs.CR',
 'abs:"Lenstra" AND abs:"factoring" AND cat:cs.CR',
 'abs:"Coppersmith method" AND abs:"small roots"',
 'abs:"lattice reduction" AND abs:"RSA" AND cat:cs.CR',
 'abs:"factorization" AND abs:"tensor network"',
 'abs:"quantum annealing" AND abs:"factoring"',
 'abs:"Shor algorithm" AND abs:"resource estimate"',
 'abs:"factoring" AND abs:"logical qubit"',
 'abs:"cryptanalysis" AND abs:"RSA" AND cat:cs.CR',
 'abs:"partially known" AND abs:"RSA" AND abs:"private key"',
 'abs:"side channel" AND abs:"factoring"',
 'abs:"post-quantum" AND abs:"RSA" AND abs:"migration"',
 'abs:"continuous fraction" AND abs:"factoring"',
 'abs:"Wilson theorem" AND abs:"factoring"',
 'abs:"factorial" AND abs:"factoring" AND cat:cs.CR',
 'abs:"multivariate" AND abs:"polynomial" AND abs:"modular composition"',
 'abs:"modular composition" AND cat:cs.CR',
 'abs:"Khovanskii" AND cat:cs.CR',
 'abs:"linear algebra" AND abs:"polynomial" AND abs:"factorization" AND cat:cs.CR',
 'abs:"triangular" AND abs:"RSA" AND abs:"primes"',
 'abs:"multi-polynomial" AND abs:"factorization"',
]
UA={'User-Agent':'Mozilla/5.0'}
out={}
for q in QUERIES:
    for start in (0,50):
        url=("http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)
             +f"&start={start}&max_results=50&sortBy=submittedDate&sortOrder=descending")
        try:
            r=urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=60).read().decode('utf8','replace')
        except Exception as e:
            print("ERR",q,start,e,file=sys.stderr); break
        ents=re.findall(r'<entry>(.*?)</entry>',r,re.S)
        if not ents: break
        for e in ents:
            aid=re.search(r'<id>http://arxiv.org/abs/([\d.]+)v?\d*</id>',e)
            ti=re.search(r'<title>(.*?)</title>',e,re.S)
            pub=re.search(r'<published>(\d{4})',e)
            su=re.search(r'<summary>(.*?)</summary>',e,re.S)
            au=re.findall(r'<name>(.*?)</name>',e)
            if not aid: continue
            base=aid.group(1)
            if pub and pub.group(1)<'2022': continue
            out[base]=dict(title=re.sub(r'\s+',' ',ti.group(1)).strip() if ti else '',
                           year=pub.group(1) if pub else '',
                           q=q, authors=au[:6],
                           abstract=re.sub(r'\s+',' ',su.group(1)).strip() if su else '')
        time.sleep(1.5)
json.dump(out,open('sweep.json','w'),indent=1)
print("total new-in-window:",len(out))
