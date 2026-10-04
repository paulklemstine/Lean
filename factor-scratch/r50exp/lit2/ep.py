import sys,re,html,urllib.request,urllib.parse,time
UA={'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36'}
def get(q,show=14):
    u="https://eprint.iacr.org/search?q="+urllib.parse.quote(q)
    try:
        t=urllib.request.urlopen(urllib.request.Request(u,headers=UA),timeout=60).read().decode('utf8','replace')
    except Exception as e:
        return q,"ERR "+str(e),[]
    m=re.search(r'([\d,]+)\s*results',t)
    if not m: return q,"?",[]
    seg=t[m.start():]
    ent=re.split(r'(?=href="/\d{4}/\d+")',seg)[1:1+show]
    out=[]
    for e in ent:
        href=re.match(r'href="(/\d{4}/\d+)"',e).group(1)
        txt=re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]+>',' ',e[:1400])))
        txt=re.sub(r'href="/\d{4}/\d+">\S+\s*\(PDF\)\s*Last updated: \S+\s*','',txt).strip()
        out.append(("https://eprint.iacr.org"+href,txt[:190]))
    return q,m.group(1)+" results",out
for q in sys.argv[1:]:
    q2,c,o=get(q)
    print("=== %-42s ==> %s"%(q2,c))
    for h,t in o: print("   ",h,"|",t)
    sys.stdout.flush(); time.sleep(3)
