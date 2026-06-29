"""
Neural Network Training as Renormalization Group (RG) Flow
==========================================================

Numerical demonstrations of the results formalized in
`Catalog/MachineLearning/RGFlowTraining.lean`.

Conceptual dictionary
---------------------
* Coarse-graining (RG) step  -> idempotent linear operator  P  (P @ P == P).
* Residual / irrelevant part -> R = I - P   (R x = x - P x).
* Relevance loss             -> L(x) = 1/2 * ||x - P x||^2 ,  gradient = R x.
* RG training flow           -> theta(t) = P x0 + exp(-t) * (x0 - P x0).

We verify, with plain Python (no third-party dependencies required), each of the
ten formalized theorems on concrete numerical examples:

  T1  rgResidual_apply            R x = x - P x
  T2  rg_sgd_fixedPoint_iff       R x = 0  <=>  P x = x
  T3  rg_fixedPoint_iff_mem_range P x = x  <=>  x in range(P)
  T4  rgFlow_zero                 theta(0) = x0
  T5  rgFlow_proj                 P(theta(t)) = P x0
  T6  rgFlow_hasDerivAt           theta'(t) = -R(theta(t))
  T7  rgFlow_dist                 ||theta(t)-Px0|| = exp(-t)||x0-Px0||
  T8  rgFlow_tendsto              theta(t) -> P x0
  T9  rgFlow_limit_isFixedPoint   P(P x0) = P x0
  T10 rg_universality             P x0 = P y0  =>  same limit
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


# ----------------------------------------------------------------------------
# Minimal linear algebra (pure Python, no numpy needed)
# ----------------------------------------------------------------------------
def mat_vec(P: Matrix, x: Sequence[float]) -> Vector:
    """Matrix-vector product P @ x."""
    return [sum(P[i][j] * x[j] for j in range(len(x))) for i in range(len(P))]


def mat_mat(A: Matrix, B: Matrix) -> Matrix:
    """Matrix-matrix product A @ B."""
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]


def vec_sub(a: Sequence[float], b: Sequence[float]) -> Vector:
    return [ai - bi for ai, bi in zip(a, b)]


def vec_add(a: Sequence[float], b: Sequence[float]) -> Vector:
    return [ai + bi for ai, bi in zip(a, b)]


def vec_scale(c: float, a: Sequence[float]) -> Vector:
    return [c * ai for ai in a]


def norm(a: Sequence[float]) -> float:
    return math.sqrt(sum(ai * ai for ai in a))


def allclose(a: Sequence[float], b: Sequence[float], tol: float = 1e-9) -> bool:
    return all(abs(ai - bi) <= tol for ai, bi in zip(a, b))


# ----------------------------------------------------------------------------
# Core RG-flow primitives (the math under test)
# ----------------------------------------------------------------------------
def residual(P: Matrix, x: Sequence[float]) -> Vector:
    """R x = x - P x   (T1: rgResidual_apply)."""
    return vec_sub(list(x), mat_vec(P, x))


def relevance_loss(P: Matrix, x: Sequence[float]) -> float:
    """L(x) = 1/2 ||x - P x||^2 ; its gradient is residual(P, x)."""
    r = residual(P, x)
    return 0.5 * sum(ri * ri for ri in r)


def rg_flow(P: Matrix, x0: Sequence[float], t: float) -> Vector:
    """theta(t) = P x0 + exp(-t) (x0 - P x0)   (Definition 2.5)."""
    Px0 = mat_vec(P, x0)
    return vec_add(Px0, vec_scale(math.exp(-t), vec_sub(list(x0), Px0)))


def is_idempotent(P: Matrix, tol: float = 1e-9) -> bool:
    """Check P @ P == P (idempotency / 'blurring twice = blurring once')."""
    PP = mat_mat(P, P)
    return all(abs(PP[i][j] - P[i][j]) <= tol for i in range(len(P)) for j in range(len(P[0])))


def orthogonal_projector(basis: Sequence[Sequence[float]]) -> Matrix:
    """
    Build the orthogonal projector P onto span(basis) via Gram-Schmidt.
    P = Q Q^T with Q's columns an orthonormal basis of the relevant subspace.
    The result is idempotent and self-adjoint by construction.
    """
    # Gram-Schmidt to get orthonormal vectors q_k
    qs: List[Vector] = []
    for v in basis:
        w = list(map(float, v))
        for q in qs:
            proj = sum(wi * qi for wi, qi in zip(w, q))
            w = [wi - proj * qi for wi, qi in zip(w, q)]
        nw = norm(w)
        if nw > 1e-12:
            qs.append([wi / nw for wi in w])
    d = len(basis[0])
    # P[i][j] = sum_k q_k[i] q_k[j]
    return [[sum(q[i] * q[j] for q in qs) for j in range(d)] for i in range(d)]


# ----------------------------------------------------------------------------
# Demonstrations of the ten theorems
# ----------------------------------------------------------------------------
def demo_fixed_point_correspondence() -> None:
    """T1, T2, T3: SGD critical points = RG fixed points = range(P)."""
    print("=" * 70)
    print("Demo 1: Fixed-point correspondence  (Theorems 1-3)")
    print("=" * 70)
    # Project onto the x-y plane in R^3 (relevant subspace), drop the z axis.
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    assert is_idempotent(P), "P must be idempotent"
    print(f"  Coarse-graining P projects onto the x-y plane; idempotent: {is_idempotent(P)}")

    # A fixed point: already in the relevant subspace.
    fp = [3.0, -2.0, 0.0]
    print(f"  x = {fp}:  R x = {residual(P, fp)} (zero), P x = x ? {allclose(mat_vec(P, fp), fp)}")
    assert allclose(residual(P, fp), [0, 0, 0])         # T2: R x = 0
    assert allclose(mat_vec(P, fp), fp)                 # <=> P x = x

    # A non-fixed point: has irrelevant z-content.
    nfp = [3.0, -2.0, 5.0]
    r = residual(P, nfp)
    print(f"  x = {nfp}:  R x = {r} (irrelevant z-mode), loss L = {relevance_loss(P, nfp):.3f}")
    assert not allclose(r, [0, 0, 0])

    # T3: fixed points are exactly the range of P. P x always lies in range(P)
    # and is a fixed point:
    Pnfp = mat_vec(P, nfp)
    assert allclose(mat_vec(P, Pnfp), Pnfp)
    print(f"  P x = {Pnfp} lies in range(P) and is a fixed point. [T1,T2,T3 OK]\n")


def demo_flow_and_ode() -> None:
    """T4, T5, T6: flow starts at x0, conserves P x0, solves theta' = -R theta."""
    print("=" * 70)
    print("Demo 2: The training flow solves the gradient ODE  (Theorems 4-6)")
    print("=" * 70)
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    x0 = [1.0, 2.0, 4.0]

    # T4: theta(0) = x0
    assert allclose(rg_flow(P, x0, 0.0), x0)
    print(f"  theta(0) = {rg_flow(P, x0, 0.0)} = x0 .  [T4 OK]")

    # T5: P(theta(t)) = P x0 for all t
    Px0 = mat_vec(P, x0)
    for t in (0.0, 0.5, 1.7, 5.0):
        assert allclose(mat_vec(P, rg_flow(P, x0, t)), Px0)
    print(f"  P(theta(t)) = {Px0} conserved for all t (slow modes frozen).  [T5 OK]")

    # T6: theta'(t) = -R(theta(t)), checked by finite differences
    h = 1e-6
    max_err = 0.0
    for t in (0.0, 0.5, 1.7, 3.0):
        numeric = vec_scale(1.0 / (2 * h),
                            vec_sub(rg_flow(P, x0, t + h), rg_flow(P, x0, t - h)))
        analytic = vec_scale(-1.0, residual(P, rg_flow(P, x0, t)))
        max_err = max(max_err, norm(vec_sub(numeric, analytic)))
    print(f"  max |theta'(t) - (-R theta(t))| over sampled t = {max_err:.2e}.  [T6 OK]\n")
    assert max_err < 1e-5


