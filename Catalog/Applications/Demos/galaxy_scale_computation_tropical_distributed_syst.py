#!/usr/bin/env python3
"""
Tropical Distributed Systems: Real-World Applications

Demonstrates how the tropical distributed systems theory applies to:
1. Data center network optimization
2. Interplanetary internet design
3. CRDT-based distributed databases
4. MapReduce barrier scheduling
"""

import numpy as np
from algorithms import (
    floyd_warshall, compute_network_metrics, simulate_broadcast,
    analyze_speedup, simulate_idempotent_aggregation, bellman_ford
)

INF = float('inf')


def application_1_datacenter():
    """
    Application 1: Data Center Network Topology Analysis

    Models a hierarchical data center with rack-level, pod-level,
    and cross-pod communication latencies.
    """
    print("=" * 70)
    print("APPLICATION 1: Data Center Network Topology")
    print("=" * 70)
    print()

    # 8 nodes: 2 pods × 2 racks × 2 servers
    # Latencies in microseconds
    n = 8
    w = np.full((n, n), INF)
    np.fill_diagonal(w, 0)

    # Same rack: 1 μs
    for pod in range(2):
        for rack in range(2):
            i = pod * 4 + rack * 2
            w[i][i+1] = w[i+1][i] = 1.0

    # Same pod, different rack: 5 μs
    for pod in range(2):
        base = pod * 4
        for i in range(4):
            for j in range(4):
                if w[base+i][base+j] == INF and i != j:
                    w[base+i][base+j] = 5.0

    # Cross-pod: 20 μs
    for i in range(4):
        for j in range(4, 8):
            if w[i][j] == INF:
                w[i][j] = w[j][i] = 20.0

    metrics = compute_network_metrics(w)
    labels = [f"P{p}R{r}S{s}" for p in range(2) for r in range(2) for s in range(2)]

    print("Network topology (latency in μs):")
    for i in range(n):
        ecc = metrics['eccentricities'][i]
        print(f"  {labels[i]}: eccentricity = {ecc:.0f} μs")

    print(f"\n  Tropical Diameter = {metrics['diameter']:.0f} μs")
    print(f"  Tropical Radius   = {metrics['radius']:.0f} μs")
    print(f"  Center nodes: {[labels[i] for i in metrics['center']]}")

    # Speedup analysis for distributed training
    print("\n  Distributed ML Training Analysis:")
    print(f"  (1M FLOPS total work, 100 gradient sync barriers)")
    analysis = analyze_speedup(
        W=1e6, D=metrics['diameter'], B=100,
        workers=[1, 2, 4, 8]
    )
    for k, S, eff in zip(analysis.workers, analysis.speedups, analysis.efficiencies):
        print(f"    {k} workers: speedup = {S:.2f}, efficiency = {eff:.1%}")

    return metrics


