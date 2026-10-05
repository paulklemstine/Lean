#!/usr/bin/env python3
"""Diagnose WHY t_max == |P0| in exp_a. Two candidate explanations:
 (E1) some difference a1*di + a2*dj is EXACTLY 0 (integer), so every p divides it.
     => the "gap" is degenerate (a1/a2 is a ratio of small ints), i.e. it is really
        rank-1, and t is vacuous for that gap.
 (E2) t_max is genuinely large for a nondegenerate gap.
This distinguishes them. Also tests the ZERO-COEFFICIENT trap a1==0 or a2==0.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import rng, band_primes, t_profile, sample_gap_leq_exp
import numpy as np
from math import gcd

SEED = 20261004
ALPHA = 1.0/3.0

def find_argmax(a1, a2, L1, L2, P):
    """Recompute the t map and return the argmax difference."""
    P = np.asarray(P, dtype=np.int64)
    tmap = np.zeros((2*L1-1, 2*L2-1), dtype=np.int32)
    dI = np.arange(-(L1-1), L1, dtype=np.int64)
    for p in P:
        p = int(p)
        if a1 % p == 0 and a2 % p == 0: continue
        a1p, a2p = a1 % p, a2 % p
        r = (-a1p * pow(a2p, -1, p)) % p if a2p != 0 else 0
        vals = (r * dI) % p
        pos = vals < L2
        neg = vals > (p - L2)
        if pos.any(): tmap[(dI[pos]+L1-1), (vals[pos])] += 1
        if neg.any(): tmap[(dI[neg]+L1-1), (vals[neg]-p+L2-1)] += 1
    tmap[L1-1, L2-1] = -1
    idx = np.unravel_index(np.argmax(tmap), tmap.shape)
    di, dj = int(idx[0])-(L1-1), int(idx[1])-(L2-1)
    return di, dj, int(tmap[idx]), a1*di + a2*dj

L = 2**8; n = L**3
P = band_primes(n)
for rep in range(3):
    r = rng(SEED, f"randA-8-{rep}")
    a1, a2, b0 = sample_gap_leq_exp(r, n, ALPHA, L, L)
    di, dj, t, D = find_argmax(a1, a2, L, L, P)
    g = gcd(abs(a1), abs(a2))
    print(f"rep{rep}: a1==0? {a1==0}  a2==0? {a2==0}  gcd(a1,a2) bitlen={g.bit_length()}")
    print(f"   argmax diff (di,dj)=({di},{dj})  t={t}   a1*di+a2*dj = {D}")
    print(f"   exact integer zero? {D==0}    reduced ratio a1/g : a2/g bitlens = "
          f"{(a1//g).bit_length()},{(a2//g).bit_length()}   both < L? "
          f"{abs(a1//g)<L and abs(a2//g)<L}")