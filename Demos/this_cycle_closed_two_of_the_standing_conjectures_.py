"""
demo.py — Numerical demonstrations of the Discrete Hodge Theory of Message Passing.

This script illustrates, with concrete numbers, the two headline laws proved
formally in the accompanying work:

  STRUCTURE (harmonic core = cohomology)
    * Split Dirichlet energy:        <Delta x, x> = ||d x||^2 + ||e* x||^2
    * Discrete Hodge theorem:        ker Delta = ker d  ∩  ker e*
    * Hodge-Betti identity:          dim(ker Delta) + rank(e) = dim(ker d)
                                     i.e.  b_k = dim ker d - rank e

  DYNAMICS (logarithmic depth clock)
    * Depth formula:                 hodgeDepth = ceil( log_rho(eps / E) )
    * Sufficiency:                   depth >= hodgeDepth  ==> residual <= eps
    * Tightness:                     depth <  hodgeDepth  ==> residual >  eps  (worst case)
    * Energy-free schedule:          log_rho(e2/E) - log_rho(e1/E) = log_rho(e2/e1)

Self-contained: requires only numpy.
"""

from __future__ import annotations

import math
from typing import Tuple

import numpy as np


# ----------------------------------------------------------------------------
# Linear-algebra helpers
# ----------------------------------------------------------------------------
def numerical_rank(M: np.ndarray, tol: float = 1e-9) -> int:
    """Numerical rank of a matrix via singular values."""
    if M.size == 0:
        return 0
    s = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(s > tol))


def dim_kernel(M: np.ndarray, tol: float = 1e-9) -> int:
    """Dimension of the kernel (null space) of M : R^cols -> R^rows."""
    cols = M.shape[1]
    return cols - numerical_rank(M, tol)


def hodge_laplacian(D: np.ndarray, E: np.ndarray) -> np.ndarray:
    """Combinatorial Hodge Laplacian  Delta = D^T D + E E^T  on the middle space.

    Here D represents the 'down' map d : V -> W and E represents the 'up' map
    e : U -> V.  The adjoints are transposes in the standard inner product.
    """
    return D.T @ D + E @ E.T


# ----------------------------------------------------------------------------
# Example complex: a single 2-simplex (oriented triangle)
# Nodes {0,1,2}, edges {(0,1),(1,2),(0,2)}, one triangle (0,1,2).
#   e = boundary_2 : triangles -> edges    (U -> V)
#   d = boundary_1 : edges     -> nodes    (V -> W)
#   chain condition  d . e = 0   (boundary of a boundary is zero)
# ----------------------------------------------------------------------------
def triangle_complex() -> Tuple[np.ndarray, np.ndarray]:
    """Return (D, E) for the filled oriented triangle.  D @ E == 0."""
    # d = boundary_1 (3 nodes x 3 edges); column j = head - tail of edge j.
    D = np.array(
        [
            [-1.0, 0.0, -1.0],  # node 0
            [1.0, -1.0, 0.0],   # node 1
            [0.0, 1.0, 1.0],    # node 2
        ]
    )
    # e = boundary_2 (3 edges x 1 triangle):  (0,1)+(1,2)-(0,2)
    E = np.array([[1.0], [1.0], [-1.0]])
    return D, E


# ----------------------------------------------------------------------------
# STRUCTURE demos
# ----------------------------------------------------------------------------
def demo_split_energy(D: np.ndarray, E: np.ndarray, seed: int = 0) -> None:
    """Verify  <Delta x, x> = ||D x||^2 + ||E^T x||^2  on random cochains."""
    print("=" * 70)
    print("DEMO 1 — Split Dirichlet energy:  <Delta x, x> = ||Dx||^2 + ||E^T x||^2")
    print("=" * 70)
    rng = np.random.default_rng(seed)
    Delta = hodge_laplacian(D, E)
    max_err = 0.0
    for _ in range(5):
        x = rng.standard_normal(D.shape[1])
        lhs = float(x @ (Delta @ x))
        rhs = float((D @ x) @ (D @ x) + (E.T @ x) @ (E.T @ x))
        max_err = max(max_err, abs(lhs - rhs))
    print(f"  max |LHS - RHS| over 5 random cochains : {max_err:.2e}")
    print("  => the quadratic form splits exactly into two squared norms.\n")


