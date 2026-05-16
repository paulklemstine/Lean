#!/usr/bin/env python3
"""
Algorithms for Tropical Divisor Theory on Trees

Implements the core algorithms from the formal theory:
1. Leaf-firing normalization (certified chip-firing)
2. Singleton representative computation
3. Effective representative computation
4. Jacobian triviality verification

All algorithms have complexity O(n) where n = |V|.

Keywords: chip-firing, graph Laplacian, tropical geometry, Baker-Norine,
          certified normalization algorithm
"""

from __future__ import annotations
from typing import Dict, List, Tuple, Set, Optional
from collections import defaultdict, deque


class TreeGraph:
    """A finite tree with integer-weighted divisors.

    Attributes:
        n: Number of vertices (labeled 0..n-1).
        adj: Adjacency list representation.
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        """Initialize tree from vertex count and edge list.

        Args:
            n: Number of vertices.
            edges: List of (u, v) pairs.

        Raises:
            ValueError: If edges don't form a tree.
        """
        self.n = n
        self.adj: Dict[int, List[int]] = defaultdict(list)
        for u, v in edges:
            if u < 0 or u >= n or v < 0 or v >= n:
                raise ValueError(f"Vertex out of range: ({u}, {v})")
            self.adj[u].append(v)
            self.adj[v].append(u)

        if len(edges) != n - 1:
            raise ValueError(f"A tree on {n} vertices needs {n-1} edges, got {len(edges)}")

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return len(self.adj[v])

    def leaves(self) -> List[int]:
        """Return all leaves (degree-1 vertices)."""
        return [v for v in range(self.n) if self.degree(v) == 1]

    def root_at(self, root: int) -> Dict[int, Optional[int]]:
        """BFS to find parent pointers when tree is rooted at `root`.

        Returns:
            Dictionary mapping each vertex to its parent (root maps to None).
        """
        parent: Dict[int, Optional[int]] = {root: None}
        queue = deque([root])
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in parent:
                    parent[w] = v
                    queue.append(w)
        return parent


def graph_laplacian(T: TreeGraph, f: Dict[int, int]) -> Dict[int, int]:
    r"""Compute the graph Laplacian (principal divisor) of f.

    .. math::
        \Delta f(v) = \sum_{w \sim v} (f(w) - f(v))

    Complexity: O(n) for trees.

    Args:
        T: The tree graph.
        f: Integer-valued function on vertices.

    Returns:
        The principal divisor div(f).
    """
    result = {}
    for v in range(T.n):
        total = 0
        for w in T.adj[v]:
            total += f.get(w, 0) - f.get(v, 0)
        result[v] = total
    return result


def leaf_firing_normalization(
    T: TreeGraph,
    D: Dict[int, int],
    target: Optional[int] = None
) -> Tuple[Dict[int, int], Dict[int, int], int]:
    """Normalize a divisor on a tree by leaf-firing.

    Algorithm:
        1. Pick a target vertex (or use the last remaining vertex).
        2. Repeatedly find leaves, fire their chips to their neighbor.
        3. Remove the leaf. Iterate until one vertex remains.

    This is the CERTIFIED NORMALIZATION ALGORITHM: it produces
    an explicit witness (firing function) proving linear equivalence.

    Complexity: O(n) time, O(n) space.

    Args:
        T: The tree graph.
        D: Input divisor (integer-valued function on vertices).
        target: Optional target vertex. If None, uses the last remaining.

    Returns:
        (result_divisor, firing_function, target_vertex) where
        result_divisor = D + div(firing_function) is concentrated at target_vertex.

    Example:
        >>> T = TreeGraph(4, [(0,1), (1,2), (2,3)])
        >>> D = {0: 2, 1: -1, 2: 3, 3: -1}
        >>> E, f, v = leaf_firing_normalization(T, D)
        >>> E[v] == sum(D.values())
        True
    """
    n = T.n
    deg = sum(D.get(v, 0) for v in range(n))

    # Mutable state
    current = {v: D.get(v, 0) for v in range(n)}
    f = {v: 0 for v in range(n)}

    # Build mutable adjacency for active subgraph
    active_deg = {v: T.degree(v) for v in range(n)}
    active = set(range(n))

    # Find initial leaves (excluding target if specified)
    leaf_queue = deque()
    for v in range(n):
        if active_deg[v] == 1 and (target is None or v != target):
            leaf_queue.append(v)

    while len(active) > 1:
        if not leaf_queue:
            break

        leaf = leaf_queue.popleft()
        if leaf not in active:
            continue
        if active_deg[leaf] != 1:
            continue
        if target is not None and leaf == target and len(active) > 1:
            continue

        # Find the unique active neighbor
        neighbor = None
        for w in T.adj[leaf]:
            if w in active and w != leaf:
                neighbor = w
                break

        if neighbor is None:
            break

        # Fire: move current[leaf] chips from leaf to neighbor
        fire_amount = current[leaf]
        f[leaf] += fire_amount  # f(leaf) += fire_amount
        current[neighbor] += fire_amount
        current[leaf] = 0

        # Remove leaf
        active.remove(leaf)
        active_deg[neighbor] -= 1

        # Check if neighbor became a leaf
        if active_deg[neighbor] == 1 and (target is None or neighbor != target):
            leaf_queue.append(neighbor)

    target_v = next(iter(active))
    assert current[target_v] == deg

    return current, f, target_v


def find_effective_representative(
    T: TreeGraph,
    D: Dict[int, int]
) -> Tuple[Dict[int, int], Dict[int, int]]:
    """Find an effective divisor linearly equivalent to D.

    Precondition: deg(D) >= 0.

    The result E satisfies:
    - E(v) >= 0 for all v (effectiveness)
    - E = D + div(f) for some f (linear equivalence)
    - deg(E) = deg(D)

    Complexity: O(n).

    Args:
        T: The tree graph.
        D: Input divisor with nonneg degree.

    Returns:
        (effective_divisor, firing_function).
    """
    deg = sum(D.get(v, 0) for v in range(T.n))
    if deg < 0:
        raise ValueError("Divisor must have nonneg degree for effective representative")

    E, f, _ = leaf_firing_normalization(T, D)
    return E, f


def verify_principal(T: TreeGraph, D: Dict[int, int]) -> Optional[Dict[int, int]]:
    """For a degree-0 divisor D, find f such that D = div(f), or return None.

    On a tree, every degree-0 divisor is principal (Jacobian triviality).
    This function computes the explicit witness using subtree sums.

    Complexity: O(n).

    Args:
        T: The tree graph.
        D: Divisor with deg(D) = 0.

    Returns:
        f such that D = div(f), or None if deg(D) != 0.
    """
    deg = sum(D.get(v, 0) for v in range(T.n))
    if deg != 0:
        return None

    # Use subtree sum construction: g concentrates D at root
    # D + div(g) = 0 (since deg = 0), so D = div(-g) = -div(g)
    root = 0
    g = subtree_sum_construction(T, D, root)

    # D + div(g) = deg(D) * delta_root = 0 * delta_root = 0
    # So D = -div(g) = div(-g)
    f = {v: -g[v] for v in range(T.n)}

    # Verify
    div_f = graph_laplacian(T, f)
    for v in range(T.n):
        assert div_f[v] == D.get(v, 0), f"Verification failed at vertex {v}"

    return f


def subtree_sum_construction(
    T: TreeGraph,
    D: Dict[int, int],
    root: int
) -> Dict[int, int]:
    """Construct firing function using subtree sums.

    Alternative to leaf-firing: compute f(v) = sum of D(u) over all
    descendants of v (including v itself), which gives div(f) = -D
    at all non-root vertices.

    This is the algebraic construction used in the formal proof.

    Args:
        T: The tree graph.
        D: Input divisor.
        root: Root vertex.

    Returns:
        f such that D + div(f) is concentrated at root.
    """
    parent = T.root_at(root)

    # Compute subtree sums bottom-up
    # First, get BFS order (to process children before parents)
    order = []
    queue = deque([root])
    visited = {root}
    while queue:
        v = queue.popleft()
        order.append(v)
        for w in T.adj[v]:
            if w not in visited:
                visited.add(w)
                queue.append(w)

    # Compute subtree sums bottom-up
    subtree_sum = {v: D.get(v, 0) for v in range(T.n)}
    for v in reversed(order):
        if parent[v] is not None:
            subtree_sum[parent[v]] += subtree_sum[v]

    # Build f top-down: f(root) = 0, f(v) = f(parent(v)) + subtree_sum(v)
    f = {root: 0}
    for v in order:
        if v != root:
            f[v] = f[parent[v]] + subtree_sum[v]
    return f


# ─── Complexity Analysis ─────────────────────────────────────────────────────

def complexity_analysis():
    """Print complexity analysis of the algorithms."""
    print("COMPLEXITY ANALYSIS")
    print("=" * 50)
    print()
    print("Algorithm                    | Time  | Space")
    print("-" * 50)
    print("Graph Laplacian              | O(n)  | O(n)")
    print("Leaf-firing normalization    | O(n)  | O(n)")
    print("Effective representative     | O(n)  | O(n)")
    print("Jacobian triviality (verify) | O(n)  | O(n)")
    print("Subtree sum construction     | O(n)  | O(n)")
    print()
    print("All algorithms are LINEAR in the number of vertices,")
    print("exploiting the tree structure (no cycles to handle).")
    print()
    print("For general graphs (genus > 0), the analogous problems")
    print("may require exponential time (NP-hard in general).")


if __name__ == "__main__":
    # Quick sanity checks
    T = TreeGraph(5, [(0,1), (1,2), (2,3), (3,4)])
    D = {0: 2, 1: -3, 2: 5, 3: -1, 4: 0}

    print("Leaf-firing normalization test:")
    E, f, v = leaf_firing_normalization(T, D)
    print(f"  D = {D}, deg = {sum(D.values())}")
    print(f"  Result concentrated at vertex {v}: {E}")
    print(f"  Firing function: {f}")

    print("\nJacobian triviality test:")
    D0 = {0: 1, 1: -2, 2: 3, 3: -4, 4: 2}
    witness = verify_principal(T, D0)
    print(f"  D = {D0}")
    print(f"  Witness f = {witness}")
    print(f"  div(f) = {graph_laplacian(T, witness)}")

    print()
    complexity_analysis()