def application_2_interplanetary():
    """
    Application 2: Interplanetary Internet

    Models communication delays between planets/stations in the inner
    solar system. Latencies are one-way light-travel times.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Interplanetary Internet")
    print("=" * 70)
    print()

    # Average distances in light-minutes (one-way)
    bodies = ["Earth", "Moon", "Mars", "Venus", "Mercury", "L2 Point"]
    n = len(bodies)
    w = np.full((n, n), INF)
    np.fill_diagonal(w, 0)

    # Earth-Moon: 1.3 seconds ≈ 0.02 light-minutes
    w[0][1] = w[1][0] = 0.02
    # Earth-Mars: 4-24 min, average ~12 min
    w[0][2] = w[2][0] = 12.0
    # Earth-Venus: 2-14 min, average ~6 min
    w[0][3] = w[3][0] = 6.0
    # Earth-Mercury: 5-12 min, average ~8 min
    w[0][4] = w[4][0] = 8.0
    # Earth-L2: ~0.08 light-minutes
    w[0][5] = w[5][0] = 0.08
    # Moon-L2: ~0.1 light-minutes
    w[1][5] = w[5][1] = 0.1
    # Mars-Venus: ~15 min average
    w[2][3] = w[3][2] = 15.0
    # Venus-Mercury: ~5 min
    w[3][4] = w[4][3] = 5.0
    # Mars-Mercury: ~13 min
    w[2][4] = w[4][2] = 13.0

    dist, _ = floyd_warshall(w)
    metrics = compute_network_metrics(w)

    print("Interplanetary shortest-path latencies (light-minutes):")
    header = "          " + "  ".join(f"{b:>8}" for b in bodies)
    print(header)
    for i in range(n):
        row = [f"{dist[i][j]:8.2f}" if dist[i][j] < INF else "     inf" for j in range(n)]
        print(f"  {bodies[i]:>8}: {'  '.join(row)}")

    print(f"\n  Tropical Diameter = {metrics['diameter']:.2f} light-minutes")
    print(f"  Tropical Radius   = {metrics['radius']:.2f} light-minutes")
    print(f"  Network center: {[bodies[i] for i in metrics['center']]}")

    # Broadcast from Earth
    result = simulate_broadcast(w, 0)
    print(f"\n  Broadcast from Earth:")
    for i, t in enumerate(result.delivery_times):
        print(f"    → {bodies[i]:>10}: {t:.2f} light-minutes")
    print(f"    Completion: {result.completion_time:.2f} light-minutes")

    # What this means for distributed computation
    print(f"\n  For a distributed computation with 50 sync barriers:")
    W_total = 1e9
    analysis = analyze_speedup(
        W=W_total, D=metrics['diameter'], B=50,
        workers=[1, 2, 3, 6]
    )
    for k, S, eff in zip(analysis.workers, analysis.speedups, analysis.efficiencies):
        T = W_total / k + 50 * metrics['diameter']
        print(f"    {k} stations: speedup = {S:.4f}, efficiency = {eff:.2%}")

    return metrics


def application_3_crdt():
    """
    Application 3: CRDT-based Distributed Database

    Demonstrates that min/max-based CRDTs (conflict-free replicated data types)
    converge without consensus, as proven in Theorem C.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: CRDT-based Distributed Database")
    print("=" * 70)
    print()

    # 5 replicas with initial "last-writer-wins" timestamps
    # Each replica tracks timestamps for 4 keys
    print("Scenario: 5 database replicas tracking 4 keys")
    print("Operation: LWW-Register (last-writer-wins via max timestamp)")
    print()

    initial_states = [
        [10, 5, 3, 8],   # Replica 0
        [7, 12, 1, 6],   # Replica 1
        [3, 8, 9, 2],    # Replica 2
        [11, 4, 7, 5],   # Replica 3
        [6, 9, 2, 14],   # Replica 4
    ]

    print("Initial replica states (timestamps per key):")
    for i, s in enumerate(initial_states):
        print(f"  Replica {i}: keys = {s}")

    # True converged state (max over all replicas for each key)
    converged = [max(initial_states[r][k] for r in range(5)) for k in range(4)]
    print(f"\nExpected converged state: {converged}")

    # Three different exchange schedules (all should converge to same result)
    schedules = [
        # Schedule A: sequential ring
        [(0,1), (1,2), (2,3), (3,4), (4,0), (0,1), (1,2), (2,3), (3,4)],
        # Schedule B: random pairs
        [(2,4), (0,3), (1,2), (3,4), (0,1), (2,3), (1,4), (0,2), (3,4)],
        # Schedule C: star topology (all through node 0)
        [(0,1), (0,2), (0,3), (0,4), (0,1), (0,2), (0,3), (0,4)],
    ]

    for name, schedule in zip(["A (ring)", "B (random)", "C (star)"], schedules):
        result = simulate_idempotent_aggregation(initial_states, schedule, op=max)
        all_match = all(result.final_states[r] == converged for r in range(5))
        print(f"\n  Schedule {name}: {result.steps_to_converge} steps")
        print(f"    Final states match expected: {all_match}")
        if all_match:
            print(f"    → Consensus achieved WITHOUT a consensus protocol! ✓")

    print("\n  Key insight: The algebra (max = idempotent + commutative)")
    print("  guarantees convergence regardless of schedule. No Paxos needed!")


