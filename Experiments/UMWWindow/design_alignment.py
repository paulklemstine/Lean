#!/usr/bin/env python3
"""
Design-theoretic alignment for the divisor cover (round 96d).

QUESTION: can a STRUCTURED set S -- a perfect difference set, whose pairwise
differences are provably maximally SPREAD (Singer (v,k,1) sets, formalized in
Catalog/Bridges/DifferenceSetFlatProfile.lean) -- beat a RANDOM S of the same
size at covering [n] via differences?  Spread differences are exactly what the
round-96b birthday obstruction punishes clustering for, so a difference set is
the natural design-theoretic candidate for EVADING it.

The cover condition, NON-VACUOUSLY (S, T disjoint as integer sets, so every
difference s-t is nonzero -- Round 49 flagged 0 in the difference set as making
the whole thing trivial):
    for i in [2,n]:  (S mod i) INTERSECTS (T mod i).

Known perfect difference sets used (v,k,1), shifted to avoid 0:
    (7,3)  (13,4)  (21,5)  (31,6).

FINDING: the design/random coverage ratio stays ~1.0-1.06 at ALL scales n.
Perfect difference sets give a constant-factor (not exponent) improvement: they
do NOT evade the birthday obstruction, because flatness of differences mod v
says nothing about the distribution mod each i <= n.  NEGATIVE result.
"""
import random

# Perfect (v,k,1) difference sets (Singer), shifted +1 so no element is 0.
PDS = {
    (7, 3):  {1, 2, 4},
    (13, 4): {1, 2, 4, 10},
    (21, 5): {1, 2, 5, 15, 17},
    (31, 6): {1, 2, 4, 9, 13, 19},
}

def is_perfect(v, D):
    diffs = [(a - b) % v for a in D for b in D if a != b]
    return len(diffs) == len(set(diffs)) == v - 1

def coverage(S, T, n):
    """fraction of i in [2,n] with (S mod i) INTERSECT (T mod i) nonempty."""
    cov = 0
    for i in range(2, n + 1):
        rs = {x % i for x in S}
        if any(y % i in rs for y in T):
            cov += 1
    return cov / (n - 1)

def main():
    for (v, k), D in PDS.items():
        print(f"({v},{k},1) shifted set {sorted(D)} perfect? {is_perfect(v, D)}")

    random.seed(0)
    print("\nNon-vacuous coverage (S, T disjoint), design vs random, ratio vs n:")
    for (v, k), D in PDS.items():
        T = set(range(v, 2 * v))          # disjoint from D (< v)
        row = []
        for mult in [1, 2, 4, 8, 16]:
            n = v * mult
            covD = coverage(D, T, n)
            covR = sum(coverage(set(random.sample(range(v), k)), T, n) for _ in range(20)) / 20
            ratio = covD / covR if covR > 0 else float('nan')
            row.append(f"n={n}: d={covD:.3f} r={covR:.3f} ratio={ratio:.3f}")
        print(f"  v={v:3d} k={k}: " + "  ".join(row))
    print("\nVERDICT: ratio ~1.0-1.06 at every scale -> constant-factor only,")
    print("SAME birthday exponent. Perfect difference sets do NOT evade the")
    print("obstruction. Design-theoretic alignment is a negative result here.")

if __name__ == "__main__":
    main()