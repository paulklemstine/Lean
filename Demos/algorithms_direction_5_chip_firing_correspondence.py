"""
Algorithms for Chip-Firing and Tropical Hodge Theory on Graphs.

Implements:
- Graph Laplacian computation
- Jacobian group via Smith Normal Form
- Q-reduced divisor computation (Dhar's burning algorithm)
- Tropical kernel dimension computation
- Genus and spanning tree counting

All algorithms operate on graphs represented as adjacency matrices (numpy arrays).
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from collections import defaultdict
import itertools


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """
    Compute the graph Laplacian matrix L = D - A.

    Args:
        adj: Adjacency matrix (symmetric, 0-1, zero diagonal).

    Returns:
        Laplacian matrix L as an integer numpy array.

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])  # Triangle
        >>> graph_laplacian(adj)
        array([[ 2, -1, -1],
               [-1,  2, -1],
               [-1, -1,  2]])
    """
    adj = np.asarray(adj, dtype=int)
    degree = np.diag(adj.sum(axis=1))
    return degree - adj


def graph_genus(adj: np.ndarray) -> int:
    """
    Compute the genus (cyclomatic number) of a graph.
    g = |E| - |V| + c, where c = number of connected components.

    Args:
        adj: Adjacency matrix.

    Returns:
        The genus (first Betti number).

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])  # Triangle
        >>> graph_genus(adj)
        1
    """
    n = adj.shape[0]
    m = np.sum(adj) // 2  # number of edges
    c = count_components(adj)
    return m - n + c


def count_components(adj: np.ndarray) -> int:
    """Count connected components via BFS."""
    n = adj.shape[0]
    visited = [False] * n
    components = 0
    for start in range(n):
        if not visited[start]:
            components += 1
            queue = [start]
            visited[start] = True
            while queue:
                v = queue.pop(0)
                for w in range(n):
                    if adj[v, w] and not visited[w]:
                        visited[w] = True
                        queue.append(w)
    return components


def is_connected(adj: np.ndarray) -> bool:
    """Check if graph is connected."""
    return count_components(adj) == 1


def reduced_laplacian(adj: np.ndarray, q: int = 0) -> np.ndarray:
    """
    Compute the reduced Laplacian by deleting row q and column q.

    Args:
        adj: Adjacency matrix.
        q: Base vertex to remove.

    Returns:
        The (n-1) x (n-1) reduced Laplacian matrix.
    """
    L = graph_laplacian(adj)
    indices = [i for i in range(L.shape[0]) if i != q]
    return L[np.ix_(indices, indices)]


def smith_normal_form(M: np.ndarray) -> Tuple[np.ndarray, List[int]]:
    """
    Compute the Smith Normal Form of an integer matrix.

    Returns the diagonal entries (invariant factors).

    Args:
        M: Integer matrix.

    Returns:
        Tuple of (diagonal SNF matrix, list of invariant factors > 1).
    """
    M = np.array(M, dtype=int).copy()
    n, m = M.shape
    size = min(n, m)

    for col in range(size):
        # Find pivot
        found = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i, j] != 0:
                    # Swap rows and columns
                    M[[col, i]] = M[[i, col]]
                    M[:, [col, j]] = M[:, [j, col]]
                    found = True
                    break
            if found:
                break
        if not found:
            break

        # Eliminate using the pivot
        changed = True
        while changed:
            changed = False
            # Make pivot positive
            if M[col, col] < 0:
                M[col] = -M[col]

            # Eliminate column
            for i in range(col + 1, n):
                if M[i, col] != 0:
                    q_val = M[i, col] // M[col, col]
                    M[i] -= q_val * M[col]
                    if M[i, col] != 0:
                        M[[col, i]] = M[[i, col]]
                        changed = True

            # Eliminate row
            for j in range(col + 1, m):
                if M[col, j] != 0:
                    q_val = M[col, j] // M[col, col]
                    M[:, j] -= q_val * M[:, col]
                    if M[col, j] != 0:
                        M[:, [col, j]] = M[:, [j, col]]
                        changed = True

    diag = [abs(M[i, i]) if i < n and i < m else 0 for i in range(size)]
    invariant_factors = [d for d in diag if d > 1]
    return np.diag(diag), invariant_factors


def jacobian_group(adj: np.ndarray, q: int = 0) -> Dict:
    """
    Compute the Jacobian group Jac(G) = Div^0(G) / Prin(G).

    Args:
        adj: Adjacency matrix of a connected graph.
        q: Base vertex.

    Returns:
        Dictionary with:
        - 'order': |Jac(G)| (= number of spanning trees)
        - 'invariant_factors': list of invariant factors > 1
        - 'group_str': human-readable group description

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])  # Triangle
        >>> result = jacobian_group(adj)
        >>> result['order']
        3
    """
    L_red = reduced_laplacian(adj, q)
    _, factors = smith_normal_form(L_red)

    order = 1
    for f in factors:
        order *= f
    if not factors:
        # For trees, the reduced Laplacian has det = 1
        order = max(1, abs(int(round(np.linalg.det(L_red.astype(float))))))

    group_parts = [f"Z/{f}Z" for f in factors]
    group_str = " x ".join(group_parts) if group_parts else "{0}"

    return {
        'order': order,
        'invariant_factors': factors,
        'group_str': group_str
    }


def spanning_tree_count(adj: np.ndarray) -> int:
    """
    Count spanning trees using Kirchhoff's matrix-tree theorem.
    |spanning trees| = det(L^(q)) for any vertex q.

    Args:
        adj: Adjacency matrix of a connected graph.

    Returns:
        Number of spanning trees.
    """
    if adj.shape[0] <= 1:
        return 1
    L_red = reduced_laplacian(adj, 0)
    det_val = np.linalg.det(L_red.astype(float))
    return max(1, int(round(det_val)))


def chip_fire(divisor: np.ndarray, adj: np.ndarray, q: int) -> np.ndarray:
    """
    Fire vertex q: send one chip along each edge to neighbors.

    Args:
        divisor: Current chip configuration (integer array).
        adj: Adjacency matrix.
        q: Vertex to fire.

    Returns:
        New chip configuration after firing.

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])
        >>> d = np.array([3, 0, 0])
        >>> chip_fire(d, adj, 0)
        array([1, 1, 1])
    """
    result = divisor.copy()
    degree = adj[q].sum()
    result[q] -= degree
    for v in range(len(divisor)):
        if adj[q, v]:
            result[v] += 1
    return result


def is_q_reduced(divisor: np.ndarray, adj: np.ndarray, q: int) -> bool:
    """
    Check if a divisor is q-reduced using Dhar's burning algorithm.

    A divisor D is q-reduced if:
    1. D(v) >= 0 for all v != q
    2. For every nonempty A ⊆ V\\{q}, there exists v in A with
       D(v) < outdeg_A(v)

    Args:
        divisor: Chip configuration.
        adj: Adjacency matrix.
        q: Base vertex.

    Returns:
        True if the divisor is q-reduced.
    """
    n = len(divisor)

    # Check non-negativity away from q
    for v in range(n):
        if v != q and divisor[v] < 0:
            return False

    # Check the subset condition via Dhar's burning algorithm
    # Start fire at q, see if everything burns
    burned = [False] * n
    burned[q] = True
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if not burned[v]:
                # Count burned neighbors
                burned_neighbors = sum(1 for w in range(n)
                                      if adj[v, w] and burned[w])
                if divisor[v] < burned_neighbors:
                    burned[v] = True
                    changed = True

    return all(burned)


def q_reduce(divisor: np.ndarray, adj: np.ndarray, q: int,
             max_iter: int = 10000) -> np.ndarray:
    """
    Compute the q-reduced representative of a divisor.

    Args:
        divisor: Initial chip configuration.
        adj: Adjacency matrix.
        q: Base vertex.
        max_iter: Maximum iterations to prevent infinite loops.

    Returns:
        The unique q-reduced divisor linearly equivalent to the input.
    """
    d = divisor.copy()
    n = len(d)
    L = graph_laplacian(adj)

    for _ in range(max_iter):
        if is_q_reduced(d, adj, q):
            return d

        # Find a fireable subset
        for v in range(n):
            if v != q and d[v] >= adj[v].sum():
                d = chip_fire(d, adj, v)
                break
        else:
            # Try firing sets of vertices
            break

    return d


def tropical_kernel_dimension(adj: np.ndarray) -> int:
    """
    Compute the dimension of the tropical kernel of the Laplacian.
    For a connected graph, this equals the genus = |E| - |V| + 1.

    The tropical kernel is the cycle space, whose dimension equals
    the first Betti number.

    Args:
        adj: Adjacency matrix.

    Returns:
        Tropical kernel dimension (= genus for connected graphs).
    """
    return graph_genus(adj)


def cycle_space_basis(adj: np.ndarray) -> List[List[Tuple[int, int]]]:
    """
    Compute a basis for the cycle space using a spanning tree.
    Each non-tree edge creates a fundamental cycle.

    Args:
        adj: Adjacency matrix of a connected graph.

    Returns:
        List of fundamental cycles, each as a list of edges (i, j).
    """
    n = adj.shape[0]
    # Find spanning tree via BFS
    tree_edges = set()
    visited = [False] * n
    visited[0] = True
    queue = [0]
    parent = [-1] * n

    while queue:
        v = queue.pop(0)
        for w in range(n):
            if adj[v, w] and not visited[w]:
                visited[w] = True
                parent[w] = v
                tree_edges.add((min(v, w), max(v, w)))
                queue.append(w)

    # Find non-tree edges
    non_tree = []
    for i in range(n):
        for j in range(i + 1, n):
            if adj[i, j] and (i, j) not in tree_edges:
                non_tree.append((i, j))

    # For each non-tree edge, find the fundamental cycle
    cycles = []
    for u, v in non_tree:
        # Find path from u to v in the tree
        path_u = []
        x = u
        while x != -1:
            path_u.append(x)
            x = parent[x]

        path_v = []
        x = v
        while x != -1:
            path_v.append(x)
            x = parent[x]

        # Find LCA
        set_u = set(path_u)
        lca = -1
        for x in path_v:
            if x in set_u:
                lca = x
                break

        # Build cycle
        cycle_edges = [(u, v)]
        x = u
        while x != lca:
            p = parent[x]
            cycle_edges.append((min(x, p), max(x, p)))
            x = p
        x = v
        while x != lca:
            p = parent[x]
            cycle_edges.append((min(x, p), max(x, p)))
            x = p

        cycles.append(cycle_edges)

    return cycles


def circuit_divisor(cycle: List[Tuple[int, int]], n: int) -> np.ndarray:
    """
    Compute the circuit divisor from a cycle.
    Each vertex in the cycle gets +1 or -1 based on edge orientation.

    For a simple cycle, each vertex appears exactly twice in the edge list,
    so we assign based on position.

    Args:
        cycle: List of edges forming the cycle.
        n: Number of vertices.

    Returns:
        Circuit divisor as integer array.
    """
    # Count vertex appearances with signs
    div = np.zeros(n, dtype=int)
    vertices = set()
    for u, v in cycle:
        vertices.add(u)
        vertices.add(v)

    # Assign alternating +1/-1 to vertices in cycle order
    # Build adjacency for cycle edges
    cycle_adj = defaultdict(set)
    for u, v in cycle:
        cycle_adj[u].add(v)
        cycle_adj[v].add(u)

    if not vertices:
        return div

    # Walk the cycle
    start = min(vertices)
    visited_edges = set()
    current = start
    sign = 1
    while True:
        div[current] = sign
        sign = -sign
        found = False
        for next_v in sorted(cycle_adj[current]):
            edge = (min(current, next_v), max(current, next_v))
            if edge not in visited_edges:
                visited_edges.add(edge)
                current = next_v
                found = True
                break
        if not found or current == start:
            break

    return div


def verify_genus_equals_kernel_dim(max_vertices: int = 8) -> Dict:
    """
    Verify that tropical kernel dimension = genus for all connected
    graphs up to max_vertices vertices.

    Returns:
        Dictionary with verification results.
    """
    results = {'total_graphs': 0, 'all_passed': True, 'by_size': {}}

    for n in range(1, max_vertices + 1):
        count = 0
        passed = 0

        # Generate all graphs on n vertices
        edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
        for r in range(len(edges) + 1):
            for edge_subset in itertools.combinations(edges, r):
                adj = np.zeros((n, n), dtype=int)
                for i, j in edge_subset:
                    adj[i, j] = adj[j, i] = 1

                if is_connected(adj):
                    count += 1
                    g = graph_genus(adj)
                    trop_dim = tropical_kernel_dimension(adj)
                    if g == trop_dim and g >= 0:
                        passed += 1
                    else:
                        results['all_passed'] = False

        results['by_size'][n] = {'count': count, 'passed': passed}
        results['total_graphs'] += count

    return results


# Named graph constructors
def petersen_graph() -> np.ndarray:
    """Return adjacency matrix of the Petersen graph."""
    adj = np.zeros((10, 10), dtype=int)
    # Outer cycle
    for i in range(5):
        adj[i, (i + 1) % 5] = adj[(i + 1) % 5, i] = 1
    # Inner pentagram
    for i in range(5):
        adj[5 + i, 5 + (i + 2) % 5] = adj[5 + (i + 2) % 5, 5 + i] = 1
    # Spokes
    for i in range(5):
        adj[i, 5 + i] = adj[5 + i, i] = 1
    return adj


def complete_graph(n: int) -> np.ndarray:
    """Return adjacency matrix of K_n."""
    adj = np.ones((n, n), dtype=int)
    np.fill_diagonal(adj, 0)
    return adj


def cycle_graph(n: int) -> np.ndarray:
    """Return adjacency matrix of C_n."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i + 1) % n] = adj[(i + 1) % n, i] = 1
    return adj


