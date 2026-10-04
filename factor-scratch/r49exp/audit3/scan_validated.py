import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return [int(p) for p in np.flatnonzero(s)]
_C={}
def P(n):
    if n not in _C: _C[n]=sieve_primes(n)
    return _C[n]
def psi(X,Y):
    sm=np.ones(X+1,dtype=bool); sm[0]=False
    for p in P(X):
        if p>Y: sm[p::p]=False
    return int(sm.sum())
def dickman(u,N=200000):
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    h=(u-2.0)/N
    g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+(i-0.5)*h; s=t-1.0
        rs=1.0-math.log(s) if s<=2 else g[min(int((s-2.0)/h),N)]
        g[i]=g[i-1]-h*rs/t
    return g[N]
print("== A. Psi/X at u=3 (Y=X^(1/3)) vs X -- note claims 6.77e-1 at X=2^24 ==")
print("      X            Y           Psi/X         rho(3)       Psi/rho")
for e in [12,16,20,22,24]:
    X=1<<e; Y=int(round(X**(1.0/3)))
    d=psi(X,Y); px=d/X; r=dickman(3.0)
    print("      2^%-3d  %9d   %.6e   %.4e   %7.2fx"%(e,Y,px,r,px/r))
print("\n== B. full note table reproduced with the VALIDATED sieve at X=2^24 ==")
print("      u       B        Psi/X        rho(u)       Psi/rho    note-Psi/X  note-ratio")
note={3.0:(6.77e-1,13.9),3.5:(6.03e-1,37.2),4.0:(5.39e-1,109.7),4.5:(4.86e-1,353.0),5.0:(4.45e-1,1244.0)}
for u in [3.0,3.5,4.0,4.5,5.0]:
    X=1<<24; B=int(round(math.exp(math.log(X)/u)))
    d=psi(X,B); px=d/X; r=dickman(u)
    npx,nr=note[u]
    print("      %.1f  %7d   %.6e   %.4e   %7.2fx   %.2e  %8.1fx"%(u,B,px,r,px/r,npx,nr))
print("\n== C. what Y at X=2^24 would give the note's Psi/X column? ==")
for tgt in [6.77e-1,4.45e-1]:
    lo,hi=2,1<<24
    # binary search on Y
    for _ in range(40):
        mid=(lo+hi)//2
        if psi(1<<24,mid)/(1<<24) < tgt: lo=mid+1
        else: hi=mid
    u_imp=math.log(2**24)/math.log(lo)
    print("   note Psi/X=%.2e  <->  Y=%d  which is u=%.2f (not the u it is filed under)"%(tgt,lo,u_imp))
