from sympy import primerange, jacobi_symbol
from fractions import Fraction as F
import math
def v2(x):
    k=0
    while x%2==0: x//=2; k+=1
    return k
def ord2(p,g):
    """v2(ord_p(g)): smallest i with g^((p-1)/2^i) != 1 is i=s-v2(ord)+1."""
    s=v2(p-1)
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)!=1: return s-i+1
    return 0   # no i in 0..s fails  <=>  v2(ord_p(g)) = 0
# sanity
assert ord2(3,2)==v2(2)==1, ord2(3,2)
assert ord2(7,2)==v2(3)==0, ord2(7,2)
assert ord2(7,3)==v2(6)==1
print("ord2 self-test OK")

def F_jac(sp,sq):
    if sp==sq: return F(1)
    return F(1)-F(1,2**(1+abs(sp-sq)))
def pk(j,k):
    if k>j: return F(0)
    return F(1,2**j) if k==0 else F(2**(k-1),2**j)
def F_uni(sp,sq):
    return F(1)-sum(pk(sp,k)*pk(sq,k) for k in range(0,max(sp,sq)+1))

PS=[p for p in primerange(3,80)]
meu=F(0);mjac=F(0);W=0;bad=0;cells=0
for i,p in enumerate(PS):
    for q in PS[i+1:]:
        n=p*q; U=J=CJ=CJok=0
        for g in range(2,n):
            if math.gcd(g,n)!=1: continue
            U+=1; ok=(ord2(p,g)!=ord2(q,g)); J+=ok
            if jacobi_symbol(g,n)==-1: CJ+=1; CJok+=ok
        if CJ==0: continue
        mu=F(J,U); mj=F(CJok,CJ)
        sp,sq=v2(p-1),v2(q-1)
        fu=F_uni(sp,sq); fj=F_jac(sp,sq)
        w=F(1)
        cells+=1; meu=max(meu,abs(mu-fu)); mjac=max(mjac,abs(mj-fj))
        if abs(mj-fj)>F(1,500): bad+=1
print("cells=%d  max|measured-formula| uniform=%.6f  jacobi=%.6f  (#jac cells off>1/500: %d)"%(cells,float(meu),float(mjac),bad))

def ps(j): return F(2)**(-j)
tot=sum(ps(x) for x in range(1,41))
S={j:ps(j)/tot for j in range(1,41)}
fu=sum(S[j]*S[j2]*F_uni(j,j2) for j in S for j2 in S)
fj=sum(S[j]*S[j2]*F_jac(j,j2) for j in S for j2 in S)
print("\nEXACT uniform: success=%.12f   (20/27 = %.12f, diff %+.3e)"%(float(1-fu),20/27,float(1-fu)-20/27))
print("EXACT Jacobi-conditioned (-1): success=%.12f"%float(1-fj))
print("exact jacobi failure = %s"%fj)
print("RATIO %.6fx    abs gain %+.6f    attempts 1.3500 -> %.4f"%(float((1-fj)/(1-fu)),float((1-fj)-(1-fu)),1/(1-fj)))
