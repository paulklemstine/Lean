"""
Algorithms for Primewise Persistent Homology and Isogeny Volcano Depth Detection.

This module implements the core algorithms for:
1. Building l-isogeny volcano graphs
2. Computing BFS neighborhood complexes
3. Extracting persistence barcodes (H₁)
4. Classifying volcano depth from topological invariants

Type-hinted throughout for clarity and integration.
"""

from typing import List, Dict, Tuple, Set, Optional
from collections import defaultdict, deque
import math


# ---------------------------------------------------------------------------
# Data Structures
# ---------------------------------------------------------------------------

class VolcanoGraph:
    """Represents an l-isogeny volcano graph."""

    def __init__(self, l: int, crater_size: int, max_depth: int):
        self.l = l
        self.crater_size = crater_size
        self.max_depth = max_depth
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.depth: Dict[int, int] = {}
        self.vertices: Set[int] = set()
        self._build()

    def _build(self) -> None:
        """Build the volcano graph layer by layer."""
        vertex_id = 0

        # Crater: cycle of crater_size vertices
        crater_vertices = []
        for i in range(self.crater_size):
            self.vertices.add(vertex_id)
            self.depth[vertex_id] = 0
            crater_vertices.append(vertex_id)
            vertex_id += 1

        # Connect crater as cycle
        for i in range(self.crater_size):
            u = crater_vertices[i]
            v = crater_vertices[(i + 1) % self.crater_size]
            self.adj[u].add(v)
            self.adj[v].add(u)

        # Build descending layers
        current_layer = crater_vertices
        for d in range(1, self.max_depth + 1):
            next_layer = []
            for parent in current_layer:
                # Each parent has l children (descending edges)
                for _ in range(self.l):
                    child = vertex_id
                    vertex_id += 1
                    self.vertices.add(child)
                    self.depth[child] = d
                    self.adj[parent].add(child)
                    self.adj[child].add(parent)
                    next_layer.append(child)
            current_layer = next_layer

    def total_vertices(self) -> int:
        return len(self.vertices)

    def get_vertices_at_depth(self, d: int) -> List[int]:
        return [v for v in self.vertices if self.depth[v] == d]


class NeighborhoodComplex:
    """BFS neighborhood complex with vertex/edge counts at each radius."""

    def __init__(self, graph: VolcanoGraph, center: int, max_radius: int):
        self.center = center
        self.max_radius = max_radius
        self.center_depth = graph.depth[center]
        self.vertex_counts: List[int] = []
        self.edge_counts: List[int] = []
        self._compute(graph)

    def _compute(self, graph: VolcanoGraph) -> None:
        """BFS from center, recording vertex/edge counts at each radius."""
        visited: Set[int] = {self.center}
        current_boundary: Set[int] = {self.center}
        all_edges: Set[Tuple[int, int]] = set()

        for r in range(self.max_radius + 1):
            # Count vertices
            self.vertex_counts.append(len(visited))

            # Count edges within visited set
            edges_in_ball = set()
            for v in visited:
                for u in graph.adj[v]:
                    if u in visited:
                        edge = (min(u, v), max(u, v))
                        edges_in_ball.add(edge)
            self.edge_counts.append(len(edges_in_ball))

            # Expand BFS
            next_boundary: Set[int] = set()
            for v in current_boundary:
                for u in graph.adj[v]:
                    if u not in visited:
                        next_boundary.add(u)
                        visited.add(u)
            current_boundary = next_boundary

    def cycle_rank(self, r: int) -> int:
        """First Betti number β₁ at radius r."""
        if r >= len(self.vertex_counts):
            r = len(self.vertex_counts) - 1
        return max(0, self.edge_counts[r] - self.vertex_counts[r] + 1)

    def first_cycle_birth(self) -> Optional[int]:
        """First radius where β₁ > 0."""
        for r in range(len(self.vertex_counts)):
            if self.cycle_rank(r) > 0:
                return r
        return None

    def persistence_bar_length(self) -> Optional[int]:
        """Length of first persistence bar: max_radius - first_cycle_birth."""
        fcb = self.first_cycle_birth()
        if fcb is None:
            return None
        return self.max_radius - fcb


# ---------------------------------------------------------------------------
# Core Algorithms
# ---------------------------------------------------------------------------

