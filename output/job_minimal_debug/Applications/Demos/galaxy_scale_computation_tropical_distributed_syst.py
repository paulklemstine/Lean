#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Distributed Systems

Demonstrates practical applications of the theoretical framework:
1. Deep-space network optimization (NASA DSN-style)
2. Content delivery network (CDN) cache propagation
3. Distributed database consistency (CRDT-style)
4. Multi-datacenter synchronization
"""

import math
from typing import List, Dict, Tuple

INF = float('inf')


def floyd_warshall(w: List[List[float]]) -> List[List[float]]:
    """All-pairs shortest paths."""
    n = len(w)
    d = [row[:] for row in w]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 1: Deep-Space Network Optimization
# ═══════════════════════════════════════════════════════════════════

def deep_space_network():
    """
    Model a deep-space communication network and analyze broadcast
    latency using tropical diameter.

    Scenario: A network of space probes and relay stations across
    the solar system. Communication delays are determined by
    light-travel time.
    """
    print("=" * 70)
    print("APPLICATION 1: Deep-Space Network Optimization")
    print("=" * 70)

    # Nodes: Earth, ISS, Moon, Mars, Jupiter, DSN-Relay
    nodes = ["Earth", "ISS", "Moon", "Mars", "Jupiter", "DSN-Relay"]
    n = len(nodes)

    # Light-travel delays in minutes
    w = [[INF] * n for _ in range(n)]
    for i in range(n):
        w[i][i] = 0

    # Connections (bidirectional)
    links = [
        (0, 1, 0.001),   # Earth ↔ ISS (negligible)
        (0, 2, 1.3),     # Earth ↔ Moon
        (0, 3, 12.5),    # Earth ↔ Mars (average)
        (0, 4, 43.2),    # Earth ↔ Jupiter (average)
        (0, 5, 0.5),     # Earth ↔ DSN-Relay
        (2, 5, 1.5),     # Moon ↔ DSN-Relay
        (3, 5, 13.0),    # Mars ↔ DSN-Relay
        (1, 2, 1.3),     # ISS ↔ Moon
    ]

    for i, j, delay in links:
        w[i][j] = delay
        w[j][i] = delay

    d = floyd_warshall(w)

    print("\nNetwork topology (light-travel delays in minutes):")
    for i, j, delay in links:
        print(f"  {nodes[i]} ↔ {nodes[j]}: {delay} min")

    print("\nShortest-path distances (minutes):")
    print(f"{'':>12}", end="")
    for name in nodes:
        print(f"{name:>10}", end="")
    print()
    for i in range(n):
        print(f"{nodes[i]:>12}", end="")
        for j in range(n):
            if d[i][j] >= INF:
                print(f"{'∞':>10}", end="")
            else:
                print(f"{d[i][j]:>10.1f}", end="")
        print()

    # Compute eccentricities
    eccentricities = [max(d[i]) for i in range(n)]
    diameter = max(eccentricities)
    radius = min(eccentricities)
    center = eccentricities.index(radius)

    print(f"\nTropical diameter: {diameter:.1f} minutes")
    print(f"Tropical radius: {radius:.1f} minutes")
    print(f"Network center: {nodes[center]}")

    # Optimal broadcast source
    print(f"\nOptimal broadcast source (minimizing completion time): {nodes[center]}")
    print(f"  Broadcast from {nodes[center]} completes in {radius:.1f} min")
    print(f"  Broadcast from worst source completes in {diameter:.1f} min")

    # Speedup analysis for distributed computation
    W_total = 10000  # computation units
    print(f"\nSpeedup analysis (W={W_total}, B=5 barriers):")
    for k in [2, 4, 6]:
        denom = W_total / k + 5 * diameter
        speedup = W_total / denom
        print(f"  {k} probes: speedup = {speedup:.2f}x (ideal = {k}x)")


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 2: CDN Cache Propagation
# ═══════════════════════════════════════════════════════════════════

def cdn_cache_propagation():
    """
    Analyze content propagation in a global CDN using tropical metrics.

    When content is updated at an origin server, the time for all
    edge caches to receive the update is the eccentricity of the
    origin in the tropical metric.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: CDN Cache Propagation")
    print("=" * 70)

    # Global CDN nodes with network latencies (milliseconds)
    nodes = ["US-West", "US-East", "Europe", "Asia", "S-America", "Africa"]
    n = len(nodes)

    w = [[INF] * n for _ in range(n)]
    for i in range(n):
        w[i][i] = 0

    # Network latencies (ms)
    links = [
        (0, 1, 40),    # US-West ↔ US-East
        (1, 2, 80),    # US-East ↔ Europe
        (2, 3, 120),   # Europe ↔ Asia
        (0, 3, 150),   # US-West ↔ Asia (transpacific)
        (1, 4, 100),   # US-East ↔ S-America
        (2, 5, 90),    # Europe ↔ Africa
        (0, 4, 90),    # US-West ↔ S-America
        (3, 5, 200),   # Asia ↔ Africa
    ]

    for i, j, delay in links:
        w[i][j] = delay
        w[j][i] = delay

    d = floyd_warshall(w)
    eccentricities = [max(d[i]) for i in range(n)]

    print("\nCDN topology (latencies in ms):")
    for i, j, delay in links:
        print(f"  {nodes[i]} ↔ {nodes[j]}: {delay} ms")

    print("\nCache update propagation times from each origin:")
    for i in range(n):
        max_time = eccentricities[i]
        print(f"  Origin at {nodes[i]}: all caches updated in {max_time:.0f} ms")

    best_origin = eccentricities.index(min(eccentricities))
    print(f"\nOptimal origin server: {nodes[best_origin]}")
    print(f"  Update propagation: {min(eccentricities):.0f} ms")
    print(f"  Worst-case origin: {max(eccentricities):.0f} ms")

    # CRDT-style convergence
    print("\nCRDT consistency analysis:")
    print("  Min-aggregation (e.g., 'earliest timestamp seen'):")
    print("  → Converges without coordination in ≤ diameter rounds")
    print(f"  → Tropical diameter = {max(max(row) for row in d):.0f} ms")
    print("  → No consensus protocol needed for eventual consistency!")


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 3: Distributed Database Consistency
# ═══════════════════════════════════════════════════════════════════

