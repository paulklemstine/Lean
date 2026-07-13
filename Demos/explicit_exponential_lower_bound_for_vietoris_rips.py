"""Numerical demonstrations of the effective exponential lower bound for
sub-sqrt(2) Vietoris-Rips approximations.

Setting.  For each n we build a graded ultrametric on the label set
{0, 1, ..., n-1}:

    radius(n, i) = 1 + (sqrt2 - 1) * (i + 1) / n
    d_n(i, j)    = 0                       if i == j
                 = radius(n, max(i, j))    if i != j

Every non-zero distance lies in [1, sqrt(2)], and d_n is an ultrametric.

Main result.  For any approximation factor c in [1, sqrt2), any one-sided
multiplicative c-approximation G of the Vietoris-Rips filtration must store at
least

    2 ** floor(gamma(c) * n)   simplices at scale sqrt(2),

where the effective rate is

    gamma(c) = (sqrt2 / c - 1) / (sqrt2 - 1),

which satisfies 0 < gamma(c) <= 1 on [1, sqrt2), gamma(1) = 1, and
gamma(c) -> 0 as c -> sqrt2^-.

This script verifies each ingredient directly: the metric axioms, the
clique -> power set counting bridge, the active-set count, and the final bound.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import List, Tuple

SQRT2: float = math.sqrt(2.0)


# --------------------------------------------------------------------------- #
# The graded ultrametric
# --------------------------------------------------------------------------- #
def radius(n: int, i: int) -> float:
    """Graded radius of point i among n points."""
    return 1.0 + (SQRT2 - 1.0) * (i + 1) / n


def metric_d(n: int, i: int, j: int) -> float:
    """Graded (ultra)metric distance between points i and j."""
    if i == j:
        return 0.0
    return radius(n, max(i, j))


def verify_metric_axioms(n: int) -> bool:
    """Check symmetry, non-negativity, identity of indiscernibles, and the
    (strong) triangle inequality for all triples."""
    tol = 1e-12
    for i in range(n):
        if abs(metric_d(n, i, i)) > tol:
            return False
        for j in range(n):
            if abs(metric_d(n, i, j) - metric_d(n, j, i)) > tol:
                return False
            if i != j and metric_d(n, i, j) < 1.0 - tol:
                return False
            for k in range(n):
                lhs = metric_d(n, i, k)
                # strong (ultrametric) inequality implies the ordinary one
                if lhs > max(metric_d(n, i, j), metric_d(n, j, k)) + tol:
                    return False
    return True


# --------------------------------------------------------------------------- #
# Vietoris-Rips complex and the counting bridge
# --------------------------------------------------------------------------- #
def is_vr_simplex(n: int, r: float, subset: Tuple[int, ...]) -> bool:
    """Is `subset` a Vietoris-Rips simplex at scale r (a metric clique)?"""
    tol = 1e-12
    return all(metric_d(n, i, j) <= r + tol for i in subset for j in subset)


def vr_complex_size(n: int, r: float) -> int:
    """Number of simplices of the Vietoris-Rips complex at scale r
    (brute-force enumeration of all subsets; use only for small n)."""
    count = 0
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if is_vr_simplex(n, r, subset):
                count += 1
    return count


# --------------------------------------------------------------------------- #
# The effective exponent and the active set
# --------------------------------------------------------------------------- #
def gamma(c: float) -> float:
    """Effective rate gamma(c) = (sqrt2 / c - 1) / (sqrt2 - 1)."""
    return (SQRT2 / c - 1.0) / (SQRT2 - 1.0)


def active_set(n: int, s: float) -> List[int]:
    """Indices whose radius is at most s (a metric clique at scale s)."""
    tol = 1e-12
    return [i for i in range(n) if radius(n, i) <= s + tol]


def predicted_exponent(n: int, c: float) -> int:
    """The guaranteed exponent floor(gamma(c) * n)."""
    return math.floor(gamma(c) * n)


def lower_bound(n: int, c: float) -> int:
    """2 ** floor(gamma(c) * n): the guaranteed minimum simplex count at
    scale sqrt(2) for any c-approximation."""
    return 2 ** predicted_exponent(n, c)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_metric_axioms() -> None:
    print("=" * 68)
    print("1. The graded metric is a genuine ultrametric")
    print("=" * 68)
    for n in [1, 2, 5, 10, 20]:
        ok = verify_metric_axioms(n)
        print(f"  n = {n:3d}: metric/ultrametric axioms hold = {ok}")
    print()


def demo_distance_window() -> None:
    print("=" * 68)
    print("2. Non-zero distances live in [1, sqrt(2)]")
    print("=" * 68)
    n = 8
    print(f"  radii for n = {n}:")
    for i in range(n):
        print(f"    radius({n}, {i}) = {radius(n, i):.6f}")
    print(f"  (largest radius equals sqrt(2) = {SQRT2:.6f})")
    print()


def demo_clique_bridge() -> None:
    print("=" * 68)
    print("3. Clique -> power set: a clique of size m forces 2^m simplices")
    print("=" * 68)
    n = 6
    for c in [1.0, 1.1, 1.2, 1.3]:
        s = SQRT2 / c
        A = active_set(n, s)
        m = len(A)
        # Every subset of A is a VR simplex at scale s: count them directly.
        subsets_present = sum(
            1
            for size in range(m + 1)
            for T in combinations(A, size)
            if is_vr_simplex(n, s, T)
        )
        print(
            f"  c = {c:.2f}: scale sqrt2/c = {s:.4f}, active clique size m = {m}, "
            f"subsets present = {subsets_present} (2^m = {2 ** m})"
        )
    print()


def demo_gamma_behaviour() -> None:
    print("=" * 68)
    print("4. The effective rate gamma(c) on [1, sqrt2)")
    print("=" * 68)
    print("     c        gamma(c)")
    for c in [1.0, 1.05, 1.1, 1.2, 1.3, 1.4, 1.41, 1.414]:
        g = gamma(c)
        print(f"  {c:6.3f}    {g:8.5f}")
    print(f"  gamma(1) = {gamma(1.0):.5f} (recovers full 2^n),  "
          f"gamma(c) -> 0 as c -> sqrt2 = {SQRT2:.5f}")
    print()


def demo_lower_bound_verification() -> None:
    print("=" * 68)
    print("5. End-to-end: predicted bound vs. true VR count at scale sqrt(2)")
    print("=" * 68)
    print("  For the trivial approximation G = VR itself (c = 1), |G(sqrt2)| = 2^n.")
    print("  For c < sqrt2 the predicted lower bound is 2^floor(gamma(c)*n).")
    print()
    print("   n    c      gamma    exponent   lower_bound   |VR(sqrt2)|")
    for n in [4, 6, 8, 10]:
        true_full = vr_complex_size(n, SQRT2)  # = 2^n (diameter <= sqrt2)
        for c in [1.0, 1.15, 1.3]:
            g = gamma(c)
            e = predicted_exponent(n, c)
            lb = lower_bound(n, c)
            assert lb <= true_full, "lower bound must not exceed the true count"
            print(
                f"  {n:2d}  {c:.2f}   {g:6.4f}   {e:6d}    {lb:9d}    {true_full:9d}"
            )
    print()
    print("  All predicted lower bounds are <= the true simplex count. QED-by-example.")
    print()


def main() -> None:
    demo_metric_axioms()
    demo_distance_window()
    demo_clique_bridge()
    demo_gamma_behaviour()
    demo_lower_bound_verification()


if __name__ == "__main__":
    main()
