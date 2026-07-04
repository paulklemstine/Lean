"""
Numerical demonstrations for
"The Even Harmonic Strength of Antipodal Spherical Designs".

This self-contained script illustrates the paper's main results on the
harmonic strength Hst(X) of a finite set X of unit vectors in R^n:

  * Theorem 3.4 -- for antipodal X (X = -X) every ODD degree lies in Hst(X);
  * Theorem 4.2 -- degree 2 lies in Hst(X) iff the moment matrix
                   M_{ij} = sum_x x_i x_j equals (|X|/n) I  (isotropy);
  * Theorem 4.4 -- the degree-2 Welch bound
                   sum_{x,y} <x,y>^2 >= |X|^2 / n,
                   with equality iff 2 in Hst(X).

Only the Python standard library is used (plus optional numpy if present,
but a pure-Python fallback is provided).
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, List, Sequence, Tuple

Vector = Tuple[float, ...]


# --------------------------------------------------------------------------
# Linear-algebra helpers (pure Python, no dependencies)
# --------------------------------------------------------------------------
def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Standard Euclidean inner product <x, y>."""
    return sum(xi * yi for xi, yi in zip(x, y))


def normalize(x: Sequence[float]) -> Vector:
    """Return x / |x| as a unit vector (assumes x != 0)."""
    norm = math.sqrt(dot(x, x))
    return tuple(xi / norm for xi in x)


def moment_matrix(X: Sequence[Vector], n: int) -> List[List[float]]:
    """Moment matrix M_{ij} = sum_{x in X} x_i x_j."""
    M = [[0.0 for _ in range(n)] for _ in range(n)]
    for x in X:
        for i in range(n):
            for j in range(n):
                M[i][j] += x[i] * x[j]
    return M


# --------------------------------------------------------------------------
# The three theorem-level quantities
# --------------------------------------------------------------------------
def welch_energy(X: Sequence[Vector]) -> float:
    """Total squared correlation  E(X) = sum_{x,y in X} <x, y>^2."""
    return sum(dot(x, y) ** 2 for x in X for y in X)


def welch_bound(X: Sequence[Vector], n: int) -> float:
    """The degree-2 Welch / Sidelnikov lower bound  |X|^2 / n."""
    return len(X) ** 2 / n


def is_isotropic(X: Sequence[Vector], n: int, tol: float = 1e-9) -> bool:
    """Test M = (|X|/n) I: off-diagonals ~0 and diagonals all equal |X|/n."""
    M = moment_matrix(X, n)
    target = len(X) / n
    for i in range(n):
        for j in range(n):
            expected = target if i == j else 0.0
            if abs(M[i][j] - expected) > tol:
                return False
    return True


def odd_degree_sum(
    X: Sequence[Vector], p: Callable[[Vector], float]
) -> float:
    """sum_{x in X} p(x) for a test polynomial p (used to check Thm 3.4)."""
    return sum(p(x) for x in X)


# --------------------------------------------------------------------------
# Example antipodal configurations
# --------------------------------------------------------------------------
def cross_polytope(n: int) -> List[Vector]:
    """Vertices {+-e_i}: the standard cross-polytope in R^n (antipodal)."""
    pts: List[Vector] = []
    for i in range(n):
        e = [0.0] * n
        e[i] = 1.0
        pts.append(tuple(e))
        f = [0.0] * n
        f[i] = -1.0
        pts.append(tuple(f))
    return pts


def antipodal_pair(v: Sequence[float]) -> List[Vector]:
    """The two-point antipodal set {v, -v} with v normalized."""
    u = normalize(v)
    return [u, tuple(-ui for ui in u)]


