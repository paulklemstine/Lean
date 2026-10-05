import urllib.request, time, os
terms=["sparse","basis","thin","Leech","Wichmann","Golomb","product+of+primes","primorial","modulo+every","residues+S+T","n-divisor","cover+all+integers+by+divisibility","set+of+differences"]
hdr={'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) lit-search'}
os.makedirs("ep",exist_ok=True)
for t in terms:
    fn="ep/s_"+t.replace("+","_")+".html"
    url="https://www.erdosproblems.com/search/"+t
    if os.path.exists(fn) and os.path.getsize(fn)>5000: continue
    for a in range(4):
        try:
            r=urllib.request.urlopen(urllib.request.Request(url,headers=hdr),timeout=60)
            d=r.read(); open(fn,"wb").write(d); print(t,len(d),r.status,flush=True); break
        except Exception as e:
            print(t,"ERR",e,flush=True); time.sleep(20)
    time.sleep(8)
for p in ["lists","definitions"]:
    fn="ep/page_"+p+".html"
    try:
        r=urllib.request.urlopen(urllib.request.Request("https://www.erdosproblems.com/"+p,headers=hdr),timeout=60)
        d=r.read(); open(fn,"wb").write(d); print(p,len(d),r.status,flush=True)
    except Exception as e: print(p,"ERR",e,flush=True)
    time.sleep(8)
