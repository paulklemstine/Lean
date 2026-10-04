import sys,json,urllib.request,urllib.parse,time
def q(bib,n=6):
    u="https://api.crossref.org/works?rows=%d&query.bibliographic=%s"%(n,urllib.parse.quote(bib))
    try:
        d=json.load(urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'litsweep/1.0 (mailto:x@y.z)'}),timeout=60))
    except Exception as e: return bib,"ERR "+str(e),[]
    out=[]
    for it in d['message']['items']:
        out.append((it.get('DOI'),(it.get('title') or ['?'])[0][:95],(it.get('container-title') or [''])[:40],
                    it.get('issued',{}).get('date-parts',[['?']])[0][0], it.get('page',''), it.get('volume','')))
    return bib,"n=%d"%len(out),out
for b in sys.argv[1:]:
    bb,c,o=q(b); print("\n=== %s  [%s]"%(bb,c))
    for doi,t,ct,yr,pg,vol in o: print("   DOI %-40s %s | vol %s pp %-12s | %s"%(str(doi),yr,str(vol),str(pg),t))
    sys.stdout.flush(); time.sleep(2)
