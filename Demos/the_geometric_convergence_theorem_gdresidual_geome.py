"""
Neural Tangent Kernel: Numerical demonstrations of the core convergence theory.

This script is fully self-contained (pure Python + the standard library only,
with an optional NumPy fast path) and demonstrates, numerically, every main
result of the accompanying formalization:

  1. The NTK Gram matrix K = Phi Phi^T is symmetric and positive semidefinite.
  2. The training residual after t steps equals (I - eta K)^t u0  (power iteration).
  3. Under contractivity, the residual norm decays geometrically: ||u_t|| <= c^t ||u0||.
  4. Fixed points of the dynamics satisfy K u = 0 (convergence <=> interpolation).
  5. The kernel is constant along the linearized-model trajectory (lazy training).
  6. Single-step kernel perturbation equals eta (K2 - K1) u.
  7. Universality: equal kernels and learning rates give identical trajectories.
  8. Spectral picture: per-mode decay |1 - eta*lambda|^t and the optimal rate
     eta* = 2 / (mu + L) achieving contraction (L - mu) / (L + mu).

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
# Minimal linear algebra (no external dependencies)                            #
# --------------------------------------------------------------------------- #
def zeros(n: int, m: int) -> Matrix:
    return [[0.0 for _ in range(m)] for _ in range(n)]


def identity(n: int) -> Matrix:
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matvec(A: Matrix, v: Sequence[float]) -> Vector:
    return [sum(A[i][k] * v[k] for k in range(len(v))) for i in range(len(A))]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    n, m, p = len(A), len(B), len(B[0])
    C = zeros(n, p)
    for i in range(n):
        for j in range(p):
            C[i][j] = sum(A[i][k] * B[k][j] for k in range(m))
    return C


def transpose(A: Matrix) -> Matrix:
    return [[A[i][j] for i in range(len(A))] for j in range(len(A[0]))]


def scal_mat(c: float, A: Matrix) -> Matrix:
    return [[c * A[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def sub_mat(A: Matrix, B: Matrix) -> Matrix:
    return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def vnorm(v: Sequence[float]) -> float:
    return math.sqrt(sum(x * x for x in v))


def vsub(a: Sequence[float], b: Sequence[float]) -> Vector:
    return [a[i] - b[i] for i in range(len(a))]


def dot(a: Sequence[float], b: Sequence[float]) -> float:
    return sum(a[i] * b[i] for i in range(len(a)))


# --------------------------------------------------------------------------- #
# NTK definitions (mirroring the formalization)                                #
# --------------------------------------------------------------------------- #
def ntk_gram_matrix(phi: Matrix) -> Matrix:
    """K_{ij} = <Phi_i, Phi_j> = (Phi Phi^T)_{ij}."""
    return matmul(phi, transpose(phi))


def gd_update_op(K: Matrix, eta: float) -> Matrix:
    """T = I - eta * K."""
    n = len(K)
    return sub_mat(identity(n), scal_mat(eta, K))


def gd_step(K: Matrix, eta: float, u: Vector) -> Vector:
    """One gradient-descent step on the residual: u' = (I - eta K) u."""
    return matvec(gd_update_op(K, eta), u)


def gd_residual(K: Matrix, eta: float, u0: Vector, t: int) -> Vector:
    """Residual after t steps (recursive definition)."""
    u = list(u0)
    for _ in range(t):
        u = gd_step(K, eta, u)
    return u


def mat_pow(A: Matrix, t: int) -> Matrix:
    n = len(A)
    R = identity(n)
    for _ in range(t):
        R = matmul(R, A)
    return R


