"""
Algorithms for Gravity as Quantum Error Correction.

Implements core algorithms connecting quantum error-correcting codes
to holographic gravity, including:
- QEC code parameter verification
- Greedy entanglement wedge reconstruction
- RT minimal surface computation via min-cut
- Holographic entropy cone membership testing
- HaPPY code tensor network construction

Type-hinted throughout for clarity.
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass, field
from typing import FrozenSet, Optional


@dataclass(frozen=True)
class QECCode:
    """A quantum error-correcting code [[n, k, d]].

    Attributes:
        n: Number of physical qubits (boundary sites).
        k: Number of logical qubits (bulk degrees of freedom).
        d: Code distance (minimum weight of non-trivial logical operator).
    """
    n: int
    k: int
    d: int

    def __post_init__(self) -> None:
        assert self.k <= self.n, f"k={self.k} > n={self.n}"
        assert self.d > 0, f"d={self.d} must be positive"
        assert self.d <= self.n, f"d={self.d} > n={self.n}"

    @property
    def redundancy(self) -> int:
        """Number of check qubits: n - k."""
        return self.n - self.k

    @property
    def rate(self) -> float:
        """Code rate: k / n."""
        return self.k / self.n if self.n > 0 else 0.0

    @property
    def erasure_threshold(self) -> int:
        """Maximum erasures correctable: d - 1."""
        return self.d - 1

    def satisfies_singleton_bound(self) -> bool:
        """Check the quantum Singleton bound: 2(d-1) <= n - k."""
        return 2 * (self.d - 1) <= self.n - self.k

    def is_perfect(self) -> bool:
        """Check if the code saturates the Singleton bound: 2(d-1) = n - k."""
        return 2 * (self.d - 1) == self.n - self.k

    def area_entropy_duality(self) -> Optional[int]:
        """For perfect codes, verify 2(d-1) + k = n. Returns n if perfect, None otherwise."""
        if self.is_perfect():
            assert 2 * (self.d - 1) + self.k == self.n
            return self.n
        return None


# Standard quantum codes
CODE_5_1_3 = QECCode(n=5, k=1, d=3)
CODE_7_1_3 = QECCode(n=7, k=1, d=3)  # Steane code
CODE_9_1_3 = QECCode(n=9, k=1, d=3)  # Shor code


@dataclass
class BulkGraph:
    """A discrete bulk geometry as a weighted graph.

    Vertices are labeled 0..num_vertices-1.
    Boundary vertices are a subset of all vertices.
    """
    num_vertices: int
    edges: dict[tuple[int, int], float] = field(default_factory=dict)
    boundary_vertices: set[int] = field(default_factory=set)

    def add_edge(self, u: int, v: int, weight: float = 1.0) -> None:
        """Add an undirected edge."""
        self.edges[(min(u, v), max(u, v))] = weight

    def neighbors(self, v: int) -> list[int]:
        """Get neighbors of vertex v."""
        result = []
        for (u, w), _ in self.edges.items():
            if u == v:
                result.append(w)
            elif w == v:
                result.append(u)
        return result

    def edge_weight(self, u: int, v: int) -> float:
        """Get weight of edge (u, v), or 0 if no edge."""
        key = (min(u, v), max(u, v))
        return self.edges.get(key, 0.0)


def greedy_entanglement_wedge(
    graph: BulkGraph,
    boundary_region: set[int],
) -> set[int]:
    """Greedy entanglement wedge reconstruction.

    Given a bulk graph and a boundary region A, iteratively include
    bulk vertices whose connection to A exceeds their connection to
    the complement.

    Args:
        graph: The discrete bulk geometry.
        boundary_region: Set of boundary vertex indices in region A.

    Returns:
        The entanglement wedge: set of bulk vertices reconstructable from A.
    """
    reconstructed = set(boundary_region)
    bulk_vertices = set(range(graph.num_vertices)) - graph.boundary_vertices
    changed = True

    while changed:
        changed = False
        for v in list(bulk_vertices - reconstructed):
            nbrs = graph.neighbors(v)
            count_in = sum(1 for u in nbrs if u in reconstructed)
            count_out = sum(1 for u in nbrs if u not in reconstructed)
            if count_in > count_out:
                reconstructed.add(v)
                changed = True

    return reconstructed - graph.boundary_vertices


def min_cut_area(
    graph: BulkGraph,
    boundary_region: set[int],
) -> float:
    """Compute the minimal surface area (min-cut) for a boundary region.

    Uses a brute-force enumeration for small graphs.

    Args:
        graph: The discrete bulk geometry.
        boundary_region: Boundary vertices in region A.

    Returns:
        The minimum cut value separating A from its complement.
    """
    complement = graph.boundary_vertices - boundary_region
    if not complement:
        return 0.0

    all_vertices = set(range(graph.num_vertices))
    non_boundary = all_vertices - graph.boundary_vertices
    best_cut = float('inf')

    # Enumerate all possible separating sets
    for size in range(len(non_boundary) + 1):
        for subset in itertools.combinations(non_boundary, size):
            side_a = boundary_region | set(subset)
            side_b = all_vertices - side_a

            # Check connectivity: A side must contain all of boundary_region
            # B side must contain all of complement
            if not complement.issubset(side_b):
                continue

            # Compute cut value
            cut_value = 0.0
            for (u, v), w in graph.edges.items():
                if (u in side_a and v in side_b) or (u in side_b and v in side_a):
                    cut_value += w

            best_cut = min(best_cut, cut_value)

    return best_cut


def is_holographic_vector(
    entropy: dict[FrozenSet[int], float],
    n: int,
    tol: float = 1e-10,
) -> tuple[bool, str]:
    """Check if an entropy vector satisfies holographic constraints.

    Tests: non-negativity, SSA, and MMI.

    Args:
        entropy: Map from subsets to entropy values.
        n: Number of parties.
        tol: Numerical tolerance.

    Returns:
        (is_holographic, reason) where reason explains any violation.
    """
    parties = list(range(n))

    # Non-negativity
    for subset, val in entropy.items():
        if val < -tol:
            return False, f"Negative entropy: S({subset}) = {val}"

    # SSA: S(A∪B) + S(A∩B) ≤ S(A) + S(B)
    for size_a in range(1, n + 1):
        for a_tuple in itertools.combinations(parties, size_a):
            a = frozenset(a_tuple)
            for size_b in range(1, n + 1):
                for b_tuple in itertools.combinations(parties, size_b):
                    b = frozenset(b_tuple)
                    union = a | b
                    inter = a & b
                    s_union = entropy.get(union, 0.0)
                    s_inter = entropy.get(inter, 0.0)
                    s_a = entropy.get(a, 0.0)
                    s_b = entropy.get(b, 0.0)
                    if s_union + s_inter > s_a + s_b + tol:
                        return False, (
                            f"SSA violated: S({union}) + S({inter}) = "
                            f"{s_union + s_inter} > S({a}) + S({b}) = {s_a + s_b}"
                        )

    # MMI: S(AB) + S(AC) + S(BC) ≥ S(A) + S(B) + S(C) + S(ABC)
    for triple in itertools.combinations(parties, 3):
        a, b, c = frozenset([triple[0]]), frozenset([triple[1]]), frozenset([triple[2]])
        ab, ac, bc = a | b, a | c, b | c
        abc = a | b | c
        lhs = entropy.get(ab, 0.0) + entropy.get(ac, 0.0) + entropy.get(bc, 0.0)
        rhs = (entropy.get(a, 0.0) + entropy.get(b, 0.0) +
               entropy.get(c, 0.0) + entropy.get(abc, 0.0))
        if lhs < rhs - tol:
            return False, (
                f"MMI violated for {triple}: "
                f"S(AB)+S(AC)+S(BC) = {lhs} < S(A)+S(B)+S(C)+S(ABC) = {rhs}"
            )

    return True, "All holographic constraints satisfied"


@dataclass
class HaPPYTile:
    """A single tile in a HaPPY code tensor network."""
    code: QECCode
    bulk_legs: int
    boundary_legs: int
    tile_id: int

    def __post_init__(self) -> None:
        assert self.code.n == self.bulk_legs + self.boundary_legs


@dataclass
class HaPPYCode:
    """A HaPPY code: tensor network of [[5,1,3]] tiles.

    Each tile is a [[5,1,3]] code with some legs connected to other tiles
    (bulk legs) and some legs on the boundary.
    """
    tiles: list[HaPPYTile]
    connections: list[tuple[int, int, int, int]]  # (tile1, leg1, tile2, leg2)

    @property
    def num_tiles(self) -> int:
        return len(self.tiles)

    @property
    def total_logical_qubits(self) -> int:
        """Total logical qubits = number of tiles (each contributes k=1)."""
        return sum(t.code.k for t in self.tiles)

    @property
    def total_boundary_legs(self) -> int:
        return sum(t.boundary_legs for t in self.tiles)

    @property
    def total_physical_legs(self) -> int:
        return sum(t.code.n for t in self.tiles)

    def verify_structure(self) -> bool:
        """Verify HaPPY code structural properties."""
        # All tiles must be [[5,1,3]]
        for t in self.tiles:
            if t.code != CODE_5_1_3:
                return False
        # Total logical = num tiles
        if self.total_logical_qubits != self.num_tiles:
            return False
        # Total physical = 5 * num tiles
        if self.total_physical_legs != 5 * self.num_tiles:
            return False
        return True


def build_single_tile_happy() -> HaPPYCode:
    """Build the simplest HaPPY code: a single [[5,1,3]] tile with all legs on boundary."""
    tile = HaPPYTile(
        code=CODE_5_1_3,
        bulk_legs=0,
        boundary_legs=5,
        tile_id=0,
    )
    return HaPPYCode(tiles=[tile], connections=[])


def build_two_tile_happy() -> HaPPYCode:
    """Build a 2-tile HaPPY code with one shared edge."""
    tile0 = HaPPYTile(code=CODE_5_1_3, bulk_legs=1, boundary_legs=4, tile_id=0)
    tile1 = HaPPYTile(code=CODE_5_1_3, bulk_legs=1, boundary_legs=4, tile_id=1)
    return HaPPYCode(
        tiles=[tile0, tile1],
        connections=[(0, 0, 1, 0)],  # leg 0 of tile 0 connects to leg 0 of tile 1
    )


def complementary_recovery_check(code: QECCode, region_size: int) -> dict[str, object]:
    """Check complementary recovery for a given region size.

    Returns analysis of whether the region can reconstruct bulk information
    and whether its complement can as well (should be impossible by no-cloning).
    """
    complement_size = code.n - region_size
    region_can_reconstruct = region_size >= code.n - code.d + 1
    complement_can_reconstruct = complement_size >= code.n - code.d + 1

    return {
        "code": f"[[{code.n},{code.k},{code.d}]]",
        "region_size": region_size,
        "complement_size": complement_size,
        "region_can_reconstruct": region_can_reconstruct,
        "complement_can_reconstruct": complement_can_reconstruct,
        "no_cloning_satisfied": not (region_can_reconstruct and complement_can_reconstruct),
        "complement_lt_distance": complement_size < code.d,
    }


def singleton_bound_analysis(codes: list[QECCode]) -> list[dict[str, object]]:
    """Analyze the Singleton bound for a collection of codes."""
    results = []
    for code in codes:
        lhs = 2 * (code.d - 1)
        rhs = code.n - code.k
        results.append({
            "code": f"[[{code.n},{code.k},{code.d}]]",
            "2(d-1)": lhs,
            "n-k": rhs,
            "satisfies_singleton": lhs <= rhs,
            "is_perfect": lhs == rhs,
            "redundancy": code.redundancy,
            "erasure_threshold": code.erasure_threshold,
            "rate": round(code.rate, 4),
        })
    return results