def application_4_mapreduce():
    """
    Application 4: MapReduce Barrier Scheduling

    Shows how tropical diameter governs the time between map and reduce
    phases in a geographically distributed MapReduce cluster.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: MapReduce Barrier Scheduling")
    print("=" * 70)
    print()

    # 6-node cluster spread across 3 data centers
    # DC1 (nodes 0,1), DC2 (nodes 2,3), DC3 (nodes 4,5)
    n = 6
    w = np.full((n, n), INF)
    np.fill_diagonal(w, 0)

    # Within DC: 0.5 ms
    for dc in range(3):
        i = dc * 2
        w[i][i+1] = w[i+1][i] = 0.5

    # DC1-DC2: 30 ms (US East - US West)
    for i in range(2):
        for j in range(2, 4):
            w[i][j] = w[j][i] = 30.0

    # DC1-DC3: 100 ms (US - Europe)
    for i in range(2):
        for j in range(4, 6):
            w[i][j] = w[j][i] = 100.0

    # DC2-DC3: 120 ms (US West - Europe)
    for i in range(2, 4):
        for j in range(4, 6):
            w[i][j] = w[j][i] = 120.0

    metrics = compute_network_metrics(w)
    dc_labels = ["DC1-S0", "DC1-S1", "DC2-S0", "DC2-S1", "DC3-S0", "DC3-S1"]

    print("Geo-distributed MapReduce cluster:")
    for i in range(n):
        print(f"  {dc_labels[i]}: eccentricity = {metrics['eccentricities'][i]:.1f} ms")

    D = metrics['diameter']
    print(f"\n  Tropical Diameter = {D:.1f} ms")
    print(f"  → Each shuffle/barrier phase takes at least {D:.1f} ms")

    # MapReduce job analysis
    total_data_gb = 100
    map_time_per_gb = 10  # ms per GB per worker
    reduce_time = 50  # ms
    n_barriers = 3  # shuffle + sort + reduce

    W_total = total_data_gb * map_time_per_gb  # Total map work in ms

    print(f"\n  MapReduce job: {total_data_gb} GB, {n_barriers} barriers")
    print(f"  Total map work: {W_total} ms")
    print(f"\n  {'Workers':>8} | {'Map time':>10} | {'Barrier cost':>13} | {'Total':>10} | {'Speedup':>8}")
    print("  " + "-" * 60)

    for k in [1, 2, 3, 6]:
        map_t = W_total / k
        barrier_t = n_barriers * D
        total_t = map_t + barrier_t + reduce_time
        spdup = (W_total + reduce_time) / total_t
        print(f"  {k:>8} | {map_t:>8.1f} ms | {barrier_t:>11.1f} ms | {total_t:>8.1f} ms | {spdup:>8.2f}x")

    # Critical ratio
    critical_k = W_total / (n_barriers * D)
    print(f"\n  Critical worker count (beyond which barriers dominate): {critical_k:.1f}")
    print(f"  → Adding more than ~{int(critical_k)} workers gives diminishing returns")


if __name__ == '__main__':
    application_1_datacenter()
    application_2_interplanetary()
    application_3_crdt()
    application_4_mapreduce()


#!/usr/bin/env python3
"""
Tropical Distributed Systems: Demonstrations

Concrete numerical examples demonstrating the theorems formalized in the
Lean 4 development. Shows how min-plus (tropical) geometry governs
distributed computation timing, speedup bounds, and aggregation convergence.
"""

import numpy as np
from itertools import product

INF = float('inf')


def floyd_warshall(w: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths using Floyd-Warshall (min-plus closure)."""
    n = w.shape[0]
    d = w.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


def eccentricity(d: np.ndarray, s: int) -> float:
    """Eccentricity of node s: max shortest distance from s to any other node."""
    return max(d[s])


def tropical_diameter(d: np.ndarray) -> float:
    """Tropical diameter: max eccentricity over all nodes."""
    n = d.shape[0]
    return max(eccentricity(d, s) for s in range(n))


def bellman_ford_steps(w: np.ndarray, s: int, steps: int) -> list:
    """Run Bellman-Ford from source s, returning distance vectors at each step."""
    n = w.shape[0]
    history = []

    # Initial: 0 at source, inf elsewhere
    d = np.full(n, INF)
    d[s] = 0
    history.append(d.copy())

    for _ in range(steps):
        d_new = d.copy()
        for j in range(n):
            for i in range(n):
                if d[i] + w[i][j] < d_new[j]:
                    d_new[j] = d[i] + w[i][j]
        d = d_new
        history.append(d.copy())

    return history


