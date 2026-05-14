#!/usr/bin/env python3
"""
Tropical Portal Networks — Real-World Applications

Demonstrates how the tropical scaling theory applies to:
1. Logistics network design (hub-and-spoke optimization)
2. Internet backbone routing
3. Multi-resolution spatial databases
4. Transportation network planning
"""

import math
import random
from typing import List, Tuple


# ─────────────────────────────────────────────────────────────
# Core functions (self-contained, no local imports)
# ─────────────────────────────────────────────────────────────

def l1_dist(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    return abs(p[0] - q[0]) + abs(p[1] - q[1])

def nether_map_k(p: Tuple[int, int], k: int) -> Tuple[int, int]:
    return (math.floor(p[0] / k), math.floor(p[1] / k))

def dual_cost(c: int, k: int, p: Tuple[int, int], q: Tuple[int, int]) -> int:
    overworld = l1_dist(p, q)
    nether = 2 * c + l1_dist(nether_map_k(p, k), nether_map_k(q, k))
    return min(overworld, nether)

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py: return False
        if self.rank[px] < self.rank[py]: px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]: self.rank[px] += 1
        return True

def kruskal_mst(n, weights):
    edges = sorted((weights[i][j], i, j) for i in range(n) for j in range(i+1, n))
    uf = UnionFind(n)
    mst = []
    total = 0
    for w, i, j in edges:
        if uf.union(i, j):
            mst.append((i, j, w))
            total += w
    return mst, total


# ─────────────────────────────────────────────────────────────
# Application 1: Logistics Network Design
# ─────────────────────────────────────────────────────────────

def logistics_network():
    """
    Model: A company has warehouses in various cities.
    - Local truck delivery: cost = distance (slow, no setup)
    - Air freight: cost = distance/k + 2*airport_fee (fast, needs airports)

    The tropical scaling theory tells us:
    - Threshold for air freight: d > 2*fee*k/(k-1)
    - Optimal backbone: MST in air-freight metric
    """
    print("=" * 60)
    print("APPLICATION 1: Logistics Network Design")
    print("=" * 60)

    # Cities (approximate grid coordinates, in km)
    cities = {
        "NYC": (0, 0),
        "Chicago": (-1200, 400),
        "LA": (-3900, -300),
        "Houston": (-2200, -1200),
        "Phoenix": (-3400, -800),
        "Philadelphia": (100, -100),
        "Dallas": (-2300, -900),
        "Atlanta": (-1200, -700),
    }

    airport_fee = 200  # cost units per airport entry/exit
    k = 10  # air freight is 10x faster than trucking

    names = list(cities.keys())
    coords = [cities[n] for n in names]
    n = len(coords)

    # Compute dual-cost matrix
    weights = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            weights[i][j] = dual_cost(airport_fee, k, coords[i], coords[j])

    # MST in dual-world metric
    mst_edges, total = kruskal_mst(n, weights)

    threshold = 2 * airport_fee * k / (k - 1)
    print(f"\n  Parameters: airport_fee={airport_fee}, speed_factor={k}x")
    print(f"  Threshold distance: {threshold:.0f} km")
    print(f"\n  Optimal logistics backbone:")
    for i, j, w in mst_edges:
        direct = l1_dist(coords[i], coords[j])
        air = 2 * airport_fee + l1_dist(nether_map_k(coords[i], k), nether_map_k(coords[j], k))
        mode = "✈ Air" if air < direct else "🚛 Truck"
        print(f"    {names[i]:15s} ↔ {names[j]:15s}: cost={w:5d}  ({mode}, direct={direct})")

    print(f"\n  Total backbone cost: {total}")

    # Compare with complete graph
    complete_cost = sum(weights[i][j] for i in range(n) for j in range(i+1, n))
    print(f"  Complete graph cost: {complete_cost}")
    print(f"  Savings: {(1 - total/complete_cost)*100:.1f}%")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Internet Backbone Routing
# ─────────────────────────────────────────────────────────────

