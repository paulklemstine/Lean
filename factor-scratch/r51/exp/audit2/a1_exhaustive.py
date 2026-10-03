#!/usr/bin/env python3
"""A1: exhaustive verification of the CORRECTED NFS valuation law in #523.

Claim (corrected, paper section 4.3):
  P(p^k | a^2-b^3)/p^k = (2 - 1/p) + [ p^(k - ceil(k/2) - ceil(k/3)) - 1 ]

Counting method (EXACT, no exclusions):
  For each a in [0,p^k): s = a^2 mod p^k.  Build a multiset counter of s.
  Then count = sum over b in [0,p^k) of counter[b^3 mod p^k].
  This counts ALL (a,b) pairs including a^2 = b^3 = 0 and including
  every partial-cancellation case.  It is O(p^k), exact, no sampling.

NEGATIVE CONTROL: run the identical counter on a uniform model where the
  b-side is replaced by an independent uniform residue.  The null MUST
  return ratio = 1.0 to high precision.  If the null does not return 1.0
  the harness is broken.
"""
import sys, math
from collections import Counter

def count_pairs(p, k):
    M = p ** k
    ctr = Counter()
    for a in range(M):
        ctr[(a * a) % M] += 1
    tot = 0
    for b in range(M):
        tot += ctr[(b * b * b) % M]
    return tot

def ratio_null(p, k):
    """Null harness: independent uniform b-residues. Must give 1.0."""
    M = p ** k
    ctr = Counter()
    for a in range(M):
        ctr[(a * a) % M] += 1
    tot = 0
    for b in range(M):
        tot += ctr[(b * 7 + 3) % M]      # affine => uniform over residues
    return (tot / M) * 1.0 / M

def predict(p, k):
    e = k - math.ceil(k/2) - math.ceil(k/3)
    return (2 - 1.0/p) + (p ** e - 1)

if __name__ == "__main__":
    primes = [2,3,5,7,11,13]
    print("=== A1 exhaustive enumeration, ALL (a,b) mod p^k, no exclusions ===")
    print("p  k  M       count            ratio            predict           resid   null")
    for p in primes:
        for k in range(1, 8):
            M = p ** k
            if M > 6_000_000:
                print(f"{p:3d} {k:3d}  {M:>9d}  SKIPPED (too large)")
                continue
            c = count_pairs(p, k)
            r = (c / (M*M)) / (1.0/M)      # = count / M
            pr = predict(p, k)
            nul = ratio_null(p, k)
            flag = "" if abs(r-pr) < 1e-9 else "   <<< DEPARTURE"
            print(f"{p:3d} {k:3d}  {M:>9d}  {c:>15d}  {r:14.7f}  {pr:14.7f}  {r-pr:+9.2e}  {nul:.6f}{flag}")
        print()