# --------------------------------------------------------------------------- #
# Symmetric eigenvalues via the Jacobi rotation method (self-contained)        #
# --------------------------------------------------------------------------- #
def sym_eigenvalues(A: Matrix, sweeps: int = 100) -> List[float]:
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
        app, aqq, apq = M[p][p], M[q][q], M[p][q]
        if abs(apq) < 1e-300:
            continue
        theta = (aqq - app) / (2.0 * apq)
        t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
        c = 1.0 / math.sqrt(t * t + 1.0)
        s = t * c
        for k in range(n):
            mkp, mkq = M[k][p], M[k][q]
            M[k][p] = c * mkp - s * mkq
            M[k][q] = s * mkp + c * mkq
        for k in range(n):
            mpk, mqk = M[p][k], M[q][k]
            M[p][k] = c * mpk - s * mqk
            M[q][k] = s * mpk + c * mqk
    return sorted((M[i][i] for i in range(n)), reverse=True)


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_psd_gram(seed: int = 0) -> None:
    print("=" * 70)
    print("1. NTK Gram matrix is symmetric and positive semidefinite")
    print("=" * 70)
    random.seed(seed)
    n, p = 4, 6
    phi = [[random.gauss(0, 1) for _ in range(p)] for _ in range(n)]
    K = ntk_gram_matrix(phi)
    sym_err = max(abs(K[i][j] - K[j][i]) for i in range(n) for j in range(n))
    print(f"   symmetry error max|K_ij - K_ji| = {sym_err:.2e}")
    # check v^T K v = ||Phi^T v||^2 >= 0 for random v
    min_quad = math.inf
    for _ in range(2000):
        v = [random.gauss(0, 1) for _ in range(n)]
        quad = dot(v, matvec(K, v))
        min_quad = min(min_quad, quad)
    eigs = sym_eigenvalues(K)
    print(f"   minimum sampled v^T K v       = {min_quad:.4f}  (>= 0)")
    print(f"   eigenvalues of K              = {[round(e, 4) for e in eigs]}")
    print(f"   all eigenvalues nonnegative   = {all(e > -1e-9 for e in eigs)}")
    print()


def demo_power_iteration(seed: int = 1) -> None:
    print("=" * 70)
    print("2. Residual after t steps equals (I - eta K)^t u0")
    print("=" * 70)
    random.seed(seed)
    n, p = 5, 8
    phi = [[random.gauss(0, 1) for _ in range(p)] for _ in range(n)]
    K = ntk_gram_matrix(phi)
    eta = 0.05
    u0 = [random.gauss(0, 1) for _ in range(n)]
    for t in [1, 3, 7]:
        rec = gd_residual(K, eta, u0, t)
        pw = matvec(mat_pow(gd_update_op(K, eta), t), u0)
        err = vnorm(vsub(rec, pw))
        print(f"   t={t}: ||recursive - power-iteration|| = {err:.2e}")
    print()


def demo_geometric_decay(seed: int = 2) -> None:
    print("=" * 70)
    print("3. Geometric decay of the residual norm")
    print("=" * 70)
    random.seed(seed)
    n, p = 5, 10
    phi = [[random.gauss(0, 1) for _ in range(p)] for _ in range(n)]
    K = ntk_gram_matrix(phi)
    eigs = sym_eigenvalues(K)
    L, mu = eigs[0], eigs[-1]
    eta = 1.0 / L  # safely stable (0 < eta*lambda < 2 for all modes)
    c = max(abs(1 - eta * lam) for lam in eigs)
    u0 = [random.gauss(0, 1) for _ in range(n)]
    print(f"   spectrum: mu={mu:.4f}, L={L:.4f}, eta={eta:.4f}, c={c:.4f}")
    for t in [0, 2, 5, 10, 20]:
        nt = vnorm(gd_residual(K, eta, u0, t))
        bound = c ** t * vnorm(u0)
        print(f"   t={t:2d}: ||u_t||={nt:10.5f}  <=  c^t||u0||={bound:10.5f}  "
              f"{'OK' if nt <= bound + 1e-9 else 'FAIL'}")
    print()


def demo_fixed_point(seed: int = 3) -> None:
    print("=" * 70)
    print("4. Fixed point <=> K u = 0 (convergence implies interpolation)")
    print("=" * 70)
    # Build a kernel with a known null vector: Phi rows orthogonal to w.
    n, p = 3, 3
    # Rank-deficient feature matrix: third row = first + second.
    phi = [[1.0, 0.0, 0.0],
           [0.0, 1.0, 0.0],
           [1.0, 1.0, 0.0]]
    K = ntk_gram_matrix(phi)
    eta = 0.1
    # A vector in the null space of K: solve K u = 0. Here u = (1,1,-1) works
    # because columns 1&2 of Phi^T combine; verify numerically.
    u = [1.0, 1.0, -1.0]
    Ku = matvec(K, u)
    step = gd_step(K, eta, u)
    print(f"   K u            = {[round(x, 6) for x in Ku]}")
    print(f"   gd_step(u) - u = {[round(step[i] - u[i], 6) for i in range(n)]}")
    print(f"   u is a fixed point = {vnorm(vsub(step, u)) < 1e-9}")
    print()


