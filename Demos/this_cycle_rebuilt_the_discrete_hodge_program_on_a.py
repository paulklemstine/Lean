"""
demo.py — Numerical demonstrations of the Discrete Hodge Laplacian program.

This script reproduces, with concrete finite-dimensional matrices, every theorem
established in the formal development:

    U --e--> V --d--> W ,        Delta = d* . d  +  e . e*   acting on V.

We verify, numerically:
  * self-adjointness of Delta;
  * the Dirichlet identity  <Delta x, x> = ||d x||^2 + ||e* x||^2;
  * harmonic  <=>  closed & co-closed  (Delta x = 0  iff  d x = 0 and e* x = 0);
  * strict positivity off the kernel  (<Delta x, x> = 0  iff  Delta x = 0);
  * the image of Delta is orthogonal to ker Delta;
  * diffusion S = I - a*Delta fixes harmonic cochains at every depth;
  * the harmonic projection P is conserved along diffusion: P(S^k x) = P x.

Everything is self-contained (only NumPy).
"""

from __future__ import annotations

import numpy as np

np.random.seed(0)


# ---------------------------------------------------------------------------
# Core operators
# ---------------------------------------------------------------------------
def adjoint(matrix: np.ndarray) -> np.ndarray:
    """Adjoint of a real linear map = matrix transpose (Euclidean inner product)."""
    return matrix.T


def hodge_laplacian(e: np.ndarray, d: np.ndarray) -> np.ndarray:
    """Hodge Laplacian Delta = d* d + e e* on the middle space V.

    Shapes:  e : V x U  (maps U -> V),   d : W x V  (maps V -> W).
    Returns a V x V matrix.
    """
    return adjoint(d) @ d + e @ adjoint(e)


def diff_step(e: np.ndarray, d: np.ndarray, a: float) -> np.ndarray:
    """One explicit-Euler diffusion step S = I - a*Delta as a V x V matrix."""
    dim_v = e.shape[0]
    return np.eye(dim_v) - a * hodge_laplacian(e, d)


def harmonic_basis(delta: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthonormal basis (columns) of ker(Delta), i.e. the harmonic space."""
    # Symmetric eigendecomposition; harmonics = eigenvectors with eigenvalue ~ 0.
    eigvals, eigvecs = np.linalg.eigh(delta)
    cols = [eigvecs[:, i] for i in range(len(eigvals)) if abs(eigvals[i]) < tol]
    if not cols:
        return np.zeros((delta.shape[0], 0))
    return np.column_stack(cols)


def harmonic_projection(delta: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Orthogonal projection P x of x onto ker(Delta)."""
    basis = harmonic_basis(delta)
    if basis.shape[1] == 0:
        return np.zeros_like(x)
    return basis @ (basis.T @ x)


# ---------------------------------------------------------------------------
# A concrete two-step complex on a small graph-like model
# ---------------------------------------------------------------------------
def build_example() -> tuple[np.ndarray, np.ndarray]:
    """A genuine two-step cochain complex with a non-trivial harmonic space.

    We model a 'theta graph': two vertices {0, 1} joined by three parallel
    edges e0, e1, e2 (all oriented 0 -> 1).  The middle space V = R^3 is the
    edge space; U = R^2 is the vertex space; W = R^1 carries a single 2-cell
    whose boundary is the loop  e0 - e1.

      * e : U(2) -> V(3) is the vertex->edge coboundary (ef)(u->v) = f(v)-f(u).
      * d : V(3) -> W(1) is the edge->face coboundary, the chosen 2-cell
        boundary  [1, -1, 0].

    One can check d . e = 0, so this is a genuine cochain complex.  Filling one
    of the theta graph's two independent loops leaves exactly one un-filled
    loop, so the harmonic space ker(Delta) is 1-dimensional (first Betti = 1).
    Crucially BOTH Laplacian terms d* d and e e* are non-trivial here.
    """
    # e : U(2) -> V(3): every edge sees the same vertex difference f1 - f0.
    e = np.array(
        [
            [-1.0, 1.0],
            [-1.0, 1.0],
            [-1.0, 1.0],
        ]
    )
    # d : V(3) -> W(1): boundary of the single filled 2-cell, the loop e0 - e1.
    d = np.array([[1.0, -1.0, 0.0]])
    assert np.allclose(d @ e, 0.0), "d . e must vanish for a genuine complex"
    return e, d


# ---------------------------------------------------------------------------
# Verifications
# ---------------------------------------------------------------------------
def main() -> None:
    e, d = build_example()
    delta = hodge_laplacian(e, d)
    dim_v = e.shape[0]

    print("=" * 70)
    print("Hodge Laplacian Delta =")
    print(delta)

    # 1. Self-adjointness ---------------------------------------------------
    print("\n[1] Self-adjoint:           ", np.allclose(delta, delta.T))

    # 2. Dirichlet identity  <Delta x, x> = ||d x||^2 + ||e* x||^2 ----------
    x = np.random.randn(dim_v)
    lhs = x @ (delta @ x)
    rhs = np.linalg.norm(d @ x) ** 2 + np.linalg.norm(adjoint(e) @ x) ** 2
    print(f"[2] Dirichlet identity:      {lhs:.10f} == {rhs:.10f} ->",
          np.isclose(lhs, rhs))

    # 3. Harmonic <=> closed & co-closed -----------------------------------
    basis = harmonic_basis(delta)
    print(f"[3] dim ker(Delta) (Betti1): {basis.shape[1]}")
    for i in range(basis.shape[1]):
        h = basis[:, i]
        closed = np.allclose(d @ h, 0.0)
        coclosed = np.allclose(adjoint(e) @ h, 0.0)
        print(f"      harmonic vector {i}: closed={closed}, co-closed={coclosed}")

    # 4. Strict positivity off the kernel ----------------------------------
    quad = x @ (delta @ x)
    print(f"[4] Rayleigh form on generic x > 0: {quad:.6f} >",
          0.0, "->", quad > 0)

    # 5. Image of Delta is orthogonal to ker(Delta) ------------------------
    img = delta @ x
    ortho = all(np.isclose(img @ basis[:, i], 0.0) for i in range(basis.shape[1]))
    print("[5] Delta x  _|_  ker(Delta):", ortho)

    # 6. Diffusion fixes harmonics at every depth --------------------------
    a = 0.1
    s = diff_step(e, d, a)
    if basis.shape[1] > 0:
        h = basis[:, 0]
        fixed = all(np.allclose(np.linalg.matrix_power(s, k) @ h, h)
                    for k in range(1, 12))
        print("[6] S^k h = h for harmonic h (k<=11):", fixed)

    # 7. Harmonic projection conserved: P(S^k x) = P x ---------------------
    px = harmonic_projection(delta, x)
    conserved = True
    for k in range(1, 30):
        sk_x = np.linalg.matrix_power(s, k) @ x
        if not np.allclose(harmonic_projection(delta, sk_x), px):
            conserved = False
            break
    print("[7] P(S^k x) = P x along diffusion:", conserved)

    # 8. Diffusion relaxes the non-harmonic part to 0 ----------------------
    print("\n[8] Convergence of S^k x to its harmonic projection P x:")
    for k in [0, 1, 2, 5, 10, 50, 200]:
        sk_x = np.linalg.matrix_power(s, k) @ x
        residual = np.linalg.norm(sk_x - px)
        print(f"      k={k:4d}   ||S^k x - P x|| = {residual:.6e}")
    print("=" * 70)


if __name__ == "__main__":
    main()
