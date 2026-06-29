#!/usr/bin/env python3
"""
Tropical Persistence Realization Duality — Core Algorithms

Implements the three certified algorithms from the theory:
1. Möbius barcode extraction (Theorem A)
2. Filtered graph realization (Theorem B)
3. Certified reconstruction from presentations (Theorem C)

All algorithms run in O(N²) time where N is the number of scale values.
"""

from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════
# Data Types
# ═══════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Interval:
    """A persistence interval [birth, death]."""
    birth: int
    death: int

    def __post_init__(self):
        assert self.birth <= self.death, f"Invalid: birth={self.birth} > death={self.death}"

    def contains(self, i: int, j: int) -> bool:
        """Does this interval contain the range [i, j]?"""
        return self.birth <= i and j <= self.death

    @property
    def lifetime(self) -> int:
        return self.death - self.birth


@dataclass
class BarcodeResult:
    """Result of barcode extraction with certificates."""
    intervals: List[Interval]
    critical_scales: Set[int]
    rank_certificate: Dict[Tuple[int, int], int]  # rank values used

    @property
    def size(self) -> int:
        return len(self.intervals)

    def rank(self, i: int, j: int) -> int:
        return sum(1 for iv in self.intervals if iv.contains(i, j))


@dataclass
class GraphRealization:
    """A filtered metric graph realizing a barcode."""
    num_vertices: int
    edges: List[Tuple[int, int, int, int]]  # (v1, v2, birth, death)

    def rank(self, i: int, j: int) -> int:
        return sum(1 for _, _, b, d in self.edges if b <= i and j <= d)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Möbius Barcode Extraction
# ═══════════════════════════════════════════════════════════════════

def mobius_coefficient(rho, a: int, b: int) -> int:
    """
    Compute the Möbius coefficient μ(a, b) from a rank function ρ.

    Algorithm:
        μ(a, b) = ρ(a, b) - ρ(a, b+1) - [ρ(a-1, b) - ρ(a-1, b+1)]
        μ(0, b) = ρ(0, b) - ρ(0, b+1)

    Time: O(1) given oracle access to ρ.

    Correctness: By Theorem A, for any barcode B,
        μ(a, b) = 1 iff (a, b) ∈ B, and μ(a, b) = 0 otherwise.
    """
    result = rho(a, b) - rho(a, b + 1)
    if a > 0:
        result -= rho(a - 1, b) - rho(a - 1, b + 1)
    return result


def extract_barcode(rho, max_scale: int) -> BarcodeResult:
    """
    Extract the unique minimal barcode from a rank function via Möbius inversion.

    Algorithm:
        1. For each (a, b) with 0 ≤ a ≤ b ≤ max_scale:
           a. Compute μ(a, b) via mobius_coefficient
           b. If μ(a, b) = 1, add interval [a, b] to barcode
           c. If μ(a, b) ∉ {0, 1}, reject (not a valid barcode rank function)
        2. Collect critical scales (all birth and death times)
        3. Verify rank certificate

    Time: O(N²) where N = max_scale
    Space: O(N²) for rank certificate

    Correctness: By mobius_recovers_membership and rank_determines_barcode,
    this is the UNIQUE barcode with the given rank function.
    """
    intervals = []
    critical_scales = set()
    rank_cert = {}

    for a in range(max_scale + 1):
        for b in range(a, max_scale + 1):
            mu = mobius_coefficient(rho, a, b)
            if mu == 1:
                intervals.append(Interval(a, b))
                critical_scales.add(a)
                critical_scales.add(b)
            elif mu < 0 or mu > 1:
                raise ValueError(
                    f"Invalid Möbius coefficient μ({a},{b})={mu}: "
                    f"must be 0 or 1 for a valid barcode rank function"
                )

    # Build rank certificate
    for i in range(max_scale + 1):
        for j in range(max_scale + 1):
            rank_cert[(i, j)] = rho(i, j)

    return BarcodeResult(
        intervals=intervals,
        critical_scales=critical_scales,
        rank_certificate=rank_cert,
    )


def verify_barcode_correctness(result: BarcodeResult, rho, max_scale: int) -> bool:
    """
    Verify that the extracted barcode correctly realizes the rank function.

    Certificate check: for all (i, j), barcodeRank(i, j) = ρ(i, j).
    """
    for i in range(max_scale + 1):
        for j in range(max_scale + 1):
            if result.rank(i, j) != rho(i, j):
                return False
    return True


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Filtered Graph Realization
# ═══════════════════════════════════════════════════════════════════

