#!/usr/bin/env python3
"""
Algorithms for Tropical Hodge Theory on Weighted Polyhedral Complexes.

Type-hinted implementations of:
1. Weighted codifferential computation
2. Combinatorial Laplacian assembly
3. Harmonic form extraction (kernel computation)
4. Betti number computation
5. Tropical Hodge star
6. Spectral gap estimation
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class WeightedCoboundary:
    """A weighted coboundary map d : R^m -> R^n with positive weights."""
    d: np.ndarray          # (n, m) coboundary matrix
    src_weight: np.ndarray  # (m,) positive source weights
    tgt_weight: np.ndarray  # (n,) positive target weights

    def __post_init__(self) -> None:
        assert self.d.shape == (len(self.tgt_weight), len(self.src_weight))
        assert np.all(self.src_weight > 0), "Source weights must be positive"
        assert np.all(self.tgt_weight > 0), "Target weights must be positive"

    @property
    def m(self) -> int:
        return len(self.src_weight)

    @property
    def n(self) -> int:
        return len(self.tgt_weight)

    def codifferential(self) -> np.ndarray:
        """Compute δ = W_src^{-1} d^T W_tgt : R^n -> R^m."""
        W_src_inv = np.diag(1.0 / self.src_weight)
        W_tgt = np.diag(self.tgt_weight)
        return W_src_inv @ self.d.T @ W_tgt

    def laplacian_up(self) -> np.ndarray:
        """Compute Δ^up = δd : R^m -> R^m."""
        return self.codifferential() @ self.d

    def laplacian_down(self) -> np.ndarray:
        """Compute Δ^down = dδ : R^n -> R^n."""
        return self.d @ self.codifferential()

    def weighted_ip_src(self, u: np.ndarray, v: np.ndarray) -> float:
        """Weighted inner product on source space."""
        return float(np.sum(self.src_weight * u * v))

    def weighted_ip_tgt(self, u: np.ndarray, v: np.ndarray) -> float:
        """Weighted inner product on target space."""
        return float(np.sum(self.tgt_weight * u * v))

    def verify_adjunction(self, u: np.ndarray, v: np.ndarray, tol: float = 1e-12) -> bool:
        """Verify <du, v>_tgt = <u, δv>_src."""
        du = self.d @ u
        delta_v = self.codifferential() @ v
        lhs = self.weighted_ip_tgt(du, v)
        rhs = self.weighted_ip_src(u, delta_v)
        return abs(lhs - rhs) < tol


@dataclass
class WeightedSimplicialComplex:
    """A weighted simplicial complex with coboundary maps at each degree."""
    coboundaries: List[WeightedCoboundary]  # d_0, d_1, ..., d_{n-1}
    top_weight: np.ndarray  # weights on the top-degree cells

    def __post_init__(self) -> None:
        # Verify d² = 0
        for i in range(len(self.coboundaries) - 1):
            d_curr = self.coboundaries[i].d
            d_next = self.coboundaries[i + 1].d
            assert np.allclose(d_next @ d_curr, 0, atol=1e-12), \
                f"d_{i+1} ∘ d_{i} ≠ 0"

    @property
    def max_deg(self) -> int:
        return len(self.coboundaries)

    def ranks(self) -> List[int]:
        """Dimensions of cochain spaces at each degree."""
        dims = [self.coboundaries[0].m]
        for cb in self.coboundaries:
            dims.append(cb.n)
        return dims

    def betti_numbers(self) -> List[int]:
        """Compute all Betti numbers."""
        ranks = self.ranks()
        n_deg = len(ranks)
        betti = []

        for k in range(n_deg):
            if k == 0:
                ker_d = ranks[0] - np.linalg.matrix_rank(self.coboundaries[0].d, tol=1e-10)
                betti.append(ker_d)
            elif k < len(self.coboundaries):
                ker_dk = ranks[k] - np.linalg.matrix_rank(self.coboundaries[k].d, tol=1e-10)
                im_dk_minus_1 = np.linalg.matrix_rank(self.coboundaries[k-1].d, tol=1e-10)
                betti.append(ker_dk - im_dk_minus_1)
            else:  # top degree
                im_dk_minus_1 = np.linalg.matrix_rank(self.coboundaries[k-1].d, tol=1e-10)
                betti.append(ranks[k] - im_dk_minus_1)

        return betti

    def euler_characteristic(self) -> int:
        """Compute χ = Σ (-1)^k b_k = Σ (-1)^k dim(C^k)."""
        ranks = self.ranks()
        return sum((-1)**k * r for k, r in enumerate(ranks))

    def harmonic_forms(self, k: int) -> np.ndarray:
        """
        Compute a basis for the harmonic k-forms (kernel of Δ_k).

        Returns:
            Matrix whose rows form a basis for the harmonic k-forms.
        """
        if k < len(self.coboundaries):
            lap = self.coboundaries[k].laplacian_up()
        else:
            lap = self.coboundaries[k-1].laplacian_down()

        # Find kernel via SVD
        _, S, Vt = np.linalg.svd(lap)
        tol = 1e-10 * max(S) if len(S) > 0 and max(S) > 0 else 1e-10
        null_mask = S < tol
        return Vt[null_mask]


def compute_spectral_gap(laplacian: np.ndarray) -> float:
    """
    Compute the spectral gap (smallest non-zero eigenvalue) of a Laplacian.

    Args:
        laplacian: Symmetric positive semi-definite matrix.

    Returns:
        The spectral gap λ_1.
    """
    eigvals = np.sort(np.linalg.eigvalsh(laplacian))
    # Find smallest eigenvalue > tolerance
    tol = 1e-10 * max(abs(eigvals)) if len(eigvals) > 0 else 1e-10
    nonzero = eigvals[eigvals > tol]
    return float(nonzero[0]) if len(nonzero) > 0 else 0.0


def tropical_hodge_star(coeff: np.ndarray, weights: np.ndarray) -> np.ndarray:
    """
    Apply the tropical Hodge star: ★f_i = w_i * f_i.

    This maps (p,q)-forms to (q,p)-forms by conjugation with the weight function.
    """
    return weights * coeff


def satisfies_hlp(betti: List[int]) -> bool:
    """
    Check if Betti numbers satisfy the Hard Lefschetz Property:
    b_k ≤ b_{n-k} for all k ≤ n/2.
    """
    n = len(betti) - 1
    return all(betti[k] <= betti[n - k] for k in range(n // 2 + 1))


def laplacian_trace_formula(W: WeightedCoboundary) -> float:
    """
    Compute the trace of Δ^up using the trace formula:
    tr(Δ) = Σ_i Σ_j w_src_j^{-1} * w_tgt_i * d_{ij}²
    """
    total = 0.0
    for i in range(W.n):
        for j in range(W.m):
            total += (1.0 / W.src_weight[j]) * W.tgt_weight[i] * W.d[i, j]**2
    return total


# ============================================================
# Example: Build a simplicial complex from a graph
# ============================================================

def graph_to_complex(incidence: np.ndarray,
                      vertex_weights: Optional[np.ndarray] = None,
                      edge_weights: Optional[np.ndarray] = None) -> WeightedCoboundary:
    """
    Convert a graph (given by its incidence matrix) to a WeightedCoboundary.

    Args:
        incidence: (num_edges, num_vertices) signed incidence matrix
        vertex_weights: positive weights on vertices (default: all ones)
        edge_weights: positive weights on edges (default: all ones)

    Returns:
        WeightedCoboundary representing the graph
    """
    n_edges, n_verts = incidence.shape
    if vertex_weights is None:
        vertex_weights = np.ones(n_verts)
    if edge_weights is None:
        edge_weights = np.ones(n_edges)
    return WeightedCoboundary(incidence, vertex_weights, edge_weights)


if __name__ == "__main__":
    # Quick sanity check
    B = np.array([[-1, 1, 0], [0, -1, 1], [-1, 0, 1]], dtype=float)
    W = graph_to_complex(B)

    print("Triangle graph:")
    print(f"  Laplacian:\n{W.laplacian_up()}")
    print(f"  Spectral gap: {compute_spectral_gap(W.laplacian_up()):.4f}")
    print(f"  Trace (direct): {np.trace(W.laplacian_up()):.4f}")
    print(f"  Trace (formula): {laplacian_trace_formula(W):.4f}")
    print(f"  Adjunction verified: {W.verify_adjunction(np.array([1, 2, 3.0]), np.array([0.5, -1, 0.5]))}")
