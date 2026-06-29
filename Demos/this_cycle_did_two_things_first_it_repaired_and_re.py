"""
demo.py — Discrete Hodge Theory for Message Passing: Numerical Demonstrations
============================================================================

This script gives concrete numerical life to the abstract theorems of the
discrete-Hodge program.  Everything is built from two "boundary" matrices

    e : C_{k+1} -> C_k     (the *up* / gradient map)
    d : C_k     -> C_{k-1} (the *down* / divergence map)

satisfying the chain condition  d . e = 0.  On the middle space C_k we form the
combinatorial Hodge Laplacian

    Delta = d^T d + e e^T

and verify, on small explicit examples, the following facts that are proved as
formal theorems in the accompanying Lean development:

  1. Quadratic-form identity:  <Delta x, x> = ||d x||^2 + ||e^T x||^2.
  2. Discrete Hodge theorem:   ker Delta = ker d  &  ker e^T  (closed & coclosed).
  3. Hodge-Betti identity:     dim ker Delta + rank e = dim ker d.
  4. Three-way decomposition:  R^n = im(d^T) (+) im(e) (+) ker Delta, orthogonally.
  5. Hodge isomorphism:        ker Delta is a system of representatives for
                               cohomology  H = ker d / im e.
  6. Minimal-norm property:    the harmonic representative is the shortest member
                               of its cohomology class.
  7. Message passing:          T = I - alpha*Delta fixes harmonics and contracts
                               the rest geometrically; alpha = 1/lambda_max is the
                               optimal step.

The only dependency is NumPy.
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# Linear-algebra helpers (thin wrappers, fully inlined, with type hints)
# ---------------------------------------------------------------------------
def rank(A: np.ndarray, tol: float = 1e-9) -> int:
    """Numerical rank of a matrix via its singular values."""
    if A.size == 0:
        return 0
    s = np.linalg.svd(A, compute_uv=False)
    return int(np.sum(s > tol))


def nullspace(A: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthonormal basis (as columns) of the kernel of A."""
    if A.size == 0:
        return np.eye(A.shape[1]) if A.ndim == 2 else np.zeros((0, 0))
    u, s, vh = np.linalg.svd(A)
    n = A.shape[1]
    padded = np.zeros(n)
    padded[: s.shape[0]] = s
    mask = padded <= tol
    return vh[mask].conj().T


