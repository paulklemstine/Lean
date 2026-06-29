"""
Algorithms for EFL System analysis and tropical intersection theory.

Type-hinted implementations of:
1. EFL system construction and validation
2. Exclusive vertex computation
3. Tropical intersection matrix
4. Greedy EFL coloring
5. Tropical chromatic defect computation (brute force for small k)
"""

from itertools import combinations, product
from typing import List, Set, Dict, Tuple, Optional, FrozenSet
from dataclasses import dataclass


@dataclass
class EFLSystem:
    """A k-uniform linear hypergraph with k edges."""
    k: int
    edges: List[FrozenSet[int]]

    def validate(self) -> bool:
        """Check uniformity and linearity conditions."""
        if len(self.edges) != self.k:
            return False
        if any(len(e) != self.k for e in self.edges):
            return False
        for i, j in combinations(range(self.k), 2):
            if len(self.edges[i] & self.edges[j]) > 1:
                return False
        return True

    @property
    def vertex_set(self) -> FrozenSet[int]:
        """Union of all edges."""
        return frozenset().union(*self.edges) if self.edges else frozenset()

    def degree(self, v: int) -> int:
        """Number of edges containing vertex v."""
        return sum(1 for e in self.edges if v in e)

    def exclusive_vertices(self, i: int) -> FrozenSet[int]:
        """Vertices in edge i that appear in no other edge."""
        return frozenset(
            v for v in self.edges[i]
            if all(v not in self.edges[j] for j in range(self.k) if j != i)
        )

    def is_near_pencil(self) -> Tuple[bool, Optional[int]]:
        """Check if the system is a near-pencil. Returns (is_np, center_index)."""
        for c in range(self.k):
            is_center = True
            for j in range(self.k):
                if j != c and len(self.edges[c] & self.edges[j]) != 1:
                    is_center = False
                    break
            if not is_center:
                continue
            all_disjoint = True
            for i, j in combinations(range(self.k), 2):
                if i != c and j != c and self.edges[i] & self.edges[j]:
                    all_disjoint = False
                    break
            if all_disjoint:
                return True, c
        return False, None


def tropical_intersection_matrix(system: EFLSystem) -> List[List[int]]:
    """Compute the tropical intersection matrix.

    M[i][j] = 0 if i == j, else |edges[i] ∩ edges[j]|.
    In tropical (max-plus) algebra, this matrix encodes the coupling
    between edges. The linearity constraint ensures M[i][j] ≤ 1 for i ≠ j.
    """
    k = system.k
    M: List[List[int]] = [[0] * k for _ in range(k)]
    for i in range(k):
        for j in range(k):
            if i != j:
                M[i][j] = len(system.edges[i] & system.edges[j])
    return M


def total_intersection_count(system: EFLSystem) -> int:
    """Sum of all off-diagonal intersection sizes. Bounded by k(k-1)."""
    M = tropical_intersection_matrix(system)
    return sum(M[i][j] for i in range(system.k) for j in range(system.k))


def greedy_efl_coloring(system: EFLSystem) -> Optional[Dict[int, int]]:
    """Attempt a strong k-coloring using the greedy strategy.

    Strategy:
    1. Color one exclusive vertex per edge with a distinct color.
    2. Greedily color remaining vertices, avoiding conflicts within each edge.

    Returns coloring dict or None if greedy fails.
    """
    k = system.k
    coloring: Dict[int, int] = {}

    # Phase 1: Color exclusive vertices
    for i in range(k):
        excl = system.exclusive_vertices(i)
        if excl:
            v = min(excl)
            coloring[v] = i

    # Phase 2: Greedy extension
    for v in sorted(system.vertex_set):
        if v in coloring:
            continue
        available = set(range(k))
        for i in range(k):
            if v in system.edges[i]:
                for w in system.edges[i]:
                    if w in coloring:
                        available.discard(coloring[w])
        if not available:
            return None
        coloring[v] = min(available)

    return coloring


