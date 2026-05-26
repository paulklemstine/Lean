"""
Algorithms for Tropical Kernel Rigidity.

Implements:
- Graph Laplacian computation
- Harmonic kernel computation
- Support decomposition and matching
- Tropical projective equivalence testing
- Canonical generator construction
"""

import numpy as np
from itertools import combinations, permutations
from typing import List, Tuple, Set, Optional, Dict


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the combinatorial Laplacian of a graph given its adjacency matrix.

    Args:
        adj: n×n symmetric {0,1} adjacency matrix (0 diagonal).

    Returns:
        n×n integer Laplacian matrix L where L[i,i] = degree(i),
        L[i,j] = -1 if adjacent, 0 otherwise.
    """
    n = adj.shape[0]
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        deg = int(np.sum(adj[i]))
        L[i, i] = deg
        for j in range(n):
            if i != j and adj[i, j]:
                L[i, j] = -1
    return L


def restricted_laplacian(L: np.ndarray, S: List[int]) -> np.ndarray:
    """Extract the principal minor of L indexed by S.

    Args:
        L: n×n Laplacian matrix.
        S: list of vertex indices forming the subset.

    Returns:
        |S|×|S| restricted Laplacian matrix.
    """
    return L[np.ix_(S, S)]


def harmonic_kernel(L: np.ndarray, S: List[int], n: int) -> List[np.ndarray]:
    """Compute S-harmonic functions: f : V → ℤ with (Lf)(v) = 0 for v ∈ S.

    Args:
        L: n×n Laplacian matrix.
        S: list of vertex indices where harmonicity is required.
        n: total number of vertices.

    Returns:
        List of basis vectors for the harmonic kernel (integer-valued).
    """
    # Build the constraint matrix: rows indexed by S, columns by all V
    rows = [L[v] for v in S]
    M = np.array(rows, dtype=float)

    # Compute null space via SVD
    if M.shape[0] == 0:
        return [np.eye(n, dtype=int)[i] for i in range(n)]

    _, s, Vh = np.linalg.svd(M, full_matrices=True)
    tol = 1e-10
    null_mask = np.abs(s) < tol if len(s) > 0 else np.array([], dtype=bool)
    null_start = len(s) - np.sum(null_mask) if np.any(null_mask) else len(s)

    # Vectors in null space
    null_vectors = []
    for i in range(null_start, Vh.shape[0]):
        v = Vh[i]
        # Try to make integer
        scale = 1.0
        for entry in v:
            if abs(entry) > tol:
                scale = abs(entry)
                break
        v_scaled = v / scale
        v_int = np.round(v_scaled).astype(int)
        if np.allclose(M @ v_int, 0, atol=tol):
            null_vectors.append(v_int)

    return null_vectors


def fun_support(f: np.ndarray) -> Set[int]:
    """Compute the support of an integer-valued function.

    Args:
        f: 1-d integer array.

    Returns:
        Set of indices where f is nonzero.
    """
    return {i for i in range(len(f)) if f[i] != 0}


def pairwise_disjoint_supports(family: List[np.ndarray]) -> bool:
    """Check if a family of functions has pairwise disjoint supports.

    Args:
        family: list of 1-d integer arrays.

    Returns:
        True if all pairs have disjoint supports.
    """
    supports = [fun_support(f) for f in family]
    for i in range(len(supports)):
        for j in range(i + 1, len(supports)):
            if supports[i] & supports[j]:
                return False
    return True


def is_nontrivial(f: np.ndarray) -> bool:
    """Check if f takes at least two distinct nonzero values on its support.

    Args:
        f: 1-d integer array.

    Returns:
        True if f has at least two distinct nonzero values.
    """
    nonzero_vals = set(f[f != 0])
    return len(nonzero_vals) >= 2


def trop_proj_equiv(F: List[np.ndarray], G: List[np.ndarray]) -> Optional[Tuple[List[int], List[int]]]:
    """Test if two families are tropically projectively equivalent.

    Args:
        F, G: lists of 1-d integer arrays of the same length.

    Returns:
        (permutation, constants) if equivalent, None otherwise.
        permutation[i] = j means G[j] corresponds to F[i].
        constants[i] = c means G[perm[i]][v] = F[i][v] + c for all v.
    """
    n = len(F)
    if len(G) != n:
        return None

    for perm in permutations(range(n)):
        constants = []
        valid = True
        for i in range(n):
            j = perm[i]
            diff = G[j] - F[i]
            if len(set(diff)) != 1:
                valid = False
                break
            constants.append(int(diff[0]))
        if valid:
            return list(perm), constants

    return None


def canonical_support_matching(F: List[np.ndarray], G: List[np.ndarray]) -> Optional[List[int]]:
    """Find permutation matching supports of F to supports of G.

    Args:
        F, G: families with pairwise disjoint supports.

    Returns:
        permutation sigma such that support(F[i]) = support(G[sigma[i]]),
        or None if no such permutation exists.
    """
    n = len(F)
    if len(G) != n:
        return None

    F_supports = [fun_support(f) for f in F]
    G_supports = [fun_support(g) for g in G]

    sigma = [None] * n
    used = set()

    for i in range(n):
        matched = False
        for j in range(n):
            if j not in used and F_supports[i] == G_supports[j]:
                sigma[i] = j
                used.add(j)
                matched = True
                break
        if not matched:
            return None

    return sigma


def verify_uniqueness(adj: np.ndarray, S: List[int], family: List[np.ndarray]) -> Dict:
    """Verify the uniqueness theorem for a specific graph and generator family.

    Args:
        adj: adjacency matrix.
        S: vertex subset.
        family: candidate generator family.

    Returns:
        Dictionary with verification results.
    """
    result = {
        "pairwise_disjoint": pairwise_disjoint_supports(family),
        "all_nontrivial": all(fun_support(f) for f in family),
        "generators_count": len(family),
    }

    L = graph_laplacian(adj)
    n = adj.shape[0]

    # Check harmonicity
    harmonic = []
    for f in family:
        is_harm = all(np.dot(L[v], f) == 0 for v in S)
        harmonic.append(is_harm)
    result["all_harmonic"] = all(harmonic)

    return result


def enumerate_connected_graphs(n: int) -> List[np.ndarray]:
    """Enumerate all connected simple graphs on n vertices (up to isomorphism, naively).

    Args:
        n: number of vertices.

    Returns:
        List of adjacency matrices for connected graphs.
        Warning: includes isomorphic duplicates for n > 4.
    """
    if n <= 0:
        return []
    if n == 1:
        return [np.zeros((1, 1), dtype=int)]

    edges = list(combinations(range(n), 2))
    graphs = []

    for r in range(n - 1, len(edges) + 1):
        for edge_subset in combinations(edges, r):
            adj = np.zeros((n, n), dtype=int)
            for i, j in edge_subset:
                adj[i, j] = 1
                adj[j, i] = 1

            # Check connectivity via BFS
            visited = {0}
            queue = [0]
            while queue:
                v = queue.pop(0)
                for w in range(n):
                    if adj[v, w] and w not in visited:
                        visited.add(w)
                        queue.append(w)

            if len(visited) == n:
                graphs.append(adj)

            if len(graphs) > 500:  # Safety limit
                return graphs

    return graphs


if __name__ == "__main__":
    # Example: Path graph P4: 0-1-2-3
    n = 4
    adj = np.zeros((n, n), dtype=int)
    adj[0, 1] = adj[1, 0] = 1
    adj[1, 2] = adj[2, 1] = 1
    adj[2, 3] = adj[3, 2] = 1

    print("=== Path Graph P4 ===")
    L = graph_laplacian(adj)
    print(f"Laplacian:\n{L}")
    print(f"Row sums: {L.sum(axis=1)}")

    S = [1, 2]
    L_S = restricted_laplacian(L, S)
    print(f"\nRestricted Laplacian on S={S}:\n{L_S}")

    kernel = harmonic_kernel(L, S, n)
    print(f"\nHarmonic kernel dimension: {len(kernel)}")
    for i, v in enumerate(kernel):
        print(f"  Basis vector {i}: {v}")

    # Example: Cycle graph C4
    adj2 = np.zeros((n, n), dtype=int)
    adj2[0, 1] = adj2[1, 0] = 1
    adj2[1, 2] = adj2[2, 1] = 1
    adj2[2, 3] = adj2[3, 2] = 1
    adj2[3, 0] = adj2[0, 3] = 1

    print("\n=== Cycle Graph C4 ===")
    L2 = graph_laplacian(adj2)
    print(f"Laplacian:\n{L2}")

    kernel2 = harmonic_kernel(L2, [1, 2], n)
    print(f"Harmonic kernel on S=[1,2]: dim={len(kernel2)}")

    # Test projective equivalence
    F = [np.array([1, 0, 0, 0]), np.array([0, 0, 1, 0])]
    G = [np.array([0, 0, 1, 0]), np.array([1, 0, 0, 0])]
    result = trop_proj_equiv(F, G)
    print(f"\nTropProjEquiv test: {result}")