def depth_prediction(graph: VolcanoGraph, vertex: int,
                     max_radius: int = 10,
                     crater_cycle_radius: int = 1) -> Optional[int]:
    """
    Predict volcano depth from BFS neighborhood topology.

    Algorithm:
    1. Build BFS neighborhood complex K(v) up to radius max_radius
    2. Compute cycle rank β₁(B_r(v)) at each radius r
    3. Return (first r where β₁ > 0) - crater_cycle_radius

    The crater_cycle_radius is ⌈crater_size/2⌉ for a crater that is
    a cycle of crater_size vertices. For crater_size=3 (triangle),
    this is 1. For crater_size=4, this is 2.

    Returns: predicted depth, or None if no cycle found
    """
    cx = NeighborhoodComplex(graph, vertex, max_radius)
    fcb = cx.first_cycle_birth()
    if fcb is None:
        return None
    return max(0, fcb - crater_cycle_radius)


def classify_all_vertices(graph: VolcanoGraph,
                          max_radius: int = 10,
                          crater_cycle_radius: int = 1) -> Dict[int, Optional[int]]:
    """Classify all vertices by predicted depth."""
    results: Dict[int, Optional[int]] = {}
    for v in graph.vertices:
        results[v] = depth_prediction(graph, v, max_radius, crater_cycle_radius)
    return results


def compute_accuracy(graph: VolcanoGraph,
                     max_radius: int = 10,
                     crater_cycle_radius: int = 1) -> Tuple[float, int, int]:
    """
    Compute classification accuracy.

    Returns: (accuracy, correct, total)
    """
    predictions = classify_all_vertices(graph, max_radius, crater_cycle_radius)
    correct = 0
    total = 0
    for v, pred in predictions.items():
        total += 1
        if pred == graph.depth[v]:
            correct += 1
    accuracy = correct / total if total > 0 else 0.0
    return accuracy, correct, total


def compute_persistence_barcode(graph: VolcanoGraph, vertex: int,
                                max_radius: int = 10) -> List[Tuple[int, int]]:
    """
    Compute H₁ persistence barcode for the neighborhood filtration.

    Returns list of (birth, death) pairs for H₁ generators.
    """
    complex = NeighborhoodComplex(graph, vertex, max_radius)
    barcode: List[Tuple[int, int]] = []

    prev_rank = 0
    for r in range(max_radius + 1):
        curr_rank = complex.cycle_rank(r)
        # New cycles born at radius r
        new_cycles = curr_rank - prev_rank
        for _ in range(new_cycles):
            barcode.append((r, max_radius))
        prev_rank = curr_rank

    return barcode


def subtree_size(l: int, r: int) -> int:
    """Geometric sum: 1 + l + l² + ... + l^r."""
    if l == 1:
        return r + 1
    return (l ** (r + 1) - 1) // (l - 1)


def volcano_total_vertices(l: int, crater_size: int, depth: int) -> int:
    """Total number of vertices in the volcano."""
    return crater_size * subtree_size(l, depth)


def euler_characteristic(n_vertices: int, n_edges: int) -> int:
    """Euler characteristic χ = V - E."""
    return n_vertices - n_edges


# ---------------------------------------------------------------------------
# Experimental Verification
# ---------------------------------------------------------------------------

def run_experiment(l: int = 2, crater_size: int = 3,
                   max_depth: int = 4, max_radius: int = 10) -> Dict:
    """
    Run a complete experiment verifying the depth detection conjecture.

    Args:
        l: branching factor (isogeny prime)
        crater_size: number of crater vertices
        max_depth: volcano depth
        max_radius: BFS radius for classification

    Returns: experiment results dictionary
    """
    graph = VolcanoGraph(l, crater_size, max_depth)
    crater_cycle_radius = crater_size // 2
    accuracy, correct, total = compute_accuracy(graph, max_radius, crater_cycle_radius)

    # Per-depth accuracy
    depth_results: Dict[int, Dict] = {}
    for d in range(max_depth + 1):
        vertices_at_d = graph.get_vertices_at_depth(d)
        d_correct = sum(
            1 for v in vertices_at_d
            if depth_prediction(graph, v, max_radius, crater_cycle_radius) == d
        )
        depth_results[d] = {
            "count": len(vertices_at_d),
            "correct": d_correct,
            "accuracy": d_correct / len(vertices_at_d) if vertices_at_d else 0.0
        }

    return {
        "l": l,
        "crater_size": crater_size,
        "max_depth": max_depth,
        "total_vertices": total,
        "accuracy": accuracy,
        "correct": correct,
        "depth_results": depth_results
    }


if __name__ == "__main__":
    # Quick test
    result = run_experiment(l=2, crater_size=3, max_depth=3, max_radius=10)
    print(f"Accuracy: {result['accuracy']:.2%}")
    print(f"Correct: {result['correct']}/{result['total_vertices']}")
    for d, dr in result["depth_results"].items():
        print(f"  Depth {d}: {dr['correct']}/{dr['count']} ({dr['accuracy']:.2%})")