def random_antipodal(n: int, pairs: int, seed: int = 0) -> List[Vector]:
    """A random antipodal set: `pairs` random unit vectors and their negatives."""
    rng = random.Random(seed)
    pts: List[Vector] = []
    for _ in range(pairs):
        v = normalize(tuple(rng.gauss(0.0, 1.0) for _ in range(n)))
        pts.append(v)
        pts.append(tuple(-vi for vi in v))
    return pts


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_odd_degrees_free() -> None:
    """Theorem 3.4: odd homogeneous forms sum to zero over antipodal sets."""
    print("=" * 70)
    print("Theorem 3.4  --  Every ODD degree is free for antipodal sets")
    print("=" * 70)

    X = random_antipodal(n=3, pairs=4, seed=42)

    # Some homogeneous test polynomials of various degrees.
    tests = [
        (1, "x0",             lambda x: x[0]),
        (3, "x0^3",           lambda x: x[0] ** 3),
        (3, "x0 x1 x2",       lambda x: x[0] * x[1] * x[2]),
        (5, "x0^5",           lambda x: x[0] ** 5),
        (2, "x0^2",           lambda x: x[0] ** 2),   # EVEN: need NOT vanish
        (4, "x0^4",           lambda x: x[0] ** 4),   # EVEN: need NOT vanish
    ]
    for deg, name, p in tests:
        s = odd_degree_sum(X, p)
        parity = "odd " if deg % 2 == 1 else "even"
        note = "-> 0 (guaranteed)" if deg % 2 == 1 else "(not forced to 0)"
        print(f"  deg {deg} [{parity}]  sum of {name:<10} = {s:+.6e}  {note}")
    print()


def demo_degree_two_isotropy() -> None:
    """Theorem 4.2: degree 2 in Hst(X) iff the moment matrix is isotropic."""
    print("=" * 70)
    print("Theorem 4.2  --  Degree 2 in Hst(X)  <=>  M = (|X|/n) I")
    print("=" * 70)

    n = 3
    good = cross_polytope(n)              # isotropic -> 2 in Hst
    bad = antipodal_pair((1.0, 0.0, 0.0))  # a single axis -> NOT isotropic

    for label, X in [("cross-polytope {+-e_i}", good),
                     ("antipodal pair {+-e_0}", bad)]:
        M = moment_matrix(X, n)
        iso = is_isotropic(X, n)
        print(f"  {label}:  |X| = {len(X)}")
        for row in M:
            print("      [" + "  ".join(f"{v:+.3f}" for v in row) + "]")
        print(f"      isotropic (2 in Hst)? {iso}")
        print()


def demo_welch_bound() -> None:
    """Theorem 4.4: Welch bound and equality iff 2 in Hst(X)."""
    print("=" * 70)
    print("Theorem 4.4  --  Welch bound  sum <x,y>^2 >= |X|^2 / n")
    print("=" * 70)

    n = 3
    configs = [
        ("cross-polytope {+-e_i}", cross_polytope(n)),
        ("antipodal pair {+-e_0}", antipodal_pair((1.0, 0.0, 0.0))),
        ("random antipodal (4 pairs)", random_antipodal(n, 4, seed=7)),
    ]
    for label, X in configs:
        E = welch_energy(X)
        B = welch_bound(X, n)
        defect = E - B
        eq = is_isotropic(X, n)
        print(f"  {label}:")
        print(f"      energy sum <x,y>^2 = {E:.6f}")
        print(f"      bound |X|^2 / n    = {B:.6f}")
        print(f"      Welch defect       = {defect:.6e}"
              f"   (equality: {eq})")
        print()


def demo_energy_identity() -> None:
    """Lemma 4.3: sum_{x,y} <x,y>^2 = sum_{i,j} M_{ij}^2 (cross-check)."""
    print("=" * 70)
    print("Lemma 4.3  --  sum_{x,y} <x,y>^2 = sum_{i,j} M_{ij}^2")
    print("=" * 70)
    n = 4
    X = random_antipodal(n, 5, seed=123)
    lhs = welch_energy(X)
    M = moment_matrix(X, n)
    rhs = sum(M[i][j] ** 2 for i in range(n) for j in range(n))
    print(f"  sum_{{x,y}} <x,y>^2 = {lhs:.6f}")
    print(f"  sum_{{i,j}} M_ij^2 = {rhs:.6f}")
    print(f"  match: {math.isclose(lhs, rhs, rel_tol=1e-9)}")
    print()


def main() -> None:
    demo_odd_degrees_free()
    demo_degree_two_isotropy()
    demo_welch_bound()
    demo_energy_identity()


if __name__ == "__main__":
    main()
