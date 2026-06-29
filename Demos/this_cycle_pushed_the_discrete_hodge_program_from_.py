"""
demo.py — The Hodge Laplacian: Spectral Positivity and the Resolution of the Identity
=====================================================================================

This script gives self-contained numerical demonstrations of the two main theorems
formalized in this package, working over finite-dimensional real inner-product spaces
(here, ordinary Euclidean R^n with the dot product, so that the adjoint of a linear
map is the transpose of its matrix).

Setting
-------
A *two-step cochain complex* is a chain of linear maps

        U --e--> V --d--> W ,        with the chain condition   d . e = 0 .

On the middle space V we form the **Hodge Laplacian**

        Delta  =  d* . d  +  e . e*        (a linear map  V -> V),

where  f*  denotes the adjoint (transpose) of  f.

Theorem A (Spectral positivity).
    For every x in V:
        <Delta x, x>  =  ||d x||^2 + ||e* x||^2            (sum of squares)
    Consequences:
        <Delta x, x> >= 0                                  (Delta is PSD)
        <Delta x, x> = 0  <=>  x in ker Delta              (vanishing locus = harmonic space)
        Delta is symmetric, and every eigenvalue of Delta is >= 0.

Theorem B (Resolution of the identity).
    With the three orthogonal projectors
        P_coexact  = projection onto range(d*)
        P_exact    = projection onto range(e)
        P_harmonic = projection onto ker(Delta),
    one has, for every x in V,
        P_coexact x + P_exact x + P_harmonic x = x         (resolution of 1)
    and the projectors pairwise annihilate:
        P_i . P_j = 0   for  i != j .

Run:  python3 demo.py
"""

from __future__ import annotations

import numpy as np

np.set_printoptions(precision=4, suppress=True)


# ---------------------------------------------------------------------------
# Core constructions
# ---------------------------------------------------------------------------
def hodge_laplacian(d: np.ndarray, e: np.ndarray) -> np.ndarray:
    """Return the Hodge Laplacian Delta = d^T d + e e^T acting on the middle space V.

    Here ``d`` maps V -> W (shape (dimW, dimV)) and ``e`` maps U -> V
    (shape (dimV, dimU)); adjoints are transposes for the Euclidean inner product.
    """
    return d.T @ d + e @ e.T


def rayleigh(delta: np.ndarray, x: np.ndarray) -> float:
    """Return the Rayleigh quadratic form <Delta x, x>."""
    return float(x @ (delta @ x))


def sum_of_squares(d: np.ndarray, e: np.ndarray, x: np.ndarray) -> float:
    """Return ||d x||^2 + ||e* x||^2, the right-hand side of Theorem A."""
    return float(np.dot(d @ x, d @ x) + np.dot(e.T @ x, e.T @ x))


def orthogonal_projector(basis_cols: np.ndarray) -> np.ndarray:
    """Orthogonal projector onto the column span of ``basis_cols`` (any spanning matrix).

    Uses the pseudoinverse so that it is robust to rank-deficient / non-orthonormal input.
    If the span is {0} (empty or zero matrix) the zero projector is returned.
    """
    if basis_cols.size == 0 or np.linalg.matrix_rank(basis_cols) == 0:
        n = basis_cols.shape[0]
        return np.zeros((n, n))
    return basis_cols @ np.linalg.pinv(basis_cols)


