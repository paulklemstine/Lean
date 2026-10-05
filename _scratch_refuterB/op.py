import numpy as np, random
from math import isqrt, log, log10
N=8000000
sp=np.ones(N+1,dtype=bool); sp[0:2]=False
for i in range(2,isqrt(N)+1):
    if sp[i]: sp[i*i::i]=False
PR=np.flatnonzero(sp)
print("sieve done, primes:",len(PR))
# lpf table via sieve (largest prime factor of every n<=N)
lpf=np.zeros(N+1,dtype=np.int64)
# vectorized: for each prime q, set lpf[m]=q for all multiples m -> last write wins = largest
for q in PR:
    lpf[q::q]=q
# but assigning per prime in increasing order overwrites with larger primes -> correct.
print("lpf table done")
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
    return aa,bb
split=[int(p) for p in PR if p%4==1 and 1000<p<=6500000]
print("split primes:",len(split))
# ECM operating point: B1 = c * p^(1/2)   (standard ECM stage-1 smoothness)
rnd=random.Random(999)
for frac in [0.5, 1.0, 2.0]:
    # block by decade of p
    blocks={}
    for p in split:
        B=int(frac*isqrt(p))
        if B>=N: continue
        d=10**int(log10(p))
        e=p+1-2*sum2sq_arr(p)[0]
        lE=lpf[e]; lP=lpf[p+1]
        lR=lpf[rnd.randrange(max(2,p-2*isqrt(p)),p+2*isqrt(p)+1)]
        s=blocks.setdefault(d,[0,0,0])
        s[0]+= (lE<=B); s[1]+=(lP<=B); s[2]+=(lR<=B); s.append(0) if False else None
    print(f"\n=== B1 = {frac}*sqrt(p) ===")
    print("  p-decade    n     P(smooth #E)  P(smooth p+1)  P(smooth rand)   lift/p+1  lift/rand")
    for d in sorted(blocks):
        s=blocks[d]; n=len([1 for p in split if 10**int(log10(p))==d])
        a,b,c=s[0]/n,s[1]/n,s[2]/n
        print(f"{d:>10d} {n:7d}   {a:10.5f}   {b:12.5f}   {c:12.5f}   {a/b:8.3f}   {a/c:9.3f}")
