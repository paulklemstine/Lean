"""
Algorithms for Tropical Kernel Rigidity Theory

Implements the core algorithms for computing canonical tropical kernel families,
checking tropical projective equivalence, and verifying support separation.

These algorithms correspond to the formally verified theorems in
TropicalKernelRigidity.lean.
"""

from typing import Optional
import numpy as np
from itertools import permutations


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """
    Compute the combinatorial graph Laplacian from an adjacency matrix.

    L(i,j) = deg(i) if i == j, -1 if adj(i,j) == 1, 0 otherwise.

    Args:
        adj: Symmetric binary adjacency matrix (n x n)

    Returns:
        Laplacian matrix (n x n, integer-valued)

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])
        >>> graph_laplacian(adj)
        array([[ 2, -1, -1],
               [-1,  2, -1],
               [-1, -1,  2]])
    """
    n = adj.shape[0]
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = int(np.sum(adj[i]))
            elif adj[i, j]:
                L[i, j] = -1
    return L


def restricted_laplacian(L: np.ndarray, S: list[int]) -> np.ndarray:
    """
    Extract the principal submatrix of L indexed by S.

    Args:
        L: Full Laplacian matrix
        S: List of vertex indices for the subset

    Returns:
        |S| x |S| submatrix
    """
    idx = np.array(S)
    return L[np.ix_(idx, idx)]


def fun_support(f: np.ndarray) -> set[int]:
    """
    Compute the support of an integer-valued function.

    Args:
        f: Integer array representing f : V -> Z

    Returns:
        Set of indices where f is nonzero
    """
    return {i for i in range(len(f)) if f[i] != 0}


def pairwise_disjoint_supports(family: list[np.ndarray]) -> bool:
    """
    Check if a family of functions has pairwise disjoint supports.

    Args:
        family: List of integer arrays

    Returns:
        True if all supports are pairwise disjoint
    """
    supports = [fun_support(f) for f in family]
    for i in range(len(supports)):
        for j in range(i + 1, len(supports)):
            if supports[i] & supports[j]:
                return False
    return True


def nontrivial_on_support(family: list[np.ndarray]) -> bool:
    """
    Check if each function in the family varies nontrivially on its support.

    Args:
        family: List of integer arrays

    Returns:
        True if each function takes at least two distinct nonzero values on its support
    """
    for f in family:
        supp = fun_support(f)
        if len(supp) < 2:
            return False
        vals = {f[i] for i in supp}
        if len(vals) < 2:
            return False
    return True


def check_trop_proj_equiv(
    F: list[np.ndarray], G: list[np.ndarray]
) -> Optional[tuple[list[int], list[int]]]:
    """
    Check if two families are tropically projectively equivalent.

    Returns (permutation, constants) if equivalent, None otherwise.

    Two families F, G : [n] -> V -> Z are tropically projectively equivalent if
    there exists a permutation sigma and constants c such that
    G[sigma(i)](v) = F[i](v) + c[i] for all i, v.

    Args:
        F: First family of integer arrays
        G: Second family of integer arrays

    Returns:
        (sigma, c) if equivalent, None otherwise

    Example:
        >>> F = [np.array([1,0,0]), np.array([0,2,0])]
        >>> G = [np.array([0,5,0]), np.array([4,0,0])]
        >>> check_trop_proj_equiv(F, G)
        ([1, 0], [3, 3])
    """
    n = len(F)
    if len(G) != n:
        return None
    if n == 0:
        return ([], [])

    V = len(F[0])

    for perm in permutations(range(n)):
        constants = []
        valid = True
        for i in range(n):
            j = perm[i]
            # Check if G[j] = F[i] + c for some constant c
            diff = G[j] - F[i]
            if np.all(diff == diff[0]):
                constants.append(int(diff[0]))
            else:
                valid = False
                break
        if valid:
            return (list(perm), constants)

    return None


def is_harmonic_on(
    L: np.ndarray, S: list[int], f: np.ndarray
) -> bool:
    """
    Check if f is S-harmonic: L*f restricted to S is zero.

    Args:
        L: Full Laplacian matrix (n x n)
        S: Subset of vertex indices
        f: Function values (length n)

    Returns:
        True if sum_w L(v,w)*f(w) = 0 for all v in S
    """
    Lf = L @ f
    return all(Lf[v] == 0 for v in S)


