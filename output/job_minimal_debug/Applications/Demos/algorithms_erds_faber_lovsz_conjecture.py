"""
Algorithms for the Erdős–Faber–Lovász Conjecture

Type-hinted implementations of coloring algorithms and structural analysis
for k-uniform linear hypergraphs (EFL systems).
"""

from typing import List, Set, Dict, Tuple, Optional, FrozenSet
from itertools import combinations
import random


class EFLSystem:
    """A k-uniform linear hypergraph with k edges.
    
    Represents an EFL system: k sets (edges), each of size k,
    where any two distinct edges share at most one element.
    """
    
    def __init__(self, edges: List[Set[int]]):
        """Initialize an EFL system from a list of sets.
        
        Args:
            edges: List of sets, each of the same size k = len(edges),
                   with pairwise intersection size ≤ 1.
        
        Raises:
            ValueError: If the system violates EFL constraints.
        """
        self.k = len(edges)
        self.edges = [frozenset(e) for e in edges]
        self._validate()
    
    def _validate(self) -> None:
        """Verify EFL constraints: k-uniformity and linearity."""
        for i, e in enumerate(self.edges):
            if len(e) != self.k:
                raise ValueError(
                    f"Edge {i} has size {len(e)}, expected {self.k}"
                )
        for i, j in combinations(range(self.k), 2):
            inter = self.edges[i] & self.edges[j]
            if len(inter) > 1:
                raise ValueError(
                    f"Edges {i} and {j} share {len(inter)} vertices "
                    f"(max 1 allowed): {inter}"
                )
    
    @property
    def vertex_set(self) -> Set[int]:
        """Return the set of all vertices."""
        return set().union(*self.edges)
    
    def degree(self, v: int) -> int:
        """Return the degree of vertex v (number of edges containing v)."""
        return sum(1 for e in self.edges if v in e)
    
    def degree_sequence(self) -> List[int]:
        """Return the sorted degree sequence (descending)."""
        return sorted(
            [self.degree(v) for v in self.vertex_set],
            reverse=True
        )
    
    def incidence_count(self) -> int:
        """Return the total number of vertex-edge incidences (should be k²)."""
        return sum(len(e) for e in self.edges)
    
    def is_near_pencil(self) -> Tuple[bool, Optional[int]]:
        """Check if the system is a near-pencil.
        
        Returns:
            (True, center_vertex) if near-pencil, (False, None) otherwise.
        """
        if self.k == 0:
            return True, None
        common = set(self.edges[0])
        for e in self.edges[1:]:
            common &= e
        if common:
            return True, min(common)
        return False, None
    
    def exclusive_vertices(self) -> Dict[int, int]:
        """Find degree-1 vertices and their unique edge index.
        
        Returns:
            Dict mapping vertex -> edge index for all degree-1 vertices.
        """
        result = {}
        for i, e in enumerate(self.edges):
            for v in e:
                if self.degree(v) == 1:
                    result[v] = i
        return result
    
    def high_degree_vertices(self) -> Set[int]:
        """Return vertices with degree ≥ 2."""
        return {v for v in self.vertex_set if self.degree(v) >= 2}
    
    def pairwise_intersection_sum(self) -> int:
        """Sum of |edges[i] ∩ edges[j]| over all ordered pairs i ≠ j."""
        total = 0
        for i, j in combinations(range(self.k), 2):
            total += 2 * len(self.edges[i] & self.edges[j])
        return total


def near_pencil_coloring(system: EFLSystem) -> Dict[int, int]:
    """Color a near-pencil EFL system with k colors.
    
    Algorithm:
    1. Assign color 0 to the center vertex.
    2. For each edge i, assign colors 1,...,k-1 to non-center vertices.
    3. Uncolored vertices get color 0.
    
    Args:
        system: A near-pencil EFL system.
    
    Returns:
        Dict mapping vertex -> color (in range [0, k)).
    
    Raises:
        ValueError: If the system is not a near-pencil.
    """
    is_np, center = system.is_near_pencil()
    if not is_np:
        raise ValueError("System is not a near-pencil")
    
    coloring: Dict[int, int] = {}
    
    if system.k == 0:
        return coloring
    
    assert center is not None
    coloring[center] = 0
    
    for i, edge in enumerate(system.edges):
        non_center = sorted(edge - {center})
        for j, v in enumerate(non_center):
            coloring[v] = j + 1  # Colors 1 through k-1
    
    return coloring


