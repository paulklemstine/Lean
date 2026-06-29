"""
demo.py — Numerical demonstrations for
"The Full Hodge Decomposition and a Logarithmic Depth Law for Simplicial Message Passing"

All functions are inlined and depend only on NumPy. Each block reproduces, on
concrete small complexes, one of the proven theorems:

  * fullHodge_quadform   — Dirichlet energy splits as ||Dx||^2 + ||E^T x||^2
  * fullHodge_psd        — the Hodge Laplacian is positive semidefinite
  * fullHodge_kernel     — discrete Hodge theorem: harmonic = closed & coclosed
  * hodge_image_orthogonal / hodge_energy_pythagoras — under DE = 0
  * quadform_iterate_bound / hodgeDepth_residual_bound — logarithmic depth law

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable

import numpy as np

# ---------------------------------------------------------------------------
# Core operators
# ---------------------------------------------------------------------------


def full_hodge(D: np.ndarray, E: np.ndarray) -> np.ndarray:
    """Full combinatorial Hodge Laplacian  L = D^T D + E E^T  on k-cochains."""
    return D.T @ D + E @ E.T


def dirichlet_energy(L: np.ndarray, x: np.ndarray) -> float:
    """Quadratic form <x, L x>."""
    return float(x @ (L @ x))


def energy_split(D: np.ndarray, E: np.ndarray, x: np.ndarray) -> tuple[float, float]:
    """Closed channel ||D x||^2 and coclosed channel ||E^T x||^2."""
    Dx = D @ x
    Etx = E.T @ x
    return float(Dx @ Dx), float(Etx @ Etx)


def mp_step(L: np.ndarray, alpha: float, x: np.ndarray) -> np.ndarray:
    """One layer of gradient-descent Hodge message passing:  x -> x - alpha (L x)."""
    return x - alpha * (L @ x)


def hodge_depth(rho: float, energy0: float, eps: float) -> int:
    """Explicit logarithmic depth  N(eps) = ceil( log_rho(eps / energy0) )."""
    if energy0 <= 0.0:
        return 0
    ratio = eps / energy0
    if ratio >= 1.0:  # already within tolerance
        return 0
    return max(0, math.ceil(math.log(ratio) / math.log(rho)))


# ---------------------------------------------------------------------------
# Concrete complexes
# ---------------------------------------------------------------------------


def filled_triangle() -> tuple[np.ndarray, np.ndarray]:
    """
    A single filled triangle (a topological disk), working on its 3 edges (k = 1).

    Vertices 0,1,2 ; edges e0=(0,1), e1=(1,2), e2=(0,2) ; one face f=(0,1,2).

    D = boundary(edges -> vertices), 3x3.   E = boundary(face -> edges), 3x1.
    The chain condition D E = 0 holds. Its first cohomology is trivial (no holes),
    so the harmonic edge-space is 0-dimensional.
    """
    D = np.array(
        [
            [-1.0, 0.0, -1.0],  # vertex 0 touches e0 (-), e2 (-)
            [1.0, -1.0, 0.0],   # vertex 1 touches e0 (+), e1 (-)
            [0.0, 1.0, 1.0],    # vertex 2 touches e1 (+), e2 (+)
        ]
    )
    E = np.array([[1.0], [1.0], [-1.0]])  # face boundary e0 + e1 - e2
    return D, E


def hollow_triangle() -> tuple[np.ndarray, np.ndarray]:
    """
    The boundary cycle of a triangle (a topological circle), no face filled.

    Same D as the filled triangle, but E = 0 (no 2-cells). Its first cohomology
    is 1-dimensional (one loop), so the harmonic edge-space has dimension 1.
    """
    D, _ = filled_triangle()
    E = np.zeros((3, 0))  # no faces
    return D, E


def cycle_graph_laplacian(num_nodes: int) -> np.ndarray:
    """Node (k = 0) Hodge Laplacian L = B^T B of the n-cycle graph C_n.

    Its eigenvalues are 2 - 2 cos(2*pi*j/n); the constant vector is harmonic
    (eigenvalue 0) and the smallest nonzero eigenvalue is the spectral gap."""
    L = np.zeros((num_nodes, num_nodes))
    for i in range(num_nodes):
        j = (i + 1) % num_nodes
        L[i, i] += 1.0
        L[j, j] += 1.0
        L[i, j] -= 1.0
        L[j, i] -= 1.0
    return L


def project_off_null(L: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Project x onto the orthogonal complement of ker L (the contracting part)."""
    vals, vecs = np.linalg.eigh(L)
    v = x.copy()
    for i in range(len(vals)):
        if vals[i] < 1e-9:  # harmonic direction
            v = v - (vecs[:, i] @ v) * vecs[:, i]
    return v


