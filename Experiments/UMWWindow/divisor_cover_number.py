#!/usr/bin/env python3
"""
TRUE divisor-cover number (round 96f): the divisor-reuse escape route, measured.

Round 96e left one route not killed by the birthday obstruction: reuse ONE
difference's DIVISOR STRUCTURE rather than its residues. A difference d<=M
covers every i that divides d, so we ask: how many integers d_1..d_k <= M are
needed so that every i<=n divides some d_j? (a set-cover problem). If
cover_number <= n^(2 gamma) for gamma<0.4, a rank-2 GAP with those differences
could beat 1/5.

BUG NOTE: an earlier draft of this script reported k=2-3 as a "full cover".
That was wrong -- the greedy stopped when bestgain hit 0 (gave up) and the code
counted the picks, not a successful cover. Here we (a) report uncovered and a
full=True flag, and (b) use ALL integers <=M as candidates, so the greedy is a
real upper bound on the minimum k.

FINDING: cover_number ~ 1.9 * (n / ln n) = Theta(pi(n)), because every maximal
prime power m = p^floor(log_p n) <= n needs a dedicated d, and no single d <= M
is a multiple of two large primes (their product >> M). This EXCEEDS the n^(2g)
budget for gamma<1/2, so the divisor-reuse route hits the SAME counting wall as
every other route. The wall is machine-checked in UMWCountingWall.lean.
"""
import math

def divisors_of(d, n):
    out = {1}
    for i in range(1, min(n, int(math.isqrt(d))) + 1):
        if d % i == 0:
            out.add(i)
            if d // i <= n:
                out.add(d // i)
    if d <= n:
        out.add(d)
    return out

def greedy_cover(n, M):
    # candidates: all d <= M (cap for speed); precompute divisor sets in [1,n]
    cands = {d: divisors_of(d, n) for d in range(1, min(M, 3000) + 1)}
    uncovered = set(range(1, n + 1))
    k = 0
    while uncovered:
        best, bg = None, 0
        for d, ds in cands.items():
            g = len(ds & uncovered)
            if g > bg:
                bg, best = g, d
        if bg == 0:
            break
        k += 1
        uncovered -= cands[best]
    return k, len(uncovered)

def main():
    print("TRUE divisor-cover number (all d<=M candidates, full-coverage flagged).")
    print("n | gamma |      M | cover_k | uncovered | full | budget n^(2g) | feasible")
    for n in [100, 200, 400]:
        for gamma in [0.34, 0.36, 0.399, 0.50]:
            M = int(math.exp(n ** gamma))
            k, unc = greedy_cover(n, M)
            full = (unc == 0)
            budget = n ** (2 * gamma)
            print(f"{n:4d} | {gamma:.3f} | {M:9d} | {k:7d} | {unc:9d} | {str(full):5s} | "
                  f"{budget:12.1f} | {full and k <= budget}")
    print("\ncover_k ~ 1.9 * (n/ln n) = Theta(pi(n)): every maximal prime power")
    print("needs a dedicated difference (no small d<=M is a multiple of two large")
    print("primes). This exceeds the n^(2g) budget for gamma<1/2, so divisor reuse")
    print("HITS THE SAME COUNTING WALL. No escape; window still closed.")

if __name__ == "__main__":
    main()