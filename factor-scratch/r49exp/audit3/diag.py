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
def buchstab(u,N=200000):
    # omega(u) = (1 + int_2^u omega(t-1)/t dt)/u
    if u<2: return 1.0
    h=(u-2.0)/N
    g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+(i-0.5)*h; s=t-1.0
        rs=1.0-math.log(s) if s<=2 else g[min(int((s-2.0)/h),N)]
        g[i]=g[i-1]-h*rs/t
    return (1.0+g[N])/u
print("== Which known function equals the note's Psi/X column? ==")
print("  u    note-Psi/X   exactPsi/X(X=2^24)   Buchstab w(u)   rho(u)")
for u,nv in [(3.0,6.77e-1),(3.5,6.03e-1),(4.0,5.39e-1),(4.5,4.86e-1),(5.0,4.45e-1)]:
    X=1<<24; Y=int(round(math.exp(math.log(X)/u)))
    print("  %.1f  %.4e   %.4e        %.4e     %.4e"%(u,nv,psi(X,Y)/X,buchstab(u),dickman(u)))
print("\n== at what X does Psi/X=6.77e-1 with u=3 (Y=X^(1/3))? ==")
for e in [4,6,8,10,12]:
    X=1<<e; Y=int(round(X**(1/3)))
    print("   X=2^%-2d Y=%3d  Psi/X=%.4e"%(e,Y,psi(X,Y)/X))
print("\n== TRUE trend at the stated X=2^24 (validated sieve) ==")
for u in [3.0,3.5,4.0,4.5,5.0]:
    X=1<<24; Y=int(round(math.exp(math.log(X)/u)))
    print("   u=%.1f  Y=%5d  Psi/X=%.4e  rho=%.4e  Psi/rho=%7.2fx"%(u,Y,psi(X,Y)/X,dickman(u),(psi(X,Y)/X)/dickman(u)))
