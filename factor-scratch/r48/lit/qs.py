import re,html,subprocess,sys,time
def st(h): return html.unescape(re.sub('<[^>]+>',' ',h)).strip()
def search(q,extra=""):
    qq=q.replace(' ','%20')
    url="https://arxiv.org/search/?searchtype=all&query="+qq+extra
    subprocess.run(["curl","-sSL","--max-time","100","-A","Mozilla/5.0 (X11; Linux x86_64)",url,"-o","_s3.html"],timeout=120)
    t=open("_s3.html",encoding="utf-8",errors="replace").read()
    blocks=re.split(r'<li class="arxiv-result">',t)[1:]
    if not blocks: print("  (no results)"); return
    for b in blocks:
        i=re.search(r'arxiv.org/abs/([0-9.v]+)',b)
        ti=re.search(r'<p class="title is-5 mathjax">(.*?)</p>',b,re.S)
        au=re.findall(r'searchtype=author[^>]*>([^<]+)</a>',b)
        print(i.group(1) if i else '?','|',st(ti.group(1))[:140] if ti else '?','|',', '.join(a.strip() for a in au[:4]))
if __name__=="__main__":
    search(sys.argv[1], sys.argv[2] if len(sys.argv)>2 else "")
