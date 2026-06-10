"""
Algorithms for 4-Manifold Intersection Form Analysis

Implements the algebraic machinery for detecting exotic smooth structures
on 4-manifolds via intersection form theory (Donaldson/Freedman/Furuta).
"""

from typing import List, Tuple, Optional
import numpy as np


def quadratic_form(M: np.ndarray, v: np.ndarray) -> int:
    """Compute Q_M(v) = v^T M v for integer matrix M and vector v."""
    return int(v @ M @ v)


def has_even_diagonal(M: np.ndarray) -> bool:
    """Check if all diagonal entries of M are even."""
    return all(int(M[i, i]) % 2 == 0 for i in range(M.shape[0]))


def is_unimodular(M: np.ndarray) -> bool:
    """Check if det(M) = ±1 (unimodular matrix)."""
    det = int(round(np.linalg.det(M)))
    return det == 1 or det == -1


def is_symmetric(M: np.ndarray) -> bool:
    """Check if M is symmetric."""
    return np.allclose(M, M.T)


def is_positive_definite(M: np.ndarray) -> bool:
    """Check if M is positive definite via eigenvalue test."""
    if not is_symmetric(M):
        return False
    eigenvalues = np.linalg.eigvalsh(M)
    return all(ev > 0 for ev in eigenvalues)


def verify_exotic_witness(M: np.ndarray) -> dict:
    """
    Verify whether an integer matrix constitutes an ExoticWitness.
    
    An ExoticWitness is a symmetric, even-diagonal, positive-definite,
    unimodular integer matrix. Such matrices certify (via Donaldson's
    theorem) that the corresponding topological 4-manifold has no
    smooth structure.
    
    Returns a dict with verification results for each property.
    """
    results = {
        'rank': M.shape[0],
        'symmetric': is_symmetric(M),
        'even_diagonal': has_even_diagonal(M),
        'positive_definite': is_positive_definite(M),
        'unimodular': is_unimodular(M),
        'determinant': int(round(np.linalg.det(M))),
    }
    results['is_exotic_witness'] = all([
        results['symmetric'],
        results['even_diagonal'],
        results['positive_definite'],
        results['unimodular'],
    ])
    return results


def minimum_norm_search(M: np.ndarray, search_radius: int = 3) -> Tuple[int, np.ndarray]:
    """
    Search for the minimum nonzero norm Q_M(v) over integer vectors
    with coordinates in [-search_radius, search_radius].
    
    Returns (min_norm, minimizing_vector).
    """
    n = M.shape[0]
    min_norm = float('inf')
    min_vec = None
    
    # Generate all vectors in the search cube
    from itertools import product
    for coords in product(range(-search_radius, search_radius + 1), repeat=n):
        v = np.array(coords, dtype=int)
        if np.all(v == 0):
            continue
        norm = quadratic_form(M, v)
        if norm < min_norm:
            min_norm = norm
            min_vec = v.copy()
    
    return int(min_norm), min_vec


def furuta_bound_check(rank: int, abs_signature: int) -> dict:
    """
    Check the Furuta 10/8 bound: 8*rank >= 10*|signature| + 16.
    
    Also checks the conjectured 11/8 bound: 8*rank >= 11*|signature|.
    """
    furuta_lhs = 8 * rank
    furuta_rhs = 10 * abs_signature + 16
    conjecture_rhs = 11 * abs_signature
    
    return {
        'rank': rank,
        'abs_signature': abs_signature,
        'furuta_satisfied': furuta_lhs >= furuta_rhs,
        'furuta_margin': furuta_lhs - furuta_rhs,
        'conjecture_11_8_satisfied': furuta_lhs >= conjecture_rhs,
        'conjecture_margin': furuta_lhs - conjecture_rhs,
        'rohlin_satisfied': abs_signature % 16 == 0,
    }


def intersection_form_geography(max_rank: int = 50) -> List[dict]:
    """
    Enumerate lattice points (rank, |σ|) satisfying necessary conditions
    for even smooth intersection forms:
    - Rohlin: σ ≡ 0 mod 16
    - Furuta: 8r ≥ 10|σ| + 16
    - Parity: r ≡ |σ| mod 2 (since r = b⁺ + b⁻, |σ| = |b⁺ - b⁻|)
    """
    feasible = []
    for rank in range(2, max_rank + 1):
        for abs_sig in range(0, rank + 1, 16):
            # Parity check: rank - abs_sig must be even
            if (rank - abs_sig) % 2 != 0:
                continue
            check = furuta_bound_check(rank, abs_sig)
            if check['furuta_satisfied'] and check['rohlin_satisfied']:
                feasible.append({
                    'rank': rank,
                    'abs_signature': abs_sig,
                    'b_plus': (rank + abs_sig) // 2,
                    'b_minus': (rank - abs_sig) // 2,
                    'furuta_margin': check['furuta_margin'],
                    'conjecture_11_8': check['conjecture_11_8_satisfied'],
                })
    return feasible


def e8_cartan_matrix() -> np.ndarray:
    """
    The E₈ Cartan matrix — the canonical example of an ExoticWitness.
    
    This 8×8 matrix is symmetric, has all diagonal entries = 2 (even),
    is positive definite, and has determinant 1 (unimodular).
    """
    E8 = np.array([
        [ 2, -1,  0,  0,  0,  0,  0,  0],
        [-1,  2, -1,  0,  0,  0,  0,  0],
        [ 0, -1,  2, -1,  0,  0,  0, -1],
        [ 0,  0, -1,  2, -1,  0,  0,  0],
        [ 0,  0,  0, -1,  2, -1,  0,  0],
        [ 0,  0,  0,  0, -1,  2, -1,  0],
        [ 0,  0,  0,  0,  0, -1,  2,  0],
        [ 0,  0, -1,  0,  0,  0,  0,  2],
    ], dtype=int)
    return E8


def signature_computation(M: np.ndarray) -> dict:
    """Compute the signature data of a symmetric matrix."""
    eigenvalues = np.linalg.eigvalsh(M)
    b_plus = sum(1 for ev in eigenvalues if ev > 1e-10)
    b_minus = sum(1 for ev in eigenvalues if ev < -1e-10)
    return {
        'b_plus': b_plus,
        'b_minus': b_minus,
        'rank': b_plus + b_minus,
        'signature': b_plus - b_minus,
    }