def internet_backbone():
    """
    Model: Data centers connected by local links and backbone fiber.
    - Local link: latency = distance (in ms)
    - Backbone fiber: latency = distance/20 + 2*router_setup (20x faster)

    The tropical closure gives optimal routing table.
    """
    print("=" * 60)
    print("APPLICATION 2: Internet Backbone Routing")
    print("=" * 60)

    # Data centers
    data_centers = [
        ("US-East", (0, 0)),
        ("US-West", (4000, 0)),
        ("Europe", (6000, 3000)),
        ("Asia", (10000, 1000)),
        ("South-Am", (2000, -5000)),
    ]

    router_cost = 50  # ms setup per router hop
    k = 20  # backbone is 20x faster

    names = [d[0] for d in data_centers]
    coords = [d[1] for d in data_centers]
    n = len(coords)

    # Cost matrix
    W = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            W[i][j] = dual_cost(router_cost, k, coords[i], coords[j])

    print(f"\n  Parameters: router_cost={router_cost}ms, backbone_speedup={k}x")
    print(f"\n  Direct latency matrix (ms):")
    print(f"  {'':>12s}", end="")
    for name in names:
        print(f"{name:>10s}", end="")
    print()
    for i in range(n):
        print(f"  {names[i]:>12s}", end="")
        for j in range(n):
            print(f"{W[i][j]:10d}", end="")
        print()

    # Tropical closure = optimal routing
    dist = [row[:] for row in W]
    for k_idx in range(n):
        for i in range(n):
            for j in range(n):
                via = dist[i][k_idx] + dist[k_idx][j]
                if via < dist[i][j]:
                    dist[i][j] = via

    print(f"\n  Optimal routing table after tropical closure (ms):")
    print(f"  {'':>12s}", end="")
    for name in names:
        print(f"{name:>10s}", end="")
    print()
    for i in range(n):
        print(f"  {names[i]:>12s}", end="")
        for j in range(n):
            improvement = W[i][j] - dist[i][j]
            suffix = f"(-{improvement})" if improvement > 0 else ""
            print(f"{dist[i][j]:>6d}{suffix:>4s}", end="")
        print()
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Transportation Phase Diagram
# ─────────────────────────────────────────────────────────────

def transportation_phases():
    """
    Compute and display the phase diagram showing when each
    transportation mode (local vs express) is optimal.
    """
    print("=" * 60)
    print("APPLICATION 3: Transportation Phase Diagram")
    print("=" * 60)

    print("\n  Phase diagram: Optimal transport mode")
    print("  (L=Local, E=Express)")
    print()
    print(f"  {'Cost↓/Dist→':>12s}", end="")
    for d in range(0, 1001, 100):
        print(f"{d:>6d}", end="")
    print()

    for c in range(0, 201, 20):
        threshold = 2 * c * 8 / 7 if c > 0 else 0
        print(f"  c={c:>4d}     ", end="")
        for d in range(0, 1001, 100):
            if d == 0:
                print(f"{'=':>6s}", end="")
            elif d > threshold:
                print(f"{'E':>6s}", end="")
            else:
                print(f"{'L':>6s}", end="")
        print(f"  (threshold={threshold:.0f})")

    print()


# ─────────────────────────────────────────────────────────────
# Application 4: Multi-Scale Network Comparison
# ─────────────────────────────────────────────────────────────

def multi_scale_comparison():
    """
    Compare network costs across different scaling factors.
    Shows how the infrastructure saving varies with compression ratio.
    """
    print("=" * 60)
    print("APPLICATION 4: Multi-Scale Network Comparison")
    print("=" * 60)

    random.seed(42)
    n = 10
    settlements = [(random.randint(-500, 500), random.randint(-500, 500)) for _ in range(n)]

    print(f"\n  {n} random settlements, comparing scaling factors k=2,4,8,16,32")
    print(f"  Portal cost c = 50")
    c = 50

    print(f"\n  {'k':>6s} {'MST Cost':>10s} {'Overworld':>12s} {'Saving':>10s} {'Threshold':>12s}")
    print(f"  {'-'*6} {'-'*10} {'-'*12} {'-'*10} {'-'*12}")

    # Overworld-only MST
    ow = [[l1_dist(settlements[i], settlements[j]) for j in range(n)] for i in range(n)]
    _, ow_total = kruskal_mst(n, ow)

    for k in [2, 4, 8, 16, 32]:
        weights = [[dual_cost(c, k, settlements[i], settlements[j])
                     for j in range(n)] for i in range(n)]
        _, total = kruskal_mst(n, weights)
        threshold = 2 * c * k / (k - 1)
        saving = (1 - total / ow_total) * 100
        print(f"  {k:>6d} {total:>10d} {ow_total:>12d} {saving:>9.1f}% {threshold:>12.1f}")

    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL PORTAL NETWORKS — REAL-WORLD APPLICATIONS")
    print("=" * 60 + "\n")

    logistics_network()
    internet_backbone()
    transportation_phases()
    multi_scale_comparison()

    print("All applications complete.")


