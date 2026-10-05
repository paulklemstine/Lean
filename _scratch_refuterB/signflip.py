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
def oddpart(x):
    while x%2==0: x//=2
    return x
rnd=random.Random(20260925)
print("SIGN TEST. Hypothesis: sum-of-two-squares forces lpf(#E) DOWN.")
print("Test: at MATCHED odd-part size, is #E's lpf below or above a random odd number?\n")
print(" decade      n    geo lpf(#E)   geo lpf(random odd, same size)   ratio  (>1 means CM is WORSE)")
for d in [4,5,6]:
    lo,hi=10**d,min(10**(d+1),LIM-20)
    sel=[int(p) for p in PR if p%4==1 and lo<=p<hi]
    if len(sel)<50: continue
    E=[p+1-2*s2(p) for p in sel]
    e=np.array(E)
    oE=np.array([oddpart(x) for x in E],dtype=np.int64)
    ctrl=np.array([max(3,(int(rnd.randrange(1,max(2,int(t))))|1)) for t in oE],dtype=np.int64)
    ge=float(np.exp(np.mean(np.log(lpf[e]))))
    gc=float(np.exp(np.mean(np.log(lpf[ctrl]))))
    print(f" 1e{d} {len(sel):7d}   {ge:11.1f}   {gc:29.1f}   {ge/gc:.4f}")
print()
print("MECHANISM: a sum of two squares has every 3 mod 4 prime to EVEN exponent.")
print("Since lpf(2^v m)=lpf(m), the 3 mod 4 restriction acts ONLY on the odd part,")
print("and it FORCES the odd part to be built from 1 mod 4 primes -> a 2x sparser")
print("prime pool -> the largest prime factor is pushed UP, not down.")
