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
rnd=random.Random(8080)
print("Is the geomean-lpf ratio 0.42 real, or just 'the odd part is smaller'?")
print(" control = 2^v * (random odd m), v = v2(#E), m ~ (#E / 2^v)  [SAME size, SAME 2-adic]")
print()
print(" decade     n   geo lpf(#E)  geo lpf(p+1)  ratio   geo lpf(CTRL)  ratio_vs_CTRL")
for d in [4,5,6]:
    lo,hi=10**d,min(10**(d+1),LIM-20)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if len(sel)<50: continue
    E=[p+1-2*s2(p) for p in sel]
    e=np.array(E); p1=np.array([p+1 for p in sel])
    ctrl=[]
    for x in E:
        v=0; t=x
        while t%2==0: t//=2; v+=1
        ctrl.append((1<<v)*(int(rnd.randrange(1,max(2,(t)|1)))|1))
    ctrl=np.array(ctrl,dtype=np.int64)
    ge=float(np.exp(np.mean(np.log(lpf[e]))))
    gp=float(np.exp(np.mean(np.log(lpf[p1]))))
    gc=float(np.exp(np.mean(np.log(lpf[ctrl]))))
    print(f" 1e{d} {len(sel):7d}  {ge:11.1f}  {gp:12.1f}  {ge/gp:.4f}  {gc:13.1f}  {ge/gc:.4f}")
