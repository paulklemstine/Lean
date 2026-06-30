"""
Projective-Plane Coupon Collection Slowness — numerical demonstrations.

This self-contained script demonstrates the central result: collecting coupons by
drawing the LINES of a finite projective plane of order q is slower, in expected
cover time, than drawing uniformly random (q+1)-subsets of the same q^2 + q + 1
points.

It provides:
  1. A cyclic (Singer) construction of a projective plane via a planar difference
     set, found by search and self-verified.
  2. Exact rational expected cover times via inclusion-exclusion (feasible q=2,3).
  3. The closed-form geometric avoid-counts (point, pair, collinear/generic triple)
     verified against the constructed plane.
  4. The convexity-driven order-three surplus that explains the slowness.
  5. Monte Carlo cover-time estimates for larger orders q=4,5.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction
from math import comb
from typing import Dict, List, Optional, Sequence, Tuple


# --------------------------------------------------------------------------- #
# 1. Construct a projective plane of order q as a cyclic difference set.
# --------------------------------------------------------------------------- #
def find_difference_set(q: int) -> List[int]:
    """Find a planar (Singer) difference set D of size q+1 in Z/n, n=q^2+q+1.

    A planar difference set has all (q+1)*q nonzero differences distinct, hence
    each nonzero residue appears exactly once. Its translates form a projective
    plane of order q. Returns the lexicographically first such set containing 0.
    """
    n: int = q * q + q + 1
    k: int = q + 1
    # Fix 0 and 1 in the set to prune the search; search the rest.
    rest_pool: List[int] = list(range(2, n))
    for combo in itertools.combinations(rest_pool, k - 2):
        d: List[int] = [0, 1] + list(combo)
        diffs = set()
        ok = True
        for a in d:
            for b in d:
                if a == b:
                    continue
                delta = (a - b) % n
                if delta in diffs:
                    ok = False
                    break
                diffs.add(delta)
            if not ok:
                break
        if ok and len(diffs) == k * (k - 1):
            return d
    raise RuntimeError(f"No difference set found for q={q}")


def build_plane(q: int) -> Tuple[int, List[frozenset]]:
    """Return (n, lines) where lines are the n translates of a difference set."""
    n: int = q * q + q + 1
    d: List[int] = find_difference_set(q)
    lines: List[frozenset] = [
        frozenset((x + i) % n for x in d) for i in range(n)
    ]
    return n, lines


def verify_plane(n: int, lines: Sequence[frozenset], q: int) -> bool:
    """Check the projective-plane axioms for the constructed incidence structure."""
    if len(lines) != n:
        return False
    if any(len(L) != q + 1 for L in lines):
        return False
    # Every pair of points lies on exactly one common line.
    for p, r in itertools.combinations(range(n), 2):
        cnt = sum(1 for L in lines if p in L and r in L)
        if cnt != 1:
            return False
    return True


# --------------------------------------------------------------------------- #
# 2. Avoid-probabilities.
# --------------------------------------------------------------------------- #
def p_plane(A: frozenset, lines: Sequence[frozenset]) -> Fraction:
    """Probability a uniformly random line avoids the point set A."""
    avoid = sum(1 for L in lines if L.isdisjoint(A))
    return Fraction(avoid, len(lines))


def p_unif(k: int, n: int, q: int) -> Fraction:
    """Probability a uniformly random (q+1)-subset avoids a fixed k-set."""
    return Fraction(comb(n - k, q + 1), comb(n, q + 1))


# --------------------------------------------------------------------------- #
# 3. Exact expected cover time via inclusion-exclusion.
# --------------------------------------------------------------------------- #
def expected_cover_time_plane(n: int, lines: Sequence[frozenset]) -> Fraction:
    """E = sum_{A != empty} (-1)^{|A|+1} / (1 - p_A) for the plane mechanism."""
    total = Fraction(0)
    points = list(range(n))
    for k in range(1, n + 1):
        sign = 1 if k % 2 == 1 else -1
        for A in itertools.combinations(points, k):
            pa = p_plane(frozenset(A), lines)
            total += sign * Fraction(1, 1) / (1 - pa)
    return total


def expected_cover_time_unif(n: int, q: int) -> Fraction:
    """E for the uniform mechanism; p_A depends only on |A|, so group by size."""
    total = Fraction(0)
    for k in range(1, n + 1):
        sign = 1 if k % 2 == 1 else -1
        pk = p_unif(k, n, q)
        total += sign * Fraction(comb(n, k)) / (1 - pk)
    return total


# --------------------------------------------------------------------------- #
# 4. Geometric avoid-counts (closed forms) and order-three surplus.
# --------------------------------------------------------------------------- #
def avoid_counts_closed_form(q: int) -> Dict[str, int]:
    """The closed-form number of lines avoiding each configuration type."""
    return {
        "point": q * q,
        "pair": q * q - q,
        "collinear_triple": q * q - 2 * q,
        "generic_triple": (q - 1) ** 2,
    }


def measured_avoid_counts(n: int, lines: Sequence[frozenset]) -> Dict[str, int]:
    """Measure the four avoid-counts directly on the constructed plane."""
    # point
    pt = sum(1 for L in lines if 0 not in L)
    # pair (any two distinct points are symmetric: pick 0,1)
    pr = sum(1 for L in lines if 0 not in L and 1 not in L)
    # a collinear triple: take any whole line's first three points
    a_line = sorted(next(iter(lines)))
    coll = frozenset(a_line[:3])
    coll_cnt = sum(1 for L in lines if L.isdisjoint(coll))
    # a generic triple: search for three non-collinear points
    gen: Optional[frozenset] = None
    for trip in itertools.combinations(range(n), 3):
        t = frozenset(trip)
        if not any(t <= L for L in lines):
            gen = t
            break
    gen_cnt = sum(1 for L in lines if L.isdisjoint(gen)) if gen else -1
    return {
        "point": pt,
        "pair": pr,
        "collinear_triple": coll_cnt,
        "generic_triple": gen_cnt,
    }


def order_three_surplus(q: int) -> Fraction:
    """Closed-form order-three surplus: positive, driving the slowness.

    surplus_3 = sum over triples [ 1/(1-p_type) - 1/(1-p_unif_3) ],
    where collinear and generic triples carry distinct avoid-probabilities whose
    weighted mean equals the uniform value (Jensen => strictly positive).
    """
    n: int = q * q + q + 1
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)
    p_u = p_unif(3, n, q)
    n_coll = n * comb(q + 1, 3)          # collinear triples
    n_gen = comb(n, 3) - n_coll          # generic triples
    plane_part = n_coll / (1 - p_coll) + n_gen / (1 - p_gen)
    unif_part = Fraction(comb(n, 3)) / (1 - p_u)
    return plane_part - unif_part


# --------------------------------------------------------------------------- #
# 5. Monte Carlo cover-time estimation for larger q.
# --------------------------------------------------------------------------- #
def simulate_plane(
    n: int, lines: Sequence[frozenset], trials: int, seed: int = 0
) -> float:
    """Average number of draws to cover all n points, drawing random LINES."""
    rng = random.Random(seed)
    full = (1 << n) - 1
    bitmasks = [sum(1 << p for p in L) for L in lines]
    total_steps = 0
    for _ in range(trials):
        covered = 0
        steps = 0
        while covered != full:
            covered |= rng.choice(bitmasks)
            steps += 1
        total_steps += steps
    return total_steps / trials


def simulate_unif(n: int, size: int, trials: int, seed: int = 0) -> float:
    """Average draws to cover all n points, drawing FRESH uniform size-subsets.

    Each draw samples a new uniformly random (q+1)-subset (true uniform mechanism,
    not a pre-sampled pool), which is essential for an unbiased cover-time gap.
    """
    rng = random.Random(seed)
    full = (1 << n) - 1
    pts = range(n)
    total_steps = 0
    for _ in range(trials):
        covered = 0
        steps = 0
        while covered != full:
            for p in rng.sample(pts, size):
                covered |= 1 << p
            steps += 1
        total_steps += steps
    return total_steps / trials


# --------------------------------------------------------------------------- #
# Main demonstration.
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 72)
    print("Projective-Plane Coupon Collection Slowness")
    print("=" * 72)

    # ---- Exact results for q = 2 (Fano) and q = 3 -------------------------- #
    for q in (2, 3):
        n, lines = build_plane(q)
        assert verify_plane(n, lines, q), f"plane axioms failed for q={q}"
        print(f"\n--- q = {q}  (n = {n} points, {n} lines, line size {q + 1}) ---")

        cf = avoid_counts_closed_form(q)
        mc = measured_avoid_counts(n, lines)
        print(f"  avoid-counts  closed-form: {cf}")
        print(f"  avoid-counts  measured   : {mc}")
        assert cf == mc, "avoid-count mismatch!"

        e_plane = expected_cover_time_plane(n, lines)
        e_unif = expected_cover_time_unif(n, q)
        print(f"  E_plane = {e_plane} = {float(e_plane):.6f}")
        print(f"  E_unif  = {e_unif} = {float(e_unif):.6f}")
        gap = e_plane - e_unif
        print(f"  gap E_plane - E_unif = {gap} = {float(gap):.6f}  (> 0 means slower)")
        assert gap > 0, "expected plane to be slower!"

        s3 = order_three_surplus(q)
        print(f"  order-three surplus (closed form) = {float(s3):.6f}  (> 0, Jensen)")
        assert s3 > 0

    # Fano exact-value check matching the headline numbers.
    n2, lines2 = build_plane(2)
    assert expected_cover_time_plane(n2, lines2) == Fraction(163, 30)
    assert expected_cover_time_unif(n2, 2) == Fraction(85691, 15810)
    print("\n  [verified] Fano: E_plane = 163/30, E_unif = 85691/15810")

    # ---- Monte Carlo for q = 4, 5 ----------------------------------------- #
    print("\n--- Monte Carlo cover-time estimates for larger orders ---")
    for q in (4, 5):
        n, lines = build_plane(q)
        assert verify_plane(n, lines, q)
        trials = 300000 if q == 4 else 150000
        e_plane = simulate_plane(n, lines, trials, seed=q)
        e_unif = simulate_unif(n, q + 1, trials, seed=q + 100)
        print(
            f"  q = {q}  (n = {n}, {trials} trials):  E_plane ~ {e_plane:.4f},  "
            f"E_unif ~ {e_unif:.4f},  gap ~ {e_plane - e_unif:+.4f}"
        )

    print("\nConclusion: across q = 2,3,4,5 the projective-plane line mechanism")
    print("is slower than uniform sampling — the slowness phenomenon.")


if __name__ == "__main__":
    main()
