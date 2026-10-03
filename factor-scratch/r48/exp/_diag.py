import random
from math import log2
import lll as L
random.seed(7)
d=12
B0=[[random.getrandbits(400) for _ in range(d)] for _ in range(d)]
B=[list(r) for r in B0]
n=d; dd=d
mu=[[0.0]*n for _ in range(n)]; Bst=[[0.0]*dd for _ in range(n)]
Dsh=[0.0]*n; logD=[0.0]*n
def gs_row(i):
    s=L._shift(B[i]); v=L._to_float(B[i],s)
    for j in range(i):
        num=sum(v[t]*Bst[j][t] for t in range(dd)); mu[i][j]=num/Dsh[j] if Dsh[j]>0 else 0.0
    r=list(v)
    for j in range(i):
        c=mu[i][j]; bj=Bst[j]
        for t in range(dd): r[t]-=c*bj[t]
    nrm=max(sum(x*x for x in r),1e-300)
    Bst[i]=r; Dsh[i]=nrm; logD[i]=2.0*s+log2(nrm)
for i in range(n): gs_row(i)
k=1; traj=[]
for step in range(3000):
    for j in range(k-1,-1,-1):
        if abs(mu[k][j])>0.5+1e-12:
            q=int(round(mu[k][j]))
            for t in range(dd): B[k][t]-=q*B[j][t]
    gs_row(k)
    lhs=logD[k]; rhs=logD[k-1]+log2(max(0.99-mu[k][k-1]**2,1e-12))
    if lhs>=rhs-1e-9: k+=1
    else:
        B[k],B[k-1]=B[k-1],B[k]; gs_row(k-1); gs_row(k); k=max(k-1,1)
    traj.append((step,k,round(lhs-rhs,6)))
    if k>=n: print("converged at step",step); break
else:
    print("no convergence; last 25 traj (step,k,lhs-rhs):")
    for t in traj[-25:]: print("  ",t)