def kernel_basis(matrix: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Return an orthonormal basis (as columns) of the kernel of ``matrix``."""
    _, s, vh = np.linalg.svd(matrix)
    rank = int(np.sum(s > tol))
    return vh[rank:].T  # rows of vh beyond the rank span the kernel


# ---------------------------------------------------------------------------
# Example 1 — the canonical axis-aligned complex on V = R^3
# ---------------------------------------------------------------------------
def example_axis_complex() -> tuple[np.ndarray, np.ndarray]:
    """A minimal complex realizing all three Hodge summands as coordinate axes.

    U = R^1 --e--> V = R^3 --d--> W = R^1, with d e = 0:
        e = (1, 0, 0)^T   (range e = x-axis  = the *exact* part)
        d = (0, 0, 1)     (range d* = z-axis = the *coexact* part)
    Then Delta = diag(1, 0, 1); the harmonic space ker Delta is the y-axis.
    """
    e = np.array([[1.0], [0.0], [0.0]])        # V <- U
    d = np.array([[0.0, 0.0, 1.0]])            # W <- V
    return d, e


# ---------------------------------------------------------------------------
# Example 2 — a real graph: the hollow triangle (first Betti number = 1)
# ---------------------------------------------------------------------------
def example_triangle_loop() -> tuple[np.ndarray, np.ndarray]:
    """Discrete Hodge theory on a graph: vertices --e--> edges --d--> triangles.

    Graph = the boundary of a triangle on vertices {0,1,2} with edges
        e1 = (0,1),  e2 = (1,2),  e3 = (0,2),
    and NO filled 2-cell.  Here:
        e = d0 (the gradient / vertex-to-edge incidence map), V = R^3 (edges)
        d = 0  (no triangles to map into)
    The harmonic 1-forms ker Delta are then the cycle space, of dimension 1 =
    the first Betti number: the single independent loop around the triangle.
    """
    # e (edges x vertices): row for edge (a,b) has -1 at a, +1 at b
    e = np.array([
        [-1.0, 1.0, 0.0],   # edge 0->1
        [0.0, -1.0, 1.0],   # edge 1->2
        [-1.0, 0.0, 1.0],   # edge 0->2
    ])
    d = np.zeros((1, 3))     # no triangles
    return d, e


# ---------------------------------------------------------------------------
# Verification routines
# ---------------------------------------------------------------------------
def verify_theorem_A(d: np.ndarray, e: np.ndarray, rng: np.random.Generator) -> None:
    """Check the sum-of-squares identity, PSD, vanishing locus, symmetry, eigenvalues."""
    delta = hodge_laplacian(d, e)
    n = delta.shape[0]

    print("  Delta =")
    print("   ", str(delta).replace("\n", "\n    "))

    # 1. Quadratic form is a sum of squares, on random test vectors.
    max_err = 0.0
    min_rayleigh = np.inf
    for _ in range(2000):
        x = rng.standard_normal(n)
        lhs = rayleigh(delta, x)
        rhs = sum_of_squares(d, e, x)
        max_err = max(max_err, abs(lhs - rhs))
        min_rayleigh = min(min_rayleigh, lhs)
    print(f"  Theorem A  <Delta x,x> = ||dx||^2 + ||e* x||^2 : max error = {max_err:.2e}")
    print(f"  PSD        min <Delta x,x> over 2000 samples   = {min_rayleigh:.4f}  (>= 0)")

    # 2. Symmetry.
    print(f"  Symmetry   ||Delta - Delta^T||                 = {np.linalg.norm(delta - delta.T):.2e}")

    # 3. Eigenvalues are nonnegative; 0-eigenspace = ker Delta.
    eigvals = np.linalg.eigvalsh(delta)
    print(f"  Spectrum   eigenvalues                         = {eigvals}")
    print(f"             min eigenvalue                      = {eigvals.min():.4f}  (>= 0)")

    # 4. Vanishing locus = harmonic space: <Delta x, x> = 0  iff  Delta x = 0.
    ker = kernel_basis(delta)
    if ker.shape[1] > 0:
        x = ker @ rng.standard_normal(ker.shape[1])
        print(f"  Harmonic x: <Delta x,x>={rayleigh(delta, x):.2e}, ||Delta x||={np.linalg.norm(delta @ x):.2e}")
    print(f"  dim ker Delta (harmonic dimension / Betti)     = {ker.shape[1]}")


def verify_theorem_B(d: np.ndarray, e: np.ndarray, rng: np.random.Generator) -> None:
    """Check the resolution of the identity and pairwise annihilation of projectors."""
    delta = hodge_laplacian(d, e)
    n = delta.shape[0]

    P_coexact = orthogonal_projector(d.T)            # onto range(d*)
    P_exact = orthogonal_projector(e)                # onto range(e)
    P_harmonic = orthogonal_projector(kernel_basis(delta))  # onto ker(Delta)

    # Resolution of the identity.
    res = P_coexact + P_exact + P_harmonic - np.eye(n)
    print(f"  Resolution ||P_coexact + P_exact + P_harmonic - I|| = {np.linalg.norm(res):.2e}")

    # Pairwise annihilation.
    pairs = {
        "P_harm . P_exact": P_harmonic @ P_exact,
        "P_harm . P_coexact": P_harmonic @ P_coexact,
        "P_exact . P_coexact": P_exact @ P_coexact,
    }
    for name, prod in pairs.items():
        print(f"  Annihilate {name:22s} ||.|| = {np.linalg.norm(prod):.2e}")

    # Three-way decomposition of a random signal x = c + a + h.
    x = rng.standard_normal(n)
    c, a, h = P_coexact @ x, P_exact @ x, P_harmonic @ x
    print(f"  Decompose  x = c + a + h : ||x - (c+a+h)|| = {np.linalg.norm(x - (c + a + h)):.2e}")
    print(f"             ||c||={np.linalg.norm(c):.4f}  ||a||={np.linalg.norm(a):.4f}  ||h||={np.linalg.norm(h):.4f}")
    print(f"             orthogonality <c,a>={c@a:.2e}  <c,h>={c@h:.2e}  <a,h>={a@h:.2e}")


def main() -> None:
    rng = np.random.default_rng(20260614)

    print("=" * 74)
    print("EXAMPLE 1 — canonical axis-aligned complex on V = R^3")
    print("=" * 74)
    d, e = example_axis_complex()
    print(f"  chain condition  ||d.e|| = {np.linalg.norm(d @ e):.2e}")
    verify_theorem_A(d, e, rng)
    verify_theorem_B(d, e, rng)

    print()
    print("=" * 74)
    print("EXAMPLE 2 — the hollow triangle graph (vertices -> edges -> triangles)")
    print("=" * 74)
    d, e = example_triangle_loop()
    print(f"  chain condition  ||d.e|| = {np.linalg.norm(d @ e):.2e}")
    verify_theorem_A(d, e, rng)
    verify_theorem_B(d, e, rng)
    delta = hodge_laplacian(d, e)
    harm = kernel_basis(delta)
    print(f"  Harmonic 1-form (loop circulation), normalized = {harm[:, 0]}")


if __name__ == "__main__":
    main()
