"""
Numerical demonstrations for:

    Sharp Lower Bounds for Sumsets in L1 Balls in Z^d

This self-contained script illustrates the main results:

  * the iterated Cauchy-Davenport additive bound,
  * the multiplicative and geometric-mean sumset bounds,
  * validity of the geometric-mean bound at every exponent q >= n,
  * the transcendental sharp exponent p = n*log(m+1)/log(nm+1) and the
    bracket 1 < p < n,
  * the extremal interval configuration attaining equality,
  * the cross-polytope geometry (radius-1 count 2d+1, dilation containment).

Run:  python demo.py
"""

from __future__ import annotations

import math
from itertools import product
from typing import Iterable, List, Set, Tuple

Vector = Tuple[int, ...]


# --------------------------------------------------------------------------
# Core combinatorial primitives
# --------------------------------------------------------------------------
def minkowski_sum(a: Iterable[Vector], b: Iterable[Vector]) -> Set[Vector]:
    """Pointwise (Minkowski) sum of two finite sets of integer vectors."""
    a = list(a)
    b = list(b)
    return {
        tuple(ai + bi for ai, bi in zip(u, v))
        for u in a
        for v in b
    }


def iterated_sumset(sets: List[Set[Vector]]) -> Set[Vector]:
    """The n-fold sumset A_1 + ... + A_n."""
    if not sets:
        raise ValueError("need at least one set")
    acc = set(sets[0])
    for s in sets[1:]:
        acc = minkowski_sum(acc, s)
    return acc


def l1_norm(x: Vector) -> int:
    """The taxicab (L1) norm sum |x_i|."""
    return sum(abs(c) for c in x)


def l1_ball(d: int, m: int) -> Set[Vector]:
    """All lattice points x in Z^d with |x_1| + ... + |x_d| <= m."""
    rng = range(-m, m + 1)
    return {x for x in product(rng, repeat=d) if l1_norm(x) <= m}


# --------------------------------------------------------------------------
# The sharp exponent and its bracket
# --------------------------------------------------------------------------
def sharp_exponent(n: int, m: int) -> float:
    """p(n, m) = n * log(m + 1) / log(n*m + 1)."""
    return n * math.log(m + 1) / math.log(n * m + 1)


def bracket_certificate(n: int, m: int) -> Tuple[bool, bool]:
    """
    Return (p_gt_1, p_lt_n) certified by *exact integer* comparisons:
      p > 1  <=>  n*m + 1 < (m + 1)^n
      p < n  <=>  m + 1   < n*m + 1
    """
    p_gt_1 = (n * m + 1) < (m + 1) ** n
    p_lt_n = (m + 1) < (n * m + 1)
    return p_gt_1, p_lt_n


# --------------------------------------------------------------------------
# Bound evaluations
# --------------------------------------------------------------------------
def geometric_mean_bound(sizes: List[int], q: float) -> float:
    """The claimed lower bound (prod sizes)^(1/q)."""
    prod = 1
    for s in sizes:
        prod *= s
    return prod ** (1.0 / q)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_additive_and_multiplicative() -> None:
    print("=" * 70)
    print("Additive (Cauchy-Davenport) and multiplicative bounds in Z (d=1)")
    print("=" * 70)
    A1 = {(0,), (2,), (5,)}
    A2 = {(0,), (1,), (3,), (7,)}
    A3 = {(0,), (4,)}
    sets = [A1, A2, A3]
    S = iterated_sumset(sets)
    n = len(sets)
    sizes = [len(a) for a in sets]
    print(f"|A_j| = {sizes},   |sumset| = {len(S)}")
    lhs = sum(sizes) + 1
    rhs = len(S) + n
    print(f"Additive:      sum|A_j| + 1 = {lhs}  <=  |sumset| + n = {rhs}   "
          f"{'OK' if lhs <= rhs else 'FAIL'}")
    prod = math.prod(sizes)
    print(f"Multiplicative: prod|A_j| = {prod}  <=  |sumset|^n = {len(S) ** n}   "
          f"{'OK' if prod <= len(S) ** n else 'FAIL'}")
    print()