def greedy_coloring(system: EFLSystem) -> Dict[int, int]:
    """Greedy coloring of an EFL system.
    
    Colors vertices in decreasing degree order, using the smallest
    available color that doesn't create a conflict on any edge.
    
    Args:
        system: An EFL system.
    
    Returns:
        Dict mapping vertex -> color.
    """
    vertices = sorted(
        system.vertex_set,
        key=lambda v: -system.degree(v)
    )
    
    coloring: Dict[int, int] = {}
    
    for v in vertices:
        # Find colors used by neighbors on shared edges
        forbidden: Set[int] = set()
        for edge in system.edges:
            if v in edge:
                for u in edge:
                    if u in coloring:
                        forbidden.add(coloring[u])
        
        # Assign smallest available color
        color = 0
        while color in forbidden:
            color += 1
        coloring[v] = color
    
    return coloring


def verify_strong_coloring(
    system: EFLSystem,
    coloring: Dict[int, int]
) -> bool:
    """Verify that a coloring is a strong k-coloring.
    
    Checks that the coloring is injective on each edge.
    """
    for edge in system.edges:
        colors_used = set()
        for v in edge:
            if v not in coloring:
                return False
            c = coloring[v]
            if c in colors_used:
                return False
            colors_used.add(c)
    return True


def make_near_pencil(k: int) -> EFLSystem:
    """Construct the near-pencil EFL system with parameter k.
    
    The center vertex is 0. Edge i has vertices {0, i*k+1, ..., i*k+k-1}
    for i = 0, ..., k-1 (using shifted indexing to ensure distinctness).
    
    Actually, we use: center = 0, edge i = {0} ∪ {i*(k-1)+1, ..., i*(k-1)+(k-1)}.
    """
    if k == 0:
        return EFLSystem([])
    
    center = 0
    edges = []
    for i in range(k):
        non_center = set(range(1 + i * (k - 1), 1 + (i + 1) * (k - 1)))
        if k == 1:
            non_center = set()
        edges.append({center} | non_center)
    
    return EFLSystem(edges)


def make_disjoint_system(k: int) -> EFLSystem:
    """Construct a disjoint EFL system (all edges pairwise disjoint).
    
    Edge i = {i*k, i*k+1, ..., i*k+k-1}.
    This is the "loosest" EFL configuration.
    """
    edges = [set(range(i * k, (i + 1) * k)) for i in range(k)]
    return EFLSystem(edges)


def enumerate_efl_systems(k: int, max_vertices: int = None) -> List[EFLSystem]:
    """Enumerate some EFL systems with parameter k.
    
    For small k, generates several canonical EFL configurations.
    Not exhaustive for k > 3.
    """
    if max_vertices is None:
        max_vertices = k * k
    
    systems = []
    
    # Near-pencil
    systems.append(make_near_pencil(k))
    
    # Disjoint system
    if k >= 2:
        systems.append(make_disjoint_system(k))
    
    # For k = 3, some intermediate configurations
    if k == 3:
        # Two edges share a vertex, third is disjoint from one
        systems.append(EFLSystem([{0, 1, 2}, {0, 3, 4}, {5, 6, 7}]))
        # Chain: each consecutive pair shares a vertex
        systems.append(EFLSystem([{0, 1, 2}, {2, 3, 4}, {4, 5, 6}]))
        # Triangle: each pair shares one vertex
        systems.append(EFLSystem([{0, 1, 2}, {0, 3, 4}, {1, 3, 5}]))
    
    return systems


def structural_analysis(system: EFLSystem) -> Dict:
    """Perform complete structural analysis of an EFL system.
    
    Returns a dictionary with all key invariants.
    """
    k = system.k
    vs = system.vertex_set
    is_np, center = system.is_near_pencil()
    exclusive = system.exclusive_vertices()
    high_deg = system.high_degree_vertices()
    
    return {
        'k': k,
        'num_vertices': len(vs),
        'vertex_set_lower_bound': k,
        'vertex_set_upper_bound': k ** 2,
        'incidence_count': system.incidence_count(),
        'expected_incidence': k ** 2,
        'degree_sequence': system.degree_sequence(),
        'max_degree': max(system.degree_sequence()) if vs else 0,
        'is_near_pencil': is_np,
        'center_vertex': center,
        'num_exclusive_vertices': len(exclusive),
        'num_high_degree_vertices': len(high_deg),
        'high_degree_bound': k * (k - 1) // 2,
        'pairwise_intersection_sum': system.pairwise_intersection_sum(),
        'pairwise_bound': k * (k - 1),
    }
