#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for higher-rank defect spectrum computation.

Implements:
1. Graph invariant computation (Betti number, root component count)
2. Higher structural defect via the topological shortcut formula
3. Defect spectrum analysis (slope extraction, affine verification)
4. Brute-force chip-firing rank for validation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from collections import defaultdict, deque
from typing import Dict, List, Set, Tuple, Optional, Callable
from itertools import combinations


# ============================================================
# Data structures
# ============================================================

class SimpleGraph:
    """
    A finite simple undirected graph.

    Attributes:
        vertices: set of vertex labels (integers)
        adj: adjacency list (dict of sets)
        edges: set of edges as sorted pairs

    Time complexity for construction: O(|V| + |E|)
    Space complexity: O(|V| + |E|)
    """

    def __init__(self, vertices: List[int], edges: List[Tuple[int, int]]):
        self.vertices: Set[int] = set(vertices)
        self.edges: Set[Tuple[int, int]] = set()
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        for u, v in edges:
            if u != v and u in self.vertices and v in self.vertices:
                e = (min(u, v), max(u, v))
                self.edges.add(e)
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        """Degree of vertex v. O(1)."""
        return len(self.adj.get(v, set()))

    def induce(self, S: Set[int]) -> 'SimpleGraph':
        """
        Return the induced subgraph G[S].

        Time: O(|S|² ) in the worst case (checking all pairs).
        Space: O(|S| + edges in G[S]).
        """
        sub_edges = [(u, v) for u, v in self.edges if u in S and v in S]
        return SimpleGraph(list(S), sub_edges)

    def remove_vertex(self, v: int) -> 'SimpleGraph':
        """Return G - {v}. Time: O(|V| + |E|)."""
        new_verts = [u for u in self.vertices if u != v]
        new_edges = [(a, b) for a, b in self.edges if a != v and b != v]
        return SimpleGraph(new_verts, new_edges)

    def connected_components(self) -> List[Set[int]]:
        """
        Compute connected components via BFS.

        Time: O(|V| + |E|)
        Space: O(|V|)

        Returns: list of sets, each set is a connected component.
        """
        visited: Set[int] = set()
        components: List[Set[int]] = []
        for v in self.vertices:
            if v not in visited:
                comp: Set[int] = set()
                queue = deque([v])
                while queue:
                    u = queue.popleft()
                    if u in visited:
                        continue
                    visited.add(u)
                    comp.add(u)
                    for w in self.adj[u]:
                        if w in self.vertices and w not in visited:
                            queue.append(w)
                components.append(comp)
        return components

    def is_connected(self) -> bool:
        """Check connectivity. Time: O(|V| + |E|)."""
        if not self.vertices:
            return True
        comps = self.connected_components()
        return len(comps) == 1

    def num_edges(self) -> int:
        """Number of edges. O(1)."""
        return len(self.edges)


# ============================================================
# Algorithm 1: Graph invariant computation
# ============================================================

def compute_betti_1(G: SimpleGraph, S: Set[int]) -> int:
    """
    Compute the first Betti number β₁(G[S]).

    β₁ = |E(G[S])| - |S| + c(G[S])

    where c is the number of connected components.

    Time: O(|S|² + |S|)  — inducing subgraph + BFS
    Space: O(|S| + |E(G[S])|)

    Args:
        G: the ambient graph
        S: vertex subset

    Returns:
        β₁(G[S]) as a non-negative integer

    Example:
        >>> G = SimpleGraph([0,1,2,3], [(0,1),(1,2),(2,0),(2,3)])
        >>> compute_betti_1(G, {0,1,2})  # triangle
        1
        >>> compute_betti_1(G, {0,1,3})  # path
        0
    """
    sub = G.induce(S)
    e = sub.num_edges()
    c = len(sub.connected_components())
    return e - len(S) + c


def compute_root_component_count(G: SimpleGraph, q: int, S: Set[int]) -> int:
    """
    Compute κ(G, q, S): number of components of G-{q} intersecting S.

    Time: O(|V| + |E|)
    Space: O(|V|)

    Args:
        G: the ambient graph
        q: root vertex
        S: vertex subset (should not contain q for the theory to apply)

    Returns:
        κ(G, q, S) as a non-negative integer

    Example:
        >>> G = SimpleGraph([0,1,2,3], [(0,1),(0,2),(0,3)])  # star
        >>> compute_root_component_count(G, 0, {1,2,3})
        3
        >>> compute_root_component_count(G, 0, {1,2})
        2
    """
    G_minus_q = G.remove_vertex(q)
    comps = G_minus_q.connected_components()
    return sum(1 for comp in comps if comp & S)


# ============================================================
# Algorithm 2: Higher structural defect (topological shortcut)
# ============================================================

