import random, math
from collections import defaultdict

class UF:
    def __init__(s,n): s.p=list(range(n)); s.sz=[1]*n
    def find(s,x):
        while s.p[x]!=x: s.p[x]=s.p[s.p[x]]; x=s.p[x]
        return x
    def union(s,x,y):
        a,b=s.find(x),s.find(y)
        if a!=b: s.p[b]=a; s.sz[a]+=s.sz[b]

def susceptibility(n, p, trials=100):
    vals = []
    for _ in range(trials):
        uf = UF(n)
        for i in range(n):
            for j in range(i+1,n):
                if random.random()<p: uf.union(i,j)
        roots = {}
        for i in range(n): roots[uf.find(i)] = uf.sz[uf.find(i)]
        vals.append(sum(s**2 for s in roots.values())/n)
    mu = sum(vals)/len(vals)
    sd = math.sqrt(sum((x-mu)**2 for x in vals)/(len(vals)-1))
    return mu, 1.96*sd/math.sqrt(len(vals))

random.seed(42)
for c in [0.5, 1.0, 2.0]:
    m, ci = susceptibility(200, c/200, 50)
    print(f"c={c}: chi={m:.1f} +/- {ci:.1f}")