#!/usr/bin/env python3
"""
Algorithms for Complex Weighted Random Graphs

Type-hinted implementations of the core algorithms for analyzing
complex-weighted graphs and their spectral properties.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class ComplexWeightedGraph:
    """A complex weighted graph G(n, z) with n vertices and edge weight z."""
    n: int
    z: complex
    adjacency: np.ndarray  # Boolean adjacency matrix (n x n, dtype float)
    
    @property
    def adj_matrix(self) -> np.ndarray:
        """The complex-weighted adjacency matrix A_z = z * B."""
        return self.z * self.adjacency
    
    @property
    def edge_pair_count(self) -> int:
        """Number of directed edge pairs."""
        return int(np.sum(self.adjacency))
    
    @property
    def edge_count(self) -> int:
        """Number of undirected edges (half the directed count)."""
        return self.edge_pair_count // 2
    
    def degree(self, vertex: int) -> int:
        """Degree of a given vertex."""
        return int(np.sum(self.adjacency[vertex]))
    
    @property
    def degrees(self) -> np.ndarray:
        """Degree sequence."""
        return self.adjacency.sum(axis=1).astype(int)


@dataclass
class SpectralAnalysis:
    """Results of spectral analysis of a complex weighted graph."""
    eigenvalues: np.ndarray
    collinearity_direction: complex
    collinearity_error: float  # max |Im(λ/z)|
    frobenius_norm_sq: float
    is_normal: bool
    normality_defect: float


def generate_erdos_renyi_complex(
    n: int, z: complex, p: float = 0.5, seed: Optional[int] = None
) -> ComplexWeightedGraph:
    """Generate a random Erdős-Rényi complex weighted graph G(n, z).
    
    Args:
        n: Number of vertices
        z: Complex edge weight
        p: Edge probability
        seed: Random seed (optional)
    
    Returns:
        ComplexWeightedGraph instance
    """
    if seed is not None:
        np.random.seed(seed)
    
    upper = np.random.random((n, n)) < p
    B = np.triu(upper, k=1).astype(float)
    B = B + B.T
    np.fill_diagonal(B, 0)
    
    return ComplexWeightedGraph(n=n, z=z, adjacency=B)


def generate_directed_complex(
    n: int, z: complex, p: float = 0.5, seed: Optional[int] = None
) -> ComplexWeightedGraph:
    """Generate a random directed complex weighted graph.
    
    Args:
        n: Number of vertices
        z: Complex edge weight
        p: Edge probability
        seed: Random seed (optional)
    
    Returns:
        ComplexWeightedGraph instance (with non-symmetric adjacency)
    """
    if seed is not None:
        np.random.seed(seed)
    
    B = (np.random.random((n, n)) < p).astype(float)
    np.fill_diagonal(B, 0)
    
    return ComplexWeightedGraph(n=n, z=z, adjacency=B)


def analyze_spectrum(G: ComplexWeightedGraph) -> SpectralAnalysis:
    """Perform full spectral analysis of a complex weighted graph.
    
    Computes eigenvalues, verifies collinearity, normality, and
    the Frobenius norm identity.
    
    Args:
        G: A ComplexWeightedGraph
    
    Returns:
        SpectralAnalysis with all computed properties
    """
    A = G.adj_matrix
    AH = A.conj().T
    
    # Eigenvalues
    eigenvalues = np.linalg.eigvals(A)
    
    # Collinearity check
    if abs(G.z) > 1e-14:
        scaled = eigenvalues / G.z
        collinearity_error = float(np.max(np.abs(scaled.imag)))
    else:
        collinearity_error = 0.0
    
    # Normality check
    normality_defect = float(np.max(np.abs(A @ AH - AH @ A)))
    is_normal = normality_defect < 1e-8
    
    # Frobenius norm
    frobenius_norm_sq = float(np.real(np.trace(AH @ A)))
    
    return SpectralAnalysis(
        eigenvalues=eigenvalues,
        collinearity_direction=G.z,
        collinearity_error=collinearity_error,
        frobenius_norm_sq=frobenius_norm_sq,
        is_normal=is_normal,
        normality_defect=normality_defect,
    )


def compute_walk_phases(
    G: ComplexWeightedGraph, source: int, target: int, max_length: int
) -> List[Tuple[int, complex]]:
    """Compute walk amplitudes from source to target for each walk length.
    
    The amplitude of length-k walks is z^k * (B^k)_{source, target}.
    
    Args:
        G: A ComplexWeightedGraph
        source: Source vertex index
        target: Target vertex index
        max_length: Maximum walk length to compute
    
    Returns:
        List of (k, amplitude) pairs for k = 1, ..., max_length
    """
    B = G.adjacency
    B_power = np.eye(G.n)
    results = []
    
    for k in range(1, max_length + 1):
        B_power = B_power @ B
        walk_count = B_power[source, target]
        amplitude = G.z ** k * walk_count
        results.append((k, amplitude))
    
    return results


def verify_scalar_factorization(G: ComplexWeightedGraph) -> float:
    """Verify A_z = z * B and return the maximum error.
    
    Args:
        G: A ComplexWeightedGraph
    
    Returns:
        Maximum absolute entry-wise error
    """
    return float(np.max(np.abs(G.adj_matrix - G.z * G.adjacency)))


def verify_frobenius_identity(G: ComplexWeightedGraph) -> float:
    """Verify tr(A*A) = |z|^2 * edge_pair_count and return relative error.
    
    Args:
        G: A ComplexWeightedGraph
    
    Returns:
        Relative error of the identity
    """
    A = G.adj_matrix
    actual = float(np.real(np.trace(A.conj().T @ A)))
    predicted = abs(G.z) ** 2 * G.edge_pair_count
    return abs(actual - predicted) / max(abs(predicted), 1e-16)


def spectral_dimension_estimate(
    eigenvalues: np.ndarray, threshold: float = 0.01
) -> float:
    """Estimate the effective dimension of the eigenvalue distribution.
    
    Uses the ratio of the two largest principal component variances
    of the eigenvalue set viewed as 2D points (Re, Im).
    
    Returns a value between 0 and 1:
    - ~0: eigenvalues are collinear (1D)
    - ~1: eigenvalues fill a 2D region
    
    Args:
        eigenvalues: Array of complex eigenvalues
        threshold: Minimum eigenvalue magnitude to include
    
    Returns:
        Spectral dimension estimate in [0, 1]
    """
    eigs = eigenvalues[np.abs(eigenvalues) > threshold]
    if len(eigs) < 3:
        return 0.0
    
    points = np.column_stack([eigs.real, eigs.imag])
    points -= points.mean(axis=0)
    
    cov = np.cov(points.T)
    svs = np.linalg.svd(cov, compute_uv=False)
    
    if svs[0] < 1e-14:
        return 0.0
    
    return float(svs[1] / svs[0])


if __name__ == "__main__":
    # Quick demonstration
    G = generate_erdos_renyi_complex(100, 0.5 + 0.3j, p=0.5, seed=42)
    analysis = analyze_spectrum(G)
    
    print(f"Graph: n={G.n}, z={G.z}, edges={G.edge_count}")
    print(f"Normal: {analysis.is_normal} (defect={analysis.normality_defect:.2e})")
    print(f"Collinear: {analysis.collinearity_error:.2e}")
    print(f"Frobenius: {analysis.frobenius_norm_sq:.2f}")
    print(f"Spectral dim: {spectral_dimension_estimate(analysis.eigenvalues):.4f}")
    
    print("\nDirected comparison:")
    G_dir = generate_directed_complex(100, 0.5 + 0.3j, p=0.5, seed=42)
    analysis_dir = analyze_spectrum(G_dir)
    print(f"Normal: {analysis_dir.is_normal} (defect={analysis_dir.normality_defect:.2e})")
    print(f"Spectral dim: {spectral_dimension_estimate(analysis_dir.eigenvalues):.4f}")
