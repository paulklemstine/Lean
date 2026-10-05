import numpy as np, random
from math import isqrt, log10
LIM=120000000
sp=np.ones(LIM+1,dtype=bool); sp[0:2]=False
for i in range(2,isqrt(LIM)+1):
    if sp[i]: sp[i*i::i]=False
PR=np.flatnonzero(sp)
print("sieve to",LIM,"primes",len(PR),flush=True)
def sum2sq_arr(p):
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
def bsmooth_frac(vals, Bs):
    """fraction of vals that are Bs-smooth, vectorized"""
    v=vals.astype(np.int64).copy()
    m=v.copy()
    for B in Bs:
        m=m.copy()
        idx=np.flatnonzero(m>1)
        for q in PR:
            if q>B: break
            qq=int(q)
            sel=m%qq==0
            while sel.any():
                m[sel]//=qq
                sel=m%qq==0
        pass
    return None
# simpler: per-block B is constant, do trial division by primes<=B
def smooth_frac(vals,B):
    m=vals.astype(np.int64).copy()
    for q in PR:
        qq=int(q)
        if qq>B: break
        sel=(m%qq==0)&(m>1)
        while sel.any():
            m[sel]//=qq
            sel=(m%qq==0)&(m>1)
    return float(np.mean(m==1))
rnd=random.Random(4242)
frac=0.5
for lo,hi in [(10**5,10**6),(10**6,10**7),(10**7,10**8),(10**8,12*10**8)]:
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if not sel: continue
    e=np.array([p+1-2*sum2sq_arr(p) for p in sel],dtype=np.int64)
    p1=np.array([p+1 for p in sel],dtype=np.int64)
    r =np.array([rnd.randrange(p-2*isqrt(p),p+2*isqrt(p)+1) for p in sel],dtype=np.int64)
    B=int(frac*isqrt(hi))
    a=smooth_frac(e,B); b=smooth_frac(p1,B); c=smooth_frac(r,B)
    print(f"p in [{lo:.0e},{hi:.0e})  n={len(sel):7d}  B=0.5*sqrt(hi)={B}")
    print(f"   P(smooth #E)={a:.5f}  P(smooth p+1)={b:.5f}  P(smooth rand)={c:.5f}   lift/p+1={a/b:.3f}  lift/rand={a/c:.3f}",flush=True)
