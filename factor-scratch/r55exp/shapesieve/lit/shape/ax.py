import sys,urllib.parse,subprocess,re,xml.etree.ElementTree as ET
q=sys.argv[1]; n=sys.argv[2] if len(sys.argv)>2 else "10"
url="https://export.arxiv.org/api/query?search_query="+urllib.parse.quote(q)+"&max_results="+n
out=subprocess.run(["curl","-sSL","--max-time","60",url],capture_output=True,text=True).stdout
NS={'a':'http://www.w3.org/2005/Atom','o':'http://a9.com/-/spec/opensearch/1.1/','x':'http://arxiv.org/schemas/atom'}
try: r=ET.fromstring(out)
except Exception as e:
    print("PARSE FAIL",e); print(out[:500]); sys.exit()
print("QUERY:",q)
print("URL:",url)
print("TOTAL:",r.findtext('o:totalResults',default='?',namespaces=NS))
es=r.findall('a:entry',NS)
print("RETURNED:",len(es))
for e in es:
    print("---")
    print("ID:",e.findtext('a:id',default='',namespaces=NS))
    print("TITLE:"," ".join(e.findtext('a:title',default='',namespaces=NS).split()))
    au=[a.findtext('a:name',default='',namespaces=NS) for a in e.findall('a:author',NS)]
    print("AUTHORS:","; ".join(au) if au else "NONE")
    print("PUB:",e.findtext('a:published',default='',namespaces=NS))
    c=e.find('x:journal_ref',NS); print("JOURNAL_REF:",c.text if c is not None else "NOT RETRIEVED")
    d=e.find('x:doi',NS); print("DOI:",d.text if d is not None else "NOT RETRIEVED")
    print("ABSTRACT:"," ".join(e.findtext('a:summary',default='',namespaces=NS).split())[:700])
