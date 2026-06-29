"""
demo.py — Spectral Depth Thresholds for Hodge-Laplacian Message Passing
=======================================================================

Self-contained numerical demonstrations of the results in
`HodgeSpectralThreshold`.  We build small simplicial complexes, assemble their
combinatorial Hodge Laplacians  Delta = up + down  on k-cochains, model one
message-passing layer as  T = 1 - t*Delta,  and study depth-L message passing
T^L.  We verify, numerically:

  * Hodge vanishing principle:  <S x, x> = 0  =>  S x = 0   (symmetric PSD S).
  * harmonic = closed and coclosed:  Delta x = 0  <=>  up x = 0 and down x = 0.
  * topology is depth-invariant:  Delta x = 0  =>  T^L x = x  for all L.
  * mode decay:  (1 - t*lam)^L <= (1 - t*mu)^L  for lam >= mu.
  * harmonic modes keep amplitude 1; gap modes -> 0.
  * the explicit critical depth  L_c = ceil(log eps / log(1 - t*mu)).

Only NumPy is required.
"""

from __future__ import annotations

import math
from typing import Tuple

import numpy as np

# ---------------------------------------------------------------------------
# Building combinatorial Hodge Laplacians on a small simplicial complex
# ---------------------------------------------------------------------------


def boundary_1(n_vertices: int, edges: list[tuple[int, int]]) -> np.ndarray:
    """Signed vertex-edge boundary matrix B1 (rows = vertices, cols = edges).

    For oriented edge (i, j) with i < j, column has -1 at i and +1 at j.
    """
    B1: np.ndarray = np.zeros((n_vertices, len(edges)))
    for c, (i, j) in enumerate(edges):
        B1[i, c] = -1.0
        B1[j, c] = +1.0
    return B1


def boundary_2(
    edges: list[tuple[int, int]], triangles: list[tuple[int, int, int]]
) -> np.ndarray:
    """Signed edge-triangle boundary matrix B2 (rows = edges, cols = triangles)."""
    edge_index = {e: k for k, e in enumerate(edges)}
    B2: np.ndarray = np.zeros((len(edges), len(triangles)))
    for c, (i, j, k) in enumerate(triangles):
        # oriented boundary of [i,j,k] = [j,k] - [i,k] + [i,j]
        for sign, e in ((+1.0, (j, k)), (-1.0, (i, k)), (+1.0, (i, j))):
            B2[edge_index[e], c] += sign
    return B2


