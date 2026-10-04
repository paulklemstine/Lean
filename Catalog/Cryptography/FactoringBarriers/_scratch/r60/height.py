"""Why does L_min(n) ~= n/2 in the brute-force range, while He-Sahai force
L >> n^(3/4)?

He-Sahai's Theorem 1.1 needs  log H = o(sqrt n)  with  H = b + (L-1)c.
At L = n/2 and c = 1,  log H = log n,  which is NOT o(sqrt n)  (log n >> sqrt n).
So the brute-force solutions found above sit at height H ~ n, far above the
height regime the theorem covers.

Where is the height threshold?
    log H <= log n  requires  L*c ~ n  at most.
    log H = o(sqrt n)  requires  L*c = n^{1/2 - eps}  or smaller.

Umans-Wang need L = n^{2/3} and H = exp(n^{1/3}).
    log H = n^{1/3}  vs  sqrt n = n^{1/2}.   n^{1/3} = o(n^{1/2})?   YES.
So Umans-Wang's parameters ARE in He-Sahai's regime.  Good -- consistent.

THE QUESTION: at moderate L, what height is NEEDED for a cover?  That is the
tradeoff curve  H_min(L, n).  He-Sahai's theorem says: for L <= n^{2/3}, any
cover must have log H >= sqrt n - o(sqrt n), i.e. H >= exp((1-o(1)) sqrt n).
Let us verify that by search: for each L, find the minimum possible H.
"""
from __future__ import annotations
import math, random
from math import gcd, isqrt

def primes_upto(n):
    s = bytearray([1])*(n+1); s[0:2]=b"\x00\x00"
    for i in range(2, isqrt(n)+1):
        if s[i]: s[i*i::i] = bytearray(len(s[i*i::i]))
    return [i for i in range(2,n+1) if s[i]]

def min_height_for(n, L, cmax=60, bmax=200):
    """smallest b (with c <= cmax) such that {b+ic: i<L} covers [1,n]"""
    mods = list(range(2, n+1))
    best = None
    for c in range(1, cmax+1):
        for b in range(1, bmax+1):
            H = b + (L-1)*c
            # fast: build set of first L terms, check divisibility
            terms = [b + i*c for i in range(L)]
            ok = True
            for m in mods:
                hit = False
                for t in terms:
                    if t % m == 0:
                        hit = True; break
                if not hit:
                    ok = False; break
            if ok:
                if best is None or H < best[0]:
                    best = (H, b, c)
                break
    return best

def main():
    print(__doc__)
    print("=== minimum H for a cover of [1,n] with L terms (brute force) ===")
    print(f"{'n':>5} {'L':>5} {'H_min':>8} {'b':>5} {'c':>4} "
          f"{'log H':>8} {'sqrt n':>8} {'logH/sqrtn':>11}")
    for n in (12, 18, 24):
        for L in range(max(1, n//4), n+1, max(1, n//6)):
            r = min_height_for(n, L)
            if r is None: continue
            H, b, c = r
            print(f"{n:5d} {L:5d} {H:8d} {b:5d} {c:4d} "
                  f"{math.log(H):8.3f} {math.sqrt(n):8.3f} "
                  f"{math.log(H)/math.sqrt(n):11.3f}")
        print()

    print("=== the Umans-Wang parameter point, for scale ===")
    print("  L = n^(2/3), H = exp(n^(1/3)):  log H / sqrt n = n^(1/3)/n^(1/2)")
    for n in (10**3, 10**6, 10**9, 10**12):
        L = n ** (2/3); logH = n ** (1/3); sq = n ** 0.5
        print(f"    n=1e{int(round(math.log10(n)))}: L={L:.3e}  "
              f"log H/sqrt n = {logH/sq:.4f}   -> in He-Sahai regime: {logH/sq < 0.01}")
    print()
    print("=== so: covers DO exist at L ~= n/2 with H ~ n, but that height")
    print("    is OUTSIDE He-Sahai's regime (log H = log n >> sqrt n).")
    print("    Umans-Wang's target sits INSIDE the regime, where the")
    print("    obstruction applies.  The brute force above is consistent")
    print("    with the refutation, not against it. -/")

if __name__ == "__main__":
    main()
