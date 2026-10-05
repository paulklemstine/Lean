import math
from math import isqrt
def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]
def cardE(p):
    n=1
    for x in range(p):
        v=(x*x%p*x+x)%p
        if v==0: n+=1
        elif pow(v,(p-1)//2,p)==1: n+=2
    return n
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
    return aa,bb   # aa odd
bad=0
for p in sieve(2000):
    if p%4!=1: continue
    a,b=sum2sq(p); E=cardE(p)
    c1=(a-1)**2+b*b; c2=(a+1)**2+b*b
    ok = (c1==E) or (c2==E)
    if not ok: bad+=1; print("MISMATCH",p,a,b,E,c1,c2)
print("mismatches:",bad)