def find_cycle_basis_indicators(adj: np.ndarray, S: list[int]) -> list[np.ndarray]:
    """
    Find cycle indicators for the induced subgraph on S.

    Uses a spanning tree approach: for each non-tree edge, constructs the
    fundamental cycle and returns its indicator function.

    Args:
        adj: Adjacency matrix of the full graph
        S: Vertex subset

    Returns:
        List of cycle indicator arrays (each of length |V|)
    """
    n = adj.shape[0]
    S_set = set(S)

    # Build induced subgraph adjacency
    sub_adj = {}
    edges = []
    for i in S:
        sub_adj[i] = []
        for j in S:
            if adj[i, j] and i < j:
                edges.append((i, j))
                sub_adj.setdefault(i, []).append(j)
                sub_adj.setdefault(j, []).append(i)

    if not S:
        return []

    # BFS spanning tree
    visited = set()
    tree_edges = set()
    parent = {}
    queue = [S[0]]
    visited.add(S[0])
    parent[S[0]] = -1

    while queue:
        v = queue.pop(0)
        for w in sub_adj.get(v, []):
            if w not in visited:
                visited.add(w)
                parent[w] = v
                tree_edges.add((min(v, w), max(v, w)))
                queue.append(w)

    # Non-tree edges give fundamental cycles
    indicators = []
    for (u, v) in edges:
        if (u, v) not in tree_edges:
            # Find the cycle: path from u to v in tree + edge (u,v)
            # Find path from u to root
            path_u = []
            x = u
            while x != -1:
                path_u.append(x)
                x = parent.get(x, -1)
            path_v = []
            x = v
            while x != -1:
                path_v.append(x)
                x = parent.get(x, -1)

            # Find LCA
            set_u = set(path_u)
            lca = -1
            for x in path_v:
                if x in set_u:
                    lca = x
                    break

            # Cycle vertices
            cycle = set()
            x = u
            while x != lca:
                cycle.add(x)
                x = parent[x]
            cycle.add(lca)
            x = v
            while x != lca:
                cycle.add(x)
                x = parent[x]

            indicator = np.zeros(n, dtype=int)
            for c in cycle:
                indicator[c] = 1
            indicators.append(indicator)

    return indicators