#!/usr/bin/env python3
"""
Tropical Portal Networks — Demonstration Script

Demonstrates the key theorems from the tropical scaling theory
with concrete numerical examples.
"""

import random
import math

def l1_dist(p, q):
    """Manhattan (L1) distance between two 2D integer points."""
    return abs(p[0] - q[0]) + abs(p[1] - q[1])

def lift_over(p):
    """Lift Nether coordinates to Overworld (scale by 8)."""
    return (8 * p[0], 8 * p[1])

def nether_map(p):
    """Map Overworld coordinates to Nether (integer division by 8)."""
    # Python's // does floor division, matching Lean's Int.ediv
    return (p[0] // 8 if p[0] >= 0 else -((-p[0]) // 8 + (1 if (-p[0]) % 8 != 0 else 0)),
            p[1] // 8 if p[1] >= 0 else -((-p[1]) // 8 + (1 if (-p[1]) % 8 != 0 else 0)))

def nether_map_simple(p):
    """Simplified Nether map using Python's floor division."""
    return (math.floor(p[0] / 8), math.floor(p[1] / 8))

def dual_world_cost(c, p, q):
    """Dual-world travel cost with portal penalty c."""
    overworld = l1_dist(p, q)
    nether = 2 * c + l1_dist(nether_map_simple(p), nether_map_simple(q))
    return min(overworld, nether)


def demo_exact_scaling():
    """Demonstrate Theorem 1: exact tropical scaling on lifted coordinates."""
    print("=" * 60)
    print("THEOREM 1: Exact Tropical Scaling")
    print("L1Dist(LiftOver(p), LiftOver(q)) = 8 * L1Dist(p, q)")
    print("=" * 60)

    test_cases = [
        ((0, 0), (1, 1)),
        ((3, -5), (7, 2)),
        ((-10, 20), (15, -8)),
        ((100, -200), (-50, 300)),
    ]

    for p, q in test_cases:
        lhs = l1_dist(lift_over(p), lift_over(q))
        rhs = 8 * l1_dist(p, q)
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} p={p}, q={q}: LHS={lhs}, RHS={rhs}")

    # Random verification
    failures = 0
    N = 100000
    for _ in range(N):
        p = (random.randint(-1000, 1000), random.randint(-1000, 1000))
        q = (random.randint(-1000, 1000), random.randint(-1000, 1000))
        if l1_dist(lift_over(p), lift_over(q)) != 8 * l1_dist(p, q):
            failures += 1

    print(f"\n  Random verification: {N} trials, {failures} failures")
    print()


def demo_lattice_scaling():
    """Demonstrate Theorem 2: exact scaling on the 8-lattice."""
    print("=" * 60)
    print("THEOREM 2: Lattice Scaling (8-lattice)")
    print("L1Dist(NetherMap(p), NetherMap(q)) * 8 = L1Dist(p, q)")
    print("for p, q on the 8-lattice")
    print("=" * 60)

    test_cases = [
        ((0, 0), (8, 8)),
        ((16, -24), (80, 40)),
        ((-64, 128), (256, -192)),
    ]

    for p, q in test_cases:
        nether_dist = l1_dist(nether_map_simple(p), nether_map_simple(q))
        over_dist = l1_dist(p, q)
        status = "✓" if nether_dist * 8 == over_dist else "✗"
        print(f"  {status} p={p}, q={q}: nether_dist*8={nether_dist * 8}, over_dist={over_dist}")

    print()


