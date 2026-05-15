#!/usr/bin/env python3
"""
Tropical Entanglement Wedge — Algorithms

Implements the core algorithms from the tropical holographic reconstruction
theory, including wedge computation, boundary observation, and surgery
detectability analysis.
"""

import numpy as np
from typing import Set, Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class TropicalGraph:
    """A finite weighted graph for tropical holographic analysis.

    Attributes:
        n: Number of vertices
        dist: Distance matrix (n × n)
        boundary: Set of boundary vertex indices
        bulk: Set of bulk vertex indices
    """
    n: int
    dist: np.ndarray
    boundary: Set[int]
    bulk: Set[int]

    @classmethod
    def from_edges(cls, n: int, boundary: Set[int],
                   edges: List[Tuple[int, int, float]]) -> 'TropicalGraph':
        """Construct from edge list. Computes shortest-path distances.

        Args:
            n: Number of vertices
            boundary: Set of boundary vertex indices
            edges: List of (u, v, weight) tuples

        Returns:
            TropicalGraph with Floyd-Warshall shortest-path distances

        Complexity: O(n³) time, O(n²) space
        """
        dist = np.full((n, n), np.inf)
        np.fill_diagonal(dist, 0.0)
        for u, v, w in edges:
            dist[u][v] = min(dist[u][v], w)
            dist[v][u] = min(dist[v][u], w)

        # Floyd-Warshall: O(n³)
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if dist[i][k] + dist[k][j] < dist[i][j]:
                        dist[i][j] = dist[i][k] + dist[k][j]

        bulk = set(range(n)) - boundary
        return cls(n=n, dist=dist, boundary=boundary, bulk=bulk)


def dist_to_finset(dist: np.ndarray, s: Set[int], v: int) -> float:
    """Compute min-plus distance from vertex v to set s.

    d_S(v) = min_{b ∈ S} dist(v, b)

    Complexity: O(|S|)
    """
    return min(dist[v][b] for b in s)


def entanglement_wedge(graph: TropicalGraph, B: Set[int]) -> Set[int]:
    """Compute the entanglement wedge of boundary subset B.

    Wedge(B) = {v ∈ bulk | d_B(v) < d_{Bc}(v)}

    where Bc = boundary \\ B.

    This is the set of bulk vertices strictly closer to B than to
    the boundary complement, forming a tropical Voronoi cell.

    Args:
        graph: The tropical graph
        B: Subset of boundary vertices

    Returns:
        Set of bulk vertices in the wedge

    Complexity: O(|bulk| · |boundary|)
    """
    Bc = graph.boundary - B
    if not B or not Bc:
        return graph.bulk.copy() if not B else set()

    wedge = set()
    for v in graph.bulk:
        dB = dist_to_finset(graph.dist, B, v)
        dBc = dist_to_finset(graph.dist, Bc, v)
        if dB < dBc:
            wedge.add(v)
    return wedge


def wedge_gap(graph: TropicalGraph, B: Set[int], v: int) -> float:
    """Compute the separation gap δ_v = d_{Bc}(v) - d_B(v).

    Positive gap means v is in the wedge. The magnitude measures
    robustness: the wedge membership is stable under perturbations
    of size ε < δ_v/2.

    Complexity: O(|boundary|)
    """
    Bc = graph.boundary - B
    if not B or not Bc:
        return float('inf')
    dB = dist_to_finset(graph.dist, B, v)
    dBc = dist_to_finset(graph.dist, Bc, v)
    return dBc - dB


def boundary_obs(graph: TropicalGraph, phi: Dict[int, float],
                 b: int) -> float:
    """Compute boundary observation at boundary point b.

    Obs(φ)(b) = min_{v ∈ bulk} (φ(v) + dist(v, b))

    This is the tropical convolution / distance transform.

    Complexity: O(|bulk|)
    """
    return min(phi[v] + graph.dist[v][b] for v in graph.bulk)


def full_boundary_profile(graph: TropicalGraph, phi: Dict[int, float],
                          B: Set[int]) -> Dict[int, float]:
    """Compute the full boundary observation profile on B.

    Returns Obs_B(φ)(b) for each b ∈ B.

    Complexity: O(|B| · |bulk|)
    """
    return {b: boundary_obs(graph, phi, b) for b in B}


