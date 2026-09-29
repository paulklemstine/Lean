#!/usr/bin/env python3
"""THE DECISIVE EXPERIMENT.

The record searches for a relation with chi_P = -1 by brute force over (u,v).  The
elliptic-curve reduction says the relations are the rational points of a genus-1 curve,
so the right search is MORDELL-WEIL: generate points from a basis and read off the
character.  If chi_P = -1 occurs on the Mordell-Weil group, the search becomes constructive.

This is only legitimate if the round trip  quartic <-> Weierstrass  is verified, so it is
verified in the same script, on every point, before any statistic is computed.
"""
from fractions import Fraction as F
from math import gcd, isqrt, comb
import cypari2
P = cypari2.Pari()

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

def to_E(t, y, m, c):
    return y + 2*t*t + 2*m*t, 2*(y + 2*t*t + 2*m*t - m*m)*t + (m*(y + 2*t*t + 2*m*t) - c)

def to_quartic(x, Y, m, c):
    den = 2*(x - m*m)
    if den == 0: return None, None
    t = (Y - m*x + c) / den
    y = x - 2*t*t - 2*m*t
    return t, y

def on_quartic(t, y, m, c):
    return y*y == 4*t**4 + 8*m*t**3 - 4*c*t + m*c

def chi(t, y, m, c, N):
    C = m*m - 2*t*m - 2*t*t
    v = C*y
    if v == 0: return 0
    if v.denominator != 1:
        d = v.denominator
        v = v*(d*d)
    return jacobi(int(v), N)

def Bval(t, c):
    return c*c - 20*c*t**3 - 8*t**6

def run(N, c, m, nmult=6, ncomb=2):
    a, b = -3*m*c, c*c + m**3*c
    E = P.ellinit([0, 0, 0, a, b])
    r = P.ellrank(E)
    rank, gens = int(r[0]), r[3]
    p = next(d for d in range(3, N, 2) if N % d == 0 and P.isprime(d))
    q = N//p
    print(f"\n=== N={N} (={p}*{q})  c={c} m={m}   Jac: Y^2 = X^3 - {a}X + {b}")
    print(f"    rank {rank}, PARI basis has {len(gens)} generator(s)")
    G = []
    for i in range(len(gens)):
        for n in range(-nmult, nmult+1):
            G.append(P.ellmul(E, gens[i], n))
    for i in range(len(gens)):          # add pairs of generators
        for j in range(i+1, len(gens)):
            for ni in range(-ncomb, ncomb+1):
                for nj in range(-ncomb, ncomb+1):
                    G.append(P.elladd(E, P.ellmul(E, gens[i], ni),
                                      P.ellmul(E, gens[j], nj)))
    G = [g for g in G if g != 0]

    seen, tally, bad = set(), {1: 0, -1: 0, 0: 0}, 0
    witness = None
    for g in G:
        # str(), NOT int(): PARI returns rationals like -79/16 and int() truncates
        # them to -4, which silently puts the point off the curve.  Same class of
        # bug as int(n**(1/3)) understating floor(n^(1/3)) at every perfect cube.
        x, Y = F(str(g[0])), F(str(g[1]))
        t, y = to_quartic(x, Y, m, c)
        if t is None: continue
        if not on_quartic(t, y, m, c): bad += 1; continue
        ch = chi(t, y, m, c, N)
        if (t, y) in seen: continue
        seen.add((t, y))
        tally[ch] = tally.get(ch, 0) + 1
        if ch == -1 and witness is None:
            witness = (t, y, x, Y)
    print(f"    round trip verified on {len(seen)} Mordell-Weil points "
          f"({bad} FAILED -> {'MAP OK' if bad == 0 else '*** MAP BROKEN ***'})")
    tot = sum(tally.values())
    if tot:
        print(f"    chi_P over the group:  +1: {tally[1]:>4}   -1: {tally[-1]:>4}"
              f"   0: {tally[0]:>4}    ->  fraction -1 = {tally[-1]/tot:.1%}")
    if witness:
        t, y, x, Y = witness
        Bt = Bval(t, c)
        print(f"    WITNESS  x={x} (height {len(str(abs(x)))} digits)")
        print(f"      t = {t}")
        print(f"      y = {y}")
        print(f"      B(t) = Norm(g)/v^6 = {Bt}   <-- the smoothness burden, "
              f"numerator has bits {len(str(abs(Bt.numerator)))}")
        from math import gcd as G2
        gg = G2(int(C_of(t, m)*y), N)
        print(f"      gcd(C(t)y, N) = {gg}  (must be 1 for a valid relation)")
    else:
        print(f"    *** NO chi_P = -1 point in the generated group ***")
    return tally

def C_of(t, m):
    return m*m - 2*t*m - 2*t*t

if __name__ == "__main__":
    for (N, c, m) in [(1333, 2, 20), (2201, 256, 19), (2537, 207, 14),
                      (5461, 108, 28), (1829, 368, 13), (2077, 263, 22)]:
        try:
            run(N, c, m)
        except Exception as e:
            print(f"  N={N} c={c} m={m}: FAILED {str(e)[:120]}")