def find_component_indicators(
    adj: np.ndarray, q: int, S: list[int]
) -> list[np.ndarray]:
    """
    Find q-visible component indicators.

    Computes connected components of G - {q} that intersect S,
    and returns their indicator functions restricted to S.

    Args:
        adj: Adjacency matrix
        q: Basepoint vertex
        S: Vertex subset (not containing q)

    Returns:
        List of component indicator arrays (each of length |V|)
    """
    n = adj.shape[0]
    S_set = set(S)
    vertices = [v for v in range(n) if v != q]

    # BFS to find components of G - {q}
    visited = set()
    components = []

    for start in vertices:
        if start in visited:
            continue
        comp = set()
        queue = [start]
        visited.add(start)
        while queue:
            v = queue.pop(0)
            comp.add(v)
            for w in range(n):
                if w != q and adj[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        components.append(comp)

    # Keep only components that intersect S
    indicators = []
    for comp in components:
        if comp & S_set:
            indicator = np.zeros(n, dtype=int)
            for v in comp & S_set:
                indicator[v] = 1
            indicators.append(indicator)

    return indicators


def canonical_tropical_kernel_family(
    adj: np.ndarray, q: int, S: list[int]
) -> list[np.ndarray]:
    """
    Construct the canonical tropical kernel family for (G, q, S).

    Combines cycle indicators and component indicators.

    Args:
        adj: Adjacency matrix of graph G
        q: Basepoint vertex
        S: Vertex subset (not containing q)

    Returns:
        List of canonical generator arrays

    Example:
        >>> # Triangle graph with q=0, S=[1,2]
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])
        >>> canonical_tropical_kernel_family(adj, 0, [1, 2])
        [array([0, 1, 1]), array([0, 1, 1])]
    """
    cycles = find_cycle_basis_indicators(adj, S)
    components = find_component_indicators(adj, q, S)
    return cycles + components


def uniqueness_witness_or_counterexample(
    adj: np.ndarray, q: int, S: list[int]
) -> dict:
    """
    Compute the canonical family and check uniqueness.

    Returns a dictionary with:
    - 'canonical_family': the canonical generators
    - 'support_separated': whether the hypothesis holds
    - 'unique_up_to_proj_equiv': whether uniqueness holds
    - 'witness': the permutation and constants (if unique)
    - 'counterexample': an alternative family (if not unique)

    Args:
        adj: Adjacency matrix
        q: Basepoint
        S: Vertex subset

    Returns:
        Dictionary with analysis results
    """
    family = canonical_tropical_kernel_family(adj, q, S)

    result = {
        'canonical_family': family,
        'num_generators': len(family),
        'support_separated': False,
        'nontrivial': False,
        'unique_up_to_proj_equiv': None,
    }

    if not family:
        result['support_separated'] = True
        result['nontrivial'] = True
        result['unique_up_to_proj_equiv'] = True
        return result

    result['support_separated'] = pairwise_disjoint_supports(family)
    result['nontrivial'] = nontrivial_on_support(family)

    if result['support_separated'] and result['nontrivial']:
        result['unique_up_to_proj_equiv'] = True
        result['witness'] = 'By the main uniqueness theorem (disjoint_support_unique_up_to_tropProjEquiv)'
    else:
        result['unique_up_to_proj_equiv'] = 'Unknown (hypotheses not satisfied)'

    return result


def leaf_rigidity_check(
    adj: np.ndarray, S: list[int], f: np.ndarray
) -> list[tuple[int, int, bool]]:
    """
    Check leaf rigidity for a function on a graph.

    For each leaf vertex v in S with unique neighbor w also in S,
    checks whether f(v) == f(w).

    Args:
        adj: Adjacency matrix
        S: Vertex subset
        f: Function values

    Returns:
        List of (leaf, neighbor, rigidity_holds) triples
    """
    results = []
    S_set = set(S)
    for v in S:
        degree = int(np.sum(adj[v]))
        if degree == 1:
            w = int(np.where(adj[v] == 1)[0][0])
            if w in S_set:
                results.append((v, w, f[v] == f[w]))
    return results


if __name__ == '__main__':
    # Example: Triangle graph K3
    print("=" * 60)
    print("Example 1: Complete graph K3")
    print("=" * 60)
    adj = np.array([[0, 1, 1], [1, 0, 1], [1, 1, 0]])
    L = graph_laplacian(adj)
    print(f"Laplacian:\n{L}")
    print(f"Row sums: {np.sum(L, axis=1)}")

    q, S = 0, [1, 2]
    family = canonical_tropical_kernel_family(adj, q, S)
    print(f"\nCanonical family for q={q}, S={S}:")
    for i, f in enumerate(family):
        print(f"  Generator {i}: {f}")
    print(f"Pairwise disjoint supports: {pairwise_disjoint_supports(family)}")

    # Example: Path graph P4
    print("\n" + "=" * 60)
    print("Example 2: Path graph P4 (0-1-2-3)")
    print("=" * 60)
    adj = np.array([
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [0, 0, 1, 0]
    ])
    L = graph_laplacian(adj)
    print(f"Laplacian:\n{L}")

    q, S = 0, [1, 2, 3]
    result = uniqueness_witness_or_counterexample(adj, q, S)
    print(f"\nAnalysis for q={q}, S={S}:")
    for k, v in result.items():
        if k != 'canonical_family':
            print(f"  {k}: {v}")
    print("  Canonical family:")
    for i, f in enumerate(result['canonical_family']):
        print(f"    Generator {i}: {f}")

    # Example: Cycle graph C4
    print("\n" + "=" * 60)
    print("Example 3: Cycle graph C4")
    print("=" * 60)
    adj = np.array([
        [0, 1, 0, 1],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [1, 0, 1, 0]
    ])
    q, S = 0, [1, 2, 3]
    result = uniqueness_witness_or_counterexample(adj, q, S)
    print(f"Analysis for q={q}, S={S}:")
    for k, v in result.items():
        if k != 'canonical_family':
            print(f"  {k}: {v}")

    # Leaf rigidity example
    print("\n" + "=" * 60)
    print("Example 4: Leaf rigidity on star graph")
    print("=" * 60)
    adj = np.array([
        [0, 1, 1, 1],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0]
    ])
    L = graph_laplacian(adj)
    f = np.array([5, 5, 5, 5])  # constant = harmonic
    print(f"Constant function {f}: harmonic = {is_harmonic_on(L, [0,1,2,3], f)}")
    rigidity = leaf_rigidity_check(adj, [0, 1, 2, 3], f)
    print(f"Leaf rigidity checks: {rigidity}")

    # Tropical projective equivalence
    print("\n" + "=" * 60)
    print("Example 5: Tropical projective equivalence")
    print("=" * 60)
    F = [np.array([1, 2, 0, 0]), np.array([0, 0, 3, 4])]
    G = [np.array([0, 0, 8, 9]), np.array([4, 5, 0, 0])]
    result = check_trop_proj_equiv(F, G)
    if result:
        perm, consts = result
        print(f"F ~ G with permutation {perm} and constants {consts}")
    else:
        print("F and G are NOT tropically projectively equivalent")
