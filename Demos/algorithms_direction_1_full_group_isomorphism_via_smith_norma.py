"""
Algorithms for the Tropical-Arithmetic SNF Correspondence.

Implements the core computational pipeline:
1. Graph Laplacian computation
2. Restricted Laplacian extraction
3. Smith Normal Form decomposition
4. Canonical generator construction
5. Cokernel decomposition

All functions are typed and documented.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from math import gcd
from functools import reduce


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the combinatorial Laplacian of a graph.
    
    Args:
        adj: Adjacency matrix (symmetric, 0-1, zero diagonal).
        
    Returns:
        Laplacian matrix L = D - A where D = diag(deg).
        
    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])
        >>> graph_laplacian(adj)
        array([[ 2, -1, -1],
               [-1,  2, -1],
               [-1, -1,  2]])
    """
    deg = np.sum(adj, axis=1)
    return np.diag(deg) - adj


def restricted_laplacian(L: np.ndarray, S: List[int]) -> np.ndarray:
    """Extract the restricted Laplacian (principal minor) for vertex set S.
    
    Args:
        L: Full Laplacian matrix.
        S: List of vertex indices in the subset.
        
    Returns:
        |S| x |S| matrix L_S.
        
    Example:
        >>> L = graph_laplacian(np.array([[0,1,0],[1,0,1],[0,1,0]]))
        >>> restricted_laplacian(L, [0, 2])
        array([[ 1,  0],
               [ 0,  1]])
    """
    idx = np.array(S)
    return L[np.ix_(idx, idx)]


