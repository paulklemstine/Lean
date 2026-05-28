"""
Applications of Sheaf-Theoretic Tropical Persistence
=====================================================

Real-world applications of the sheaf-theoretic framework:
1. Network analysis: detecting phase transitions in dynamic networks
2. Sensor coverage: tracking coverage changes in sensor networks
3. Social network evolution: community formation events
"""

from typing import List, Dict, Tuple, Set
from collections import defaultdict
import math
import random


# ─── Core infrastructure (self-contained) ───────────────────────────

class Graph:
    def __init__(self, vertices: Set[int], edges: List[Tuple[int, int]]):
        self.vertices = vertices
        self.edges = edges
        self._adj: Dict[int, Set[int]] = defaultdict(set)
        for u, v in edges:
            self._adj[u].add(v)
            self._adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self._adj[v])


class VertexFiltration:
    def __init__(self, entrance_times: Dict[int, float]):
        self.entrance_times = entrance_times
        self._critical_values = sorted(set(entrance_times.values()))

    @property
    def critical_values(self) -> List[float]:
        return self._critical_values

    def active_vertices(self, t: float) -> Set[int]:
        return {v for v, ft in self.entrance_times.items() if ft <= t}

    def fiber(self, c: float) -> Set[int]:
        return {v for v, ft in self.entrance_times.items() if ft == c}

    def sup_distance(self, other: 'VertexFiltration') -> float:
        return max(abs(self.entrance_times[v] - other.entrance_times[v])
                   for v in self.entrance_times)


def sheaf_jump(G: Graph, filt: VertexFiltration, c: float) -> int:
    return sum(G.degree(v) + 1 for v in filt.fiber(c))


def sheaf_event_profile(G: Graph, filt: VertexFiltration, t: float) -> int:
    return sum(sheaf_jump(G, filt, c) for c in filt.critical_values if c <= t)


def connected_components(vertices: Set[int],
                        edges: List[Tuple[int, int]]) -> int:
    """Count connected components via union-find."""
    if not vertices:
        return 0
    parent = {v: v for v in vertices}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    for u, v in edges:
        if u in vertices and v in vertices:
            pu, pv = find(u), find(v)
            if pu != pv:
                parent[pu] = pv
    return len(set(find(v) for v in vertices))


# ─── Application 1: Network Phase Transitions ──────────────────────

