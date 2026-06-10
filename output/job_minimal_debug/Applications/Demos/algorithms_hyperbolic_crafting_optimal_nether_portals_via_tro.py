#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for tropical portal network optimization.

Implements:
1. Tropical (min-plus) matrix multiplication and closure
2. Prim's MST on compressed metric graphs
3. Dual-world shortest path (Floyd-Warshall in tropical semiring)
4. Portal placement optimizer
"""

from typing import List, Tuple, Dict, Optional
import math

# ============================================================
# Core Types
# ============================================================
Point2D = Tuple[int, int]
INF = float('inf')


# ============================================================
# 1. Metric Operations
# ============================================================

def l1_dist(p: Point2D, q: Point2D) -> int:
    """Manhattan (L1) distance between two 2D integer points.

    Time: O(1), Space: O(1)
    """
    return abs(p[0] - q[0]) + abs(p[1] - q[1])


def nether_map(p: Point2D) -> Point2D:
    """Map Overworld coordinates to Nether via floor division by 8.

    Time: O(1), Space: O(1)
    """
    return (p[0] // 8, p[1] // 8)


def lift_over(p: Point2D) -> Point2D:
    """Lift Nether coordinates to Overworld by scaling by 8.

    Time: O(1), Space: O(1)
    """
    return (8 * p[0], 8 * p[1])


def nether_dist(p: Point2D, q: Point2D) -> int:
    """Manhattan distance in Nether between two Overworld points.

    Time: O(1), Space: O(1)
    """
    return l1_dist(nether_map(p), nether_map(q))


def dual_world_cost(p: Point2D, q: Point2D, portal_cost: int = 0) -> int:
    """Optimal single-hop cost between two points in the dual-world model.

    Returns min(overworld_direct, 2*portal_cost + nether_travel).

    Time: O(1), Space: O(1)
    """
    ow = l1_dist(p, q)
    nw = 2 * portal_cost + nether_dist(p, q)
    return min(ow, nw)


# ============================================================
# 2. Tropical (Min-Plus) Matrix Operations
# ============================================================

def tropical_mat_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Min-plus matrix multiplication: C[i][k] = min_j(A[i][j] + B[j][k]).

    This is the tropical semiring analog of standard matrix multiplication,
    replacing (×, +) with (+, min).

    Time: O(n³), Space: O(n²)

    Args:
        A: n×n matrix (list of lists)
        B: n×n matrix (list of lists)

    Returns:
        C: n×n tropical product matrix
    """
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            for j in range(n):
                val = A[i][j] + B[j][k]
                if val < C[i][k]:
                    C[i][k] = val
    return C


def tropical_closure(W: List[List[float]], max_iter: Optional[int] = None) -> List[List[float]]:
    """Compute the tropical (min-plus) closure of a weight matrix.

    The closure W* satisfies W*[i][k] = shortest path cost from i to k.
    This is equivalent to the Floyd-Warshall all-pairs shortest path,
    expressed as iterated tropical matrix squaring.

    Convergence: At most n iterations suffice for n vertices.

    Time: O(n⁴) naive, O(n³ log n) with repeated squaring
    Space: O(n²)

    Args:
        W: n×n weight matrix with W[i][i] = 0
        max_iter: maximum iterations (default: n)

    Returns:
        W*: tropical closure matrix
    """
    n = len(W)
    if max_iter is None:
        max_iter = n

    D = [row[:] for row in W]  # copy

    for _ in range(max_iter):
        D_new = tropical_mat_mul(D, W)
        # Take elementwise min with current
        changed = False
        for i in range(n):
            for j in range(n):
                new_val = min(D[i][j], D_new[i][j])
                if new_val < D[i][j]:
                    D[i][j] = new_val
                    changed = True
        if not changed:
            break

    return D


def floyd_warshall_tropical(W: List[List[float]]) -> List[List[float]]:
    """Floyd-Warshall as explicit tropical closure.

    Equivalent to tropical_closure but uses the standard DP formulation.

    Time: O(n³), Space: O(n²)

    Args:
        W: n×n weight matrix

    Returns:
        All-pairs shortest path matrix
    """
    n = len(W)
    D = [row[:] for row in W]

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]

    return D


