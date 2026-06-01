"""
Algorithms for Erdős–Faber–Lovász Conjecture

Type-hinted implementations of key algorithms related to the EFL conjecture:
1. EFL system construction and validation
2. Greedy coloring for linear hypergraphs
3. Near-pencil construction
4. Probabilistic coloring bound (Kang–Kelly–Kühn–Methuku–Osthus approach)
"""

from typing import List, Set, Dict, Tuple, Optional
import random
from itertools import combinations


class EFLSystem:
    """An EFL system: k sets of size k with pairwise intersection ≤ 1."""

    def __init__(self, edges: List[Set[int]]) -> None:
        self.edges = edges
        self.k = len(edges)

    def is_valid(self) -> bool:
        """Check k-uniformity and linearity."""
        # k-uniformity
        for e in self.edges:
            if len(e) != self.k:
                return False
        # linearity
        for i, j in combinations(range(self.k), 2):
            if len(self.edges[i] & self.edges[j]) > 1:
                return False
        return True

    def vertex_set(self) -> Set[int]:
        """Union of all edges."""
        result: Set[int] = set()
        for e in self.edges:
            result |= e
        return result

    def degree(self, v: int) -> int:
        """Number of edges containing vertex v."""
        return sum(1 for e in self.edges if v in e)

    def high_degree_vertices(self) -> Set[int]:
        """Vertices with degree ≥ 2."""
        return {v for v in self.vertex_set() if self.degree(v) >= 2}

    def incidence_count(self) -> int:
        """Total vertex-edge incidences. Should equal k²."""
        return sum(len(e) for e in self.edges)


def construct_near_pencil(k: int) -> EFLSystem:
    """
    Construct the near-pencil EFL system with parameter k.

    The near-pencil has:
    - One center vertex (0) shared by all k edges
    - k petals of k-1 vertices each, all disjoint

    Total vertices: 1 + k*(k-1) = k² - k + 1
    """
    center = 0
    edges: List[Set[int]] = []
    next_vertex = 1
    for i in range(k):
        edge: Set[int] = {center}
        for _ in range(k - 1):
            edge.add(next_vertex)
            next_vertex += 1
        edges.append(edge)
    return EFLSystem(edges)


def construct_disjoint_system(k: int) -> EFLSystem:
    """
    Construct the disjoint EFL system: k disjoint edges of size k.
    Total vertices: k².
    """
    edges: List[Set[int]] = []
    for i in range(k):
        edges.append(set(range(i * k, (i + 1) * k)))
    return EFLSystem(edges)


def greedy_rainbow_coloring(system: EFLSystem) -> Optional[Dict[int, int]]:
    """
    Greedy coloring algorithm for EFL systems.

    Attempts to color vertices so that each edge receives all distinct colors.
    Uses a greedy strategy: process vertices in decreasing degree order,
    assign the smallest color not already used in any edge containing v.

    Returns a coloring dict {vertex: color} or None if greedy fails.
    """
    k = system.k
    vertices = sorted(system.vertex_set(),
                       key=lambda v: system.degree(v), reverse=True)

    coloring: Dict[int, int] = {}

    for v in vertices:
        # Find colors used in edges containing v
        forbidden: Set[int] = set()
        for e in system.edges:
            if v in e:
                for u in e:
                    if u in coloring:
                        forbidden.add(coloring[u])

        # Assign smallest available color
        color = 0
        while color in forbidden:
            color += 1
        coloring[v] = color

    # Verify: all colors < k?
    max_color = max(coloring.values()) if coloring else 0
    if max_color >= k:
        return None  # Greedy used too many colors
    return coloring


def verify_strong_coloring(system: EFLSystem, coloring: Dict[int, int]) -> bool:
    """Verify that a coloring is a valid strong (rainbow) coloring."""
    for e in system.edges:
        colors_in_edge = set()
        for v in e:
            if v not in coloring:
                return False
            if coloring[v] in colors_in_edge:
                return False  # Two vertices in same edge have same color
            colors_in_edge.add(coloring[v])
    return True


def probabilistic_coloring_bound(k: int, trials: int = 1000) -> float:
    """
    Estimate the probability that a random coloring of the near-pencil
    is a valid strong coloring.

    For the near-pencil with parameter k, a random assignment of k colors
    to k² - k + 1 vertices. Estimates P(valid).

    This demonstrates why probabilistic approaches need careful derandomization:
    the probability is very small for large k.
    """
    if k <= 0:
        return 1.0

    system = construct_near_pencil(k)
    vertices = sorted(system.vertex_set())
    n_valid = 0

    for _ in range(trials):
        coloring = {v: random.randint(0, k - 1) for v in vertices}
        if verify_strong_coloring(system, coloring):
            n_valid += 1

    return n_valid / trials


def fisher_pair_bound(system: EFLSystem) -> Tuple[int, int]:
    """
    Compute the actual pairwise intersection sum and the Fisher bound k*(k-1).

    Returns (actual_sum, bound).
    The theorem guarantees actual_sum ≤ bound.
    """
    total = 0
    for i, j in combinations(range(system.k), 2):
        total += len(system.edges[i] & system.edges[j])
    # Note: theorem uses ordered pairs, so multiply by 2
    return 2 * total, system.k * (system.k - 1)


def sunflower_core_analysis(system: EFLSystem) -> Dict[int, int]:
    """
    Analyze the sunflower structure: for each vertex, compute its degree.
    In EFL theory, vertices of high degree form sunflower cores.

    Returns {vertex: degree} for all vertices.
    """
    return {v: system.degree(v) for v in system.vertex_set()}


# Type alias for clarity
ColoringResult = Dict[int, int]
