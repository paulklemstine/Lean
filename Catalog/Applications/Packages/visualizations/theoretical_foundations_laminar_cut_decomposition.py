#!/usr/bin/env python3
"""
Spectral Theory of Novelty — Algorithms

Implements the key algorithms from the research:
1. Laminar cut decomposition of ultrametrics
2. Hierarchical spectral analysis
3. Novelty quantification at each scale
4. Compressed representation via hierarchy
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class CutDecomposition:
    """Represents d(i,j) = ∑_t w_t · δ_{S_t}(i,j) where δ_S is the cut metric."""
    weights: List[float]      # w_t ≥ 0
    subsets: List[set]         # S_t ⊆ {0,...,n-1}
    n: int                     # number of points


@dataclass
class HierarchyLevel:
    """A single level in the hierarchical decomposition."""
    threshold: float           # distance threshold
    clusters: List[set]        # equivalence classes at this level
    weight: float              # increment weight


@dataclass
class SpectralDecomposition:
    """Spectral analysis of the centered distance matrix."""
    eigenvalues: np.ndarray
    eigenvectors: np.ndarray
    effective_rank: float
    scale_energies: List[float]


def compute_cut_decomposition(D: np.ndarray) -> CutDecomposition:
    """
    Decompose a finite ultrametric into a nonnegative sum of cut metrics.
    
    Algorithm (O(n² log n)):
    1. Find distinct nonzero distance values v₁ < v₂ < ... < v_m
    2. At each level v_k, compute the partition into clusters
    3. Each cluster contributes a cut with weight (v_k - v_{k-1})/2
    
    Returns:
        CutDecomposition with weights and subsets
    
    Pseudocode:
        INPUT: D[n×n] ultrametric distance matrix
        values ← sorted distinct positive values of D
        cuts ← []
        for k = 1 to |values|:
            v_k ← values[k], v_{k-1} ← values[k-1] (or 0)
            partition ← equivalence classes of {i~j : D[i,j] ≤ v_{k-1}}
            weight ← (v_k - v_{k-1}) / 2
            for each cluster C in partition:
                cuts.append((weight, C))
        RETURN cuts
    """
    n = D.shape[0]
    
    # Find distinct positive distance values
    values = sorted(set(D[i, j] for i in range(n) for j in range(n) if D[i, j] > 0))
    
    if not values:
        return CutDecomposition(weights=[], subsets=[], n=n)
    
    weights = []
    subsets = []
    
    prev_v = 0.0
    for v in values:
        # Compute equivalence classes: i ~ j iff D[i,j] ≤ prev_v
        visited = [False] * n
        clusters = []
        for i in range(n):
            if not visited[i]:
                cluster = set()
                stack = [i]
                while stack:
                    node = stack.pop()
                    if not visited[node]:
                        visited[node] = True
                        cluster.add(node)
                        for j in range(n):
                            if not visited[j] and D[node, j] <= prev_v + 1e-12:
                                stack.append(j)
                clusters.append(cluster)
        
        # Weight for this level
        w = (v - prev_v) / 2.0
        
        # Each cluster contributes a cut
        for cluster in clusters:
            if len(cluster) < n:  # Skip the full set (trivial cut)
                weights.append(w)
                subsets.append(cluster)
        
        prev_v = v
    
    return CutDecomposition(weights=weights, subsets=subsets, n=n)


def reconstruct_from_cuts(decomp: CutDecomposition) -> np.ndarray:
    """Reconstruct the distance matrix from its cut decomposition."""
    n = decomp.n
    D = np.zeros((n, n))
    for w, S in zip(decomp.weights, decomp.subsets):
        for i in range(n):
            for j in range(n):
                if (i in S) != (j in S):
                    D[i, j] += w
    return D


def hierarchical_spectral_analysis(D: np.ndarray) -> SpectralDecomposition:
    """
    Compute the spectral decomposition of the centered ultrametric kernel.
    
    Algorithm (O(n³)):
    1. Compute centering matrix J = I - (1/n)11ᵀ
    2. Compute centered kernel B = -JDJ
    3. Eigendecompose B
    4. Compute effective rank and scale energies
    
    Returns:
        SpectralDecomposition with eigenvalues, eigenvectors, effective rank,
        and energy at each scale
    """
    n = D.shape[0]
    
    # Centering
    J = np.eye(n) - np.ones((n, n)) / n
    B = -J @ D @ J
    
    # Symmetrize (numerical stability)
    B = (B + B.T) / 2
    
    # Eigendecomposition
    eigenvalues, eigenvectors = np.linalg.eigh(B)
    
    # Sort descending
    idx = np.argsort(-eigenvalues)
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    # Effective rank (exp of Shannon entropy of normalized eigenvalues)
    pos_eigs = eigenvalues[eigenvalues > 1e-10]
    if len(pos_eigs) > 0:
        p = pos_eigs / pos_eigs.sum()
        entropy = -np.sum(p * np.log(p))
        effective_rank = np.exp(entropy)
    else:
        effective_rank = 0.0
    
    # Scale energies from cut decomposition
    decomp = compute_cut_decomposition(D)
    scale_energies = []
    for w, S in zip(decomp.weights, decomp.subsets):
        # Energy of this cut = 2w · (number of i in S) · (number of j not in S) / n²
        s = len(S)
        scale_energies.append(2 * w * s * (n - s) / n**2)
    
    return SpectralDecomposition(
        eigenvalues=eigenvalues,
        eigenvectors=eigenvectors,
        effective_rank=effective_rank,
        scale_energies=scale_energies
    )


def novelty_at_scale(D: np.ndarray, x: np.ndarray, scale_idx: int) -> float:
    """
    Compute the novelty of observation x at a specific hierarchical scale.
    
    The novelty at scale k is the projection of x onto the k-th eigenspace
    of the centered distance kernel, weighted by the eigenvalue.
    
    Args:
        D: Ultrametric distance matrix
        x: Observation vector (will be centered)
        scale_idx: Which scale to measure (0 = coarsest)
    
    Returns:
        Novelty score at the specified scale
    """
    decomp = hierarchical_spectral_analysis(D)
    
    # Center x
    x_centered = x - x.mean()
    
    # Project onto eigenspace
    if scale_idx >= len(decomp.eigenvalues):
        return 0.0
    
    v = decomp.eigenvectors[:, scale_idx]
    projection = np.dot(x_centered, v)
    
    return decomp.eigenvalues[scale_idx] * projection**2


def spectral_compression_ratio(D: np.ndarray, tolerance: float = 0.01) -> float:
    """
    Compute the spectral compression ratio: what fraction of eigenvalues
    are needed to capture (1 - tolerance) of the total spectral energy.
    
    For ultrametrics with few hierarchy levels, this ratio is small,
    confirming that hierarchical structure implies spectral sparsity.
    """
    decomp = hierarchical_spectral_analysis(D)
    pos_eigs = decomp.eigenvalues[decomp.eigenvalues > 1e-10]
    
    if len(pos_eigs) == 0:
        return 0.0
    
    total = pos_eigs.sum()
    cumulative = np.cumsum(pos_eigs)
    
    # Find minimum k such that cumulative[k] >= (1-tolerance) * total
    threshold = (1 - tolerance) * total
    k = np.searchsorted(cumulative, threshold) + 1
    
    return k / (D.shape[0] - 1)  # Normalize by max possible rank


def build_dendrogram_ultrametric(merge_heights: List[float], 
                                  merge_pairs: List[Tuple[int, int]],
                                  n: int) -> np.ndarray:
    """
    Build an ultrametric distance matrix from a dendrogram specification.
    
    Args:
        merge_heights: Heights at which clusters merge (ascending)
        merge_pairs: Which cluster indices merge at each step
        n: Number of leaf points
    
    Returns:
        n×n ultrametric distance matrix
    """
    # Union-Find for tracking clusters
    parent = list(range(n + len(merge_pairs)))
    size = [1] * (n + len(merge_pairs))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    # Track which leaf points are in each cluster
    members = {i: {i} for i in range(n)}
    
    D = np.zeros((n, n))
    
    for height, (a, b) in zip(merge_heights, merge_pairs):
        ra, rb = find(a), find(b)
        if ra == rb:
            continue
        
        # Set distance between all cross-cluster pairs
        for i in members.get(ra, set()):
            for j in members.get(rb, set()):
                D[i, j] = height
                D[j, i] = height
        
        # Merge
        new_id = len(members)
        members[new_id] = members.pop(ra, set()) | members.pop(rb, set())
        parent[ra] = new_id
        parent[rb] = new_id
        parent[new_id] = new_id
    
    return D


# Example usage
if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")
    
    # Build a dendrogram-based ultrametric
    D = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    
    print("Distance matrix:")
    print(D)
    
    # Cut decomposition
    decomp = compute_cut_decomposition(D)
    print(f"\nCut decomposition: {len(decomp.weights)} cuts")
    for w, S in zip(decomp.weights, decomp.subsets):
        print(f"  weight={w:.2f}, subset={S}")
    
    # Verify reconstruction
    D_reconstructed = reconstruct_from_cuts(decomp)
    print(f"\nReconstruction error: {np.max(np.abs(D - D_reconstructed)):.2e}")
    
    # Spectral analysis
    spec = hierarchical_spectral_analysis(D)
    print(f"\nEigenvalues of -JDJ: {spec.eigenvalues}")
    print(f"Effective rank: {spec.effective_rank:.3f}")
    print(f"Compression ratio (1% tolerance): {spectral_compression_ratio(D, 0.01):.3f}")
    
    # Novelty scores
    x = np.array([1, -1, 0, 0, 0], dtype=float)
    print(f"\nNovelty of x={x}:")
    for k in range(min(4, len(spec.eigenvalues))):
        nov = novelty_at_scale(D, x, k)
        print(f"  Scale {k}: {nov:.4f}")
