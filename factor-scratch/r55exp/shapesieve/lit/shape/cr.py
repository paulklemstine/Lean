import sys,urllib.parse,subprocess,json
q=sys.argv[1]; n=sys.argv[2] if len(sys.argv)>2 else "8"
url=("https://api.crossref.org/works?query.bibliographic="+urllib.parse.quote(q)
     +"&rows="+n+"&select=DOI,title,container-title,volume,page,published,author")
out=subprocess.run(["curl","-sSL","--max-time","60",url],capture_output=True,text=True).stdout
try: d=json.loads(out)
except Exception as e:
    print("JSON FAIL",e); print(out[:400]); sys.exit()
print("QUERY:",q)
print("URL:",url)
items=d.get("message",{}).get("items",[])
print("TOTAL-RESULTS:",d.get("message",{}).get("total-results"),"RETURNED:",len(items))
for it in items:
    print("---")
    print("DOI:",it.get("DOI"))
    print("TITLE:",it.get("title"))
    print("CONTAINER:",it.get("container-title"))
    print("VOLUME:",it.get("volume"),"| PAGE:",it.get("page"))
    print("PUBLISHED:",it.get("published",{}).get("date-parts"))
    print("AUTHORS:","; ".join([(a.get("given","")+" "+a.get("family","")).strip() for a in (it.get("author") or [])]))
