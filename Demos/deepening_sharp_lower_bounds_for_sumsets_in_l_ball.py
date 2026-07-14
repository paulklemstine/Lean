"""
Numerical demonstrations for sharp sumset lower bounds in intervals and boxes.

This self-contained script illustrates the main results:

  * The sharp one-dimensional exponent  p(n, m) = n*log(m+1) / log(n*m + 1).
  * The general exponent  q(n, M) = n*log(M) / log(1 + n*(M - 1)),  with
    q(n, m+1) = p(n, m).
  * The lower bound  (|A_1|*...*|A_n|)^{1/p} <= |A_1 + ... + A_n|  for
    A_j subset of {0, ..., m} in Z, verified against brute-force sumsets.
  * The extremal interval A_j = {0, ..., m} attaining equality.
  * Domination over the geometric-mean exponent:  p(n, m) <= n.
  * The higher-dimensional box bound in Z^d and its non-sharpness for d >= 2.

Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Iterable, List, Sequence, Tuple


# --------------------------------------------------------------------------
# Exponents
# --------------------------------------------------------------------------
def p_exp(n: int, m: int) -> float:
    """Sharp one-dimensional exponent p(n, m) = n*log(m+1) / log(n*m + 1)."""
    return n * math.log(m + 1) / math.log(n * m + 1)


def q_exp(n: int, M: float) -> float:
    """General exponent q(n, M) = n*log(M) / log(1 + n*(M - 1))."""
    return n * math.log(M) / math.log(1 + n * (M - 1))


# --------------------------------------------------------------------------
# Sumsets
# --------------------------------------------------------------------------
def sumset_1d(sets: Sequence[Iterable[int]]) -> set[int]:
    """Minkowski sum A_1 + ... + A_n of finite integer sets."""
    acc: set[int] = {0}
    for A in sets:
        acc = {a + b for a in acc for b in A}
    return acc


def sumset_nd(sets: Sequence[Iterable[Tuple[int, ...]]]) -> set[Tuple[int, ...]]:
    """Minkowski sum of finite sets of lattice points in Z^d."""
    it = iter(sets)
    acc = set(next(it))
    for A in it:
        acc = {tuple(x + y for x, y in zip(a, b)) for a in acc for b in A}
    return acc


# --------------------------------------------------------------------------
# Certified lower bounds
# --------------------------------------------------------------------------
def certified_floor(sizes: Sequence[int], M: float) -> float:
    """Certified lower bound (prod sizes)^{1/q(n, M)} on the sumset size."""
    n = len(sizes)
    prod = math.prod(sizes)
    return prod ** (1.0 / q_exp(n, M))


def cauchy_davenport_floor(sizes: Sequence[int]) -> int:
    """The additive floor  1 + sum_j (|A_j| - 1)."""
    return 1 + sum(s - 1 for s in sizes)


def geometric_mean_floor(sizes: Sequence[int]) -> float:
    """The classical geometric-mean floor  (prod sizes)^{1/n}."""
    n = len(sizes)
    return math.prod(sizes) ** (1.0 / n)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_exponent_table() -> None:
    print("=" * 70)
    print("Sharp exponent p(n,m) vs. geometric-mean exponent n")
    print("=" * 70)
    print(f"{'n':>3} {'m':>3} {'p(n,m)':>12} {'n':>6} {'p<=n?':>7}")
    for n in (1, 2, 3, 5, 10):
        for m in (1, 3, 10):
            p = p_exp(n, m)
            print(f"{n:>3} {m:>3} {p:>12.6f} {n:>6} {str(p <= n + 1e-12):>7}")
    print()


def demo_compatibility() -> None:
    print("=" * 70)
    print("Compatibility:  q(n, m+1) == p(n, m)")
    print("=" * 70)
    for n in (2, 4, 7):
        for m in (1, 5, 12):
            lhs, rhs = q_exp(n, m + 1), p_exp(n, m)
            print(f"n={n:>2} m={m:>2}:  q(n,m+1)={lhs:.8f}  p(n,m)={rhs:.8f}"
                  f"  diff={abs(lhs - rhs):.2e}")
    print()


def demo_random_verification(trials: int = 2000, seed: int = 20260714) -> None:
    print("=" * 70)
    print("Random verification of the sharp bound (dimension one)")
    print("  (prod |A_j|)^{1/p} <= |A_1 + ... + A_n|  for A_j subset {0..m}")
    print("=" * 70)
    rng = random.Random(seed)
    violations = 0
    worst_ratio = math.inf  # min of  actual / floor  ; must stay >= 1
    for _ in range(trials):
        n = rng.randint(1, 4)
        m = rng.randint(1, 8)
        universe = list(range(m + 1))
        sets: List[List[int]] = []
        for _ in range(n):
            k = rng.randint(1, m + 1)
            sets.append(rng.sample(universe, k))
        actual = len(sumset_1d(sets))
        floor = certified_floor([len(A) for A in sets], m + 1)
        ratio = actual / floor
        worst_ratio = min(worst_ratio, ratio)
        if ratio < 1 - 1e-9:
            violations += 1
    print(f"trials={trials}  violations={violations}  "
          f"tightest ratio actual/floor = {worst_ratio:.6f}  (>=1 required)")
    print()


def demo_extremal_equality() -> None:
    print("=" * 70)
    print("Extremal interval A_j = {0,...,m} attains equality")
    print("=" * 70)
    for n in (2, 3, 5):
        for m in (2, 4, 9):
            interval = list(range(m + 1))
            actual = len(sumset_1d([interval] * n))          # == n*m + 1
            floor = certified_floor([m + 1] * n, m + 1)      # == n*m + 1
            print(f"n={n} m={m}:  |sumset|={actual:>4}  "
                  f"floor={floor:>10.4f}  (expected {n*m+1})")
    print()


def demo_box_higher_dim() -> None:
    print("=" * 70)
    print("Higher-dimensional box bound in Z^d (valid, not sharp for d>=2)")
    print("=" * 70)
    for d, n, m in [(2, 2, 2), (2, 3, 2), (3, 2, 1)]:
        M = (m + 1) ** d
        # Full box as each summand: the extremal 1D shape lifted coordinatewise.
        axis = range(m + 1)
        box = [tuple(pt) for pt in itertools.product(axis, repeat=d)]
        actual = len(sumset_nd([box] * n))                   # == (n*m + 1)^d
        floor = certified_floor([len(box)] * n, M)
        print(f"d={d} n={n} m={m}:  |sumset|={actual:>6}  "
              f"box-floor={floor:>12.4f}  q={q_exp(n, M):.4f}  "
              f"slack(actual/floor)={actual/floor:.3f}")
    print("  slack > 1 shows the box exponent is NOT sharp for d >= 2.")
    print()


def demo_bound_comparison() -> None:
    print("=" * 70)
    print("Sharp floor vs. Cauchy-Davenport floor vs. geometric-mean floor")
    print("=" * 70)
    for sizes, m in [((5, 5, 5), 6), ((2, 9, 3), 9), ((4, 4, 4, 4), 4)]:
        n = len(sizes)
        cd = cauchy_davenport_floor(sizes)
        gm = geometric_mean_floor(sizes)
        sharp = certified_floor(sizes, m + 1)
        print(f"sizes={sizes} m={m}:  CD={cd:>4}  "
              f"geo-mean={gm:>8.3f}  sharp={sharp:>8.3f}")
    print()


def main() -> None:
    demo_exponent_table()
    demo_compatibility()
    demo_random_verification()
    demo_extremal_equality()
    demo_box_higher_dim()
    demo_bound_comparison()


if __name__ == "__main__":
    main()
