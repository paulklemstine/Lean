import random,math
from sympy import primerange, jacobi_symbol
from fractions import Fraction as F
def v2(x):
    k=0
    while x%2==0: x//=2;k+=1
    return k
def ord2(p,g):
    s=v2(p-1)
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)!=1: return s-i+1
    return 0
def S_jac(sp,sq):
    if sp==sq: return F(1)
    return F(1)-F(1,2**(1+abs(sp-sq)))
def pk(j,k):
    if k>j: return F(0)
    return F(1,2**j) if k==0 else F(2**(k-1),2**j)
def S_uni(sp,sq):
    return F(1)-sum(pk(sp,k)*pk(sq,k) for k in range(0,max(sp,sq)+1))
def law(maxs=200):
    tot=sum(F(2)**(-x) for x in range(1,maxs+1))
    return {j:F(2)**(-j)/tot for j in range(1,maxs+1)}
S=law()
fu=sum(S[j]*S[j2]*S_uni(j,j2) for j in S for j2 in S)
fj=sum(S[j]*S[j2]*S_jac(j,j2) for j in S for j2 in S)
print("EXACT uniform success      = %.14f"%float(fu))
print("20/27                     = %.14f   diff %+.3e"%(20/27,float(fu)-20/27))
print("EXACT Jacobi-conditioned  = %.14f"%float(fj))
print("RATIO  = %.6fx   abs gain %+.6f"%(float(fj/fu),float(fj-fu)))
print("attempts: %.4f -> %.4f  (saving %.1f%%)"%(1/float(fu),1/float(fj),100*(1-float(fj)*float(fu))))
# is it a nice rational?
print("jacobi success as fraction (float-decomp): see below")

random.seed(7)
pool=list(primerange(3,2000000))
U=UJ=UJok=J=Jok=0
for _ in range(60000):
    p=random.choice(pool);q=random.choice(pool)
    if p==q: continue
    n=p*q; g=random.randrange(2,n)
    if math.gcd(g,n)!=1: continue
    ok=(ord2(p,g)!=ord2(q,g))
    U+=1; UJ+=ok
    if jacobi_symbol(g,n)==-1: J+=1; Jok+=ok
print("\nMC uniform  = %d/%d = %.5f   [exact %.5f]  z=%+.2f"%(UJ,U,UJ/U,float(fu),(UJ/U-float(fu))/math.sqrt(float(fu)*(1-float(fu))/U)))
print("MC jacobi   = %d/%d = %.5f   [exact %.5f]  z=%+.2f"%(Jok,J,Jok/J,float(fj),(Jok/J-float(fj))/math.sqrt(float(fj)*(1-float(fj))/J)))
print("MC ratio    = %.5f"%((Jok/J)/(UJ/U)))
