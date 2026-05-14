#!/usr/bin/env python3
"""
Algorithms for Tropical Graph Optimization

Implements the core algorithms formalized in the Lean 4 proofs:
1. Bellman-Ford tropical shortest path (DP formulation)
2. Hexagonal lattice geometry and boundary computation
3. Kardashev index computation and capacity bounds
4. Tropical matrix closure (Kleene star)

All algorithms correspond to theorems proved in the formal verification:
- bellman_ford_tropical ↔ dpDist / tropicalDist
- hex_patch / edge_boundary ↔ hexPatch / edgeBoundary
- kardashev_bound ↔ kardashev_bound_of_capacity
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass

# ============================================================
# §1. TROPICAL ALGEBRA
# ============================================================

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ propagation)."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j]).
    
    Time complexity: O(n³) for n×n matrices.
    Space complexity: O(n²).
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C

def trop_matrix_closure(W: np.ndarray) -> np.ndarray:
    """
    Tropical Kleene star: W* = I ⊕ W ⊕ W² ⊕ ... ⊕ W^(n-1).
    
    Computes all-pairs shortest paths via repeated tropical matrix squaring.
    Equivalent to Floyd-Warshall but expressed in tropical linear algebra.
    
    Time complexity: O(n³ log n) via repeated squaring, or O(n⁴) direct.
    Space complexity: O(n²).
    
    Precondition: No negative-weight cycles.
    """
    n = W.shape[0]
    # Start with identity (0 on diagonal, ∞ elsewhere)
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0.0)
    
    # Direct computation: W^k for k = 1, ..., n-1
    power = W.copy()
    for _ in range(n - 1):
        # result = result ⊕ power
        result = np.minimum(result, power)
        power = trop_matrix_mul(power, W)
    
    return result

# ============================================================
# §2. BELLMAN-FORD TROPICAL SHORTEST PATH
# ============================================================

@dataclass
class TropicalGraph:
    """A finite weighted directed graph for tropical optimization."""
    n_vertices: int
    edges: List[Tuple[int, int, float]]
    
    def adjacency_matrix(self) -> np.ndarray:
        """Convert to tropical adjacency matrix."""
        W = np.full((self.n_vertices, self.n_vertices), INF)
        np.fill_diagonal(W, 0.0)
        for u, v, w in self.edges:
            W[u, v] = min(W[u, v], w)
        return W

def bellman_ford_tropical(
    graph: TropicalGraph, 
    source: int,
    return_predecessors: bool = False
) -> Tuple[np.ndarray, Optional[np.ndarray]]:
    """
    Bellman-Ford algorithm in the tropical semiring.
    
    Computes tropical distance (shortest path cost) from source to all vertices
    using the DP recurrence:
        dpDist(0, v) = 0 if v = source, ∞ otherwise
        dpDist(k+1, v) = min(dpDist(k, v), min_u(dpDist(k, u) + w(u,v)))
    
    This corresponds to the formal dpDist definition and the
    Bellman optimality equation proved in tropicalDist_bellman.
    
    Args:
        graph: Weighted directed graph
        source: Source vertex index
        return_predecessors: If True, also return predecessor array
    
    Returns:
        dist: Array of tropical distances from source
        pred: (Optional) predecessor array for path reconstruction
    
    Time complexity: O(V·E)
    Space complexity: O(V)
    """
    n = graph.n_vertices
    dist = np.full(n, INF)
    dist[source] = 0.0
    pred = np.full(n, -1, dtype=int)
    
    for iteration in range(n - 1):
        updated = False
        for u, v, w in graph.edges:
            new_dist = trop_mul(dist[u], w)
            if new_dist < dist[v]:
                dist[v] = new_dist
                pred[v] = u
                updated = True
        if not updated:
            break  # Stabilization achieved
    
    if return_predecessors:
        return dist, pred
    return dist, None

def reconstruct_path(pred: np.ndarray, source: int, target: int) -> List[int]:
    """Reconstruct shortest path from predecessor array."""
    if pred[target] == -1 and target != source:
        return []  # No path
    path = [target]
    current = target
    while current != source:
        current = pred[current]
        if current == -1:
            return []
        path.append(current)
    return list(reversed(path))

def tropical_capacity(graph: TropicalGraph, source: int) -> float:
    """
    Compute tropical capacity: min distance from source to any vertex.
    
    Corresponds to: tropicalCapacity w s = ⨅ v, tropicalDist w s v
    """
    dist, _ = bellman_ford_tropical(graph, source)
    non_source = [dist[v] for v in range(graph.n_vertices) if v != source]
    return min(non_source) if non_source else INF

def optimal_gain(graph: TropicalGraph, source: int, G: float) -> Tuple[float, int]:
    """
    Compute optimal gain and the vertex achieving it.
    
    Corresponds to: max_gain_eq proving ⨆ v, gainAt w s G v = G - tropicalCapacity w s
    """
    dist, _ = bellman_ford_tropical(graph, source)
    best_v = -1
    best_gain = -INF
    for v in range(graph.n_vertices):
        if v == source:
            continue
        gain = G - dist[v]
        if gain > best_gain:
            best_gain = gain
            best_v = v
    return best_gain, best_v

# ============================================================
# §3. HEXAGONAL LATTICE GEOMETRY
# ============================================================

def hex_distance(a: Tuple[int, int], b: Tuple[int, int]) -> int:
    """
    Hex distance in axial coordinates.
    
    hexDist(a, b) = max(|b.1 - a.1|, |b.2 - a.2|, |(b.1+b.2) - (a.1+a.2)|)
    
    Proved symmetric (hexDist_symm) and positive definite (hexDist_eq_zero_iff).
    """
    dq = abs(b[0] - a[0])
    dr = abs(b[1] - a[1])
    ds = abs((b[0] + b[1]) - (a[0] + a[1]))
    return max(dq, dr, ds)

def hex_neighbors(p: Tuple[int, int]) -> List[Tuple[int, int]]:
    """
    The 6 neighbors of a hex lattice point.
    
    Proved: hexNeighborsList_length (always 6),
            hexNeighborsList_nodup (no duplicates),
            mem_hexNeighborsList_iff (characterizes hexAdj).
    """
    q, r = p
    return [(q+1, r), (q-1, r), (q, r+1), (q, r-1), (q+1, r-1), (q-1, r+1)]

def hex_patch(radius: int) -> Set[Tuple[int, int]]:
    """
    Generate the hexagonal patch of given radius.
    
    hexPatch r = {p | hexDist((0,0), p) ≤ r}
    
    Proved: |hexPatch r| = 3r² + 3r + 1 (verified computationally)
    """
    points = set()
    for q in range(-radius, radius + 1):
        for s in range(-radius, radius + 1):
            if hex_distance((0, 0), (q, s)) <= radius:
                points.add((q, s))
    return points

def edge_boundary(S: Set[Tuple[int, int]]) -> int:
    """
    Edge boundary: number of directed edges from S to complement.
    
    Proved: edgeBoundary_singleton = 6
            edgeBoundary_hexPatch_zero = 6
    """
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n not in S:
                count += 1
    return count

def hex_patch_card(r: int) -> int:
    """Exact cardinality: 3r² + 3r + 1."""
    return 3 * r * r + 3 * r + 1

def hex_patch_boundary(r: int) -> int:
    """Exact edge boundary: 6(2r + 1)."""
    return 6 * (2 * r + 1)

# ============================================================
# §4. KARDASHEV INDEX AND CAPACITY BOUNDS
# ============================================================

def kardashev_norm(P: float) -> float:
    """
    Normalized Kardashev index: log₁₀(P).
    
    Proved monotone (kardashevNorm_mono): P ≤ Q ⟹ K(P) ≤ K(Q).
    """
    if P <= 0:
        return -INF
    return np.log10(P)

def shell_power(L: float, eta: float, C: float) -> float:
    """
    Optimal power from shell network.
    
    shellPower L η C = L * η * C
    
    Proved: optimal_power_le (shellPower L η C ≤ L * η when C ≤ 1)
    """
    return L * eta * C

def kardashev_bound(L: float, eta: float, C: float) -> Tuple[float, float]:
    """
    Compute Kardashev index of optimal power and its upper bound.
    
    Returns (K(P_opt), K(L*η)) where K(P_opt) ≤ K(L*η) is formally proved.
    
    Corresponds to: kardashev_bound_of_capacity theorem.
    """
    P_opt = shell_power(L, eta, C)
    P_max = L * eta
    return kardashev_norm(P_opt), kardashev_norm(P_max)

# ============================================================
# §5. EXAMPLE: DYSON SPHERE NETWORK
# ============================================================

def create_dyson_shell_network(
    n_panels: int,
    base_loss: float = 0.1,
    routing_loss: float = 0.05,
    seed: int = 42
) -> TropicalGraph:
    """
    Create a model Dyson shell network.
    
    Node 0 = star (source)
    Nodes 1..n_panels = panel sites
    
    Edge weights represent transport/conversion losses.
    """
    rng = np.random.RandomState(seed)
    edges = []
    
    # Star to panels: base loss + random variation
    for i in range(1, n_panels + 1):
        loss = base_loss + rng.uniform(0, 0.3)
        edges.append((0, i, loss))
    
    # Inter-panel routing: ring topology + random shortcuts
    for i in range(1, n_panels + 1):
        j = (i % n_panels) + 1
        edges.append((i, j, routing_loss + rng.uniform(0, 0.1)))
        edges.append((j, i, routing_loss + rng.uniform(0, 0.1)))
    
    # Random shortcuts (10% of possible edges)
    for i in range(1, n_panels + 1):
        for j in range(i + 2, n_panels + 1):
            if rng.random() < 0.1:
                loss = routing_loss * 2 + rng.uniform(0, 0.2)
                edges.append((i, j, loss))
                edges.append((j, i, loss))
    
    return TropicalGraph(n_vertices=n_panels + 1, edges=edges)


if __name__ == "__main__":
    # Quick algorithm test
    print("Testing Bellman-Ford tropical shortest path...")
    G = create_dyson_shell_network(20)
    dist, pred = bellman_ford_tropical(G, 0, return_predecessors=True)
    cap = tropical_capacity(G, 0)
    
    print(f"  Network: {G.n_vertices} vertices, {len(G.edges)} edges")
    print(f"  Tropical capacity: {cap:.4f}")
    print(f"  Best panel gain (G=10): {10 - cap:.4f}")
    
    # Verify gain = G - capacity
    best_gain, best_v = optimal_gain(G, 0, 10.0)
    print(f"  Optimal panel: {best_v}, gain: {best_gain:.4f}")
    assert abs(best_gain - (10 - cap)) < 1e-10, "max_gain_eq verification failed!"
    print("  ✓ max_gain_eq verified: sup(gain) = G - tropicalCapacity")
    
    path = reconstruct_path(pred, 0, best_v)
    print(f"  Optimal path: {' → '.join(map(str, path))}")
    
    # Hex patch test
    print("\nTesting hexagonal lattice...")
    for r in range(6):
        patch = hex_patch(r)
        assert len(patch) == hex_patch_card(r), f"Card mismatch at r={r}"
        assert edge_boundary(patch) == hex_patch_boundary(r), f"Boundary mismatch at r={r}"
    print("  ✓ All hex patch properties verified")
    
    # Kardashev bound test
    print("\nTesting Kardashev bounds...")
    L_sun = 3.828e26
    K_opt, K_max = kardashev_bound(L_sun, 0.3, 0.7)
    assert K_opt <= K_max + 1e-10
    print(f"  K(P_opt) = {K_opt:.2f} ≤ K(L·η) = {K_max:.2f} ✓")
    
    print("\nAll algorithm tests passed! ✓")
