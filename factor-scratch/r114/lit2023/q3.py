import urllib.request,urllib.parse,re,time,sys
UA={'User-Agent':'Mozilla/5.0'}
def g(q,n=30):
    url=("http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)
         +f"&start=0&max_results={n}&sortBy=submittedDate&sortOrder=descending")
    for a in range(4):
        try: return urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=60).read().decode('utf8','replace')
        except Exception as e: print("  err",e,file=sys.stderr); time.sleep(20)
    return ""
# SIeving Problem proper: Bernstein multipoint eval, Schroeppel-Shamir, Leducq modular hyperbolas
QS=['abs:"multipoint evaluation" AND abs:"sieving"',
    'abs:"modular hyperbolas"',
    'au:"Schroeppel" AND abs:"factorization"',
    'abs:"smooth numbers" AND abs:"batch" AND cat:cs.DS',
    'ti:"sieving" AND cat:cs.CR',
    'abs:"line sieve" OR abs:"lattice sieve" AND cat:cs.CR',
    'abs:"Coppersmith" AND abs:"many variables"',
    'au:"Coppersmith" AND cat:cs.CR',
    'abs:"subspace" AND abs:"factorization" AND abs:"small root"']
for q in QS:
    print("="*60); print("Q:",q)
    r=g(q); n=0
    for e in re.findall(r'<entry>(.*?)</entry>',r,re.S):
        ti=re.search(r'<title>(.*?)</title>',e,re.S); pub=re.search(r'<published>(\d{4})',e)
        i=re.search(r'<id>http://arxiv.org/abs/([\d.]+)',e)
        if pub and pub.group(1)>='2016':
            print(" ",pub.group(1),i.group(1),'|',re.sub(r'\s+',' ',ti.group(1)).strip()[:88]); n+=1
    if n==0: print("  (none 2016+)")
    time.sleep(7)
