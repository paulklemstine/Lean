"""
Spectral Depth Thresholds for Hodge-Laplacian Message Passing
=============================================================

Numerical demonstrations of the results in the package, using only the Python
standard library (no NumPy required). All linear algebra is implemented inline
with type hints so the file is fully self-contained.

The mathematics being demonstrated:

  Definition (Hodge Laplacian):     L = B^T B
  Definition (message-passing):     mpStep(x) = x - alpha * (L x)

  hodge_quadform:   <x, L x> = <B x, B x> = ||B x||^2     (Dirichlet energy)
  hodge_psd:        <x, L x> >= 0
  harmonic_iff_boundary:  L x = 0  <=>  B x = 0
  mpStep_fixes_harmonic:  L x = 0  =>  mpStep(x) = x  (at every depth)
  quadform_mpStep:  ||mpStep(x)||^2 = ||x||^2 - 2a<x,Lx> + a^2 ||Lx||^2
  mpStep_contraction:  ||mpStep(x)||^2 <= (1 - a*mu*(2 - a*lam)) ||x||^2
  quadform_iterate_bound:  ||T^k x||^2 <= rho^k ||x||^2
  spectral_depth_threshold:  finite K with residual < eps
"""

from __future__ import annotations

import math
from typing import List, Tuple

Vector = List[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
#  Minimal linear algebra (stdlib only)
# --------------------------------------------------------------------------- #
def dot(u: Vector, v: Vector) -> float:
    """Euclidean inner product <u, v>."""
    return sum(ui * vi for ui, vi in zip(u, v))


def norm_sq(v: Vector) -> float:
    """Squared Euclidean norm ||v||^2 = <v, v>."""
    return dot(v, v)


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


def vec_sub(u: Vector, v: Vector) -> Vector:
    return [a - b for a, b in zip(u, v)]


def vec_scale(c: float, v: Vector) -> Vector:
    return [c * a for a in v]


# --------------------------------------------------------------------------- #
#  Core definitions
# --------------------------------------------------------------------------- #
def hodge(B: Matrix) -> Matrix:
    """Up Hodge Laplacian L = B^T B."""
    return matmul(transpose(B), B)


def mp_step(L: Matrix, alpha: float, x: Vector) -> Vector:
    """One message-passing layer: x - alpha * (L x)."""
    return vec_sub(x, vec_scale(alpha, matvec(L, x)))


def mp_iterate(L: Matrix, alpha: float, x: Vector, k: int) -> Vector:
    """Apply k message-passing layers."""
    for _ in range(k):
        x = mp_step(L, alpha, x)
    return x


# --------------------------------------------------------------------------- #
#  Spectral helpers (power iteration; symmetric PSD matrices)
# --------------------------------------------------------------------------- #
def top_eigenvalue(L: Matrix, iters: int = 2000) -> float:
    """Largest eigenvalue lambda of symmetric PSD L via power iteration."""
    n = len(L)
    # A deterministic, asymmetric start vector avoids accidentally landing on
    # an eigenvector (e.g. the harmonic constant vector).
    v: Vector = [math.sin(1.0 + i) for i in range(n)]
    nrm = math.sqrt(norm_sq(v))
    v = vec_scale(1.0 / nrm, v)
    lam = 0.0
    for _ in range(iters):
        w = matvec(L, v)
        nw = math.sqrt(norm_sq(w))
        if nw < 1e-15:
            return 0.0
        v = vec_scale(1.0 / nw, w)
        lam = dot(v, matvec(L, v))
    return lam


def smallest_nonzero_eigenvalue(L: Matrix, tol: float = 1e-8) -> float:
    """Smallest *nonzero* eigenvalue mu (the spectral gap), via deflation."""
    lam = top_eigenvalue(L)
    n = len(L)
    # Shift: M = lam*I - L has eigenvalues lam - eig(L); its top eigenvalue
    # corresponds to the smallest eigenvalue of L. We then walk up to the
    # smallest strictly-positive eigenvalue of L by repeated power iteration
    # on the shifted matrix with deflation of (near-)zero modes is overkill
    # for the small examples here; instead compute the full spectrum by a
    # simple symmetric Jacobi eigensolver for robustness.
    eigs = sorted(jacobi_eigenvalues(L))
    for e in eigs:
        if e > tol:
            return e
    return 0.0


def jacobi_eigenvalues(A: Matrix, sweeps: int = 100) -> List[float]:
    """Classical Jacobi eigenvalue algorithm for a symmetric matrix."""
    n = len(A)
    M = [row[:] for row in A]
    for _ in range(sweeps):
        off = 0.0
        p, q = 0, 1
        for i in range(n):
            for j in range(i + 1, n):
                if abs(M[i][j]) > off:
                    off = abs(M[i][j])
                    p, q = i, j
        if off < 1e-14:
            break
        if abs(M[p][p] - M[q][q]) < 1e-30:
            theta = math.pi / 4
        else:
            theta = 0.5 * math.atan2(2 * M[p][q], M[p][p] - M[q][q])
        c, s = math.cos(theta), math.sin(theta)
        for k in range(n):
            mkp, mkq = M[k][p], M[k][q]
            M[k][p] = c * mkp + s * mkq
            M[k][q] = -s * mkp + c * mkq
        for k in range(n):
            mpk, mqk = M[p][k], M[q][k]
            M[p][k] = c * mpk + s * mqk
            M[q][k] = -s * mpk + c * mqk
    return [M[i][i] for i in range(n)]


# --------------------------------------------------------------------------- #
#  Example complex: a triangle boundary (a 1-dimensional loop)
# --------------------------------------------------------------------------- #
def triangle_loop_incidence() -> Matrix:
    """
    Vertex-edge incidence matrix B (the boundary operator d_1) for a triangle:
    vertices {0,1,2}, edges e0=(0,1), e1=(1,2), e2=(2,0).

    Rows = vertices (3), columns = edges (3). The Hodge Laplacian L = B^T B is
    then the 3x3 edge Laplacian. The harmonic space (ker L) is 1-dimensional:
    it is the homology class of the loop -- a topological invariant (b_1 = 1).
    """
    #            e0   e1   e2
    return [
        [-1.0, 0.0, 1.0],   # vertex 0
        [1.0, -1.0, 0.0],   # vertex 1
        [0.0, 1.0, -1.0],   # vertex 2
    ]


def harmonic_loop_signal() -> Vector:
    """The circulating signal (1,1,1) around the triangle: a harmonic cochain."""
    return [1.0, 1.0, 1.0]


def path_graph_incidence() -> Matrix:
    """
    Edge-vertex incidence matrix B for the path graph on 4 vertices with edges
    (0,1), (1,2), (2,3). Rows = edges (3), columns = vertices (4).

    Then L = B^T B is the 4x4 graph (vertex) Laplacian of the path. Its
    spectrum is {0, 2-sqrt2, 2, 2+sqrt2}, so the spectral gap mu = 2-sqrt2 is
    strictly below the top eigenvalue lambda = 2+sqrt2 (condition number > 1),
    giving a non-degenerate contraction factor 0 < rho < 1. The harmonic space
    (ker L) is the constants -- one per connected component (b_0 = 1).
    """
    #          v0    v1    v2    v3
    return [
        [-1.0, 1.0, 0.0, 0.0],   # edge (0,1)
        [0.0, -1.0, 1.0, 0.0],   # edge (1,2)
        [0.0, 0.0, -1.0, 1.0],   # edge (2,3)
    ]


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_dirichlet_energy_and_psd() -> None:
    print("=" * 70)
    print("DEMO 1 -- Dirichlet energy identity and positive semidefiniteness")
    print("=" * 70)
    B = triangle_loop_incidence()
    L = hodge(B)
    for x in ([1.0, 0.0, 0.0], [2.0, -1.0, 3.0], [0.5, 0.5, -1.5]):
        lhs = dot(x, matvec(L, x))            # <x, L x>
        rhs = norm_sq(matvec(B, x))           # ||B x||^2
        print(f"  x={x}")
        print(f"    <x, L x> = {lhs:.6f},  ||B x||^2 = {rhs:.6f}  (equal? "
              f"{math.isclose(lhs, rhs, abs_tol=1e-9)})")
        print(f"    energy >= 0 ? {lhs >= -1e-12}")
    print()


def demo_discrete_hodge() -> None:
    print("=" * 70)
    print("DEMO 2 -- Discrete Hodge theorem: L x = 0  <=>  B x = 0")
    print("=" * 70)
    B = triangle_loop_incidence()
    L = hodge(B)
    x = harmonic_loop_signal()
    Lx = matvec(L, x)
    Bx = matvec(B, x)
    print(f"  harmonic loop signal x = {x}")
    print(f"    L x = {[round(v, 9) for v in Lx]}  (zero? {norm_sq(Lx) < 1e-12})")
    print(f"    B x = {[round(v, 9) for v in Bx]}  (zero? {norm_sq(Bx) < 1e-12})")
    print("  => the harmonic space encodes the loop (b_1 = 1), a topological "
          "invariant.")
    print()


def demo_harmonic_immortal() -> None:
    print("=" * 70)
    print("DEMO 3 -- Harmonic signals are exact fixed points at every depth")
    print("=" * 70)
    B = triangle_loop_incidence()
    L = hodge(B)
    alpha = 0.3
    x = harmonic_loop_signal()
    for k in (1, 5, 50, 1000):
        xk = mp_iterate(L, alpha, x, k)
        drift = math.sqrt(norm_sq(vec_sub(xk, x)))
        print(f"  depth k={k:>5}:  ||mpStep^k(x) - x|| = {drift:.3e}")
    print("  => topology passes through arbitrarily deep networks undistorted.")
    print()


def demo_energy_expansion_and_contraction() -> None:
    print("=" * 70)
    print("DEMO 4 -- Exact energy expansion and one-layer contraction")
    print("=" * 70)
    B = path_graph_incidence()
    L = hodge(B)
    lam = top_eigenvalue(L)
    mu = smallest_nonzero_eigenvalue(L)
    alpha = 1.0 / lam  # optimal admissible step
    print(f"  spectral data: mu (gap) = {mu:.6f}, lambda (top) = {lam:.6f}")
    print(f"  step alpha = 1/lambda = {alpha:.6f}  (admissible: alpha*lam={alpha*lam:.3f} <= 2)")
    rho = 1.0 - alpha * mu * (2.0 - alpha * lam)
    print(f"  predicted contraction factor rho = 1 - a*mu*(2 - a*lam) = {rho:.6f}")
    # An energy-carrying signal orthogonal to the harmonic constants (sum 0).
    x = [1.0, -2.0, 0.5, 0.5]
    lhs = norm_sq(mp_step(L, alpha, x))
    exact = (norm_sq(x) - 2 * alpha * dot(x, matvec(L, x))
             + alpha ** 2 * norm_sq(matvec(L, x)))
    print(f"  x = {x}")
    print(f"    ||mpStep(x)||^2          = {lhs:.6f}")
    print(f"    exact expansion formula  = {exact:.6f}  (equal? "
          f"{math.isclose(lhs, exact, abs_tol=1e-9)})")
    print(f"    contraction bound rho*||x||^2 = {rho * norm_sq(x):.6f}  "
          f"(holds? {lhs <= rho * norm_sq(x) + 1e-9})")
    print()


def demo_geometric_decay_and_threshold() -> None:
    print("=" * 70)
    print("DEMO 5 -- Geometric decay rho^k and the spectral depth threshold")
    print("=" * 70)
    B = path_graph_incidence()
    L = hodge(B)
    lam = top_eigenvalue(L)
    mu = smallest_nonzero_eigenvalue(L)
    alpha = 1.0 / lam
    rho = 1.0 - alpha * mu * (2.0 - alpha * lam)

    # A purely energy-carrying signal: orthogonal to the harmonic constants.
    x = [1.0, -1.0, 1.0, -1.0]   # sums to zero => orthogonal to constants
    e0 = norm_sq(x)
    eps = 1e-6
    K = depth_threshold(rho, e0, eps)
    print(f"  rho = {rho:.6f}, initial energy ||x||^2 = {e0:.6f}, tol eps = {eps}")
    print(f"  predicted threshold K = ceil(log(eps/||x||^2)/log rho) = {K}")
    print("  depth   measured ||T^k x||^2     bound rho^k ||x||^2")
    for k in (0, 5, 10, 20, K):
        xk = mp_iterate(L, alpha, x, k)
        meas = norm_sq(xk)
        bound = rho ** k * e0
        print(f"  {k:>5}   {meas:>18.3e}     {bound:>18.3e}")
    xK = mp_iterate(L, alpha, x, K)
    print(f"  residual at K = {norm_sq(xK):.3e}  (< eps? {norm_sq(xK) < eps})")
    print()


def depth_threshold(rho: float, init_energy: float, eps: float) -> int:
    """Smallest depth K with rho^K * init_energy <= eps (Theorem 5.4)."""
    if init_energy <= eps:
        return 0
    if not (0.0 <= rho < 1.0):
        raise ValueError("need 0 <= rho < 1 for a finite threshold")
    return math.ceil(math.log(eps / init_energy) / math.log(rho))


def main() -> None:
    demo_dirichlet_energy_and_psd()
    demo_discrete_hodge()
    demo_harmonic_immortal()
    demo_energy_expansion_and_contraction()
    demo_geometric_decay_and_threshold()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
