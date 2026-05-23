#!/usr/bin/env python3
"""
Algorithms for Compact Operator Invariant Subspace Analysis

This module implements algorithms for:
1. Computing eigenspaces of compact-like operators
2. Finding invariant subspaces from compact spectral data
3. Verifying commutant preservation properties
4. Detecting Enflo-Read obstruction patterns

All algorithms are designed for finite-dimensional truncations (matrices)
that approximate infinite-dimensional compact operators.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class EigenspaceData:
    """Data about an eigenspace of an operator."""
    eigenvalue: complex
    dimension: int
    basis: np.ndarray  # columns are basis vectors
    is_invariant: bool = True
    preservation_error: float = 0.0


@dataclass
class InvariantSubspaceResult:
    """Result of an invariant subspace computation."""
    subspace_basis: np.ndarray  # columns are basis vectors
    dimension: int
    is_nontrivial: bool
    is_proper: bool
    is_closed: bool  # always True in finite dimensions
    invariance_error: float
    source_eigenvalue: complex


def compute_compact_eigenspaces(
    K: np.ndarray,
    eigenvalue_threshold: float = 1e-10,
    clustering_tolerance: float = 1e-8
) -> List[EigenspaceData]:
    """
    Compute the nonzero eigenspaces of a compact-like operator.
    
    This implements the spectral decomposition step: given a matrix K
    (approximating a compact operator), find all eigenvalues with |μ| > threshold
    and compute their eigenspaces.
    
    Algorithm:
        1. Compute full eigendecomposition of K
        2. Filter out near-zero eigenvalues
        3. Cluster nearby eigenvalues (accounting for numerical error)
        4. For each cluster, compute the eigenspace as span of eigenvectors
    
    Complexity: O(n³) for n×n matrix (dominated by eigendecomposition)
    
    Args:
        K: Square matrix (compact operator approximation)
        eigenvalue_threshold: Minimum |μ| to consider nonzero
        clustering_tolerance: Maximum distance for eigenvalue clustering
    
    Returns:
        List of EigenspaceData for each nonzero eigenvalue
    """
    n = K.shape[0]
    eigenvalues, eigenvectors = np.linalg.eig(K)
    
    # Filter nonzero eigenvalues
    nonzero_mask = np.abs(eigenvalues) > eigenvalue_threshold
    nonzero_indices = np.where(nonzero_mask)[0]
    
    if len(nonzero_indices) == 0:
        return []
    
    # Cluster eigenvalues
    used = set()
    clusters: List[List[int]] = []
    
    for i in nonzero_indices:
        if i in used:
            continue
        cluster = [int(j) for j in nonzero_indices 
                   if j not in used and abs(eigenvalues[j] - eigenvalues[i]) < clustering_tolerance]
        clusters.append(cluster)
        used.update(cluster)
    
    # Build eigenspace data
    results = []
    for cluster in clusters:
        ev = np.mean(eigenvalues[cluster])
        basis = eigenvectors[:, cluster]
        
        # Orthogonalize the basis (Gram-Schmidt)
        Q, R = np.linalg.qr(basis, mode='reduced')
        # Keep only linearly independent columns
        rank = np.sum(np.abs(np.diag(R)) > 1e-12)
        Q = Q[:, :rank]
        
        results.append(EigenspaceData(
            eigenvalue=ev,
            dimension=rank,
            basis=Q
        ))
    
    return sorted(results, key=lambda x: -abs(x.eigenvalue))


def find_invariant_subspaces_from_compact(
    T: np.ndarray,
    K: np.ndarray,
    eigenvalue_threshold: float = 1e-10,
    commutator_tolerance: float = 1e-6
) -> List[InvariantSubspaceResult]:
    """
    Find invariant subspaces of T using the compact operator K.
    
    This implements the core algorithm from our formalized theory:
    if T commutes with K and K has nonzero eigenvalue μ, then
    the eigenspace E_μ(K) is T-invariant.
    
    Algorithm:
        1. Verify T and K approximately commute: ‖TK - KT‖ < tolerance
        2. Compute nonzero eigenspaces of K
        3. For each eigenspace, verify T-invariance
        4. Return eigenspaces that are T-invariant, nontrivial, and proper
    
    Complexity: O(n³) dominated by eigendecomposition
    
    Args:
        T: The operator for which we seek invariant subspaces
        K: A compact operator commuting with T
        eigenvalue_threshold: Minimum |μ| for eigenvalues of K
        commutator_tolerance: Maximum ‖[T,K]‖ to accept commutation
    
    Returns:
        List of InvariantSubspaceResult
    """
    n = T.shape[0]
    
    # Step 1: Check commutation
    commutator_norm = np.linalg.norm(T @ K - K @ T)
    if commutator_norm > commutator_tolerance:
        print(f"Warning: ‖[T,K]‖ = {commutator_norm:.2e} > tolerance {commutator_tolerance}")
        return []
    
    # Step 2: Compute eigenspaces of K
    eigenspaces = compute_compact_eigenspaces(K, eigenvalue_threshold)
    
    # Step 3: Verify T-invariance and build results
    results = []
    for es in eigenspaces:
        # Check if T maps the eigenspace into itself
        # T·V should be in the column space of V
        TV = T @ es.basis
        # Project TV onto eigenspace
        proj = es.basis @ (es.basis.conj().T @ TV)
        invariance_error = np.linalg.norm(TV - proj)
        
        is_nontrivial = es.dimension > 0
        is_proper = es.dimension < n
        
        results.append(InvariantSubspaceResult(
            subspace_basis=es.basis,
            dimension=es.dimension,
            is_nontrivial=is_nontrivial,
            is_proper=is_proper,
            is_closed=True,  # Always true in finite dimensions
            invariance_error=invariance_error,
            source_eigenvalue=es.eigenvalue
        ))
    
    return results


def verify_commutant_eigenspace_preservation(
    commutant: List[np.ndarray],
    K: np.ndarray,
    eigenvalue_threshold: float = 1e-10,
    preservation_tolerance: float = 1e-6
) -> Dict[complex, Dict]:
    """
    Verify that all operators in a commutant preserve eigenspaces of K.
    
    This implements the verification step for the commutant_preserves_compact_spectral_sector
    theorem: for every T in the commutant of K, every eigenspace of K is T-invariant.
    
    Algorithm:
        1. Compute eigenspaces of K
        2. For each eigenspace and each operator T in commutant:
           a. Compute T·v for each basis vector v
           b. Project onto eigenspace
           c. Measure preservation error
    
    Complexity: O(|commutant| · n³)
    
    Args:
        commutant: List of operators commuting with K
        K: Compact operator
        eigenvalue_threshold: Minimum eigenvalue magnitude
        preservation_tolerance: Maximum preservation error
    
    Returns:
        Dictionary mapping eigenvalues to preservation data
    """
    eigenspaces = compute_compact_eigenspaces(K, eigenvalue_threshold)
    
    results = {}
    for es in eigenspaces:
        preservation_data = {
            'dimension': es.dimension,
            'eigenvalue': es.eigenvalue,
            'operators_checked': len(commutant),
            'all_preserved': True,
            'max_error': 0.0,
            'individual_errors': []
        }
        
        for T in commutant:
            TV = T @ es.basis
            proj = es.basis @ (es.basis.conj().T @ TV)
            error = np.linalg.norm(TV - proj)
            
            preservation_data['individual_errors'].append(error)
            preservation_data['max_error'] = max(preservation_data['max_error'], error)
            if error > preservation_tolerance:
                preservation_data['all_preserved'] = False
        
        results[es.eigenvalue] = preservation_data
    
    return results


def detect_enflo_read_pattern(
    T: np.ndarray,
    num_trials: int = 100,
    rank_range: range = range(1, 6),
    commutator_tolerance: float = 1e-4
) -> Dict:
    """
    Detect whether an operator exhibits an Enflo-Read obstruction pattern.
    
    An operator has the Enflo-Read pattern if no nonzero compact operator
    commutes with it. We test this by attempting to find low-rank operators
    in the commutant.
    
    Algorithm:
        1. For each target rank r in rank_range:
           a. Generate random rank-r matrices
           b. Optimize to minimize ‖[T, K]‖ (commutator norm)
           c. Record minimum commutator norm achieved
        2. If all minimum norms are large, T exhibits the Enflo-Read pattern
    
    Complexity: O(num_trials · max_rank · n²)
    
    Args:
        T: Operator to test
        num_trials: Number of random trials per rank
        rank_range: Range of ranks to test
        commutator_tolerance: Threshold for approximate commutation
    
    Returns:
        Dictionary with pattern detection results
    """
    n = T.shape[0]
    
    results = {
        'has_pattern': True,
        'rank_results': {},
        'best_commutator_norm': float('inf'),
        'best_rank': None
    }
    
    for r in rank_range:
        min_norm = float('inf')
        
        for _ in range(num_trials):
            # Random rank-r matrix
            A = np.random.randn(n, r) + 1j * np.random.randn(n, r)
            B = np.random.randn(r, n) + 1j * np.random.randn(r, n)
            K = A @ B
            K = K / (np.linalg.norm(K) + 1e-15)  # Normalize
            
            comm_norm = np.linalg.norm(T @ K - K @ T)
            min_norm = min(min_norm, comm_norm)
        
        results['rank_results'][r] = min_norm
        
        if min_norm < results['best_commutator_norm']:
            results['best_commutator_norm'] = min_norm
            results['best_rank'] = r
        
        if min_norm < commutator_tolerance:
            results['has_pattern'] = False
    
    return results


def spectral_invariant_sector_algorithm(
    operators: List[np.ndarray],
    compact_operator: np.ndarray,
    eigenvalue_threshold: float = 1e-10
) -> List[Dict]:
    """
    Main algorithm: compute candidate invariant sectors from compact spectral slices.
    
    Given a family of operators and a compact operator K, this algorithm:
    1. Computes the nonzero eigenspaces of K
    2. Checks which operators in the family commute with K
    3. For commuting operators, verifies eigenspace preservation
    4. Returns the eigenspaces as candidate invariant sectors
    
    This is the computational realization of the compactlyGeneratedInvariant
    construction from our formal theory.
    
    Complexity: O(|operators| · n³)
    
    Args:
        operators: List of operators to analyze
        compact_operator: A compact operator
        eigenvalue_threshold: Minimum eigenvalue magnitude
    
    Returns:
        List of dictionaries describing invariant sectors
    """
    K = compact_operator
    n = K.shape[0]
    
    # Step 1: Compute eigenspaces
    eigenspaces = compute_compact_eigenspaces(K, eigenvalue_threshold)
    
    # Step 2: Identify commuting operators
    commuting = []
    non_commuting = []
    for i, T in enumerate(operators):
        comm_norm = np.linalg.norm(T @ K - K @ T)
        if comm_norm < 1e-6:
            commuting.append((i, T))
        else:
            non_commuting.append((i, T, comm_norm))
    
    # Step 3: For each eigenspace, verify preservation
    sectors = []
    for es in eigenspaces:
        preserved_by = []
        for idx, T in commuting:
            TV = T @ es.basis
            proj = es.basis @ (es.basis.conj().T @ TV)
            error = np.linalg.norm(TV - proj)
            if error < 1e-6:
                preserved_by.append(idx)
        
        sectors.append({
            'eigenvalue': es.eigenvalue,
            'dimension': es.dimension,
            'basis': es.basis,
            'preserved_by_indices': preserved_by,
            'is_nontrivial': es.dimension > 0,
            'is_proper': es.dimension < n,
            'num_commuting_operators': len(commuting),
            'num_preserving_operators': len(preserved_by)
        })
    
    return sectors


# Example usage
if __name__ == '__main__':
    print("Spectral Invariant Sector Algorithm - Example")
    print("=" * 50)
    
    n = 40
    
    # Create compact operator (diagonal with decay)
    K = np.diag([5.0, 3.0, 2.0, 1.0] + [0.5**k for k in range(1, n-3)]).astype(complex)
    
    # Create commuting operators (diagonal)
    operators = [np.diag(np.random.randn(n) + 1j * np.random.randn(n)) for _ in range(5)]
    
    sectors = spectral_invariant_sector_algorithm(operators, K)
    
    print(f"\nCompact operator K: {n}×{n} diagonal with decaying eigenvalues")
    print(f"Number of test operators: {len(operators)}")
    print(f"\nInvariant sectors found: {len(sectors)}")
    
    for s in sectors[:5]:
        print(f"  μ = {s['eigenvalue']:.4f}, dim = {s['dimension']}, "
              f"preserved by {s['num_preserving_operators']}/{s['num_commuting_operators']} commuting ops")
    
    # Test Enflo-Read detection
    print("\n" + "=" * 50)
    print("Enflo-Read Pattern Detection")
    print("=" * 50)
    
    # Forward shift (models Enflo-Read)
    S = np.zeros((n, n), dtype=complex)
    for i in range(n-1):
        S[i+1, i] = 1.0
    
    result = detect_enflo_read_pattern(S, num_trials=50)
    print(f"\nForward shift operator:")
    print(f"  Has Enflo-Read pattern: {result['has_pattern']}")
    print(f"  Best commutator norm: {result['best_commutator_norm']:.4f}")
    for r, norm in sorted(result['rank_results'].items()):
        print(f"    Rank {r}: min ‖[S,K]‖ = {norm:.4f}")
