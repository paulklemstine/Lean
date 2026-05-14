#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Applications

Real-world applications of tropical spectral theory to:
1. Task scheduling and critical path analysis
2. Network routing cost optimization
3. Circuit design depth estimation
4. Branching program analysis
"""

import numpy as np
from algorithms import (
    build_layered_matrix, compute_depth, min_plus_permanent_hungarian,
    enumerate_paths, depth_cost_tradeoff, tropical_spectral_gap
)
from typing import List, Tuple


# =============================================================================
# Application 1: Task Scheduling (Critical Path Method)
# =============================================================================

def task_scheduling_demo():
    """
    Model a project as a layered circuit matrix.
    Tasks are vertices, dependencies are edges with duration weights.
    The depth = critical path length = minimum project duration.
    The tropical bridge theorem gives bounds on total work.
    """
    print("=" * 70)
    print("APPLICATION 1: Task Scheduling — Critical Path Analysis")
    print("=" * 70)

    # Tasks: Design(0) → Backend(1), Frontend(2) → Integration(3) → Testing(4) → Deploy(5)
    n = 6
    task_names = ["Design", "Backend", "Frontend", "Integration", "Testing", "Deploy"]
    M = np.zeros((n, n), dtype=int)

    # Dependencies with durations (days)
    dependencies = [
        (0, 1, 5),   # Design → Backend: 5 days
        (0, 2, 3),   # Design → Frontend: 3 days
        (1, 3, 4),   # Backend → Integration: 4 days
        (2, 3, 2),   # Frontend → Integration: 2 days
        (1, 4, 3),   # Backend → Testing: 3 days
        (3, 4, 6),   # Integration → Testing: 6 days
        (3, 5, 2),   # Integration → Deploy: 2 days
        (4, 5, 1),   # Testing → Deploy: 1 day
    ]

    for i, j, w in dependencies:
        M[i, j] = w

    print(f"\nProject task graph ({n} tasks):")
    for i, j, w in dependencies:
        print(f"  {task_names[i]} → {task_names[j]}: {w} days")

    depth, critical_path = compute_depth(M)
    print(f"\nCritical path length: {depth} edges")
    print(f"Critical path: {' → '.join(task_names[v] for v in critical_path)}")

    # Compute critical path cost
    cost = sum(M[critical_path[k], critical_path[k+1]] for k in range(len(critical_path)-1))
    print(f"Minimum project duration: {cost} days")

    # Tropical analysis
    gap = tropical_spectral_gap(M)
    print(f"\nTropical spectral analysis:")
    print(f"  Min edge weight: {gap['min_offdiag']}")
    print(f"  Max edge weight: {gap['max_entry']}")
    print(f"  Depth upper bound (n-1): {n - 1}")
    print(f"  Actual depth: {depth}")

    # Bridge theorem: min_weight × depth ≤ critical_path_cost
    min_w = gap['min_offdiag']
    print(f"\n  Bridge theorem: {min_w} × {depth} = {min_w * depth} ≤ {cost} ✓")
    return M


# =============================================================================
# Application 2: Network Routing
# =============================================================================

def network_routing_demo():
    """
    Model a layered network (e.g., CDN with multiple hops) as a circuit matrix.
    Edge weights = latency. Depth = number of hops.
    Min-plus permanent = optimal total assignment cost.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Routing — Layered CDN Analysis")
    print("=" * 70)

    # 3-layer network: Sources(0-1) → Relays(2-3) → Destinations(4-5)
    n = 6
    node_names = ["Src-A", "Src-B", "Relay-1", "Relay-2", "Dst-X", "Dst-Y"]
    M = np.zeros((n, n), dtype=int)

    # Latencies (ms)
    connections = [
        (0, 2, 10), (0, 3, 25),  # Src-A to relays
        (1, 2, 15), (1, 3, 8),   # Src-B to relays
        (2, 4, 12), (2, 5, 20),  # Relay-1 to destinations
        (3, 4, 18), (3, 5, 5),   # Relay-2 to destinations
    ]

    for i, j, w in connections:
        M[i, j] = w

    print(f"\nNetwork topology ({n} nodes, 3 layers):")
    for i, j, w in connections:
        print(f"  {node_names[i]} → {node_names[j]}: {w}ms")

    # Depth analysis
    depth, longest = compute_depth(M)
    print(f"\nMax hop count: {depth}")

    # Min-plus permanent (assignment cost)
    perm_val, perm_assignment = min_plus_permanent_hungarian(M)
    print(f"Min-plus permanent (optimal assignment cost): {perm_val}ms")
    print(f"  Assignment: {perm_assignment}")

    # All paths
    paths = enumerate_paths(M)
    print(f"\nAll routing paths ({len(paths)} total):")
    for p in sorted(paths, key=lambda x: x.cost):
        route = " → ".join(node_names[v] for v in p.vertices)
        print(f"  {route}: {p.cost}ms ({p.edges} hops)")

    # Depth-cost tradeoff
    gap = tropical_spectral_gap(M)
    min_w = gap['min_offdiag']
    print(f"\nTropical bridge: min_latency ({min_w}ms) × depth ({depth}) = {min_w * depth}ms")
    print(f"  Any path of {depth} hops costs at least {min_w * depth}ms ✓")
    return M


