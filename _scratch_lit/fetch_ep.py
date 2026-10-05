import urllib.request, time, sys, os
terms = ["divisor","divisible","lcm","additive+basis","smooth+number","difference+set","covering+system","ruler","postage+stamp","difference"]
os.makedirs("ep", exist_ok=True)
hdr={'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) research-literature-search'}
for t in terms:
    url=f"https://www.erdosproblems.com/search/{t}"
    fn="ep/"+t.replace("+","_")+".html"
    if os.path.exists(fn) and os.path.getsize(fn)>5000: continue
    for attempt in range(4):
        try:
            r=urllib.request.urlopen(urllib.request.Request(url,headers=hdr),timeout=60)
            d=r.read()
            open(fn,"wb").write(d)
            print(t,len(d),r.status,flush=True)
            break
        except Exception as e:
            print(t,"ERR",e,flush=True)
            time.sleep(20)
    time.sleep(8)
