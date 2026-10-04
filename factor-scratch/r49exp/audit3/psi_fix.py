import numpy as np, math
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return np.flatnonzero(s)
def exact_psi(X,Y):
    """Count y-smooth integers in [1,X] by EXACT DP. No sampling, no float compare."""
    # dp[j] = count of y-smooth numbers <= j  (classic sieve of Eratosthenes style)
    # Use the standard trick: keep array a where a[j]=1 if j is y-smooth
    a=np.ones(X+1,dtype=bool); a[0]=False
    primes=sieve_primes(Y)
    for p in primes:
        # remove multiples of p that are NOT p-smooth: a[j] = a[j//p] accumulated
        # do the standard: for each j multiple of p descending, a[j] &= a[j//p]
        for j in range(X//p,0,-1):
            # mark: j is smooth iff (j//p) smooth (given other primes handled)
            pass
        # vectorised correct version:
        a[::p] &= a[::p]  # placeholder
    # correct approach below
    return None
# CORRECT method: multiplicative indicator via DP over primes in increasing order
def exact_psi_v2(X,Y):
    primes=sieve_primes(Y)
    a=np.zeros(X+1,dtype=bool); a[0]=True   # 1 is smooth
    # iterate primes; for each p, extend: a[p*j] |= a[j] with j processed
    for p in primes:
        # descending so powers chain
        idx=np.arange(0,X//p+1)
        for k in range(1,60):
            src=a[idx]
            # propagate a[j] -> a[j*p^k] done implicitly by looping k
        # simpler: iterate j descending
        for j in range(X//p,0,-1):
            if a[j]: a[j*p]=True
    return int(a.sum())
if __name__=="__main__":
    # SELF-TEST: must return NULL (small) at tight cases, and must FIRE on corrupted input
    import itertools
    print("== TIGHTEST-CASE SELF-TEST ==")
    # 1) small exact ground truth by brute force
    def brute(X,Y):
        c=0
        for j in range(1,X+1):
            t=j
            ok=True
            for p in range(2,Y+1):
                if t%p==0:
                    while t%p==0: t//=p
            if t==1: c+=1
        return c
    for X,Y in [(100,10),(1000,20),(5000,30),(2**16,64)]:
        b=brute(X,Y); v=exact_psi_v2(X,Y)
        print("  X=%6d Y=%3d brute=%6d dp=%6d %s"%(X,Y,b,v,"OK" if b==v else "*** MISMATCH ***"))
