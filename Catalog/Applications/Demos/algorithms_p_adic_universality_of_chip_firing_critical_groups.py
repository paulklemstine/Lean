"""
Algorithms for chip-firing critical groups, graph lifts, and Cohen-Lenstra distributions.

This module implements the core algorithms described in the research paper:
- Graph Laplacian and reduced Laplacian computation
- Critical group computation via Smith Normal Form
- Graph lift construction from voltage assignments
- Cohen-Lenstra measure computation
- p-primary decomposition of finite abelian groups
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import permutations
from collections import Counter
import random
from math import gcd, factorial
from functools import reduce


def adjacency_matrix(edges: List[Tuple[int, int]], n_vertices: int) -> np.ndarray:
    """Compute the adjacency matrix of a simple graph.

    Args:
        edges: List of (u, v) pairs representing undirected edges.
        n_vertices: Number of vertices.

    Returns:
        n_vertices × n_vertices integer adjacency matrix.

    Example:
        >>> adjacency_matrix([(0,1), (1,2), (2,0)], 3)
        array([[0, 1, 1],
               [1, 0, 1],
               [1, 1, 0]])
    """
    A = np.zeros((n_vertices, n_vertices), dtype=int)
    for u, v in edges:
        A[u, v] = 1
        A[v, u] = 1
    return A


def laplacian_matrix(edges: List[Tuple[int, int]], n_vertices: int) -> np.ndarray:
    """Compute the Laplacian matrix L = D - A.

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.

    Returns:
        n_vertices × n_vertices integer Laplacian matrix.

    Example:
        >>> L = laplacian_matrix([(0,1), (1,2), (2,0)], 3)
        >>> L
        array([[ 2, -1, -1],
               [-1,  2, -1],
               [-1, -1,  2]])
        >>> np.sum(L, axis=1)  # Row sums are zero
        array([0, 0, 0])
    """
    A = adjacency_matrix(edges, n_vertices)
    D = np.diag(np.sum(A, axis=1))
    return D - A


def reduced_laplacian(edges: List[Tuple[int, int]], n_vertices: int,
                      base_vertex: int = 0) -> np.ndarray:
    """Compute the reduced Laplacian by deleting row/column of base vertex.

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.
        base_vertex: Vertex to remove (default 0).

    Returns:
        (n_vertices-1) × (n_vertices-1) integer matrix.

    Example:
        >>> reduced_laplacian([(0,1), (1,2), (2,0)], 3)
        array([[ 2, -1],
               [-1,  2]])
    """
    L = laplacian_matrix(edges, n_vertices)
    indices = [i for i in range(n_vertices) if i != base_vertex]
    return L[np.ix_(indices, indices)]


def smith_normal_form(M: np.ndarray) -> List[int]:
    """Compute the diagonal entries of the Smith Normal Form of an integer matrix.

    Uses elementary row/column operations to reduce M to diagonal form
    diag(d_1, d_2, ..., d_k) where d_i | d_{i+1}.

    Args:
        M: Integer matrix.

    Returns:
        List of diagonal entries (invariant factors), sorted with divisibility.

    Example:
        >>> smith_normal_form(np.array([[2, -1], [-1, 2]]))
        [1, 3]
    """
    M = M.copy().astype(int)
    rows, cols = M.shape
    n = min(rows, cols)
    diag = []

    for k in range(n):
        # Find nonzero pivot
        submatrix = M[k:, k:]
        nonzero = np.argwhere(submatrix != 0)
        if len(nonzero) == 0:
            diag.extend([0] * (n - k))
            break

        # Move smallest absolute value to pivot
        for _ in range(100):  # Iterate until stable
            # Find min absolute nonzero in submatrix
            sub = M[k:, k:]
            nonzero_vals = sub[sub != 0]
            if len(nonzero_vals) == 0:
                break
            min_abs = np.min(np.abs(nonzero_vals))
            idx = np.argwhere(np.abs(sub) == min_abs)[0]
            pi, pj = idx[0] + k, idx[1] + k

            # Swap to pivot position
            if pi != k:
                M[[k, pi]] = M[[pi, k]]
            if pj != k:
                M[:, [k, pj]] = M[:, [pj, k]]

            if M[k, k] < 0:
                M[k] = -M[k]

            # Eliminate column k
            changed = False
            for i in range(k + 1, rows):
                if M[i, k] != 0:
                    q = M[i, k] // M[k, k]
                    M[i] -= q * M[k]
                    if M[i, k] != 0:
                        changed = True

            # Eliminate row k
            for j in range(k + 1, cols):
                if M[k, j] != 0:
                    q = M[k, j] // M[k, k]
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        changed = True

            if not changed:
                # Check if pivot divides all remaining entries
                sub = M[k+1:, k+1:]
                if M[k, k] != 0 and np.all(sub % M[k, k] == 0):
                    break
                elif M[k, k] != 0:
                    # Add a row with non-divisible entry to pivot row
                    for i in range(k + 1, rows):
                        for j in range(k + 1, cols):
                            if M[i, j] % M[k, k] != 0:
                                M[k] += M[i]
                                break
                        else:
                            continue
                        break
                else:
                    break

        diag.append(abs(M[k, k]) if M[k, k] != 0 else 0)

    # Ensure divisibility chain
    for i in range(len(diag) - 1):
        if diag[i] != 0 and diag[i + 1] != 0:
            g = gcd(diag[i], diag[i + 1])
            l = diag[i] * diag[i + 1] // g
            diag[i] = g
            diag[i + 1] = l

    return diag


def critical_group(edges: List[Tuple[int, int]], n_vertices: int,
                   base_vertex: int = 0) -> List[int]:
    """Compute the critical group as a product of cyclic groups.

    Returns the invariant factors [d_1, d_2, ..., d_k] where d_i | d_{i+1}
    and d_i > 1, representing Jac(G) ≅ ℤ/d_1 × ℤ/d_2 × ... × ℤ/d_k.

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.
        base_vertex: Vertex to remove.

    Returns:
        List of invariant factors > 1.

    Example:
        >>> critical_group([(0,1),(1,2),(2,3),(3,0),(0,2)], 4)
        [8]
    """
    L_red = reduced_laplacian(edges, n_vertices, base_vertex)
    snf = smith_normal_form(L_red)
    return [d for d in snf if d > 1]


def p_primary_part(invariant_factors: List[int], p: int) -> List[int]:
    """Extract the p-primary part of a finite abelian group.

    Given invariant factors [d_1, ..., d_k], returns the p-parts
    [p^{v_p(d_1)}, ..., p^{v_p(d_k)}] where v_p(d) is the p-adic valuation.

    Args:
        invariant_factors: List of invariant factors.
        p: Prime number.

    Returns:
        List of p-power invariant factors > 1.

    Example:
        >>> p_primary_part([6, 12], 2)
        [2, 4]
        >>> p_primary_part([6, 12], 3)
        [3, 3]
    """
    result = []
    for d in invariant_factors:
        pk = 1
        while d % p == 0:
            pk *= p
            d //= p
        if pk > 1:
            result.append(pk)
    return sorted(result)


def construct_lift(edges: List[Tuple[int, int]], n_vertices: int,
                   n_sheets: int, voltage: Dict[Tuple[int, int], List[int]]
                   ) -> Tuple[List[Tuple[int, int]], int]:
    """Construct an n-sheeted graph lift from a voltage assignment.

    The lifted graph has vertices V × {0, ..., n-1} encoded as
    vertex (v, i) → v * n_sheets + i.

    Args:
        edges: List of (u, v) pairs (undirected).
        n_vertices: Number of base vertices.
        n_sheets: Number of sheets.
        voltage: Maps oriented edge (u, v) to a permutation (list of length n_sheets).

    Returns:
        (lift_edges, lift_n_vertices): edges and vertex count of the lift.

    Example:
        >>> # Triangle with identity voltages (trivial 2-sheeted cover)
        >>> edges = [(0,1), (1,2), (2,0)]
        >>> voltage = {(0,1): [0,1], (1,0): [0,1],
        ...           (1,2): [0,1], (2,1): [0,1],
        ...           (2,0): [0,1], (0,2): [0,1]}
        >>> lift_edges, lift_n = construct_lift(edges, 3, 2, voltage)
        >>> lift_n
        6
    """
    lift_n_vertices = n_vertices * n_sheets
    lift_edges = set()

    for u, v in edges:
        perm = voltage[(u, v)]
        for i in range(n_sheets):
            j = perm[i]
            u_lift = u * n_sheets + i
            v_lift = v * n_sheets + j
            edge = (min(u_lift, v_lift), max(u_lift, v_lift))
            lift_edges.add(edge)

    return list(lift_edges), lift_n_vertices


def random_voltage_assignment(edges: List[Tuple[int, int]], n_sheets: int
                              ) -> Dict[Tuple[int, int], List[int]]:
    """Generate a random voltage assignment for a graph lift.

    For each undirected edge {u,v}, generates a random permutation σ ∈ S_n
    and assigns voltage(u→v) = σ, voltage(v→u) = σ⁻¹.

    Args:
        edges: List of (u, v) pairs (undirected).
        n_sheets: Number of sheets.

    Returns:
        Voltage assignment dictionary.
    """
    voltage: Dict[Tuple[int, int], List[int]] = {}
    for u, v in edges:
        perm = list(range(n_sheets))
        random.shuffle(perm)
        voltage[(u, v)] = perm
        # Inverse permutation
        inv_perm = [0] * n_sheets
        for i, j in enumerate(perm):
            inv_perm[j] = i
        voltage[(v, u)] = inv_perm
    return voltage


def is_connected(edges: List[Tuple[int, int]], n_vertices: int) -> bool:
    """Check if a graph is connected using BFS.

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.

    Returns:
        True if the graph is connected.
    """
    if n_vertices == 0:
        return True
    adj: Dict[int, List[int]] = {i: [] for i in range(n_vertices)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    visited = set()
    queue = [0]
    visited.add(0)
    while queue:
        node = queue.pop(0)
        for neighbor in adj[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    return len(visited) == n_vertices


def random_connected_lift(edges: List[Tuple[int, int]], n_vertices: int,
                          n_sheets: int, max_attempts: int = 1000
                          ) -> Optional[Tuple[List[Tuple[int, int]], int]]:
    """Generate a random connected n-sheeted lift.

    Repeatedly samples random voltage assignments until a connected lift is found.

    Args:
        edges: Base graph edges.
        n_vertices: Number of base vertices.
        n_sheets: Number of sheets.
        max_attempts: Maximum sampling attempts.

    Returns:
        (lift_edges, lift_n_vertices) or None if no connected lift found.
    """
    for _ in range(max_attempts):
        voltage = random_voltage_assignment(edges, n_sheets)
        lift_edges, lift_n = construct_lift(edges, n_vertices, n_sheets, voltage)
        if is_connected(lift_edges, lift_n):
            return lift_edges, lift_n
    return None


def betti_number(edges: List[Tuple[int, int]], n_vertices: int) -> int:
    """Compute the first Betti number b₁ = |E| - |V| + 1.

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.

    Returns:
        First Betti number (assuming connected graph).

    Example:
        >>> betti_number([(0,1),(1,2),(2,3),(3,0),(0,2)], 4)
        2
    """
    return len(edges) - n_vertices + 1


def spanning_tree_count(edges: List[Tuple[int, int]], n_vertices: int) -> int:
    """Compute the number of spanning trees via det(reduced Laplacian).

    Args:
        edges: List of (u, v) pairs.
        n_vertices: Number of vertices.

    Returns:
        Number of spanning trees (Kirchhoff's theorem).

    Example:
        >>> spanning_tree_count([(0,1),(1,2),(2,0)], 3)
        3
        >>> spanning_tree_count([(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], 4)
        16
    """
    L_red = reduced_laplacian(edges, n_vertices)
    return abs(int(round(np.linalg.det(L_red))))


def cohen_lenstra_weight(p_group: List[int], p: int, b: int) -> float:
    """Compute the Cohen-Lenstra weight of a finite abelian p-group.

    Weight = 1 / (|Aut(A)| · |A|^b)

    Args:
        p_group: List of p-power invariant factors (e.g., [2, 4] for ℤ/2 × ℤ/4).
        p: Prime.
        b: Betti number parameter.

    Returns:
        Unnormalized Cohen-Lenstra weight.

    Example:
        >>> cohen_lenstra_weight([], 2, 3)  # Trivial group
        1.0
        >>> cohen_lenstra_weight([2], 2, 3)  # ℤ/2
        0.5
    """
    if not p_group:
        return 1.0

    # Compute |A|
    size = 1
    for d in p_group:
        size *= d

    # Compute |Aut(A)|
    # For A = ⊕ ℤ/p^{a_i}, |Aut(A)| can be computed from the partition type
    aut_size = _aut_size_p_group(p_group, p)

    return 1.0 / (aut_size * (size ** b))


def _aut_size_p_group(invariants: List[int], p: int) -> int:
    """Compute |Aut(A)| for a finite abelian p-group A.

    For A = ℤ/p^{a_1} ⊕ ... ⊕ ℤ/p^{a_r} with a_1 ≤ a_2 ≤ ... ≤ a_r,
    |Aut(A)| = ∏ᵢ (p^{rᵢ} - p^{i-1}) · ∏ p^{(r-i)·(aᵢ-1)}
    where the formula involves the multiplicities of each exponent.

    Args:
        invariants: Sorted list of p-powers (e.g., [p, p, p^2]).
        p: Prime.

    Returns:
        |Aut(A)| as an integer.
    """
    if not invariants:
        return 1

    # Convert to exponents
    exponents = []
    for d in invariants:
        e = 0
        x = d
        while x > 1:
            x //= p
            e += 1
        exponents.append(e)
    exponents.sort()

    r = len(exponents)
    # Count multiplicities
    from collections import Counter
    mult = Counter(exponents)
    distinct = sorted(mult.keys())

    result = 1

    # For each distinct exponent value, compute the GL contribution
    for e in distinct:
        m = mult[e]
        for i in range(m):
            result *= (p ** m - p ** i)

    # Cross terms
    for i in range(r):
        for j in range(i + 1, r):
            if exponents[j] > exponents[i]:
                result *= p ** exponents[i]
            # else handled by GL part

    return result


def enumerate_p_groups(p: int, max_order: int) -> List[List[int]]:
    """Enumerate finite abelian p-groups up to a given order.

    Args:
        p: Prime.
        max_order: Maximum group order.

    Returns:
        List of p-groups as lists of invariant factors.

    Example:
        >>> enumerate_p_groups(2, 16)
        [[], [2], [4], [2, 2], [8], [2, 4], [2, 2, 2], [16], [2, 8], [4, 4], [2, 2, 4], [2, 2, 2, 2]]
    """
    def _partitions(n: int, max_part: int) -> List[List[int]]:
        if n == 0:
            return [[]]
        result = []
        for part in range(1, min(n, max_part) + 1):
            for rest in _partitions(n - part, part):
                result.append([part] + rest)
        return result

    groups = [[]]  # Trivial group
    max_exp = 0
    pe = 1
    while pe <= max_order:
        max_exp += 1
        pe *= p

    for total_exp in range(1, max_exp + 1):
        if p ** total_exp > max_order:
            break
        for partition in _partitions(total_exp, total_exp):
            groups.append([p ** e for e in sorted(partition)])

    return groups


def cohen_lenstra_distribution(p: int, b: int, max_order: int = 64
                               ) -> Dict[str, float]:
    """Compute the (approximate) Cohen-Lenstra distribution.

    Args:
        p: Prime.
        b: Betti number parameter.
        max_order: Maximum group order to consider.

    Returns:
        Dictionary mapping group description to probability.

    Example:
        >>> dist = cohen_lenstra_distribution(2, 3, 32)
        >>> abs(dist['trivial'] - 0.4196) < 0.01
        True
    """
    groups = enumerate_p_groups(p, max_order)
    weights = {}
    total = 0.0

    for group in groups:
        key = str(group) if group else 'trivial'
        w = cohen_lenstra_weight(group, p, b)
        weights[key] = w
        total += w

    return {k: v / total for k, v in weights.items()}


# ============================================================
# Standard graph constructors
# ============================================================

def complete_graph(n: int) -> Tuple[List[Tuple[int, int]], int]:
    """K_n: complete graph on n vertices."""
    edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    return edges, n


def complete_bipartite_graph(m: int, n: int) -> Tuple[List[Tuple[int, int]], int]:
    """K_{m,n}: complete bipartite graph."""
    edges = [(i, m + j) for i in range(m) for j in range(n)]
    return edges, m + n


def cycle_graph(n: int) -> Tuple[List[Tuple[int, int]], int]:
    """C_n: cycle graph on n vertices."""
    edges = [(i, (i + 1) % n) for i in range(n)]
    return edges, n


def triangular_prism() -> Tuple[List[Tuple[int, int]], int]:
    """The triangular prism graph (3-prism, K_3 □ K_2)."""
    edges = [
        (0, 1), (1, 2), (2, 0),  # Top triangle
        (3, 4), (4, 5), (5, 3),  # Bottom triangle
        (0, 3), (1, 4), (2, 5),  # Connecting edges
    ]
    return edges, 6


def petersen_graph() -> Tuple[List[Tuple[int, int]], int]:
    """The Petersen graph."""
    outer = [(i, (i + 1) % 5) for i in range(5)]
    inner = [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
    spokes = [(i, 5 + i) for i in range(5)]
    return outer + inner + spokes, 10


if __name__ == '__main__':
    print("=== Algorithm Tests ===\n")

    # Test 1: Critical group of K_4
    edges_k4, n_k4 = complete_graph(4)
    cg = critical_group(edges_k4, n_k4)
    print(f"K_4: edges={len(edges_k4)}, vertices={n_k4}, b1={betti_number(edges_k4, n_k4)}")
    print(f"  Critical group: {cg}")
    print(f"  Spanning trees: {spanning_tree_count(edges_k4, n_k4)}")
    print(f"  |Jac|: {reduce(lambda a,b: a*b, cg, 1)}")

    # Test 2: Betti number of a lift
    edges_k4, n_k4 = complete_graph(4)
    n_sheets = 3
    lift_result = random_connected_lift(edges_k4, n_k4, n_sheets)
    if lift_result:
        lift_edges, lift_n = lift_result
        b1_base = betti_number(edges_k4, n_k4)
        b1_lift = betti_number(lift_edges, lift_n)
        print(f"\n3-sheeted lift of K_4:")
        print(f"  Base: |V|={n_k4}, |E|={len(edges_k4)}, b1={b1_base}")
        print(f"  Lift: |V|={lift_n}, |E|={len(lift_edges)}, b1={b1_lift}")
        print(f"  Formula check: b1_lift + (n-1) = {b1_lift + n_sheets - 1}, "
              f"n*b1_base = {n_sheets * b1_base}")

    # Test 3: Cohen-Lenstra distribution
    print(f"\nCohen-Lenstra distribution (p=2, b=3):")
    dist = cohen_lenstra_distribution(2, 3, 64)
    for k, v in sorted(dist.items(), key=lambda x: -x[1])[:5]:
        print(f"  {k}: {v:.4f}")