def column_space(A: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthonormal basis (as columns) of the column space (image) of A."""
    if A.size == 0 or rank(A, tol) == 0:
        return np.zeros((A.shape[0], 0))
    u, s, vh = np.linalg.svd(A, full_matrices=False)
    r = int(np.sum(s > tol))
    return u[:, :r]


def project_onto(basis: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Orthogonal projection of x onto the span of the orthonormal columns `basis`."""
    if basis.shape[1] == 0:
        return np.zeros_like(x)
    return basis @ (basis.conj().T @ x)


def hodge_laplacian(d: np.ndarray, e: np.ndarray) -> np.ndarray:
    """The combinatorial Hodge Laplacian Delta = d^T d + e e^T on the middle space."""
    return d.T @ d + e @ e.T


# ---------------------------------------------------------------------------
# Example complexes
# ---------------------------------------------------------------------------
def triangle_graph_with_hole() -> tuple[np.ndarray, np.ndarray, str]:
    """
    A graph that is a single triangle (3 nodes, 3 edges) but with NO 2-cell
    filling it in.  The middle space is the edge space C_1 (dimension 3).

      d = e_down : C_1 -> C_0   is the (transposed) node-edge incidence matrix.
      e = e_up   : C_2 -> C_1   is empty (no triangles), so e is 3x0.

    Topology: one connected component (b_0 = 1) and one independent cycle
    (b_1 = 1, the empty triangle).  We work on edges, so the harmonic space has
    dimension b_1 = 1.
    """
    # Oriented incidence: rows = nodes (0,1,2), cols = edges (0->1, 1->2, 2->0)
    # boundary of edge maps to (head - tail). Down map d: C_1 -> C_0.
    d = np.array(
        [
            [-1.0, 0.0, 1.0],   # node 0
            [1.0, -1.0, 0.0],   # node 1
            [0.0, 1.0, -1.0],   # node 2
        ]
    )
    e = np.zeros((3, 0))        # no 2-cells: edge space has no "up" boundary
    return d, e, "Hollow triangle (b_1 = 1)"


def filled_triangle() -> tuple[np.ndarray, np.ndarray, str]:
    """
    The same triangle, but now with the 2-cell (the face) glued in.

      d = e_down : C_1 -> C_0   node-edge incidence  (3 nodes, 3 edges).
      e = e_up   : C_2 -> C_1   edge-face incidence   (3 edges, 1 face).

    Filling the hole kills the cycle: b_1 = 0, so the harmonic space on edges is
    trivial.  This is the chain-condition check d . e = 0 in action.
    """
    d = np.array(
        [
            [-1.0, 0.0, 1.0],
            [1.0, -1.0, 0.0],
            [0.0, 1.0, -1.0],
        ]
    )
    # Face boundary: the 2-cell's boundary is the oriented sum of its edges.
    e = np.array([[1.0], [1.0], [1.0]])  # 3 edges x 1 face
    return d, e, "Filled triangle (b_1 = 0)"


def path_graph_nodes(m: int = 6) -> tuple[np.ndarray, np.ndarray, str]:
    """
    A path graph on `m` nodes, viewed on the NODE space C_0.

      d = down : C_0 -> C_{-1}  is empty (no (-1)-cells), so d is 0 x m.
      e = up   : C_1 -> C_0     is the node-edge incidence (m nodes, m-1 edges).

    Then Delta = e e^T is the ordinary graph Laplacian, whose harmonic space is
    the constants (b_0 = 1 connected component).  A path graph has a non-degenerate
    Laplacian spectrum, so message passing exhibits genuine geometric decay at the
    rate rho = 1 - mu/lambda_max set by the spectral gap mu.
    """
    e = np.zeros((m, m - 1))
    for j in range(m - 1):
        e[j, j] = -1.0
        e[j + 1, j] = 1.0
    d = np.zeros((0, m))
    return d, e, f"Path graph on {m} nodes (b_0 = 1)"


def square_cycle() -> tuple[np.ndarray, np.ndarray, str]:
    """A 4-cycle (square) graph with no faces: b_1 = 1."""
    d = np.array(
        [
            [-1.0, 0.0, 0.0, 1.0],
            [1.0, -1.0, 0.0, 0.0],
            [0.0, 1.0, -1.0, 0.0],
            [0.0, 0.0, 1.0, -1.0],
        ]
    )
    e = np.zeros((4, 0))
    return d, e, "Square 4-cycle (b_1 = 1)"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_quadratic_form_and_hodge_theorem(d: np.ndarray, e: np.ndarray, name: str) -> None:
    print(f"\n===== {name}: quadratic form & discrete Hodge theorem =====")
    Delta = hodge_laplacian(d, e)
    n = Delta.shape[0]
    rng = np.random.default_rng(0)

    # (1) Quadratic-form identity:  <Delta x, x> = ||d x||^2 + ||e^T x||^2
    max_err = 0.0
    for _ in range(5):
        x = rng.standard_normal(n)
        lhs = x @ (Delta @ x)
        rhs = (d @ x) @ (d @ x) + (e.T @ x) @ (e.T @ x)
        max_err = max(max_err, abs(lhs - rhs))
    print(f"  <Delta x, x> = ||d x||^2 + ||e^T x||^2 : max error = {max_err:.2e}")

    # (2) ker Delta = ker d  &  ker e^T
    K_delta = nullspace(Delta)
    closed = nullspace(d)            # ker d
    coclosed = nullspace(e.T) if e.shape[1] > 0 else np.eye(n)  # ker e^T
    dim_delta = K_delta.shape[1]
    # closed AND coclosed = intersection dimension via projector ranks
    P_closed = closed @ closed.T
    P_coclosed = coclosed @ coclosed.T
    inter = rank(P_closed @ P_coclosed @ P_closed)
    print(f"  dim ker Delta = {dim_delta},  dim(ker d & ker e^T) = {inter}")
    print(f"  Hodge theorem (ker Delta = closed & coclosed): {dim_delta == inter}")


def demo_betti(d: np.ndarray, e: np.ndarray, name: str) -> None:
    print(f"\n===== {name}: Hodge-Betti identity =====")
    Delta = hodge_laplacian(d, e)
    dim_harm = nullspace(Delta).shape[1]
    dim_ker_d = nullspace(d).shape[1]
    rank_e = rank(e)
    print(f"  dim ker Delta (Betti number b)      = {dim_harm}")
    print(f"  dim ker d - rank e                  = {dim_ker_d - rank_e}")
    print(f"  identity  b + rank e = dim ker d    : "
          f"{dim_harm + rank_e == dim_ker_d}")


def demo_three_way_decomposition(d: np.ndarray, e: np.ndarray, name: str) -> None:
    print(f"\n===== {name}: three-way orthogonal decomposition =====")
    Delta = hodge_laplacian(d, e)
    n = Delta.shape[0]
    rng = np.random.default_rng(1)

    coexact_basis = column_space(d.T)     # im d^T
    exact_basis = column_space(e)         # im e
    harm_basis = nullspace(Delta)         # ker Delta

    x = rng.standard_normal(n)
    x_coex = project_onto(coexact_basis, x)
    x_ex = project_onto(exact_basis, x)
    x_harm = project_onto(harm_basis, x)

    recon_err = np.linalg.norm(x - (x_coex + x_ex + x_harm))
    # pairwise orthogonality of the three pieces
    o1 = abs(x_coex @ x_ex)
    o2 = abs(x_coex @ x_harm)
    o3 = abs(x_ex @ x_harm)
    print(f"  dims  coexact={coexact_basis.shape[1]}  exact={exact_basis.shape[1]}"
          f"  harmonic={harm_basis.shape[1]}  (sum should be n={n})")
    print(f"  reconstruction error  ||x - (P_co + P_ex + P_h)x|| = {recon_err:.2e}")
    print(f"  pairwise inner products = {o1:.2e}, {o2:.2e}, {o3:.2e}")


def demo_minimal_norm_representative(d: np.ndarray, e: np.ndarray, name: str) -> None:
    print(f"\n===== {name}: harmonic representative is minimal-norm =====")
    Delta = hodge_laplacian(d, e)
    n = Delta.shape[0]
    harm_basis = nullspace(Delta)
    if harm_basis.shape[1] == 0:
        print("  harmonic space is trivial; cohomology is zero, nothing to compare")
        return
    rng = np.random.default_rng(2)
    # pick a nonzero harmonic cochain h
    h = harm_basis @ rng.standard_normal(harm_basis.shape[1])
    norms = []
    for _ in range(2000):
        u = rng.standard_normal(e.shape[1]) if e.shape[1] > 0 else np.zeros(0)
        y = h + (e @ u if e.shape[1] > 0 else 0.0)   # y ~ h in cohomology
        norms.append(np.linalg.norm(y))
    print(f"  ||h||                       = {np.linalg.norm(h):.4f}")
    print(f"  min over 2000 cohomologous y = {min(norms):.4f}")
    print(f"  harmonic is shortest in class: {np.linalg.norm(h) <= min(norms) + 1e-9}")


def demo_message_passing(d: np.ndarray, e: np.ndarray, name: str) -> None:
    print(f"\n===== {name}: message-passing convergence to harmonics =====")
    Delta = hodge_laplacian(d, e)
    n = Delta.shape[0]
    eigvals = np.linalg.eigvalsh(Delta)
    lam_max = float(eigvals[-1])
    pos = eigvals[eigvals > 1e-9]
    if pos.size == 0:
        print("  Delta = 0: every cochain is harmonic, message passing is identity")
        return
    mu = float(pos.min())            # spectral gap (smallest nonzero eigenvalue)
    harm_basis = nullspace(Delta)
    rng = np.random.default_rng(3)
    x0 = rng.standard_normal(n)
    h = project_onto(harm_basis, x0)     # the harmonic target

    alpha = 1.0 / lam_max                # optimal spectral step
    T = np.eye(n) - alpha * Delta
    rho = 1.0 - mu / lam_max             # predicted contraction factor

    print(f"  lambda_max = {lam_max:.4f},  spectral gap mu = {mu:.4f}")
    print(f"  optimal step alpha = 1/lambda_max = {alpha:.4f}")
    print(f"  predicted contraction rate rho = 1 - mu/lambda_max = {rho:.4f}")
    x = x0.copy()
    for k in (1, 2, 4, 8, 16, 32):
        xk = np.linalg.matrix_power(T, k) @ x0
        gap = np.linalg.norm(xk - h)
        bound = (rho ** k) * np.linalg.norm(x0 - h)
        print(f"    depth k={k:3d}:  ||T^k x0 - h|| = {gap:.3e}   (<= rho^k bound "
              f"{bound:.3e}: {gap <= bound + 1e-9})")


def main() -> None:
    examples = [
        triangle_graph_with_hole(),
        filled_triangle(),
        square_cycle(),
        path_graph_nodes(6),
    ]
    for d, e, name in examples:
        demo_quadratic_form_and_hodge_theorem(d, e, name)
        demo_betti(d, e, name)
        demo_three_way_decomposition(d, e, name)
        demo_minimal_norm_representative(d, e, name)
        demo_message_passing(d, e, name)
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