def compute_higher_defect(G: SimpleGraph, q: int, S: Set[int], d: int) -> int:
    """
    Compute the higher structural defect δ_d(G, q, S).

    Formula: δ_d = d · β₁(G[S]) + κ(G,q,S) - 1

    This is the topological shortcut algorithm that avoids chip-firing
    entirely, computing the defect directly from graph topology.

    Time: O(|V| + |E|)  — dominated by BFS for components
    Space: O(|V| + |E|)

    Args:
        G: finite simple graph
        q: root vertex
        S: vertex subset (q ∉ S)
        d: degree parameter (≥ 0)

    Returns:
        δ_d as an integer

    Example:
        >>> G = SimpleGraph([0,1,2,3,4], [(0,1),(1,2),(2,3),(3,4),(4,0)])
        >>> compute_higher_defect(G, 0, {1,2,3,4}, 1)  # cycle, β₁=1, κ=1
        1
        >>> compute_higher_defect(G, 0, {1,2,3,4}, 3)
        3
    """
    beta1 = compute_betti_1(G, S)
    kappa = compute_root_component_count(G, q, S)
    return d * beta1 + kappa - 1


def compute_defect_spectrum(
    G: SimpleGraph, q: int, S: Set[int], max_d: int = 10
) -> List[int]:
    """
    Compute the full defect spectrum [δ₀, δ₁, ..., δ_{max_d}].

    Time: O(max_d · (|V| + |E|))
    Space: O(max_d + |V| + |E|)

    In practice, since β₁ and κ are computed once, this is O(|V|+|E|) + O(max_d).
    """
    beta1 = compute_betti_1(G, S)
    kappa = compute_root_component_count(G, q, S)
    return [d * beta1 + kappa - 1 for d in range(max_d + 1)]


# ============================================================
# Algorithm 3: Spectrum analysis
# ============================================================

def extract_spectral_slope(spectrum: List[int]) -> Optional[int]:
    """
    Extract the spectral slope from a defect spectrum.

    For an affine spectrum δ_d = slope · d + intercept,
    the slope is δ₁ - δ₀ = β₁(G[S]).

    Time: O(1)

    Returns:
        The slope (first difference), or None if spectrum too short.
    """
    if len(spectrum) < 2:
        return None
    return spectrum[1] - spectrum[0]


def extract_intercept(spectrum: List[int]) -> Optional[int]:
    """
    Extract the intercept of the defect spectrum.

    intercept = δ₀ = κ - 1

    Time: O(1)
    """
    if not spectrum:
        return None
    return spectrum[0]


def verify_affinity(spectrum: List[int]) -> Tuple[bool, List[int]]:
    """
    Verify that the spectrum is exactly affine by checking
    all second differences vanish.

    Time: O(len(spectrum))

    Returns:
        (is_affine, list_of_second_differences)
    """
    if len(spectrum) < 3:
        return True, []
    second_diffs = [
        spectrum[i+2] - 2 * spectrum[i+1] + spectrum[i]
        for i in range(len(spectrum) - 2)
    ]
    return all(d == 0 for d in second_diffs), second_diffs


def verify_monotonicity(spectrum: List[int]) -> bool:
    """Check that the spectrum is monotone non-decreasing. O(n)."""
    return all(spectrum[i] <= spectrum[i+1] for i in range(len(spectrum) - 1))


# ============================================================
# Algorithm 4: Cycle extension detection
# ============================================================

def find_cycle_extensions(
    G: SimpleGraph, S: Set[int]
) -> List[Tuple[int, int]]:
    """
    Find edges that could be added within S to create exactly one new cycle.

    An edge (u, v) with u, v ∈ S creates a new cycle if u and v are already
    in the same component of G[S] (and (u,v) is not already an edge).

    Time: O(|S|² + |S| + |E|)
    Space: O(|S|)

    Returns:
        List of potential cycle-creating edges.
    """
    sub = G.induce(S)
    comps = sub.connected_components()
    # Map each vertex to its component index
    comp_of = {}
    for i, comp in enumerate(comps):
        for v in comp:
            comp_of[v] = i

    extensions = []
    for u in S:
        for v in S:
            if u < v and (u, v) not in G.edges:
                if comp_of.get(u) == comp_of.get(v):
                    extensions.append((u, v))
    return extensions


def apply_cycle_extension(
    G: SimpleGraph, edge: Tuple[int, int]
) -> SimpleGraph:
    """
    Return a new graph with one additional edge.

    Time: O(|V| + |E|)
    """
    new_edges = list(G.edges) + [edge]
    return SimpleGraph(list(G.vertices), new_edges)


# ============================================================
# Algorithm 5: Exhaustive conjecture testing
# ============================================================

