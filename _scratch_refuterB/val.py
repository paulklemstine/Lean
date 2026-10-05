import numpy as np
from math import isqrt
LIM=8000000
sp=np.ones(LIM+1,dtype=bool); sp[0:2]=False
for i in range(2,isqrt(LIM)+1):
    if sp[i]: sp[i*i::i]=False
PR=np.flatnonzero(sp)
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
sel=[int(p) for p in PR if p%4==1 and 10**6<=p<2*10**6]
def dist(f):
    d={}
    for p in sel:
        e=f(p); k=0
        while e%2==0 and e>0: e//=2; k+=1
        d[k]=d.get(k,0)+1
    t=sum(d.values())
    return {k:100*v/t for k,v in sorted(d.items())}, t
de,ne=dist(lambda p: p+1-2*s2(p))
dp,np_=dist(lambda p: p+1)
print(f"n={ne} split primes p in [1e6,2e6)")
print("v2 distribution of #E :", {k:round(v,1) for k,v in de.items()})
print("v2 distribution of p+1 :", {k:round(v,1) for k,v in dp.items()})
print()
print("Dickman check: P(B-smooth) for n~X is rho(log X / log B)")
import math
# mean v2 of #E vs p+1
print("mean v2 #E  =", sum(k*v for k,v in de.items())/100)
print("mean v2 p+1 =", sum(k*v for k,v in dp.items())/100)
