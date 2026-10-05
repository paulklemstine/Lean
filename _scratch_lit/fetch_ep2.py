import urllib.request, time, os
terms=["divides","multiple+of+every","covering+congruences","sumset","sum+set","difference+set+of+integers","A-A","additive+basis+of+order","positive+integer+set+in+which+every","modulo+every+integer","small+set+of+integers","arithmetic+progression+modulo"]
os.makedirs("ep",exist_ok=True)
hdr={'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) lit-search'}
urls={"p170":"https://www.erdosproblems.com/170"}
for t in terms: urls[t]="https://www.erdosproblems.com/search/"+t
for k,url in urls.items():
    fn="ep/"+k.replace("+","_")+".html"
    if os.path.exists(fn) and os.path.getsize(fn)>5000: continue
    for a in range(4):
        try:
            r=urllib.request.urlopen(urllib.request.Request(url,headers=hdr),timeout=60)
            d=r.read(); open(fn,"wb").write(d); print(k,len(d),r.status,flush=True); break
        except Exception as e:
            print(k,"ERR",e,flush=True); time.sleep(20)
    time.sleep(8)
