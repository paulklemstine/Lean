"""
demo.py — Numerical demonstrations of Spectral Depth Thresholds for
Hodge-Laplacian Message Passing.

This script is fully self-contained (pure Python standard library: it uses only
`math` and small hand-rolled linear algebra so it runs anywhere). It numerically
verifies, on concrete small cell complexes, every headline result of the theory:

  1. Dirichlet energy identity:   <x, L x> = ||B x||^2          (hodge_quadform)
  2. Positive semidefiniteness:   <x, L x> >= 0                 (hodge_psd)
  3. Discrete Hodge theorem:      L x = 0  <=>  B x = 0         (harmonic_iff_boundary)
  4. Harmonic invariance:         harmonic x is fixed at every depth
  5. One-layer contraction:       ||mpStep x||^2 <= rho * ||x||^2
  6. Geometric decay:             ||T^k x||^2 <= rho^k ||x||^2  (quadform_iterate_bound)
  7. Logarithmic depth law:       k >= ceil(log_rho(eps/||x||^2)) => residual <= eps
  8. Full Hodge split energy:     <x, L x> = ||D x||^2 + ||E^T x||^2
  9. Full discrete Hodge theorem: L x = 0 <=> (D x = 0 and E^T x = 0)
"""

from __future__ import annotations

import math
from typing import List

