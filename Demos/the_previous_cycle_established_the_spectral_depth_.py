"""
Hodge-Laplacian Message Passing: the Convergence Cycle
======================================================

Numerical companion to the article and research paper.

This self-contained script demonstrates, by direct numerical computation, the
central facts established in the formal development:

  1.  The up Hodge Laplacian  L = Bᵀ B  is symmetric positive semidefinite,
      and its kernel is the harmonic (cohomology) subspace.

  2.  One message-passing layer  T(x) = x − α (L x)  is a *linear* operator,
      it fixes every harmonic signal exactly, and it contracts the residual
      energy by the factor  ρ(α) = 1 − α μ (2 − α λ)  off the kernel, where
      μ is the smallest nonzero eigenvalue and λ the largest eigenvalue of L.

  3.  Deep message passing  Tᵏ  converges to the orthogonal projection of the
      input onto the harmonic subspace; the squared distance to that limit is
      bounded by  ρᵏ ‖r‖²  (geometric / "logarithmic depth" law).

  4.  The contraction factor ρ(α) is minimized at the *spectral step* α = 1/λ,
      where it equals  1 − μ/λ  (one over the condition number on the range).

  5.  The harmonic dimension is a Betti number, recovered by rank–nullity:
      dim ker Δ = dim ker d − rank e.

Only NumPy is required.
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# 1.  A tiny simplicial complex and its boundary operators
# ---------------------------------------------------------------------------
def triangle_boundary_with_hole() -> dict[str, np.ndarray]:
    """A 1-complex: a square cycle 0-1-2-3-0 with both diagonals removed.

    Vertices: 0, 1, 2, 3.  Edges (oriented): (0,1), (1,2), (2,3), (3,0).
    This is a single 4-cycle, so H^1 has dimension 1 (one independent loop):
    the first Betti number is b1 = 1.

    Returns the vertex-edge incidence matrix B1 (the boundary d acting on
    1-chains), from which the up Laplacian on vertices L0 = B1 B1ᵀ and the
    edge Laplacian L1 are built.
    """
    edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    n_vertices, n_edges = 4, len(edges)
    # B1[v, e] = +1 if v is head, -1 if v is tail of edge e.
    B1 = np.zeros((n_vertices, n_edges))
    for e, (u, v) in enumerate(edges):
        B1[u, e] = -1.0
        B1[v, e] = +1.0
    return {"B1": B1}


def up_laplacian(B: np.ndarray) -> np.ndarray:
    """Up Hodge Laplacian  L = Bᵀ B  (acts on the *edge* space here)."""
    return B.T @ B


# ---------------------------------------------------------------------------
# 2.  Spectral data
# ---------------------------------------------------------------------------
def spectral_data(L: np.ndarray, tol: float = 1e-9) -> dict[str, float | np.ndarray]:
    """Eigen-decomposition of a symmetric PSD matrix L.

    Returns the eigenvalues/vectors, the smallest *nonzero* eigenvalue μ
    (the spectral gap), the largest eigenvalue λ, and the harmonic kernel.
    """
    vals, vecs = np.linalg.eigh(L)            # ascending eigenvalues
    vals = np.where(np.abs(vals) < tol, 0.0, vals)
    nonzero = vals[vals > tol]
    mu = float(nonzero.min()) if nonzero.size else 0.0
    lam = float(vals.max())
    kernel = vecs[:, vals <= tol]             # columns spanning ker L
    return {"vals": vals, "vecs": vecs, "mu": mu, "lam": lam, "kernel": kernel}


def harmonic_projection(L: np.ndarray, x: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthogonal projection of x onto ker L (the harmonic subspace)."""
    vals, vecs = np.linalg.eigh(L)
    K = vecs[:, np.abs(vals) < tol]
    return K @ (K.T @ x)


# ---------------------------------------------------------------------------
# 3.  Message passing
# ---------------------------------------------------------------------------
def mp_step(L: np.ndarray, alpha: float, x: np.ndarray) -> np.ndarray:
    """One gradient message-passing layer  T(x) = x − α (L x)."""
    return x - alpha * (L @ x)


def mp_iterate(L: np.ndarray, alpha: float, x: np.ndarray, depth: int) -> np.ndarray:
    """Depth-k message passing  Tᵏ(x)."""
    y = x.copy()
    for _ in range(depth):
        y = mp_step(L, alpha, y)
    return y


def contraction_factor(alpha: float, mu: float, lam: float) -> float:
    """The per-layer residual contraction factor  ρ(α) = 1 − α μ (2 − α λ)."""
    return 1.0 - alpha * mu * (2.0 - alpha * lam)


def optimal_step(lam: float) -> float:
    """The spectral step  α* = 1/λ  that minimizes ρ(α)."""
    return 1.0 / lam


