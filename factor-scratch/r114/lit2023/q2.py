import urllib.request,urllib.parse,re,time,sys
UA={'User-Agent':'Mozilla/5.0'}
def g(q,n=30):
    url=("http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)
         +f"&start=0&max_results={n}&sortBy=submittedDate&sortOrder=descending")
    for a in range(4):
        try: return urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=60).read().decode('utf8','replace')
        except Exception as e: print("  err",e,file=sys.stderr); time.sleep(20)
    return ""
QS=['abs:"sieving problem" AND cat:cs.CR',
    'au:"Leducq"',
    'abs:"modular hyperbolas" OR abs:"shortest vector in a family of lattices"',
    'abs:"pairings" AND abs:"sieving" AND cat:cs.CR',
    'abs:"Bernstein" AND abs:"smooth" AND abs:"batch"',
    'ti:"Shor" AND abs:"qubits"',
    'abs:"logical qubits" AND abs:"RSA"',
    'abs:"error correction" AND abs:"factoring" AND abs:"qubits"',
    'abs:"arithmetic" AND abs:"qubits" AND abs:"factoring"']
for q in QS:
    print("="*60); print("Q:",q)
    r=g(q)
    n=0
    for e in re.findall(r'<entry>(.*?)</entry>',r,re.S):
        ti=re.search(r'<title>(.*?)</title>',e,re.S); pub=re.search(r'<published>(\d{4})',e)
        i=re.search(r'<id>http://arxiv.org/abs/([\d.]+)',e)
        au=re.findall(r'<name>(.*?)</name>',e)
        if pub and pub.group(1)>='2019':
            print(" ",pub.group(1),i.group(1),'|',re.sub(r'\s+',' ',ti.group(1)).strip()[:88],'|',au[:3])
            n+=1
    if n==0: print("  (none in 2019+)")
    time.sleep(7)
