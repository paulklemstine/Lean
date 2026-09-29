#!/usr/bin/env python3
"""The NON-CIRCULAR success rate, stratified across moduli.

No factorisation of N, no rank computation, no PARI anywhere.  Pure enumeration of coprime
(u,v) with max(|u|,|v|) <= H, testing l(m) = w^2 and chi_P = Jacobi(C(t)y, N).

Two numbers decide whether this is a method:
  (a) the FRACTION of (N,f) that admit a chi_P = -1 point within H;
  (b) the NUMBER of relations found per (N,f) -- because a method needs REDUNDANCY, and
      an NFS needs ~L_n[1/3] ~ 1e35 relations.  One relation factors N, but one is not a
      margin.
"""
from fractions import Fraction as F
from math import gcd, isqrt
from sympy import isprime
import statistics, time

def jacobi(a, n):
    a, n = int(a) % n, int(n)
    r = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5): r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3: r = -r
        a %= n
    return r if n == 1 else 0

def gsq(g, P, Q):
    g0, g1, g2 = g
    return (g0*g0 - 2*Q*g1*g2, 2*g0*g1 - 2*P*g1*g2 - Q*g2*g2,
            2*g0*g2 + g1*g1 - P*g2*g2)

def icbrt(n):
    lo, hi = 0, 1
    while hi**3 <= n: hi *= 2
    while lo+1 < hi:
        mid=(lo+hi)//2
        if mid**3<=n: lo=mid
        else: hi=mid
    return lo

def scan(N, m, P, Q, H):
    best = None; npts = 0
    for v in range(1, H+1):
        for u in range(-H, H+1):
            if gcd(abs(u), v) != 1: continue
            g = (P*v*v - 4*u*u, -4*u*v, 2*v*v)
            c0, c1, c2 = gsq(g, P, Q)
            if c2 != 0: continue
            lm = c1*m + c0
            if lm <= 0: continue
            w = isqrt(lm)
            if w*w != lm or w % N == 0: continue
            gm = g[0] + g[1]*m + g[2]*m*m
            if gm % N == 0: continue
            npts += 1
            t = F(u, v); yy = F(w, v*v)
            val = (F(m*m) - 2*t*m - 2*t*t) * yy
            if val.denominator != 1:
                d = val.denominator; val = val*(d*d)
            if jacobi(int(val), N) == -1:
                if best is None: best = max(abs(u), v)
    return best, npts

if __name__ == "__main__":
    H = 60
    semiprimes = [1333, 1829, 2077, 2201, 2449, 2537, 3053, 3397, 3953, 4189,
                  4757, 5461, 6203, 7633, 10231, 11863, 12763, 15163, 16633, 18191]
    good = [N for N in semiprimes
            if (lambda pq: pq and pq[0]%4==3 and pq[1]%4==3)(
                (lambda p: (p, N//p) if p else None)(
                    next((d for d in range(3,N,2) if N%d==0 and isprime(d)), None)))]
    print(f"factorisation-free, H = {H}, {len(good)} moduli, P != 0 exercised\n")
    print(f"{'N':>7} {'m':>4} {'P':>4} {'Q':>6} {'#rel':>5} {'chi=-1?':>9} {'Hmin':>5}")
    print("-"*54)
    perN = {}; rows = []
    t0 = time.time()
    for N in good:
        fN = tN = 0
        for m in range(icbrt(N)+1, icbrt(N)+200):
            for P in [0, 2, 5, 9, 13, 17, 21]:
                for Q in range(-80, 81):
                    if (m**3 + P*m + Q) % N != 0: continue
                    hm, np_ = scan(N, m, P, Q, H)
                    tN += 1; fN += (hm is not None)
                    rows.append((N,m,P,Q,np_,hm))
                    if tN >= 8: break
                if tN >= 8: break
            if tN >= 8: break
        perN[N] = (fN, tN)
        print(f"{N:>7} {'':>4} {'':>4} {'':>6} {'':>5} "
              f"{str(fN)+'/'+str(tN):>9} {'':>5}")
    print("-"*54)
    tot = sum(t for _, t in perN.values()); found = sum(f for f, _ in perN.values())
    rel = [r[4] for r in rows]; hmv = [r[5] for r in rows if r[5]]
    print(f"  chi_P = -1 within H={H}:  {found}/{tot} = {100*found/tot:.0f}%  "
          f"of (N,f), NO factorisation used")
    print(f"  relations per (N,f) at H={H}:  median {statistics.median(rel)}  "
          f"max {max(rel)}   (an NFS needs ~1e35)")
    print(f"  Hmin among successes:  median {statistics.median(hmv)}  max {max(hmv)}")
    print(f"  elapsed {time.time()-t0:.1f}s")
