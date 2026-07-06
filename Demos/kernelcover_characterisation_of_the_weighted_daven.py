"""
Numerical demonstrations for the kernel-cover characterization of the
weighted Davenport constant.

The weighted Davenport bound "D_Psi(G) <= n" is equivalent to the statement
that the kernels of the induced universal homomorphisms

        Phi_phi(x) = sum_i phi_i(x_i)

cover the whole space F^n, where each coordinate weight phi_i is either the
skip weight 0 or a genuine weight from the weight set W, and at least one
coordinate carries a genuine weight.

This file works entirely with finite abelian groups modelled as Z/m and with
finite fields F_p (p prime), representing homomorphisms Z/m -> Z/m as
"multiply by a fixed constant" maps.  Everything is self-contained and uses
only the Python standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Core building block: does a length-n sequence over Z/m have a non-empty
# zero-sum subsequence?  This is the classical (single-weight, identity) case.
# ----------------------------------------------------------------------------
def has_zero_sum_subsequence(seq: Sequence[int], m: int) -> bool:
    """Return True iff some non-empty subset of `seq` sums to 0 modulo m.

    Uses the partial-sum / pigeonhole idea: track the set of achievable
    subset-sums as we scan.  For clarity (not speed) we use a reachable-set DP.
    """
    reachable: set[int] = set()
    for value in seq:
        v = value % m
        new_reachable = {v}
        for r in reachable:
            new_reachable.add((r + v) % m)
        reachable |= new_reachable
        if 0 in reachable:
            return True
    return 0 in reachable


def classical_kernel_cover(n: int, m: int) -> bool:
    """Return True iff every length-n sequence over Z/m has a non-empty
    zero-sum subsequence (i.e. the kernel-cover property holds at level n
    for the single-weight set {id})."""
    for seq in product(range(m), repeat=n):
        if not has_zero_sum_subsequence(seq, m):
            return False
    return True


def davenport_constant_cyclic(m: int, search_limit: int | None = None) -> int:
    """Compute D(Z/m) as the least n with the kernel-cover property.

    By the Cyclic Davenport Theorem this equals m; the function verifies it
    by brute force.  `search_limit` caps the search (defaults to m + 1)."""
    limit = search_limit if search_limit is not None else m + 1
    for n in range(1, limit + 1):
        if classical_kernel_cover(n, m):
            return n
    raise RuntimeError("no threshold found within search_limit")


# ----------------------------------------------------------------------------
# General weighted kernel-cover check over Z/m with a finite weight set.
#
# A homomorphism Z/m -> Z/m is "multiply by c" for some c in Z/m.  A weight
# set W is a list of such constants c (all non-zero to be genuine weights).
# The skip weight is c = 0.
# ----------------------------------------------------------------------------
def induced_hom_value(coeffs: Sequence[int], x: Sequence[int], m: int) -> int:
    """Evaluate Phi_phi(x) = sum_i coeffs[i] * x[i]  (mod m)."""
    return sum((c * xi) for c, xi in zip(coeffs, x)) % m


def is_admissible(coeffs: Sequence[int], weight_set: Sequence[int]) -> bool:
    """A choice (list of coefficients) is admissible if each coefficient is
    0 (skip) or a genuine weight in `weight_set`, and at least one is non-zero.
    """
    allowed = {0, *weight_set}
    if any(c not in allowed for c in coeffs):
        return False
    return any(c != 0 for c in coeffs)


def weighted_kernel_cover(n: int, m: int, weight_set: Sequence[int]) -> bool:
    """Return True iff the weighted kernel-cover property holds at level n:
    every x in (Z/m)^n is annihilated by some admissible induced homomorphism.
    """
    allowed_coeffs: List[int] = [0, *weight_set]
    admissible_choices: List[Tuple[int, ...]] = [
        c for c in product(allowed_coeffs, repeat=n) if is_admissible(c, weight_set)
    ]
    for x in product(range(m), repeat=n):
        if not any(induced_hom_value(c, x, m) == 0 for c in admissible_choices):
            return False
    return True


def weighted_davenport_constant(
    m: int, weight_set: Sequence[int], search_limit: int = 12
) -> int:
    """Least n at which the weighted kernel-cover property holds over Z/m."""
    for n in range(1, search_limit + 1):
        if weighted_kernel_cover(n, m, weight_set):
            return n
    raise RuntimeError("no threshold found within search_limit")


# ----------------------------------------------------------------------------
# Finite-field / hyperplane instance: F = G = F_p, weights = F_p^* (all non-zero
# scalars).  Admissible induced homs are non-zero linear functionals; kernels
# are hyperplanes.  The kernel-cover property = "these hyperplanes cover F_p^n".
# ----------------------------------------------------------------------------
def hyperplane_cover_holds(n: int, p: int) -> bool:
    """Return True iff the non-zero linear functionals on F_p^n cover the space
    (this holds for every n >= 1 since 0 is on every hyperplane and any non-zero
    vector lies on some hyperplane through the origin)."""
    weight_set = list(range(1, p))  # F_p^* = {1, ..., p-1}
    return weighted_kernel_cover(n, p, weight_set)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_cyclic_davenport(max_m: int = 6) -> None:
    print("=" * 68)
    print("Cyclic Davenport constant  D(Z/m) = m")
    print("=" * 68)
    for m in range(1, max_m + 1):
        d = davenport_constant_cyclic(m)
        witness = tuple(1 for _ in range(m - 1)) if m >= 2 else ()
        print(f"  m = {m:2d}:  D(Z/m) = {d:2d}   (matches m: {d == m})"
              f"   extremal length-{m-1} sequence with no zero-sum: {witness}")
    print()


def demo_bridge(m: int = 4, n: int = 4) -> None:
    print("=" * 68)
    print("Bridge: {id}-weighted kernel-cover == classical zero-sum property")
    print("=" * 68)
    for k in range(1, n + 1):
        cover = classical_kernel_cover(k, m)
        # The weight set {id} over Z/m is the single genuine weight c = 1.
        weighted = weighted_kernel_cover(k, m, weight_set=[1])
        print(f"  Z/{m}, level n={k}:  classical={cover}   weighted({{1}})={weighted}"
              f"   agree: {cover == weighted}")
    print()


def demo_weight_set_monotone(m: int = 6) -> None:
    print("=" * 68)
    print("Enlarging the weight set can only lower the Davenport constant")
    print("=" * 68)
    small: List[int] = [1]
    large: List[int] = [1, 2, 3, 4, 5]  # more scalars available
    d_small = weighted_davenport_constant(m, small)
    d_large = weighted_davenport_constant(m, large)
    print(f"  Z/{m}, weights {{1}}          : D = {d_small}")
    print(f"  Z/{m}, weights {{1,2,3,4,5}}  : D = {d_large}")
    print(f"  monotone (larger set gives <= constant): {d_large <= d_small}")
    print()


def demo_hyperplane(p: int = 3, max_n: int = 3) -> None:
    print("=" * 68)
    print(f"Finite-field instance over F_{p}: hyperplanes cover F_{p}^n")
    print("=" * 68)
    for n in range(1, max_n + 1):
        holds = hyperplane_cover_holds(n, p)
        print(f"  n = {n}:  non-zero functionals cover F_{p}^{n} : {holds}")
    print("  (over a field a single non-zero functional annihilates only 0, so"
          " level 1 fails; from level 2 on the origin-hyperplanes cover F_p^n.)")
    print()


def main() -> None:
    demo_cyclic_davenport(max_m=6)
    demo_bridge(m=4, n=4)
    demo_weight_set_monotone(m=6)
    demo_hyperplane(p=3, max_n=3)


if __name__ == "__main__":
    main()