def demo_exponential_relaxation() -> None:
    """T7, T8, T9: exact exponential decay, convergence, limit is fixed point."""
    print("=" * 70)
    print("Demo 3: Exact exponential relaxation & convergence  (Theorems 7-9)")
    print("=" * 70)
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    x0 = [1.0, 2.0, 4.0]
    Px0 = mat_vec(P, x0)
    d0 = norm(vec_sub(list(x0), Px0))
    print(f"  ||x0 - P x0|| = {d0:.6f}  (initial irrelevant content)")
    print(f"  {'t':>5} | {'||theta(t)-Px0||':>18} | {'exp(-t)*||x0-Px0||':>20}")
    for t in (0.0, 1.0, 2.0, 5.0, 10.0):
        lhs = norm(vec_sub(rg_flow(P, x0, t), Px0))
        rhs = math.exp(-t) * d0
        assert abs(lhs - rhs) < 1e-9          # T7: exact equality
        print(f"  {t:5.1f} | {lhs:18.10f} | {rhs:20.10f}")
    # T8: theta(t) -> P x0 ; T9: P(P x0) = P x0
    far = rg_flow(P, x0, 40.0)
    assert allclose(far, Px0, tol=1e-12)
    assert allclose(mat_vec(P, Px0), Px0)
    print(f"  theta(40) = {[round(v, 12) for v in far]} -> P x0 (a fixed point).  [T7,T8,T9 OK]\n")


