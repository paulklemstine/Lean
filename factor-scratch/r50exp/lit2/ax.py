import sys,re,html,urllib.request,urllib.parse,time
def q(query,n=12):
    u=("https://export.arxiv.org/api/query?search_query="+urllib.parse.quote(query)
       +"&start=0&max_results=%d&sortBy=submittedDate&sortOrder=descending"%n)
    try:
        t=urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'litsweep/1.0'}),timeout=60).read().decode('utf8','replace')
    except Exception as e: return query,"ERR "+str(e),[]
    tot=re.search(r'opensearch:totalResults[^>]*>(\d+)<',t)
    tot=tot.group(1) if tot else '?'
    ents=re.findall(r'<entry>(.*?)</entry>',t,flags=re.S)
    out=[]
    for e in ents:
        i=re.search(r'<id>(.*?)</id>',e,re.S); ti=re.search(r'<title>(.*?)</title>',e,re.S)
        pb=re.search(r'<published>(.*?)</published>',e,re.S)
        su=re.sub(r'\s+',' ',html.unescape(ti.group(1))).strip() if ti else '?'
        out.append((i.group(1).split('/abs/')[-1] if i else '?', pb.group(1)[:7] if pb else '?', su))
    return query,"totalResults="+tot,out
for Q in sys.argv[1:]:
    qq,c,o=q(Q); print("\n=== [%s] %s"%(qq,c))
    for a,b,t in o: print("   %-14s %s  %s"%(a,b,t[:105]))
    sys.stdout.flush(); time.sleep(3.5)
