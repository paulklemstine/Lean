"""
Citation Complex Algorithms: Constructing and Analyzing Theorem Networks

Type-hinted implementations for building citation complexes, computing
topological invariants, and analyzing depth filtrations.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import FrozenSet, Dict, List, Set, Tuple
from itertools import combinations
from collections import Counter


@dataclass
class CitationNetwork:
    """A citation network: theorems and their citation relationships."""
    theorems: List[str]
    cites: Dict[str, Set[str]]  # theorem -> set of cited theorems

    def degree(self, v: str) -> int:
        """Citation degree (out-degree) of a theorem."""
        return len(self.cites.get(v, set()))

    def cociter_set(self, sigma: FrozenSet[str]) -> Set[str]:
        """All theorems that cite every element of sigma."""
        return {t for t in self.theorems if sigma <= self.cites.get(t, set())}

    def depth(self, sigma: FrozenSet[str]) -> int:
        """Citation depth: number of theorems that cite all of sigma."""
        return len(self.cociter_set(sigma))

    def is_face(self, sigma: FrozenSet[str]) -> bool:
        """Check if sigma is a face of the citation complex."""
        return len(sigma) > 0 and len(self.cociter_set(sigma)) > 0


@dataclass
class CitationComplex:
    """The citation complex: an abstract simplicial complex from citations."""
    network: CitationNetwork
    faces: Set[FrozenSet[str]] = field(default_factory=set)
    f_vector: Dict[int, int] = field(default_factory=dict)

    @classmethod
    def from_network(cls, network: CitationNetwork) -> CitationComplex:
        """Build the citation complex from a citation network.

        Algorithm:
        1. For each theorem t, enumerate all nonempty subsets of cites(t)
        2. Each such subset is a face
        3. Compute the f-vector (face counts by dimension)
        """
        faces: Set[FrozenSet[str]] = set()
        for t in network.theorems:
            cited = list(network.cites.get(t, set()))
            for k in range(1, len(cited) + 1):
                for combo in combinations(cited, k):
                    faces.add(frozenset(combo))

        f_vector: Dict[int, int] = Counter()
        for face in faces:
            dim = len(face) - 1
            f_vector[dim] += 1

        return cls(network=network, faces=faces, f_vector=dict(f_vector))

    def dimension(self) -> int:
        """Maximum dimension of any face."""
        if not self.faces:
            return -1
        return max(len(f) - 1 for f in self.faces)

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic: alternating sum of face counts."""
        chi = 0
        for dim, count in self.f_vector.items():
            chi += ((-1) ** dim) * count
        return chi

    def vertices(self) -> Set[str]:
        """All vertices (0-faces) of the complex."""
        return {v for f in self.faces for v in f}


@dataclass
class DepthFiltration:
    """A depth filtration of the citation complex.

    At filtration level d, include only faces with depth >= d.
    This gives a decreasing sequence of subcomplexes.
    """
    network: CitationNetwork
    max_depth: int
    levels: Dict[int, Set[FrozenSet[str]]] = field(default_factory=dict)

    @classmethod
    def from_network(cls, network: CitationNetwork) -> DepthFiltration:
        """Build the depth filtration.

        Algorithm:
        1. Build the full citation complex
        2. For each face, compute its depth
        3. Group faces by their depth threshold
        """
        complex = CitationComplex.from_network(network)
        depth_map: Dict[FrozenSet[str], int] = {}
        for face in complex.faces:
            depth_map[face] = network.depth(face)

        max_depth = max(depth_map.values()) if depth_map else 0
        levels: Dict[int, Set[FrozenSet[str]]] = {}
        for d in range(1, max_depth + 1):
            levels[d] = {f for f, depth in depth_map.items() if depth >= d}

        return cls(network=network, max_depth=max_depth, levels=levels)

    def betti_0_estimate(self, d: int) -> int:
        """Estimate β₀ (connected components) at filtration level d.

        Uses union-find to count connected components among 1-faces
        at depth >= d.
        """
        if d not in self.levels:
            return 0
        faces_at_d = self.levels[d]
        vertices = {v for f in faces_at_d for v in f if len(f) == 1}
        edges = {f for f in faces_at_d if len(f) == 2}

        # Union-find
        parent: Dict[str, str] = {v: v for v in vertices}

        def find(x: str) -> str:
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x: str, y: str) -> None:
            rx, ry = find(x), find(y)
            if rx != ry:
                parent[rx] = ry

        for edge in edges:
            u, v = list(edge)
            if u in parent and v in parent:
                union(u, v)

        if not vertices:
            return 0
        return len({find(v) for v in vertices})


def compute_f_vector_bound(network: CitationNetwork, k: int) -> int:
    """Upper bound on f_k from the f-vector bound theorem.

    f_k <= sum over all theorems t of C(degree(t), k+1)
    """
    from math import comb
    bound = 0
    for t in network.theorems:
        deg = network.degree(t)
        bound += comb(deg, k + 1)
    return bound


def euler_contribution(d: int) -> int:
    """The Euler contribution of a citation neighborhood of size d.

    Proved to equal 1 for d >= 1 (binomial theorem).
    """
    if d == 0:
        return 0
    from math import comb
    return sum((-1)**k * comb(d, k+1) for k in range(d))


# --- Example construction ---

def build_example_network() -> CitationNetwork:
    """Build an example citation network modeling a small mathematical community.

    Network structure:
    - 8 theorems in two loosely connected clusters
    - Cluster 1 (Algebra): A1, A2, A3, A4
    - Cluster 2 (Topology): T1, T2, T3, T4
    - Bridge theorems that cite across clusters
    """
    theorems = ["A1", "A2", "A3", "A4", "T1", "T2", "T3", "T4"]
    cites = {
        "A1": set(),                      # Foundational, cites nothing
        "A2": {"A1"},                      # Builds on A1
        "A3": {"A1", "A2"},               # Builds on A1, A2
        "A4": {"A1", "A2", "A3"},          # Survey of algebra cluster
        "T1": set(),                      # Foundational topology
        "T2": {"T1"},                      # Builds on T1
        "T3": {"T1", "T2"},               # Builds on T1, T2
        "T4": {"T1", "T2", "T3", "A1"},   # Bridge: connects both clusters
    }
    return CitationNetwork(theorems=theorems, cites=cites)


if __name__ == "__main__":
    # Verify euler_contribution theorem computationally
    for d in range(1, 20):
        assert euler_contribution(d) == 1, f"Failed for d={d}"
    print("✓ Euler contribution = 1 for all d in [1, 19]")