def distributed_database():
    """
    Model CRDT-style eventual consistency using idempotent aggregation.

    Shows that for commutative idempotent merge operations, all
    replicas converge regardless of message ordering or duplication.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Distributed Database — CRDT Convergence")
    print("=" * 70)

    # 5 database replicas
    n = 5
    replicas = [f"Replica-{i}" for i in range(n)]

    # Each replica has observed different maximum timestamps
    # Using max-aggregation (Last-Writer-Wins CRDT)
    timestamps = [100, 250, 180, 300, 150]

    print(f"\nInitial timestamps at each replica:")
    for i in range(n):
        print(f"  {replicas[i]}: t = {timestamps[i]}")

    # Ring topology
    adj = [[INF] * n for _ in range(n)]
    for i in range(n):
        adj[i][i] = 0
        adj[i][(i+1) % n] = 1
        adj[(i+1) % n][i] = 1

    # Simulate max-aggregation (each node takes max of neighbors)
    state = timestamps[:]
    print(f"\nMax-aggregation rounds (ring topology):")
    for t in range(5):
        print(f"  Round {t}: {state}")
        new_state = state[:]
        for i in range(n):
            for j in range(n):
                if adj[i][j] < INF:
                    new_state[i] = max(new_state[i], state[j])
        if new_state == state:
            print(f"  → CONVERGED at round {t}!")
            break
        state = new_state
    else:
        print(f"  Round 5: {state}")

    print(f"\nFinal value at all replicas: {state[0]}")
    print(f"Global max: {max(timestamps)}")
    print(f"Agreement achieved WITHOUT consensus protocol")

    # Demonstrate duplicate insensitivity
    print("\nDuplicate insensitivity test:")
    values_once = [100, 250, 180]
    values_duped = [100, 250, 180, 100, 250, 100]
    result_once = max(values_once)
    result_duped = max(values_duped)
    print(f"  max({values_once}) = {result_once}")
    print(f"  max({values_duped}) = {result_duped}")
    print(f"  Same? {result_once == result_duped} — duplicates are harmless!")


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 4: Multi-Datacenter Synchronization
# ═══════════════════════════════════════════════════════════════════

def multi_datacenter():
    """
    Analyze synchronization costs for a geo-distributed system
    using the tropical speedup bound.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Multi-Datacenter Synchronization Costs")
    print("=" * 70)

    # 4 datacenters with inter-DC latencies (ms)
    dcs = ["Virginia", "Oregon", "Frankfurt", "Tokyo"]
    n = 4
    w = [
        [0, 60, 90, 150],
        [60, 0, 120, 100],
        [90, 120, 0, 200],
        [150, 100, 200, 0]
    ]

    d = floyd_warshall(w)
    diameter = max(max(row) for row in d)
    radius = min(max(row) for row in range(n) if True for row in [d[i] for i in range(n)])
    # Fix radius computation
    eccs = [max(d[i]) for i in range(n)]
    radius = min(eccs)
    center_idx = eccs.index(radius)

    print(f"\nDatacenter latencies (ms): tropical diameter = {diameter} ms")
    print(f"Network center: {dcs[center_idx]} (eccentricity = {radius} ms)")

    # Analyze MapReduce-style computation
    W = 1_000_000  # total work units
    print(f"\nMapReduce analysis (W = {W:,} work units):")
    print(f"{'Workers':>10} {'Barriers':>10} {'Runtime':>12} {'Speedup':>10} {'Efficiency':>12}")
    print("-" * 56)

    for k in [4, 8, 16, 32, 64]:
        for B in [5, 20]:
            runtime = W / k + B * diameter
            speedup = W / runtime
            efficiency = speedup / k
            print(f"{k:>10} {B:>10} {runtime:>12,.0f} {speedup:>10.2f}x {efficiency:>11.1%}")

    print(f"\nKey insight: Even with {64} workers and diameter = {diameter} ms,")
    print(f"20 barriers waste {(1 - W / (W/64 + 20*diameter) / 64) * 100:.0f}% of compute")
    print(f"→ Tropical diameter is the fundamental bottleneck")


