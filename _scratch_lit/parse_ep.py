import re,html,sys,glob,os
def strip(t):
    t=re.sub(r'<br\s*/?>','\n',t)
    t=re.sub(r'<[^>]+>',' ',t)
    t=html.unescape(t)
    return re.sub(r'[ \t]+',' ',t).strip()
def parse(fn):
    s=open(fn,encoding='utf-8',errors='replace').read()
    out=[]
    for m in re.finditer(r'<div class="problem-text" id="(\w+)">(.*?)\n</div>\s*</div>\s*', s, re.S):
        body=m.group(2)
        pid=re.search(r'<a href="/(\d+)">#(\d+)</a>', body)
        cont=re.search(r'<div id="content">(.*?)</div>', body, re.S)
        tags=re.search(r'<div id="tags">(.*?)</div>', body, re.S)
        add=re.search(r'<div class="problem-additional-text">(.*?)\n</div>', body, re.S)
        if not pid: continue
        out.append(dict(num=pid.group(2), status=m.group(1),
            content=strip(cont.group(1)) if cont else '',
            tags=strip(tags.group(1)) if tags else '',
            extra=strip(add.group(1)) if add else ''))
    return out
if __name__=='__main__':
    fn=sys.argv[1]
    ps=parse(fn)
    print('parsed',len(ps),'from',fn)
