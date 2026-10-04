import numpy as np, math
def primes_upto(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return [int(p) for p in np.flatnonzero(s)]
def psi(X,Y):
    sm=np.ones(X+1,dtype=bool); sm[0]=False
    for p in primes_upto(X):
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
print("== gap across the u in [5,8] regime the OLD 8.46x claimed (X=2^24) ==")
for u in [5.0,6.0,7.0,8.0]:
    X=1<<24; Y=int(round(math.exp(math.log(X)/u)))
    px=psi(X,Y)/X; r=dickman(u)
    print("   u=%.0f  Y=%5d  Psi/X=%.4e  rho=%.4e  Psi/rho=%7.2fx"%(u,Y,px,r,px/r))
print("\n   note: the gap GROWS with u at fixed X (small B converges slower).")
print("   so '8.46x at u in [5,8]' is not crazy in magnitude, but the paper's")
print("   replacement (13.9x at u=3, 1244x at u=5) is ~10x / ~200x too high.")