Vector = List[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
# Minimal linear algebra
# --------------------------------------------------------------------------- #
def dot(x: Vector, y: Vector) -> float:
    """Standard inner product <x, y> = sum_i x_i y_i."""
    return sum(xi * yi for xi, yi in zip(x, y))


def norm_sq(x: Vector) -> float:
    """Squared Euclidean norm ||x||^2."""
    return dot(x, x)


def transpose(A: Matrix) -> Matrix:
    """Matrix transpose A^T."""
    return [list(col) for col in zip(*A)]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    """Matrix product A B."""
    Bt = transpose(B)
    return [[dot(row, col) for col in Bt] for row in A]


def matvec(A: Matrix, x: Vector) -> Vector:
    """Matrix-vector product A x."""
    return [dot(row, x) for row in A]


def vsub(x: Vector, y: Vector) -> Vector:
    return [a - b for a, b in zip(x, y)]


def vscale(a: float, x: Vector) -> Vector:
    return [a * xi for xi in x]


def is_zero(x: Vector, tol: float = 1e-9) -> bool:
    return all(abs(xi) < tol for xi in x)


# --------------------------------------------------------------------------- #
# Core definitions mirroring the Lean development
# --------------------------------------------------------------------------- #
def hodge(B: Matrix) -> Matrix:
    """Up-Hodge Laplacian L = B^T B (Definition `hodge`)."""
    return matmul(transpose(B), B)


def full_hodge(D: Matrix, E: Matrix) -> Matrix:
    """Full Hodge Laplacian L = D^T D + E E^T (Definition `fullHodge`)."""
    DtD = matmul(transpose(D), D)
    EEt = matmul(E, transpose(E))
    return [[a + b for a, b in zip(r1, r2)] for r1, r2 in zip(DtD, EEt)]


def mp_step(L: Matrix, alpha: float, x: Vector) -> Vector:
    """One message-passing layer x -> x - alpha (L x) (Definition `mpStep`)."""
    return vsub(x, vscale(alpha, matvec(L, x)))


def mp_iterate(L: Matrix, alpha: float, x: Vector, k: int) -> Vector:
    """Depth-k message passing (mpStep L alpha)^[k] x."""
    for _ in range(k):
        x = mp_step(L, alpha, x)
    return x


def hodge_depth(rho: float, e0: float, eps: float) -> int:
    """Explicit logarithmic depth N(eps) = ceil(log_rho(eps / e0)) (`hodgeDepth`)."""
    if e0 <= 0.0:
        return 0
    val = math.log(eps / e0) / math.log(rho)  # log_rho(eps/e0)
    return max(0, math.ceil(val))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_triangle_graph() -> None:
    """A triangle graph: 3 vertices, 3 edges. B is the edge-vertex incidence.

    Edges are signals here (1-cochains). The up-Laplacian's kernel (harmonic
    1-cochains) is the cycle space; for a single triangle it is 1-dimensional
    (the loop around the triangle), matching the first Betti number b_1 = 1.
    """
    print("=" * 70)
    print("DEMO 1 — Triangle graph: energy identity, PSD, discrete Hodge theorem")
    print("=" * 70)
    # Oriented incidence matrix B: rows = vertices (3), cols = edges (3).
    # Edges: e0 = (v0->v1), e1 = (v1->v2), e2 = (v2->v0).
    B = [
        [-1.0, 0.0, 1.0],   # v0
        [1.0, -1.0, 0.0],   # v1
        [0.0, 1.0, -1.0],   # v2
    ]
    L = hodge(B)
    print("Hodge Laplacian L = B^T B =")
    for row in L:
        print("   ", row)

    x = [2.0, -1.0, 3.0]
    lhs = dot(x, matvec(L, x))            # <x, L x>
    rhs = norm_sq(matvec(B, x))           # ||B x||^2
    print(f"\nDirichlet energy identity:  <x,Lx> = {lhs:.6f},  ||Bx||^2 = {rhs:.6f}")
    print(f"   match? {abs(lhs - rhs) < 1e-9}")
    print(f"PSD check:  <x,Lx> = {lhs:.6f} >= 0 ? {lhs >= -1e-12}")

    # Harmonic 1-cochain: the cycle x = (1,1,1) traverses the loop, B x = 0.
    h = [1.0, 1.0, 1.0]
    print(f"\nHarmonic candidate h = {h}")
    print(f"   B h = {matvec(B, h)}  (should be 0)")
    print(f"   L h = {matvec(L, h)}  (should be 0)")
    print(f"   discrete Hodge theorem (Lh=0 <=> Bh=0): "
          f"{is_zero(matvec(L, h)) == is_zero(matvec(B, h))}")
    print()


def demo_harmonic_invariance() -> None:
    """Harmonic signals are EXACT fixed points at every depth."""
    print("=" * 70)
    print("DEMO 2 — Harmonic invariance: topology survives arbitrary depth")
    print("=" * 70)
    B = [
        [-1.0, 0.0, 1.0],
        [1.0, -1.0, 0.0],
        [0.0, 1.0, -1.0],
    ]
    L = hodge(B)
    alpha = 0.2
    h = [1.0, 1.0, 1.0]  # harmonic
    for k in (0, 1, 5, 50, 1000):
        hk = mp_iterate(L, alpha, h, k)
        print(f"   depth {k:>4}:  (mpStep)^[k] h = {hk}  (unchanged: {hk == h or all(abs(a-b)<1e-9 for a,b in zip(hk,h))})")
    print()


def demo_contraction_and_decay() -> None:
    """One-layer contraction and geometric energy decay on a non-harmonic signal."""
    print("=" * 70)
    print("DEMO 3 — Spectral contraction and geometric energy decay")
    print("=" * 70)
    # Path graph on 4 vertices => graph Laplacian on vertex signals.
    # Incidence B (rows=edges, cols=vertices) for edges (0-1),(1-2),(2-3):
    B = [
        [1.0, -1.0, 0.0, 0.0],
        [0.0, 1.0, -1.0, 0.0],
        [0.0, 0.0, 1.0, -1.0],
    ]
    L = hodge(B)
    # Spectral data of this path Laplacian (computed analytically/known):
    # eigenvalues are 2 - 2cos(k pi / 4), k=0..3 => {0, ~0.586, 2, ~3.414}.
    lam = 2.0 - 2.0 * math.cos(3 * math.pi / 4)   # top eigenvalue ~3.414
    mu = 2.0 - 2.0 * math.cos(1 * math.pi / 4)    # spectral gap   ~0.586
    alpha = 1.0 / lam                              # admissible: 0 < alpha < 2/lam
    rho = 1.0 - alpha * mu * (2.0 - alpha * lam)
    print(f"top eigenvalue lambda = {lam:.6f}, spectral gap mu = {mu:.6f}")
    print(f"step alpha = {alpha:.6f}, per-layer contraction rho = {rho:.6f}")

    # Non-harmonic signal orthogonal to the constant (harmonic) direction.
    x = [1.0, -1.0, 1.0, -1.0]
    e0 = norm_sq(x)
    print(f"\nstart energy ||x||^2 = {e0:.6f}")
    print(f"{'depth':>6} {'||T^k x||^2':>14} {'rho^k ||x||^2 bound':>22} {'<= bound?':>10}")
    for k in (0, 1, 2, 4, 8, 16):
        xk = mp_iterate(L, alpha, x, k)
        ek = norm_sq(xk)
        bound = rho ** k * e0
        print(f"{k:>6} {ek:>14.6e} {bound:>22.6e} {str(ek <= bound + 1e-9):>10}")
    print()


def demo_logarithmic_depth() -> None:
    """Explicit logarithmic depth law: ceil(log_rho(eps/||x||^2)) layers suffice."""
    print("=" * 70)
    print("DEMO 4 — Logarithmic depth law N(eps) = ceil(log_rho(eps/||x||^2))")
    print("=" * 70)
    B = [
        [1.0, -1.0, 0.0, 0.0],
        [0.0, 1.0, -1.0, 0.0],
        [0.0, 0.0, 1.0, -1.0],
    ]
    L = hodge(B)
    lam = 2.0 - 2.0 * math.cos(3 * math.pi / 4)
    mu = 2.0 - 2.0 * math.cos(1 * math.pi / 4)
    alpha = 1.0 / lam
    rho = 1.0 - alpha * mu * (2.0 - alpha * lam)
    x = [1.0, -1.0, 1.0, -1.0]
    e0 = norm_sq(x)
    print(f"rho = {rho:.6f},  ||x||^2 = {e0:.6f}")
    print(f"\n{'eps':>10} {'N(eps)':>8} {'residual at N':>16} {'residual <= eps?':>18}")
    for eps in (1.0, 1e-2, 1e-4, 1e-6, 1e-9):
        n = hodge_depth(rho, e0, eps)
        residual = norm_sq(mp_iterate(L, alpha, x, n))
        print(f"{eps:>10.0e} {n:>8} {residual:>16.6e} {str(residual <= eps + 1e-12):>18}")
    print("Note: depth grows linearly in the number of digits, i.e. like log(1/eps).")
    print()


def demo_full_hodge() -> None:
    """Full Hodge Laplacian L = D^T D + E E^T: split energy and full Hodge theorem.

    We use a tiny chain ... C_{k+1} --E--> C_k --D--> C_{k-1} with D E = 0.
    """
    print("=" * 70)
    print("DEMO 5 — Full Hodge Laplacian: split energy and closed-and-coclosed")
    print("=" * 70)
    # C_{k+1} has dim 1, C_k has dim 3, C_{k-1} has dim 1.
    # E : C_{k+1} -> C_k  (3x1), D : C_k -> C_{k-1} (1x3), with D E = 0.
    E = [[1.0], [1.0], [1.0]]            # gradient image = span(1,1,1)
    D = [[1.0, -1.0, 0.0]]              # divergence; D E = 1 - 1 + 0 = 0  (chain cond.)
    DE = matmul(D, E)
    print(f"chain condition D E = {DE}  (should be [[0]])")
    L = full_hodge(D, E)
    print("Full Hodge Laplacian L = D^T D + E E^T =")
    for row in L:
        print("   ", row)

    x = [3.0, -2.0, 5.0]
    lhs = dot(x, matvec(L, x))
    rhs = norm_sq(matvec(D, x)) + norm_sq(matvec(transpose(E), x))
    print(f"\nsplit energy:  <x,Lx> = {lhs:.6f},  ||Dx||^2 + ||E^T x||^2 = {rhs:.6f}")
    print(f"   match? {abs(lhs - rhs) < 1e-9}")

    # Harmonic = closed (D x = 0) AND coclosed (E^T x = 0).
    # closed: x in ker D => x0 = x1; coclosed: x in ker E^T => x0+x1+x2 = 0.
    # Solve: x = (1, 1, -2).
    h = [1.0, 1.0, -2.0]
    closed = is_zero(matvec(D, h))
    coclosed = is_zero(matvec(transpose(E), h))
    harmonic = is_zero(matvec(L, h))
    print(f"\ncandidate harmonic h = {h}")
    print(f"   closed (D h = 0)?    {closed}   D h = {matvec(D, h)}")
    print(f"   coclosed (E^T h = 0)? {coclosed}   E^T h = {matvec(transpose(E), h)}")
    print(f"   harmonic (L h = 0)?  {harmonic}   L h = {matvec(L, h)}")
    print(f"   full Hodge theorem (Lh=0 <=> closed&coclosed): "
          f"{harmonic == (closed and coclosed)}")
    print()


def main() -> None:
    demo_triangle_graph()
    demo_harmonic_invariance()
    demo_contraction_and_decay()
    demo_logarithmic_depth()
    demo_full_hodge()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