def network_phase_transition_analysis():
    """
    Analyze phase transitions in a growing network using sheaf jumps.

    Model: vertices represent nodes in a network that come online at
    different times. Large sheaf jumps indicate phase transitions where
    the network structure changes significantly.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Phase Transition Detection")
    print("=" * 60)

    # Build a network with clear phase transitions
    n = 20
    random.seed(42)
    vertices = set(range(n))

    # Create edges: dense clusters connected by bridges
    edges = []
    # Cluster 1: vertices 0-6 (dense)
    for i in range(7):
        for j in range(i + 1, 7):
            if random.random() < 0.6:
                edges.append((i, j))
    # Cluster 2: vertices 7-13 (dense)
    for i in range(7, 14):
        for j in range(i + 1, 14):
            if random.random() < 0.6:
                edges.append((i, j))
    # Bridge: vertex 14 connects clusters
    edges.append((6, 14))
    edges.append((14, 7))
    # Cluster 3: vertices 15-19
    for i in range(15, 20):
        for j in range(i + 1, 20):
            if random.random() < 0.5:
                edges.append((i, j))
    edges.append((13, 15))

    G = Graph(vertices, edges)

    # Filtration: vertices enter at their index time
    filt = VertexFiltration({i: float(i) for i in range(n)})

    print(f"\nNetwork: {n} vertices, {len(edges)} edges")
    print(f"Critical values: {filt.critical_values}")

    print(f"\n{'Time':>6} | {'Active':>6} | {'Components':>10} | {'Jump':>5} | {'Profile':>8} | {'Phase':>8}")
    print("-" * 60)

    prev_profile = 0
    for c in filt.critical_values:
        active = filt.active_vertices(c)
        active_edges = [(u, v) for u, v in edges if u in active and v in active]
        comps = connected_components(active, edges)
        j = sheaf_jump(G, filt, c)
        profile = sheaf_event_profile(G, filt, c)

        # Detect phase transitions: large jumps relative to average
        avg_jump = profile / (c + 1) if c >= 0 else 0
        phase = "⚡ TRANS" if j > avg_jump * 1.5 and c > 0 else ""

        print(f"{c:>6.0f} | {len(active):>6} | {comps:>10} | {j:>5} | {profile:>8} | {phase:>8}")
        prev_profile = profile

    # Identify the strongest phase transitions
    jumps = [(c, sheaf_jump(G, filt, c)) for c in filt.critical_values]
    jumps.sort(key=lambda x: x[1], reverse=True)
    print(f"\nTop 3 phase transitions (by sheaf jump):")
    for c, j in jumps[:3]:
        v = int(c)
        print(f"  t={c}: jump={j} (vertex {v}, degree={G.degree(v)})")


# ─── Application 2: Sensor Coverage Analysis ───────────────────────

def sensor_coverage_analysis():
    """
    Track coverage changes in a sensor network using constructible sheaf theory.

    Model: sensors activate at different times. The sheaf tracks
    how coverage (active sensors and their connections) evolves.
    Constructibility means coverage is stable between activation events.
    """
    print(f"\n{'='*60}")
    print("APPLICATION 2: Sensor Coverage Analysis")
    print("=" * 60)

    # Grid-like sensor network
    grid_size = 4
    vertices = set()
    edges = []
    for i in range(grid_size):
        for j in range(grid_size):
            v = i * grid_size + j
            vertices.add(v)
            if j < grid_size - 1:
                edges.append((v, v + 1))
            if i < grid_size - 1:
                edges.append((v, v + grid_size))

    G = Graph(vertices, edges)

    # Activation times: center sensors activate first, periphery later
    center = (grid_size - 1) / 2
    activation = {}
    for i in range(grid_size):
        for j in range(grid_size):
            v = i * grid_size + j
            dist = abs(i - center) + abs(j - center)
            activation[v] = dist

    filt = VertexFiltration(activation)
    print(f"\nSensor grid: {grid_size}x{grid_size} = {len(vertices)} sensors")
    print(f"Activation order: center-out (Manhattan distance)")
    print(f"Critical values: {filt.critical_values}")

    print(f"\n{'Phase':>6} | {'Sensors':>7} | {'Coverage':>8} | {'Jump':>5} | {'Components':>10}")
    print("-" * 52)

    for c in filt.critical_values:
        active = filt.active_vertices(c)
        comps = connected_components(active, edges)
        j = sheaf_jump(G, filt, c)
        coverage_pct = len(active) / len(vertices) * 100
        print(f"{c:>6.0f} | {len(active):>7} | {coverage_pct:>7.0f}% | {j:>5} | {comps:>10}")

    # Stability analysis: perturbations
    print(f"\n--- Stability under sensor timing jitter ---")
    random.seed(123)
    for eps in [0.1, 0.3, 0.5]:
        perturbed = {v: activation[v] + random.uniform(-eps, eps) for v in vertices}
        filt2 = VertexFiltration(perturbed)
        max_diff = 0
        for t_val in range(int(max(activation.values())) + 2):
            t = float(t_val)
            p1 = sheaf_event_profile(G, filt, t)
            p2 = sheaf_event_profile(G, filt2, t)
            max_diff = max(max_diff, abs(p1 - p2))
        print(f"  ε={eps}: sup_dist={filt.sup_distance(filt2):.3f}, max profile diff={max_diff}")


# ─── Application 3: Community Formation ─────────────────────────────

def community_formation_analysis():
    """
    Track community formation in a social network using Möbius inversion.

    The Möbius-like formula decomposes the global profile into local contributions,
    revealing which community formation events contribute most to network complexity.
    """
    print(f"\n{'='*60}")
    print("APPLICATION 3: Community Formation via Möbius Inversion")
    print("=" * 60)

    # Social network: two communities with a bridge
    n = 12
    vertices = set(range(n))
    edges = []

    # Community A: {0,1,2,3,4}
    for i in range(5):
        for j in range(i + 1, 5):
            edges.append((i, j))

    # Community B: {5,6,7,8,9}
    for i in range(5, 10):
        for j in range(i + 1, 10):
            edges.append((i, j))

    # Bridges
    edges.append((4, 5))  # Bridge between A and B
    edges.append((9, 10))  # Extension to {10, 11}
    edges.append((10, 11))

    G = Graph(vertices, edges)
    filt = VertexFiltration({i: float(i) for i in range(n)})

    print(f"\nSocial network: {n} people, {len(edges)} connections")
    print(f"Communities: A={{0-4}}, B={{5-9}}, extension={{10-11}}")

    # Compute Möbius inversion
    crits = filt.critical_values
    print(f"\n--- Möbius Inversion: Profile Decomposition ---")
    print(f"{'Interval':>15} | {'Jump':>5} | {'Cumulative':>10} | {'Description':>20}")
    print("-" * 60)

    cumulative = 0
    for i, c in enumerate(crits):
        j = sheaf_jump(G, filt, c)
        cumulative += j
        v = int(c)
        desc = f"vertex {v} (deg={G.degree(v)})"
        if v <= 4:
            desc += " [comm A]"
        elif v <= 9:
            desc += " [comm B]"
        else:
            desc += " [extension]"

        s_str = f"({crits[i-1]:.0f}, {c:.0f}]" if i > 0 else f"(-∞, {c:.0f}]"
        print(f"{s_str:>15} | {j:>5} | {cumulative:>10} | {desc:>20}")

    # Verify telescoping
    total_profile = sheaf_event_profile(G, filt, float(n))
    print(f"\nTotal profile (computed): {total_profile}")
    print(f"Cumulative jumps: {cumulative}")
    print(f"Match: {'✓' if total_profile == cumulative else '✗'}")


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    network_phase_transition_analysis()
    sensor_coverage_analysis()
    community_formation_analysis()
    print(f"\n{'='*60}")
    print("All applications completed.")
    print("=" * 60)


"""
Sheaf-Theoretic Tropical Persistence: Interactive Demo
=====================================================

