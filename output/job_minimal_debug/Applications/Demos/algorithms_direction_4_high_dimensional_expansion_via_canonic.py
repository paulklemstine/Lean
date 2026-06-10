#!/usr/bin/env python3
"""
Algorithms for High-Dimensional Expansion via Canonical Cochains

Implements the core algorithms from the research paper:
1. Construction of boundary matrices for complete k-complexes
2. Canonical filling computation via least-squares
3. Congestion analysis
4. Spectral gap certification
5. Frame constant computation

All algorithms include type hints, docstrings, and complexity analysis.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional


def build_complete_complex(n: int, k: int = 2) -> Tuple[List, List, np.ndarray, np.ndarray]:
    """
    Build the complete k-complex on n vertices.

    Returns the k-cells, (k+1)-cells, and boundary matrices.
    For k=1 (edges/triangles), returns:
      - edges: list of (i,j) pairs
      - triangles: list of (i,j,k) triples
      - boundary2: matrix ∂₂ (edges × triangles)
      - boundary1: matrix ∂₁ (vertices × edges)

    Time complexity: O(n^(k+2))
    Space complexity: O(n^(2k+2))

    Args:
        n: Number of vertices
        k: Dimension of lower cells (default 1 for edges)

    Returns:
        Tuple of (k-cells, (k+1)-cells, boundary_upper, boundary_lower)

    Example:
        >>> edges, tris, b2, b1 = build_complete_complex(4)
        >>> print(f"{len(edges)} edges, {len(tris)} triangles")
        6 edges, 4 triangles
    """
    vertices = list(range(n))
    edges = list(combinations(vertices, 2))
    triangles = list(combinations(vertices, 3))

    edge_index = {e: i for i, e in enumerate(edges)}
    ne, nt = len(edges), len(triangles)

    # Boundary ∂₂: triangles → edges
    boundary2 = np.zeros((ne, nt))
    for t_idx, (i, j, k) in enumerate(triangles):
        boundary2[edge_index[(j, k)], t_idx] += 1
        boundary2[edge_index[(i, k)], t_idx] -= 1
        boundary2[edge_index[(i, j)], t_idx] += 1

    # Boundary ∂₁: edges → vertices
    boundary1 = np.zeros((n, ne))
    for e_idx, (i, j) in enumerate(edges):
        boundary1[j, e_idx] += 1
        boundary1[i, e_idx] -= 1

    return edges, triangles, boundary2, boundary1


def compute_cycle_basis(boundary1: np.ndarray) -> np.ndarray:
    """
    Compute an orthonormal basis for the 1-cycle space ker(∂₁).

    Time complexity: O(n³) via SVD
    Space complexity: O(n²)

    Args:
        boundary1: The boundary matrix ∂₁ (vertices × edges)

    Returns:
        Matrix whose rows form an orthonormal basis for ker(∂₁)

    Example:
        >>> _, _, _, b1 = build_complete_complex(4)
        >>> cycles = compute_cycle_basis(b1)
        >>> print(f"Cycle space dimension: {cycles.shape[0]}")
        Cycle space dimension: 3
    """
    U, S, Vt = np.linalg.svd(boundary1)
    rank = np.sum(S > 1e-10)
    return Vt[rank:, :]


def compute_canonical_fillings(
    boundary2: np.ndarray,
    cycle_basis: np.ndarray
) -> List[np.ndarray]:
    """
    Compute canonical fillings for each basis cycle via least-norm solution.

    For each cycle z, solves min ‖F‖ subject to ∂₂F = z.
    This gives the minimum-energy filling, which minimizes congestion.

    Time complexity: O(m · n²) where m = cycle dimension, n = number of edges
    Space complexity: O(m · t) where t = number of triangles

    Args:
        boundary2: Boundary matrix ∂₂ (edges × triangles)
        cycle_basis: Matrix of cycle basis vectors (rows)

    Returns:
        List of filling vectors (one per basis cycle)

    Example:
        >>> edges, tris, b2, b1 = build_complete_complex(5)
        >>> cycles = compute_cycle_basis(b1)
        >>> fillings = compute_canonical_fillings(b2, cycles)
        >>> print(f"Number of fillings: {len(fillings)}")
        Number of fillings: 6
    """
    fillings = []
    for i in range(cycle_basis.shape[0]):
        z = cycle_basis[i]
        F, _, _, _ = np.linalg.lstsq(boundary2, z, rcond=None)
        fillings.append(F)
    return fillings


def compute_congestion(
    fillings: List[np.ndarray],
    num_triangles: int
) -> Dict[str, float]:
    """
    Compute congestion statistics for a set of canonical fillings.

    Congestion measures how much each (k+1)-cell is used across all fillings.

    Time complexity: O(m · t)
    Space complexity: O(t)

    Args:
        fillings: List of filling vectors
        num_triangles: Number of (k+1)-cells

    Returns:
        Dictionary with congestion statistics:
        - 'per_cell': congestion per cell
        - 'max_congestion': maximum congestion across all cells
        - 'total_weight': total filling weight Σ_z ‖F(z)‖²
        - 'filling_weights': individual filling weights

    Example:
        >>> edges, tris, b2, b1 = build_complete_complex(5)
        >>> cycles = compute_cycle_basis(b1)
        >>> fillings = compute_canonical_fillings(b2, cycles)
        >>> stats = compute_congestion(fillings, len(tris))
        >>> print(f"Max congestion: {stats['max_congestion']:.4f}")
    """
    congestion_per_cell = np.zeros(num_triangles)
    filling_weights = []

    for F in fillings:
        congestion_per_cell += F ** 2
        filling_weights.append(float(np.sum(F ** 2)))

    return {
        'per_cell': congestion_per_cell,
        'max_congestion': float(np.max(congestion_per_cell)),
        'total_weight': sum(filling_weights),
        'filling_weights': filling_weights
    }


def compute_hodge_spectrum(
    boundary2: np.ndarray,
    boundary1: np.ndarray
) -> Dict[str, np.ndarray]:
    """
    Compute the full spectrum of the 1-Hodge Laplacian.

    L = L_up + L_down = ∂₂∂₂ᵀ + ∂₁ᵀ∂₁

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        boundary2: Upper boundary matrix (edges × triangles)
        boundary1: Lower boundary matrix (vertices × edges)

    Returns:
        Dictionary with:
        - 'full': full Hodge Laplacian eigenvalues
        - 'upper': upper Laplacian eigenvalues
        - 'lower': lower Laplacian eigenvalues
        - 'spectral_gap': smallest positive eigenvalue
        - 'spectral_gap_upper': smallest positive upper eigenvalue

    Example:
        >>> edges, tris, b2, b1 = build_complete_complex(5)
        >>> spec = compute_hodge_spectrum(b2, b1)
        >>> print(f"Spectral gap: {spec['spectral_gap']:.4f}")
    """
    L_up = boundary2 @ boundary2.T
    L_down = boundary1.T @ boundary1
    L_full = L_up + L_down

    eigs_full = np.sort(np.linalg.eigvalsh(L_full))
    eigs_up = np.sort(np.linalg.eigvalsh(L_up))
    eigs_down = np.sort(np.linalg.eigvalsh(L_down))

    pos_full = eigs_full[eigs_full > 1e-10]
    pos_up = eigs_up[eigs_up > 1e-10]

    return {
        'full': eigs_full,
        'upper': eigs_up,
        'lower': eigs_down,
        'spectral_gap': float(np.min(pos_full)) if len(pos_full) > 0 else 0.0,
        'spectral_gap_upper': float(np.min(pos_up)) if len(pos_up) > 0 else 0.0,
    }


def certify_spectral_gap(
    n: int,
    verbose: bool = True
) -> Dict[str, float]:
    """
    Full pipeline: construct complex, compute fillings, certify spectral gap.

    This implements the complete canonical filling method for the complete
    2-complex on n vertices.

    Time complexity: O(n⁶) dominated by SVD/least-squares on n²-dimensional matrices
    Space complexity: O(n⁴)

    Args:
        n: Number of vertices
        verbose: Whether to print progress

    Returns:
        Dictionary with certification results:
        - 'n': number of vertices
        - 'spectral_gap': actual spectral gap
        - 'certified_bound': certified lower bound from fillings
        - 'total_weight': total filling weight
        - 'max_congestion': maximum per-cell congestion
        - 'gap_times_weight': product λ₁⁺ · W (should be bounded)

    Example:
        >>> result = certify_spectral_gap(5, verbose=False)
        >>> print(f"Gap: {result['spectral_gap']:.4f}")
    """
    edges, triangles, b2, b1 = build_complete_complex(n)
    cycle_basis = compute_cycle_basis(b1)
    fillings = compute_canonical_fillings(b2, cycle_basis)
    congestion = compute_congestion(fillings, len(triangles))
    spectrum = compute_hodge_spectrum(b2, b1)

    W = congestion['total_weight']
    gap = spectrum['spectral_gap_upper']
    certified = 1.0 / W if W > 0 else 0.0

    result = {
        'n': n,
        'num_edges': len(edges),
        'num_triangles': len(triangles),
        'cycle_dim': cycle_basis.shape[0],
        'spectral_gap': gap,
        'certified_bound': certified,
        'total_weight': W,
        'max_congestion': congestion['max_congestion'],
        'gap_times_weight': gap * W,
    }

    if verbose:
        print(f"n={n}: edges={len(edges)}, triangles={len(triangles)}, "
              f"cycle_dim={cycle_basis.shape[0]}")
        print(f"  λ₁⁺(up) = {gap:.6f}")
        print(f"  W = {W:.6f}")
        print(f"  Certified bound = {certified:.6f}")
        print(f"  λ₁⁺ · W = {gap * W:.6f}")
        print(f"  Max congestion = {congestion['max_congestion']:.6f}")

    return result


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("CANONICAL FILLING SPECTRAL GAP CERTIFICATION")
    print("=" * 60)

    results = []
    for n in range(4, 9):
        print(f"\n--- n = {n} ---")
        r = certify_spectral_gap(n)
        results.append(r)

    print("\n" + "=" * 60)
    print("SUMMARY TABLE")
    print("=" * 60)
    print(f"{'n':>3} {'edges':>6} {'tris':>6} {'cycles':>7} "
          f"{'λ₁⁺':>10} {'W':>10} {'λ₁⁺·W':>10} {'1/W':>10}")
    print("-" * 70)
    for r in results:
        print(f"{r['n']:>3} {r['num_edges']:>6} {r['num_triangles']:>6} "
              f"{r['cycle_dim']:>7} {r['spectral_gap']:>10.4f} "
              f"{r['total_weight']:>10.4f} {r['gap_times_weight']:>10.4f} "
              f"{r['certified_bound']:>10.4f}")
