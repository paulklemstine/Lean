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
rnd=random.Random(555)
# KEY: compare #E to 4*(a random odd m) with m ~ E/4  -- i.e. SAME SIZE, same 2-adic val
print("SIZE-MATCHED + 2-ADIC-MATCHED control:  4*(random odd m), m ~ (#E)/4")
print(" decade     n     B    P(sm #E)  P(sm 4m~#E/4)   LIFT")
for d in [4,5,6]:
    lo,hi=10**d,min(10**(d+1),LIM-20)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if len(sel)<50: continue
    E=[p+1-2*s2(p) for p in sel]
    e=np.array(E)
    ctrl=np.array([4*(int(rnd.randrange(1,(x//4)|1))|1) for x in E],dtype=np.int64)
    B=int(0.5*isqrt(hi))
    a=float(np.mean(lpf[e]<=B)); c=float(np.mean(lpf[ctrl]<=B))
    print(f" 1e{d} {len(sel):7d} {B:6d}   {a:.5f}    {c:.5f}      {a/c:.4f}")
# and the 2-adic distribution of #E
print()
sel=[int(p) for p in PR if p%4==1 and 10**6<=p<2*10**6]
v2={}
for p in sel:
    e=p+1-2*s2(p); k=0
    while e%2==0: e//=2; k+=1
    v2[k]=v2.get(k,0)+1
tot=sum(v2.values())
print("2-adic valuation distribution of #E over split p in [1e6,2e6):")
for k in sorted(v2): print(f"   v2={k}: {v2[k]:7d}  ({100*v2[k]/tot:.1f}%)")
pv2={}
for p in sel:
    m=p+1; k=0
    while m%2==0: m//=2; k+=1
    pv2[k]=pv2.get(k,0)+1
print("2-adic valuation distribution of p+1:")
for k in sorted(pv2): print(f"   v2={k}: {pv2[k]:7d}  ({100*pv2[k]/tot:.1f}%)")
