#!/usr/bin/env python3
"""
Applications of Sheaf-Theoretic Tropical Persistence

Demonstrates real-world applications of the constructible sheaf framework:
1. Network resilience analysis via sheaf jumps
2. Sensor network coverage monitoring
3. Social network community detection through tropical filtrations
"""

from typing import List, Tuple, Dict, Set
from dataclasses import dataclass
import math


# ─── Core Types (self-contained) ─────────────────────────────────────────

@dataclass
class Graph:
    n: int
    edges: List[Tuple[int, int]]

    def degree(self, v: int) -> int:
        return sum(1 for (a, b) in self.edges if a == v or b == v)

    def neighbors(self, v: int) -> Set[int]:
        result = set()
        for (a, b) in self.edges:
            if a == v: result.add(b)
            elif b == v: result.add(a)
        return result


def critical_values(entrance_times: List[float]) -> List[float]:
    return sorted(set(entrance_times))


def active_vertices(entrance_times: List[float], t: float) -> List[int]:
    return [v for v, fv in enumerate(entrance_times) if fv <= t]


def sheaf_jump(graph: Graph, entrance_times: List[float], c: float) -> int:
    entering = [v for v, fv in enumerate(entrance_times) if fv == c]
    return sum(graph.degree(v) + 1 for v in entering)


def sheaf_event_profile(graph: Graph, entrance_times: List[float], t: float) -> int:
    crit = critical_values(entrance_times)
    return sum(sheaf_jump(graph, entrance_times, c) for c in crit if c <= t)


def euler_char(graph: Graph, entrance_times: List[float], t: float) -> int:
    active = set(active_vertices(entrance_times, t))
    V = len(active)
    E = sum(1 for (a, b) in graph.edges if a in active and b in active)
    return V - E


# ─── Application 1: Network Resilience Analysis ──────────────────────────

