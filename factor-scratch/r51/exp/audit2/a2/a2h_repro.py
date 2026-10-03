#!/usr/bin/env python3
"""Reproducibility of the 0/890 cell: does r3_classgroup.py's DEFAULT even run,
and at what p scale?"""
import time, math
import sympy, cypari2
pari=cypari2.Pari(); pari.default("parisizemax",1<<30)
print("r3_classgroup.py q1_divisibility() defaults: n_trials=300, kmax=8")
print("  -> 300*8 = 2400 (N,k) pairs, p,q = randprime(10^25,10^26)")
print(f"  10^25 = 2^{math.log2(10**25):.1f}  => p ~ 2^{math.log2(10**25):.0f}, N ~ 2^{math.log2(10**26)*2:.0f}")
print("  NOTES REPORT: 'N ~ 2^66, 40 instances, 16 k-values = 640'.")
print("  ==> MISMATCH on scale (script: N~2^166) and on trial count (2400 vs 640).")
print()
print("r3_why_zero.py uses randprime(10^9,10**10) => p ~ 2^30, N ~ 2^60-2^66. MATCHES '2^66'.")
print("  But r3_why_zero.py runs 40 trials x 22 k-values = 880 pairs, k up to 1024.")
print("  ==> 880 ~ 890. THE 890 IS PROBABLY 40*22=880 MISCOUNTED, or 40x22 rounded.")
print("  ==> Either way the two cells in the paper (640 + 150) sum to 790, not 890.")
print()
print("TIMING: is qfbclassno at 2^166 even feasible?")
for bits in [60, 100, 140]:
    p=sympy.randprime(2**(bits-1),2**bits); q=sympy.randprime(2**(bits-1),2**bits)
    N=p*q; t=time.time()
    h=int(pari.qfbclassno(-4*N))
    print(f"  p,q ~ 2^{bits}: qfbclassno(-4N) took {time.time()-t:8.2f}s   "
          f"(N ~ 2^{2*bits})")
    if time.time()-t > 30: break
