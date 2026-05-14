#!/usr/bin/env python3
"""
Tropical Portal Networks — Algorithms

Implements the core algorithms from the tropical scaling theory:
- Tropical matrix multiplication (min-plus)
- Floyd-Warshall tropical closure
- Dual-world MST computation (Kruskal's)
- Portal threshold decision
- Rounding error computation
"""

from typing import List, Tuple, Optional
import math


# ─────────────────────────────────────────────────────────────
# Core Distance Functions
# ─────────────────────────────────────────────────────────────

def l1_dist(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """Manhattan (L1) distance between two 2D integer points.

    >>> l1_dist((0, 0), (3, 4))
    7
    >>> l1_dist((-1, 2), (3, -1))
    7
    """
    return abs(p[0] - q[0]) + abs(p[1] - q[1])


def lift_over(p: Tuple[int, int]) -> Tuple[int, int]:
    """Lift Nether coordinates to Overworld (scale by 8).

    >>> lift_over((1, 2))
    (8, 16)
    """
    return (8 * p[0], 8 * p[1])


def nether_map(p: Tuple[int, int]) -> Tuple[int, int]:
    """Map Overworld coordinates to Nether (floor division by 8).

    >>> nether_map((17, -5))
    (2, -1)
    >>> nether_map((16, 24))
    (2, 3)
    """
    return (math.floor(p[0] / 8), math.floor(p[1] / 8))


def dual_world_cost(c: int, p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """Dual-world travel cost with portal entry cost c.

    Returns min(overworld_dist, 2*c + nether_dist).

    >>> dual_world_cost(0, (0, 0), (80, 0))
    10
    >>> dual_world_cost(100, (0, 0), (80, 0))
    80
    """
    overworld = l1_dist(p, q)
    nether = 2 * c + l1_dist(nether_map(p), nether_map(q))
    return min(overworld, nether)


# ─────────────────────────────────────────────────────────────
# Tropical (Min-Plus) Matrix Operations
# ─────────────────────────────────────────────────────────────

def tropical_mat_mul(A: List[List[int]], B: List[List[int]]) -> List[List[int]]:
    """Min-plus matrix multiplication.

    (A ⊗ B)_{ik} = min_j (A_{ij} + B_{jk})

    Args:
        A: n×m matrix
        B: m×p matrix

    Returns:
        n×p tropical product matrix

    >>> A = [[0, 3], [7, 0]]
    >>> B = [[0, 1], [2, 0]]
    >>> tropical_mat_mul(A, B)
    [[0, 1], [2, 0]]
    """
    n = len(A)
    m = len(B)
    p = len(B[0])
    INF = float('inf')
    C = [[INF] * p for _ in range(n)]
    for i in range(n):
        for k in range(p):
            for j in range(m):
                val = A[i][j] + B[j][k]
                if val < C[i][k]:
                    C[i][k] = val
    return C


def tropical_closure(W: List[List[int]]) -> List[List[int]]:
    """Compute the tropical (min-plus) closure of a cost matrix.

    This is equivalent to Floyd-Warshall all-pairs shortest paths.
    The closure W* satisfies W* ⊗ W* = W* (tropical idempotence).

    Args:
        W: n×n cost matrix with W[i][i] = 0

    Returns:
        n×n all-pairs shortest path matrix

    Time complexity: O(n³)
    Space complexity: O(n²)

    >>> W = [[0, 5, 100], [5, 0, 3], [100, 3, 0]]
    >>> tropical_closure(W)
    [[0, 5, 8], [5, 0, 3], [8, 3, 0]]
    """
    n = len(W)
    dist = [row[:] for row in W]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                via_k = dist[i][k] + dist[k][j]
                if via_k < dist[i][j]:
                    dist[i][j] = via_k
    return dist


def tropical_step(W: List[List[int]]) -> List[List[int]]:
    """One step of tropical closure: min(W, W ⊗ W).

    >>> W = [[0, 5, 100], [5, 0, 3], [100, 3, 0]]
    >>> tropical_step(W)
    [[0, 5, 8], [5, 0, 3], [8, 3, 0]]
    """
    W2 = tropical_mat_mul(W, W)
    n = len(W)
    return [[min(W[i][j], W2[i][j]) for j in range(n)] for i in range(n)]


# ─────────────────────────────────────────────────────────────
# Graph Algorithms
# ─────────────────────────────────────────────────────────────

class UnionFind:
    """Disjoint set / union-find data structure for Kruskal's algorithm."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        return True


def kruskal_mst(
    n: int,
    weights: List[List[int]]
) -> Tuple[List[Tuple[int, int, int]], int]:
    """Compute minimum spanning tree using Kruskal's algorithm.

    Args:
        n: number of vertices
        weights: n×n symmetric weight matrix

    Returns:
        (edges, total_weight) where edges is list of (i, j, weight)

    Time complexity: O(n² log n)

    >>> weights = [[0, 1, 3], [1, 0, 2], [3, 2, 0]]
    >>> edges, total = kruskal_mst(3, weights)
    >>> total
    3
    """
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((weights[i][j], i, j))
    edges.sort()

    uf = UnionFind(n)
    mst_edges = []
    total = 0
    for w, i, j in edges:
        if uf.union(i, j):
            mst_edges.append((i, j, w))
            total += w
            if len(mst_edges) == n - 1:
                break

    return mst_edges, total


def dual_world_mst(
    settlements: List[Tuple[int, int]],
    portal_cost: int = 0
) -> Tuple[List[Tuple[int, int, int]], int]:
    """Compute MST of a settlement network in the dual-world metric.

    Args:
        settlements: list of (x, z) Overworld coordinates
        portal_cost: fixed cost per portal entry/exit

    Returns:
        (edges, total_weight) in dual-world cost

    >>> settlements = [(0, 0), (80, 0), (0, 80)]
    >>> edges, total = dual_world_mst(settlements, portal_cost=0)
    >>> total
    20
    """
    n = len(settlements)
    weights = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            weights[i][j] = dual_world_cost(portal_cost, settlements[i], settlements[j])
    return kruskal_mst(n, weights)


# ─────────────────────────────────────────────────────────────
# Analysis Functions
# ─────────────────────────────────────────────────────────────

def rounding_error(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """Compute the rounding error for the Nether scaling.

    Returns |L1Dist(p,q) - 8 * L1Dist(NetherMap(p), NetherMap(q))|.

    >>> rounding_error((7, 7), (8, 8))
    14
    >>> rounding_error((0, 0), (8, 8))
    0
    """
    over = l1_dist(p, q)
    nether = l1_dist(nether_map(p), nether_map(q))
    return abs(over - 8 * nether)


def portal_threshold(c: int, k: int = 8) -> float:
    """Compute the distance threshold beyond which Nether travel dominates.

    For scaling factor k and portal cost c, Nether wins when:
    2c + d/k < d, i.e., d > 2ck/(k-1)

    >>> portal_threshold(100)
    228.57142857142858
    >>> portal_threshold(50)
    114.28571428571429
    """
    return 2 * c * k / (k - 1)


def verify_scaling_exact(p: Tuple[int, int], q: Tuple[int, int]) -> bool:
    """Verify the exact scaling theorem for a pair of points.

    Returns True iff L1Dist(LiftOver(p), LiftOver(q)) == 8 * L1Dist(p, q).

    >>> verify_scaling_exact((3, -5), (7, 2))
    True
    """
    return l1_dist(lift_over(p), lift_over(q)) == 8 * l1_dist(p, q)


def verify_lattice_scaling(p: Tuple[int, int], q: Tuple[int, int]) -> bool:
    """Verify the lattice scaling theorem for 8-lattice points.

    Returns True iff L1Dist(NetherMap(p), NetherMap(q)) * 8 == L1Dist(p, q).
    Requires p, q on the 8-lattice.

    >>> verify_lattice_scaling((16, 24), (80, -8))
    True
    """
    assert p[0] % 8 == 0 and p[1] % 8 == 0, f"{p} not on 8-lattice"
    assert q[0] % 8 == 0 and q[1] % 8 == 0, f"{q} not on 8-lattice"
    return l1_dist(nether_map(p), nether_map(q)) * 8 == l1_dist(p, q)


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Portal Networks — Algorithm Examples\n")

    # Example 1: Tropical matrix closure
    print("1. Tropical Closure (3 cities)")
    W = [[0, 10, 100],
         [10, 0, 5],
         [100, 5, 0]]
    print(f"   Input: {W}")
    W_star = tropical_closure(W)
    print(f"   Closure: {W_star}")
    print(f"   Shortest 0→2: {W_star[0][2]} (via vertex 1: 10+5=15)")

    # Example 2: Dual-world MST
    print("\n2. Dual-World MST (5 settlements)")
    settlements = [(0, 0), (80, 0), (160, 0), (80, 80), (80, -80)]
    edges, total = dual_world_mst(settlements, portal_cost=0)
    print(f"   Settlements: {settlements}")
    print(f"   MST edges: {edges}")
    print(f"   Total MST weight: {total}")

    # Example 3: Portal threshold
    print("\n3. Portal Threshold Analysis")
    for c in [10, 50, 100]:
        thresh = portal_threshold(c)
        print(f"   Portal cost {c}: threshold = {thresh:.1f} blocks")

    # Example 4: Rounding errors
    print("\n4. Maximum Rounding Error Search")
    max_err = 0
    max_pair = None
    import random
    random.seed(123)
    for _ in range(100000):
        p = (random.randint(-100, 100), random.randint(-100, 100))
        q = (random.randint(-100, 100), random.randint(-100, 100))
        err = rounding_error(p, q)
        if err > max_err:
            max_err = err
            max_pair = (p, q)
    print(f"   Max error found: {max_err} at {max_pair}")
