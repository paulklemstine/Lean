#!/usr/bin/env python3
"""
Algorithms for Chip-Firing Canonical Forms via Tropical Kernels

Implements the core computational methods for:
1. Graph Laplacian construction and restricted Laplacian extraction
2. Smith Normal Form computation for integer matrices
3. Harmonic kernel computation and normalization
4. Canonical tropical kernel generator identification
5. Firing equivalence checking
6. Critical group structure computation

All algorithms work over integer arithmetic where possible,
falling back to rational/floating-point for kernel computation.
"""

from typing import List, Tuple, Optional, Dict
import numpy as np
from copy import deepcopy


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """
    Compute the combinatorial graph Laplacian L = D - A.
    
    Parameters:
        adj: n×n symmetric adjacency matrix (0/1 entries)
    
    Returns:
        n×n integer Laplacian matrix
    
    Time: O(n²), Space: O(n²)
    
    >>> A = np.array([[0,1,1],[1,0,1],[1,1,0]])
    >>> graph_laplacian(A)
    array([[ 2, -1, -1],
           [-1,  2, -1],
           [-1, -1,  2]])
    """
    n = adj.shape[0]
    D = np.diag(adj.sum(axis=1).astype(int))
    return D - adj.astype(int)


def restricted_laplacian(L: np.ndarray, S: List[int]) -> np.ndarray:
    """
    Extract the principal minor of Laplacian L indexed by subset S.
    
    Parameters:
        L: n×n Laplacian matrix
        S: list of vertex indices forming the subset
    
    Returns:
        |S|×|S| restricted Laplacian matrix
    
    Time: O(|S|²), Space: O(|S|²)
    """
    return L[np.ix_(S, S)].copy()


def smith_normal_form(M: np.ndarray) -> Tuple[List[int], np.ndarray]:
    """
    Compute the Smith Normal Form of an integer matrix.
    
    Returns the invariant factors (diagonal entries) and the
    transformed matrix in SNF.
    
    Parameters:
        M: m×n integer matrix
    
    Returns:
        (invariant_factors, snf_matrix) where invariant_factors
        is a list of positive integers d_1 | d_2 | ... | d_r
    
    Time: O(n³ · log(max_entry)) expected, Space: O(n²)
    
    Algorithm: Row/column reduction with gcd pivoting.
    """
    M = np.array(M, dtype=np.int64).copy()
    rows, cols = M.shape
    min_dim = min(rows, cols)
    
    for k in range(min_dim):
        # Find pivot
        subM = M[k:, k:]
        if np.all(subM == 0):
            break
        
        for iteration in range(2000):
            nonzero = np.argwhere(M[k:, k:] != 0)
            if len(nonzero) == 0:
                break
            
            abs_vals = np.array([abs(int(M[k + r, k + c])) for r, c in nonzero])
            min_idx = np.argmin(abs_vals)
            r, c = nonzero[min_idx]
            r, c = int(r + k), int(c + k)
            
            if r != k:
                M[[k, r]] = M[[r, k]]
            if c != k:
                M[:, [k, c]] = M[:, [c, k]]
            
            if M[k, k] < 0:
                M[k] = -M[k]
            
            if M[k, k] == 0:
                break
            
            changed = False
            for i in range(k + 1, rows):
                if M[i, k] != 0:
                    q = int(M[i, k]) // int(M[k, k])
                    M[i] -= q * M[k]
                    if M[i, k] != 0:
                        changed = True
            
            for j in range(k + 1, cols):
                if M[k, j] != 0:
                    q = int(M[k, j]) // int(M[k, k])
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        changed = True
            
            if not changed:
                all_divide = True
                for i in range(k + 1, rows):
                    for j in range(k + 1, cols):
                        if M[k, k] != 0 and M[i, j] % M[k, k] != 0:
                            M[i] += M[k]
                            all_divide = False
                            break
                    if not all_divide:
                        break
                if all_divide:
                    break
    
    factors = []
    for k in range(min_dim):
        if M[k, k] != 0:
            factors.append(abs(int(M[k, k])))
    
    return factors, M


def compute_critical_group(L: np.ndarray, S: List[int]) -> Dict:
    """
    Compute the restricted critical group structure.
    
    The critical group is the cokernel of the restricted Laplacian:
    Z^|S| / Im(L_S)
    
    Parameters:
        L: full graph Laplacian
        S: subset indices
    
    Returns:
        Dictionary with:
        - 'invariant_factors': list of invariant factors > 1
        - 'order': order of the critical group (product of factors)
        - 'rank': rank of L_S
        - 'snf_diagonal': full SNF diagonal
    
    Time: O(|S|³ · log(max_entry)), Space: O(|S|²)
    """
    L_S = restricted_laplacian(L, S)
    factors, _ = smith_normal_form(L_S)
    
    nontrivial = [f for f in factors if f > 1]
    order = 1
    for f in nontrivial:
        order *= f
    
    return {
        'invariant_factors': nontrivial,
        'order': order,
        'rank': len(factors),
        'snf_diagonal': factors,
    }


def harmonic_kernel_basis(L: np.ndarray, S: List[int]) -> np.ndarray:
    """
    Compute a basis for the harmonic kernel on subset S.
    
    Finds vectors f such that (L_S · f)_v = 0 for all v in S.
    
    Parameters:
        L: full graph Laplacian
        S: subset indices
    
    Returns:
        k×|S| matrix whose rows are kernel basis vectors
    
    Time: O(|S|³), Space: O(|S|²)
    """
    L_S = restricted_laplacian(L, S)
    _, s, Vh = np.linalg.svd(L_S.astype(float))
    tol = 1e-8 * max(s) if len(s) > 0 and max(s) > 0 else 1e-8
    null_mask = s < tol
    return Vh[null_mask]