def contraction_factor(L: np.ndarray, alpha: float) -> float:
    """Worst-case per-layer energy contraction max_{lambda>0} (1 - alpha*lambda)^2."""
    vals = np.linalg.eigvalsh(L)
    nonzero = [v for v in vals if v > 1e-9]
    return float(max((1.0 - alpha * v) ** 2 for v in nonzero))


# ---------------------------------------------------------------------------
# Demonstration blocks
# ---------------------------------------------------------------------------


def demo_energy_split_and_psd() -> None:
    print("=" * 70)
    print("Theorem 3.2/3.3: energy split  <x,Lx> = ||Dx||^2 + ||E^T x||^2  >= 0")
    print("=" * 70)
    D, E = filled_triangle()
    L = full_hodge(D, E)
    rng = np.random.default_rng(0)
    for _ in range(4):
        x = rng.standard_normal(3)
        total = dirichlet_energy(L, x)
        closed, coclosed = energy_split(D, E, x)
        print(
            f"  <x,Lx> = {total:8.4f}   ||Dx||^2 = {closed:8.4f}   "
            f"||E^T x||^2 = {coclosed:8.4f}   sum = {closed + coclosed:8.4f}"
        )
        assert math.isclose(total, closed + coclosed, abs_tol=1e-9)
        assert total >= -1e-9  # positive semidefinite
    print("  OK: split is exact and the form is non-negative.\n")


def demo_discrete_hodge_theorem() -> None:
    print("=" * 70)
    print("Theorem 4.1: discrete Hodge theorem  Lx = 0  <=>  Dx = 0 and E^T x = 0")
    print("=" * 70)
    for name, (D, E) in [("filled triangle (disk)", filled_triangle()),
                         ("hollow triangle (circle)", hollow_triangle())]:
        L = full_hodge(D, E)
        # Harmonic space = null space of L; compute via SVD.
        _, s, vt = np.linalg.svd(L)
        harmonic_dim = int(np.sum(s < 1e-9))
        print(f"  {name}: dim(harmonic edge-space) = {harmonic_dim}")
        # Verify each harmonic vector is closed and coclosed.
        for i in range(len(s)):
            if s[i] < 1e-9:
                x = vt[i]
                assert np.allclose(D @ x, 0, atol=1e-8)
                if E.shape[1] > 0:
                    assert np.allclose(E.T @ x, 0, atol=1e-8)
    print("  OK: harmonic disk = 0-dim (no holes); harmonic circle = 1-dim (one loop).\n")


def demo_betti_numbers() -> None:
    print("=" * 70)
    print("Algorithm C: Hodge-Betti  b_k = dim ker(D) - rank(E) = dim ker(L)")
    print("=" * 70)
    for name, (D, E) in [("disk", filled_triangle()), ("circle", hollow_triangle())]:
        n = D.shape[1]
        rank_D = int(np.linalg.matrix_rank(D))
        rank_E = int(np.linalg.matrix_rank(E)) if E.shape[1] > 0 else 0
        ker_D = n - rank_D
        betti_formula = ker_D - rank_E
        harmonic_dim = int(np.sum(np.linalg.svd(full_hodge(D, E))[1] < 1e-9))
        print(
            f"  {name:7s}: dim ker D = {ker_D}, rank E = {rank_E}, "
            f"b_1 = {betti_formula}  (dim ker L = {harmonic_dim})"
        )
        assert betti_formula == harmonic_dim
    print("  OK: local incidence data recovers the global Betti number.\n")


