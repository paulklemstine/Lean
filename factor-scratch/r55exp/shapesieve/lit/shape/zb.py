import sys,urllib.parse,subprocess,json
q=sys.argv[1]; n=sys.argv[2] if len(sys.argv)>2 else "10"
url="https://api.zbmath.org/v1/document/_search?search_string="+urllib.parse.quote(q)+"&results_per_page="+n
out=subprocess.run(["curl","-sSL","--max-time","60",url],capture_output=True,text=True).stdout
try: d=json.loads(out)
except Exception as e:
    print("JSON FAIL",e); print(out[:400]); sys.exit()
print("QUERY:",q)
print("URL:",url)
print("NR_TOTAL_RESULTS:",(d.get("status") or {}).get("nr_total_results","?"))
res=d.get("result") or []
print("RETURNED:",len(res))
for r in res:
    print("---")
    print("ZBMATH_ID:",r.get("id"),"| identifier:",r.get("identifier"))
    t=r.get("title",{}) or {}
    print("TITLE:",t.get("title"))
    c=r.get("contributors",{}) or {}
    print("AUTHORS:","; ".join([a.get("name","?") for a in (c.get("authors") or [])]))
    src=(r.get("source",{}) or {}).get("series") or []
    for s in src:
        print("SOURCE:",s.get("title"),"| vol",s.get("volume"),"| year",s.get("year"),"| part",s.get("part"),"| issue",s.get("issue"))
    print("PAGES:",(r.get("source",{}) or {}).get("pages"))
    print("FULLSOURCE:",(r.get("source",{}) or {}).get("source"))
    print("YEAR:",r.get("year"))
    print("MSc:",[(m.get("code"),m.get("text")) for m in (r.get("msc") or [])])
    print("LINKS:",[(l.get("identifier"),l.get("type"),l.get("url")) for l in (r.get("links") or [])])
    print("DATESTAMP:",r.get("datestamp"))