def unique_argmin_witness(graph: TropicalGraph, phi: Dict[int, float],
                          b: int) -> Optional[Tuple[int, float]]:
    """Find the unique argmin witness at boundary point b, if it exists.

    Returns (v*, gap) where v* achieves the minimum of φ(v) + d(v,b)
    and gap is the difference to the second-best vertex.
    Returns None if the minimum is not uniquely achieved.

    Complexity: O(|bulk|)
    """
    vals = [(phi[v] + graph.dist[v][b], v) for v in graph.bulk]
    vals.sort()
    if len(vals) < 1:
        return None
    if len(vals) == 1:
        return (vals[0][1], float('inf'))
    if abs(vals[0][0] - vals[1][0]) < 1e-12:
        return None  # tie
    return (vals[0][1], vals[1][0] - vals[0][0])


def detect_surgery(graph: TropicalGraph, phi: Dict[int, float],
                   phi_prime: Dict[int, float],
                   B: Set[int]) -> List[Tuple[int, float, float]]:
    """Detect where a surgery is visible from boundary subset B.

    Returns list of (b, obs_original, obs_new) for each b ∈ B
    where the observation changed.

    Complexity: O(|B| · |bulk|)
    """
    detections = []
    for b in sorted(B):
        obs_orig = boundary_obs(graph, phi, b)
        obs_new = boundary_obs(graph, phi_prime, b)
        if abs(obs_orig - obs_new) > 1e-12:
            detections.append((b, obs_orig, obs_new))
    return detections


def perturbation_stability_radius(graph: TropicalGraph,
                                  B: Set[int]) -> Dict[int, float]:
    """Compute the stability radius for each wedge vertex.

    For each v in Wedge(B), returns ε_max = gap(v)/2,
    the maximum perturbation that preserves wedge membership.

    Complexity: O(|bulk| · |boundary|)
    """
    radii = {}
    for v in graph.bulk:
        gap = wedge_gap(graph, B, v)
        if gap > 0:
            radii[v] = gap / 2.0
    return radii


def tropical_voronoi_decomposition(graph: TropicalGraph) -> Dict[int, Set[int]]:
    """Compute tropical Voronoi decomposition of bulk w.r.t. boundary.

    Assigns each bulk vertex to its nearest boundary vertex.
    Ties are broken arbitrarily.

    Returns: Dict mapping boundary vertex → set of bulk vertices

    Complexity: O(|bulk| · |boundary|)
    """
    cells = {b: set() for b in graph.boundary}
    for v in graph.bulk:
        nearest = min(graph.boundary, key=lambda b: graph.dist[v][b])
        cells[nearest].add(v)
    return cells


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Build a small graph
    edges = [
        (0, 4, 1.0), (1, 4, 2.0), (2, 5, 1.0), (3, 5, 2.0),
        (4, 5, 3.0), (0, 5, 5.0), (1, 5, 6.0), (2, 4, 5.0), (3, 4, 6.0)
    ]
    G = TropicalGraph.from_edges(n=6, boundary={0, 1, 2, 3}, edges=edges)
    B = {0, 1}

    print("=== Tropical Entanglement Wedge Analysis ===\n")
    print(f"Graph: {G.n} vertices, boundary={G.boundary}, bulk={G.bulk}")
    print(f"Boundary subset B = {B}")

    # Compute wedge
    W = entanglement_wedge(G, B)
    print(f"\nEntanglement Wedge(B) = {W}")

    # Gaps
    print("\nVertex gaps (δ_v = d_Bc(v) - d_B(v)):")
    for v in sorted(G.bulk):
        gap = wedge_gap(G, B, v)
        print(f"  v={v}: gap = {gap:.3f}, in_wedge = {v in W}")

    # Stability radii
    radii = perturbation_stability_radius(G, B)
    print(f"\nStability radii (ε_max = gap/2):")
    for v, r in sorted(radii.items()):
        print(f"  v={v}: ε_max = {r:.3f}")

    # Boundary observations
    phi = {v: 0.0 for v in G.bulk}
    print(f"\nBulk state φ = {phi}")
    prof = full_boundary_profile(G, phi, B)
    print(f"Boundary profile Obs_B(φ) = {prof}")

    # Surgery detectability
    phi_prime = {4: 2.0, 5: 0.0}
    print(f"\nSurgery: φ' = {phi_prime}")
    detections = detect_surgery(G, phi, phi_prime, B)
    print(f"Detections: {len(detections)} boundary points changed")
    for b, orig, new in detections:
        print(f"  b={b}: {orig:.2f} → {new:.2f}")

    # Voronoi decomposition
    voronoi = tropical_voronoi_decomposition(G)
    print(f"\nTropical Voronoi decomposition:")
    for b, cell in sorted(voronoi.items()):
        if cell:
            print(f"  boundary {b} → bulk {cell}")