def demo_orthogonality_and_pythagoras() -> None:
    print("=" * 70)
    print("Theorem 4.2/4.3: under D E = 0,  <E y, D^T z> = 0  and Pythagoras holds")
    print("=" * 70)
    D, E = filled_triangle()
    assert np.allclose(D @ E, 0, atol=1e-9), "chain condition D E = 0"
    rng = np.random.default_rng(1)
    for _ in range(4):
        y = rng.standard_normal(E.shape[1])
        z = rng.standard_normal(D.shape[0])
        Ey = E @ y
        Dtz = D.T @ z
        cross = float(Ey @ Dtz)
        lhs = float((Ey + Dtz) @ (Ey + Dtz))
        rhs = float(Ey @ Ey) + float(Dtz @ Dtz)
        print(f"  <E y, D^T z> = {cross: .2e}   ||Ey+Dtz||^2 = {lhs:8.4f}   "
              f"||Ey||^2+||Dtz||^2 = {rhs:8.4f}")
        assert abs(cross) < 1e-9
        assert math.isclose(lhs, rhs, abs_tol=1e-9)
    print("  OK: gradient and divergence images are orthogonal; Pythagoras holds.\n")


def demo_geometric_decay() -> None:
    print("=" * 70)
    print("Theorem 5.1: geometric decay  ||T^k x||^2 <= rho^k ||x||^2")
    print("=" * 70)
    L = cycle_graph_laplacian(12)
    alpha = 1.0 / float(np.linalg.eigvalsh(L)[-1])
    rho = contraction_factor(L, alpha)
    rng = np.random.default_rng(3)
    x = project_off_null(L, rng.standard_normal(12))
    e0 = float(x @ x)
    print(f"  guaranteed contraction rho = {rho:.4f}")
    for k in range(0, 31, 5):
        vv = x.copy()
        for _ in range(k):
            vv = mp_step(L, alpha, vv)
        bound = (rho ** k) * e0
        actual = float(vv @ vv)
        print(f"  k = {k:2d}:  ||T^k x||^2 = {actual:.4e}   bound rho^k ||x||^2 = {bound:.4e}   "
              f"{'OK' if actual <= bound + 1e-9 else 'FAIL'}")
        assert actual <= bound + 1e-9
    print("  OK: residual energy stays under the geometric envelope.\n")


def demo_logarithmic_depth() -> None:
    print("=" * 70)
    print("Theorem 5.4: explicit depth  N = ceil(log_rho(eps/E0))  drives residual <= eps")
    print("=" * 70)
    L = cycle_graph_laplacian(12)
    lam_max = float(np.linalg.eigvalsh(L)[-1])
    alpha = 1.0 / lam_max  # safely inside (0, 2/lam_max)
    rho = contraction_factor(L, alpha)
    rng = np.random.default_rng(2)
    x = project_off_null(L, rng.standard_normal(12))  # on the contracting complement
    T: Callable[[np.ndarray], np.ndarray] = lambda v: mp_step(L, alpha, v)
    e0 = float(x @ x)
    print(f"  12-cycle, alpha = {alpha:.4f}, guaranteed contraction rho = {rho:.4f}")
    prev_N = 0
    for eps in [1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6]:
        N = hodge_depth(rho, e0, eps)
        v = x.copy()
        for _ in range(N):
            v = T(v)
        residual = float(v @ v)
        ok = residual <= eps + 1e-9
        print(f"  eps = {eps:.0e}  ->  N = {N:3d} layers (+{N - prev_N:2d}),  "
              f"residual = {residual:.3e}  {'<= eps OK' if ok else 'FAIL'}")
        assert ok
        prev_N = N
    print("  Note: depth grows by a CONSTANT increment per decade (logarithmic law).\n")


def main() -> None:
    demo_energy_split_and_psd()
    demo_discrete_hodge_theorem()
    demo_betti_numbers()
    demo_orthogonality_and_pythagoras()
    demo_geometric_decay()
    demo_logarithmic_depth()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
