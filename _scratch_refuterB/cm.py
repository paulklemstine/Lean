import math, random
from math import isqrt

def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]

def legendre_count(p,A=1,B=0):
    # brute force #E over F_p for y^2=x^3+Ax+B
    s=sum(1 for x in range(p) if (x*x%p*x+A*x+B)%p == 0)
    s+=sum(1 for x in range(p) if pow((x*x%p*x+A*x+B)%p,(p-1)//2,p)==1)
    return p+1-s

def sum2sq(p):
    # Cornacchia: p = a^2+b^2, a odd, b even, a = 1 mod 4 (canonical CM)
    z=2
    while True:
        t=pow(z,(p-1)//4,p)
        if (t*t)%p==p-1: break
        z+=1
    a,b=p,t
    r=isqrt(p)
    while b>r:
        a,b=b,a%b
    bb=isqrt(p-b*b)
    assert bb*bb==p-b*b
    return b,bb

# calibrate the sign convention on small split primes
print("calibration: brute force vs (a-1)^2+b^2 / (a+1)^2+b^2")
for p in sieve(500):
    if p%4!=1: continue
    a,b=sum2sq(p)
    tr=legendre_count(p)
    c1=(a-1)**2+b*b; c2=(a+1)**2+b*b
    print(p,a,b,"#E=",tr,"(a-1)^2+b^2=",c1,"(a+1)^2+b^2=",c2,"ap=",p+1-tr)
