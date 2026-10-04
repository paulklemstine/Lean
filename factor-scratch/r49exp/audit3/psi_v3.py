import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return np.flatnonzero(s)
def exact_psi(X,Y):
    """EXACT count of Y-smooth integers in [1,X]. No sampling, no float comparison."""
    a=np.zeros(X+1,dtype=bool); a[1]=True      # 1 is smooth  <-- the bug was a[0]
    for p in sieve_primes(Y):
        for j in range(X//p,0,-1):
            if a[j]: a[j*p]=True
    return int(a.sum())
def brute(X,Y):
    c=0
    for j in range(1,X+1):
        t=j; ok=True
        while t>1:
            f=False
            for p in range(2,Y+1):
                if t%p==0:
                    while t%p==0: t//=p
                    f=True; break
            if not f: ok=False; break
        if ok: c+=1
    return c
def dickman(u,N=200000):
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    h=(u-2.0)/N
    g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+(i-0.5)*h; s=t-1.0
        if s<=2: rs=1.0-math.log(s)
        else:
            j=min(int((s-2.0)/h),N); rs=g[j]
        g[i]=g[i-1]-h*rs/t
    return g[N]

if __name__=="__main__":
    print("== SELF-TEST 1: dp vs brute force (tightest small cases) ==")
    ok=True
    for X,Y in [(100,10),(1000,20),(5000,30),(2**16,64),(2**20,128)]:
        b=brute(X,Y); v=exact_psi(X,Y)
        good = (b==v); ok &= good
        print("   X=%8d Y=%4d brute=%7d dp=%7d %s"%(X,Y,b,v,"OK" if good else "*** MISMATCH ***"))
    print("   ->",("PASS" if ok else "FAIL"))
    print("\n== SELF-TEST 2: NEGATIVE CONTROL - corrupt Y and confirm it FIRES ==")
    X=1000;Y=20
    b=brute(X,Y); v=exact_psi(X,Y)
    print("   truth           Psi(1000,20)=%d"%b)
    print("   corrupted (Y=19) Psi(1000,19)=%d  differs? %s"%(exact_psi(X,19), exact_psi(X,19)!=b))
    print("   corrupted (Y=21) Psi(1000,21)=%d  differs? %s"%(exact_psi(X,21), exact_psi(X,21)!=b))
    print("   -> checker fires on corruption:", exact_psi(X,19)!=b and exact_psi(X,21)!=b)
    print("\n== SELF-TEST 3: Psi/rho at NFS operating points, X=2^24 (note's setup) ==")
    X=1<<24
    print("   u      B       exactPsi/X      rho(u)       Psi/rho")
    for u in [3.0,3.5,4.0,4.5,5.0]:
        B=int(round(math.exp(math.log(X)/u)))
        psi=exact_psi(X,B); r=dickman(u)
        print("   %.1f  %7d   %.6e   %.6e   %.1fx"%(u,B,psi/X,r,(psi/X)/r))
