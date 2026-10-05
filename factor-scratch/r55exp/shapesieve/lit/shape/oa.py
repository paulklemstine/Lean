import sys,urllib.parse,subprocess,json
q=sys.argv[1]; n=sys.argv[2] if len(sys.argv)>2 else "8"
url=("https://api.openalex.org/works?search="+urllib.parse.quote(q)
     +"&per_page="+n+"&select=id,doi,title,publication_year,primary_location,authorships,biblio,type")
out=subprocess.run(["curl","-sSL","--max-time","60",url],capture_output=True,text=True).stdout
try: d=json.loads(out)
except Exception as e:
    print("JSON FAIL",e); print(out[:400]); sys.exit()
print("QUERY:",q); print("URL:",url)
print("META_COUNT:",(d.get("meta") or {}).get("count"))
res=d.get("results") or []
print("RETURNED:",len(res))
for r in res:
    print("---")
    print("OPENALEX_ID:",r.get("id"))
    print("DOI:",r.get("doi"))
    print("TITLE:",r.get("title"))
    print("YEAR:",r.get("publication_year"),"| TYPE:",r.get("type"))
    print("AUTHORS:","; ".join([a.get("author",{}).get("display_name","?") for a in (r.get("authorships") or [])]))
    pl=r.get("primary_location") or {}
    src=(pl.get("source") or {})
    print("SOURCE:",src.get("display_name"),"| vol:",(r.get("biblio") or {}).get("volume"),"| pages:",(r.get("biblio") or {}).get("first_page"),"-",(r.get("biblio") or {}).get("last_page"))