def demo_hodge_theorem_and_betti(D: np.ndarray, E: np.ndarray) -> None:
    """Verify ker Delta = ker D ∩ ker E^T (dimension) and the Hodge-Betti identity."""
    print("=" * 70)
    print("DEMO 2 — Discrete Hodge theorem  &  Hodge-Betti identity")
    print("=" * 70)
    Delta = hodge_laplacian(D, E)

    dim_kerDelta = dim_kernel(Delta)
    dim_kerD = dim_kernel(D)
    dim_ker_Et = dim_kernel(E.T)
    rank_E = numerical_rank(E)

    # ker D ∩ ker E^T : kernel of the stacked map [D; E^T].
    stacked = np.vstack([D, E.T])
    dim_closed_coclosed = dim_kernel(stacked)

    betti_from_harmonic = dim_kerDelta
    betti_from_boundaries = dim_kerD - rank_E

    print(f"  dim(ker Delta)            = {dim_kerDelta}")
    print(f"  dim(ker D ∩ ker E^T)      = {dim_closed_coclosed}   (discrete Hodge thm)")
    print(f"  dim(ker D)                = {dim_kerD}")
    print(f"  rank(E)                   = {rank_E}")
    print(f"  Hodge-Betti:  dim(ker D) - rank(E) = {betti_from_boundaries}")
    print(f"  harmonic dimension                 = {betti_from_harmonic}")
    ok = (
        dim_kerDelta == dim_closed_coclosed
        and betti_from_harmonic == betti_from_boundaries
    )
    print(f"  identities hold: {ok}")
    print("  (Filled triangle: b_1 = 0 — the loop is filled in.)\n")


def demo_betti_hollow() -> None:
    """Same triangle but UNFILLED (no 2-cell): b_1 jumps to 1 — a genuine hole."""
    print("=" * 70)
    print("DEMO 3 — Removing the filling creates a hole (b_1: 0 -> 1)")
    print("=" * 70)
    D, _ = triangle_complex()
    E_empty = np.zeros((3, 0))  # no triangles
    Delta = hodge_laplacian(D, E_empty)
    print(f"  filled triangle  : b_1 = {dim_kernel(hodge_laplacian(*triangle_complex()))}")
    print(f"  hollow triangle  : b_1 = {dim_kernel(Delta)}")
    print("  => the harmonic core literally counts topological holes.\n")


# ----------------------------------------------------------------------------
# DYNAMICS demos
# ----------------------------------------------------------------------------
def hodge_depth(rho: float, E: float, eps: float) -> int:
    """The exact minimum depth  ceil( log_rho(eps / E) ),  clamped at 0."""
    val = math.log(eps / E) / math.log(rho)  # log_rho(eps/E)
    return max(0, math.ceil(val))


def demo_depth_sufficiency_and_tightness(rho: float = 0.6) -> None:
    """On a SATURATING input ||T^k x||^2 = rho^k ||x||^2, show the depth is exact."""
    print("=" * 70)
    print(f"DEMO 4 — Depth clock (rho = {rho}):  sufficient AND tight")
    print("=" * 70)
    E = 100.0       # initial Dirichlet energy ||x||^2
    eps = 1.0e-3    # target residual energy
    N = hodge_depth(rho, E, eps)
    print(f"  energy E = {E},  tolerance eps = {eps}")
    print(f"  hodgeDepth = ceil(log_rho(eps/E)) = {N} layers")

    def residual(k: int) -> float:
        return rho ** k * E  # saturating worst-case residual

    print(f"  residual at depth N-1 = {residual(N - 1):.3e}  (> eps : {residual(N-1) > eps})")
    print(f"  residual at depth N   = {residual(N):.3e}  (<= eps: {residual(N) <= eps})")
    # tightness: every depth strictly below N overshoots eps
    tight = all(residual(k) > eps for k in range(N))
    suff = residual(N) <= eps
    print(f"  tightness (all k < N overshoot)  : {tight}")
    print(f"  sufficiency (depth N reaches eps): {suff}\n")


def demo_energy_free_schedule(rho: float = 0.6) -> None:
    """Incremental depth depends only on the tolerance RATIO, not the energy."""
    print("=" * 70)
    print("DEMO 5 — Energy-free schedule:  log_rho(e2/E) - log_rho(e1/E) = log_rho(e2/e1)")
    print("=" * 70)

    def logb(base: float, x: float) -> float:
        return math.log(x) / math.log(base)

    eps1, eps2 = 1e-2, 1e-4
    for E in (1.0, 100.0, 5000.0):
        lhs = logb(rho, eps2 / E) - logb(rho, eps1 / E)
        rhs = logb(rho, eps2 / eps1)
        print(f"  E = {E:7.0f}:  increment = {lhs:8.4f}  ratio-only = {rhs:8.4f}  "
              f"(match: {abs(lhs - rhs) < 1e-9})")
    print("  => the signal energy E cancels exactly; only eps2/eps1 matters.\n")


def main() -> None:
    print("\nDISCRETE HODGE THEORY OF MESSAGE PASSING — numerical demonstrations\n")
    D, E = triangle_complex()
    assert np.allclose(D @ E, 0.0), "chain condition d . e = 0 must hold"
    demo_split_energy(D, E)
    demo_hodge_theorem_and_betti(D, E)
    demo_betti_hollow()
    demo_depth_sufficiency_and_tightness()
    demo_energy_free_schedule()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
