#!/usr/bin/env python3
"""
Algorithms for Electrical Flow Certificates on Cayley Graphs

Implements:
  1. Cayley graph construction from generators
  2. Effective resistance computation via Laplacian pseudoinverse
  3. Canonical path congestion computation
  4. Unit flow construction and energy computation
  5. Resistance certificate verification

All algorithms work for arbitrary finite groups given as permutation groups.

Complexity Analysis:
  - Cayley graph construction: O(|G| · |S|)
  - Laplacian pseudoinverse: O(|G|^3)  [dense linear algebra]
  - Canonical path congestion: O(|G|^2 · L) where L = max path length
  - Flow energy: O(|G|^2)
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import numpy as np


# ─────────────────────────────────────────────────────────────────────
# Type aliases
# ─────────────────────────────────────────────────────────────────────
Perm = Tuple[int, ...]
Edge = Tuple[int, int]


# ─────────────────────────────────────────────────────────────────────
# 1. Permutation group utilities
# ─────────────────────────────────────────────────────────────────────
def identity(n: int) -> Perm:
    """Identity permutation of {0, ..., n-1}."""
    return tuple(range(n))


def compose(a: Perm, b: Perm) -> Perm:
    """Compose permutations: (a ∘ b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(len(a)))


def inverse(p: Perm) -> Perm:
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def adjacent_transpositions(n: int) -> List[Perm]:
    """Adjacent transpositions (i, i+1) for S_n."""
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens


# ─────────────────────────────────────────────────────────────────────
# 2. Cayley graph construction
# ─────────────────────────────────────────────────────────────────────
class CayleyGraph:
    """Cayley graph of a finite group with given generators.

    Attributes:
        n: degree of the permutation group
        elements: list of all group elements
        elem_to_idx: mapping from element to index
        generators: list of generators
        adjacency: adjacency matrix (numpy array)
        num_vertices: number of vertices = |G|
        degree: degree of each vertex = |S|
    """

    def __init__(self, n: int, generators: Optional[List[Perm]] = None):
        """Build Cayley graph of S_n with given generators.

        Args:
            n: size of permutation group S_n
            generators: list of generators (default: adjacent transpositions)
        """
        self.n = n
        self.generators = generators or adjacent_transpositions(n)

        # Generate all elements by BFS
        self.elements = []
        visited: Set[Perm] = set()
        queue = [identity(n)]
        visited.add(identity(n))

        while queue:
            current = queue.pop(0)
            self.elements.append(current)
            for g in self.generators:
                for next_elem in [compose(g, current), compose(current, g)]:
                    if next_elem not in visited:
                        visited.add(next_elem)
                        queue.append(next_elem)

        self.elem_to_idx = {e: i for i, e in enumerate(self.elements)}
        self.num_vertices = len(self.elements)
        self.degree = len(self.generators)

        # Build adjacency matrix
        self.adjacency = np.zeros((self.num_vertices, self.num_vertices), dtype=float)
        for g in self.elements:
            gi = self.elem_to_idx[g]
            for s in self.generators:
                sg = compose(s, g)
                si = self.elem_to_idx[sg]
                self.adjacency[gi][si] = 1

    def laplacian(self) -> np.ndarray:
        """Graph Laplacian L = D - A."""
        D = np.diag(self.adjacency.sum(axis=1))
        return D - self.adjacency

    def effective_resistance_matrix(self) -> np.ndarray:
        """Compute all pairwise effective resistances.

        Uses the formula R(i,j) = L†(i,i) + L†(j,j) - 2L†(i,j)
        where L† is the Moore-Penrose pseudoinverse of the Laplacian.

        Complexity: O(|G|^3) for the pseudoinverse.
        """
        L = self.laplacian()
        L_pinv = np.linalg.pinv(L)
        n = self.num_vertices
        R = np.zeros((n, n))
        diag = np.diag(L_pinv)
        for i in range(n):
            for j in range(n):
                R[i][j] = diag[i] + diag[j] - 2 * L_pinv[i][j]
        return R