Demonstrates the core theorems on path graphs and cycle graphs:
1. Critical thresholds and stalk values
2. Sheaf jump computation
3. Cumulative jump profile = event profile
4. Constructibility (locally constant between critical values)
5. Stability under perturbation
"""

import numpy as np
from typing import List, Dict, Tuple, Optional


# ─── Graph definitions ───────────────────────────────────────────────

def path_graph_adj(n: int) -> List[Tuple[int, int]]:
    """Edges of the path graph P_{n+1} on vertices {0, ..., n}."""
    return [(i, i + 1) for i in range(n)]


def cycle_graph_adj(n: int) -> List[Tuple[int, int]]:
    """Edges of the cycle graph C_n on vertices {0, ..., n-1}. Requires n >= 3."""
    assert n >= 3
    return [(i, (i + 1) % n) for i in range(n)]


def degree(edges: List[Tuple[int, int]], v: int) -> int:
    """Degree of vertex v in the graph."""
    return sum(1 for (a, b) in edges if a == v or b == v)


# ─── Filtration and active sets ──────────────────────────────────────

def active_vertices(filt: Dict[int, float], t: float) -> set:
    """Vertices whose entrance time is ≤ t."""
    return {v for v, ft in filt.items() if ft <= t}


def tropical_event_profile(edges: List[Tuple[int, int]],
                            filt: Dict[int, float],
                            t: float) -> int:
    """Cumulative degree-weighted event profile at threshold t."""
    active = active_vertices(filt, t)
    return sum(degree(edges, v) + 1 for v in active)


# ─── Sheaf constructions ────────────────────────────────────────────

def critical_values(filt: Dict[int, float]) -> List[float]:
    """Sorted critical values (entrance times)."""
    return sorted(set(filt.values()))


def sheaf_jump(edges: List[Tuple[int, int]],
               filt: Dict[int, float],
               c: float) -> int:
    """Sheaf jump at critical value c: sum of (degree(v) + 1) for vertices entering at time c."""
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)


def cumulative_sheaf_jump(edges: List[Tuple[int, int]],
                          filt: Dict[int, float],
                          t: float) -> int:
    """Cumulative sheaf jump up to threshold t."""
    crits = critical_values(filt)
    return sum(sheaf_jump(edges, filt, c) for c in crits if c <= t)


def stalk_rank(filt: Dict[int, float], t: float) -> int:
    """Stalk rank = |active vertices at t|."""
    return len(active_vertices(filt, t))


def singular_support(edges: List[Tuple[int, int]],
                     filt: Dict[int, float]) -> List[float]:
    """Critical values where sheaf jump is nonzero."""
    return [c for c in critical_values(filt) if sheaf_jump(edges, filt, c) != 0]


def higher_sheaf_jump(filt: Dict[int, float], c: float) -> int:
    """Higher sheaf jump: counts simultaneous vertex entrances above 1."""
    fiber = [v for v, ft in filt.items() if ft == c]
    return max(0, len(fiber) - 1)


# ─── Demo 1: Path Graph ─────────────────────────────────────────────

def demo_path_graph(n: int = 5):
    """Demonstrate sheaf constructions on path graph P_{n+1}."""
    print(f"\n{'='*60}")
    print(f"DEMO 1: Path Graph P_{n+1} (vertices 0..{n})")
    print(f"{'='*60}")

    edges = path_graph_adj(n)
    # Natural filtration: vertex i enters at time i
    filt = {i: float(i) for i in range(n + 1)}

    crits = critical_values(filt)
    print(f"\nCritical values: {crits}")
    print(f"Singular support: {singular_support(edges, filt)}")
    print(f"\n{'Threshold':>10} | {'Active':>8} | {'Stalk':>6} | {'EventProf':>10} | {'CumJump':>8} | {'Match':>5}")
    print("-" * 65)

    # Test at various thresholds including between critical values
    test_thresholds = sorted(set(
        [c - 0.5 for c in crits] + crits + [c + 0.5 for c in crits] + [-1.0, n + 1.0]
    ))

    for t in test_thresholds:
        active = active_vertices(filt, t)
        sr = stalk_rank(filt, t)
        ep = tropical_event_profile(edges, filt, t)
        cj = cumulative_sheaf_jump(edges, filt, t)
        match = "✓" if ep == cj else "✗"
        print(f"{t:>10.1f} | {str(active):>8} | {sr:>6} | {ep:>10} | {cj:>8} | {match:>5}")

    print(f"\n--- Sheaf Jumps at Critical Values ---")
    for c in crits:
        j = sheaf_jump(edges, filt, c)
        hj = higher_sheaf_jump(filt, c)
        v = int(c)
        d = degree(edges, v)
        print(f"  c={c}: jump={j} (vertex {v}, degree={d}, weight={d+1}), higher_jump={hj}")

    # Verify Theorem: sheaf jump ≤ 3 for path graphs
    print(f"\n--- Theorem Verification: sheafJump ≤ 3 ---")
    all_ok = all(sheaf_jump(edges, filt, c) <= 3 for c in crits)
    print(f"  All jumps ≤ 3: {all_ok}")

    # Verify constructibility: profile constant between critical values
    print(f"\n--- Constructibility Check ---")
    for i in range(len(crits) - 1):
        s = (crits[i] + crits[i + 1]) / 2 - 0.1
        t = (crits[i] + crits[i + 1]) / 2 + 0.1
        ep_s = tropical_event_profile(edges, filt, s)
        ep_t = tropical_event_profile(edges, filt, t)
        print(f"  Between c={crits[i]} and c={crits[i+1]}: profile({s:.1f})={ep_s}, profile({t:.1f})={ep_t}, constant={ep_s==ep_t}")


# ─── Demo 2: Cycle Graph ────────────────────────────────────────────

def demo_cycle_graph(n: int = 6):
    """Demonstrate sheaf constructions on cycle graph C_n."""
    print(f"\n{'='*60}")
    print(f"DEMO 2: Cycle Graph C_{n} (vertices 0..{n-1})")
    print(f"{'='*60}")

    edges = cycle_graph_adj(n)
    filt = {i: float(i) for i in range(n)}

    crits = critical_values(filt)
    print(f"\nCritical values: {crits}")
    print(f"Singular support: {singular_support(edges, filt)}")

    print(f"\n{'Threshold':>10} | {'Stalk':>6} | {'EventProf':>10} | {'CumJump':>8} | {'Match':>5}")
    print("-" * 55)

    test_thresholds = sorted(set(
        [c - 0.5 for c in crits] + crits + [c + 0.5 for c in crits] + [-1.0, n + 0.5]
    ))

    for t in test_thresholds:
        sr = stalk_rank(filt, t)
        ep = tropical_event_profile(edges, filt, t)
        cj = cumulative_sheaf_jump(edges, filt, t)
        match = "✓" if ep == cj else "✗"
        print(f"{t:>10.1f} | {sr:>6} | {ep:>10} | {cj:>8} | {match:>5}")

    print(f"\n--- Sheaf Jumps ---")
    for c in crits:
        j = sheaf_jump(edges, filt, c)
        hj = higher_sheaf_jump(filt, c)
        v = int(c)
        d = degree(edges, v)
        print(f"  c={c}: jump={j}, vertex {v}, degree={d}, higher_jump={hj}")

    # Verify higher jump vanishing (injective filtration)
    print(f"\n--- Higher Jump Vanishing (injective filtration) ---")
    all_zero = all(higher_sheaf_jump(filt, c) == 0 for c in crits)
    print(f"  All higher jumps = 0: {all_zero}")


# ─── Demo 3: Stability ──────────────────────────────────────────────

def demo_stability(n: int = 5, epsilon: float = 0.3):
    """Demonstrate stability of sheaf event profiles under perturbation."""
    print(f"\n{'='*60}")
    print(f"DEMO 3: Stability (path P_{n+1}, ε={epsilon})")
    print(f"{'='*60}")

    edges = path_graph_adj(n)
    filt1 = {i: float(i) for i in range(n + 1)}

    # Perturbed filtration
    np.random.seed(42)
    perturbation = {i: np.random.uniform(-epsilon, epsilon) for i in range(n + 1)}
    filt2 = {i: filt1[i] + perturbation[i] for i in range(n + 1)}

    sup_dist = max(abs(filt1[v] - filt2[v]) for v in filt1)
    print(f"\nSup distance: {sup_dist:.4f}")
    print(f"Perturbation bound ε: {epsilon}")

    print(f"\n{'t':>6} | {'Prof1':>6} | {'Prof2':>6} | {'Prof2(t+ε)':>11} | {'Interleaved':>11}")
    print("-" * 55)

    for t_int in range(-1, n + 3):
        t = float(t_int) * 0.5
        p1 = cumulative_sheaf_jump(edges, filt1, t)
        p2 = cumulative_sheaf_jump(edges, filt2, t)
        p2_shift = cumulative_sheaf_jump(edges, filt2, t + epsilon)
        interleaved = p1 <= p2_shift
        print(f"{t:>6.1f} | {p1:>6} | {p2:>6} | {p2_shift:>11} | {'✓' if interleaved else '✗':>11}")

    # Verify interleaving both directions
    print(f"\n--- Full Interleaving Check ---")
    thresholds = np.linspace(-1, n + 1, 100)
    fwd_ok = all(
        cumulative_sheaf_jump(edges, filt1, t) <= cumulative_sheaf_jump(edges, filt2, t + epsilon)
        for t in thresholds
    )
    bwd_ok = all(
        cumulative_sheaf_jump(edges, filt2, t) <= cumulative_sheaf_jump(edges, filt1, t + epsilon)
        for t in thresholds
    )
    print(f"  Forward interleaving (f1 ≤ f2 shifted): {fwd_ok}")
    print(f"  Backward interleaving (f2 ≤ f1 shifted): {bwd_ok}")


# ─── Demo 4: Möbius Inversion ───────────────────────────────────────

def demo_mobius_inversion(n: int = 5):
    """Demonstrate the Möbius-like inversion formula."""
    print(f"\n{'='*60}")
    print(f"DEMO 4: Möbius Inversion Formula (path P_{n+1})")
    print(f"{'='*60}")

    edges = path_graph_adj(n)
    filt = {i: float(i) for i in range(n + 1)}
    crits = critical_values(filt)

    print(f"\nVerifying: profile(t) - profile(s) = Σ jumps in (s,t]")
    print(f"\n{'s':>4} | {'t':>4} | {'Δprofile':>9} | {'Σjumps':>8} | {'Match':>5}")
    print("-" * 40)

    for i in range(len(crits)):
        for j in range(i, len(crits)):
            s = crits[i] - 0.5 if i == 0 else crits[i]
            t = crits[j]
            prof_s = cumulative_sheaf_jump(edges, filt, s)
            prof_t = cumulative_sheaf_jump(edges, filt, t)
            delta = prof_t - prof_s
            jump_sum = sum(
                sheaf_jump(edges, filt, c)
                for c in crits if s < c <= t
            )
            match = "✓" if delta == jump_sum else "✗"
            print(f"{s:>4.1f} | {t:>4.1f} | {delta:>9} | {jump_sum:>8} | {match:>5}")


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_path_graph(5)
    demo_cycle_graph(6)
    demo_stability(5, 0.3)
    demo_mobius_inversion(5)
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Constructible Sheaf on the Threshold Line
=========================================================

Visualizes the core mathematical concept: the tropical event profile
as a constructible sheaf, with jumps at critical values and constant
stalks between them. Shows path graph and cycle graph side by side.

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict
from typing import List, Tuple, Dict, Set


# ─── Self-contained graph/filtration infrastructure ──────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def cycle_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, (i + 1) % n) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def cum_profile(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    crits = sorted(set(filt.values()))
    return sum(sheaf_jump(edges, filt, c) for c in crits if c <= t)


# ─── Main visualization ─────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Path Graph P_6 ---
n_path = 5
edges_p = path_edges(n_path)
filt_p = {i: float(i) for i in range(n_path + 1)}
crits_p = sorted(set(filt_p.values()))

# Panel 1: Sheaf profile (step function)
ax1 = axes[0, 0]
t_range = [c - 0.5 for c in crits_p] + crits_p + [c + 0.5 for c in crits_p]
t_range = sorted(set(t_range + [-1.0, n_path + 1.0]))
t_range = [t for t in t_range if -1.5 <= t <= n_path + 1.5]
profiles_p = [cum_profile(edges_p, filt_p, t) for t in t_range]

ax1.step(t_range, profiles_p, where='post', color='#2196F3', linewidth=2, label='Sheaf Event Profile')
for c in crits_p:
    j = sheaf_jump(edges_p, filt_p, c)
    y = cum_profile(edges_p, filt_p, c)
    ax1.plot(c, y, 'o', color='#F44336', markersize=8, zorder=5)
    ax1.annotate(f'+{j}', (c, y), textcoords="offset points",
                xytext=(5, 10), fontsize=9, color='#F44336', fontweight='bold')

ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_ylabel('Profile Value', fontsize=11)
ax1.set_title('Path Graph P₆: Constructible Sheaf Profile', fontsize=12, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-1.5, n_path + 1.5)

# Panel 2: Sheaf jumps (bar chart)
ax2 = axes[0, 1]
jumps_p = [sheaf_jump(edges_p, filt_p, c) for c in crits_p]
colors_p = ['#4CAF50' if j <= 2 else '#FF9800' for j in jumps_p]
ax2.bar(crits_p, jumps_p, width=0.6, color=colors_p, edgecolor='black', linewidth=0.5)
ax2.axhline(y=3, color='red', linestyle='--', alpha=0.5, label='Bound (≤3)')
for i, (c, j) in enumerate(zip(crits_p, jumps_p)):
    ax2.text(c, j + 0.1, str(j), ha='center', fontsize=10, fontweight='bold')
ax2.set_xlabel('Critical Value', fontsize=11)
ax2.set_ylabel('Sheaf Jump', fontsize=11)
ax2.set_title('Path Graph P₆: Sheaf Jumps (Singular Support)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# --- Cycle Graph C_6 ---
n_cycle = 6
edges_c = cycle_edges(n_cycle)
filt_c = {i: float(i) for i in range(n_cycle)}
crits_c = sorted(set(filt_c.values()))

# Panel 3: Sheaf profile (step function)
ax3 = axes[1, 0]
t_range_c = sorted(set(
    [c - 0.5 for c in crits_c] + crits_c + [c + 0.5 for c in crits_c] + [-1.0, n_cycle + 0.5]
))
t_range_c = [t for t in t_range_c if -1.5 <= t <= n_cycle + 0.5]
profiles_c = [cum_profile(edges_c, filt_c, t) for t in t_range_c]

ax3.step(t_range_c, profiles_c, where='post', color='#9C27B0', linewidth=2, label='Sheaf Event Profile')
for c in crits_c:
    j = sheaf_jump(edges_c, filt_c, c)
    y = cum_profile(edges_c, filt_c, c)
    ax3.plot(c, y, 'o', color='#F44336', markersize=8, zorder=5)
    ax3.annotate(f'+{j}', (c, y), textcoords="offset points",
                xytext=(5, 10), fontsize=9, color='#F44336', fontweight='bold')

ax3.set_xlabel('Threshold t', fontsize=11)
ax3.set_ylabel('Profile Value', fontsize=11)
ax3.set_title('Cycle Graph C₆: Constructible Sheaf Profile', fontsize=12, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Stalk rank evolution
ax4 = axes[1, 1]
stalk_ranks_p = [len({v for v, ft in filt_p.items() if ft <= t}) for t in t_range]
stalk_ranks_c = [len({v for v, ft in filt_c.items() if ft <= t}) for t in t_range_c]

ax4.step(t_range, stalk_ranks_p, where='post', color='#2196F3', linewidth=2, label='Path P₆')
ax4.step(t_range_c, stalk_ranks_c, where='post', color='#9C27B0', linewidth=2, label='Cycle C₆')
ax4.set_xlabel('Threshold t', fontsize=11)
ax4.set_ylabel('Stalk Rank (|Active Vertices|)', fontsize=11)
ax4.set_title('Stalk Rank: Constructible Step Functions', fontsize=12, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sheaf_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: sheaf_visualization.png")


"""
Visualization: Sheaf-Theoretic Stability
=========================================

