import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return [int(p) for p in np.flatnonzero(s)]
_PC={}
def primes_upto(n):
    if n not in _PC: _PC[n]=sieve_primes(n)
    return _PC[n]
def psi(X,Y):
    smooth=np.ones(X+1,dtype=bool); smooth[0]=False
    for p in primes_upto(X):
        if p>Y: smooth[p::p]=False
    return int(smooth.sum())
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
print("== A. note's u=3 row: which X reproduces their claimed 6.77e-1 ? (Y=X^(1/3) each) ==")
for e in [16,20,24,28,32]:
    X=1<<e; Y=int(round(X**(1.0/3)))
    print("   X=2^%-3d Y=%-7d Psi/X=%.6e   ratio to rho(3)=%.2fx"%(e,Y,psi(X,Y)/X,(psi(X,Y)/X)/dickman(3.0)))
print("\n== B. Psi/rho vs X at FIXED u=3 (Y=X^(1/3)) ==")
for e in [16,20,24,28,32,36]:
    X=1<<e; Y=int(round(X**(1.0/3)))
    print("   X=2^%-3d  Y=%-8d  Psi/X=%.4e  rho(3)=%.4e  Psi/rho=%.2fx"%(e,Y,psi(X,Y)/X,dickman(3.0),(psi(X,Y)/X)/dickman(3.0)))
print("\n== C. does ANY X give 13.9x at u=3? ==")
for e in [12,14,16,18,20,22,24]:
    X=1<<e; Y=int(round(X**(1.0/3)))
    r=(psi(X,Y)/X)/dickman(3.0)
    print("   X=2^%-3d Psi/rho=%6.2fx %s"%(e,r,"<== 13.9x here" if 12.5<r<15.5 else ""))