# ============================================================
# 3. MST Algorithms
# ============================================================

def prim_mst(n: int, weight: List[List[float]]) -> Tuple[List[Tuple[int, int]], float]:
    """Prim's algorithm for minimum spanning tree.

    Time: O(n²), Space: O(n)

    Args:
        n: number of vertices
        weight: n×n symmetric weight matrix

    Returns:
        (edges, total_cost): list of MST edges and total weight
    """
    in_tree = [False] * n
    in_tree[0] = True
    edges = []
    total = 0.0

    for _ in range(n - 1):
        best_cost = INF
        best_edge = (-1, -1)
        for u in range(n):
            if not in_tree[u]:
                continue
            for v in range(n):
                if in_tree[v]:
                    continue
                if weight[u][v] < best_cost:
                    best_cost = weight[u][v]
                    best_edge = (u, v)
        if best_edge[0] >= 0:
            edges.append(best_edge)
            total += best_cost
            in_tree[best_edge[1]] = True

    return edges, total


def kruskal_mst(n: int, weight: List[List[float]]) -> Tuple[List[Tuple[int, int]], float]:
    """Kruskal's algorithm for minimum spanning tree using union-find.

    Time: O(n² log n), Space: O(n)

    Args:
        n: number of vertices
        weight: n×n symmetric weight matrix

    Returns:
        (edges, total_cost): list of MST edges and total weight
    """
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1
        return True

    # Collect and sort all edges
    all_edges = []
    for i in range(n):
        for j in range(i + 1, n):
            all_edges.append((weight[i][j], i, j))
    all_edges.sort()

    mst_edges = []
    total = 0.0
    for w, u, v in all_edges:
        if union(u, v):
            mst_edges.append((u, v))
            total += w
            if len(mst_edges) == n - 1:
                break

    return mst_edges, total


# ============================================================
# 4. Portal Network Optimizer
# ============================================================

