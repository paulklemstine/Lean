import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return list(np.flatnonzero(s))
def exact_psi(X,Y):
    """EXACT count of Y-smooth integers in [1,X]. Full sieve, no sampling, no float compare.
       For each prime p, for each k>=1 with p^k<=X:  a[p^k :: p^k] |= a[::p^k]
       Source indices are always strictly below destination indices => no aliasing; the k-loop
       closes under all powers. (Descending-order DP silently fails to chain powers.)"""
    a=np.zeros(X+1,dtype=bool); a[0]=True   # index 0 = multiplicative identity (1), not counted
    for p in sieve_primes(Y):
        pk=p
        while pk<=X:
            m=len(a[pk::pk])             # dest: pk,2pk,...,m*pk
            a[pk::pk] |= a[::pk][:m]      # src : 0,pk,...,(m-1)pk (truncate; src idx < dest idx)
            pk*=p
    return int(a[1:].sum())            # exclude the identity slot
def brute(X,Y):
    P=sieve_primes(Y)
    c=0
    for j in range(1,X+1):
        t=j
        for p in P:
            while t%p==0: t//=p
        if t==1: c+=1
    return c
def dickman(u,N=200000):
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    h=(u-2.0)/N
    g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+(i-0.5)*h; s=t-1.0
        rs = 1.0-math.log(s) if s<=2 else g[min(int((s-2.0)/h),N)]
        g[i]=g[i-1]-h*rs/t
    return g[N]
if __name__=="__main__":
    print("== SELF-TEST 1: dp vs INDEPENDENT brute force ==")
    ok=True
    for X,Y in [(100,10),(1000,20),(5000,30),(2**16,64),(2**20,128)]:
        b=brute(X,Y); v=exact_psi(X,Y); good=(b==v); ok&=good
        print("   X=%8d Y=%4d brute=%7d dp=%7d %s"%(X,Y,b,v,"OK" if good else "*** MISMATCH ***"))
    print("   ->","PASS" if ok else "FAIL")
    print("\n== SELF-TEST 2: NEGATIVE CONTROL (must FIRE on corrupted input) ==")
    X,Y=1000,20; truth=brute(X,Y)
    print("   brute truth Psi(1000,20) =",truth)
    for badY in [19,21,1,2]:
        v=exact_psi(X,badY); print("   corrupted Y=%-3d -> Psi=%-6d differs from truth: %s"%(badY,v,v!=truth))
    print("\n== SELF-TEST 3: rho spot values vs the published Dickman table ==")
    for u,tv in [(2.0,0.3069),(3.0,0.0486),(4.0,0.00491),(5.0,0.000355)]:
        r=dickman(u); print("   rho(%.1f)=%.6g  table=%.6g  relerr=%.2f%%"%(u,r,tv,100*abs(r-tv)/tv))
    print("\n== SELF-TEST 4: Psi/rho at NFS operating points, X=2^24 ==")
    X=1<<24
    print("   u      B       exactPsi/X      rho(u)       Psi/rho")
    for u in [3.0,3.5,4.0,4.5,5.0]:
        B=int(round(math.exp(math.log(X)/u)))
        psi=exact_psi(X,B); r=dickman(u)
        print("   %.1f  %7d   %.6e   %.6e   %.1fx"%(u,B,psi/X,r,(psi/X)/r))