def network_resilience_analysis():
    """
    Analyze network resilience by interpreting sheaf jumps as vulnerability indicators.

    A network's nodes fail sequentially (modeled by a filtration). Large sheaf jumps
    at a critical threshold indicate that the failing node was a hub — its removal
    causes a large change in the network's tropical invariant.

    This application uses the constructibility theorem: between failures, all
    network invariants remain stable.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Network Resilience Analysis")
    print("=" * 60 + "\n")

    # Model a small infrastructure network (e.g., power grid topology)
    # Hub-and-spoke with some cross-links
    n = 10
    edges = [
        (0, 1), (0, 2), (0, 3),  # Hub 0
        (1, 4), (1, 5),          # Branch from 1
        (2, 5), (2, 6),          # Branch from 2
        (3, 6), (3, 7),          # Branch from 3
        (4, 8), (5, 8),          # Cross-link
        (6, 9), (7, 9),          # Cross-link
        (8, 9),                  # Back edge
    ]
    G = Graph(n, edges)

    # Failure order: periphery fails first, hubs fail last
    # (resilience ordering — most critical nodes protected longest)
    failure_times = [9.0, 6.0, 7.0, 8.0, 1.0, 2.0, 3.0, 4.0, 0.0, 5.0]

    print("Network: 10-node infrastructure graph")
    print(f"Failure times: {failure_times}")
    print(f"Failure order: {[failure_times.index(i) for i in range(n)]}")
    print()

    crit = critical_values(failure_times)
    print("Sheaf Jump Analysis (vulnerability indicators):")
    print(f"{'Time':>6} {'Failing Node':>14} {'Deg':>5} {'Jump':>6} {'Cum Profile':>13} {'χ':>4}")
    print("-" * 52)

    for c in crit:
        entering = [v for v, fv in enumerate(failure_times) if fv == c]
        j = sheaf_jump(G, failure_times, c)
        cum = sheaf_event_profile(G, failure_times, c)
        chi = euler_char(G, failure_times, c)
        for v in entering:
            d = G.degree(v)
            vulnerability = "⚠ HIGH" if j >= 4 else "  low"
            print(f"{c:6.0f} {v:14d} {d:5d} {j:6d} {cum:13d} {chi:4d}  {vulnerability}")

    print("\nInterpretation: Large sheaf jumps identify critical infrastructure nodes.")
    print("The constructibility theorem guarantees stability between failure events.")


# ─── Application 2: Sensor Network Coverage ──────────────────────────────

def sensor_coverage_analysis():
    """
    Model sensor network activation as a tropical filtration.

    Sensors activate at different times (sunrise, scheduled activation, etc.).
    The sheaf jump at each activation time measures the coverage contribution
    of the activating sensor. The cumulative profile tracks total coverage capacity.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Sensor Network Coverage Monitoring")
    print("=" * 60 + "\n")

    # Grid-like sensor network
    # 3x3 grid
    n = 9
    edges = [
        (0, 1), (1, 2),         # Row 0
        (3, 4), (4, 5),         # Row 1
        (6, 7), (7, 8),         # Row 2
        (0, 3), (3, 6),         # Col 0
        (1, 4), (4, 7),         # Col 1
        (2, 5), (5, 8),         # Col 2
    ]
    G = Graph(n, edges)

    # Activation times (staggered for energy efficiency)
    activation = [0.0, 0.5, 1.0, 0.5, 1.0, 1.5, 1.0, 1.5, 2.0]

    print("Sensor grid (3x3):")
    print("  0 - 1 - 2")
    print("  |   |   |")
    print("  3 - 4 - 5")
    print("  |   |   |")
    print("  6 - 7 - 8")
    print(f"\nActivation times: {activation}")

    crit = critical_values(activation)
    print(f"\nCritical activation times: {crit}")
    print(f"\nCoverage buildup:")
    print(f"{'Time':>6} {'Active Sensors':>20} {'Coverage (profile)':>20} {'χ':>5}")
    print("-" * 55)

    for c in crit:
        active = active_vertices(activation, c)
        profile = sheaf_event_profile(G, activation, c)
        chi = euler_char(G, activation, c)
        print(f"{c:6.1f} {str(active):>20} {profile:20d} {chi:5d}")

    print("\nThe sheaf event profile grows monotonically, reflecting increasing")
    print("network capacity. Euler characteristic tracks connectivity.")


# ─── Application 3: Community Evolution ──────────────────────────────────

def community_evolution():
    """
    Track community structure evolution in a social network.

    As new members join (filtration), the sheaf jumps quantify the structural
    impact of each new member. High-degree members joining cause large jumps.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Social Network Community Evolution")
    print("=" * 60 + "\n")

    # Two communities with a bridge
    n = 8
    edges = [
        # Community A (dense)
        (0, 1), (0, 2), (1, 2), (0, 3), (1, 3), (2, 3),
        # Community B (dense)
        (4, 5), (4, 6), (5, 6), (4, 7), (5, 7), (6, 7),
        # Bridge
        (3, 4),
    ]
    G = Graph(n, edges)

    # Members join over time
    join_times = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]

    print("Social network: Two communities (A={0,1,2,3}, B={4,5,6,7})")
    print(f"Bridge: 3-4")
    print(f"Join times: {join_times}")

    crit = critical_values(join_times)
    print(f"\nCommunity evolution:")
    print(f"{'Time':>6} {'New Member':>12} {'Degree':>8} {'Jump':>6} "
          f"{'Profile':>9} {'χ':>4} {'Phase':>12}")
    print("-" * 63)

    for c in crit:
        entering = [v for v, fv in enumerate(join_times) if fv == c]
        j = sheaf_jump(G, join_times, c)
        profile = sheaf_event_profile(G, join_times, c)
        chi = euler_char(G, join_times, c)

        for v in entering:
            d = G.degree(v)
            if v <= 3:
                phase = "Community A"
            elif v == 4:
                phase = "Bridge!"
            else:
                phase = "Community B"
            print(f"{c:6.0f} {v:12d} {d:8d} {j:6d} {profile:9d} {chi:4d} {phase:>12}")

    # Stability experiment: perturb join times
    print("\n--- Stability under perturbation ---")
    perturbed = [t + 0.2 * math.sin(t) for t in join_times]
    eps = max(abs(a - b) for a, b in zip(join_times, perturbed))
    print(f"Perturbed times: {[f'{t:.2f}' for t in perturbed]}")
    print(f"Sup distance: ε = {eps:.4f}")

    # Check interleaving
    interleaved = True
    for t_test in [float(i) * 0.5 for i in range(20)]:
        p1 = sheaf_event_profile(G, join_times, t_test)
        p2 = sheaf_event_profile(G, perturbed, t_test + eps)
        if p1 > p2:
            interleaved = False
            break
    print(f"ε-interleaving verified: {'✓' if interleaved else '✗'}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Sheaf-Theoretic Tropical Persistence   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    network_resilience_analysis()
    sensor_coverage_analysis()
    community_evolution()

    print(f"\n{'=' * 60}")
    print("  All applications completed successfully.")
    print(f"{'=' * 60}")


#!/usr/bin/env python3
"""
Sheaf-Theoretic Tropical Persistence — Interactive Demo