def demo_exponent_monotonicity() -> None:
    print("=" * 70)
    print("Geometric-mean bound holds for every exponent q >= n")
    print("=" * 70)
    A1 = {(0,), (1,), (4,)}
    A2 = {(0,), (2,), (3,), (9,)}
    sets = [A1, A2]
    S = iterated_sumset(sets)
    n = len(sets)
    sizes = [len(a) for a in sets]
    print(f"|A_j| = {sizes},  |sumset| = {len(S)},  n = {n}")
    for q in [n, n + 0.5, n + 1.0, 2 * n, 5 * n]:
        bound = geometric_mean_bound(sizes, q)
        ok = bound <= len(S) + 1e-9
        print(f"  q = {q:5.1f}:  (prod)^(1/q) = {bound:7.4f}  <=  |sumset| = {len(S)}"
              f"   {'OK' if ok else 'FAIL'}")
    print()


def demo_sharp_exponent() -> None:
    print("=" * 70)
    print("Sharp exponent p = n*log(m+1)/log(nm+1) and bracket 1 < p < n")
    print("=" * 70)
    for n, m in [(2, 1), (2, 3), (3, 2), (5, 4), (10, 10)]:
        p = sharp_exponent(n, m)
        g1, ln = bracket_certificate(n, m)
        equality = (m + 1) ** (n / p)  # should equal n*m + 1
        print(f"  n={n:2d}, m={m:2d}:  p = {p:7.4f}   "
              f"(1 < p: {g1}, p < n: {ln})   "
              f"(m+1)^(n/p) = {equality:8.4f}  (target nm+1 = {n * m + 1})")
    print()


def demo_extremal_interval() -> None:
    print("=" * 70)
    print("Extremal configuration A_j = {0,...,m} attains equality (d=1)")
    print("=" * 70)
    for n, m in [(2, 3), (3, 2), (4, 5)]:
        A = set((i,) for i in range(m + 1))
        sets = [set(A) for _ in range(n)]
        S = iterated_sumset(sets)
        p = sharp_exponent(n, m)
        prod = (m + 1) ** n
        bound = prod ** (1.0 / p)
        print(f"  n={n}, m={m}: |A_j|={m + 1}, |sumset|={len(S)} (=nm+1={n * m + 1}); "
              f"additive eq: {sum([m + 1] * n) + 1 == len(S) + n}; "
              f"sharp eq: (prod)^(1/p)={bound:.4f} vs |sumset|={len(S)}")
    print()


def demo_geometry() -> None:
    print("=" * 70)
    print("Cross-polytope geometry: |B_1^d| = 2d+1 and dilation containment")
    print("=" * 70)
    for d in range(0, 5):
        b1 = l1_ball(d, 1)
        print(f"  d={d}: |B_1^d| = {len(b1)}   (predicted 2d+1 = {2 * d + 1})   "
              f"{'OK' if len(b1) == 2 * d + 1 else 'FAIL'}")
    print()
    # Dilation: sum of two sets inside radius-m ball lands in radius-2m ball.
    d, m = 2, 2
    ball = l1_ball(d, m)
    B = {x for i, x in enumerate(sorted(ball)) if i % 3 == 0}
    C = {x for i, x in enumerate(sorted(ball)) if i % 2 == 0}
    S = minkowski_sum(B, C)
    inside = all(l1_norm(x) <= 2 * m for x in S)
    print(f"  d={d}, m={m}: B+C subset of B_(2m)^d ? {'OK' if inside else 'FAIL'} "
          f"(|B|={len(B)}, |C|={len(C)}, |B+C|={len(S)}, max norm={max(l1_norm(x) for x in S)})")
    print()


def main() -> None:
    demo_additive_and_multiplicative()
    demo_exponent_monotonicity()
    demo_sharp_exponent()
    demo_extremal_interval()
    demo_geometry()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
