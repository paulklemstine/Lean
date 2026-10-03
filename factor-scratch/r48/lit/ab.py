import sys,subprocess,xml.etree.ElementTree as ET
ids=','.join(sys.argv[1:])
out=subprocess.run(['curl','-sG','https://export.arxiv.org/api/query','--data-urlencode','id_list='+ids,'--data','max_results=40'],capture_output=True,text=True,timeout=120).stdout
ns={'a':'http://www.w3.org/2005/Atom'}
t=ET.fromstring(out)
for e in t.findall('a:entry',ns):
    i=e.find('a:id',ns).text.split('/abs/')[-1]
    d=e.find('a:published',ns).text[:10]
    ti=' '.join(e.find('a:title',ns).text.split())
    su=' '.join(e.find('a:summary',ns).text.split())
    au=', '.join(x.find('a:name',ns).text for x in e.findall('a:author',ns))
    print('='*100); print(f'{i}  {d}  {ti}'); print(f'AUTHORS: {au[:200]}'); print(su)
