import numpy as np, random
from math import isqrt
LIM=8000000
sp=np.ones(LIM+1,dtype=bool); sp[0:2]=False
for i in range(2,isqrt(LIM)+1):
    if sp[i]: sp[i*i::i]=False
PR=np.flatnonzero(sp)
lpf=np.zeros(LIM+1,dtype=np.int64)
for q in PR: lpf[q::q]=q
def s2(p):
    z=2
    while True:
        t=pow(z,(p-1)//4,p)
        if (t*t)%p==p-1: break
        z+=1
    a,b=p,t; r=isqrt(p)
    while b>r: a,b=b,a%b
    aa=b; bb=isqrt(p-b*b)
    if aa%2==0: aa,bb=bb,aa
    if aa%4!=1: aa=-aa
    return aa
rnd=random.Random(7)
print("CONFOUND CONTROL: 4|#E is a known theorem. Match the baseline on residue class.\n")
print(" decade    n     P(sm #E)  P(sm p+1)  P(sm 4m'~p)  P(sm 2m~p)   lift/p+1  lift/MATCHED")
for d in [3,4,5,6]:
    lo,hi=10**d,min(10**(d+1),LIM-20)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if len(sel)<50: continue
    e=np.array([p+1-2*s2(p) for p in sel])
    p1=np.array([p+1 for p in sel])
    # MATCHED baseline: 4*m with m odd ~ p/4  (same forced 2-adic valuation, random otherwise)
    m4=np.array([4*rnd.randrange(1,(p//4)|1) for p in sel],dtype=np.int64)
    m4=[4*(int(rnd.randrange(1,(p//4)|1))|1) for p in sel]
    m4=np.array([x for x in m4],dtype=np.int64)
    m4=m4[m4<LIM]
    B=int(0.5*isqrt(hi))
    a=float(np.mean(lpf[e]<=B)); b=float(np.mean(lpf[p1]<=B))
    c=float(np.mean(lpf[m4[:len(sel)]]<=B))
    print(f" 1e{d} {len(sel):7d}   {a:.5f}   {b:.5f}   {c:.5f}          {a/b:7.3f}   {a/c:7.3f}")