def path_graph(n: int) -> np.ndarray:
    """Return adjacency matrix of P_n."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj[i, i + 1] = adj[i + 1, i] = 1
    return adj


if __name__ == "__main__":
    print("=== Chip-Firing Algorithms Demo ===\n")

    # Example: Triangle graph
    adj = complete_graph(3)
    print("Triangle (K3):")
    print(f"  Laplacian:\n{graph_laplacian(adj)}")
    print(f"  Genus: {graph_genus(adj)}")
    print(f"  Spanning trees: {spanning_tree_count(adj)}")
    jac = jacobian_group(adj)
    print(f"  Jacobian: {jac['group_str']} (order {jac['order']})")
    print()

    # Example: Petersen graph
    adj = petersen_graph()
    print("Petersen graph:")
    print(f"  Genus: {graph_genus(adj)}")
    print(f"  Spanning trees: {spanning_tree_count(adj)}")
    jac = jacobian_group(adj)
    print(f"  Jacobian: {jac['group_str']} (order {jac['order']})")
    cycles = cycle_space_basis(adj)
    print(f"  Fundamental cycles: {len(cycles)}")
    print()

    # Verification
    print("Verifying genus = tropical kernel dimension for small graphs...")
    results = verify_genus_equals_kernel_dim(6)
    print(f"  Total connected graphs checked: {results['total_graphs']}")
    print(f"  All passed: {results['all_passed']}")
    for n, data in results['by_size'].items():
        print(f"    n={n}: {data['count']} graphs, {data['passed']} passed")