# ═══════════════════════════════════════════════════════════════════
# Run all applications
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    deep_space_network()
    cdn_cache_propagation()
    distributed_database()
    multi_datacenter()

    print("\n" + "=" * 70)
    print("Summary: Tropical Geometry → Practical Systems Design")
    print("=" * 70)
    print("""
Key practical takeaways:
1. BROADCAST: Choose the network center as origin to minimize
   global update latency (= tropical radius).
2. SPEEDUP: The tropical diameter imposes a hard ceiling on
   parallel speedup—adding workers beyond sqrt(W/(B·D)) is wasteful.
3. CONSISTENCY: Use idempotent aggregation (min, max, union) for
   eventual consistency WITHOUT consensus protocols—the algebra
   guarantees convergence.
4. PLACEMENT: Server/replica placement should minimize eccentricity,
   which is exactly the tropical facility location problem.
""")


#!/usr/bin/env python3
"""
demo.py — Tropical Distributed Systems: Concrete Numerical Demonstrations

Demonstrates the core theorems with concrete examples:
1. Shortest-path distances, eccentricity, and tropical diameter on small networks
2. Speedup bounds under communication latency
3. Idempotent aggregation stabilization
4. Duplicate/order insensitivity of min-fold
"""

import numpy as np
from typing import List, Tuple

INF = float('inf')


