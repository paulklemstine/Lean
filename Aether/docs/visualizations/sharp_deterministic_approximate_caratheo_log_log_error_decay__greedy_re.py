"""Visualize the O(1/k) error decay: greedy realized error, the sharp tau/k
bound, and the classical R^2/k bound, on log-log axes."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def centroid(p, V):
    x = [0.0]*len(V[0])
    for pi, Vi in zip(p, V):
        x = [a+pi*b for a, b in zip(x, Vi)]
    return x

def tau(p, V):
    x = centroid(p, V)
    return sum(pi*sum((a-b)**2 for a,b in zip(Vi,x)) for pi,Vi in zip(p,V))

def greedy_err(p, V, k):
    x = centroid(p, V); dim=len(V[0]); s=[0.0]*dim; idx=[]
    for _ in range(k):
        bi,bv=0,math.inf
        for i in range(len(V)):
            val=sum((s[d]+(V[i][d]-x[d]))**2 for d in range(dim))
            if val<bv: bi,bv=i,val
        idx.append(bi); s=[s[d]+V[bi][d]-x[d] for d in range(dim)]
    avg=[sum(V[i][d] for i in idx)/k for d in range(dim)]
    return sum((x[d]-avg[d])**2 for d in range(dim))

V=[[2,0],[0,1],[-1,-1],[0.5,2],[1.5,-0.5]]
p=[0.30,0.25,0.20,0.15,0.10]
R2=max(sum(c*c for c in Vi) for Vi in V)
t=tau(p,V)
ks=list(range(1,65))
ge=[max(greedy_err(p,V,k),1e-12) for k in ks]
plt.figure(figsize=(8,5))
plt.loglog(ks,[R2/k for k in ks],'--',label=r'classical $R^2/k$')
plt.loglog(ks,[t/k for k in ks],'-',label=r'sharp $\tau/k$')
plt.loglog(ks,ge,'o-',ms=3,label='greedy realized')
plt.xlabel('list length k'); plt.ylabel('squared error')
plt.title('Approximate Caratheodory: greedy error vs bounds')
plt.legend(); plt.grid(True, which='both', alpha=0.3)
plt.tight_layout(); plt.savefig('caratheodory_decay.png', dpi=150)
print('wrote caratheodory_decay.png')
