from sympy import primerange, jacobi_symbol
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
assert ord2(3,2)==1 and ord2(7,2)==0 and ord2(7,3)==1 and ord2(13,2)==2

# ---- GROUND TRUTH: exhaustive over g, per (p,q) ----
def measure(p,q):
    n=p*q; U=J=UJ=Jok=0
    for g in range(2,n):
        if math.gcd(g,n)!=1: continue
        U+=1; ok=(ord2(p,g)!=ord2(q,g)); UJ+=ok
        if jacobi_symbol(g,n)==-1: J+=1; Jok+=ok
    return F(UJ,U), F(Jok,J) if J else None

# ---- candidate formulas for the Jacobi-conditioned SUCCESS ----
def cand_A(sp,sq):   # what I wrote: 1 - 2^{-(1+|ds|)}
    return F(1) if sp==sq else 1-F(1,2**(1+abs(sp-sq)))
def cand_B(sp,sq):   # derived: 1 - 1/(2*max)
    return F(1) if sp==sq else 1-F(1,2*max(sp,sq))

print("cell        s_p,s_q | measured |  candA       candB")
rows=[]
PS=[p for p in primerange(3,130)]
for i,p in enumerate(PS):
    for q in PS[i+1:]:
        mu,mj=measure(p,q)
        if mj is None or mj.denominator>2000: continue
        sp,sq=v2(p-1),v2(q-1)
        rows.append((sp,sq,mu,mj))
        if (sp,sq) in [(1,1),(1,2),(1,3),(1,4),(2,3),(2,4),(3,4),(2,5),(1,5),(3,5)] and sp<sq:
            print("p=%3d q=%3d  (%d,%d) | %.5f  | %.5f  %.5f"%(p,q,sp,sq,float(mj),float(cand_A(sp,sq)),float(cand_B(sp,sq))))
eA=max(abs(r[3]-cand_A(r[0],r[1])) for r in rows)
eB=max(abs(r[3]-cand_B(r[0],r[1])) for r in rows)
print("\nrows=%d  max|candA - measured| = %.6f"%((eA is not None,len(rows)),float(eA)))
print("rows=%d  max|candB - measured| = %.6f"%((len(rows)),float(eB)))

# ---- now aggregate BOTH with the theoretical law P(s=j)=2^-j ----
def law(M=300):
    tot=sum(F(2)**(-x) for x in range(1,M+1))
    return {j:F(2)**(-j)/tot for j in range(1,M+1)}
S=law()
def pk(j,k):
    if k>j: return F(0)
    return F(1,2**j) if k==0 else F(2**(k-1),2**j)
Su=sum(S[j]*S[j2]*(F(1)-sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1))) for j in S for j2 in S)
SjA=sum(S[j]*S[j2]*cand_A(j,j2) for j in S for j2 in S)
SjB=sum(S[j]*S[j2]*cand_B(j,j2) for j in S for j2 in S)
print("\nAGGREGATE with theoretical law P(s)=2^-j:")
print("  uniform          = %.14f   (20/27=%.14f, d=%+.2e)"%(float(Su),20/27,float(Su)-20/27))
print("  Jacobi candA     = %.14f   (=8/9? %s)"%(float(SjA), abs(float(SjA)-8/9)<1e-12))
print("  Jacobi candB     = %.14f"%float(SjB))
print("  candB ratio to 20/27 = %.6fx"%(float(SjB)/float(Su)))
print("\nFALLBACK (law from measured rows, small-prime pool):")
from collections import Counter
cnt=Counter((r[0],r[1]) for r in rows)
w=sum(cnt.values()); 
u=sum(cnt[(a,bb)]/w*(1-sum(pk(a,k)*pk(bb,k) for k in range(0,max(a,bb)+1))) for (a,bb) in cnt)
b=sum(cnt[(a,bb)]/w*cand_B(a,bb) for (a,bb) in cnt)
print("  uniform=%.5f  jacobiB=%.5f  ratio=%.4fx"%(u,b,b/u))
