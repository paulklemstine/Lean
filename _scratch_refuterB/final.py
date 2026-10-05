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
rnd=random.Random(112358)
print("FULLY MATCHED control: random odd m with m ~ oddpart(#E), same size, same 2-adic")
print(" decade     n     B    P(sm #E)  P(sm CTRL)   lift    Dickman rho(u) for size |oddpart|")
for d in [4,5,6]:
    lo,hi=10**d,min(10**(d+1),LIM-20)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if len(sel)<50: continue
    E=[p+1-2*s2(p) for p in sel]
    e=np.array(E)
    def oddpart(x):
        while x%2==0: x//=2
        return x
    oE=np.array([oddpart(x) for x in E],dtype=np.int64)
    ctrl=np.array([max(3,(int(rnd.randrange(1,max(2,int(t))))|1)) for t in oE],dtype=np.int64)
    B=int(0.5*isqrt(hi))
    a=float(np.mean(lpf[e]<=B)); c=float(np.mean(lpf[ctrl]<=B))
    print(f" 1e{d} {len(sel):7d} {B:6d}   {a:.5f}   {c:.5f}   {a/c:.4f}")