# ---------------------------------------------------------------------------
# 4.  Demonstrations
# ---------------------------------------------------------------------------
def demo_linearity_and_fixed_points() -> None:
    print("=" * 70)
    print("DEMO 1:  The layer is linear and fixes harmonic signals exactly")
    print("=" * 70)
    L = up_laplacian(triangle_boundary_with_hole()["B1"])
    rng = np.random.default_rng(0)
    x, y = rng.standard_normal(L.shape[0]), rng.standard_normal(L.shape[0])
    a, b = 1.7, -0.4
    alpha = 0.3

    lhs = mp_step(L, alpha, a * x + b * y)
    rhs = a * mp_step(L, alpha, x) + b * mp_step(L, alpha, y)
    print(f"  ‖T(ax+by) − (a·Tx + b·Ty)‖ = {np.linalg.norm(lhs - rhs):.2e}  (linear)")

    sd = spectral_data(L)
    h = sd["kernel"][:, 0] if sd["kernel"].shape[1] else np.zeros(L.shape[0])
    print(f"  harmonic dim (Betti b1) = {sd['kernel'].shape[1]}")
    fixed = mp_iterate(L, alpha, h, depth=50)
    print(f"  ‖T^50(h) − h‖ for harmonic h = {np.linalg.norm(fixed - h):.2e}  (fixed)")
    print()


def demo_convergence_to_harmonic() -> None:
    print("=" * 70)
    print("DEMO 2:  Deep message passing converges to the harmonic projection")
    print("=" * 70)
    L = up_laplacian(triangle_boundary_with_hole()["B1"])
    sd = spectral_data(L)
    mu, lam = sd["mu"], sd["lam"]
    alpha = optimal_step(lam)
    rho = contraction_factor(alpha, mu, lam)

    rng = np.random.default_rng(1)
    x = rng.standard_normal(L.shape[0])
    h = harmonic_projection(L, x)
    r = x - h
    r_energy = float(r @ r)

    print(f"  spectral gap μ = {mu:.4f},  top eigenvalue λ = {lam:.4f}")
    print(f"  spectral step α* = 1/λ = {alpha:.4f},  ρ(α*) = 1 − μ/λ = {rho:.4f}")
    print(f"  {'depth k':>8} | {'‖Tᵏx − h‖²':>14} | {'bound ρᵏ‖r‖²':>14}")
    for k in (0, 1, 2, 4, 8, 16, 32):
        yk = mp_iterate(L, alpha, x, k)
        dist2 = float((yk - h) @ (yk - h))
        bound = (rho ** k) * r_energy
        print(f"  {k:>8} | {dist2:>14.6e} | {bound:>14.6e}")
    print()


def demo_optimal_step() -> None:
    print("=" * 70)
    print("DEMO 3:  The contraction factor is minimized at α = 1/λ")
    print("=" * 70)
    L = up_laplacian(triangle_boundary_with_hole()["B1"])
    sd = spectral_data(L)
    mu, lam = sd["mu"], sd["lam"]
    print(f"  μ = {mu:.4f},  λ = {lam:.4f}")
    print(f"  {'α':>8} | {'ρ(α) = 1 − αμ(2 − αλ)':>26}")
    grid = np.linspace(0.05, 2.0 / lam - 1e-6, 9)
    for a in grid:
        print(f"  {a:>8.4f} | {contraction_factor(a, mu, lam):>26.6f}")
    a_star = optimal_step(lam)
    print(f"  --> minimum at α* = 1/λ = {a_star:.4f}, "
          f"ρ(α*) = {contraction_factor(a_star, mu, lam):.6f} = 1 − μ/λ")
    print()


def demo_betti_rank_nullity() -> None:
    print("=" * 70)
    print("DEMO 4:  Harmonic dimension is a Betti number (rank–nullity)")
    print("=" * 70)
    B1 = triangle_boundary_with_hole()["B1"]      # d : edges -> vertices
    # In this 1-complex there are no 2-cells, so e = 0 (no gradient image
    # into the edge space).  The first Betti number is dim ker d - rank e.
    d = B1                                         # boundary on 1-chains
    dim_ker_d = d.shape[1] - np.linalg.matrix_rank(d)
    rank_e = 0                                     # no 2-cells
    betti = dim_ker_d - rank_e
    L1 = up_laplacian(B1)                          # edge up-Laplacian = BᵀB
    harm_dim = L1.shape[0] - np.linalg.matrix_rank(L1)
    print(f"  dim ker d (cycles)      = {dim_ker_d}")
    print(f"  rank e (boundaries)     = {rank_e}")
    print(f"  Betti number b1         = dim ker d − rank e = {betti}")
    print(f"  dim ker Δ (harmonic)    = {harm_dim}")
    print(f"  agreement: {betti == harm_dim}")
    print()


def main() -> None:
    demo_linearity_and_fixed_points()
    demo_convergence_to_harmonic()
    demo_optimal_step()
    demo_betti_rank_nullity()


if __name__ == "__main__":
    main()