def floyd_warshall(w: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths via Floyd-Warshall (min-plus closure)."""
    n = w.shape[0]
    d = w.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


def eccentricity(d: np.ndarray, i: int) -> float:
    """Eccentricity of node i: max shortest-path distance from i."""
    return np.max(d[i])


def tropical_diameter(d: np.ndarray) -> float:
    """Tropical diameter: max eccentricity over all nodes."""
    n = d.shape[0]
    return max(eccentricity(d, i) for i in range(n))


def speedup(W: float, k: int, B: int, D: float) -> float:
    """Compute speedup W / (W/k + B*D)."""
    denom = W / k + B * D
    if denom <= 0:
        return float('inf')
    return W / denom


def min_fold(seed: float, values: List[float]) -> float:
    """Fold min over a list with a seed value."""
    result = seed
    for v in reversed(values):
        result = min(v, result)
    return result


def idempotent_iteration(f, x, rounds: int):
    """Apply f repeatedly, tracking all intermediate states."""
    states = [x]
    current = x
    for _ in range(rounds):
        current = f(current)
        states.append(current)
    return states


# ─────────────────────────────────────────────────────────────────
# DEMO 1: Galactic Network — Shortest Paths and Diameter
# ─────────────────────────────────────────────────────────────────
print("=" * 70)
print("DEMO 1: Galactic Network — Tropical Distance & Diameter")
print("=" * 70)

# 5-node network representing "galactic" nodes with light-year delays
# Nodes: Earth(0), Mars(1), Alpha Centauri(2), Sirius(3), Proxima(4)
node_names = ["Earth", "Mars", "AlphaCen", "Sirius", "Proxima"]
n = 5

# Edge weights (communication delays in light-years)
w = np.full((n, n), INF)
for i in range(n):
    w[i][i] = 0.0

# Direct links
w[0][1] = 0.1   # Earth → Mars
w[1][0] = 0.1   # Mars → Earth
w[0][2] = 4.37  # Earth → Alpha Centauri
w[2][0] = 4.37  # Alpha Centauri → Earth
w[2][4] = 0.05  # Alpha Centauri → Proxima
w[4][2] = 0.05  # Proxima → Alpha Centauri
w[0][3] = 8.6   # Earth → Sirius
w[3][0] = 8.6   # Sirius → Earth
w[1][3] = 9.0   # Mars → Sirius
w[3][1] = 9.0   # Sirius → Mars

print(f"\nNetwork: {n} nodes ({', '.join(node_names)})")
print("Direct link delays (light-years):")
for i in range(n):
    for j in range(n):
        if i != j and w[i][j] < INF:
            print(f"  {node_names[i]} → {node_names[j]}: {w[i][j]:.2f} ly")

# Compute shortest paths
d = floyd_warshall(w)

print("\nAll-pairs shortest-path distances (tropical metric):")
print(f"{'':>12}", end="")
for name in node_names:
    print(f"{name:>10}", end="")
print()
for i in range(n):
    print(f"{node_names[i]:>12}", end="")
    for j in range(n):
        if d[i][j] == INF:
            print(f"{'∞':>10}", end="")
        else:
            print(f"{d[i][j]:>10.2f}", end="")
    print()

print("\nEccentricities:")
for i in range(n):
    ecc = eccentricity(d, i)
    if ecc == INF:
        print(f"  {node_names[i]}: ∞")
    else:
        print(f"  {node_names[i]}: {ecc:.2f} ly")

diam = tropical_diameter(d)
print(f"\nTropical Diameter: {diam:.2f} light-years")
print(f"→ Any global broadcast requires at least {diam:.2f} ly of propagation time")

# Verify eccentricity ≤ diameter for all nodes
print("\nVerify eccentricity ≤ diameter (Theorem 1):")
for i in range(n):
    ecc = eccentricity(d, i)
    print(f"  {node_names[i]}: ecc={ecc:.2f} ≤ diam={diam:.2f}: {ecc <= diam + 1e-10}")


# ─────────────────────────────────────────────────────────────────
# DEMO 2: Speedup Bounds Under Communication Latency
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 2: Speedup Bounds — Latency Limits Parallelism")
print("=" * 70)

W = 1000.0  # Total work units
D = diam    # Communication delay = tropical diameter
barriers = [1, 5, 10, 20]
workers = [1, 2, 4, 8, 16, 32, 64]

print(f"\nTotal work W = {W}, Communication delay D = {D:.2f} ly")
print(f"\nSpeedup S = W / (W/k + B*D):")
print(f"{'k workers':>12}", end="")
for B in barriers:
    print(f"{'B=' + str(B):>12}", end="")
print()
print("-" * (12 + 12 * len(barriers)))

for k in workers:
    print(f"{k:>12}", end="")
    for B in barriers:
        s = speedup(W, k, B, D)
        print(f"{s:>12.2f}", end="")
    print()

print(f"\nKey insight: With D = {D:.2f} ly and B = 10 barriers,")
print(f"  64 workers achieve speedup = {speedup(W, 64, 10, D):.2f}x (not 64x)")
print(f"  → Communication latency wastes {(1 - speedup(W, 64, 10, D)/64)*100:.1f}% of parallelism")


# ─────────────────────────────────────────────────────────────────
# DEMO 3: Idempotent Aggregation Stabilization
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 3: Idempotent Aggregation — Convergence Without Consensus")
print("=" * 70)

# Tropical min-aggregation on a 4-node network
n_small = 4
initial_values = np.array([7.0, 3.0, 9.0, 1.0])

# Simple adjacency (ring network)
adj = np.full((n_small, n_small), INF)
for i in range(n_small):
    adj[i][i] = 0.0
    adj[i][(i+1) % n_small] = 1.0
    adj[(i+1) % n_small][i] = 1.0

def tropical_min_update(state: np.ndarray) -> np.ndarray:
    """Each node takes min of its value and all neighbor values."""
    new_state = state.copy()
    for i in range(len(state)):
        for j in range(len(state)):
            if adj[i][j] < INF:
                new_state[i] = min(new_state[i], state[j])
    return new_state

print(f"\nInitial node values: {initial_values}")
print(f"Network: {n_small}-node ring")
print(f"Update rule: each node takes min of itself and neighbors")

states = idempotent_iteration(tropical_min_update, initial_values, 5)
for r, s in enumerate(states):
    marker = " ← STABLE" if r > 0 and np.array_equal(s, states[r-1]) else ""
    print(f"  Round {r}: {s}{marker}")

global_min = np.min(initial_values)
print(f"\nGlobal minimum: {global_min}")
print(f"All nodes converge to global min after ≤ diameter rounds")
print(f"No consensus protocol needed — idempotence guarantees convergence!")


# ─────────────────────────────────────────────────────────────────
# DEMO 4: Duplicate Insensitivity & Order Independence
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 4: Duplicate Insensitivity & Order Independence")
print("=" * 70)

import random
random.seed(42)

values = [5.0, 2.0, 8.0, 1.0, 6.0]
seed = 10.0

result_original = min_fold(seed, values)
print(f"\nOriginal: foldr min {seed} {values} = {result_original}")

# Duplicate some elements
duplicated = values + [values[0], values[2], values[0]]
result_duplicated = min_fold(seed, duplicated)
print(f"Duplicated: foldr min {seed} {duplicated} = {result_duplicated}")
print(f"  Same result? {result_original == result_duplicated} ← Duplicate insensitivity!")

# Permute
for trial in range(3):
    shuffled = values.copy()
    random.shuffle(shuffled)
    result_shuffled = min_fold(seed, shuffled)
    print(f"Permuted {trial+1}: foldr min {seed} {shuffled} = {result_shuffled}")
    print(f"  Same result? {result_original == result_shuffled} ← Order independence!")


# ─────────────────────────────────────────────────────────────────
# DEMO 5: Broadcast Time = Eccentricity
# ─────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 5: Optimal Broadcast Time = Eccentricity of Source")
print("=" * 70)

# Use the galactic network from Demo 1
source = 0  # Earth
print(f"\nSource: {node_names[source]}")
print(f"Eccentricity of {node_names[source]}: {eccentricity(d, source):.2f} ly")
print(f"\nShortest-path delivery times from {node_names[source]}:")
for j in range(n):
    dist_val = d[source][j]
    if dist_val == INF:
        print(f"  → {node_names[j]}: ∞ (unreachable)")
    else:
        print(f"  → {node_names[j]}: {dist_val:.2f} ly")

print(f"\nOptimal broadcast completion time = max(delivery times)")
print(f"  = eccentricity({node_names[source]}) = {eccentricity(d, source):.2f} ly")
print(f"\nFor all-source broadcast: completion time = diameter = {diam:.2f} ly")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("Key takeaway: Network geometry IS computational complexity.")
print("=" * 70)


#!/usr/bin/env python3
"""
visualizations.py — Generate publication-quality figures for
Tropical Distributed Systems research.

Generates:
1. Speedup curves showing latency degradation
2. Aggregation convergence heatmap
3. Network distance matrix visualization
4. Tropical diameter vs. broadcast time comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO

INF = float('inf')


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def floyd_warshall(w):
    n = w.shape[0]
    d = w.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


# ═══════════════════════════════════════════════════════════════════
# Figure 1: Speedup Curves Under Communication Latency
# ═══════════════════════════════════════════════════════════════════

def generate_speedup_curves():
    """Show how tropical diameter limits parallel speedup."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    W = 1000
    workers = np.arange(1, 65)
    diameters = [0, 5, 10, 20, 50]
    B = 10

    # Left: Speedup vs workers for different diameters
    ax1.plot(workers, workers, 'k--', alpha=0.3, label='Linear (ideal)')
    for D in diameters:
        speedups = [W / (W/k + B*D) for k in workers]
        label = f'D = {D}' + (' (no latency)' if D == 0 else '')
        ax1.plot(workers, speedups, linewidth=2, label=label)

    ax1.set_xlabel('Number of Workers (k)', fontsize=12)
    ax1.set_ylabel('Speedup S(k)', fontsize=12)
    ax1.set_title('Speedup Bounded by Tropical Diameter', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_xlim(1, 64)
    ax1.set_ylim(0, 65)
    ax1.grid(True, alpha=0.3)

    # Right: Efficiency (S/k) vs workers
    for D in diameters:
        if D == 0:
            continue
        efficiencies = [(W / (W/k + B*D)) / k * 100 for k in workers]
        ax2.plot(workers, efficiencies, linewidth=2, label=f'D = {D}')

    ax2.set_xlabel('Number of Workers (k)', fontsize=12)
    ax2.set_ylabel('Parallel Efficiency (%)', fontsize=12)
    ax2.set_title('Efficiency Degrades with Network Diameter', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_xlim(1, 64)
    ax2.set_ylim(0, 105)
    ax2.axhline(y=50, color='r', linestyle=':', alpha=0.5)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Theorem B: Communication Latency Limits Parallelism',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_speedup.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════
# Figure 2: Idempotent Aggregation Convergence
# ═══════════════════════════════════════════════════════════════════

def generate_convergence_heatmap():
    """Visualize convergence of min-aggregation on a network."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # 8-node ring network
    n = 8
    adj = np.full((n, n), np.inf)
    for i in range(n):
        adj[i][i] = 0
        adj[i][(i+1) % n] = 1
        adj[(i+1) % n][i] = 1

    # Initial values with one minimum
    np.random.seed(42)
    initial = np.array([15, 8, 22, 3, 19, 11, 25, 7], dtype=float)

    # Simulate min-aggregation
    rounds = 6
    states = np.zeros((rounds + 1, n))
    states[0] = initial
    state = initial.copy()

    for t in range(1, rounds + 1):
        new_state = state.copy()
        for i in range(n):
            for j in range(n):
                if adj[i][j] < np.inf:
                    new_state[i] = min(new_state[i], state[j])
        states[t] = new_state
        state = new_state

    # Heatmap
    im = ax1.imshow(states.T, aspect='auto', cmap='viridis_r',
                    interpolation='nearest')
    ax1.set_xlabel('Round', fontsize=12)
    ax1.set_ylabel('Node', fontsize=12)
    ax1.set_title('Min-Aggregation Convergence', fontsize=14)
    ax1.set_xticks(range(rounds + 1))
    ax1.set_yticks(range(n))
    ax1.set_yticklabels([f'Node {i}' for i in range(n)])
    plt.colorbar(im, ax=ax1, label='Value')

    # Add value annotations
    for t in range(rounds + 1):
        for i in range(n):
            val = states[t][i]
            color = 'white' if val > 10 else 'black'
            ax1.text(t, i, f'{val:.0f}', ha='center', va='center',
                    color=color, fontsize=8)

    # Line plot showing convergence
    for i in range(n):
        ax2.plot(range(rounds + 1), states[:, i], 'o-',
                label=f'Node {i}', markersize=4)
    ax2.axhline(y=3, color='red', linestyle='--', linewidth=2,
               label='Global min (3)')
    ax2.set_xlabel('Round', fontsize=12)
    ax2.set_ylabel('Node Value', fontsize=12)
    ax2.set_title('All Nodes Converge to Global Minimum', fontsize=14)
    ax2.legend(fontsize=8, ncol=3)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Theorem C: Idempotent Aggregation Stabilizes Without Consensus',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════
# Figure 3: Distance Matrix and Network Geometry
# ═══════════════════════════════════════════════════════════════════

def generate_distance_matrix():
    """Visualize the tropical shortest-path distance matrix."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Galactic network
    nodes = ["Earth", "Mars", "α Cen", "Sirius", "Proxima"]
    n = 5
    w = np.full((n, n), np.inf)
    for i in range(n):
        w[i][i] = 0
    w[0][1] = w[1][0] = 0.1
    w[0][2] = w[2][0] = 4.37
    w[2][4] = w[4][2] = 0.05
    w[0][3] = w[3][0] = 8.6
    w[1][3] = w[3][1] = 9.0

    d = floyd_warshall(w)

    # Replace inf with NaN for visualization
    d_vis = d.copy()
    d_vis[d_vis == np.inf] = np.nan

    im = ax1.imshow(d_vis, cmap='YlOrRd', interpolation='nearest')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(nodes, rotation=45, ha='right')
    ax1.set_yticklabels(nodes)
    ax1.set_title('Tropical Distance Matrix\n(Shortest-Path Delays, ly)', fontsize=13)
    plt.colorbar(im, ax=ax1, label='Light-years')

    for i in range(n):
        for j in range(n):
            if not np.isnan(d_vis[i][j]):
                ax1.text(j, i, f'{d_vis[i][j]:.1f}', ha='center', va='center',
                        color='black' if d_vis[i][j] < 8 else 'white', fontsize=9)

    # Eccentricity bar chart
    eccs = [np.max(d[i][d[i] < np.inf]) if np.any(d[i] < np.inf) else 0 for i in range(n)]
    colors = ['#2ecc71' if e == min(eccs) else '#e74c3c' if e == max(eccs) else '#3498db'
              for e in eccs]

    bars = ax2.bar(range(n), eccs, color=colors, edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels(nodes, rotation=45, ha='right')
    ax2.set_ylabel('Eccentricity (light-years)', fontsize=12)
    ax2.set_title('Node Eccentricities\n(Green = Center, Red = Periphery)', fontsize=13)

    diameter = max(eccs)
    ax2.axhline(y=diameter, color='red', linestyle='--', linewidth=2,
               label=f'Diameter = {diameter:.1f} ly')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    for bar, ecc in zip(bars, eccs):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                f'{ecc:.1f}', ha='center', va='bottom', fontsize=10)

    fig.suptitle('Theorem A: Network Geometry Determines Broadcast Time',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_distance.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════
# Figure 4: Broadcast Wavefront Propagation
# ═══════════════════════════════════════════════════════════════════

def generate_broadcast_wavefront():
    """Visualize broadcast propagation as a tropical wavefront."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Timeline of broadcast from Earth
    nodes = ["Earth", "Mars", "α Centauri", "Proxima", "Sirius"]
    arrival_times = [0, 0.1, 4.37, 4.42, 8.6]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(nodes)))

    for i, (node, t) in enumerate(zip(nodes, arrival_times)):
        ax.barh(i, t, color=colors[i], edgecolor='black', linewidth=0.5, height=0.6)
        if t > 0:
            ax.text(t + 0.1, i, f'{t:.2f} ly', va='center', fontsize=11)
        else:
            ax.text(0.1, i, f'{t:.2f} ly', va='center', fontsize=11)

    ax.set_yticks(range(len(nodes)))
    ax.set_yticklabels(nodes, fontsize=12)
    ax.set_xlabel('Time (light-years)', fontsize=13)
    ax.set_title('Broadcast Wavefront from Earth\n'
                 '(Optimal broadcast time = eccentricity = 8.60 ly)',
                 fontsize=14, fontweight='bold')

    # Mark eccentricity
    ax.axvline(x=8.6, color='red', linestyle='--', linewidth=2,
              label=f'Eccentricity = 8.60 ly')
    ax.legend(fontsize=11, loc='lower right')
    ax.grid(True, alpha=0.3, axis='x')
    ax.set_xlim(-0.5, 10)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_broadcast.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════
# Generate all figures
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    b64_speedup = generate_speedup_curves()
    print(f"  fig_speedup.png generated ({len(b64_speedup)} chars)")

    b64_convergence = generate_convergence_heatmap()
    print(f"  fig_convergence.png generated ({len(b64_convergence)} chars)")

    b64_distance = generate_distance_matrix()
    print(f"  fig_distance.png generated ({len(b64_distance)} chars)")

    b64_broadcast = generate_broadcast_wavefront()
    print(f"  fig_broadcast.png generated ({len(b64_broadcast)} chars)")

    print("\nAll visualizations saved to project root.")

    # Output base64 URIs for JSON package
    import json
    viz_data = {
        "speedup": b64_speedup,
        "convergence": b64_convergence,
        "distance": b64_distance,
        "broadcast": b64_broadcast,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data written to viz_data.json")
