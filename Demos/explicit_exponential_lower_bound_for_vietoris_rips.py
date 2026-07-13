"""
Numerical demonstration of the exponential lower bound for Vietoris-Rips
approximations below the sqrt(2) threshold.

This script is fully self-contained (standard library only). It illustrates:

  1. The equidistant configuration realised by the standard basis of R^n, whose
     pairwise distances are all exactly sqrt(2).
  2. The Vietoris-Rips complex of that configuration: the full power set (2^n
     simplices) at scale r >= d, and only n+1 simplices at scale r < d -- a
     single exponential cliff at r = d.
  3. The forced lower bound |G(c*d)| >= 2^n for every c-approximation G.
  4. The threshold exponent gamma(c) = 1/2 - log2(c): positive on [1, sqrt2),
     bounded by 1, and vanishing as c -> sqrt(2)^-.
  5. The headline floor 2^(gamma(c) * n) and its relation to the uniform 2^n
     bound.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Dict, Iterable, List, Tuple


# --------------------------------------------------------------------------- #
# 1. The equidistant configuration and its Euclidean realisation
# --------------------------------------------------------------------------- #

def standard_basis(n: int) -> List[Tuple[float, ...]]:
    """Return the n standard basis vectors of R^n as tuples of floats."""
    return [tuple(1.0 if i == k else 0.0 for i in range(n)) for k in range(n)]


def euclidean_distance(u: Tuple[float, ...], v: Tuple[float, ...]) -> float:
    """Ordinary Euclidean distance between two vectors of equal length."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(u, v)))


def equi_dissimilarity(i: int, j: int, d: float) -> float:
    """The equidistant dissimilarity: 0 on the diagonal, d off it."""
    return 0.0 if i == j else d


def verify_standard_basis_is_equidistant(n: int) -> bool:
    """Check that the standard basis realises the equidistant metric with d=sqrt2."""
    basis = standard_basis(n)
    d = math.sqrt(2.0)
    for i in range(n):
        for j in range(n):
            realised = euclidean_distance(basis[i], basis[j])
            target = equi_dissimilarity(i, j, d)
            if not math.isclose(realised, target, abs_tol=1e-12):
                return False
    return True


# --------------------------------------------------------------------------- #
# 2. The Vietoris-Rips complex of the equidistant configuration
# --------------------------------------------------------------------------- #

def is_vr_simplex(subset: Tuple[int, ...], d: float, r: float) -> bool:
    """A subset is a VR simplex at scale r iff all pairwise distances are <= r."""
    for i, j in itertools.combinations(subset, 2):
        if equi_dissimilarity(i, j, d) > r:
            return False
    return True


def vr_complex(n: int, d: float, r: float) -> List[Tuple[int, ...]]:
    """Enumerate all VR simplices of the equidistant configuration at scale r.

    (Exponential in n by construction -- kept small for demonstration.)
    """
    points = range(n)
    simplices: List[Tuple[int, ...]] = []
    for k in range(n + 1):
        for subset in itertools.combinations(points, k):
            if is_vr_simplex(subset, d, r):
                simplices.append(subset)
    return simplices


def vr_complex_size(n: int, d: float, r: float) -> int:
    """Number of simplices of the equidistant VR complex at scale r."""
    return len(vr_complex(n, d, r))


# --------------------------------------------------------------------------- #
# 3. The threshold exponent
# --------------------------------------------------------------------------- #

def gamma(c: float) -> float:
    """Threshold exponent gamma(c) = 1/2 - log2(c)."""
    return 0.5 - math.log2(c)


def headline_floor(c: float, n: int) -> float:
    """The guaranteed lower bound 2^(gamma(c) * n) on some approximation level."""
    return 2.0 ** (gamma(c) * n)


# --------------------------------------------------------------------------- #
# 4. Demonstrations
# --------------------------------------------------------------------------- #

def demo_euclidean_realisation() -> None:
    print("=" * 70)
    print("1. Euclidean realisation: standard basis is equidistant at sqrt(2)")
    print("=" * 70)
    for n in range(2, 7):
        ok = verify_standard_basis_is_equidistant(n)
        print(f"  n={n}: standard basis pairwise distances all = sqrt(2)?  {ok}")
    print()


def demo_single_cliff() -> None:
    print("=" * 70)
    print("2. The single exponential cliff of VR(equi_d) at r = d  (d = sqrt2)")
    print("=" * 70)
    d = math.sqrt(2.0)
    print(f"  {'n':>3} | {'size (r<d)':>12} | {'n+1':>6} | "
          f"{'size (r>=d)':>12} | {'2^n':>8}")
    print("  " + "-" * 58)
    for n in range(1, 9):
        below = vr_complex_size(n, d, r=d - 0.1)
        above = vr_complex_size(n, d, r=d + 0.1)
        print(f"  {n:>3} | {below:>12} | {n + 1:>6} | "
              f"{above:>12} | {2 ** n:>8}")
    print("  The size is n+1 below the gap and jumps to 2^n at the gap.")
    print()


def demo_lower_bound() -> None:
    print("=" * 70)
    print("3. Forced lower bound: any c-approximation G has |G(c*d)| >= 2^n")
    print("=" * 70)
    d = math.sqrt(2.0)
    print("  By the interleaving axiom VR(d) <= G(c*d); since VR(d) is the full")
    print("  power set, |G(c*d)| >= |VR(d)| = 2^n, uniformly in c.\n")
    print(f"  {'n':>3} | {'|VR(d)| = 2^n':>14} | forced lower bound on |G(c*d)|")
    print("  " + "-" * 52)
    for n in range(1, 11):
        vr = vr_complex_size(n, d, r=d)
        print(f"  {n:>3} | {vr:>14} | >= {vr}")
    print()


def demo_threshold_exponent() -> None:
    print("=" * 70)
    print("4. The threshold exponent gamma(c) = 1/2 - log2(c)")
    print("=" * 70)
    sqrt2 = math.sqrt(2.0)
    cs = [1.0, 1.05, 1.1, 1.2, 1.3, 1.4, 1.41, 1.414, sqrt2 - 1e-9]
    print(f"  {'c':>10} | {'gamma(c)':>12} | {'positive?':>10} | {'<= 1?':>6}")
    print("  " + "-" * 48)
    for c in cs:
        g = gamma(c)
        print(f"  {c:>10.6f} | {g:>12.6f} | {str(g > 0):>10} | "
              f"{str(g <= 1 + 1e-12):>6}")
    print(f"\n  gamma(sqrt2) = {gamma(sqrt2):.6f}  (exactly 0 at the threshold)")
    print("  As c -> sqrt(2)^-, gamma(c) -> 0.\n")


def demo_headline_floor() -> None:
    print("=" * 70)
    print("5. Headline floor 2^(gamma(c) * n) <= 2^n for several c and n")
    print("=" * 70)
    cs = [1.0, 1.1, 1.25, 1.4]
    ns = [10, 20, 50, 100]
    header = "  c \\ n   " + "".join(f"{n:>16}" for n in ns)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for c in cs:
        g = gamma(c)
        row = f"  c={c:<5.2f}"
        for n in ns:
            row += f"{headline_floor(c, n):>16.3e}"
        print(row + f"   (gamma={g:.4f})")
    print("\n  Every entry is a rigorous lower bound on some level's simplex count,")
    print("  and each is <= 2^n (the uniform bound), consistent with gamma(c) <= 1.")
    print()


def main() -> None:
    demo_euclidean_realisation()
    demo_single_cliff()
    demo_lower_bound()
    demo_threshold_exponent()
    demo_headline_floor()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