def demo_rounding_error():
    """Demonstrate Theorem 3: bounded rounding distortion ≤ 14."""
    print("=" * 60)
    print("THEOREM 3: Rounding Error Bound ≤ 14")
    print("|L1Dist(p,q) - 8 * L1Dist(NetherMap(p), NetherMap(q))| ≤ 14")
    print("=" * 60)

    max_error = 0
    error_counts = {}
    N = 1000000

    for _ in range(N):
        p = (random.randint(-1000, 1000), random.randint(-1000, 1000))
        q = (random.randint(-1000, 1000), random.randint(-1000, 1000))
        over_dist = l1_dist(p, q)
        nether_dist = l1_dist(nether_map_simple(p), nether_map_simple(q))
        error = abs(over_dist - 8 * nether_dist)
        max_error = max(max_error, error)
        error_counts[error] = error_counts.get(error, 0) + 1

    print(f"  {N} random trials:")
    print(f"  Maximum error observed: {max_error}")
    print(f"  Mean error: {sum(e * c for e, c in error_counts.items()) / N:.2f}")
    print(f"  Error = 0: {error_counts.get(0, 0) / N * 100:.2f}%")
    print(f"  Error = 14 (tight bound): {error_counts.get(14, 0)} occurrences")

    # Show the tight example
    p, q = (7, 7), (8, 8)
    over_dist = l1_dist(p, q)
    nether_dist = l1_dist(nether_map_simple(p), nether_map_simple(q))
    error = abs(over_dist - 8 * nether_dist)
    print(f"\n  Tight example: p={p}, q={q}")
    print(f"    Overworld dist = {over_dist}")
    print(f"    Nether dist = {nether_dist}")
    print(f"    Error = |{over_dist} - 8*{nether_dist}| = {error}")
    print()


def demo_portal_threshold():
    """Demonstrate Theorem 4: portal threshold."""
    print("=" * 60)
    print("THEOREM 4: Portal Threshold")
    print("Nether wins when 2c + d < 8d, i.e., d > 16c/7")
    print("=" * 60)

    for c in [10, 50, 100, 500]:
        threshold = 16 * c / 7
        print(f"\n  Portal cost c = {c}:")
        print(f"  Threshold distance: d > {threshold:.1f}")
        for d in [int(threshold) - 10, int(threshold), int(threshold) + 10]:
            if d <= 0:
                continue
            over_cost = d
            nether_cost = 2 * c + d  # in Nether units (d/8 * 8 = d, but portal cost is added)
            # Actually: Overworld cost = 8d (in Nether-unit scale), Nether cost = 2c + d
            nether_actual = 2 * c + d // 8
            winner = "Nether" if nether_actual < over_cost else "Overworld"
            print(f"    d = {d}: Overworld = {over_cost}, Nether = {nether_actual} → {winner}")

    print()


def demo_tropical_closure():
    """Demonstrate tropical matrix closure (Floyd-Warshall)."""
    print("=" * 60)
    print("THEOREM 5: Tropical Closure (Floyd-Warshall)")
    print("Min-plus matrix powers converge to shortest paths")
    print("=" * 60)

    # Small example: 4 settlements
    settlements = [(0, 0), (80, 0), (0, 80), (80, 80)]
    n = len(settlements)

    # Compute Nether distance matrix
    W = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            W[i][j] = l1_dist(nether_map_simple(settlements[i]),
                              nether_map_simple(settlements[j]))

    print("\n  Settlements (Overworld):", settlements)
    print("  Nether distance matrix:")
    for row in W:
        print("   ", row)

    # Tropical closure
    INF = float('inf')
    dist = [row[:] for row in W]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]

    print("\n  After tropical closure (shortest paths):")
    for row in dist:
        print("   ", row)

    # Verify idempotence: closure of closure = closure
    dist2 = [row[:] for row in dist]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist2[i][k] + dist2[k][j] < dist2[i][j]:
                    dist2[i][j] = dist2[i][k] + dist2[k][j]

    idempotent = all(dist[i][j] == dist2[i][j] for i in range(n) for j in range(n))
    print(f"\n  Closure is idempotent: {idempotent}")
    print()


def demo_mst():
    """Demonstrate MST optimality for portal networks."""
    print("=" * 60)
    print("THEOREM 6: MST Portal Backbone")
    print("Optimal connected portal network is an MST")
    print("=" * 60)

    # Generate random settlements on 8-lattice
    random.seed(42)
    n = 8
    settlements = [(random.randint(-50, 50) * 8, random.randint(-50, 50) * 8)
                    for _ in range(n)]

    print(f"\n  {n} settlements on 8-lattice:")
    for i, s in enumerate(settlements):
        print(f"    S{i}: {s} (Nether: {nether_map_simple(s)})")

    # Compute all pairwise Nether distances
    nether_coords = [nether_map_simple(s) for s in settlements]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            w = l1_dist(nether_coords[i], nether_coords[j])
            edges.append((w, i, j))
    edges.sort()

    # Kruskal's MST
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
            return True
        return False

    mst_edges = []
    mst_weight = 0
    for w, i, j in edges:
        if union(i, j):
            mst_edges.append((i, j, w))
            mst_weight += w

    print(f"\n  MST edges (Nether distances):")
    for i, j, w in mst_edges:
        print(f"    S{i} -- S{j}: Nether dist = {w}, Overworld dist = {w * 8}")

    total_complete = sum(w for w, _, _ in edges)
    print(f"\n  Total MST weight (Nether): {mst_weight}")
    print(f"  Total MST weight (Overworld): {mst_weight * 8}")
    print(f"  Complete graph total weight: {total_complete}")
    print(f"  MST saves {(1 - mst_weight / total_complete) * 100:.1f}% vs complete graph")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL PORTAL NETWORKS — THEOREM DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_exact_scaling()
    demo_lattice_scaling()
    demo_rounding_error()
    demo_portal_threshold()
    demo_tropical_closure()
    demo_mst()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Tropical Portal Networks — Visualizations

