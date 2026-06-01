#!/usr/bin/env python3
import itertools, random
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available'); exit()

def gen(n):
    return [tuple(tuple(b[i*n+j] for j in range(n)) for i in range(n)) for b in itertools.product([False,True], repeat=n*n)]

def dist(g1,g2):
    n=len(g1); return sum(1 for i in range(n) for j in range(n) if g1[i][j]!=g2[i][j])

n=2; configs=gen(n); N=len(configs); random.seed(42)
pts=[]
for _ in range(500):
    nc=random.randint(1,N); m={g:random.randint(0,nc-1) for g in configs}
    enc=lambda g,m=m:m[g]; fibers={}
    for g in configs: c=enc(g); fibers.setdefault(c,[]).append(g)
    recon={c:min(f,key=lambda x:max(dist(x,y) for y in f)) for c,f in fibers.items()}
    dec=lambda c,r=recon:r.get(c,configs[0])
    pd=(len(set(enc(g) for g in configs))-1)/(N-1)
    wcd=max(dist(g,dec(enc(g))) for g in configs)
    pts.append((pd,wcd))

fig,ax=plt.subplots(figsize=(10,7))
ax.scatter([p[0] for p in pts],[p[1] for p in pts],alpha=0.4,s=20,c='steelblue',label='Random channels')
ax.scatter([0],[max(dist(configs[0],g) for g in configs)],s=200,c='red',marker='*',zorder=5,label='Trivial (max privacy)')
ax.scatter([1],[0],s=200,c='green',marker='*',zorder=5,label='Identity (max surveillance)')
ax.set_xlabel('Privacy Defect'); ax.set_ylabel('Worst-Case Distortion')
ax.set_title(f'Privacy-Utility Tradeoff ({n}-Node Networks, {N} configs)')
ax.legend(); ax.grid(True,alpha=0.3)
plt.tight_layout(); plt.savefig('privacy_utility_tradeoff.png',dpi=150)
print('Saved: privacy_utility_tradeoff.png')