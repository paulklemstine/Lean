import numpy as np
from math import isqrt, log, log10
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
print("Falsifiable prediction (1): geomean lpf ratio by decade")
print("  decade      n      geomean lpf(#E)  geomean lpf(p+1)   ratio")
prev=None
for d in range(3,7):
    lo,hi=10**d,10**(d+1)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<min(hi,LIM-10)]
    if len(sel)<50: continue
    e=np.array([p+1-2*s2(p) for p in sel])
    p1=np.array([p+1 for p in sel])
    ge=float(np.exp(np.mean(np.log(lpf[e])))); gp=float(np.exp(np.mean(np.log(lpf[p1]))))
    print(f"  1e{d}  {len(sel):8d}   {ge:14.1f}  {gp:15.1f}   {ge/gp:.4f}")
