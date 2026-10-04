"""Direct test of the rank-2 escape: can a GAP cover beat an AP cover?

Round 60 (mine) argued that the n^{3/4} obstruction of He-Sahai (arXiv:2608.06681)
is probably rank-INDEPENDENT, reducing the whole Umans-Wang route to bounding
`t` = the number of band primes dividing a GAP difference.  Round 59 measured
first-moment densities and found rank-2 == rank-1.

This script asks the DIRECT question instead: not a density, but EXISTENCE.

  rank-1:  A = { b + i c : 0 <= i < L }          -- an arithmetic progression
  rank-2:  S = { a + i : 0 <= i < L1 },  T = { B j : 0 <= j < L2 }
           A = S - T = { a + i - B j }

"A is an n-divisor cover" means: for every m in [1,n] there is an element of A
divisible by m.  We minimise |A| (or the effective count) for each rank.

If rank-2 finds covers of markedly smaller size than rank-1, the escape is real
and Round 60 is wrong.  If not, the picture is consistent.

METHOD.  Brute force over the structural parameters, exact divisibility test.
For each candidate we test all m <= n.  We report the minimum covering |A|.
"""
from __future__ import annotations
import math, itertools
from math import isqrt

def covers(A, n):
    """A: iterable of positive integers.  True if every m in [1,n] divides
    some element of A (0 is not admissible -- vacuous)."""
    A = [x for x in A if x > 0]
    s = set(A)
    for m in range(1, n + 1):
        hit = False
        for t in range(1, n // m + 1):
            if t * m in s:
                hit = True; break
        if not hit:
            return False
    return True

def ap_min_cover(n, Lmax=None):
    """minimum L for a rank-1 AP cover; (L,b,c)"""
    if Lmax is None: Lmax = n
    for L in range(1, Lmax + 1):
        for c in range(1, 60):
            for b in range(1, 60):
                if covers([b + i * c for i in range(L)], n):
                    return L, b, c
    return None

def gap_min_cover(n, L1max, L2max, Bmax):
    """minimum |A| for a rank-2 cover; (L1,L2,a,B)"""
    best = None
    for L1 in range(1, L1max + 1):
        for L2 in range(1, L2max + 1):
            size = L1 * L2
            if best is not None and size >= best[0]:
                continue
            for B in range(1, Bmax + 1):
                for a in range(1, 60):
                    A = [a + i - B * j for i in range(L1) for j in range(L2)]
                    if covers(A, n):
                        best = (size, L1, L2, a, B)
                        break
                if best is not None: break
            if best is not None and best[0] == size: break
    return best

def main():
    print(__doc__)
    print("=== rank-1 (AP) vs rank-2 (GAP): minimum covering size ===")
    print()
    print(f"{'n':>4} {'rank1 L':>8} {'rank1 (b,c)':>12} "
          f"{'rank2 |A|':>10} {'rank2 (L1,L2,a,B)':>22} {'ratio':>7}")
    for n in (10, 14, 18, 22, 26):
        r1 = ap_min_cover(n)
        # rank 2 search: allow L1,L2 up to about n
        r2 = gap_min_cover(n, min(n, 12), min(n, 12), 25)
        if r1 is None: continue
        if r2 is None:
            print(f"{n:4d} {r1[0]:8d} {str((r1[1],r1[2])):>12} "
                  f"{'none':>10} {'':>22} {'-':>7}")
        else:
            print(f"{n:4d} {r1[0]:8d} {str((r1[1],r1[2])):>12} "
                  f"{r2[0]:10d} {str((r2[1],r2[2],r2[3],r2[4])):>22} "
                  f"{r2[0]/r1[0]:7.3f}")

if __name__ == "__main__":
    main()