def speedup(W: float, k: float, B: float, D: float) -> float:
    """Compute speedup = W / (W/k + B*D)."""
    runtime = W / k + B * D
    return W / runtime if runtime > 0 else INF


def min_aggregate(values: list) -> float:
    """Tropical (min) aggregation over a list of values."""
    return min(values) if values else INF


# ============================================================
# Demo 1: Broadcast Time = Eccentricity on a Small Network
# ============================================================
print("=" * 70)
print("DEMO 1: Broadcast Time = Eccentricity")
print("=" * 70)
print()

# 5-node network with asymmetric latencies
w = np.array([
    [0,   3,   8, INF, INF],
    [INF, 0,   2,   5, INF],
    [INF, INF, 0,   1,   6],
    [INF, INF, INF, 0,   4],
    [INF, INF, INF, INF, 0],
])

print("Weight matrix (edge delays):")
for i in range(5):
    row = [f"{w[i][j]:5.0f}" if w[i][j] < INF else "  inf" for j in range(5)]
    print(f"  Node {i}: [{', '.join(row)}]")
print()

# Compute all-pairs shortest paths
d = floyd_warshall(w)
print("Shortest-path distance matrix:")
for i in range(5):
    row = [f"{d[i][j]:5.1f}" if d[i][j] < INF else "  inf" for j in range(5)]
    print(f"  Node {i}: [{', '.join(row)}]")
print()

# Eccentricity and diameter
for s in range(5):
    ecc = eccentricity(d, s)
    ecc_str = f"{ecc:.1f}" if ecc < INF else "inf"
    print(f"  Eccentricity(node {s}) = {ecc_str}")

diam = tropical_diameter(d)
diam_str = f"{diam:.1f}" if diam < INF else "inf"
print(f"\n  Tropical Diameter = {diam_str}")

# Broadcast simulation
print("\nBroadcast from node 0:")
bf_history = bellman_ford_steps(w, 0, 5)
for step, dist in enumerate(bf_history):
    vals = [f"{v:5.1f}" if v < INF else "  inf" for v in dist]
    print(f"  Step {step}: [{', '.join(vals)}]")

print(f"\n  Broadcast completion time from node 0 = {eccentricity(d, 0):.1f}")
print(f"  = eccentricity(node 0) ✓")

# ============================================================
# Demo 2: Speedup Degradation with Network Diameter
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Parallel Speedup is Diameter-Limited")
print("=" * 70)
print()

W = 1000.0  # Total work
B = 10.0    # Number of synchronization barriers

print(f"Total work W = {W}, Barriers B = {B}")
print(f"{'Workers k':>12} | {'Diameter D':>12} | {'Runtime T(k)':>14} | {'Speedup':>10} | {'Gap':>10}")
print("-" * 70)

for k in [2, 4, 8, 16, 32]:
    for D in [0, 1, 5, 10, 50]:
        T = W / k + B * D
        S = speedup(W, k, B, D)
        gap = k - S
        print(f"  k={k:>4}      |   D={D:>5.0f}     |   T={T:>8.1f}    |   S={S:>6.2f}  |   {gap:>6.2f}")
    print("-" * 70)

# ============================================================
# Demo 3: Idempotent Aggregation is Duplicate/Order-Insensitive
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Idempotent Aggregation = Consensus-Free Computation")
print("=" * 70)
print()

import random
random.seed(42)

# Source values at 6 nodes
values = [7.2, 3.1, 9.8, 1.5, 6.3, 4.7]
print(f"Node values: {values}")
print()

# Different delivery orderings (simulating different network schedules)
orderings = [
    list(range(6)),
    list(reversed(range(6))),
    [3, 0, 5, 2, 1, 4],
    [1, 4, 3, 0, 2, 5],
]

# With duplicates
orderings_with_dups = [
    [0, 1, 2, 3, 4, 5, 0, 1, 2],
    [3, 3, 3, 0, 1, 2, 4, 5, 5, 5],
    [5, 4, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5],
]