Visualizes the stability theorem: when two filtrations are ε-close,
their sheaf event profiles are ε-interleaved. Shows the original
and perturbed profiles with the interleaving bands.

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random
from typing import List, Tuple, Dict


# ─── Self-contained infrastructure ──────────────────────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def cum_profile(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    crits = sorted(set(filt.values()))
    return sum(sheaf_jump(edges, filt, c) for c in crits if c <= t)


# ─── Setup ───────────────────────────────────────────────────────────

n = 7
edges = path_edges(n)
filt1 = {i: float(i) for i in range(n + 1)}

random.seed(42)
epsilon = 0.5
filt2 = {i: filt1[i] + random.uniform(-epsilon, epsilon) for i in range(n + 1)}
actual_eps = max(abs(filt1[v] - filt2[v]) for v in filt1)

# Sample points
t_vals = [i * 0.1 for i in range(-15, n * 10 + 20)]

prof1 = [cum_profile(edges, filt1, t) for t in t_vals]
prof2 = [cum_profile(edges, filt2, t) for t in t_vals]
prof2_shifted = [cum_profile(edges, filt2, t + actual_eps) for t in t_vals]
prof1_shifted = [cum_profile(edges, filt1, t + actual_eps) for t in t_vals]

# ─── Plot ────────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: profiles with interleaving
ax1.plot(t_vals, prof1, color='#2196F3', linewidth=2.5, label='Original filtration f₁')
ax1.plot(t_vals, prof2, color='#F44336', linewidth=2.5, label='Perturbed filtration f₂')
ax1.plot(t_vals, prof2_shifted, color='#F44336', linewidth=1, linestyle='--',
         alpha=0.5, label=f'f₂(t + ε)')
