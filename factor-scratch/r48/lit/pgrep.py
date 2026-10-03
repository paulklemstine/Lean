import sys,re
f=sys.argv[1]; pat=sys.argv[2]
ctx=sys.argv[3] if len(sys.argv)>3 else '350'
pages=open(f,errors='replace').read().split('\f')
for i,p in enumerate(pages,1):
    for m in re.finditer(pat,p,re.I):
        a=max(0,m.start()-int(ctx)//2); b=min(len(p),m.end()+int(ctx)//2)
        print(f'--- p.{i} ---')
        print(' '.join(p[a:b].split()))