def is_separated(adj: np.ndarray, S: List[int]) -> bool:
    """Check if vertex set S is separated (independent) in the graph.
    
    Args:
        adj: Adjacency matrix.
        S: List of vertex indices.
        
    Returns:
        True if no two vertices in S are adjacent.
    """
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if adj[S[i], S[j]] != 0:
                return False
    return True


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the Smith Normal Form of an integer matrix.
    
    Returns (U, D, V) such that U @ M @ V = D, where:
    - U, V are unimodular (det ±1)
    - D is diagonal with d_i | d_{i+1}
    
    Uses the classical algorithm with row/column operations.
    
    Args:
        M: Integer matrix.
        
    Returns:
        Tuple (U, D, V) with U @ M @ V = D.
    """
    n, m = M.shape
    D = M.copy().astype(np.int64)
    U = np.eye(n, dtype=np.int64)
    V = np.eye(m, dtype=np.int64)
    
    for k in range(min(n, m)):
        # Find pivot
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if D[i, j] != 0:
                    # Swap to position (k, k)
                    D[[k, i]] = D[[i, k]]
                    U[[k, i]] = U[[i, k]]
                    D[:, [k, j]] = D[:, [j, k]]
                    V[:, [k, j]] = V[:, [j, k]]
                    found = True
                    break
            if found:
                break
        
        if not found:
            break
        
        # Make D[k,k] positive
        if D[k, k] < 0:
            D[k] = -D[k]
            U[k] = -U[k]
        
        # Eliminate entries in row k and column k
        changed = True
        while changed:
            changed = False
            
            # Column operations
            for j in range(k + 1, m):
                if D[k, j] != 0:
                    q = D[k, j] // D[k, k]
                    D[:, j] -= q * D[:, k]
                    V[:, j] -= q * V[:, k]
                    if D[k, j] != 0:
                        # GCD step
                        g = gcd(abs(int(D[k, k])), abs(int(D[k, j])))
                        if g < abs(D[k, k]):
                            # Extended GCD to reduce
                            a, b = int(D[k, k]), int(D[k, j])
                            # Find s, t such that s*a + t*b = g
                            s, t = _extended_gcd(a, b)
                            new_col_k = s * D[:, k] + t * D[:, j]
                            new_col_j = -(b // g) * D[:, k] + (a // g) * D[:, j]
                            D[:, k] = new_col_k
                            D[:, j] = new_col_j
                            new_v_k = s * V[:, k] + t * V[:, j]
                            new_v_j = -(b // g) * V[:, k] + (a // g) * V[:, j]
                            V[:, k] = new_v_k
                            V[:, j] = new_v_j
                        changed = True
            
            # Row operations
            for i in range(k + 1, n):
                if D[i, k] != 0:
                    q = D[i, k] // D[k, k]
                    D[i] -= q * D[k]
                    U[i] -= q * U[k]
                    if D[i, k] != 0:
                        a, b = int(D[k, k]), int(D[i, k])
                        s, t = _extended_gcd(a, b)
                        g = s * a + t * b
                        new_row_k = s * D[k] + t * D[i]
                        new_row_i = -(b // g) * D[k] + (a // g) * D[i]
                        D[k] = new_row_k
                        D[i] = new_row_i
                        new_u_k = s * U[k] + t * U[i]
                        new_u_i = -(b // g) * U[k] + (a // g) * U[i]
                        U[k] = new_u_k
                        U[i] = new_u_i
                        changed = True
        
        # Ensure positive diagonal
        if D[k, k] < 0:
            D[k] = -D[k]
            U[k] = -U[k]
    
    # Ensure divisibility chain by bubble-sorting with GCD
    for _ in range(min(n, m)):
        for k in range(min(n, m) - 1):
            if D[k, k] != 0 and D[k+1, k+1] != 0:
                g = gcd(abs(int(D[k, k])), abs(int(D[k+1, k+1])))
                if g != abs(D[k, k]):
                    l = abs(int(D[k, k])) * abs(int(D[k+1, k+1])) // g
                    D[k, k] = g
                    D[k+1, k+1] = l
    
    return U, D, V


def _extended_gcd(a: int, b: int) -> Tuple[int, int]:
    """Extended GCD: returns (s, t) such that s*a + t*b = gcd(a, b)."""
    if b == 0:
        return (1, 0) if a >= 0 else (-1, 0)
    old_r, r = a, b
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        q = old_r // r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    if old_r < 0:
        return -old_s, -old_t
    return old_s, old_t


def invariant_factors(M: np.ndarray) -> List[int]:
    """Compute the invariant factors of an integer matrix.
    
    Args:
        M: Integer matrix.
        
    Returns:
        List of nonzero diagonal entries of the SNF, in divisibility order.
    """
    _, D, _ = smith_normal_form(M)
    factors = [abs(int(D[i, i])) for i in range(min(D.shape)) if D[i, i] != 0]
    factors.sort()
    return factors


def canonical_harmonic_generators(adj: np.ndarray, S: List[int]) -> List[np.ndarray]:
    """Construct canonical harmonic generators for a separated set.
    
    For separated S, the canonical generator for vertex s is the
    indicator function: 1 at s, 0 elsewhere.
    
    Args:
        adj: Adjacency matrix.
        S: Separated vertex subset.
        
    Returns:
        List of generator vectors (one per vertex in S).
    """
    n = adj.shape[0]
    generators = []
    for s in S:
        gen = np.zeros(n, dtype=np.int64)
        gen[s] = 1
        generators.append(gen)
    return generators


def boundary_restriction(gen: np.ndarray, S: List[int]) -> np.ndarray:
    """Restrict a function on V to the subset S.
    
    Args:
        gen: Function values on all vertices.
        S: Subset indices.
        
    Returns:
        Restriction to S.
    """
    return gen[S]


def cokernel_decomposition(L_S: np.ndarray) -> List[int]:
    """Decompose the Laplacian cokernel as a product of cyclic groups.
    
    Returns the list of cyclic group orders d_i such that
    Z^n / Im(L_S) ≅ ⊕ Z/d_i.
    
    Args:
        L_S: Restricted Laplacian matrix.
        
    Returns:
        List of cyclic group orders (invariant factors > 1).
    """
    factors = invariant_factors(L_S)
    return [f for f in factors if f > 1]


def full_pipeline(adj: np.ndarray, S: List[int]) -> Dict:
    """Execute the complete tropical-to-SNF correspondence pipeline.
    
    Args:
        adj: Adjacency matrix of the graph.
        S: Nonempty separated vertex subset.
        
    Returns:
        Dictionary containing all computed data.
    """
    assert is_separated(adj, S), "S must be separated"
    assert len(S) > 0, "S must be nonempty"
    
    n = adj.shape[0]
    L = graph_laplacian(adj)
    L_S = restricted_laplacian(L, S)
    
    # Canonical generators
    generators = canonical_harmonic_generators(adj, S)
    restrictions = [boundary_restriction(g, S) for g in generators]
    
    # SNF decomposition
    U, D, V = smith_normal_form(L_S)
    
    # Invariant factors
    factors = [abs(int(D[i, i])) for i in range(len(S)) if D[i, i] != 0]
    
    # Cokernel decomposition
    cyclic_orders = cokernel_decomposition(L_S)
    
    # Torsion order
    det = int(np.round(np.linalg.det(L_S.astype(float))))
    
    # Vertex degrees at S
    degrees = [int(np.sum(adj[s])) for s in S]
    
    return {
        'graph_size': n,
        'subset_S': S,
        'laplacian': L,
        'restricted_laplacian': L_S,
        'is_diagonal': np.allclose(L_S - np.diag(np.diag(L_S)), 0),
        'generators': generators,
        'restrictions': restrictions,
        'snf_U': U,
        'snf_D': D,
        'snf_V': V,
        'invariant_factors': factors,
        'cyclic_orders': cyclic_orders,
        'determinant': det,
        'degrees_at_S': degrees,
        'det_equals_prod_degrees': det == reduce(lambda x, y: x * y, degrees, 1),
    }


def enumerate_separated_sets(adj: np.ndarray) -> List[List[int]]:
    """Enumerate all nonempty separated (independent) sets of a graph.
    
    Args:
        adj: Adjacency matrix.
        
    Returns:
        List of all nonempty independent sets.
    """
    n = adj.shape[0]
    result = []
    for mask in range(1, 1 << n):
        S = [i for i in range(n) if mask & (1 << i)]
        if is_separated(adj, S):
            result.append(S)
    return result


def verify_correspondence(adj: np.ndarray, max_subset_size: int = 8) -> Dict:
    """Verify the SNF correspondence for all separated subsets of a graph.
    
    Args:
        adj: Adjacency matrix.
        max_subset_size: Maximum subset size to test.
        
    Returns:
        Summary of verification results.
    """
    separated_sets = enumerate_separated_sets(adj)
    results = {
        'total_sets': len(separated_sets),
        'all_diagonal': True,
        'all_det_match': True,
        'failures': []
    }
    
    for S in separated_sets:
        if len(S) > max_subset_size:
            continue
        data = full_pipeline(adj, S)
        if not data['is_diagonal']:
            results['all_diagonal'] = False
            results['failures'].append(('not_diagonal', S))
        if not data['det_equals_prod_degrees']:
            results['all_det_match'] = False
            results['failures'].append(('det_mismatch', S))
    
    return results


if __name__ == '__main__':
    # Example: Path graph P_4
    adj = np.array([
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [0, 0, 1, 0]
    ])
    
    print("=== Path Graph P_4 ===")
    S = [0, 2]  # Separated set
    result = full_pipeline(adj, S)
    print(f"Subset S = {result['subset_S']}")
    print(f"Degrees at S = {result['degrees_at_S']}")
    print(f"Restricted Laplacian:\n{result['restricted_laplacian']}")
    print(f"Is diagonal: {result['is_diagonal']}")
    print(f"Determinant = {result['determinant']}")
    print(f"Product of degrees = {reduce(lambda x, y: x * y, result['degrees_at_S'], 1)}")
    print(f"det = ∏ deg: {result['det_equals_prod_degrees']}")
    print(f"Invariant factors: {result['invariant_factors']}")
    print(f"Cokernel ≅ {'×'.join(f'Z/{d}' for d in result['cyclic_orders']) or 'trivial'}")