def demo_universality() -> None:
    """T10: same coarse-grained class => same limiting fixed point."""
    print("=" * 70)
    print("Demo 4: Universality  (Theorem 10)")
    print("=" * 70)
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    # Two very different initializations that agree after coarse-graining:
    # they share x,y but differ wildly in the irrelevant z-direction.
    x0 = [1.0, 2.0, 4.0]
    y0 = [1.0, 2.0, -97.0]
    print(f"  x0 = {x0}")
    print(f"  y0 = {y0}  (same x,y; wildly different irrelevant z)")
    print(f"  P x0 = {mat_vec(P, x0)},  P y0 = {mat_vec(P, y0)}  -> same class")
    assert allclose(mat_vec(P, x0), mat_vec(P, y0))
    lim_x = rg_flow(P, x0, 50.0)
    lim_y = rg_flow(P, y0, 50.0)
    assert allclose(lim_x, lim_y, tol=1e-12)
    print(f"  lim theta_x = {[round(v, 10) for v in lim_x]}")
    print(f"  lim theta_y = {[round(v, 10) for v in lim_y]}")
    print(f"  Same destination, despite different microscopic init.  [T10 OK]\n")


def demo_discrete_vs_continuous() -> None:
    """Discrete SGD  theta_{n+1} = theta_n - eta R theta_n  matches the flow."""
    print("=" * 70)
    print("Demo 5: Discrete gradient descent reproduces the continuous flow")
    print("=" * 70)
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    x0 = [1.0, 2.0, 4.0]
    dt = 0.1
    eta = 1.0 - math.exp(-dt)   # step size matching exp decay over dt
    theta = list(x0)
    print(f"  step size eta = 1 - exp(-dt) = {eta:.6f},  dt = {dt}")
    print(f"  {'n':>4} | {'t':>5} | {'||SGD - flow||':>16}")
    max_err = 0.0
    for n in range(0, 51):
        t = n * dt
        flow = rg_flow(P, x0, t)
        err = norm(vec_sub(theta, flow))
        max_err = max(max_err, err)
        if n % 10 == 0:
            print(f"  {n:4d} | {t:5.1f} | {err:16.2e}")
        # one SGD step on the relevance loss (gradient = residual)
        theta = vec_sub(theta, vec_scale(eta, residual(P, theta)))
    print(f"  max discrete-vs-continuous gap = {max_err:.2e} (machine precision).\n")
    assert max_err < 1e-9


def estimate_critical_exponent() -> float:
    """
    Estimate the critical exponent (beta-function slope) from the flow by
    fitting log ||theta(t) - Px0|| vs t.  The theory predicts slope = -1.
    """
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])
    x0 = [1.0, 2.0, 4.0]
    Px0 = mat_vec(P, x0)
    ts = [0.5 * k for k in range(1, 11)]
    ys = [math.log(norm(vec_sub(rg_flow(P, x0, t), Px0))) for t in ts]
    n = len(ts)
    tbar = sum(ts) / n
    ybar = sum(ys) / n
    slope = sum((t - tbar) * (y - ybar) for t, y in zip(ts, ys)) / \
            sum((t - tbar) ** 2 for t in ts)
    return slope


