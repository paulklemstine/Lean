import random
from math import isqrt, log
def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]
P=sieve(3000000)
PR=[q for q in P]
PRset=set(P)
def lpf(n):
    m=n; best=1
    for q in PR:
        if q*q>m: break
        if m%q==0:
            best=q
            while m%q==0: m//=q
    if m>1 and m>best: best=m
    return best
def sum2sq(p):
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
split=[p for p in P if p%4==1 and p>1000]
print("split primes:",len(split))
gE=gP1=gR=0.0; n=0
Bs=[200,500,1000,2000,5000,10000,20000]
cE={B:0 for B in Bs}; cP1={B:0 for B in Bs}; cR={B:0 for B in Bs}
rnd=random.Random(12345)
for p in split:
    a,b=sum2sq(p); E=p+1-2*a
    assert E>0
    lE=lpf(E); lP=lpf(p+1)
    # ECM baseline: a RANDOM curve order near p, same size as #E
    lR=lpf(rnd.randrange(p+1-int(2*isqrt(p)), p+1+int(2*isqrt(p))+1))
    gE+=log(lE); gP1+=log(lP); gR+=log(lR); n+=1
    for B in Bs:
        if lE<=B: cE[B]+=1
        if lP<=B: cP1[B]+=1
        if lR<=B: cR[B]+=1
import math
gE/=n; gP1/=n; gR/=n
print(f"geomean lpf  CM order #E   : {math.exp(gE):10.1f}")
print(f"geomean lpf  p+1            : {math.exp(gP1):10.1f}   ratio E/(p+1) = {math.exp(gE-gP1):.4f}")
print(f"geomean lpf  RANDOM curve   : {math.exp(gR):10.1f}   ratio E/random = {math.exp(gE-gR):.4f}")
print()
print("     B    P(lpf#E<=B)  P(lpf(p+1)<=B)  P(lpf(rand)<=B)   lift vs p+1  lift vs RANDOM")
for B in Bs:
    a=cE[B]/n; bb=cP1[B]/n; c=cR[B]/n
    print(f"{B:7d}   {a:10.5f}   {bb:12.5f}   {c:12.5f}   {a/bb:9.3f}   {a/c:10.3f}")
