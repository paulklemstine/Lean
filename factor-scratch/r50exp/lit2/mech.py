from sympy import jacobi_symbol, legendre_symbol
from fractions import Fraction as F
import math
def v2(x):
    k=0
    while x%2==0: x//=2;k+=1
    return k
def ord2(p,g):
    s=v2(p-1)
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)!=1: return s-i+1
    return 0
for (p,q) in [(3,17),(3,5),(5,41),(41,113),(3,97)]:
    n=p*q; sp,sq=v2(p-1),v2(q-1)
    A_t=A_f=B_t=B_f=0
    dist={}
    for g in range(2,n):
        if math.gcd(g,n)!=1: continue
        if jacobi_symbol(g,n)!=-1: continue
        a,b=ord2(p,g),ord2(q,g)
        ok=(a!=b)
        if legendre_symbol(g,p)==-1: A_t+=1; A_f+= (not ok)
        else: B_t+=1; B_f+=(not ok)
        dist[(a,b)]=dist.get((a,b),0)+1
    print("p=%3d q=%3d s=(%d,%d)  armA(g/p=-1): %d trials, %d fail (%.4f)   armB(g/p=+1): %d trials, %d fail (%.4f)  overall fail=%.5f"%(
        p,q,sp,sq,A_t,A_f,A_f/A_t if A_t else 0,B_t,B_f,B_f/B_t if B_t else 0,(A_f+B_f)/(A_t+B_t)))
    print("     (a,b) distribution over Jacobi=-1 arm:",dict(sorted(dist.items())))
print()
# Check the claim (g/p)=-1 <=> v2(ord_p g) = s_p
bad=0
for p in [3,5,17,41,113,97,257,65537]:
    for g in range(2,60):
        if math.gcd(g,p)!=1: continue
        if (legendre_symbol(g,p)==-1) != (ord2(p,g)==v2(p-1)): bad+=1
print("lemma  (g/p)=-1 <=> v2(ord_p g)=s_p : violations =",bad)