ax1.plot(t_vals, prof1_shifted, color='#2196F3', linewidth=1, linestyle='--',
         alpha=0.5, label=f'f₁(t + ε)')

# Shade interleaving region
ax1.fill_between(t_vals, prof1, prof2_shifted, alpha=0.1, color='green')

ax1.set_xlabel('Threshold t', fontsize=12)
ax1.set_ylabel('Sheaf Event Profile', fontsize=12)
ax1.set_title(f'Stability: ε-Interleaving (ε = {actual_eps:.3f})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-1, n + 1)

# Right panel: profile difference
diffs = [abs(p1 - p2) for p1, p2 in zip(prof1, prof2)]
max_shift_bound = [max(cum_profile(edges, filt2, t + actual_eps) - cum_profile(edges, filt2, t),
                       cum_profile(edges, filt1, t + actual_eps) - cum_profile(edges, filt1, t))
                   for t in t_vals]

ax2.fill_between(t_vals, 0, max_shift_bound, alpha=0.2, color='orange', label='Stability bound')
ax2.plot(t_vals, diffs, color='#4CAF50', linewidth=2, label='|Profile₁ - Profile₂|')
ax2.plot(t_vals, max_shift_bound, color='orange', linewidth=1, linestyle='--', alpha=0.7)

ax2.set_xlabel('Threshold t', fontsize=12)
ax2.set_ylabel('Profile Difference', fontsize=12)
ax2.set_title('Sheaf-Theoretic Stability Bound', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-1, n + 1)

plt.tight_layout()
plt.savefig('stability_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: stability_visualization.png")


"""
Visualization: Critical Stratification and Singular Support
=============================================================

Visualizes the critical stratification of the threshold line,
showing how the sheaf is constructible: constant on open strata
with jumps only at critical values (the singular support).

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from typing import List, Tuple, Dict


# ─── Self-contained infrastructure ──────────────────────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def cycle_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, (i + 1) % n) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def active_verts(filt: Dict[int, float], t: float) -> set:
    return {v for v, ft in filt.items() if ft <= t}

def euler_char(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    active = active_verts(filt, t)
    ae = sum(1 for u, v in edges if u in active and v in active)
    return len(active) - ae


# ─── Setup ───────────────────────────────────────────────────────────

n = 6
edges = path_edges(n)
filt = {i: float(i) for i in range(n + 1)}
crits = sorted(set(filt.values()))

fig, axes = plt.subplots(3, 1, figsize=(12, 10))

# ─── Panel 1: Critical Stratification ───────────────────────────────

ax1 = axes[0]

# Draw the threshold line
ax1.axhline(y=0, color='black', linewidth=1)

# Draw open strata (green bars)
for i in range(len(crits) - 1):
    ax1.fill_between([crits[i], crits[i+1]], -0.15, 0.15,
                     color='#4CAF50', alpha=0.3)
    ax1.plot([(crits[i] + crits[i+1])/2], [0], 's',
            color='#4CAF50', markersize=10, zorder=5)

# Draw critical strata (red dots)
for c in crits:
    j = sheaf_jump(edges, filt, c)
    ax1.plot(c, 0, 'o', color='#F44336', markersize=12, zorder=6)
    ax1.annotate(f'c={int(c)}\njump={j}',
                (c, 0), textcoords="offset points",
                xytext=(0, 20), fontsize=9, ha='center',
                color='#F44336', fontweight='bold')

# Arrow indicating singular support
ax1.annotate('', xy=(-0.5, -0.3), xytext=(n + 0.5, -0.3),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=1.5))
ax1.text(n/2, -0.45, 'Singular Support = Critical Values',
        ha='center', fontsize=10, color='purple', style='italic')

ax1.set_xlim(-1, n + 1)
ax1.set_ylim(-0.6, 0.6)
ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_title('Critical Stratification of the Threshold Line',
             fontsize=13, fontweight='bold')
ax1.set_yticks([])

legend_elements = [
    mpatches.Patch(color='#F44336', alpha=0.8, label='Critical strata (jumps)'),
    mpatches.Patch(color='#4CAF50', alpha=0.3, label='Open strata (sheaf constant)')
]
ax1.legend(handles=legend_elements, fontsize=10, loc='upper left')

# ─── Panel 2: Stalk Data at Each Stratum ────────────────────────────

ax2 = axes[1]

t_range = []
stalk_data = []
for i, c in enumerate(crits):
    if i > 0:
        t_mid = (crits[i-1] + c) / 2
        t_range.append(t_mid)
        stalk_data.append(len(active_verts(filt, t_mid)))
    t_range.append(c)
    stalk_data.append(len(active_verts(filt, c)))

# Add endpoints
t_range_ext = [-0.5] + t_range + [n + 0.5]
stalk_ext = [0] + stalk_data + [stalk_data[-1]]

ax2.step(t_range_ext, stalk_ext, where='post', color='#2196F3', linewidth=2.5)

for c in crits:
    sr = len(active_verts(filt, c))
    ax2.plot(c, sr, 'o', color='#F44336', markersize=8, zorder=5)

ax2.set_xlabel('Threshold t', fontsize=11)
ax2.set_ylabel('Stalk Rank', fontsize=11)
ax2.set_title('Stalk Rank = |Active Vertices| (Constructible Step Function)',
             fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-1, n + 1)

# ─── Panel 3: Euler Characteristic ──────────────────────────────────

ax3 = axes[2]

t_fine = [i * 0.05 for i in range(-20, (n + 1) * 20 + 10)]
euler_vals = [euler_char(edges, filt, t) for t in t_fine]

ax3.step(t_fine, euler_vals, where='post', color='#FF9800', linewidth=2.5)

for c in crits:
    ec = euler_char(edges, filt, c)
    ax3.plot(c, ec, 'o', color='#F44336', markersize=8, zorder=5)

ax3.set_xlabel('Threshold t', fontsize=11)
ax3.set_ylabel('Euler Characteristic', fontsize=11)
ax3.set_title('Euler Characteristic χ(t) = |V_active| - |E_active| (Also Constructible)',
             fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3)
ax3.set_xlim(-1, n + 1)
ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('stratification_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: stratification_visualization.png")