class PortalNetworkOptimizer:
    """Optimizes portal network design for a set of settlements.

    Given settlement locations in the Overworld, computes:
    - The optimal MST backbone using Nether-compressed distances
    - All-pairs shortest travel times via tropical closure
    - Cost-benefit analysis of portal activation costs

    Example:
        >>> settlements = [(0,0), (80,0), (0,80), (80,80)]
        >>> opt = PortalNetworkOptimizer(settlements, portal_cost=10)
        >>> opt.compute_mst()
        >>> opt.compute_shortest_paths()
        >>> opt.report()
    """

    def __init__(self, settlements: List[Point2D], portal_cost: int = 0):
        self.settlements = settlements
        self.portal_cost = portal_cost
        self.n = len(settlements)
        self.nether_coords = [nether_map(s) for s in settlements]

        # Build weight matrices
        self.ow_dist_matrix = self._build_ow_matrix()
        self.nether_dist_matrix = self._build_nether_matrix()
        self.dual_cost_matrix = self._build_dual_matrix()

        self.mst_edges = None
        self.mst_cost = None
        self.shortest_paths = None

    def _build_ow_matrix(self) -> List[List[int]]:
        return [[l1_dist(self.settlements[i], self.settlements[j])
                 for j in range(self.n)] for i in range(self.n)]

    def _build_nether_matrix(self) -> List[List[int]]:
        return [[l1_dist(self.nether_coords[i], self.nether_coords[j])
                 for j in range(self.n)] for i in range(self.n)]

    def _build_dual_matrix(self) -> List[List[int]]:
        return [[dual_world_cost(self.settlements[i], self.settlements[j],
                                 self.portal_cost) if i != j else 0
                 for j in range(self.n)] for i in range(self.n)]

    def compute_mst(self) -> Tuple[List[Tuple[int, int]], float]:
        """Compute the MST of the Nether-compressed metric graph.

        Returns:
            (edges, total_cost)
        """
        self.mst_edges, self.mst_cost = prim_mst(self.n, self.dual_cost_matrix)
        return self.mst_edges, self.mst_cost

    def compute_shortest_paths(self) -> List[List[float]]:
        """Compute all-pairs shortest paths via tropical closure.

        Returns:
            Shortest path distance matrix
        """
        float_matrix = [[float(x) for x in row] for row in self.dual_cost_matrix]
        self.shortest_paths = floyd_warshall_tropical(float_matrix)
        return self.shortest_paths

    def star_cost(self, hub: int = 0) -> float:
        """Total cost of a star network centered at the given hub."""
        return sum(self.dual_cost_matrix[hub][j]
                   for j in range(self.n) if j != hub)

    def savings_report(self) -> Dict:
        """Compute savings of MST over various star configurations."""
        if self.mst_edges is None:
            self.compute_mst()

        best_star_hub = min(range(self.n), key=lambda h: self.star_cost(h))
        best_star = self.star_cost(best_star_hub)

        return {
            "mst_cost": self.mst_cost,
            "best_star_hub": best_star_hub,
            "best_star_cost": best_star,
            "savings_abs": best_star - self.mst_cost,
            "savings_pct": 100 * (best_star - self.mst_cost) / best_star if best_star > 0 else 0,
        }

    def threshold_distance(self) -> float:
        """Compute the crossover distance where Nether travel beats Overworld.

        For portal cost c, Nether travel (2c + d/8) beats Overworld (d) when:
            2c + d/8 < d  →  d > 16c/7
        """
        c = self.portal_cost
        return (16 * c) / 7 if c > 0 else 0

    def report(self) -> str:
        """Generate a full optimization report."""
        if self.mst_edges is None:
            self.compute_mst()
        if self.shortest_paths is None:
            self.compute_shortest_paths()

        lines = []
        lines.append("=" * 60)
        lines.append("PORTAL NETWORK OPTIMIZATION REPORT")
        lines.append("=" * 60)
        lines.append(f"\nSettlements: {self.n}")
        for i, s in enumerate(self.settlements):
            lines.append(f"  [{i}] OW: {s}  →  Nether: {self.nether_coords[i]}")

        lines.append(f"\nPortal activation cost: {self.portal_cost}")
        lines.append(f"Crossover distance: {self.threshold_distance():.1f}")

        lines.append(f"\nMST backbone ({self.mst_cost} total):")
        for u, v in self.mst_edges:
            lines.append(f"  {u} ↔ {v}  (cost {self.dual_cost_matrix[u][v]})")

        sr = self.savings_report()
        lines.append(f"\nBest star hub: [{sr['best_star_hub']}] (cost {sr['best_star_cost']})")
        lines.append(f"MST savings: {sr['savings_abs']} ({sr['savings_pct']:.1f}%)")

        lines.append(f"\nAll-pairs shortest paths:")
        for i in range(self.n):
            row = [f"{int(self.shortest_paths[i][j]):>5}" for j in range(self.n)]
            lines.append("  " + " ".join(row))

        return "\n".join(lines)


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Example: 6 settlements forming a varied geometry
    settlements = [
        (0, 0),       # Base camp
        (200, 0),     # Eastern outpost
        (0, 160),     # Northern fortress
        (200, 160),   # Northeast village
        (100, 80),    # Central hub
        (320, 240),   # Far colony
    ]

    print("=== Zero portal cost ===")
    opt0 = PortalNetworkOptimizer(settlements, portal_cost=0)
    opt0.compute_mst()
    opt0.compute_shortest_paths()
    print(opt0.report())

    print("\n\n=== Portal cost = 20 ===")
    opt20 = PortalNetworkOptimizer(settlements, portal_cost=20)
    opt20.compute_mst()
    opt20.compute_shortest_paths()
    print(opt20.report())

    # Verify tropical closure is idempotent
    print("\n\nVerifying tropical closure idempotence...")
    D = opt20.shortest_paths
    D2 = tropical_mat_mul(D, D)
    is_fp = all(abs(D[i][j] - min(D[i][j], D2[i][j])) < 1e-9
                for i in range(len(D)) for j in range(len(D)))
    print(f"  Closure is fixpoint: {'YES ✓' if is_fp else 'NO ✗'}")
