#!/usr/bin/env python3
"""
Baker-Norine Theory: Core Algorithms

Type-hinted implementations of chip-firing, Dhar's burning algorithm,
divisor rank computation, and the Laplacian.
"""

from typing import List, Tuple, Optional, Set, FrozenSet
import numpy as np


def laplacian_matrix(adjacency: np.ndarray) -> np.ndarray:
    """
    Compute the graph Laplacian L = D - A.

    Parameters:
        adjacency: n×n symmetric adjacency matrix (0-1 for simple graphs)

    Returns:
        n×n Laplacian matrix where L[i,i] = deg(i), L[i,j] = -A[i,j]
    """
    degree_matrix = np.diag(adjacency.sum(axis=1))
    return degree_matrix - adjacency


def chip_fire(divisor: List[int], adjacency: np.ndarray, vertex: int) -> List[int]:
    """
    Perform chip-firing at a single vertex.

    The vertex sends one chip along each edge to its neighbors.

    Parameters:
        divisor: current chip configuration D(v) for each vertex v
        adjacency: adjacency matrix of the graph
        vertex: the vertex to fire

    Returns:
        New divisor after firing

    Time: O(n) where n = number of vertices
    """
    n = len(divisor)
    result = divisor.copy()
    degree = int(adjacency[vertex].sum())
    result[vertex] -= degree
    for w in range(n):
        if adjacency[vertex, w] > 0:
            result[w] += 1
    return result


def multi_chip_fire(divisor: List[int], adjacency: np.ndarray,
                     firing_set: Set[int]) -> List[int]:
    """
    Simultaneously fire all vertices in a set S.

    Each vertex in S sends one chip to each neighbor.

    Parameters:
        divisor: current chip configuration
        adjacency: adjacency matrix
        firing_set: set of vertices to fire

    Returns:
        New divisor after simultaneous firing
    """
    result = divisor.copy()
    for v in firing_set:
        result = chip_fire(result, adjacency, v)
    return result


def dhars_burning(divisor: List[int], adjacency: np.ndarray,
                   q: int) -> Tuple[bool, Set[int]]:
    """
    Dhar's burning algorithm to test if a divisor is q-reduced.

    Starting a fire at q, vertices burn if the number of burnt neighbors
    exceeds their chip count. Returns whether the entire graph burns
    (equivalently, whether D is q-reduced).

    Parameters:
        divisor: the divisor to test
        adjacency: adjacency matrix
        q: the distinguished vertex

    Returns:
        (is_q_reduced, burnt_set): whether D is q-reduced and the set
        of vertices that burned

    Time: O(n²) worst case
    """
    n = len(divisor)
    burnt: Set[int] = {q}
    changed = True

    while changed:
        changed = False
        for v in range(n):
            if v in burnt:
                continue
            # Count burnt neighbors
            burnt_neighbors = sum(1 for w in burnt if adjacency[v, w] > 0)
            if burnt_neighbors > divisor[v]:
                burnt.add(v)
                changed = True

    return len(burnt) == n, burnt


def q_reduce(divisor: List[int], adjacency: np.ndarray,
              q: int, max_iter: int = 100000) -> Optional[List[int]]:
    """
    Find the q-reduced divisor linearly equivalent to D.

    Iteratively fires maximal subsets of V\\{q} where all vertices have
    enough chips, until reaching a q-reduced configuration.

    Parameters:
        divisor: input divisor
        adjacency: adjacency matrix
        q: distinguished vertex
        max_iter: maximum iterations

    Returns:
        The unique q-reduced representative, or None if max_iter exceeded

    The result is unique by the uniqueness theorem for q-reduced divisors.
    """
    n = len(divisor)
    current = divisor.copy()

    for _ in range(max_iter):
        is_reduced, burnt = dhars_burning(current, adjacency, q)
        if is_reduced:
            return current

        # Fire the unburnt set
        unburnt = set(range(n)) - burnt
        if not unburnt:
            return current

        for v in unburnt:
            current = chip_fire(current, adjacency, v)

    return None


