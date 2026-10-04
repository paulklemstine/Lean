import math
def dickman(u,N=400000):
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    h=(u-2.0)/N
    val=1.0-math.log(2.0)
    # iterative: rho(t-1) at increasing t, do it in one sweep with its own table
    tbl={}
    def R(t):
        if t<=0: return 1.0
        if t<=2: return 1.0-math.log(t)
        return None
    return None
# Instead: integrate rho(u) = rho(2) - int_2^u rho(t-1)/t dt using a fine cumulative table
def rho_table(u_max,N=2000000):
    h=(u_max-2.0)/N
    # build rho on grid [2, u_max]
    grid=[0.0]*(N+1)
    grid[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+i*h
        grid[i]=grid[i-1]-h*dick_lookup(grid,t-1.0,h)
    return grid,h
def dick_lookup(grid,t,h):
    if t<=2: return 1.0-math.log(max(t,1e-300))
    idx=(t-2.0)/h
    i=int(idx)
    if i>=len(grid): i=len(grid)-1
    return grid[i]
def exact_psi(X,Y):
    # y-smooth count via DP over primes (fast: O(X * pi(Y)) too slow) -> use sieve of smooth numbers
    import numpy as np
    a=np.zeros(X+1,dtype=bool); a[0]=True
    primes=sieve_primes(Y)
    for p in primes:
        # mark multiples of powers
        pw=p
        while pw<=X:
            a[pw::pw] |= a[0:len(a[pw::pw])*pw:pw][::pw] if False else a[pw::pw]
            # simpler: in-place: for t descending
            for t in range(X//p,-1,-1):
                if a[t]: a[t*p]=True
            pw*=p
    return int(a.sum())
def sieve_primes(n):
    s=[True]*(n+1); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]:
            for j in range(i*i,n+1,i): s[j]=False
    return [i for i in range(2,n+1) if s[i]]
if __name__=="__main__":
    import numpy as np
    X=1<<24
    print("u      B       exactPsi/X     rho(u)       Psi/rho")
    for u in [3.0,3.5,4.0,4.5,5.0]:
        B=int(round(math.exp(math.log(X)/u)))
        # rho via direct ODE integration using scipy-free: use the log-substitution trick
        # rho(u) computed by high-accuracy quadrature
        def rho(u,N=2000000):
            if u<1: return 1.0
            if u<=2: return 1.0-math.log(u)
            # integrate backwards using fine step and nested lookup on a coarse+fine scheme
            h=(u-2.0)/N
            g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
            for i in range(1,N+1):
                t=2.0+(i-0.5)*h
                s=t-1.0
                if s<=2: rs=1.0-math.log(s)
                else:
                    j=int((s-2.0)/h)
                    if j<0: j=0
                    if j>N: j=N
                    rs=g[j]
                g[i]=g[i-1]-h*rs/t
            return g[N]
        r=rho(u)
        psi=exact_psi(X,B)
        print("%.1f  %7d  %.6e  %.6e  %.1fx"%(u,B,psi/X,r,(psi/X)/r))
