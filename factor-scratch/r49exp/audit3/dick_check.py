# Independent re-derivation of exact Psi/rho at NFS operating points.
# TIGHTEST CASE = u=3 (smallest u in the table), where the note claims 13.9x.
# Earned rule: test at the tightest case. A self-test must return NULL where null is correct.
import sys
def rho(u,iters=200):
    if u<=1: return 1.0
    if u<=2: return 1.0-stdlib_log(u)
    v=rho(u-1); return v+ (1.0/u)*stdlib_integral_approx
def stdlib_log(x):
    import math; return math.log(x)
# implement rho numerically via the classic integral
import math
def dickman(u, tol=1e-14):
    # rho(u)=1 for u<1; rho(u)=1-ln u for 1<=u<=2; rho(u)-rho(u-1)=-1/u * int_{u-1}^{u} rho
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    # numeric: integrate du
    N=200000
    h=(u-2.0)/N
    # rho(u) = rho(2) - int_2^u (1/t) * rho(t-1) dt
    val = 1.0-math.log(2.0)
    for i in range(N):
        t=2.0+(i+0.5)*h
        val -= h*(dickman(t-1))/t
    return val

def exact_psi_ratio(X,Y):
    # Psi(X,Y)/X computed by full sieve, no sampling, no floats
    import math
    X=int(X)
    sieve=bytearray([1])*(X+1)
    sieve[0]=0
    # standard: for y-smooth, use recursion on distinct primes
    primes=[]
    s=bytearray([1])*(Y+1)
    for i in range(2,Y+1):
        if s[i]:
            primes.append(i)
            for j in range(i*i,Y+1,i): s[j]=0
    def count(x, k):
        # number of y-smooth <= x using only primes[k:]
        if k==len(primes): return 1
        if x<1: return 0
        tot=0; p=primes[k]
        # sum over powers
        pw=p
        while pw<=x:
            tot += count(x//pw, k+1)
            pw*=p
        return tot+1  # +1 for the "no further factor" 1
    # faster: use divisor-counting style DP
    dp=[0]*(X+1)
    dp[0]=1  # 1 is smooth
    # incremental: count smooth numbers <= X with primes <= Y
    smooth=bytearray(X+1); smooth[0]=1
    # build by multiplying
    # simple approach: mark all products of primes <= Y <= X
    import array
    reach=bytearray(X+1)
    reach[0]=1
    vals=[1]
    for p in primes:
        newvals=[]
        for v in vals:
            t=v
            while t<=X:
                newvals.append(t)
                t*=p
        vals.extend(newvals)
    # too slow for big X; use count via DP over primes (the "ugly numbers" method)
    dp=[0]*(X+1)
    cnt=0
    dp2=bytearray(X+1)
    dp2[0]=1
    # classic: process each prime, for each multiple slot
    # use the standard recurrence array
    a=[0]*(X+1); a[0]=1; a[1]=1
    # simpler: count y-smooth up to X with the "unitary" DP
    res=bytearray(X+1)
    res[0]=1
    for p in primes:
        # convolve
        for t in range(X//p, -1, -1):
            if res[t]:
                v=t
                while v*p<=X:
                    res[v*p]=1
                    v*=p
    return sum(res)

if __name__=="__main__":
    import math
    print("u     exactPsi/X     rho(u)       ratio")
    for u,X in [(3.0,1<<24),(4.0,1<<24),(5.0,1<<24)]:
        B=int(round(math.exp(math.log(X)/u)))
        psi=exact_psi_ratio(X,B)
        r=dickman(u)
        print("%.1f  %.6e  %.6e  %.2fx"%(u,psi/X,r,(psi/X)/r))