def brute_force_chromatic_defect(system: EFLSystem) -> Tuple[int, Optional[Dict[int, int]]]:
    """Compute the tropical chromatic defect by exhaustive search.

    Returns (defect, best_coloring).
    For small k only — exponential in |V|.
    """
    V = sorted(system.vertex_set)
    k = system.k
    if k == 0:
        return 0, {}

    best_defect = float('inf')
    best_coloring: Optional[Dict[int, int]] = None

    for assignment in product(range(k), repeat=len(V)):
        c = dict(zip(V, assignment))
        max_conflicts = 0
        for edge in system.edges:
            edge_list = sorted(edge)
            conflicts = 0
            for a, b in combinations(edge_list, 2):
                if c[a] == c[b]:
                    conflicts += 1
            max_conflicts = max(max_conflicts, conflicts)
        if max_conflicts < best_defect:
            best_defect = max_conflicts
            best_coloring = dict(c)
            if best_defect == 0:
                return 0, best_coloring

    return int(best_defect), best_coloring


def enumerate_efl_systems(k: int, max_vertex: int = None) -> List[EFLSystem]:
    """Enumerate non-isomorphic EFL systems with parameter k.

    Uses brute force over vertex assignments. Only practical for k ≤ 3.
    """
    if max_vertex is None:
        max_vertex = k * k  # Upper bound on vertex count
    if k == 0:
        return [EFLSystem(0, [])]
    if k == 1:
        return [EFLSystem(1, [frozenset({0})])]

    results: List[EFLSystem] = []
    vertices = list(range(max_vertex))

    # Generate all possible first edges
    for first_edge in combinations(vertices, k):
        first = frozenset(first_edge)
        _enumerate_recursive(k, [first], vertices, results)
        if len(results) > 1000:
            break
    return results


def _enumerate_recursive(
    k: int,
    current_edges: List[FrozenSet[int]],
    vertices: List[int],
    results: List[EFLSystem]
) -> None:
    """Recursive helper for EFL enumeration."""
    if len(current_edges) == k:
        system = EFLSystem(k, list(current_edges))
        if system.validate():
            results.append(system)
        return
    if len(results) > 1000:
        return

    for edge in combinations(vertices, k):
        edge_set = frozenset(edge)
        valid = True
        for existing in current_edges:
            if len(edge_set & existing) > 1:
                valid = False
                break
        if valid and (not current_edges or sorted(edge_set) > sorted(current_edges[-1])):
            _enumerate_recursive(k, current_edges + [edge_set], vertices, results)


def degree_sum_verification(system: EFLSystem) -> bool:
    """Verify the degree-sum identity: Σ deg(v) = k²."""
    V = system.vertex_set
    deg_sum = sum(system.degree(v) for v in V)
    return deg_sum == system.k ** 2


def exclusive_vertex_verification(system: EFLSystem) -> bool:
    """Verify that every edge has at least one exclusive vertex (for k ≥ 1)."""
    if system.k == 0:
        return True
    for i in range(system.k):
        if not system.exclusive_vertices(i):
            return False
    return True


if __name__ == "__main__":
    # Test on a near-pencil with k=4
    system = EFLSystem(4, [
        frozenset({0, 1, 2, 3}),
        frozenset({0, 4, 5, 6}),
        frozenset({1, 7, 8, 9}),
        frozenset({2, 10, 11, 12})
    ])

    print(f"Valid: {system.validate()}")
    print(f"Near-pencil: {system.is_near_pencil()}")
    print(f"Vertex count: {len(system.vertex_set)}")
    print(f"Degree-sum check: {degree_sum_verification(system)}")
    print(f"Exclusive vertex check: {exclusive_vertex_verification(system)}")

    M = tropical_intersection_matrix(system)
    print(f"Tropical intersection matrix:")
    for row in M:
        print(f"  {row}")
    print(f"Total intersection: {total_intersection_count(system)}")

    coloring = greedy_efl_coloring(system)
    print(f"Greedy coloring: {coloring}")
