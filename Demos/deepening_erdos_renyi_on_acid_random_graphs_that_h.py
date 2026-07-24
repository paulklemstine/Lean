"""
Numerical demonstrations of spectral line-locking in fixed-amplitude
complex-weighted undirected graphs.

Model
-----
Given a finite vertex set of size n, an undirected (symmetric) edge relation
g on the vertices, and a single complex amplitude z, the fixed-amplitude
adjacency matrix is

    A[i, j] = z   if g(i, j) is an edge,
    A[i, j] = 0   otherwise.

Because every present edge carries the SAME amplitude z, A factors as

    A = z * B,

where B is the real, symmetric, zero-one indicator matrix of g.

Main facts demonstrated here (all exact for finite graphs):
  1. Spectral line-locking: every eigenvalue lambda of A equals z * mu for a
     real mu, so the whole spectrum sits on the line R * z through the origin.
  2. Determinant scaling: det(A) = z**n * det(B).
  3. Vanishing loopless trace: tr(A) = 0 when g has no self-loops.
  4. Complete-graph outlier: the all-ones vector is an eigenvector of the
     complete loopless graph with eigenvalue (n - 1) * z, and this escapes the
     heuristic radius sqrt(n) * |z| for every n >= 3 (sharp: it fails at n = 2).

Only numpy is required.
"""

from __future__ import annotations

import cmath
import math

import numpy as np


# --------------------------------------------------------------------------- #
# Model construction
# --------------------------------------------------------------------------- #
def indicator_matrix(edges: np.ndarray) -> np.ndarray:
    """Return the real zero-one indicator matrix B from a boolean edge array."""
    return edges.astype(np.float64)


def adjacency_matrix(z: complex, edges: np.ndarray) -> np.ndarray:
    """Fixed-amplitude complex adjacency matrix A = z * B."""
    return z * edges.astype(np.complex128)


def random_symmetric_loopless(n: int, p: float, rng: np.random.Generator) -> np.ndarray:
    """Erdos-Renyi symmetric loopless edge relation as a boolean matrix."""
    upper = rng.random((n, n)) < p
    edges = np.triu(upper, k=1)
    edges = edges | edges.T  # symmetrize
    return edges


def complete_loopless(n: int) -> np.ndarray:
    """Complete loopless edge relation on n vertices (i != j)."""
    return ~np.eye(n, dtype=bool)


# --------------------------------------------------------------------------- #
# Demonstration 1: spectral line-locking
# --------------------------------------------------------------------------- #
def demo_line_locking(n: int = 12, p: float = 0.4, tol: float = 1e-9) -> None:
    """Verify that lambda / z is real for every eigenvalue of A = z * B."""
    print("=" * 70)
    print("DEMO 1: Spectral line-locking  (lambda = z * mu, mu real)")
    print("=" * 70)
    rng = np.random.default_rng(2024)
    z = 1.3 * cmath.exp(1j * 0.9)  # arbitrary nonzero amplitude
    edges = random_symmetric_loopless(n, p, rng)
    A = adjacency_matrix(z, edges)

    eigenvalues = np.linalg.eigvals(A)
    pulled_back = eigenvalues / z  # should be real
    max_imag = float(np.max(np.abs(pulled_back.imag)))

    print(f"  n = {n},  amplitude z = {z:.4f},  |z| = {abs(z):.4f}")
    print(f"  max |Im(lambda / z)| over all eigenvalues = {max_imag:.2e}")
    print(f"  line-locking holds (imag ~ 0): {max_imag < tol}")
    print("  sample eigenvalues and their real pull-backs mu = lambda / z:")
    for lam in eigenvalues[:5]:
        print(f"    lambda = {lam:+.4f}   ->   mu = {(lam / z).real:+.4f}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2: spectrum transport from B (no complex eigensolve)
# --------------------------------------------------------------------------- #
def demo_spectrum_transport(n: int = 12, p: float = 0.4, tol: float = 1e-9) -> None:
    """Diagonalize the real symmetric B once, then get spec(A) as {z * mu_k}."""
    print("=" * 70)
    print("DEMO 2: Spectrum transport  spec(z*B) = z * spec(B)")
    print("=" * 70)
    rng = np.random.default_rng(7)
    z = 0.8 * cmath.exp(1j * 2.1)
    edges = random_symmetric_loopless(n, p, rng)
    B = indicator_matrix(edges)
    A = adjacency_matrix(z, edges)

    mu = np.linalg.eigvalsh(B)                 # real symmetric solver, O(n^3)
    transported = np.sort_complex(z * mu)
    direct = np.sort_complex(np.linalg.eigvals(A))
    err = float(np.max(np.abs(transported - direct)))

    print(f"  n = {n},  amplitude z = {z:.4f}")
    print(f"  max discrepancy between z*spec(B) and spec(A) = {err:.2e}")
    print(f"  transport is exact: {err < 1e-6}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: determinant and trace invariants
# --------------------------------------------------------------------------- #
def demo_invariants(n: int = 8, p: float = 0.5, tol: float = 1e-6) -> None:
    """Check det(A) = z**n det(B) and tr(A) = 0 for loopless graphs."""
    print("=" * 70)
    print("DEMO 3: Global invariants  det(A) = z^n det(B),  tr(A) = 0")
    print("=" * 70)
    rng = np.random.default_rng(99)
    z = 1.1 * cmath.exp(1j * 0.5)
    edges = random_symmetric_loopless(n, p, rng)
    B = indicator_matrix(edges)
    A = adjacency_matrix(z, edges)

    det_A = np.linalg.det(A)
    det_pred = (z ** n) * np.linalg.det(B)
    tr_A = np.trace(A)

    print(f"  n = {n},  amplitude z = {z:.4f}")
    print(f"  det(A)           = {det_A:+.6f}")
    print(f"  z^n * det(B)     = {det_pred:+.6f}")
    print(f"  determinant law holds: {abs(det_A - det_pred) < tol}")
    print(f"  tr(A)            = {tr_A:+.2e}  (should be 0)")
    print(f"  trace vanishes: {abs(tr_A) < tol}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 4: complete-graph outlier and the n >= 3 threshold
# --------------------------------------------------------------------------- #
def demo_outlier() -> None:
    """Show (n-1)|z| vs sqrt(n)|z|: outlier escapes for n >= 3, fails at n = 2."""
    print("=" * 70)
    print("DEMO 4: Complete-graph outlier  |(n-1)z| vs sqrt(n)|z|")
    print("=" * 70)
    z = 2.0 * cmath.exp(1j * 1.0)
    print(f"  amplitude z = {z:.4f},  |z| = {abs(z):.4f}")
    print(f"  {'n':>3} | {'|(n-1)z|':>12} | {'sqrt(n)|z|':>12} | outlier escapes?")
    print("  " + "-" * 56)
    for n in range(2, 9):
        edges = complete_loopless(n)
        A = adjacency_matrix(z, edges)
        ones = np.ones(n, dtype=np.complex128)
        # verify all-ones is an eigenvector with eigenvalue (n-1)z
        image = A @ ones
        eig = (n - 1) * z
        assert np.allclose(image, eig * ones), "all-ones eigenpair failed"
        lhs = abs(eig)
        rhs = math.sqrt(n) * abs(z)
        print(f"  {n:>3} | {lhs:>12.4f} | {rhs:>12.4f} | {lhs > rhs}")
    print("  (escape begins exactly at n = 3; fails at n = 2)")
    print()


def main() -> None:
    demo_line_locking()
    demo_spectrum_transport()
    demo_invariants()
    demo_outlier()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
