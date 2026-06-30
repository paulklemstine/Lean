"""
Projective-Plane Coupon Collection is Slower than Uniform
=========================================================

Numerical demonstration of the structural slowness engine.

On the n = q^2 + q + 1 points of a finite projective plane of order q we compare
two coupon-collection mechanisms, both drawing blocks of size q + 1:

  * plane mechanism   -- each draw is a uniformly random LINE of the plane;
  * uniform mechanism -- each draw is a uniformly random (q+1)-subset of points.

For a covering process whose single-draw probability of AVOIDING a target set A
is p_A, the expected time to cover the whole ground set is the inclusion-exclusion
sum

    E = sum_{A != empty} (-1)^{|A|+1} / (1 - p_A).

This script:
  (1) builds PG(2,q) for prime q and computes the FULL E exactly (q = 2, 3),
      confirming the plane mechanism is strictly slower;
  (2) computes the order-three TRUNCATION E^(3) = S1 - S2 + S3 in closed form
      for any prime power q, confirming the strict order-three surplus;
  (3) verifies the mean-matching identity and the exact agreement at orders 1, 2.

All arithmetic uses exact rationals (fractions.Fraction) so the strict
inequalities are certified, not floating-point artifacts.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Building the projective plane PG(2, q) for prime q                           #
# --------------------------------------------------------------------------- #
def build_pg2(q: int) -> Tuple[List[Tuple[int, int, int]], List[frozenset]]:
    """Return (points, lines) of PG(2, q) for a prime q.

    Points are the 1-dimensional subspaces of F_q^3 (normalized so the first
    nonzero coordinate is 1). A line is the set of point-indices orthogonal to a
    given normal vector; lines are indexed the same way as points (self-dual).
    """
    points: List[Tuple[int, int, int]] = []
    seen = set()
    for a in range(q):
        for b in range(q):
            for c in range(q):
                v = (a, b, c)
                if v == (0, 0, 0):
                    continue
                # normalize: scale so the first nonzero coordinate equals 1
                for i in range(3):
                    if v[i] % q != 0:
                        inv = pow(v[i], q - 2, q)  # Fermat inverse (q prime)
                        nv = tuple((x * inv) % q for x in v)
                        break
                if nv not in seen:
                    seen.add(nv)
                    points.append(nv)
    lines: List[frozenset] = []
    for normal in points:  # self-dual: each point also names a line
        members = frozenset(
            idx
            for idx, p in enumerate(points)
            if sum(a * b for a, b in zip(normal, p)) % q == 0
        )
        lines.append(members)
    return points, lines


# --------------------------------------------------------------------------- #
# Full expected coverage time via inclusion-exclusion                          #
# --------------------------------------------------------------------------- #
def expected_time_plane_full(q: int) -> Fraction:
    """Exact full E for the plane mechanism (feasible for small q)."""
    points, lines = build_pg2(q)
    n = len(points)
    num_lines = len(lines)
    total = Fraction(0)
    for k in range(1, n + 1):
        sk = Fraction(0)
        for A in combinations(range(n), k):
            target = set(A)
            avoid = sum(1 for ln in lines if target.isdisjoint(ln))
            p = Fraction(avoid, num_lines)
            sk += Fraction(1) / (1 - p)
        total += (-1) ** (k + 1) * sk
    return total


def uniform_avoid(q: int, k: int) -> Fraction:
    """Uniform avoid-probability for a k-subset: prod_{i<k} (q^2 - i)/(n - i)."""
    n = q * q + q + 1
    num, den = 1, 1
    for i in range(k):
        num *= (q * q - i)
        den *= (n - i)
    return Fraction(num, den)


def expected_time_uniform_full(q: int) -> Fraction:
    """Exact full E for the uniform mechanism."""
    n = q * q + q + 1
    total = Fraction(0)
    for k in range(1, n + 1):
        total += (-1) ** (k + 1) * comb(n, k) / (1 - uniform_avoid(q, k))
    return total


# --------------------------------------------------------------------------- #
# Order-three truncation in closed form (any prime power q)                    #
# --------------------------------------------------------------------------- #
def truncation_order3(q: int) -> Tuple[Fraction, Fraction]:
    """Return (E^(3)_plane, E^(3)_uniform) computed from closed-form counts."""
    n = q * q + q + 1

    # Uniform marginals.
    u1 = Fraction(q * q, n)
    u2 = Fraction(q * q * (q * q - 1), n * (n - 1))
    u3 = Fraction(q * q * (q * q - 1) * (q * q - 2), n * (n - 1) * (n - 2))

    # Plane avoid-probabilities by geometry.
    p_point = Fraction(q * q, n)
    p_pair = Fraction(q * q - q, n)
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)

    # Triple species counts.
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll

    s1_u = comb(n, 1) / (1 - u1)
    s2_u = comb(n, 2) / (1 - u2)
    s3_u = comb(n, 3) / (1 - u3)
    e3_uniform = s1_u - s2_u + s3_u

    s1_p = comb(n, 1) / (1 - p_point)
    s2_p = comb(n, 2) / (1 - p_pair)
    s3_p = n_coll / (1 - p_coll) + n_gen / (1 - p_gen)
    e3_plane = s1_p - s2_p + s3_p

    return e3_plane, e3_uniform


# --------------------------------------------------------------------------- #
# Identity checks                                                             #
# --------------------------------------------------------------------------- #
def check_mean_matching(q: int) -> bool:
    """Verify the order-3 weighted-mean identity and exact orders 1, 2."""
    n = q * q + q + 1
    # orders 1, 2 pointwise agreement
    o1 = Fraction(q * q, n) == uniform_avoid(q, 1)
    o2 = Fraction(q * q - q, n) == uniform_avoid(q, 2)
    # order-3 weighted mean of plane values equals uniform value
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)
    mean = (n_coll * p_coll + n_gen * p_gen) / comb(n, 3)
    o3 = mean == uniform_avoid(q, 3)
    distinct = p_coll != p_gen
    return o1 and o2 and o3 and distinct


# --------------------------------------------------------------------------- #
# Driver                                                                       #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("FULL expected coverage time E  (plane vs uniform)")
    print("=" * 70)
    for q in (2, 3):
        ep = expected_time_plane_full(q)
        eu = expected_time_uniform_full(q)
        n = q * q + q + 1
        print(f"q = {q}  (n = {n} points)")
        print(f"   E_plane   = {float(ep):.6f}")
        print(f"   E_uniform = {float(eu):.6f}")
        print(f"   plane strictly slower: {ep > eu}\n")

    print("=" * 70)
    print("ORDER-THREE TRUNCATION  E^(3) = S1 - S2 + S3  (every prime power)")
    print("=" * 70)
    print(f"{'q':>3} {'n':>5} {'surplus E3_plane - E3_uniform':>32} {'>0':>5}")
    for q in (2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 25):
        ep, eu = truncation_order3(q)
        n = q * q + q + 1
        print(f"{q:>3} {n:>5} {float(ep - eu):>32.6f} {str(ep > eu):>5}")

    print()
    print("=" * 70)
    print("IDENTITY CHECKS  (orders 1, 2 exact; order-3 weighted mean)")
    print("=" * 70)
    for q in (2, 3, 4, 5, 7, 9, 13):
        print(f"q = {q:>2}:  mean-matching & exact low orders hold: "
              f"{check_mean_matching(q)}")


if __name__ == "__main__":
    main()