def normalize_mod_constants(vecs: np.ndarray) -> np.ndarray:
    """
    Normalize kernel vectors modulo constants.
    
    Subtracts the mean from each vector, effectively projecting
    onto the hyperplane orthogonal to the constant vector.
    
    Parameters:
        vecs: k×n matrix of kernel basis vectors
    
    Returns:
        k×n matrix of normalized vectors
    """
    if len(vecs) == 0:
        return vecs
    means = vecs.mean(axis=1, keepdims=True)
    return vecs - means


def canonical_generators(L: np.ndarray, S: List[int]) -> List[np.ndarray]:
    """
    Compute canonical tropical kernel generators on S.
    
    These are the normalized harmonic kernel vectors that form
    the canonical generating set for the tropical kernel modulo
    constants.
    
    Parameters:
        L: full graph Laplacian
        S: subset indices
    
    Returns:
        List of normalized generator vectors (empty list if kernel
        is trivial modulo constants)
    
    Time: O(|S|³), Space: O(|S|²)
    """
    basis = harmonic_kernel_basis(L, S)
    if basis.shape[0] <= 1:
        # Only constant direction or empty
        return []
    
    # Remove constant direction
    n = basis.shape[1]
    const = np.ones(n) / np.sqrt(n)
    
    # Project out constant component
    projected = []
    for v in basis:
        v_proj = v - np.dot(v, const) * const
        if np.linalg.norm(v_proj) > 1e-10:
            v_proj = v_proj / np.linalg.norm(v_proj)
            projected.append(v_proj)
    
    return projected


def is_firing_equivalent(L: np.ndarray, S: List[int],
                          f: np.ndarray, g: np.ndarray) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if f and g are firing-equivalent on S.
    
    Two functions are firing-equivalent if g - f lies in the image
    of L restricted to functions supported on S.
    
    Parameters:
        L: full graph Laplacian
        S: subset indices
        f, g: integer-valued functions on all vertices
    
    Returns:
        (is_equivalent, firing_vector) where firing_vector is the
        vector c such that g = f + L·c (or None if not equivalent)
    
    Time: O(n³), Space: O(n²)
    """
    n = L.shape[0]
    diff = g - f
    
    # Restrict to S: need c supported on S such that L_S · c_S = diff_S
    L_S = restricted_laplacian(L, S)
    diff_S = diff[S]
    
    try:
        c_S = np.linalg.solve(L_S.astype(float), diff_S.astype(float))
        # Check if integer solution
        c_S_int = np.round(c_S).astype(int)
        residual = L_S @ c_S_int - diff_S
        if np.allclose(residual, 0):
            c = np.zeros(n, dtype=int)
            for i, s in enumerate(S):
                c[s] = c_S_int[i]
            return True, c
    except np.linalg.LinAlgError:
        pass
    
    return False, None


def harmonic_normal_form(L: np.ndarray, S: List[int],
                          D: np.ndarray) -> Optional[np.ndarray]:
    """
    Compute the harmonic normal form of a divisor D on S.
    
    Finds a function f firing-equivalent to D on S such that
    f is harmonic on S and normalized.
    
    Parameters:
        L: full graph Laplacian
        S: subset indices
        D: integer-valued divisor (function on vertices)
    
    Returns:
        Harmonic normal form, or None if not found
    
    Time: O(n³), Space: O(n²)
    """
    n = L.shape[0]
    L_S = restricted_laplacian(L, S)
    
    # We want f = D + L·c where L_S·f_S = 0
    # i.e., L_S·(D_S + L_S·c_S) = 0
    # i.e., L_S·D_S + L_S²·c_S = 0
    # i.e., c_S = -(L_S²)^{-1} · L_S · D_S (when L_S² is invertible)
    
    D_S = D[S].astype(float)
    LD = L_S.astype(float) @ D_S
    L2 = L_S.astype(float) @ L_S.astype(float)
    
    try:
        c_S = -np.linalg.solve(L2, LD)
        f = D.astype(float).copy()
        for i, s in enumerate(S):
            for j, s2 in enumerate(S):
                f[s2] += L_S[j, i] * c_S[i]
        
        # Normalize
        f_S = f[S]
        f_S -= f_S.mean()
        f[S] = f_S
        
        return f
    except np.linalg.LinAlgError:
        return None


# Example usage
if __name__ == "__main__":
    print("Algorithms for Tropical Kernel Canonical Forms")
    print("=" * 50)
    
    # Example: K_4 minus one vertex as S
    A = np.array([
        [0, 1, 1, 1],
        [1, 0, 1, 1],
        [1, 1, 0, 1],
        [1, 1, 1, 0],
    ])
    L = graph_laplacian(A)
    S = [0, 1, 2]
    
    print(f"\nComplete graph K_4")
    print(f"Laplacian:\n{L}")
    print(f"Subset S = {S}")
    
    cg = compute_critical_group(L, S)
    print(f"\nCritical group structure:")
    print(f"  Invariant factors: {cg['invariant_factors']}")
    print(f"  Order: {cg['order']}")
    
    gens = canonical_generators(L, S)
    print(f"\nCanonical generators (mod constants): {len(gens)}")
    for i, g in enumerate(gens):
        print(f"  Generator {i+1}: {np.round(g, 4)}")
    
    # Test firing equivalence
    f = np.array([1, 0, 0, -1])
    g = np.array([0, 1, 0, -1])
    equiv, c = is_firing_equivalent(L, S, f, g)
    print(f"\nFiring equivalence test:")
    print(f"  f = {f}, g = {g}")
    print(f"  Equivalent: {equiv}")
    if c is not None:
        print(f"  Firing vector: {c}")
