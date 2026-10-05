import random, math
from math import isqrt, log
def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]
P=sieve(400000)
split=[p for p in P if p%4==1 and p>100]
inert=[p for p in P if p%4==3 and p>100]
def lpf(n):
    m=n; best=1
    for q in P:
        if q*q>m: break
        if m%q==0:
            best=q
            while m%q==0: m//=q
    if m>1: best=max(best,m)
    return best
# 1. is #E a sum of two squares => 3 mod 4 primes even exponent? verify exponents
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
    return aa,bb
bad3=0; tot=0
odd_exp_p1=0
for p in split[:2000]:
    a,b=sum2sq(p)
    E=(a-1)**2+b*b if (a-1)**2+b*b>0 else (a+1)**2+b*b
    # determine sign by matching mod p arithmetic is ambiguous; just take both, use the one ≡ p+1-... :
    # pick the one that is 0 mod 4 (theorem four_dvd_cmCard_split)
    c1=(a-1)**2+b*b; c2=(a+1)**2+b*b
    E = c1 if c1%4==0 else c2
    m=E
    for q in P:
        if q*3%4==3:
            e=0
            while m%q==0: m//=q; e+=1
            if e%2==1: bad3+=1
    tot+=1
    # p+1
    m=p+1
    for q in P:
        if q%4==3:
            e=0
            while m%q==0: m//=q; e+=1
            if e%2==1: odd_exp_p1+=1; break
print(f"split primes checked={tot}  3mod4-prime-odd-exponent in #E: {bad3}   in p+1: {odd_exp_p1}")