# ─────────────────────────────────────────────────────────────────────
# 3. Canonical path system (bubble-sort)
# ─────────────────────────────────────────────────────────────────────
class CanonicalPathSystem:
    """Bubble-sort canonical path system for symmetric group Cayley graphs.

    For each pair (src, dst), the canonical path is the bubble-sort
    sorting sequence applied to dst · src^{-1}, then left-translated.
    """

    def __init__(self, graph: CayleyGraph):
        self.graph = graph

    def bubble_sort_generators(self, perm: Perm) -> List[Perm]:
        """Return the sequence of adjacent transpositions that sorts perm."""
        n = len(perm)
        p = list(perm)
        path = []
        for i in range(n):
            for j in range(n - 1 - i):
                if p[j] > p[j + 1]:
                    p[j], p[j + 1] = p[j + 1], p[j]
                    swap = list(range(n))
                    swap[j], swap[j + 1] = swap[j + 1], swap[j]
                    path.append(tuple(swap))
        return path

    def canonical_path(self, src: Perm, dst: Perm) -> Tuple[List[Perm], List[Perm]]:
        """Compute the canonical path from src to dst.

        Returns:
            (vertices, generators): the vertex sequence and generator sequence
        """
        diff = compose(dst, inverse(src))
        swaps = self.bubble_sort_generators(inverse(diff))
        vertices = [src]
        current = src
        for s in swaps:
            current = compose(s, current)
            vertices.append(current)
        return vertices, swaps

    def compute_congestion(self) -> Tuple[int, Dict[Edge, int]]:
        """Compute the edge congestion of this path system.

        Returns:
            (max_congestion, edge_usage): maximum edge load and per-edge counts

        Complexity: O(|G|^2 · L) where L is max path length
        """
        edge_usage: Dict[Edge, int] = defaultdict(int)
        elements = self.graph.elements
        idx = self.graph.elem_to_idx

        for src in elements:
            for dst in elements:
                if src == dst:
                    continue
                vertices, _ = self.canonical_path(src, dst)
                for i in range(len(vertices) - 1):
                    u = idx[vertices[i]]
                    v = idx[vertices[i + 1]]
                    edge = (min(u, v), max(u, v))
                    edge_usage[edge] += 1

        max_congestion = max(edge_usage.values()) if edge_usage else 0
        return max_congestion, dict(edge_usage)

    def max_path_length(self) -> int:
        """Maximum path length over all pairs."""
        max_len = 0
        for src in self.graph.elements:
            for dst in self.graph.elements:
                if src == dst:
                    continue
                vertices, _ = self.canonical_path(src, dst)
                max_len = max(max_len, len(vertices) - 1)
        return max_len


# ─────────────────────────────────────────────────────────────────────
# 4. Unit flow construction and energy
# ─────────────────────────────────────────────────────────────────────
class UnitFlow:
    """A unit flow from source s to sink t on a finite graph.

    The flow satisfies:
      - Antisymmetry: current[u][v] = -current[v][u]
      - Conservation: ∑_w current[v][w] = 0 for v ≠ s, t
      - Source value: ∑_w current[s][w] = 1
    """

    def __init__(self, n_vertices: int, source: int, sink: int):
        self.n = n_vertices
        self.source = source
        self.sink = sink
        self.current = np.zeros((n_vertices, n_vertices))

    @staticmethod
    def from_path(vertices: List[int], n_vertices: int) -> 'UnitFlow':
        """Construct the unit flow that sends 1 unit along a path.

        Args:
            vertices: list of vertex indices defining the path
            n_vertices: total number of vertices in the graph

        Returns:
            UnitFlow with current 1 on forward edges, -1 on reverse
        """
        flow = UnitFlow(n_vertices, vertices[0], vertices[-1])
        for i in range(len(vertices) - 1):
            u, v = vertices[i], vertices[i + 1]
            flow.current[u][v] += 1
            flow.current[v][u] -= 1
        return flow

    def energy(self) -> float:
        """Compute the energy E(φ) = (1/2) ∑_{u,v} φ(u,v)²."""
        return 0.5 * np.sum(self.current ** 2)

    def verify(self, tol: float = 1e-10) -> bool:
        """Verify that this is a valid unit flow."""
        # Antisymmetry
        if not np.allclose(self.current, -self.current.T, atol=tol):
            return False
        # Conservation
        for v in range(self.n):
            net = np.sum(self.current[v])
            if v == self.source:
                if abs(net - 1.0) > tol:
                    return False
            elif v == self.sink:
                if abs(net + 1.0) > tol:
                    return False
            else:
                if abs(net) > tol:
                    return False
        return True


# ─────────────────────────────────────────────────────────────────────
# 5. Resistance certificate
# ─────────────────────────────────────────────────────────────────────
class ResistanceCertificate:
    """Certificate that congestion bounds all pairwise effective resistances.

    Verifies: κ ≥ |G| · max_{s,t} R_eff(s,t)
    """

    def __init__(self, graph: CayleyGraph, path_system: CanonicalPathSystem):
        self.graph = graph
        self.path_system = path_system
        self._R = None
        self._congestion = None

    @property
    def resistance_matrix(self) -> np.ndarray:
        if self._R is None:
            self._R = self.graph.effective_resistance_matrix()
        return self._R

    @property
    def congestion(self) -> int:
        if self._congestion is None:
            self._congestion, _ = self.path_system.compute_congestion()
        return self._congestion

    @property
    def max_resistance(self) -> float:
        return self.resistance_matrix.max()

    @property
    def bound(self) -> float:
        """Upper bound on max resistance from congestion."""
        return self.congestion / self.graph.num_vertices

    def verify(self) -> bool:
        """Check that κ / |G| ≥ max R_eff."""
        return self.bound >= self.max_resistance - 1e-10

    def report(self) -> Dict:
        """Generate a full verification report."""
        return {
            'group_order': self.graph.num_vertices,
            'num_generators': self.graph.degree,
            'congestion': self.congestion,
            'max_resistance': self.max_resistance,
            'bound': self.bound,
            'ratio': self.congestion / (self.graph.num_vertices * self.max_resistance),
            'verified': self.verify()
        }


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    for n in [3, 4]:
        print(f"\n=== S_{n} with adjacent transpositions ===")
        G = CayleyGraph(n)
        paths = CanonicalPathSystem(G)
        cert = ResistanceCertificate(G, paths)
        report = cert.report()

        for k, v in report.items():
            if isinstance(v, float):
                print(f"  {k}: {v:.6f}")
            else:
                print(f"  {k}: {v}")