Demonstrates the constructible sheaf structure on tropical graph filtrations
for path graphs and cycle graphs. Shows:
1. Critical thresholds and stalk values
2. Sheaf jump profiles
3. Cumulative sheaf event profile vs. direct tropical event profile
4. Comparison validating the recovery theorem
"""

import numpy as np
from typing import List, Dict, Tuple

# ─── Graph Definitions ───────────────────────────────────────────────────

def path_graph_adj(n: int) -> List[Tuple[int, int]]:
    """Adjacency list for path graph P_n on vertices {0, ..., n-1}."""
    return [(i, i + 1) for i in range(n - 1)]

def cycle_graph_adj(n: int) -> List[Tuple[int, int]]:
    """Adjacency list for cycle graph C_n on vertices {0, ..., n-1}."""
    edges = [(i, (i + 1) % n) for i in range(n)]
    return edges

def degree(n: int, edges: List[Tuple[int, int]], v: int) -> int:
    """Degree of vertex v in the graph."""
    return sum(1 for (a, b) in edges if a == v or b == v)

# ─── Tropical Filtration ─────────────────────────────────────────────────

def default_filtration(n: int) -> List[float]:
    """Default filtration: vertex i enters at time i."""
    return [float(i) for i in range(n)]

def random_filtration(n: int, seed: int = 42) -> List[float]:
    """Random filtration for perturbation experiments."""
    rng = np.random.default_rng(seed)
    return sorted(rng.uniform(0, n, size=n).tolist())

# ─── Core Sheaf Computations ─────────────────────────────────────────────

def critical_values(filt: List[float]) -> List[float]:
    """Critical values = sorted unique entrance times."""
    return sorted(set(filt))

def active_vertices(filt: List[float], t: float) -> List[int]:
    """Vertices active at threshold t."""
    return [v for v, fv in enumerate(filt) if fv <= t]

def tropical_event_profile(n: int, edges: List[Tuple[int, int]],
                           filt: List[float], t: float) -> int:
    """Direct computation of tropical event profile at threshold t."""
    active = active_vertices(filt, t)
    return sum(degree(n, edges, v) + 1 for v in active)

def sheaf_jump(n: int, edges: List[Tuple[int, int]],
               filt: List[float], c: float) -> int:
    """Sheaf jump at critical value c: sum of (deg(v)+1) for v entering at c."""
    entering = [v for v, fv in enumerate(filt) if fv == c]
    return sum(degree(n, edges, v) + 1 for v in entering)

def sheaf_event_profile(n: int, edges: List[Tuple[int, int]],
                        filt: List[float], t: float) -> int:
    """Cumulative sheaf jump profile up to threshold t."""
    crit = critical_values(filt)
    return sum(sheaf_jump(n, edges, filt, c) for c in crit if c <= t)

def active_edge_count(n: int, edges: List[Tuple[int, int]],
                      filt: List[float], t: float) -> int:
    """Number of active edges at threshold t."""
    active = set(active_vertices(filt, t))
    return sum(1 for (a, b) in edges if a in active and b in active)

def euler_characteristic(n: int, edges: List[Tuple[int, int]],
                         filt: List[float], t: float) -> int:
    """Euler characteristic of active subgraph: |V| - |E|."""
    V = len(active_vertices(filt, t))
    E = active_edge_count(n, edges, filt, t)
    return V - E

# ─── Constructibility Check ──────────────────────────────────────────────

def verify_constructibility(n: int, edges: List[Tuple[int, int]],
                            filt: List[float]) -> bool:
    """Verify that the event profile is constant between critical values."""
    crit = critical_values(filt)
    for i in range(len(crit) - 1):
        # Check midpoint between consecutive critical values
        mid = (crit[i] + crit[i + 1]) / 2
        # Profile at crit[i] and mid should be equal
        p_crit = tropical_event_profile(n, edges, filt, crit[i])
        p_mid = tropical_event_profile(n, edges, filt, mid)
        if p_crit != p_mid:
            return False
    return True

# ─── Stability Check ─────────────────────────────────────────────────────

def verify_interleaving(n: int, edges: List[Tuple[int, int]],
                        filt1: List[float], filt2: List[float],
                        epsilon: float) -> Tuple[bool, float]:
    """
    Verify ε-interleaving: profile_f(t) ≤ profile_g(t+ε) for all t.
    Returns (success, max_violation).
    """
    # Check that filtrations are ε-close
    actual_dist = max(abs(f1 - f2) for f1, f2 in zip(filt1, filt2))

    # Test interleaving at a fine grid
    t_values = np.linspace(-1, n + 1, 1000)
    max_violation = 0.0
    success = True
    for t in t_values:
        p1 = sheaf_event_profile(n, edges, filt1, t)
        p2_shifted = sheaf_event_profile(n, edges, filt2, t + epsilon)
        if p1 > p2_shifted:
            success = False
            max_violation = max(max_violation, p1 - p2_shifted)
    return success, max_violation

# ─── Demo Functions ───────────────────────────────────────────────────────

def demo_path_graph(n: int = 6):
    """Full demo for path graph P_n."""
    print(f"\n{'='*60}")
    print(f"  PATH GRAPH P_{n} — Sheaf-Theoretic Analysis")
    print(f"{'='*60}\n")

    edges = path_graph_adj(n)
    filt = default_filtration(n)
    crit = critical_values(filt)

    print(f"Vertices: {list(range(n))}")
    print(f"Edges: {edges}")
    print(f"Filtration: {filt}")
    print(f"Critical values: {crit}")
    print()

    # Sheaf jump profile
    print("Sheaf Jump Profile:")
    print(f"{'Threshold':>12} {'Jump':>8} {'Cum. Jump':>12} {'Direct Profile':>16}")
    print("-" * 52)
    cum = 0
    for c in crit:
        j = sheaf_jump(n, edges, filt, c)
        cum += j
        direct = tropical_event_profile(n, edges, filt, c)
        print(f"{c:12.1f} {j:8d} {cum:12d} {direct:16d}")

    # Verify recovery theorem
    print(f"\n✓ Recovery Theorem Verified: cumulative jump = direct profile")
    for c in crit:
        assert sheaf_event_profile(n, edges, filt, c) == \
               tropical_event_profile(n, edges, filt, c), \
               f"Recovery failed at t={c}"

    # Constructibility
    is_constructible = verify_constructibility(n, edges, filt)
    print(f"✓ Constructibility Verified: {is_constructible}")

    # Euler characteristic
    print(f"\nEuler Characteristic Profile:")
    for c in crit:
        chi = euler_characteristic(n, edges, filt, c)
        print(f"  χ(t={c:.0f}) = {chi}")

    # Active vertex count
    print(f"\nActive Vertex Count (= stalk cardinality):")
    for c in crit:
        av = active_vertices(filt, c)
        print(f"  |F(t={c:.0f})| = {len(av)}  (vertices: {av})")


def demo_cycle_graph(n: int = 6):
    """Full demo for cycle graph C_n."""
    print(f"\n{'='*60}")
    print(f"  CYCLE GRAPH C_{n} — Sheaf-Theoretic Analysis")
    print(f"{'='*60}\n")

    edges = cycle_graph_adj(n)
    filt = default_filtration(n)
    crit = critical_values(filt)

    print(f"Vertices: {list(range(n))}")
    print(f"Edges: {edges}")
    print(f"Filtration: {filt}")
    print(f"Critical values: {crit}")
    print()

    # Sheaf jump profile
    print("Sheaf Jump Profile:")
    print(f"{'Threshold':>12} {'Jump':>8} {'Cum. Jump':>12} {'Direct Profile':>16}")
    print("-" * 52)
    cum = 0
    for c in crit:
        j = sheaf_jump(n, edges, filt, c)
        cum += j
        direct = tropical_event_profile(n, edges, filt, c)
        print(f"{c:12.1f} {j:8d} {cum:12d} {direct:16d}")

    # Recovery theorem
    for c in crit:
        assert sheaf_event_profile(n, edges, filt, c) == \
               tropical_event_profile(n, edges, filt, c)
    print(f"\n✓ Recovery Theorem Verified")

    # Constructibility
    is_constructible = verify_constructibility(n, edges, filt)
    print(f"✓ Constructibility Verified: {is_constructible}")

    # Compare with path graph: cycle has extra edge creating cycle obstruction
    print(f"\nCycle vs Path Comparison:")
    path_edges = path_graph_adj(n)
    for c in crit:
        jp = sheaf_jump(n, path_edges, filt, c)
        jc = sheaf_jump(n, edges, filt, c)
        print(f"  t={c:.0f}: path_jump={jp}, cycle_jump={jc}, "
              f"diff={jc - jp}")


def demo_stability(n: int = 5):
    """Demo stability via sheaf interleaving."""
    print(f"\n{'='*60}")
    print(f"  STABILITY VIA SHEAF INTERLEAVING — P_{n}")
    print(f"{'='*60}\n")

    edges = path_graph_adj(n)
    filt1 = default_filtration(n)
    filt2 = [f + 0.3 * np.sin(i) for i, f in enumerate(filt1)]

    epsilon = max(abs(f1 - f2) for f1, f2 in zip(filt1, filt2))
    print(f"Filtration 1: {[f'{f:.2f}' for f in filt1]}")
    print(f"Filtration 2: {[f'{f:.2f}' for f in filt2]}")
    print(f"Sup distance: ε = {epsilon:.4f}")

    # Verify interleaving
    success_fwd, viol_fwd = verify_interleaving(n, edges, filt1, filt2, epsilon)
    success_bwd, viol_bwd = verify_interleaving(n, edges, filt2, filt1, epsilon)
    print(f"\nForward interleaving (f₁ ≤ f₂ shifted): {'✓' if success_fwd else '✗'}")
    print(f"Backward interleaving (f₂ ≤ f₁ shifted): {'✓' if success_bwd else '✗'}")

    # Show profiles at sample points
    t_samples = np.linspace(-0.5, n + 0.5, 20)
    print(f"\n{'t':>8} {'P₁(t)':>8} {'P₂(t)':>8} {'P₂(t+ε)':>10} {'P₁≤P₂(t+ε)?':>14}")
    print("-" * 54)
    for t in t_samples:
        p1 = sheaf_event_profile(n, edges, filt1, t)
        p2 = sheaf_event_profile(n, edges, filt2, t)
        p2s = sheaf_event_profile(n, edges, filt2, t + epsilon)
        ok = "✓" if p1 <= p2s else "✗"
        print(f"{t:8.2f} {p1:8d} {p2:8d} {p2s:10d} {ok:>14}")


def demo_stalk_constancy():
    """Demonstrate stalk constancy between critical values."""
    print(f"\n{'='*60}")
    print(f"  CONSTRUCTIBILITY: Stalk Constancy Demo")
    print(f"{'='*60}\n")

    n = 5
    edges = path_graph_adj(n)
    filt = default_filtration(n)
    crit = critical_values(filt)

    print("Testing that active sets are identical between critical values:\n")
    for i in range(len(crit) - 1):
        c_lo, c_hi = crit[i], crit[i + 1]
        # Test at multiple points in (c_lo, c_hi)
        test_points = np.linspace(c_lo + 0.01, c_hi - 0.01, 5)
        av_ref = set(active_vertices(filt, c_lo))
        all_equal = True
        for t in test_points:
            av_t = set(active_vertices(filt, t))
            if av_t != av_ref:
                all_equal = False
                break
        status = "✓ CONSTANT" if all_equal else "✗ CHANGED"
        print(f"  Interval ({c_lo:.0f}, {c_hi:.0f}): {status}")
        print(f"    Stalk = {sorted(av_ref)}")
        print(f"    Profile value = {tropical_event_profile(n, edges, filt, c_lo)}")
        print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Sheaf-Theoretic Tropical Persistence — Full Demo       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_path_graph(6)
    demo_cycle_graph(6)
    demo_stability(5)
    demo_stalk_constancy()

    print(f"\n{'='*60}")
    print("  All demonstrations completed successfully.")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Constructibility of the Tropical Kernel Sheaf

Shows the active subgraph evolving through the filtration, with the
constructibility property highlighted: between critical values, the
active subgraph (and all its invariants) remain constant.

Produces a multi-panel figure showing the active subgraph at each
critical threshold and in between.

This visualizes: activeVerts_eq_of_sameCritGap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)


n = 6
edges = path_graph_edges(n)
filt = list(range(n))

# Create figure: show active graph at t = -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, ...
thresholds = [-0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
crit_set = set(filt)

fig, axes = plt.subplots(3, 4, figsize=(16, 10))

for idx, t in enumerate(thresholds):
    row, col = idx // 4, idx % 4
    ax = axes[row][col]

    is_critical = t in crit_set
    is_between = not is_critical and t > -1

    # Active vertices
    active = [v for v, fv in enumerate(filt) if fv <= t]
    active_set = set(active)

    # Draw all vertices
    positions = {v: (v * 1.5, 0) for v in range(n)}
    for v in range(n):
        x, y = positions[v]
        if v in active_set:
            ax.plot(x, y, 'o', markersize=20, color='#2c3e50', zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                   color='white', fontsize=10, fontweight='bold', zorder=6)
        else:
            ax.plot(x, y, 'o', markersize=20, color='#bdc3c7', zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                   color='#7f8c8d', fontsize=10, zorder=6)

    # Draw edges
    for (a, b) in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        if a in active_set and b in active_set:
            ax.plot([xa, xb], [ya, yb], '-', color='#2c3e50', linewidth=2.5, zorder=3)
        else:
            ax.plot([xa, xb], [ya, yb], '-', color='#ecf0f1', linewidth=1.5, zorder=2)

    # Profile value
    profile = sum(degree(n, edges, v) + 1 for v in active)

    # Styling
    if is_critical:
        ax.set_facecolor('#ffeaa7')
        title_color = '#e74c3c'
        label = f't = {t:.0f} (CRITICAL)'
    elif is_between:
        ax.set_facecolor('#dfe6e9')
        title_color = '#27ae60'
        label = f't = {t:.1f} (between)'
    else:
        ax.set_facecolor('#f5f6fa')
        title_color = '#636e72'
        label = f't = {t:.1f}'

    ax.set_title(label, fontsize=10, fontweight='bold', color=title_color)
    ax.text(0.02, 0.95, f'Profile = {profile}', transform=ax.transAxes,
           fontsize=9, verticalalignment='top',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    ax.set_xlim(-1, (n-1)*1.5 + 1)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

fig.suptitle('Constructibility: Active Subgraph is Constant Between Critical Values\n'
            '(Yellow = critical threshold, Gray = between critical values)',
            fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_constructibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_constructibility.png")


#!/usr/bin/env python3
"""
Visualization: Constructible Sheaf Profile for Tropical Persistence

