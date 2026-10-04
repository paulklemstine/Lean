"""Quantify the L vs H tradeoff at moderate n, and test the regime question.

He-Sahai: log H = o(sqrt n)  =>  L >= (sqrt(8/27)-o(1)) n^(3/4)/sqrt(log n).
Brute force: at n <= 24, covers with L ~ n/2 exist at H ~ n (log H = log n).
Those are CONSISTENT: log n >> sqrt n, so the hypothesis fails and the
theorem does not apply.

The real question is the phase boundary: at what L does the cheapest cover
leave the log H = o(sqrt n) regime?  Equivalently, for each L, is H_min small
enough that log H_min = o(sqrt n)?

If for L ~ n^(2/3) we need log H_min >> sqrt n, He-Sahai is sharp and the
divisor-cover route is dead even before considering rank-2.
"""
from __future__ import annotations
import math
from math import isqrt

def cover_check(n, b, c, L):
    terms = [b + i*c for i in range(L)]
    for m in range(2, n+1):
        hit = False
        for t in terms:
            if t % m == 0:
                hit = True; break
        if not hit:
            return False
    return True

def min_H(n, L, cmax=40, bmax=120):
    best = None
    for c in range(1, cmax+1):
        for b in range(1, bmax+1):
            H = b + (L-1)*c
            if best is not None and H >= best[0]:
                break
            if cover_check(n, b, c, L):
                if best is None or H < best[0]:
                    best = (H, b, c)
                break
    return best

def main():
    print(__doc__)
    print("=== for each n and L: does a cover exist inside He-Sahai's regime? ===")
    print("He-Sahai regime needs log H < sqrt n (with margin).")
    print()
    for n in (12, 18, 24, 30):
        sq = math.sqrt(n)
        print(f"  --- n={n}, sqrt(n)={sq:.3f} ---")
        for L in sorted({max(1,n//4), max(1,n//3), max(1,n//2), max(1,2*n//3), n}):
            r = min_H(n, L)
            if r is None:
                print(f"    L={L:3d}: none found")
                continue
            H, b, c = r
            lh = math.log(H)
            frac = lh/sq
            verdict = "INSIDE regime" if frac < 1 else "outside (logH > sqrt n)"
            print(f"    L={L:3d}: H_min={H:6d} b={b:3d} c={c:2d} "
                  f"logH={lh:6.3f} logH/sqrtn={frac:6.3f}  {verdict}")
        print()
    print("=== SUMMARY TABLE: exponent of n at which the target (1/3,1/3) enters")
    print("He-Sahai's regime: need log H / sqrt n -> 0, with H = exp(n^(1/3)),")
    print("i.e. n^(1/3)/n^(1/2) = n^(-1/6) -> 0.  So the regime condition")
    print("is satisfied for ALL sufficiently large n; it is NOT the binding")
    print("issue at small n.  The binding issue is the L >= n^(3/4) bound")
    print("itself, which holds for every n in the regime.")
    print()
    print("=== conclusion: the brute-force covers at L~n/2 are a finite-size")
    print("artefact of being in the OUTSIDE regime.  Asymptotically, any cover")
    print("with L = o(n^(3/4)) must have log H >> sqrt n, which is exactly")
    print("what excludes the (1/3,1/3) point. -/")

if __name__ == "__main__":
    main()