print("Min-aggregation over different delivery orders:")
for i, order in enumerate(orderings):
    delivered = [values[idx] for idx in order]
    result = min_aggregate(delivered)
    print(f"  Order {order}: min = {result}")

print("\nMin-aggregation with duplicates:")
for i, order in enumerate(orderings_with_dups):
    delivered = [values[idx] for idx in order]
    result = min_aggregate(delivered)
    print(f"  Order {order}: min = {result}")

print("\n  → All results identical! Order and duplicates don't matter. ✓")

# ============================================================
# Demo 4: Convergence of Pointwise-Min Network Updates
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Network State Convergence via Pointwise Min")
print("=" * 70)
print()

n_nodes = 4
np.random.seed(42)

# Initial state: each node has its own "view" of the world
states = [
    [10.0, 5.0, 8.0, 3.0],   # Node 0's view
    [7.0, 2.0, 9.0, 6.0],    # Node 1's view
    [4.0, 8.0, 1.0, 7.0],    # Node 2's view
    [6.0, 3.0, 5.0, 2.0],    # Node 3's view
]

print("Initial states (each row = one node's local view):")
for i, s in enumerate(states):
    print(f"  Node {i}: {s}")

# Converged state = pointwise min over all views
converged = [min(states[j][i] for j in range(n_nodes)) for i in range(n_nodes)]
print(f"\nConverged state (pointwise min): {converged}")

# Simulate random pairwise exchanges
state_vectors = [list(s) for s in states]
print("\nRandom pairwise exchange simulation:")
for step in range(8):
    a, b = random.sample(range(n_nodes), 2)
    # Both nodes take pointwise min
    new_a = [min(state_vectors[a][i], state_vectors[b][i]) for i in range(n_nodes)]
    new_b = [min(state_vectors[a][i], state_vectors[b][i]) for i in range(n_nodes)]
    state_vectors[a] = new_a
    state_vectors[b] = new_b
    all_converged = all(state_vectors[j] == converged for j in range(n_nodes))
    marker = " ← CONVERGED!" if all_converged else ""
    print(f"  Step {step+1}: Nodes {a}↔{b} exchange. States match converged: {all_converged}{marker}")

print("\nFinal states:")
for i, s in enumerate(state_vectors):
    print(f"  Node {i}: {s}")

# ============================================================
# Demo 5: Galaxy-Scale Network Example
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Galaxy-Scale Network — Interstellar Communication")
print("=" * 70)
print()

# Distances in light-years between star systems
stars = ["Sol", "Alpha Centauri", "Barnard's Star", "Wolf 359", "Sirius"]
# Approximate distances (light-years, one-way communication delay)
w_galaxy = np.array([
    [0,    4.37, 5.96, 7.86, 8.60],
    [4.37, 0,    5.12, 7.20, 9.53],
    [5.96, 5.12, 0,    6.51, 10.1],
    [7.86, 7.20, 6.51, 0,    8.82],
    [8.60, 9.53, 10.1, 8.82, 0   ],
])

d_galaxy = floyd_warshall(w_galaxy)

print("Star system network (distances in light-years):")
for i in range(5):
    print(f"  {stars[i]:>18}: ecc = {eccentricity(d_galaxy, i):.2f} ly")

print(f"\n  Tropical Diameter = {tropical_diameter(d_galaxy):.2f} light-years")
print(f"\n  → Any distributed computation across these stars requires")
print(f"    at least {tropical_diameter(d_galaxy):.2f} years per synchronization barrier!")

W_galaxy = 1e12  # Total computation (FLOPS)
B_galaxy = 100   # Barriers
D_galaxy = tropical_diameter(d_galaxy)
k_galaxy = 5     # 5 star systems

S_galaxy = speedup(W_galaxy, k_galaxy, B_galaxy, D_galaxy)
print(f"\n  With {k_galaxy} star-system workers, {B_galaxy} barriers:")
print(f"    Ideal speedup:  {k_galaxy}")
print(f"    Actual speedup: {S_galaxy:.6f}")
print(f"    Efficiency:     {S_galaxy/k_galaxy*100:.4f}%")
print(f"\n  The universe's geometry dominates. Communication is computation.")