Visualizes the main result — the tropical event profile as a step function
with jumps at critical values (entrance times). Shows:
- Top: Sheaf jump profile (bar chart at critical values)
- Bottom: Cumulative sheaf event profile = tropical event profile (step function)
- Vertical lines marking the singular support (critical values)

This visualizes the core theorem: tropEvtProfile_eq_cumSheafJump
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def cycle_graph_edges(n):
    return [(i, (i+1) % n) for i in range(n)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)

def sheaf_jump(n, edges, filt, c):
    entering = [v for v, fv in enumerate(filt) if fv == c]
    return sum(degree(n, edges, v) + 1 for v in entering)

def sheaf_event_profile(n, edges, filt, t):
    crit = sorted(set(filt))
    return sum(sheaf_jump(n, edges, filt, c) for c in crit if c <= t)


# Parameters
n = 8
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for col, (graph_name, edge_fn) in enumerate([("Path Graph P₈", path_graph_edges),
                                               ("Cycle Graph C₈", cycle_graph_edges)]):
    edges = edge_fn(n)
    filt = list(range(n))
    crit = sorted(set(filt))

    # Sheaf jumps
    jumps = [sheaf_jump(n, edges, filt, c) for c in crit]

    # Top: Bar chart of jumps
    ax_top = axes[0][col]
    colors = ['#e74c3c' if j >= 3 else '#3498db' for j in jumps]
    ax_top.bar(crit, jumps, width=0.6, color=colors, edgecolor='black', alpha=0.8)
    ax_top.set_ylabel('Sheaf Jump', fontsize=12)
    ax_top.set_title(f'{graph_name} — Sheaf Jumps at Critical Values', fontsize=13, fontweight='bold')
    ax_top.set_xlabel('Threshold t', fontsize=11)
    for i, (c, j) in enumerate(zip(crit, jumps)):
        ax_top.text(c, j + 0.1, str(j), ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Vertical lines for singular support
    for c in crit:
        ax_top.axvline(x=c, color='gray', linestyle=':', alpha=0.3)

    # Bottom: Step function of cumulative profile
    ax_bot = axes[1][col]
    t_range = np.linspace(-0.5, n + 0.5, 500)
    profile = [sheaf_event_profile(n, edges, filt, t) for t in t_range]

    ax_bot.plot(t_range, profile, color='#2c3e50', linewidth=2.5)
    ax_bot.fill_between(t_range, profile, alpha=0.15, color='#3498db')

    # Mark critical values with dots
    crit_profile = [sheaf_event_profile(n, edges, filt, c) for c in crit]
    ax_bot.scatter(crit, crit_profile, color='#e74c3c', s=60, zorder=5, edgecolors='black')

    # Vertical lines
    for c in crit:
        ax_bot.axvline(x=c, color='gray', linestyle=':', alpha=0.3)

    ax_bot.set_ylabel('Cumulative Profile', fontsize=12)
    ax_bot.set_xlabel('Threshold t', fontsize=11)
    ax_bot.set_title(f'{graph_name} — Sheaf Event Profile (Step Function)', fontsize=13, fontweight='bold')

    # Annotate: "constructible = constant between jumps"
    if col == 0:
        ax_bot.annotate('Constructible:\nconstant between\ncritical values',
                       xy=(2.5, sheaf_event_profile(n, edges, filt, 2.5)),
                       xytext=(4, 5),
                       fontsize=9, fontweight='bold', color='#27ae60',
                       arrowprops=dict(arrowstyle='->', color='#27ae60'))

plt.suptitle('Constructible Sheaf Structure of Tropical Persistence',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_sheaf_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_sheaf_profile.png")


#!/usr/bin/env python3
"""
Visualization: Sheaf-Theoretic Stability via Interleaving

Visualizes the stability theorem: if two filtrations are ε-close, their
sheaf event profiles are ε-interleaved. Shows:
- Original and perturbed sheaf profiles
- The ε-shifted envelope demonstrating interleaving
- The stability corridor

This visualizes: sheafEvtProfile_stability
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)

def sheaf_jump(n, edges, filt, c):
    entering = [v for v, fv in enumerate(filt) if abs(fv - c) < 1e-10]
    return sum(degree(n, edges, v) + 1 for v in entering)

def sheaf_event_profile(n, edges, filt, t):
    crit = sorted(set(filt))
    return sum(sheaf_jump(n, edges, filt, c) for c in crit if c <= t + 1e-10)


n = 7
edges = path_graph_edges(n)
filt1 = [float(i) for i in range(n)]
filt2 = [float(i) + 0.4 * math.sin(i * 1.5) for i in range(n)]
epsilon = max(abs(a - b) for a, b in zip(filt1, filt2))

t_range = np.linspace(-1, n + 1, 1000)

prof1 = [sheaf_event_profile(n, edges, filt1, t) for t in t_range]
prof2 = [sheaf_event_profile(n, edges, filt2, t) for t in t_range]
prof1_shifted = [sheaf_event_profile(n, edges, filt1, t + epsilon) for t in t_range]
prof2_shifted = [sheaf_event_profile(n, edges, filt2, t + epsilon) for t in t_range]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9))

# Top plot: Both profiles with interleaving envelope
ax1.plot(t_range, prof1, color='#2c3e50', linewidth=2.5, label='Profile f₁ (original)')
ax1.plot(t_range, prof2, color='#e74c3c', linewidth=2.5, label='Profile f₂ (perturbed)')
ax1.plot(t_range, prof2_shifted, color='#e74c3c', linewidth=1.5, linestyle='--',
         alpha=0.6, label=f'Profile f₂(t+ε)')
ax1.fill_between(t_range, prof1, prof2_shifted, alpha=0.1, color='#27ae60',
                 label='Interleaving corridor')

for c in sorted(set(filt1)):
    ax1.axvline(x=c, color='#3498db', linestyle=':', alpha=0.2)
for c in sorted(set(filt2)):
    ax1.axvline(x=c, color='#e74c3c', linestyle=':', alpha=0.2)

ax1.set_ylabel('Sheaf Event Profile', fontsize=12)
ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_title(f'Sheaf-Theoretic Stability: ε-Interleaving (ε = {epsilon:.3f})',
             fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')

# Bottom plot: Profile difference and bound
diff = [abs(p1 - p2) for p1, p2 in zip(prof1, prof2)]
ax2.fill_between(t_range, diff, alpha=0.3, color='#e74c3c')
ax2.plot(t_range, diff, color='#e74c3c', linewidth=2, label='|P₁(t) - P₂(t)|')

# Show that the difference is bounded by the max possible shift
max_diff = max(diff)
ax2.axhline(y=max_diff, color='#2c3e50', linestyle='--', linewidth=1.5,
           label=f'Max difference = {max_diff}')

ax2.set_ylabel('Profile Difference', fontsize=12)
ax2.set_xlabel('Threshold t', fontsize=11)
ax2.set_title('Profile Difference Under Perturbation', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)

# Add annotation
ax2.annotate(f'Stability: profiles are\nε-interleaved with ε={epsilon:.3f}',
            xy=(n/2, max_diff * 0.7),
            fontsize=11, fontweight='bold', color='#27ae60',
            ha='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#eafaf1', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
