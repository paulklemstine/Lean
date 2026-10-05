import urllib.request,urllib.parse,re,json,time,sys
UA={'User-Agent':'Mozilla/5.0'}
def g(q,n=40):
    url=("http://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)
         +f"&start=0&max_results={n}&sortBy=submittedDate&sortOrder=descending")
    for a in range(5):
        try: return urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=60).read().decode('utf8','replace')
        except Exception as e:
            print("  err",e,file=sys.stderr); time.sleep(25)
    return ""
for q in ['abs:"GPU" AND abs:"factorization" AND cat:cs.CR',
          'abs:"ASIC" AND abs:"factoring"',
          'abs:"CADO-NFS" OR abs:"Cado-NFS"',
          'abs:"record factorization" OR abs:"factoring record"',
          'ti:"factorization" AND cat:cs.DS']:
    print("="*60); print("Q:",q)
    r=g(q)
    for e in re.findall(r'<entry>(.*?)</entry>',r,re.S):
        ti=re.search(r'<title>(.*?)</title>',e,re.S); pub=re.search(r'<published>(\d{4})',e)
        i=re.search(r'<id>http://arxiv.org/abs/([\d.]+)',e)
        if pub and pub.group(1)>='2022':
            print(" ",pub.group(1),i.group(1),'|',re.sub(r'\s+',' ',ti.group(1)).strip()[:95])
    time.sleep(8)
