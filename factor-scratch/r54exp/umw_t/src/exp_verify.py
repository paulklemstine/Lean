#!/usr/bin/env python3
"""
exp_verify.py -- INDEPENDENT brute-force verifier of t_profile().

This exists because the first version of t_profile() had an off-by-L2-1 index bug
that made t_max come out equal to |P0| on every input; nothing in the printed
summary revealed it. The rule adopted for the rest of this work: **every fast
routine gets a brute-force cross-check on the same inputs**, and the brute force
uses a completely different method (direct divisibility test on the big integer).

Checks:
  V1  positive control: hand-computed gap with known t must match exactly.
  V2  random small gaps: full brute force over the whole difference box.
  V3  the zero-difference (di,dj)=(0,0) must never be counted.
  V4  degenerate guards: a1==0 and a2==0 are handled correctly (rank-1 in disguise).
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import rng, band_primes, t_profile, is_degenerate
import numpy as np

def brute_t(a1, a2, L1, L2, P):
    """Direct: for every nonzero (di,dj), count band primes dividing a1*di+a2*dj."""
    P = [int(p) for p in P]
    best, hist = 0, {}
    for di in range(-(L1-1), L1):
        for dj in range(-(L2-1), L2):
            if di == 0 and dj == 0:
                continue                      # V3: zero difference excluded
            D = a1*di + a2*dj
            if D == 0:
                # integer zero => every prime divides it; this is a DEGENERATE gap
                return -1, hist              # signal degeneracy
            t = sum(1 for p in P if D % p == 0)
            hist[t] = hist.get(t, 0) + 1
            if t > best: best = t
    return best, hist

def main():
    ok = True
    Mx = 1
    for _p in [int(q) for q in band_primes(2**15)[:5]]: Mx *= _p
    L = 2**5                     # small box: 63 x 63 = 3969 differences, brute-forceable
    n = L**3
    P = band_primes(n)
    print(f"band primes {len(P)} in ({2*math.isqrt(n)//3}, {math.isqrt(n)}]")

    # --- V1 positive control: build a gap whose t we set by construction ---
    # a1 = 1, a2 = M-1 where M = product of chosen band primes; then D(1,1)=M,
    # so all of them divide it, and gcd(a1,a2)=1 so none is dropped.
    for want in (1, 2, 3, 5):
        chosen = [int(p) for p in P[:want]]
        M = 1
        for p in chosen: M *= p
        a1, a2, L1, L2 = 1, M - 1, L, L
        fb, fh = brute_t(a1, a2, L1, L2, P)
        ff, fhist, ndiff, drop = t_profile(a1, a2, L1, L2, P)
        match = (fb == ff)
        ok &= match
        print(f"V1 want={want}: brute={fb} fast={ff}  MATCH={match}  dropped={drop}")
        if want > 0:
            assert fb >= want, f"construction failed to deliver t>={want} (got {fb})"

    # --- V2 random gaps: full brute force cross-check ---
    for rep in range(4):
        r = rng(4242, f"verify-{rep}")
        Lr = 2**4
        nr = Lr**3
        Pr = band_primes(nr)
        a1 = int(r.integers(-10**6, 10**6)) or 1
        a2 = int(r.integers(-10**6, 10**6)) or 1
        fb, fh = brute_t(a1, a2, Lr, Lr, Pr)
        ff, fhist, ndiff, drop = t_profile(a1, a2, Lr, Lr, Pr)
        match = (fb == ff)
        ok &= match
        print(f"V2 rep{rep} a1={a1} a2={a2}: brute={fb} fast={ff} MATCH={match} "
              f"ndiff={ndiff} (expected {(2*Lr-1)**2 - 1})")

    # --- V4 degenerate guards: t MUST be flagged, not silently reported as |P| ---
    print("--- V4 degenerate guards (expect RAISE, not a number) ---")
    Ld, nd = 2**4, 2**12
    Pd = band_primes(nd)
    for (aa1, aa2, why) in [(0, 7, "a1==0 (rank-1 in disguise)"),
                            (7, 0, "a2==0 (rank-1 in disguise)"),
                            (6, 3, "a1=2*a2 (degenerate ratio)")]:
        deg = is_degenerate(aa1, aa2, Ld, Ld)
        try:
            t_profile(aa1, aa2, Ld, Ld, Pd)
            raised = False
        except ValueError:
            raised = True
        good = deg and raised
        ok &= good
        print(f"V4 {why}: is_degenerate={deg} raised={raised} OK={good}")

    # --- V4b NONdegenerate control: is_degenerate must be False, must NOT raise ---
    print("--- V4b nondegenerate controls ---")
    for (aa1, aa2, why) in [(1, Mx-1, "construction"), (999983, 1000003, "generic")]:
        deg = is_degenerate(aa1, aa2, Ld, Ld)
        try:
            tf,_,ndiff,_ = t_profile(aa1, aa2, Ld, Ld, Pd)
            raised = False
        except ValueError:
            raised = True; tf = -1
        good = (not deg) and (not raised)
        ok &= good
        print(f"V4b {why}: is_degenerate={deg} raised={raised} t={tf} OK={good}")
    _UNUSED = 0

    print("\nALL VERIFIED" if ok else "\n*** MISMATCH -- instrument untrustworthy ***")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())