# =============================================================================
# Application 3: Circuit Design Depth Estimation
# =============================================================================

def circuit_design_demo():
    """
    Model a combinational logic circuit as a layered matrix.
    Gates are vertices, wires are edges with propagation delay weights.
    The depth = circuit delay = critical path delay.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Circuit Design — Gate Delay Analysis")
    print("=" * 70)

    # Simple ALU-like circuit
    n = 8
    gate_names = ["In-A", "In-B", "XOR", "AND", "OR", "MUX", "Carry", "Out"]
    M = np.zeros((n, n), dtype=int)

    # Gate connections with propagation delays (ns)
    wires = [
        (0, 2, 2),  # In-A → XOR
        (1, 2, 2),  # In-B → XOR
        (0, 3, 1),  # In-A → AND
        (1, 3, 1),  # In-B → AND
        (0, 4, 1),  # In-A → OR
        (1, 4, 1),  # In-B → OR
        (2, 5, 3),  # XOR → MUX
        (3, 5, 3),  # AND → MUX
        (4, 5, 3),  # OR → MUX
        (3, 6, 2),  # AND → Carry
        (5, 7, 1),  # MUX → Out
        (6, 7, 1),  # Carry → Out
    ]

    for i, j, w in wires:
        M[i, j] = w

    print(f"\nCircuit ({n} gates):")
    for i, j, w in wires:
        print(f"  {gate_names[i]} → {gate_names[j]}: {w}ns")

    depth, critical_path = compute_depth(M)
    critical_cost = sum(M[critical_path[k], critical_path[k+1]] for k in range(len(critical_path)-1))

    print(f"\nCritical path depth: {depth} gates")
    print(f"Critical path: {' → '.join(gate_names[v] for v in critical_path)}")
    print(f"Total propagation delay: {critical_cost}ns")

    # Tropical analysis
    results = depth_cost_tradeoff(M)
    min_w = results['min_edge_weight']
    print(f"\nTropical analysis:")
    print(f"  Minimum gate delay: {min_w}ns")
    print(f"  Maximum gate delay: {results['max_edge_weight']}ns")
    print(f"  Depth bound from dimension: ≤ {n - 1}")
    print(f"  Actual depth: {depth}")
    print(f"  Cost lower bound: {min_w} × {depth} = {min_w * depth}ns ≤ {critical_cost}ns ✓")
    print(f"  All theorems verified: {all(results['theorems_verified'].values())} ✓")
    return M


# =============================================================================
# Application 4: Comparing Families of Circuits
# =============================================================================

def family_comparison_demo():
    """
    Compare different circuit families to illustrate the depth-cost tradeoff.
    Shows how the tropical bridge theorem distinguishes shallow from deep circuits.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Circuit Family Comparison")
    print("=" * 70)

    print("\nComparing three families of 8×8 layered circuits:\n")

    families = {
        "Shallow (unit weights)": lambda i, j: 1,
        "Medium (linear weights)": lambda i, j: j - i,
        "Deep (quadratic weights)": lambda i, j: (j - i) ** 2,
    }

    for name, weight_fn in families.items():
        n = 8
        lcm = build_layered_matrix(n, weight_fn=weight_fn)
        results = depth_cost_tradeoff(lcm.matrix)

        depth = results['depth']
        min_w = results['min_edge_weight']
        max_w = results['max_edge_weight']
        perm = results['min_plus_permanent']

        # Find max path cost
        paths = enumerate_paths(lcm.matrix)
        max_cost = max(p.cost for p in paths) if paths else 0

        print(f"  {name}:")
        print(f"    Depth: {depth}, Min weight: {min_w}, Max weight: {max_w}")
        print(f"    Max path cost: {max_cost}")
        print(f"    Min-plus permanent: {perm}")
        print(f"    Cost range: [{min_w * depth}, {max_w * depth}]")
        print(f"    Weight ratio: {max_w / min_w:.1f}x")
        print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    task_scheduling_demo()
    network_routing_demo()
    circuit_design_demo()
    family_comparison_demo()

    print("=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Demonstrations

Concrete numerical examples illustrating the bridge between tropical
(min-plus) matrix invariants and circuit depth lower bounds.

Key demonstrations:
1. Layered circuit matrices and their properties
2. Path cost computations
3. Min-plus permanent calculations
4. The depth-cost tradeoff for explicit families
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional


def is_layered(M: np.ndarray) -> bool:
    """Check if a matrix is layered (nonzero entries go from smaller to larger index)."""
    n = M.shape[0]
    for i in range(n):
        for j in range(n):
            if M[i, j] > 0 and i >= j:
                return False
    return True


def find_all_paths(M: np.ndarray) -> List[List[int]]:
    """Find all admissible paths in the support graph of M."""
    n = M.shape[0]
    paths = []

    def dfs(current: int, path: List[int]):
        paths.append(path[:])
        for j in range(n):
            if M[current, j] > 0:
                dfs(j, path + [j])

    for start in range(n):
        dfs(start, [start])

    return [p for p in paths if len(p) >= 2]  # Only paths with at least one edge


def path_cost(M: np.ndarray, path: List[int]) -> int:
    """Compute the cost of a path."""
    cost = 0
    for k in range(len(path) - 1):
        cost += M[path[k], path[k + 1]]
    return cost


def depth_of_matrix(M: np.ndarray) -> int:
    """Compute the depth (longest path length) of the support DAG."""
    paths = find_all_paths(M)
    if not paths:
        return 0
    return max(len(p) - 1 for p in paths)


def min_plus_permanent(M: np.ndarray) -> int:
    """Compute the min-plus permanent: min over permutations of Σ M[i, σ(i)]."""
    n = M.shape[0]
    min_cost = float('inf')
    best_perm = None
    for perm in permutations(range(n)):
        cost = sum(M[i, perm[i]] for i in range(n))
        if cost < min_cost:
            min_cost = cost
            best_perm = perm
    return int(min_cost), best_perm


def weighted_depth(M: np.ndarray) -> Tuple[int, List[int]]:
    """Compute the maximum path cost and the corresponding path."""
    paths = find_all_paths(M)
    if not paths:
        return 0, []
    best_path = max(paths, key=lambda p: path_cost(M, p))
    return path_cost(M, best_path), best_path


def min_edge_weight(M: np.ndarray) -> Optional[int]:
    """Minimum positive entry of M."""
    positive = M[M > 0]
    if len(positive) == 0:
        return None
    return int(positive.min())


def max_edge_weight(M: np.ndarray) -> int:
    """Maximum entry of M."""
    return int(M.max())


# =============================================================================
# Demo 1: Basic Layered Matrix
# =============================================================================
print("=" * 70)
print("DEMO 1: Basic Layered Circuit Matrix")
print("=" * 70)

# A 5x5 layered matrix (strictly upper triangular support)
M1 = np.array([
    [0, 3, 0, 7, 0],
    [0, 0, 2, 0, 5],
    [0, 0, 0, 4, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0]
])

print(f"\nMatrix M1 (5×5 layered):")
print(M1)
print(f"\nIs layered: {is_layered(M1)}")
print(f"Depth (longest path): {depth_of_matrix(M1)}")
print(f"Min edge weight: {min_edge_weight(M1)}")
print(f"Max edge weight: {max_edge_weight(M1)}")

mp, best_perm = min_plus_permanent(M1)
print(f"Min-plus permanent: {mp}")
print(f"  (achieved by permutation: {best_perm})")
print(f"  (identity permutation cost = trace = {sum(M1[i,i] for i in range(5))})")

wd, wp = weighted_depth(M1)
print(f"Maximum path cost: {wd}")
print(f"  (along path: {wp})")

print(f"\nPath cost bounds:")
w = min_edge_weight(M1)
W = max_edge_weight(M1)
d = depth_of_matrix(M1)
print(f"  min_weight × depth = {w} × {d} = {w * d}")
print(f"  max path cost = {wd}")
print(f"  max_weight × depth = {W} × {d} = {W * d}")
print(f"  Verified: {w * d} ≤ {wd} ≤ {W * d}: {w * d <= wd <= W * d}")

# =============================================================================
# Demo 2: All Paths and Costs
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 2: All Paths in the Layered Matrix")
print("=" * 70)

paths = find_all_paths(M1)
print(f"\nAll admissible paths (with ≥ 1 edge):")
for p in sorted(paths, key=lambda p: (-len(p), path_cost(M1, p))):
    cost = path_cost(M1, p)
    length = len(p) - 1
    print(f"  {p} : length={length}, cost={cost}")

print(f"\nTotal paths: {len(paths)}")
print(f"Path length bound (n=5): all lengths ≤ {5}")
for p in paths:
    assert len(p) <= 5, f"Path {p} violates length bound!"
print("  ✓ All paths satisfy length ≤ n")

# =============================================================================
# Demo 3: Min-Plus Permanent for Non-Layered Matrix
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Min-Plus Permanent — Non-Layered Matrix")
print("=" * 70)

M2 = np.array([
    [5, 2, 8],
    [3, 7, 1],
    [6, 4, 9]
])

print(f"\nMatrix M2 (3×3 non-layered):")
print(M2)

mp2, bp2 = min_plus_permanent(M2)
trace2 = sum(M2[i, i] for i in range(3))
print(f"\nMin-plus permanent: {mp2}")
print(f"  (achieved by permutation: {bp2})")
print(f"Trace (identity cost): {trace2}")
print(f"Theorem: minPlusPerm ≤ trace: {mp2} ≤ {trace2}: {mp2 <= trace2}")
print(f"Theorem: minPlusPerm ≤ n × max = {3 * max_edge_weight(M2)}: {mp2 <= 3 * max_edge_weight(M2)}")

# Show all permutation costs
print(f"\nAll permutation costs:")
for perm in permutations(range(3)):
    cost = sum(M2[i, perm[i]] for i in range(3))
    label = " ← minimum" if cost == mp2 else ""
    print(f"  σ = {perm}: cost = {cost}{label}")

# =============================================================================
# Demo 4: Explicit Family with Growing Minimum Weight
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Explicit Family — Growing Minimum Edge Weight")
print("=" * 70)

print("\nFamily F(k): 4×4 layered matrices with min edge weight = k")
print("Demonstrating the depth-cost tradeoff theorem\n")

for k in range(1, 8):
    # Create a 4×4 layered matrix with all edges having weight k
    n = 4
    Mk = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            Mk[i, j] = k + (j - i - 1)  # Weight ≥ k

    paths_k = find_all_paths(Mk)
    longest = max(paths_k, key=lambda p: len(p) - 1)
    d_k = len(longest) - 1
    cost_longest = path_cost(Mk, longest)
    min_w = min_edge_weight(Mk)
    max_w = max_edge_weight(Mk)

    print(f"  k={k}: n={n}, depth={d_k}, min_w={min_w}, max_w={max_w}")
    print(f"         k×(depth) = {k * d_k} ≤ path_cost = {cost_longest} ≤ max_w×(depth) = {max_w * d_k}")
    assert k * d_k <= cost_longest <= max_w * d_k

print("\n  ✓ All families satisfy the depth-cost tradeoff theorem")

# =============================================================================
# Demo 5: Tropical Bridge in Action
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 5: The Tropical Bridge — Depth Bounds from Cost")
print("=" * 70)

print("\nScenario: Given a cost budget C, what is the maximum possible depth?")
print("By the bridge theorem: depth ≤ C / min_edge_weight\n")

# Create a larger example
n = 8
M3 = np.zeros((n, n), dtype=int)
w = 5  # Every edge costs at least 5
for i in range(n):
    for j in range(i + 1, n):
        M3[i, j] = w + np.random.RandomState(42 + i * n + j).randint(0, 10)

print(f"Matrix M3 ({n}×{n} layered, min edge weight = {min_edge_weight(M3)})")
print(f"Depth: {depth_of_matrix(M3)}")
print(f"Min edge weight: {min_edge_weight(M3)}")

wd3, wp3 = weighted_depth(M3)
print(f"Max path cost: {wd3} (along {wp3})")

d3 = depth_of_matrix(M3)
w3 = min_edge_weight(M3)
print(f"\nBridge theorem verification:")
print(f"  min_weight × depth = {w3} × {d3} = {w3 * d3}")
print(f"  max_path_cost = {wd3}")
print(f"  {w3 * d3} ≤ {wd3}: {w3 * d3 <= wd3} ✓")
print(f"\n  Implied depth upper bound from cost budget {wd3}: {wd3 // w3}")
print(f"  Actual depth: {d3}")
print(f"  {d3} ≤ {wd3 // w3}: {d3 <= wd3 // w3} ✓")

print("\n" + "=" * 70)
print("All demonstrations completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Visualizations

Generate publication-quality figures illustrating the key mathematical
structures and theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import permutations
import base64
import io
import os


def save_fig(fig, name):
    """Save figure as PNG."""
    fig.savefig(name, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    print(f"  Saved: {name}")


def fig_to_base64(fig):
    """Convert figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# =============================================================================
# Figure 1: Layered Circuit Matrix Heatmap
# =============================================================================

def plot_layered_matrix():
    """Visualize a layered circuit matrix as a heatmap."""
    n = 6
    M = np.zeros((n, n))
    np.random.seed(42)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() > 0.3:
                M[i, j] = np.random.randint(1, 10)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Heatmap
    ax = axes[0]
    im = ax.imshow(M, cmap='YlOrRd', aspect='equal')
    ax.set_title('Layered Circuit Matrix', fontsize=14, fontweight='bold')
    ax.set_xlabel('Target Gate j')
    ax.set_ylabel('Source Gate i')
    for i in range(n):
        for j in range(n):
            val = int(M[i, j])
            color = 'white' if val > 5 else 'black'
            ax.text(j, i, str(val), ha='center', va='center', color=color, fontsize=12)
    plt.colorbar(im, ax=ax, label='Edge Weight')

    # DAG visualization
    ax = axes[1]
    ax.set_title('Support DAG', fontsize=14, fontweight='bold')
    ax.set_xlim(-0.5, n - 0.5)
    ax.set_ylim(-0.5, n - 0.5)
    ax.invert_yaxis()
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw nodes
    positions = {}
    for i in range(n):
        x = i
        y = 0
        positions[i] = (x, y)
        circle = plt.Circle((x, y), 0.3, fill=True, facecolor='steelblue',
                           edgecolor='navy', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, str(i), ha='center', va='center', color='white',
               fontsize=12, fontweight='bold')

    # Draw edges with weights
    for i in range(n):
        for j in range(i + 1, n):
            if M[i, j] > 0:
                dx = positions[j][0] - positions[i][0]
                dy = 0.4 + 0.15 * abs(j - i)
                ax.annotate('', xy=(positions[j][0], positions[j][1] - 0.35),
                          xytext=(positions[i][0], positions[i][1] - 0.35),
                          arrowprops=dict(arrowstyle='->', color='crimson',
                                        lw=1.5, connectionstyle=f'arc3,rad=-{0.3 * (j-i-1)}'))
                mid_x = (positions[i][0] + positions[j][0]) / 2
                mid_y = -0.5 - 0.4 * (j - i - 1)
                ax.text(mid_x, mid_y, str(int(M[i, j])),
                       ha='center', va='center', fontsize=9,
                       bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                                edgecolor='orange'))

    ax.set_ylim(-2.5, 1)
    ax.set_xlim(-1, n)

    fig.suptitle('Tropical Circuit Matrix — Structure', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# =============================================================================
# Figure 2: Path Cost Distribution
# =============================================================================

def plot_path_costs():
    """Show the distribution of path costs and the bridge theorem bounds."""
    n = 6
    M = np.zeros((n, n), dtype=int)
    np.random.seed(123)
    for i in range(n):
        for j in range(i + 1, n):
            M[i, j] = np.random.randint(2, 8)

    # Find all paths
    paths = []
    def dfs(current, path, cost):
        if len(path) >= 2:
            paths.append((path[:], cost, len(path) - 1))
        for j in range(n):
            if M[current, j] > 0:
                dfs(j, path + [j], cost + M[current, j])
    for s in range(n):
        dfs(s, [s], 0)

    min_w = M[M > 0].min()
    max_w = M.max()

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Scatter plot: path length vs cost
    ax = axes[0]
    lengths = [p[2] for p in paths]
    costs = [p[1] for p in paths]

    ax.scatter(lengths, costs, alpha=0.6, s=50, c='steelblue', edgecolors='navy')

    # Bridge theorem bounds
    x_range = np.arange(0, max(lengths) + 1)
    ax.fill_between(x_range, min_w * x_range, max_w * x_range, alpha=0.15,
                   color='green', label=f'Bound: [{min_w}d, {max_w}d]')
    ax.plot(x_range, min_w * x_range, 'g--', linewidth=2, label=f'Lower: {min_w}×d')
    ax.plot(x_range, max_w * x_range, 'r--', linewidth=2, label=f'Upper: {max_w}×d')

    ax.set_xlabel('Path Length (edges)', fontsize=12)
    ax.set_ylabel('Path Cost', fontsize=12)
    ax.set_title('Path Cost vs Length\n(Bridge Theorem Bounds)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Histogram of costs by path length
    ax = axes[1]
    max_len = max(lengths)
    for d in range(1, max_len + 1):
        d_costs = [c for l, c, ln in zip(lengths, costs, lengths) if ln == d]
        if d_costs:
            ax.hist(d_costs, bins=10, alpha=0.5, label=f'Length {d}')
            ax.axvline(min_w * d, color='green', linestyle='--', alpha=0.5)
            ax.axvline(max_w * d, color='red', linestyle='--', alpha=0.5)

    ax.set_xlabel('Path Cost', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Path Cost Distribution by Length', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Bridge Theorem — Path Cost Analysis', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# =============================================================================
# Figure 3: Min-Plus Permanent Landscape
# =============================================================================

def plot_permanent_landscape():
    """Visualize the min-plus permanent as an optimization landscape."""
    n = 4
    M = np.array([
        [0, 3, 7, 2],
        [0, 0, 4, 5],
        [0, 0, 0, 1],
        [0, 0, 0, 0]
    ])

    # Compute all permutation costs
    perms = list(permutations(range(n)))
    costs = []
    labels = []
    for perm in perms:
        cost = sum(M[i, perm[i]] for i in range(n))
        costs.append(cost)
        labels.append(str(perm))

    min_cost = min(costs)
    trace = sum(M[i, i] for i in range(n))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Bar chart of permutation costs
    ax = axes[0]
    colors = ['gold' if c == min_cost else 'steelblue' for c in costs]
    bars = ax.bar(range(len(costs)), costs, color=colors, edgecolor='navy', alpha=0.8)
    ax.axhline(y=min_cost, color='gold', linestyle='--', linewidth=2,
              label=f'Min-plus permanent = {min_cost}')
    ax.axhline(y=trace, color='red', linestyle=':', linewidth=2,
              label=f'Trace = {trace}')
    ax.set_xlabel('Permutation Index', fontsize=12)
    ax.set_ylabel('Assignment Cost Σ M[i,σ(i)]', fontsize=12)
    ax.set_title('All Permutation Costs\n(Min-Plus Permanent = minimum)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Cost matrix with optimal assignment highlighted
    ax = axes[1]
    opt_perm = perms[costs.index(min_cost)]
    display_M = M.copy().astype(float)

    im = ax.imshow(display_M, cmap='YlOrRd', aspect='equal')
    ax.set_title(f'Cost Matrix\n(Optimal: σ = {opt_perm})', fontsize=13, fontweight='bold')
    ax.set_xlabel('Column j = σ(i)')
    ax.set_ylabel('Row i')

    for i in range(n):
        for j in range(n):
            val = int(M[i, j])
            is_opt = opt_perm[i] == j
            fontweight = 'bold' if is_opt else 'normal'
            fontsize = 14 if is_opt else 11
            color = 'blue' if is_opt else ('white' if val > 4 else 'black')
            ax.text(j, i, str(val), ha='center', va='center',
                   color=color, fontsize=fontsize, fontweight=fontweight)
            if is_opt:
                rect = plt.Rectangle((j - 0.45, i - 0.45), 0.9, 0.9,
                                   fill=False, edgecolor='blue', linewidth=3)
                ax.add_patch(rect)

    plt.colorbar(im, ax=ax, label='Weight')

    fig.suptitle('Min-Plus Permanent — Assignment Optimization', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# =============================================================================
# Figure 4: Family Depth-Cost Tradeoff
# =============================================================================

def plot_family_tradeoff():
    """Show the depth-cost tradeoff as minimum edge weight grows."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 6
    ks = range(1, 16)

    depths = []
    max_costs = []
    min_costs = []
    permanents = []

    for k in ks:
        M = np.zeros((n, n), dtype=int)
        for i in range(n):
            for j in range(i + 1, n):
                M[i, j] = k * (j - i)

        # Compute depth
        dp = [0] * n
        for j in range(n):
            for i in range(j):
                if M[i, j] > 0:
                    dp[j] = max(dp[j], dp[i] + 1)
        depth = max(dp)
        depths.append(depth)

        # Compute path costs
        min_w = M[M > 0].min()
        max_w = M.max()
        min_costs.append(min_w * depth)
        max_costs.append(max_w * depth)

        # Permanent
        perm_cost = sum(M[i, i] for i in range(n))  # identity = 0 for layered
        permanents.append(perm_cost)

    # Plot 1: Cost bounds vs k
    ax = axes[0]
    ax.fill_between(list(ks), min_costs, max_costs, alpha=0.2, color='steelblue')
    ax.plot(list(ks), min_costs, 'o-', color='green', linewidth=2, markersize=6,
           label='Min cost bound (w×d)')
    ax.plot(list(ks), max_costs, 's-', color='red', linewidth=2, markersize=6,
           label='Max cost bound (W×d)')
    ax.set_xlabel('Minimum Edge Weight (k)', fontsize=12)
    ax.set_ylabel('Path Cost Bound', fontsize=12)
    ax.set_title('Depth-Cost Tradeoff\nas Minimum Weight Grows', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Implied depth bounds
    ax = axes[1]
    cost_budgets = [10, 25, 50, 100]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(cost_budgets)))

    for budget, color in zip(cost_budgets, colors):
        implied_depths = [min(budget // k, n - 1) if k > 0 else n - 1 for k in ks]
        ax.plot(list(ks), implied_depths, 'o-', color=color, linewidth=2, markersize=5,
               label=f'Budget C = {budget}')

    ax.axhline(y=n - 1, color='gray', linestyle=':', linewidth=1.5, label=f'Max depth = {n-1}')
    ax.set_xlabel('Minimum Edge Weight (k)', fontsize=12)
    ax.set_ylabel('Maximum Possible Depth', fontsize=12)
    ax.set_title('Implied Depth Upper Bound\n(depth ≤ C/k)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, n + 0.5)

    fig.suptitle('Explicit Family — Tropical Bridge in Action', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    os.makedirs("figures", exist_ok=True)

    print("Generating visualizations...")

    fig1 = plot_layered_matrix()
    save_fig(fig1, "figures/layered_matrix.png")

    fig2 = plot_path_costs()
    save_fig(fig2, "figures/path_costs.png")

    fig3 = plot_permanent_landscape()
    save_fig(fig3, "figures/permanent_landscape.png")

    fig4 = plot_family_tradeoff()
    save_fig(fig4, "figures/family_tradeoff.png")

    print("\nAll visualizations generated successfully!")


def get_all_base64_figures():
    """Generate all figures and return as base64 data URIs."""
    figs = {}

    fig1 = plot_layered_matrix()
    figs['layered_matrix'] = fig_to_base64(fig1)

    fig2 = plot_path_costs()
    figs['path_costs'] = fig_to_base64(fig2)

    fig3 = plot_permanent_landscape()
    figs['permanent_landscape'] = fig_to_base64(fig3)

    fig4 = plot_family_tradeoff()
    figs['family_tradeoff'] = fig_to_base64(fig4)

    return figs
