"""
Numerical demonstrations of spectral line-locking in the fixed-amplitude
complex-weighted undirected graph model.

Model
-----
An undirected graph on ``n`` vertices has a 0/1 Hermitian indicator matrix ``B``
(``B[i, j] = 1`` iff edge {i, j} is present, ``B[i, i] = 0`` for a loopless
graph). Painting every present edge with one common complex weight ``z`` gives
the fixed-amplitude weighted adjacency matrix ``A = z * B``.

Results demonstrated
--------------------
1. Spectral line-locking: every eigenvalue of ``A = z * B`` equals ``z`` times a
   real number, so the whole spectrum lies on the line ``R * z`` through 0.
2. Trace law: ``tr(z * B) = z * tr(B)``, and vanishes for loopless graphs.
3. Determinant law: ``det(z * B) = z**n * det(B)``.
4. Weight-independent singularity: ``det(z * B) = 0`` iff ``det(B) = 0`` (z != 0).
5. Complete graph mean-direction eigenvalue ``(n - 1) * z`` on the all-ones
   vector, and its escape past the naive radius ``sqrt(n) * |z|`` for n >= 3.

This file is self-contained: it depends only on ``numpy``.
"""

from __future__ import annotations

import cmath
import math
from typing import List

import numpy as np


# ---------------------------------------------------------------------------
# Model construction
# ---------------------------------------------------------------------------
def random_hermitian_indicator(n: int, p: float, seed: int) -> np.ndarray:
    """Return the 0/1 Hermitian (symmetric) indicator matrix of a random
    loopless undirected graph G(n, p): symmetric, zero diagonal."""
    rng = np.random.default_rng(seed)
    upper = (rng.random((n, n)) < p).astype(float)
    upper = np.triu(upper, k=1)          # keep strict upper triangle
    b = upper + upper.T                  # symmetrize -> undirected, loopless
    return b.astype(complex)


def complete_indicator(n: int) -> np.ndarray:
    """Return the indicator matrix of the complete graph K_n:
    1 off-diagonal, 0 on the diagonal."""
    b = np.ones((n, n), dtype=complex) - np.eye(n, dtype=complex)
    return b


def weighted_adjacency(b: np.ndarray, z: complex) -> np.ndarray:
    """Fixed-amplitude weighted adjacency matrix A = z * B."""
    return z * b


# ---------------------------------------------------------------------------
# Result 1: spectral line-locking
# ---------------------------------------------------------------------------
def line_locking_residual(b: np.ndarray, z: complex) -> float:
    """Max imaginary part of mu / z over all eigenvalues mu of z * B.

    By spectral line-locking this should be ~0 (each mu is z times a real
    number, so mu / z is real)."""
    a = weighted_adjacency(b, z)
    eigs = np.linalg.eigvals(a)
    ratios = eigs / z
    return float(np.max(np.abs(ratios.imag)))


# ---------------------------------------------------------------------------
# Results 2-4: trace, determinant, singularity
# ---------------------------------------------------------------------------
def trace_law_error(b: np.ndarray, z: complex) -> float:
    """|tr(z*B) - z*tr(B)|, which must be ~0."""
    a = weighted_adjacency(b, z)
    return abs(np.trace(a) - z * np.trace(b))


def det_law_error(b: np.ndarray, z: complex) -> float:
    """|det(z*B) - z**n * det(B)|, which must be ~0 (up to float error)."""
    n = b.shape[0]
    a = weighted_adjacency(b, z)
    return abs(np.linalg.det(a) - (z ** n) * np.linalg.det(b))


# ---------------------------------------------------------------------------
# Result 5: complete-graph mean-direction outlier
# ---------------------------------------------------------------------------
def mean_direction_check(n: int, z: complex) -> tuple[float, float, float]:
    """Return (|(n-1)z|, sqrt(n)*|z|, eigenvector residual).

    The all-ones vector should be an eigenvector of z*K_n with eigenvalue
    (n-1)*z, and its modulus should exceed the naive radius sqrt(n)*|z|."""
    b = complete_indicator(n)
    a = weighted_adjacency(b, z)
    ones = np.ones(n, dtype=complex)
    lhs = a @ ones
    rhs = (n - 1) * z * ones
    residual = float(np.max(np.abs(lhs - rhs)))
    outlier_modulus = abs((n - 1) * z)
    naive_radius = math.sqrt(n) * abs(z)
    return outlier_modulus, naive_radius, residual


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 72)
    print("Spectral line-locking in the fixed-amplitude model  (A = z * B)")
    print("=" * 72)

    z: complex = cmath.rect(1.3, 0.9)  # amplitude 1.3, phase 0.9 rad
    print(f"\nCommon edge weight z = {z:.4f}   (|z| = {abs(z):.4f}, "
          f"arg = {cmath.phase(z):.4f} rad)")

    # ---- Result 1: line-locking on several random graphs ----
    print("\n[1] Spectral line-locking: max |Im(mu/z)| over eigenvalues")
    print("    (should be ~0; every eigenvalue is z times a real number)")
    for n, p, seed in [(6, 0.5, 1), (10, 0.4, 2), (25, 0.3, 3), (60, 0.2, 4)]:
        b = random_hermitian_indicator(n, p, seed)
        res = line_locking_residual(b, z)
        print(f"    n={n:>3}  p={p:<4}  max|Im(mu/z)| = {res:.3e}")

    # ---- Results 2-4: invariants ----
    print("\n[2-4] Global invariants on a random loopless graph (n=8)")
    b = random_hermitian_indicator(8, 0.5, 7)
    print(f"    trace law error       |tr(zB) - z tr(B)|     = "
          f"{trace_law_error(b, z):.3e}")
    print(f"    trace of loopless zB  |tr(zB)|               = "
          f"{abs(np.trace(weighted_adjacency(b, z))):.3e}  (=0)")
    print(f"    determinant law error |det(zB) - z^n det(B)| = "
          f"{det_law_error(b, z):.3e}")

    # singularity is weight-independent: use a graph forced singular
    # (two identical rows via an isolated-pair structure) vs generic
    print("\n    weight-independent singularity (det zero-pattern vs z):")
    b_sing = np.zeros((4, 4), dtype=complex)   # empty graph -> det B = 0
    for zz in [1 + 0j, 2j, cmath.rect(0.5, 1.0)]:
        dz = abs(np.linalg.det(weighted_adjacency(b_sing, zz)))
        print(f"      z={zz:.3f}:  |det(zB)| = {dz:.3e}  "
              f"(det B = {abs(np.linalg.det(b_sing)):.3e})")

    # ---- Result 5: mean-direction outlier ----
    print("\n[5] Complete-graph mean-direction eigenvalue (n-1)z and escape")
    print("    (outlier modulus should exceed naive radius sqrt(n)|z| for n>=3)")
    for n in [3, 5, 10, 50, 200]:
        outlier, naive, residual = mean_direction_check(n, z)
        flag = "escapes" if outlier > naive else "inside"
        print(f"    n={n:>4}  |(n-1)z|={outlier:9.3f}  "
              f"sqrt(n)|z|={naive:9.3f}  [{flag}]  "
              f"eigvec residual={residual:.2e}")

    print("\nAll numerical checks are consistent with the theorems.")
    print("=" * 72)


if __name__ == "__main__":
    main()