Generates charts and diagrams illustrating the key mathematical results.
Saves output as PNG files and returns base64-encoded data URIs.
"""

import math
import random
import base64
import io
from typing import List, Tuple

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating text-based visualizations")


# Core functions
def l1_dist(p, q):
    return abs(p[0] - q[0]) + abs(p[1] - q[1])

def nether_map(p):
    return (math.floor(p[0] / 8), math.floor(p[1] / 8))

def lift_over(p):
    return (8 * p[0], 8 * p[1])

def dual_cost(c, p, q):
    return min(l1_dist(p, q), 2*c + l1_dist(nether_map(p), nether_map(q)))


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_rounding_error_distribution() -> str:
    """Histogram of rounding errors across random point pairs."""
    if not HAS_MPL:
        return ""

    random.seed(42)
    errors = []
    for _ in range(500000):
        p = (random.randint(-500, 500), random.randint(-500, 500))
        q = (random.randint(-500, 500), random.randint(-500, 500))
        od = l1_dist(p, q)
        nd = l1_dist(nether_map(p), nether_map(q))
        errors.append(abs(od - 8 * nd))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.hist(errors, bins=range(16), align='left', color='#2196F3', edgecolor='white',
            alpha=0.85, density=True)
    ax.axvline(x=14, color='red', linestyle='--', linewidth=2, label='Proven bound = 14')
    ax.set_xlabel('Rounding Error |d_O - 8·d_N|', fontsize=14)
    ax.set_ylabel('Probability Density', fontsize=14)
    ax.set_title('Distribution of Nether Scaling Rounding Errors\n(500K random point pairs)',
                 fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xlim(-0.5, 15.5)
    ax.grid(axis='y', alpha=0.3)

    return fig_to_base64(fig)


def viz_portal_threshold() -> str:
    """Phase diagram showing when Nether travel dominates."""
    if not HAS_MPL:
        return ""

    fig, ax = plt.subplots(figsize=(10, 6))

    c_vals = range(0, 201)
    d_vals = range(0, 1001)

    # Phase boundary: d = 16c/7
    c_line = list(range(0, 201))
    d_line = [16 * c / 7 for c in c_line]

    ax.fill_between(c_line, d_line, 1000, alpha=0.3, color='#4CAF50', label='Nether optimal')
    ax.fill_between(c_line, 0, d_line, alpha=0.3, color='#FF9800', label='Overworld optimal')
    ax.plot(c_line, d_line, 'k-', linewidth=2, label='Threshold: d = 16c/7')

    ax.set_xlabel('Portal Cost (c)', fontsize=14)
    ax.set_ylabel('Travel Distance (d)', fontsize=14)
    ax.set_title('Transportation Mode Phase Diagram\nNether vs Overworld Optimal Regions', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xlim(0, 200)
    ax.set_ylim(0, 1000)
    ax.grid(alpha=0.3)

    return fig_to_base64(fig)


def viz_mst_network() -> str:
    """Visualize MST portal backbone for random settlements."""
    if not HAS_MPL:
        return ""

    random.seed(42)
    n = 12
    settlements = [(random.randint(-40, 40) * 8, random.randint(-40, 40) * 8) for _ in range(n)]

    # Compute MST (Kruskal's)
    nether_coords = [nether_map(s) for s in settlements]
    edges = sorted((l1_dist(nether_coords[i], nether_coords[j]), i, j)
                    for i in range(n) for j in range(i+1, n))

    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    mst = []
    for w, i, j in edges:
        pi, pj = find(i), find(j)
        if pi != pj:
            parent[pi] = pj
            mst.append((i, j, w))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Complete graph (faded) + MST (bold)
    for i in range(n):
        for j in range(i+1, n):
            ax1.plot([settlements[i][0], settlements[j][0]],
                     [settlements[i][1], settlements[j][1]],
                     'b-', alpha=0.05, linewidth=0.5)

    for i, j, w in mst:
        ax1.plot([settlements[i][0], settlements[j][0]],
                 [settlements[i][1], settlements[j][1]],
                 'r-', linewidth=2.5, alpha=0.8)
        mid_x = (settlements[i][0] + settlements[j][0]) / 2
        mid_y = (settlements[i][1] + settlements[j][1]) / 2
        ax1.annotate(f'{w}', (mid_x, mid_y), fontsize=8, ha='center',
                     bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.7))

    for i, s in enumerate(settlements):
        ax1.plot(s[0], s[1], 'ko', markersize=10)
        ax1.annotate(f'S{i}', (s[0]+8, s[1]+8), fontsize=9, fontweight='bold')

    ax1.set_title('Overworld: MST Portal Backbone\n(red = MST, blue = all connections)', fontsize=13)
    ax1.set_xlabel('X coordinate')
    ax1.set_ylabel('Z coordinate')
    ax1.set_aspect('equal')
    ax1.grid(alpha=0.3)

    # Right: Nether view
    for i, j, w in mst:
        ni, nj = nether_coords[i], nether_coords[j]
        ax2.plot([ni[0], nj[0]], [ni[1], nj[1]], 'r-', linewidth=2.5, alpha=0.8)
        mid_x = (ni[0] + nj[0]) / 2
        mid_y = (ni[1] + nj[1]) / 2
        ax2.annotate(f'{w}', (mid_x, mid_y), fontsize=8, ha='center',
                     bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.7))

    for i, nc in enumerate(nether_coords):
        ax2.plot(nc[0], nc[1], 'rs', markersize=10)
        ax2.annotate(f'S{i}', (nc[0]+1, nc[1]+1), fontsize=9, fontweight='bold')

    ax2.set_title('Nether: Compressed Portal Network\n(8× compressed coordinates)', fontsize=13)
    ax2.set_xlabel('X coordinate (÷8)')
    ax2.set_ylabel('Z coordinate (÷8)')
    ax2.set_aspect('equal')
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_scaling_verification() -> str:
    """Scatter plot verifying exact scaling theorem."""
    if not HAS_MPL:
        return ""

    random.seed(123)
    nether_dists = []
    overworld_dists = []
    for _ in range(1000):
        p = (random.randint(-100, 100), random.randint(-100, 100))
        q = (random.randint(-100, 100), random.randint(-100, 100))
        nd = l1_dist(p, q)
        od = l1_dist(lift_over(p), lift_over(q))
        nether_dists.append(nd)
        overworld_dists.append(od)

    fig, ax = plt.subplots(figsize=(8, 8))
    ax.scatter(nether_dists, overworld_dists, alpha=0.3, s=10, c='#2196F3')
    max_val = max(max(nether_dists), max(overworld_dists) / 8)
    ax.plot([0, max_val], [0, 8 * max_val], 'r-', linewidth=2,
            label='y = 8x (exact scaling)')
    ax.set_xlabel('Nether Distance d_N(p, q)', fontsize=14)
    ax.set_ylabel('Overworld Distance d_O(Lift(p), Lift(q))', fontsize=14)
    ax.set_title('Exact Tropical Scaling Verification\n1000 random point pairs', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_aspect('equal')
    ax.grid(alpha=0.3)

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 data URIs."""
    results = {}

    print("Generating visualizations...")

    print("  1/4: Rounding error distribution...")
    results['rounding_error'] = viz_rounding_error_distribution()

    print("  2/4: Portal threshold phase diagram...")
    results['portal_threshold'] = viz_portal_threshold()

    print("  3/4: MST network visualization...")
    results['mst_network'] = viz_mst_network()

    print("  4/4: Scaling verification...")
    results['scaling_verification'] = viz_scaling_verification()

    print("Done!")
    return results


if __name__ == "__main__":
    vizs = generate_all_visualizations()

    # Save as individual PNG files
    for name, data_uri in vizs.items():
        if data_uri:
            b64_data = data_uri.split(",")[1]
            with open(f"{name}.png", "wb") as f:
                f.write(base64.b64decode(b64_data))
            print(f"Saved {name}.png")
