from sympy import primerange, jacobi_symbol
from fractions import Fraction as F
import math
def v2(x):
    k=0
    while x%2==0: x//=2; k+=1
    return k
def ord2(p,g):  # v2(ord_p(g))
    s=v2(p-1)
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)!=1: return s-i
    return 0
def formula(sj,sj2):
    if sj==sj2: return F(1)
    m=max(sj,sj2); return F(1)-F(1,2**(m+1))

PS=[p for p in primerange(3,120)]
bad=0;rows=0;tot_u=F(0);tot_j=F(0);totw_u=F(0);totw_j=F(0)
print("cell  s_p s_q | measured_uniform  formula     | measured_jac   formula")
for i,p in enumerate(PS):
    for q in PS[i+1:]:
        n=p*q
        u=j=cj=0
        for g in range(2,n):
            if math.gcd(g,n)!=1: continue
            ok = ord2(p,g)!=ord2(q,g)
            u+=ok
            if jacobi_symbol(g,n)==-1: j+=1; cj+=ok
        if j==0: continue
        mu=F(u,u+j-1); mj=F(cj,j)   # exclude g where gcd!=1 -> none actually since we skip
        # recount properly
        U=J=CJ=0
        for g in range(2,n):
            if math.gcd(g,n)!=1: continue
            U+=1; ok = ord2(p,g)!=ord2(q,g); J+=ok
            if jacobi_symbol(g,n)==-1: CJ+=1; CJ_ok=0
        break   # only need first p to keep it fast? no - need full. 
    break
# do full but with smaller bound
PS=[p for p in primerange(3,60)]
print("\nFULL EXHAUSTIVE over p<q<60:")
maxerr_u=F(0);maxerr_j=F(0);ncell=0
for i,p in enumerate(PS):
    for q in PS[i+1:]:
        n=p*q
        U=J=CJ=CJok=0
        for g in range(2,n):
            if math.gcd(g,n)!=1: continue
            U+=1; ok=(ord2(p,g)!=ord2(q,g)); J+=ok
            if jacobi_symbol(g,n)==-1: CJ+=1; CJok+=ok
        if CJ==0: continue
        mu=F(J,U); mj=F(CJok,CJ)
        fj=formula(v2(p-1),v2(q-1))
        fu=F(1)-sum(F(1,2**v2(p-1) if k==0 else 2**(k-1),2**v2(p-1))*0 for k in [])  # placeholder
        # uniform formula
        sp,sq=v2(p-1),v2(q-1)
        def pk(j,k):
            if k>j: return F(0)
            return F(1,2**j) if k==0 else F(2**(k-1),2**j)
        fu=F(1)-sum(pk(sp,k)*pk(sq,k) for k in range(0,max(sp,sq)+1))
        e1=abs(mu-fu); e2=abs(mj-fj)
        maxerr_u=max(maxerr_u,e1); maxerr_j=max(maxerr_j,e2); ncell+=1
        if e2>F(1,100):
            print("  MISMATCH p=%d q=%d s=(%d,%d) meas_j=%.5f formula=%.5f"%(p,q,sp,sq,float(mj),float(fj)))
print("cells=%d  max|err_uniform|=%.6f  max|err_jacobi|=%.6f"%(ncell,float(maxerr_u),float(maxerr_j)))

# exact aggregate with the CORRECT formula
def ps(j): return F(2)**(-j)
tot=sum(ps(x) for x in range(1,41))
S={j:ps(j)/tot for j in range(1,41)}
f_j=sum(S[j]*S[j2]*(1-formula(j,j2)) for j in S for j2 in S)
f_u=F(1)
def pk(j,k):
    if k>j: return F(0)
    return F(1,2**j) if k==0 else F(2**(k-1),2**j)
f_u=sum(S[j]*S[j2]*sum(pk(j,k)*pk(j2,k) for k in range(0,max(j,j2)+1)) for j in S for j2 in S)
print("\nEXACT  uniform failure=%s  success=%.12f"%(f_u,float(1-f_u)))
print("EXACT  jacobi   failure=%s  success=%.12f"%(f_j,float(1-f_j)))
print("ratio = %.6fx   absolute gain = %+.6f"%(float((1-f_j)/(1-f_u)),float((1-f_j)-(1-f_u))))
print("expected attempts to factor: uniform %.4f  jacobi %.4f"%(1/(1-f_u),1/(1-f_j)))