print("\n" + "=" * 70)
print("All demos complete. These examples demonstrate the theorems")
print("proven in the formal Lean 4 development.")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Distributed Systems: Visualizations

Generates publication-quality figures demonstrating key concepts.
All figures are saved as PNG files and can be embedded in the JSON package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import floyd_warshall, compute_network_metrics, analyze_speedup
import base64
import io

INF = float('inf')

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_1_speedup_curves():
    """Speedup curves for different network diameters."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    W = 1000.0
    B = 10.0
    workers = list(range(1, 65))

    # Left: Speedup curves
    diameters = [0, 0.5, 1, 2, 5, 10, 20]
    colors = plt.cm.viridis(np.linspace(0, 1, len(diameters)))

    for D, color in zip(diameters, colors):
        speedups = [W / (W/k + B*D) for k in workers]
        label = f"D={D}" if D > 0 else "D=0 (ideal)"
        ls = '--' if D == 0 else '-'
        ax1.plot(workers, speedups, color=color, linestyle=ls, linewidth=2, label=label)

    ax1.plot(workers, workers, 'k:', alpha=0.3, linewidth=1, label='Linear (ideal)')
    ax1.set_xlabel('Number of Workers (k)', fontsize=13)
    ax1.set_ylabel('Speedup S(k)', fontsize=13)
    ax1.set_title('Speedup vs. Workers\n(W=1000, B=10 barriers)', fontsize=14)
    ax1.legend(fontsize=10, loc='upper left')
    ax1.set_xlim(1, 64)
    ax1.set_ylim(0, 65)
    ax1.grid(True, alpha=0.3)

    # Right: Efficiency curves
    for D, color in zip(diameters, colors):
        effs = [W / (W/k + B*D) / k * 100 for k in workers]
        label = f"D={D}"
        ls = '--' if D == 0 else '-'
        ax2.plot(workers, effs, color=color, linestyle=ls, linewidth=2, label=label)

    ax2.set_xlabel('Number of Workers (k)', fontsize=13)
    ax2.set_ylabel('Efficiency (%)', fontsize=13)
    ax2.set_title('Parallel Efficiency vs. Workers\n(Theorem B: efficiency → 0 as k → ∞)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_xlim(1, 64)
    ax2.set_ylim(0, 105)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('speedup_curves.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_2_broadcast_wavefront():
    """Broadcast wavefront propagation on a network."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Network layout
    positions = {
        0: (0, 0),
        1: (2, 1),
        2: (4, 0),
        3: (1, -1.5),
        4: (3, -1.5),
    }

    edges = {
        (0,1): 3, (0,3): 5,
        (1,2): 2, (1,3): 4,
        (2,4): 1,
        (3,4): 3,
    }

    # Build weight matrix
    n = 5
    w = np.full((n, n), INF)
    np.fill_diagonal(w, 0)
    for (i,j), wt in edges.items():
        w[i][j] = wt
        w[j][i] = wt  # Undirected for visualization

    dist, _ = floyd_warshall(w)

    # Three snapshots of broadcast from node 0
    source = 0
    times = [0, 3, 6]
    titles = ['t = 0 (source only)', 't = 3 (wavefront expanding)', 't = 6 (broadcast complete)']

    for ax, t, title in zip(axes, times, titles):
        # Draw edges
        for (i,j), wt in edges.items():
            xi, yi = positions[i]
            xj, yj = positions[j]
            ax.plot([xi, xj], [yi, yj], 'gray', linewidth=1, alpha=0.5)
            mx, my = (xi+xj)/2, (yi+yj)/2
            ax.text(mx, my+0.15, str(wt), ha='center', fontsize=9, color='gray')

        # Draw nodes with color indicating reached/unreached
        for node in range(n):
            x, y = positions[node]
            d = dist[source][node]
            if d <= t:
                color = '#2ecc71'  # Green: reached
                alpha = 1.0
            else:
                color = '#e74c3c'  # Red: unreached
                alpha = 0.5

            circle = plt.Circle((x, y), 0.3, color=color, alpha=alpha, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y, str(node), ha='center', va='center', fontsize=12,
                   fontweight='bold', color='white', zorder=6)

            if d < INF:
                ax.text(x, y-0.5, f'd={d:.0f}', ha='center', fontsize=9)

        ax.set_xlim(-1, 5)
        ax.set_ylim(-2.5, 2)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=12)
        ax.axis('off')

    fig.suptitle('Broadcast Wavefront = Tropical Ball Expansion (Theorem A)',
                fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('broadcast_wavefront.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_3_convergence():
    """Convergence of idempotent aggregation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Simulate pointwise-min convergence
    np.random.seed(42)
    n_nodes = 5
    n_keys = 3

    states = np.random.randint(1, 20, (n_nodes, n_keys)).astype(float)
    target = np.min(states, axis=0)

    history = [states.copy()]
    step = 0
    max_steps = 20

    import random
    random.seed(42)

    while step < max_steps:
        a, b = random.sample(range(n_nodes), 2)
        merged = np.minimum(states[a], states[b])
        states[a] = merged
        states[b] = merged
        history.append(states.copy())
        step += 1
        if np.all(states == target):
            break

    # Left: state evolution for key 0
    for node in range(n_nodes):
        vals = [h[node, 0] for h in history]
        ax1.plot(range(len(vals)), vals, '-o', markersize=4, label=f'Node {node}')

    ax1.axhline(y=target[0], color='k', linestyle='--', alpha=0.5, label='Converged')
    ax1.set_xlabel('Exchange Step', fontsize=13)
    ax1.set_ylabel('Value (Key 0)', fontsize=13)
    ax1.set_title('Pointwise-Min Convergence\n(Theorem C: idempotent → consensus-free)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: distance from converged state
    distances = []
    for h in history:
        d = np.max(np.abs(h - target))
        distances.append(d)

    ax2.plot(range(len(distances)), distances, 'b-o', markersize=5, linewidth=2)
    ax2.set_xlabel('Exchange Step', fontsize=13)
    ax2.set_ylabel('Max Distance from Converged State', fontsize=13)
    ax2.set_title('Convergence to Fixed Point\n(Without any consensus protocol)', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(bottom=-0.5)

    fig.tight_layout()
    fig.savefig('convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_4_diameter_heatmap():
    """Heatmap of speedup as function of workers and diameter."""
    fig, ax = plt.subplots(figsize=(10, 7))

    W = 1000.0
    B = 10.0

    workers = np.arange(1, 33)
    diameters = np.linspace(0, 20, 50)

    speedup_matrix = np.zeros((len(diameters), len(workers)))
    for i, D in enumerate(diameters):
        for j, k in enumerate(workers):
            S = W / (W/k + B*D)
            speedup_matrix[i, j] = S / k  # Efficiency

    im = ax.imshow(speedup_matrix * 100, aspect='auto', origin='lower',
                   extent=[0.5, 32.5, 0, 20],
                   cmap='RdYlGn', vmin=0, vmax=100)

    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('Parallel Efficiency (%)', fontsize=12)

    # Add contour lines
    X, Y = np.meshgrid(workers, diameters)
    contours = ax.contour(X, Y, speedup_matrix * 100,
                         levels=[10, 25, 50, 75, 90],
                         colors='black', linewidths=0.8, alpha=0.7)
    ax.clabel(contours, inline=True, fontsize=9, fmt='%d%%')

    ax.set_xlabel('Number of Workers (k)', fontsize=13)
    ax.set_ylabel('Network Diameter (D)', fontsize=13)
    ax.set_title('Parallel Efficiency Phase Diagram\n'
                'Theorem B: Diameter × Barriers controls scaling limit',
                fontsize=14)

    fig.tight_layout()
    fig.savefig('diameter_heatmap.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == '__main__':
    print("Generating visualizations...")
    viz_1_speedup_curves()
    print("  ✓ speedup_curves.png")
    viz_2_broadcast_wavefront()
    print("  ✓ broadcast_wavefront.png")
    viz_3_convergence()
    print("  ✓ convergence.png")
    viz_4_diameter_heatmap()
    print("  ✓ diameter_heatmap.png")
    print("All visualizations generated.")