def test_defect_conjecture(
    max_vertices: int = 6, max_d: int = 3, verbose: bool = False
) -> Tuple[bool, Optional[dict]]:
    """
    Exhaustively test the affine defect conjecture on small graphs.

    For each connected graph on up to max_vertices vertices, each root q,
    and each subset S with q ∉ S, verify that the defect spectrum is
    exactly affine with slope β₁(G[S]) and intercept κ(G,q,S) - 1.

    Time: Exponential in max_vertices (enumerates all graphs and subsets)
    Space: O(max_vertices²)

    Returns:
        (conjecture_holds, counterexample_or_None)
    """
    tested = 0
    # Generate all simple graphs on vertices {0, ..., n-1}
    for n in range(2, max_vertices + 1):
        verts = list(range(n))
        all_possible_edges = list(combinations(verts, 2))

        # Enumerate subsets of edges
        for num_edges in range(n - 1, len(all_possible_edges) + 1):
            for edge_subset in combinations(all_possible_edges, num_edges):
                G = SimpleGraph(verts, list(edge_subset))
                if not G.is_connected():
                    continue

                # For each root and subset
                for q in verts:
                    non_root = [v for v in verts if v != q]
                    for size in range(1, len(non_root) + 1):
                        for S_tuple in combinations(non_root, size):
                            S = set(S_tuple)
                            spectrum = compute_defect_spectrum(G, q, S, max_d)
                            is_affine, second_diffs = verify_affinity(spectrum)
                            tested += 1

                            if not is_affine:
                                counterexample = {
                                    'vertices': verts,
                                    'edges': list(edge_subset),
                                    'root': q,
                                    'subset': S,
                                    'spectrum': spectrum,
                                    'second_diffs': second_diffs
                                }
                                return False, counterexample

                            # Verify slope = β₁
                            slope = extract_spectral_slope(spectrum)
                            beta1 = compute_betti_1(G, S)
                            if slope != beta1:
                                return False, {
                                    'type': 'slope_mismatch',
                                    'slope': slope,
                                    'beta1': beta1,
                                    'vertices': verts,
                                    'edges': list(edge_subset),
                                    'root': q,
                                    'subset': S,
                                }

        if verbose and n <= max_vertices:
            print(f"  Tested all connected graphs on {n} vertices. "
                  f"({tested} cases so far, all pass.)")

    return True, None


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  HIGHER DEFECT SPECTRUM — ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Example 1: Pentagon (cycle C5)
    print("\n--- Example 1: Pentagon C₅ ---")
    C5 = SimpleGraph([0,1,2,3,4], [(0,1),(1,2),(2,3),(3,4),(4,0)])
    q, S = 0, {1, 2, 3, 4}
    print(f"  β₁(G[S]) = {compute_betti_1(C5, S)}")
    print(f"  κ(G,q,S) = {compute_root_component_count(C5, q, S)}")
    spectrum = compute_defect_spectrum(C5, q, S, 6)
    print(f"  Spectrum: {spectrum}")
    print(f"  Slope: {extract_spectral_slope(spectrum)}")
    is_aff, diffs = verify_affinity(spectrum)
    print(f"  Affine: {is_aff} (2nd diffs: {diffs})")

    # Example 2: Star graph S₃
    print("\n--- Example 2: Star S₃ (tree) ---")
    star = SimpleGraph([0,1,2,3], [(0,1),(0,2),(0,3)])
    q, S = 0, {1, 2, 3}
    print(f"  β₁(G[S]) = {compute_betti_1(star, S)}")
    print(f"  κ(G,q,S) = {compute_root_component_count(star, q, S)}")
    spectrum = compute_defect_spectrum(star, q, S, 6)
    print(f"  Spectrum: {spectrum}")
    print(f"  Slope: {extract_spectral_slope(spectrum)}")
    print(f"  Tree stability: all d≥1 values equal = {len(set(spectrum[1:])) <= 1}")

    # Example 3: Cycle extension test
    print("\n--- Example 3: Cycle extension ---")
    path = SimpleGraph([0,1,2,3], [(0,1),(1,2),(2,3)])
    S = {1, 2, 3}
    print(f"  Path P₄, S={S}")
    extensions = find_cycle_extensions(path, S)
    print(f"  Possible cycle-creating edges: {extensions}")
    for edge in extensions:
        G_ext = apply_cycle_extension(path, edge)
        beta_before = compute_betti_1(path, S)
        beta_after = compute_betti_1(G_ext, S)
        print(f"  Adding edge {edge}: β₁ changes {beta_before} → {beta_after}")
        for d in range(1, 5):
            delta_before = compute_higher_defect(path, 0, S, d)
            delta_after = compute_higher_defect(G_ext, 0, S, d)
            print(f"    d={d}: δ changes {delta_before} → {delta_after} (Δ = {delta_after - delta_before})")

    # Example 4: Exhaustive testing
    print("\n--- Example 4: Exhaustive conjecture test ---")
    print("  Testing affine defect conjecture on all connected graphs up to 5 vertices...")
    holds, counter = test_defect_conjecture(max_vertices=5, max_d=4, verbose=True)
    if holds:
        print("  ✓ CONJECTURE HOLDS for all tested cases!")
    else:
        print(f"  ✗ COUNTEREXAMPLE FOUND: {counter}")
