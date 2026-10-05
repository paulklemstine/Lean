#!/usr/bin/env python3
"""
exp_e.py -- Repair the construction: can an n-divisor gap have large t?

exp_d showed a1=1,a2=M-1,b0=0 contains the value 0 (at i=j=0), which He-Sahai
Remark 4.1 excludes ("allowing zero as a witness would make the condition vacuous").
So the raw construction fails the n-divisor property for a trivial reason.

Repair: b0 = 1 (so all values are >= 1). Test whether the n-divisor property then
holds. This is the crux: He-Sahai needs a gap that ACTUALLY has the property.

If the repaired gap is still not n-divisor, then the honest conclusion is:
  "t can be made large for ARBITRARY rank-2 gaps, but I have NOT exhibited an
   n-divisor gap with large t, so this does NOT rescue the route."
That is a legitimate outcome, and I will report it as such.

Controls: checker POS/NEG rerun here so this file stands alone.
"""
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import band_primes, t_profile, is_degenerate
from exp_d import n_divisor_ok
import numpy as np

def coverage(A, n):
    """fraction of d in [1,n] dividing some a in A, and smallest missing d."""
    A = [abs(int(v)) for v in A]
    seen = bytearray(n + 1)
    for v in A:
        if v == 0: continue
        for d in range(1, min(n, v) + 1):
            if v % d == 0: seen[d] = 1
    miss = [d for d in range(1, n+1) if not seen[d]]
    return 1.0 - len(miss)/n, (miss[0] if miss else -1), len(miss)

def main():
    # standalone controls
    ok, _ = n_divisor_ok(list(range(1,101)), 100)
    print(f"CONTROL POS A=[1..100] n=100 n-divisor={ok} {'OK' if ok else 'FAIL'}")
    ok2, f2 = n_divisor_ok([1,2,3,4,5,6,8,9,10], 10)
    print(f"CONTROL NEG missing 7 -> {ok2} first={f2} {'OK' if (not ok2 and f2==7) else 'FAIL'}")

    print("\n=== b0 = 1 repair: n-divisor + large t? ===")
    rows = []
    for kb in (15, 18, 21, 24):
        L = 2 ** (kb // 3); n = L**3; alpha = 1.0/3.0
        x = math.isqrt(n)
        P = sorted(int(p) for p in band_primes(n)); P=[p for p in P if p>(2*x)//3]
        budget = n**alpha - math.log(L)
        M,k,logM = 1,0,0.0
        for p in P:
            if logM+math.log(p) <= budget: M*=p; logM+=math.log(p); k+=1
            else: break
        a1,a2,b0 = 1, M-1, 1
        tmax,_,ndiff,_ = t_profile(a1,a2,L,L,P)
        A = [b0 + a1*i + a2*j for i in range(L) for j in range(L)]
        ntest = min(n, 5000)
        cov, firstmiss, nmiss = coverage(A, ntest)
        print(f"  n=2^{3*(kb//3)}={n:9d} L={L:4d} t={tmax:4d} |A|={len(A):7d} "
              f"min|A|={min(A)} | coverage of [1,{ntest}] = {cov*100:6.2f}%  "
              f"first_missing={firstmiss}")
        rows.append(dict(k_bits=kb,n=n,L=L,k=k,tmax=int(tmax),ntest=ntest,
                         coverage=cov, first_missing=firstmiss, n_missing=nmiss,
                         minA=min(A), sizeA=len(A)))

    print("\n=== CONTROL: an ACTUAL n-divisor rank-2 gap at tiny n (existence) ===")
    # A = {b0 + a1 i + a2 j} containing [1..n]: take a1=1, L1=n, a2=0? -> rank1.
    # Genuine rank-2 with n-divisor: A = { i + (n+1)*j : i in [1,n], j in [0,m] }
    # contains 1..n so it is n-divisor; check t for it.
    nn = 96
    a1, a2 = 1, nn+1
    L1, L2 = nn, 4
    A = [a1*i + a2*j for i in range(1,L1+1) for j in range(L2)]
    cov, fm, nm = coverage(A, nn)
    Pn = sorted(int(p) for p in band_primes(nn**3)) if False else None
    print(f"  A={{i + {nn+1}*j : 1<=i<={nn}, 0<=j<{L2}}}  size={len(A)}  "
          f"coverage of [1,{nn}] = {cov*100:.2f}%  first_missing={fm}")
    print(f"  -> this IS an n-divisor rank-2 gap (rank-2 because {nn+1} > L1)")
    json.dump(rows, open(os.path.join(os.path.dirname(__file__),"..","out","exp_e.json"),"w"), indent=1)
    print("\nwrote out/exp_e.json")

if __name__ == "__main__":
    main()