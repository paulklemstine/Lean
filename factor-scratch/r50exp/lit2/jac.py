from fractions import Fraction as F
from functools import lru_cache
import itertools, math

# law of s = v2(p-1) for odd primes: P(s=j) = 2^-j, j>=1  (measured, census)
def ps(j): return F(2)**(-j)

# P(v2(ord_p g) = k) given s = v2(p-1) = j, g uniform mod p (uniform over Z_p^*)
# elements of order 2^k in cyclic 2^j group: phi(2^k)
def pk(j,k):
    if k<0 or k>j: return F(0)
    if k==0: return F(1,2**j)
    return F(2**(k-1), 2**j)

def law_s(maxs=40):
    d={}
    tot=sum(ps(j) for j in range(1,maxs+1))
    for j in range(1,maxs+1): d[j]=ps(j)/tot
    return d
S=law_s()

# ---- 1. uniform g : P(v2 differ) ----
fail=sum(S[j]*S[j2]*sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1))
         for j in S for j2 in S)
print("UNIFORM-g  P(fail)=%.12f  P(success)=%.12f"%(float(fail),float(1-fail)))
print("           20/27 =%.12f   diff=%+.3e"%(20/27,float(1-fail)-20/27))

# ---- 2. g conditioned on Jacobi symbol (g/N) = -1  (computable WITHOUT factoring) ----
# (g/N)=-1 means exactly one of (g/p),(g/q) is -1.
# (g/p)=-1 <=> v2(ord_p g) = s_p   (g is a QNR mod p)
# (g/p)=+1 <=> v2(ord_p g) <= s_p-1
# Conditioned on (g/N)=-1 and (g/p)=-1,(g/q)=+1: the conditional law of v2(ord_q g)
#   given (g/q)=+1 is uniform over k=0..j2-1  (each 2^{-j2}).
def success_jac(sj,sj2):
    # arm A: (g/p)=-1, (g/q)=+1
    if sj >= sj2:                      # v2(ord_p)=sj >= sj2 > v2(ord_q)  -> ALWAYS differ
        return F(1)
    # v2(ord_q g) | (g/q)=+1 uniform on 0..sj2-1 ; fail iff it equals sj
    failA = F(1,sj2) if sj < sj2 else F(0)
    return 1-failA
def succ_cond(sj,sj2):
    # symmetry: conditioning on jacobi=-1, both arms equally likely
    return (success_jac(sj,sj2)+success_jac(sj2,sj))/2

# 2a. conditioned on (g/N) = -1 only (search g until jacobi=-1)
tot=F(0)
for j in S:
    for j2 in S:
        tot += S[j]*S[j2]*succ_cond(j,j2)
print("JACOBI-1   P(success)=%.12f  (vs uniform %.12f)  ratio=%.4fx"%(float(tot),float(1-fail),float(tot/(1-fail))))

# 2b. ALSO require the (g/N)=+1 arm -> just uniform, for contrast
# ---- 3. arm-by-arm breakdown, where does the gain come from ----
print("\njoint table P(success | s_p,s_q) [uniform g]  (rows s_p, cols s_q)")
print("      "+"".join("%9d"%k for k in range(1,9)))
for j in range(1,9):
    row=[]
    for j2 in range(1,9):
        f=sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1))
        row.append(1-f)
    print("s_p=%d "%j+"".join("%9.5f"%v for v in row))
print("\nP(success | s_p,s_q) [Jacobi-conditioned]")
print("      "+"".join("%9d"%k for k in range(1,9)))
for j in range(1,9):
    row=[float(succ_cond(j,j2)) for j2 in range(1,9)]
    print("s_p=%d "%j+"".join("%9.5f"%v for v in row))

# ---- 4. marginal gain: what fraction of the (s_p,s_q) cells improve? ----
imp=[];reg=[]
for j in range(1,30):
    for j2 in range(1,30):
        f=sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1))
        u=1-f; c=float(succ_cond(j,j2))
        imp.append(u*S[j]*S[j2]); reg.append((c-u)*S[j]*S[j2])
print("\ntotal improvement from Jacobi-conditioning: %+.6f"%(sum(reg)))
print("best single cell gain:", max(reg), "at", )
best=max(((float(succ_cond(j,j2))-(1-sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1))))*float(S[j]*S[j2]),j,j2) for j in range(1,30) for j2 in range(1,30))
print("   delta*weight=%+.6f at (s_p,s_q)=%s"%(best[0],best[1:]))
