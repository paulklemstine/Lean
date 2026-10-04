import sys, math
from functools import lru_cache
from bisect import bisect_right
sys.setrecursionlimit(10000)
def gen_primes(n):
    s=[True]*(n+1); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]:
            for j in range(i*i,n+1,i): s[j]=False
    return [i for i in range(2,n+1) if s[i]]
PR=gen_primes(200000)
@lru_cache(maxsize=None)
def PSI(x,y):
    if x<1 or y<2: return 0
    k=bisect_right(PR,y)
    if k==0: return 0
    if y>=x: return 1
    pk=PR[k-1]
    if pk*pk>x: return k          # only 1 plus the k primes <= y
    return PSI(x, PR[k-2]) + PSI(x//pk, pk)
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
if __name__=="__main__":
    import numpy as np
    def sieve(X,Y):
        sm=np.ones(X+1,dtype=bool); sm[0]=False
        s=np.ones(X+1,dtype=bool); s[0]=s[1]=False
        for i in range(2,int(X**0.5)+1):
            if s[i]: s[i*i::i]=False
        for p in np.flatnonzero(s):
            if p>Y: sm[p::p]=False
        return int(sm.sum())
    print("== VALIDATE recursive Psi vs sieve (independent) ==")
    ok=True
    for X,Y in [(1000,20),(10000,50),(65536,64),(2**18,128),(2**20,256)]:
        a=PSI(X,Y); b=sieve(X,Y); g=(a==b); ok&=g
        print("   X=%8d Y=%4d rec=%8d sieve=%8d %s"%(X,Y,a,b,"OK" if g else "*** MISMATCH ***"))
    print("   ->","PASS" if ok else "FAIL")
    print("\n== NEGATIVE CONTROL ==")
    t=sieve(10000,50)
    print("   truth Psi(10000,50)=%d ; Y=49->%d fires=%s ; Y=51->%d fires=%s"%(t,PSI(10000,49),PSI(10000,49)!=t,PSI(10000,51),PSI(10000,51)!=t))
    print("\n== DECISIVE: Psi/X and Psi/rho at u=3 as X grows ==")
    print("   X          Y          Psi/X       rho(3)      Psi/rho")
    for e in [24,28,32,36,40,44,48]:
        X=1<<e; Y=int(round(X**(1.0/3)))
        d=PSI(X,Y); px=d/X
        print("   2^%-3d  %9d  %.6e  %.4e  %8.1fx"%(e,Y,px,dickman(3.0),px/dickman(3.0)))