def divisor_rank_brute(divisor: List[int], adjacency: np.ndarray,
                        q: int = 0) -> int:
    """
    Compute divisor rank r(D) by brute force.

    r(D) = -1 if D is not linearly equivalent to any effective divisor.
    Otherwise, r(D) is the maximum k such that for every effective E
    of degree k, D - E is linearly equivalent to an effective divisor.

    Uses q-reduced divisors for the equivalence test.

    Parameters:
        divisor: the divisor D
        adjacency: adjacency matrix
        q: distinguished vertex for q-reduction

    Returns:
        The rank r(D)
    """
    n = len(divisor)
    deg = sum(divisor)

    # First check r(D) >= 0: is D equivalent to an effective divisor?
    reduced = q_reduce(divisor, adjacency, q)
    if reduced is None or not all(d >= 0 for d in reduced if reduced.index(d) != q):
        # More careful: check if reduced form has all non-negative values except q
        pass

    # Use effective test via q-reduction
    if reduced is None:
        return -1

    # Check if D - 0 is equivalent to effective (i.e., D itself)
    if not all(d >= 0 for d in reduced):
        # q-reduced but effective? Check if the q-value makes it non-effective
        if reduced[q] < 0 and all(reduced[v] >= 0 for v in range(n) if v != q):
            return -1

    for k in range(deg + 1):
        # Check all effective divisors of degree k
        all_pass = True
        for E in _gen_effective(n, k):
            diff = [divisor[v] - E[v] for v in range(n)]
            red = q_reduce(diff, adjacency, q)
            if red is None or any(red[v] < 0 for v in range(n) if v != q):
                all_pass = False
                break
        if not all_pass:
            return max(k - 1, -1)

    return deg


def _gen_effective(n: int, k: int):
    """Generate effective divisors of degree k on n vertices (bounded)."""
    if k > 2 * n:  # Bound for practical computation
        return
    if n == 1:
        yield [k]
        return
    for val in range(k + 1):
        for rest in _gen_effective(n - 1, k - val):
            yield [val] + rest


def graph_genus(adjacency: np.ndarray) -> int:
    """Compute genus g = |E| - |V| + 1."""
    n = adjacency.shape[0]
    num_edges = int(adjacency.sum()) // 2
    return num_edges - n + 1


def canonical_divisor(adjacency: np.ndarray) -> List[int]:
    """Compute K_G where K_G(v) = deg(v) - 2."""
    return [int(adjacency[v].sum()) - 2 for v in range(adjacency.shape[0])]


def verify_riemann_roch(divisor: List[int], adjacency: np.ndarray,
                         q: int = 0) -> Tuple[int, int, int, int, bool]:
    """
    Verify the Baker-Norine Riemann-Roch identity for a specific divisor.

    Returns:
        (r_D, r_KmD, deg_D, genus, identity_holds)
        where identity_holds checks r(D) - r(K-D) == deg(D) - g + 1
    """
    g = graph_genus(adjacency)
    K = canonical_divisor(adjacency)
    deg_D = sum(divisor)

    r_D = divisor_rank_brute(divisor, adjacency, q)
    KmD = [K[v] - divisor[v] for v in range(len(divisor))]
    r_KmD = divisor_rank_brute(KmD, adjacency, q)

    identity_holds = (r_D - r_KmD) == (deg_D - g + 1)
    return r_D, r_KmD, deg_D, g, identity_holds


if __name__ == "__main__":
    # Example: C_4 cycle graph
    n = 4
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i + 1) % n] = 1
        adj[(i + 1) % n, i] = 1

    print(f"Graph: C_{n}")
    print(f"Adjacency:\n{adj}")
    print(f"Laplacian:\n{laplacian_matrix(adj)}")
    print(f"Genus: {graph_genus(adj)}")
    print(f"Canonical divisor: {canonical_divisor(adj)}")

    D = [2, 0, 0, 0]
    print(f"\nDivisor D = {D}")
    r_D, r_KmD, deg_D, g, holds = verify_riemann_roch(D, adj)
    print(f"r(D) = {r_D}, r(K-D) = {r_KmD}")
    print(f"r(D) - r(K-D) = {r_D - r_KmD}")
    print(f"deg(D) - g + 1 = {deg_D - g + 1}")
    print(f"Riemann-Roch holds: {holds}")
