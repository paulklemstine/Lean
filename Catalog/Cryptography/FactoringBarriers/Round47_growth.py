#!/usr/bin/env python3
"""SETTLE THE GROWTH QUESTION.

Round 47's verdict rests on "median 2 relations at height 60" -- too small a range to
extrapolate.  The question that decides whether this direction has ANY asymptotic content:

  supply = #admissible generators of rational height <= H   (the relations, essentially)
  demand = ~L_N[1/3]   (what an L[1/3] NFS needs)

If supply ~ Theta(H) then you must search to H ~ L_N[1/3], and the search cost is
comparable to the NFS cost itself: no win, no loss.  If supply grows slower, it is worse.
Either way this is MEASURABLE, so measure it instead of asserting it.
"""
from fractions import Fraction as F
from math import gcd, isqrt, log
from sympy import isprime

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

def L13(N):
    k = (64/9)**(1/3); lnN = log(N)
    return k * lnN**(1/3) * log(lnN)**(2/3)

def pick(N):
    for m in range(icbrt(N)+1, icbrt(N)+300):
        for P in [0, 2, 5, 9, 13, 17, 21, 26, 33, 41]:
            for Q in range(-120, 121):
                if (m**3 + P*m + Q) % N == 0:
                    return (m, P, Q)
    return None

def count(N, m, P, Q, H):
    """#admissible linear forms of rational height <= H.  Incremental by v so the total
    cost is ~H^2 once, not summed per H."""
    n = 0; perH = {}
    for v in range(1, H+1):
        for u in range(-H, H+1):
            if gcd(abs(u), v) != 1: continue
            h = max(abs(u), v)
            if h < v: continue          # already counted at a smaller height
            g = (P*v*v - 4*u*u, -4*u*v, 2*v*v)
            c0, c1, c2 = gsq(g, P, Q)
            if c2 != 0: continue
            lm = c1*m + c0
            if lm <= 0: continue
            w = isqrt(lm)
            if w*w == lm:
                n += 1; perH[h] = perH.get(h, 0) + 1
    return n, perH

if __name__ == "__main__":
    Ns = [1333, 2537, 4757, 10231, 18191, 40009, 90481, 160969]
    Hs = [20, 50, 100, 200, 400, 800]
    print(f"{'N':>7} {'ln N':>6} {'(m,P,Q)':>16}  " +
          "  ".join(f"H={h:<5}" for h in Hs) + "   growth")
    print("-"*104)
    for N in Ns:
        p = next((d for d in range(3,N,2) if N%d==0 and isprime(d)), None)
        if p is None or p%4!=3 or (N//p)%4!=3: continue
        row = pick(N)
        if not row: continue
        m,P,Q = row
        n, perH = count(N, m, P, Q, max(Hs))
        cum = 0; vals = []
        for h in Hs:
            cum += sum(k for hh,k in perH.items() if hh <= h)
            vals.append(cum)
        # linear in H would give a constant ratio cum/H
        ratios = [v/h for v,h in zip(vals,Hs)]
        print(f"{N:>7} {log(N):>6.2f} {str(row):>16}  " +
              "  ".join(f"{v:<7}" for v in vals) +
              f"   cum/H: {' '.join(f'{r:.3f}' for r in ratios)}")
    print("-"*104)
    print("cum/H approaching a constant => supply is LINEAR in H.")
    print("For L[1/3] you would need H ~ L_N[1/3] generators, i.e. a search of that size.")
