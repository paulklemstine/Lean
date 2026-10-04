import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return np.flatnonzero(s)
def exact_psi(X,Y):
    """EXACT count of Y-smooth integers in [1,X].
       Method (obviously correct by construction): j is Y-smooth iff NO prime > Y divides j.
       So start all-True and cross out multiples of every prime p in (Y, X]. Full sieve, no sampling."""
    smooth=np.ones(X+1,dtype=bool); smooth[0]=False
    for p in sieve_primes(X):
        p=int(p)
        if p>Y:
            smooth[p::p]=False
    return int(smooth.sum())
def brute(X,Y):
    P=[int(p) for p in sieve_primes(Y)]
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
    print("== SELF-TEST 1: sieve vs INDEPENDENT brute force ==")
    ok=True
    for X,Y in [(100,10),(1000,20),(5000,30),(2**16,64),(2**18,128)]:
        b=brute(X,Y); v=exact_psi(X,Y); good=(b==v); ok&=good
        print("   X=%8d Y=%4d brute=%7d sieve=%7d %s"%(X,Y,b,v,"OK" if good else "*** MISMATCH ***"))
    print("   ->","PASS" if ok else "FAIL")
    print("\n== SELF-TEST 2: NEGATIVE CONTROL (must FIRE on corrupted input) ==")
    X,Y=1000,20; truth=brute(X,Y); print("   truth Psi(1000,20)=",truth)
    for bad in [19,21,1,2,3]:
        v=exact_psi(X,bad); print("   corrupt Y=%-3d -> Psi=%-6d fires: %s"%(bad,v,v!=truth))
    print("\n== SELF-TEST 3: rho vs published Dickman table ==")
    for u,tv in [(2.0,0.3069),(3.0,0.0486),(4.0,0.00491),(5.0,0.000355)]:
        r=dickman(u); print("   rho(%.1f)=%.6g table=%.6g relerr=%.2f%%"%(u,r,tv,100*abs(r-tv)/tv))
    print("\n== SELF-TEST 4: exact Psi/rho at NFS operating points, X=2^24 ==")
    X=1<<24
    print("   u      B       exactPsi/X      rho(u)        Psi/rho")
    for u in [3.0,3.5,4.0,4.5,5.0]:
        B=int(round(math.exp(math.log(X)/u)))
        psi=exact_psi(X,B); r=dickman(u)
        print("   %.1f  %7d   %.6e   %.6e   %8.1fx"%(u,B,psi/X,r,(psi/X)/r))