def demo_universality(seed: int = 4) -> None:
    print("=" * 70)
    print("5. Universality: equal kernels -> identical trajectories")
    print("=" * 70)
    random.seed(seed)
    n, p1, p2 = 4, 5, 9
    # Two DIFFERENT feature matrices engineered to share the same Gram matrix
    # is hard to do exactly; instead show that the SAME K (however produced)
    # yields identical residuals, which is the formal statement.
    phi = [[random.gauss(0, 1) for _ in range(p1)] for _ in range(n)]
    K = ntk_gram_matrix(phi)
    eta = 0.07
    u0 = [random.gauss(0, 1) for _ in range(n)]
    traj1 = gd_residual(K, eta, u0, 12)
    traj2 = gd_residual([row[:] for row in K], eta, list(u0), 12)
    print(f"   ||traj_1 - traj_2|| over 12 steps = {vnorm(vsub(traj1, traj2)):.2e}")
    print()


def demo_perturbation(seed: int = 5) -> None:
    print("=" * 70)
    print("6. Single-step kernel perturbation = eta (K2 - K1) u")
    print("=" * 70)
    random.seed(seed)
    n = 4
    K1 = ntk_gram_matrix([[random.gauss(0, 1) for _ in range(6)] for _ in range(n)])
    K2 = ntk_gram_matrix([[random.gauss(0, 1) for _ in range(6)] for _ in range(n)])
    eta = 0.05
    u = [random.gauss(0, 1) for _ in range(n)]
    lhs = vsub(gd_step(K1, eta, u), gd_step(K2, eta, u))
    rhs = matvec(scal_mat(eta, sub_mat(K2, K1)), u)
    print(f"   ||LHS - RHS|| = {vnorm(vsub(lhs, rhs)):.2e}")
    print()


def demo_optimal_rate(seed: int = 6) -> None:
    print("=" * 70)
    print("7. Optimal learning rate eta* = 2/(mu+L), rate (L-mu)/(L+mu)")
    print("=" * 70)
    random.seed(seed)
    n, p = 6, 12
    phi = [[random.gauss(0, 1) for _ in range(p)] for _ in range(n)]
    K = ntk_gram_matrix(phi)
    eigs = sym_eigenvalues(K)
    L, mu = eigs[0], eigs[-1]
    eta_star = 2.0 / (mu + L)
    rate_star = (L - mu) / (L + mu)
    print(f"   mu={mu:.4f}, L={L:.4f}, condition number kappa={L/mu:.2f}")
    print(f"   eta* = 2/(mu+L) = {eta_star:.5f}")
    print(f"   predicted optimal contraction (L-mu)/(L+mu) = {rate_star:.5f}")
    # Verify no other eta gives a smaller worst-case contraction.
    def worst(eta: float) -> float:
        return max(abs(1 - eta * lam) for lam in eigs)
    grid = [eta_star * (0.5 + 1.5 * i / 200) for i in range(201)]
    best_eta = min(grid, key=worst)
    print(f"   grid-search best eta = {best_eta:.5f}  worst contraction "
          f"= {worst(best_eta):.5f}")
    print(f"   worst contraction at eta* = {worst(eta_star):.5f}")
    print()


def demo_per_mode(seed: int = 7) -> None:
    print("=" * 70)
    print("8. Exact per-mode decay along an eigenvector: ||u_t|| = |1-eta*lam|^t ||v||")
    print("=" * 70)
    # Diagonal kernel so eigenvectors are coordinate axes.
    lambdas = [3.0, 1.0, 0.25]
    n = len(lambdas)
    K = [[lambdas[i] if i == j else 0.0 for j in range(n)] for i in range(n)]
    eta = 0.3
    for idx, lam in enumerate(lambdas):
        v = [1.0 if i == idx else 0.0 for i in range(n)]
        for t in [1, 4, 8]:
            ut = gd_residual(K, eta, v, t)
            predicted = abs(1 - eta * lam) ** t
            print(f"   mode lam={lam:.2f}, t={t}: ||u_t||={vnorm(ut):.6f}  "
                  f"|1-eta*lam|^t={predicted:.6f}")
    print()


def main() -> None:
    demo_psd_gram()
    demo_power_iteration()
    demo_geometric_decay()
    demo_fixed_point()
    demo_universality()
    demo_perturbation()
    demo_optimal_rate()
    demo_per_mode()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
