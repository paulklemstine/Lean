#!/usr/bin/env python3
"""
AXIS 2.  Is BSGS really the only way to exploit a group of known order h?
ECM-style smoothness lottery applied to h(-kN).

Sub-questions:
 2a. Can p | h(-kN) EVER happen?  (exhaustive small-prime search)
 2b. If h is B-smooth with B = L[1/2], can p | h?  (arithmetic)
 2c. Sieve over k for B-smooth h; check p | h.  (the ECM analogue)
 2d. Distribution of h(-kN)/sqrt(kN).  (does the sqrt law ever break badly?)
"""
import math, random, sys, time
import sympy
import cypari2

pari = cypari2.Pari(); pari.default("parisizemax", 1<<30)
def h_of(D):
    """class number of the quadratic ORDER of discriminant D (D<=0, D=0/1 mod 4)."""
    if D % 4 not in (0,1):
        D = D*4
    return int(pari.qfbclassno(D))

def is_B_smooth(x, B):
    for pr in sympy.primerange(2, int(B)+1):
        while x % pr == 0: x //= pr
        if pr*pr > x:
            if x > 1:
                return x <= B
    return x <= 1

print("="*78)
print("2a. CAN p | h(-kN) EVER HAPPEN?  Exhaustive small-prime search.")
print("     N = p*q with p,q = 3 mod 4 primes.  D = -4*k*N.")
print(f"     {'p':>6} {'q':>6} {'k_max':>7} {'hits':>6}  first hit")
random.seed(20251003)
tot_hits = 0; tot_trials = 0
first_hit = None
t0=time.time()
ps = [x for x in sympy.primerange(3, 1200) if x % 4 == 3]
print(f"     primes 3 mod 4 below 1200: {len(ps)}")
for i,p in enumerate(ps):
    for q in ps[i+1:i+2]:          # adjacent pairs, small N
        N = p*q
        for k in range(1, 2001):
            h = h_of(-4*k*N)
            tot_trials += 1
            if h % p == 0:
                tot_hits += 1
                if first_hit is None:
                    first_hit = (p,q,k,h,h//p)
            if time.time()-t0 > 240:
                break
        if time.time()-t0 > 240: break
    if time.time()-t0 > 240: break
print(f"     trials={tot_trials}  HITS={tot_hits}   ({time.time()-t0:.0f}s)")
print(f"     first hit: {first_hit}")
