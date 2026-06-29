#!/usr/bin/env python3
"""
Tropical Graph Hodge Theory: Algorithms

Implements the key algorithms from the research paper:
1. Computing the predicted tropical kernel dimension
2. Identifying cycle generators and component generators
3. Graph-theoretic decomposition algorithms
"""

from typing import List, Set, Tuple, Dict, Optional
from collections import defaultdict
import itertools


class SimpleGraph:
    """A simple undirected graph on vertices {0, 1, ..., n-1}.

    Example:
        >>> G = SimpleGraph(4, [(0,1), (1,2), (2,3)])
        >>> G.neighbors(1)
        {0, 2}
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.edges: Set[Tuple[int, int]] = set()
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.add((min(u, v), max(u, v)))

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def connected_components(self, vertex_set: Optional[Set[int]] = None) -> List[Set[int]]:
        """Connected components of the induced subgraph on vertex_set.

        Args:
            vertex_set: If None, uses all vertices.

        Returns:
            List of sets, each a connected component.

        Example:
            >>> G = SimpleGraph(4, [(0,1), (2,3)])
            >>> G.connected_components()
            [{0, 1}, {2, 3}]
        """
        if vertex_set is None:
            vertex_set = set(range(self.n))
        visited: Set[int] = set()
        components = []
        for v in sorted(vertex_set):
            if v not in visited:
                comp: Set[int] = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in visited or u not in vertex_set:
                        continue
                    visited.add(u)
                    comp.add(u)
                    for w in self.adj[u]:
                        if w in vertex_set and w not in visited:
                            stack.append(w)
                components.append(comp)
        return components

    def edge_count_induced(self, S: Set[int]) -> int:
        """Number of edges in the induced subgraph on S."""
        return sum(1 for u, v in self.edges if u in S and v in S)

    def is_connected(self, S: Optional[Set[int]] = None) -> bool:
        """Check if the induced subgraph on S is connected."""
        if S is None:
            S = set(range(self.n))
        return len(self.connected_components(S)) <= 1


def compute_cycle_rank(G: SimpleGraph, S: Set[int]) -> int:
    """Compute the first Betti number (cycle rank) of G[S].

    β₁(G[S]) = |E(G[S])| - |S| + c(G[S])

    where c is the number of connected components.

    Args:
        G: The ambient graph.
        S: Vertex subset.

    Returns:
        The cycle rank β₁(G[S]).

    Time complexity: O(|S| + |E(G[S])|)

    Example:
        >>> G = SimpleGraph(3, [(0,1), (1,2), (0,2)])  # triangle
        >>> compute_cycle_rank(G, {0, 1, 2})
        1
    """
    if not S:
        return 0
    e = G.edge_count_induced(S)
    c = len(G.connected_components(S))
    return e - len(S) + c


def compute_q_visible_components(G: SimpleGraph, q: int,
                                  S: Set[int]) -> List[Set[int]]:
    """Find all q-visible connected components of G[S].

    A component K is q-visible if some vertex in K is adjacent to q in G.

    Args:
        G: The ambient graph.
        q: Basepoint vertex.
        S: Vertex subset (should not contain q).

    Returns:
        List of q-visible components (each as a set of vertices).

    Time complexity: O(|S| + |E(G[S])|)

    Example:
        >>> G = SimpleGraph(4, [(0,1), (1,2), (2,3)])
        >>> compute_q_visible_components(G, 0, {1, 2, 3})
        [{1, 2, 3}]
    """
    if not S:
        return []
    components = G.connected_components(S)
    return [comp for comp in components
            if any(q in G.adj[v] for v in comp)]


def compute_q_visible_count(G: SimpleGraph, q: int, S: Set[int]) -> int:
    """Count q-visible connected components of G[S].

    Time complexity: O(|S| + |E(G[S])|)
    """
    return len(compute_q_visible_components(G, q, S))


def predicted_tropical_kernel_dim(G: SimpleGraph, q: int,
                                   S: Set[int]) -> int:
    """Compute the predicted tropical kernel dimension.

    dim_trop(ker_trop(L_S)) = β₁(G[S]) + κ(G,q,S)

    Args:
        G: A connected graph.
        q: Basepoint vertex.
        S: Vertex subset, should satisfy q ∉ S.

    Returns:
        The predicted dimension β₁ + κ.

    Time complexity: O(|S| + |E(G[S])|)

    Example:
        >>> G = SimpleGraph(4, [(0,1), (1,2), (2,3), (3,0)])  # C4
        >>> predicted_tropical_kernel_dim(G, 0, {1, 2, 3})
        1
    """
    return compute_cycle_rank(G, S) + compute_q_visible_count(G, q, S)


def find_cycle_basis(G: SimpleGraph, S: Set[int]) -> List[List[int]]:
    """Find a cycle basis for G[S] using DFS.

    Returns a list of cycles, each represented as a list of vertices
    forming a simple cycle in G[S].

    Time complexity: O(|S| + |E(G[S])|)

    Example:
        >>> G = SimpleGraph(4, [(0,1), (1,2), (2,3), (3,0), (0,2)])
        >>> cycles = find_cycle_basis(G, {0, 1, 2, 3})
        >>> len(cycles)  # β₁ = 5 - 4 + 1 = 2
        2
    """
    if not S:
        return []

    cycles = []
    visited = set()
    parent: Dict[int, int] = {}
    depth: Dict[int, int] = {}

    def dfs(u: int, d: int, par: int):
        visited.add(u)
        depth[u] = d
        parent[u] = par
        for w in sorted(G.adj[u]):
            if w not in S:
                continue
            if w not in visited:
                dfs(w, d + 1, u)
            elif w != par and depth.get(w, d + 1) < d:
                # Found a back edge u -> w, extract cycle
                cycle = [u]
                v = u
                while v != w:
                    v = parent[v]
                    cycle.append(v)
                cycles.append(cycle)

    for start in sorted(S):
        if start not in visited:
            dfs(start, 0, -1)

    return cycles


def generate_cycle_vector(cycle: List[int], S_list: List[int]) -> List[int]:
    """Generate a tropical cycle indicator vector.

    Assigns 0 to vertices on the cycle, 1 to others.

    Args:
        cycle: List of vertices forming a cycle.
        S_list: Sorted list of all vertices in S.

    Returns:
        Vector v where v[i] = 0 if S_list[i] ∈ cycle, else 1.
    """
    cycle_set = set(cycle)
    return [0 if v in cycle_set else 1 for v in S_list]


def generate_component_vector(component: Set[int],
                               S_list: List[int]) -> List[int]:
    """Generate a tropical component indicator vector.

    Assigns 0 to vertices in the component, 1 to others.

    Args:
        component: Set of vertices in the q-visible component.
        S_list: Sorted list of all vertices in S.

    Returns:
        Vector v where v[i] = 0 if S_list[i] ∈ component, else 1.
    """
    return [0 if v in component else 1 for v in S_list]


def decompose_tropical_kernel(G: SimpleGraph, q: int,
                                S: Set[int]) -> Dict:
    """Full structural decomposition of the tropical kernel.

    Returns a dictionary with:
    - 'cycle_rank': β₁(G[S])
    - 'q_visible_count': κ(G,q,S)
    - 'predicted_dim': β₁ + κ
    - 'cycles': list of cycle basis elements
    - 'q_visible_components': list of q-visible components
    - 'cycle_generators': cycle indicator vectors
    - 'component_generators': component indicator vectors
    - 'all_generators': combined list of generators

    Time complexity: O(|S| + |E(G[S])|)

    Example:
        >>> G = SimpleGraph(4, [(0,1), (1,2), (2,3), (3,0)])
        >>> result = decompose_tropical_kernel(G, 0, {1, 2, 3})
        >>> result['predicted_dim']
        1
    """
    S_list = sorted(S)
    beta1 = compute_cycle_rank(G, S)
    kappa = compute_q_visible_count(G, q, S)

    cycles = find_cycle_basis(G, S)
    q_vis_comps = compute_q_visible_components(G, q, S)

    cycle_gens = [generate_cycle_vector(c, S_list) for c in cycles]
    comp_gens = [generate_component_vector(c, S_list) for c in q_vis_comps]

    return {
        'cycle_rank': beta1,
        'q_visible_count': kappa,
        'predicted_dim': beta1 + kappa,
        'cycles': cycles,
        'q_visible_components': q_vis_comps,
        'cycle_generators': cycle_gens,
        'component_generators': comp_gens,
        'all_generators': cycle_gens + comp_gens,
        'S_list': S_list,
    }


def print_decomposition(result: Dict):
    """Pretty-print a tropical kernel decomposition."""
    print(f"  Cycle rank β₁ = {result['cycle_rank']}")
    print(f"  Q-visible components κ = {result['q_visible_count']}")
    print(f"  Predicted tropical kernel dimension = {result['predicted_dim']}")

    if result['cycles']:
        print(f"\n  Cycle generators ({len(result['cycles'])}):")
        for i, (cycle, gen) in enumerate(zip(result['cycles'],
                                              result['cycle_generators'])):
            vec_str = str(gen)
            print(f"    C{i+1}: cycle {cycle} → {vec_str}")

    if result['q_visible_components']:
        print(f"\n  Component generators ({len(result['q_visible_components'])}):")
        for i, (comp, gen) in enumerate(zip(result['q_visible_components'],
                                             result['component_generators'])):
            vec_str = str(gen)
            print(f"    K{i+1}: component {sorted(comp)} → {vec_str}")

    print(f"\n  Total generators: {len(result['all_generators'])}")


if __name__ == "__main__":
    print("=== Tropical Kernel Decomposition Algorithm ===\n")

    # Example 1: K4
    print("K₄ with q=0, S={1,2,3}:")
    K4 = SimpleGraph(4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])
    result = decompose_tropical_kernel(K4, 0, {1, 2, 3})
    print_decomposition(result)

    # Example 2: Path
    print("\nP₅ with q=0, S={1,2,3,4}:")
    P5 = SimpleGraph(5, [(0, 1), (1, 2), (2, 3), (3, 4)])
    result = decompose_tropical_kernel(P5, 0, {1, 2, 3, 4})
    print_decomposition(result)

    # Example 3: Petersen-like
    print("\nGraph with cycle and isolated component:")
    G = SimpleGraph(6, [(0, 1), (1, 2), (2, 3), (3, 1), (4, 5)])
    result = decompose_tropical_kernel(G, 0, {1, 2, 3, 4, 5})
    print_decomposition(result)