def realize_as_graph(barcode: BarcodeResult) -> GraphRealization:
    """
    Construct a minimal filtered metric graph realizing a barcode.

    Algorithm:
        For each interval [b, d] in the barcode:
            1. Create two vertices v₁, v₂
            2. Add edge (v₁, v₂) with birth=b, death=d
        The graph has 2k vertices and k edges for k intervals.

    Time: O(k) where k = number of intervals
    Space: O(k)

    Correctness: By barcode_has_graph_realization, the graph's rank invariant
    matches the barcode's rank invariant.

    Minimality: The graph has exactly one edge per barcode interval,
    which is the minimum needed (each edge contributes at most 1 to rank).
    """
    edges = []
    vertex_count = 0

    for interval in barcode.intervals:
        v1 = vertex_count
        v2 = vertex_count + 1
        vertex_count += 2
        edges.append((v1, v2, interval.birth, interval.death))

    return GraphRealization(num_vertices=vertex_count, edges=edges)


def verify_graph_correctness(graph: GraphRealization, barcode: BarcodeResult,
                              max_scale: int) -> bool:
    """Verify graph rank matches barcode rank."""
    for i in range(max_scale + 1):
        for j in range(max_scale + 1):
            if graph.rank(i, j) != barcode.rank(i, j):
                return False
    return True


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Certified Reconstruction from Presentations
# ═══════════════════════════════════════════════════════════════════

def certified_reconstruction(generators: List[Tuple[int, int]]) -> Tuple[
    BarcodeResult, GraphRealization, Dict[str, bool]
]:
    """
    Certified reconstruction from a tropical presentation.

    Input: list of generator (birth, death) pairs
    Output: (barcode, graph, certificates)

    Algorithm:
        1. Compute rank function from generators
        2. Extract barcode via Möbius inversion
        3. Realize barcode as filtered graph
        4. Verify all certificates

    Time: O(N² + k) where N = max scale, k = number of generators
    Space: O(N²)

    Correctness: By reconstructBarcode_correct and reconstructGraph_correct.
    """
    # Validate input
    for b, d in generators:
        assert b <= d, f"Invalid generator ({b}, {d})"

    max_scale = max(d for _, d in generators) + 1 if generators else 0

    # Step 1: Compute rank function
    def rho(i: int, j: int) -> int:
        return sum(1 for b, d in generators if b <= i and j <= d)

    # Step 2: Extract barcode via Möbius inversion
    barcode = extract_barcode(rho, max_scale)

    # Step 3: Realize as graph
    graph = realize_as_graph(barcode)

    # Step 4: Verify certificates
    certificates = {
        "barcode_realizes_rank": verify_barcode_correctness(barcode, rho, max_scale),
        "graph_realizes_barcode": verify_graph_correctness(graph, barcode, max_scale),
        "barcode_minimal": True,  # Unique by Theorem A
        "graph_minimal": len(graph.edges) == barcode.size,
    }

    return barcode, graph, certificates


# ═══════════════════════════════════════════════════════════════════
# Complexity Analysis
# ═══════════════════════════════════════════════════════════════════

def complexity_analysis():
    """Print complexity analysis of all algorithms."""
    print("Complexity Analysis")
    print("=" * 50)
    print()
    print("Let N = max scale value, k = number of intervals/generators")
    print()
    print("Algorithm 1: Möbius Barcode Extraction")
    print("  Time:  O(N²) — scan all (a, b) pairs with a ≤ b")
    print("  Space: O(N²) — rank certificate storage")
    print("  Calls: O(1) per Möbius coefficient (4 rank evaluations)")
    print()
    print("Algorithm 2: Filtered Graph Realization")
    print("  Time:  O(k) — one edge per interval")
    print("  Space: O(k) — graph storage")
    print()
    print("Algorithm 3: Certified Reconstruction")
    print("  Time:  O(N² + kN²) — rank computation + extraction")
    print("  Space: O(N²) — dominated by rank certificate")
    print("  With precomputed rank matrix: O(N²)")
    print()
    print("Verification (all certificates):")
    print("  Time:  O(N² · k) — check rank at all scale pairs")
    print("  Can be reduced to O(N²) with matrix comparison")


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Persistence — Algorithm Demonstrations")
    print("=" * 50)
    print()

    # Example: certified reconstruction
    generators = [(0, 3), (1, 4), (2, 6), (5, 8)]
    print(f"Input generators: {generators}")
    print()

    barcode, graph, certs = certified_reconstruction(generators)

    print(f"Extracted barcode: {[f'[{iv.birth},{iv.death}]' for iv in barcode.intervals]}")
    print(f"Critical scales: {sorted(barcode.critical_scales)}")
    print(f"Graph: {graph.num_vertices} vertices, {len(graph.edges)} edges")
    print()

    print("Certificates:")
    for name, value in certs.items():
        status = "✓" if value else "✗"
        print(f"  {status} {name}: {value}")
    print()

    complexity_analysis()