def demo_critical_exponent() -> None:
    print("=" * 70)
    print("Demo 6: The critical exponent (beta-function slope) is exactly 1")
    print("=" * 70)
    slope = estimate_critical_exponent()
    print(f"  Fitted decay rate from log||theta(t)-Px0|| vs t: {-slope:.10f}")
    print(f"  Theory: critical exponent = 1 (irrelevant direction).  ", end="")
    print("[OK]" if abs(-slope - 1.0) < 1e-9 else "[MISMATCH]")
    print()


def main() -> None:
    print("\nNeural Network Training as Renormalization Group Flow")
    print("Numerical verification of all ten formalized theorems\n")
    demo_fixed_point_correspondence()
    demo_flow_and_ode()
    demo_exponential_relaxation()
    demo_universality()
    demo_discrete_vs_continuous()
    demo_critical_exponent()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()


"""
Visualization: RG training flow as exponential relaxation onto the relevant
manifold, with universality of the limit.

Generates two panels:
  (left)  3D trajectories of several initializations sharing the same coarse-
          grained class P x0; all glide onto the same fixed point on the
          relevant manifold (the x-y plane).
  (right) Exact exponential decay  ||theta(t) - P x0|| = exp(-t) ||x0 - P x0||
          on a log scale (a straight line of slope -1 = the critical exponent).

Requires: numpy, matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401


def orthogonal_projector(basis: List[List[float]]) -> np.ndarray:
    """Orthogonal projector P = Q Q^T onto span(basis); idempotent & symmetric."""
    Q, _ = np.linalg.qr(np.array(basis, dtype=float).T)
    return Q @ Q.T


def rg_flow(P: np.ndarray, x0: np.ndarray, t: float) -> np.ndarray:
    """theta(t) = P x0 + exp(-t)(x0 - P x0)."""
    Px0 = P @ x0
    return Px0 + math.exp(-t) * (x0 - Px0)


def main() -> None:
    # Coarse-grain onto the x-y plane (the relevant manifold); z is irrelevant.
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])

    # Several initializations in the SAME coarse-grained class (same x,y).
    inits = [
        np.array([1.0, 2.0, 4.0]),
        np.array([1.0, 2.0, -3.0]),
        np.array([1.0, 2.0, 6.0]),
        np.array([1.0, 2.0, -6.0]),
    ]
    Px0 = P @ inits[0]
    ts = np.linspace(0.0, 6.0, 200)

    fig = plt.figure(figsize=(13, 5.5))

    # ---- Left: 3D trajectories -------------------------------------------
    ax = fig.add_subplot(1, 2, 1, projection="3d")
    # the relevant manifold (x-y plane) as a translucent surface
    xx, yy = np.meshgrid(np.linspace(-1, 3, 2), np.linspace(0, 4, 2))
    ax.plot_surface(xx, yy, np.zeros_like(xx), alpha=0.15, color="gray")
    for x0 in inits:
        traj = np.array([rg_flow(P, x0, t) for t in ts])
        ax.plot(traj[:, 0], traj[:, 1], traj[:, 2], lw=2)
        ax.scatter(*x0, s=30)
    ax.scatter(*Px0, color="red", s=80, marker="*", label="fixed point P x0")
    ax.set_title("RG training flow: all classes glide to the same fixed point")
    ax.set_xlabel("relevant 1"); ax.set_ylabel("relevant 2"); ax.set_zlabel("irrelevant")
    ax.legend()

    # ---- Right: exponential relaxation -----------------------------------
    ax2 = fig.add_subplot(1, 2, 2)
    for x0 in inits:
        dist = [np.linalg.norm(rg_flow(P, x0, t) - Px0) for t in ts]
        ax2.semilogy(ts, dist, lw=2, label=f"x0={x0.tolist()}")
    # reference line exp(-t)*d0 (slope -1 in log scale)
    d0 = np.linalg.norm(inits[0] - Px0)
    ax2.semilogy(ts, d0 * np.exp(-ts), "k--", lw=1, label="exp(-t)·d0 (theory)")
    ax2.set_title("Exact exponential decay (critical exponent = 1)")
    ax2.set_xlabel("training time t")
    ax2.set_ylabel("||theta(t) - P x0||  (log scale)")
    ax2.legend(fontsize=8)
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("rg_flow_visualization.png", dpi=150)
    print("Saved rg_flow_visualization.png")


if __name__ == "__main__":
    main()
