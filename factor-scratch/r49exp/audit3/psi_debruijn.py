import sys
from functools import lru_cache
from bisect import bisect_right
sys.setrecursionlimit(100000)
# primes up to 4096 (largest B used) -- generate
def gen_primes(n):
    s=[True]*(n+1); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]:
            for j in range(i*i,n+1,i): s[j]=False
    return [i for i in range(2,n+1) if s[i]]
PR=gen_primes(60000)
calls=[0]
@lru_cache(maxsize=None)
def PSI(x, y):
    """EXACT Psi(x,y) = #{n <= x : P+(n) <= y}.  Standard recursive split."""
    calls[0]+=1
    if x<1: return 0
    if y<2: return 0
    k=bisect_right(PR,y)          # number of primes <= y
    if k==0: return 0
    if y>=x: return 1             # only n=1
    pk=PR[k-1]
    if pk*pk>x: return k          # x < y^2 -> only 1 and the primes <= y
    return PSI(x, PR[k-2]) + PSI(x//pk, pk)
if __name__=="__main__":
    import math
    print("== VALIDATE the recursive Psi against the brute-force sieve at SMALL X ==")
    import numpy as np
    def sieve(X,Y):
        sm=np.ones(X+1,dtype=bool); sm[0]=False
        s=np.ones(X+1,dtype=bool); s[0]=s[1]=False
        for i in range(2,int(X**0.5)+1):
            if s[i]: s[i*i::i]=False
        for p in np.flatnonzero(s):
            if p>Y: sm[p::p]=False
        return int(sm.sum())
    ok=True
    for X,Y in [(1000,20),(10000,50),(65536,64),(2**18,128)]:
        a=PSI(X,Y); b=sieve(X,Y); good=(a==b); ok&=good
        print("   X=%7d Y=%4d recursive=%7d sieve=%7d %s"%(X,Y,a,b,"OK" if good else "*** MISMATCH ***"))
    print("   ->","PASS" if ok else "FAIL")
    print("\n== NEGATIVE CONTROL (must FIRE) ==")
    t=sieve(1000,20); print("   truth Psi(1000,20)=%d ; Y=19 -> %d fires=%s"%(t,PSI(1000,19),PSI(1000,19)!=t))
    print("\n== THE DECISIVE TEST: note's Psi/X vs X, at u=3 (Y=X^(1/3)) ==")
    print("   X                Y        Psi/X        rho(3)     Psi/rho")
    for e in [24,26,28,30,32,34,36]:
        X=1<<e; Y=int(round(X**(1.0/3)))
        d=PSI(X,Y); px=d/X
        from consist import dickman
        print("   2^%-3d  %8d  %.6e  %.4e  %8.1fx"%(e,Y,px,dickman(3.0),px/dickman(3.0)))