def hodge_laplacian_1(
    n_vertices: int,
    edges: list[tuple[int, int]],
    triangles: list[tuple[int, int, int]],
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Return (up, down, Delta) for the 1-Hodge-Laplacian on edges.

    down = B1^T B1  (lower Laplacian, d* d),
    up   = B2  B2^T (upper Laplacian, delta delta*),
    Delta = up + down.
    """
    B1 = boundary_1(n_vertices, edges)
    B2 = boundary_2(edges, triangles)
    down: np.ndarray = B1.T @ B1
    up: np.ndarray = B2 @ B2.T
    delta: np.ndarray = up + down
    return up, down, delta


# ---------------------------------------------------------------------------
# Message passing
# ---------------------------------------------------------------------------


def layer(delta: np.ndarray, t: float) -> np.ndarray:
    """One linearized message-passing layer  T = I - t*Delta."""
    n = delta.shape[0]
    return np.eye(n) - t * delta


def depth_map(delta: np.ndarray, t: float, L: int) -> np.ndarray:
    """Depth-L message passing  T^L."""
    return np.linalg.matrix_power(layer(delta, t), L)


def critical_depth(mu: float, t: float, eps: float) -> int:
    """L_c = ceil(log eps / log(1 - t*mu)),  the depth_threshold formula."""
    r = 1.0 - t * mu
    assert 0.0 < r < 1.0, "need 0 < t*mu < 1 (normalized step)"
    assert eps > 0.0
    return max(0, math.ceil(math.log(eps) / math.log(r)))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_hodge_vanishing() -> None:
    """psd_inner_self_eq_zero: zero Dirichlet energy => operator kills vector."""
    print("=" * 70)
    print("1) Hodge vanishing principle:  <S x, x> = 0  =>  S x = 0")
    print("=" * 70)
    rng = np.random.default_rng(0)
    A = rng.standard_normal((5, 3))
    S = A @ A.T  # symmetric PSD, rank 3 -> nontrivial kernel
    # pick x in ker S (energy = 0)
    _, _, Vt = np.linalg.svd(A.T)  # null space of S = null space of A^T
    x = Vt[-1]  # last right-singular vector -> in kernel
    energy = float(x @ S @ x)
    print(f"   energy <S x, x>   = {energy: .3e}")
    print(f"   ||S x||           = {np.linalg.norm(S @ x): .3e}")
    print("   => vanishing energy forces S x = 0.\n")


def demo_harmonic_iff() -> None:
    """harmonic_iff / ker_hodgeLaplacian on a triangle-with-tail complex."""
    print("=" * 70)
    print("2) harmonic = closed and coclosed:  Delta x = 0 <=> up x = 0 = down x")
    print("=" * 70)
    # A hollow square (4-cycle) -> one 1-dimensional hole -> b1 = 1.
    edges = [(0, 1), (1, 2), (2, 3), (0, 3)]
    triangles: list[tuple[int, int, int]] = []  # no filled faces
    up, down, delta = hodge_laplacian_1(4, edges, triangles)
    vals, vecs = np.linalg.eigh(delta)
    harmonic = vecs[:, np.isclose(vals, 0.0)]
    print(f"   spectrum of Delta = {np.round(vals, 4)}")
    print(f"   dim ker Delta (b1)= {harmonic.shape[1]}  (expected 1: the loop)")
    for k in range(harmonic.shape[1]):
        x = harmonic[:, k]
        print(
            f"   harmonic mode {k}: ||up x||={np.linalg.norm(up @ x):.2e}, "
            f"||down x||={np.linalg.norm(down @ x):.2e}"
        )
    print("   => harmonic cochains are simultaneously closed and coclosed.\n")


def demo_depth_invariance() -> None:
    """harmonic_depth_invariant: Delta x = 0 => T^L x = x for all L."""
    print("=" * 70)
    print("3) topology is depth-invariant:  Delta x = 0 => T^L x = x")
    print("=" * 70)
    edges = [(0, 1), (1, 2), (2, 3), (0, 3)]
    up, down, delta = hodge_laplacian_1(4, edges, [])
    vals, vecs = np.linalg.eigh(delta)
    x = vecs[:, np.isclose(vals, 0.0)][:, 0]  # a harmonic cochain
    t = 0.1
    for L in (1, 5, 20, 100):
        y = depth_map(delta, t, L) @ x
        print(f"   L={L:4d}:  ||T^L x - x|| = {np.linalg.norm(y - x): .3e}")
    print("   => the loop survives untouched at every depth.\n")


def demo_mode_decay_and_threshold() -> None:
    """mode_decay, gap_mode_tendsto_zero, depth_threshold."""
    print("=" * 70)
    print("4) non-harmonic suppression + explicit critical depth L_c")
    print("=" * 70)
    edges = [(0, 1), (1, 2), (2, 3), (0, 3)]
    _, _, delta = hodge_laplacian_1(4, edges, [])
    vals = np.linalg.eigvalsh(delta)
    nonzero = vals[~np.isclose(vals, 0.0)]
    mu = float(nonzero.min())          # spectral gap
    lam_max = float(nonzero.max())
    t = 1.0 / lam_max                   # normalized step: 0 <= t*lam <= 1
    eps = 1e-3
    Lc = critical_depth(mu, t, eps)
    print(f"   spectral gap mu   = {mu:.4f},  lam_max = {lam_max:.4f},  t = {t:.4f}")
    print(f"   tolerance eps     = {eps}")
    print(f"   critical depth Lc = {Lc}")
    # verify: gap mode envelope at Lc is below eps; harmonic mode stays 1.
    env = (1.0 - t * mu) ** Lc
    print(f"   (1 - t*mu)^Lc     = {env: .3e}   (<= eps : {env <= eps})")
    print(f"   harmonic (lam=0)  = {(1.0 - t * 0.0) ** Lc: .3f}   (stays 1)")
    # mode_decay monotonicity: larger lam decays at least as fast.
    print("   per-mode amplitudes at L = Lc:")
    for lam in sorted(set(np.round(vals, 4))):
        print(f"     lam={lam:6.3f} -> (1 - t*lam)^Lc = {(1 - t * lam) ** Lc: .3e}")
    print("   => all non-harmonic modes below eps; topology alone remains.\n")


def main() -> None:
    demo_hodge_vanishing()
    demo_harmonic_iff()
    demo_depth_invariance()
    demo_mode_decay_and_threshold()
    print("All demonstrations consistent with the proved theorems.")


if __name__ == "__main__":
    main()
