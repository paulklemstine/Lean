import sys,re,html,urllib.request,urllib.parse,time
UA={'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120 Safari/537.36'}
def both(q):
    r=[]
    # eprint
    try:
        t=urllib.request.urlopen(urllib.request.Request("https://eprint.iacr.org/search?q="+urllib.parse.quote(q),headers=UA),timeout=60).read().decode('utf8','replace')
        m=re.search(r'([\d,]+)\s*results',t); n=m.group(1) if m else '?'
        seg=t[m.start():] if m else ''
        ents=re.split(r'(?=href="/\d{4}/\d+")',seg)[1:9]
        for e in ents:
            h=re.match(r'href="(/\d{4}/\d+)"',e).group(1)
            txt=re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>',' ',e[:900])))
            txt=re.sub(r'href="[^"]*">\S+\s*\(PDF\)\s*Last updated: \S+\s*','',txt).strip()
            r.append(("EP"+h,txt[:120]))
    except Exception as e: n="ERR"; r=[]
    return n,r
for q in sys.argv[1:]:
    n,r=both(q); print("\n=== eprint [%s] -> %s results"%(q,n))
    for h,t in r: print("   ",h,"|",t)
    sys.stdout.flush(); time.sleep(3)
