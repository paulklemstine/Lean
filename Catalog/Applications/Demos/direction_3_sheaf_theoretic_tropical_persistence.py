#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Sheaf-Theoretic Tropical Persistence

Demonstrates applications of the constructible sheaf framework to:
1. Network analysis (critical infrastructure detection)
2. Sensor coverage (threshold-dependent visibility)
3. Epidemic modeling (infection wavefront analysis)
4. Social network evolution (community formation tracking)
"""

from typing import List, Tuple, Dict, Set
import math
import random


# ===========================================================================
# Core Sheaf Computation (self-contained)
# ===========================================================================

class Graph:
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])


def sheaf_jump(G: Graph, times: List[float], c: float) -> int:
    return sum(G.degree(v) + 1 for v in range(G.n) if times[v] == c)


def sheaf_profile(G: Graph, times: List[float], t: float) -> int:
    crits = sorted(set(times))
    return sum(sheaf_jump(G, times, c) for c in crits if c <= t)


def tropical_rank(G: Graph, times: List[float], t: float) -> int:
    return sum(G.degree(v) + 1 for v in range(G.n) if times[v] <= t)


# ===========================================================================
# Application 1: Critical Infrastructure Network Analysis
# ===========================================================================

def app_infrastructure():
    """
    Application: Identifying critical failure thresholds in infrastructure networks.

    Model a power grid as a graph where vertices are substations and edges
    are transmission lines. The filtration represents vulnerability: stations
    with lower robustness scores "fail" first as stress increases.

    The sheaf jump profile reveals which failure events cause the largest
    cascading impact (highest degree + 1 contributions).
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Critical Infrastructure Analysis")
    print("=" * 60)

    # Model: 10-node power grid (simplified)
    n = 10
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 4),  # main backbone
        (0, 5), (5, 6), (6, 7),            # branch 1
        (2, 8), (8, 9),                     # branch 2
        (4, 7), (1, 8),                     # cross-connections
    ]
    G = Graph(n, edges)

    # Vulnerability scores (lower = fails first)
    vulnerability = [3.0, 1.0, 2.0, 5.0, 7.0, 4.0, 6.0, 8.0, 2.5, 9.0]
    names = ["Hub-A", "Hub-B", "Hub-C", "Hub-D", "Hub-E",
             "Sub-F", "Sub-G", "Sub-H", "Sub-I", "Sub-J"]

    print("\nSubstations (sorted by vulnerability):")
    print(f"  {'Name':>8} {'Vuln':>6} {'Degree':>8} {'Jump':>8}")
    print(f"  {'-'*34}")

    order = sorted(range(n), key=lambda v: vulnerability[v])
    for v in order:
        print(f"  {names[v]:>8} {vulnerability[v]:>6.1f} "
              f"{G.degree(v):>8} {G.degree(v)+1:>8}")

    print(f"\nCritical failure cascade analysis:")
    crits = sorted(set(vulnerability))
    cumulative = 0
    print(f"  {'Threshold':>12} {'Stations Failed':>16} {'Sheaf Jump':>12} "
          f"{'Cumulative':>12}")
    print(f"  {'-'*56}")
    for c in crits:
        j = sheaf_jump(G, vulnerability, c)
        cumulative += j
        failed = [names[v] for v in range(n) if vulnerability[v] == c]
        print(f"  {c:>12.1f} {','.join(failed):>16} {j:>12} {cumulative:>12}")

    # Identify most critical threshold
    max_jump_c = max(crits, key=lambda c: sheaf_jump(G, vulnerability, c))
    print(f"\n  ⚠ Most critical threshold: {max_jump_c:.1f}")
    print(f"    (sheaf jump = {sheaf_jump(G, vulnerability, max_jump_c)}, "
          f"indicating maximum cascade potential)")


# ===========================================================================
# Application 2: Sensor Coverage Analysis
# ===========================================================================

def app_sensor_coverage():
    """
    Application: Analyzing coverage quality as sensor activation thresholds vary.

    Sensors in a monitoring network activate at different signal strengths.
    The sheaf framework reveals how coverage quality (measured by degree-weighted
    activation) changes as the signal threshold is lowered.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Sensor Coverage Analysis")
    print("=" * 60)

    # Grid sensor network
    rows, cols = 3, 4
    n = rows * cols

    edges = []
    for r in range(rows):
        for c in range(cols):
            v = r * cols + c
            if c + 1 < cols:
                edges.append((v, v + 1))
            if r + 1 < rows:
                edges.append((v, v + cols))

    G = Graph(n, edges)

    # Activation thresholds (signal strength needed)
    random.seed(123)
    thresholds = [round(random.uniform(1, 10), 1) for _ in range(n)]

    print(f"\nSensor grid ({rows}×{cols}):")
    for r in range(rows):
        row = [f"{thresholds[r*cols+c]:>5.1f}" for c in range(cols)]
        print(f"  {' '.join(row)}")

    print(f"\nCoverage analysis (sheaf profile):")
    crits = sorted(set(thresholds))
    print(f"  {'Signal Level':>14} {'New Sensors':>13} {'Jump':>8} "
          f"{'Coverage':>10} {'% of Max':>10}")
    print(f"  {'-'*58}")
    max_rank = sum(G.degree(v) + 1 for v in range(n))
    for c in crits:
        j = sheaf_jump(G, thresholds, c)
        cov = sheaf_profile(G, thresholds, c)
        pct = 100.0 * cov / max_rank
        new = sum(1 for v in range(n) if thresholds[v] == c)
        print(f"  {c:>14.1f} {new:>13} {j:>8} {cov:>10} {pct:>9.1f}%")


# ===========================================================================
# Application 3: Epidemic Wavefront Analysis
# ===========================================================================

def app_epidemic():
    """
    Application: Analyzing infection wavefront in a contact network.

    The sheaf jump at each infection time reveals the connectivity
    impact of each newly infected individual. Higher jumps indicate
    super-spreader events.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Epidemic Wavefront Analysis")
    print("=" * 60)

    # Contact network (small-world-like)
    n = 12
    edges = [(i, (i+1) % n) for i in range(n)]  # ring
    edges += [(0, 6), (3, 9), (1, 7), (4, 10)]   # shortcuts

    G = Graph(n, edges)

    # Infection times (days)
    infection_times = [0.0, 1.0, 1.0, 2.0, 3.0, 5.0,
                       2.0, 3.0, 4.0, 4.0, 5.0, 7.0]

    print(f"\nContact network: {n} individuals, {len(edges)} contacts")
    print(f"Infection timeline:")
    crits = sorted(set(infection_times))
    for day in crits:
        infected = [v for v in range(n) if infection_times[v] == day]
        jump = sheaf_jump(G, infection_times, day)
        profile = sheaf_profile(G, infection_times, day)
        print(f"  Day {day:>4.0f}: infected={infected}, "
              f"jump={jump}, cumulative={profile}")

    # Identify super-spreader events
    max_day = max(crits, key=lambda c: sheaf_jump(G, infection_times, c))
    print(f"\n  ⚠ Peak transmission event: Day {max_day:.0f}")
    print(f"    Sheaf jump = {sheaf_jump(G, infection_times, max_day)}")

    # Stability: what if infection times shift by ±0.5 days?
    eps = 0.5
    random.seed(99)
    perturbed = [t + random.uniform(-eps, eps) for t in infection_times]
    print(f"\n  Stability under ±{eps} day uncertainty:")
    max_diff = 0
    for t_10 in range(-10, 80):
        t = t_10 / 10.0
        p1 = sheaf_profile(G, infection_times, t)
        p2 = sheaf_profile(G, perturbed, t)
        max_diff = max(max_diff, abs(p1 - p2))
    print(f"    Max profile difference: {max_diff}")
    print(f"    Sup distance: {max(abs(infection_times[v] - perturbed[v]) for v in range(n)):.3f}")


# ===========================================================================
# Application 4: Social Network Community Formation
# ===========================================================================

def app_social_network():
    """
    Application: Tracking community formation in a social network.

    Users join a platform at different times. The sheaf jump tracks
    the connectivity impact of each new user joining.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Social Network Community Formation")
    print("=" * 60)

    # Social network
    n = 8
    edges = [
        (0, 1), (0, 2),        # early adopters
        (1, 2), (2, 3),        # growth phase
        (3, 4), (4, 5),        # expansion
        (5, 6), (6, 7),        # late joiners
        (0, 3), (1, 4),        # cross-community links
    ]
    G = Graph(n, edges)
    join_times = [1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0, 5.0]
    names = ["Alice", "Bob", "Carol", "Dave", "Eve", "Frank", "Grace", "Heidi"]

    print(f"\nUser join timeline:")
    crits = sorted(set(join_times))
    for t in crits:
        users = [names[v] for v in range(n) if join_times[v] == t]
        jump = sheaf_jump(G, join_times, t)
        profile = sheaf_profile(G, join_times, t)
        print(f"  t={t:.0f}: {', '.join(users):>20} → "
              f"jump={jump}, network_weight={profile}")

    total = sum(G.degree(v) + 1 for v in range(n))
    print(f"\n  Total network weight (Euler char): {total}")
    print(f"  Sum of all jumps: {sum(sheaf_jump(G, join_times, c) for c in crits)}")
    print(f"  Match (Theorem): {'✓' if total == sum(sheaf_jump(G, join_times, c) for c in crits) else '✗'}")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  APPLICATIONS OF SHEAF-THEORETIC TROPICAL PERSISTENCE")
    print("=" * 60)

    app_infrastructure()
    app_sensor_coverage()
    app_epidemic()
    app_social_network()

    print(f"\n{'='*60}")
    print("  ALL APPLICATIONS COMPLETE")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
demo.py — Interactive Demonstration of Sheaf-Theoretic Tropical Persistence

Demonstrates the core theorems on path graphs and cycle graphs:
1. Critical thresholds and constructibility
2. Sheaf jumps and stalk values
3. Cumulative sheaf jump profile vs. tropical event profile
4. Stability under perturbation

This is a computational companion to the formally verified Lean theorems in
Catalog/Pythagorean/TropicalBridge/SheafPersistence.lean.
"""

from typing import List, Tuple, Dict
import math


# ===========================================================================
# Core Data Structures
# ===========================================================================

class SimpleGraph:
    """A simple undirected graph on vertices {0, 1, ..., n-1}."""
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, set] = {i: set() for i in range(n)}
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def vertices(self) -> range:
        return range(self.n)


class VertexFiltration:
    """Entrance-time function: each vertex gets a real threshold."""
    def __init__(self, times: List[float]):
        self.times = times

    def __call__(self, v: int) -> float:
        return self.times[v]

    def active_vertices(self, t: float) -> List[int]:
        return [v for v in range(len(self.times)) if self.times[v] <= t]

    def critical_values(self) -> List[float]:
        return sorted(set(self.times))


# ===========================================================================
# Graph Constructors
# ===========================================================================

def path_graph(n: int) -> SimpleGraph:
    """Path graph P_n on n vertices: 0-1-2-..-(n-1)."""
    edges = [(i, i+1) for i in range(n-1)]
    return SimpleGraph(n, edges)


def cycle_graph(n: int) -> SimpleGraph:
    """Cycle graph C_n on n vertices."""
    edges = [(i, (i+1) % n) for i in range(n)]
    return SimpleGraph(n, edges)


def path_filtration(n: int) -> VertexFiltration:
    """Natural filtration: vertex i enters at time i."""
    return VertexFiltration([float(i) for i in range(n)])


def cycle_filtration(n: int) -> VertexFiltration:
    """Natural filtration for cycle graph."""
    return VertexFiltration([float(i) for i in range(n)])


# ===========================================================================
# Tropical Persistence Computations
# ===========================================================================

def tropical_rank(G: SimpleGraph, f: VertexFiltration, t: float) -> int:
    """Tropical rank at threshold t: sum of (degree(v)+1) for active v."""
    return sum(G.degree(v) + 1 for v in f.active_vertices(t))


def tropical_event_profile(G: SimpleGraph, f: VertexFiltration, t: float) -> int:
    """Tropical event profile (= tropical rank as integer)."""
    return tropical_rank(G, f, t)


def sheaf_jump(G: SimpleGraph, f: VertexFiltration, c: float) -> int:
    """Sheaf jump at critical value c: sum of (degree(v)+1) for v entering at c."""
    return sum(G.degree(v) + 1 for v in range(G.n) if f(v) == c)


def sheaf_event_profile(G: SimpleGraph, f: VertexFiltration, t: float) -> int:
    """Cumulative sheaf jump profile up to threshold t."""
    return sum(sheaf_jump(G, f, c) for c in f.critical_values() if c <= t)


def degree0_jump(f: VertexFiltration, c: float) -> int:
    """Degree-0 jump: number of vertices entering at c."""
    return sum(1 for v in range(len(f.times)) if f(v) == c)


def degree1_jump(G: SimpleGraph, f: VertexFiltration, c: float) -> int:
    """Degree-1 jump: excess degree contribution."""
    return sheaf_jump(G, f, c) - degree0_jump(f, c)


# ===========================================================================
# DEMO 1: Path Graph — Constructibility and Stalk Values
# ===========================================================================

def demo_path_graph(n: int = 6):
    """Demonstrate the constructible sheaf on a path graph P_n."""
    print(f"\n{'='*70}")
    print(f"  DEMO 1: Path Graph P_{n} — Constructible Tropical Sheaf")
    print(f"{'='*70}\n")

    G = path_graph(n)
    f = path_filtration(n)

    print(f"Graph: P_{n} (path on {n} vertices)")
    print(f"Filtration: vertex i enters at time i")
    print(f"Critical values: {f.critical_values()}")
    print()

    # Show vertex degrees
    print("Vertex data:")
    print(f"  {'Vertex':>8} {'Degree':>8} {'Entry Time':>12} {'deg+1':>8}")
    print(f"  {'-'*40}")
    for v in G.vertices():
        print(f"  {v:>8} {G.degree(v):>8} {f(v):>12.1f} {G.degree(v)+1:>8}")

    # Show sheaf jumps at critical values
    print(f"\nSheaf jump analysis:")
    print(f"  {'Critical c':>12} {'Jump(c)':>10} {'deg0':>8} {'deg1':>8}")
    print(f"  {'-'*42}")
    total = 0
    for c in f.critical_values():
        j = sheaf_jump(G, f, c)
        d0 = degree0_jump(f, c)
        d1 = degree1_jump(G, f, c)
        total += j
        print(f"  {c:>12.1f} {j:>10} {d0:>8} {d1:>8}")
    print(f"  {'Total':>12} {total:>10}")

    # Verify Theorem 2: event profile = cumulative sheaf jumps
    print(f"\nTheorem 2 verification (Event Profile = Cumulative Sheaf Jumps):")
    print(f"  {'t':>8} {'EventProfile':>14} {'SheafProfile':>14} {'Match':>8}")
    print(f"  {'-'*48}")
    test_times = [c - 0.5 for c in f.critical_values()] + f.critical_values() + \
                 [f.critical_values()[-1] + 1.0]
    test_times = sorted(set(test_times))
    for t in test_times:
        ep = tropical_event_profile(G, f, t)
        sp = sheaf_event_profile(G, f, t)
        match = "✓" if ep == sp else "✗"
        print(f"  {t:>8.1f} {ep:>14} {sp:>14} {match:>8}")

    # Verify Theorem 1: constructibility (constant between criticals)
    print(f"\nTheorem 1 verification (Constructibility):")
    crits = f.critical_values()
    for i in range(len(crits) - 1):
        s = crits[i] + 0.1
        t = crits[i+1] - 0.1
        if s < t:
            rs = tropical_rank(G, f, s)
            rt = tropical_rank(G, f, t)
            match = "✓" if rs == rt else "✗"
            print(f"  Gap ({crits[i]:.1f}, {crits[i+1]:.1f}): "
                  f"rank({s:.1f}) = {rs}, rank({t:.1f}) = {rt} {match}")


# ===========================================================================
# DEMO 2: Cycle Graph — Sheaf Structure
# ===========================================================================

def demo_cycle_graph(n: int = 6):
    """Demonstrate the constructible sheaf on a cycle graph C_n."""
    print(f"\n{'='*70}")
    print(f"  DEMO 2: Cycle Graph C_{n} — Constructible Tropical Sheaf")
    print(f"{'='*70}\n")

    G = cycle_graph(n)
    f = cycle_filtration(n)

    print(f"Graph: C_{n} (cycle on {n} vertices)")
    print(f"Every vertex has degree 2, so sheaf jump at each critical = 3")
    print(f"Critical values: {f.critical_values()}")
    print()

    # Sheaf jumps
    print("Sheaf jump analysis:")
    for c in f.critical_values():
        j = sheaf_jump(G, f, c)
        print(f"  c = {c:.1f}: jump = {j} "
              f"(= degree {G.degree(int(c))} + 1)")

    # Compare with path graph of same size
    Gp = path_graph(n)
    fp = path_filtration(n)
    print(f"\nComparison with P_{n}:")
    print(f"  Euler char (C_{n}) = {sum(sheaf_jump(G, f, c) for c in f.critical_values())}")
    print(f"  Euler char (P_{n}) = {sum(sheaf_jump(Gp, fp, c) for c in fp.critical_values())}")

    # Verify Theorem 2
    print(f"\nTheorem 2 verification:")
    for t in [-1.0] + f.critical_values() + [float(n)]:
        ep = tropical_event_profile(G, f, t)
        sp = sheaf_event_profile(G, f, t)
        print(f"  t={t:>5.1f}: EventProfile={ep:>4}, SheafProfile={sp:>4}, Match={'✓' if ep==sp else '✗'}")


# ===========================================================================
# DEMO 3: Stability Under Perturbation
# ===========================================================================

def demo_stability(n: int = 5, epsilon: float = 0.3):
    """Demonstrate sheaf-theoretic stability (Theorem 3)."""
    print(f"\n{'='*70}")
    print(f"  DEMO 3: Stability — ε={epsilon} Perturbation on P_{n}")
    print(f"{'='*70}\n")

    G = path_graph(n)
    f = path_filtration(n)

    # Perturbed filtration
    import random
    random.seed(42)
    perturbed_times = [f(v) + random.uniform(-epsilon, epsilon) for v in range(n)]
    g = VertexFiltration(perturbed_times)

    print(f"Original filtration:  {[f(v) for v in range(n)]}")
    print(f"Perturbed filtration: {[round(g(v), 3) for v in range(n)]}")
    sup_dist = max(abs(f(v) - g(v)) for v in range(n))
    print(f"Sup distance: {sup_dist:.4f} ≤ ε = {epsilon}")

    # Verify interleaving (Theorem 3)
    print(f"\nTheorem 3 verification (ε-interleaving):")
    print(f"  For all t: SheafProfile_f(t) ≤ SheafProfile_g(t + ε)")
    print(f"  {'t':>8} {'SP_f(t)':>10} {'SP_g(t+ε)':>12} {'f≤g+ε':>8} "
          f"{'SP_g(t)':>10} {'SP_f(t+ε)':>12} {'g≤f+ε':>8}")
    print(f"  {'-'*72}")

    all_ok = True
    for t_int in range(-2, n + 3):
        t = float(t_int) * 0.5
        spf = sheaf_event_profile(G, f, t)
        spg_shift = sheaf_event_profile(G, g, t + epsilon)
        spg = sheaf_event_profile(G, g, t)
        spf_shift = sheaf_event_profile(G, f, t + epsilon)
        ok1 = spf <= spg_shift
        ok2 = spg <= spf_shift
        all_ok = all_ok and ok1 and ok2
        print(f"  {t:>8.1f} {spf:>10} {spg_shift:>12} "
              f"{'✓' if ok1 else '✗':>8} "
              f"{spg:>10} {spf_shift:>12} "
              f"{'✓' if ok2 else '✗':>8}")

    print(f"\n  All interleaving inequalities satisfied: {'✓' if all_ok else '✗'}")


# ===========================================================================
# DEMO 4: Theorem 4 — Cross-Domain Bridge
# ===========================================================================

def demo_cross_domain(n: int = 8):
    """Demonstrate sheafJump = degree + 1 for path graph (Theorem 4)."""
    print(f"\n{'='*70}")
    print(f"  DEMO 4: Cross-Domain Bridge — Path Graph P_{n}")
    print(f"{'='*70}\n")

    G = path_graph(n)
    f = path_filtration(n)

    print(f"Theorem 4: For path graphs, sheafJump at vertex k = degree(k) + 1")
    print()
    print(f"  {'Vertex k':>10} {'degree(k)':>12} {'deg(k)+1':>10} {'sheafJump':>12} {'Match':>8}")
    print(f"  {'-'*56}")

    all_match = True
    for k in range(n):
        deg = G.degree(k)
        expected = deg + 1
        actual = sheaf_jump(G, f, float(k))
        match = actual == expected
        all_match = all_match and match
        print(f"  {k:>10} {deg:>12} {expected:>10} {actual:>12} "
              f"{'✓' if match else '✗':>8}")

    print(f"\n  All match: {'✓' if all_match else '✗'}")
    print(f"\n  Euler characteristic = {sum(G.degree(v)+1 for v in range(n))}")
    print(f"  = sum of all sheaf jumps = {sum(sheaf_jump(G, f, c) for c in f.critical_values())}")


# ===========================================================================
# DEMO 5: Möbius Inversion Connection
# ===========================================================================

def demo_mobius(n: int = 5):
    """Demonstrate the Möbius inversion formula."""
    print(f"\n{'='*70}")
    print(f"  DEMO 5: Möbius Inversion — Cumulative Rank Formula")
    print(f"{'='*70}\n")

    G = path_graph(n)
    f = path_filtration(n)

    print("The cumulative rank at threshold t equals the Möbius sum")
    print("of sheaf jumps over critical values ≤ t.")
    print()
    print(f"  {'t':>8} {'rank(t)':>10} {'Σ jumps≤t':>12} {'Match':>8}")
    print(f"  {'-'*42}")

    for t_10 in range(-10, 10 * n + 10):
        t = t_10 / 10.0
        r = tropical_rank(G, f, t)
        s = sheaf_event_profile(G, f, t)
        if r > 0 or t == 0:
            print(f"  {t:>8.1f} {r:>10} {s:>12} {'✓' if r==s else '✗':>8}")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  SHEAF-THEORETIC TROPICAL PERSISTENCE — INTERACTIVE DEMO")
    print("  Companion to Lean 4 formal verification")
    print("=" * 70)

    demo_path_graph(6)
    demo_cycle_graph(6)
    demo_stability(5, 0.3)
    demo_cross_domain(8)
    demo_mobius(5)

    print(f"\n{'='*70}")
    print("  ALL DEMOS COMPLETE")
    print(f"{'='*70}")


#!/usr/bin/env python3
"""
Visualization 3: Sheaf Jump Decomposition

Visualizes the degree-0 / degree-1 decomposition of sheaf jumps (Theorem 4),
comparing path graphs and cycle graphs side by side.

Shows:
- Stacked bar chart of deg-0 (vertex count) and deg-1 (edge density) jumps
- How the decomposition varies with graph structure
- Total Euler characteristic comparison

This illustrates the cross-domain bridge between sheaf theory and graph topology.
"""

import matplotlib.pyplot as plt
import numpy as np


def make_path_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def make_cycle_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n):
        adj[i].add((i + 1) % n)
        adj[(i + 1) % n].add(i)
    return adj


def compute_jumps(adj, times):
    crits = sorted(set(times))
    results = []
    for c in crits:
        verts_at_c = [v for v in adj if times[v] == c]
        d0 = len(verts_at_c)
        total = sum(len(adj[v]) + 1 for v in verts_at_c)
        d1 = total - d0
        results.append((c, d0, d1, total))
    return results


n = 8
times = list(range(n))

path_jumps = compute_jumps(make_path_graph(n), times)
cycle_jumps = compute_jumps(make_cycle_graph(n), times)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax, jumps, title, colors in [
    (axes[0], path_jumps, f'Path Graph P₈', ['#42A5F5', '#1565C0']),
    (axes[1], cycle_jumps, f'Cycle Graph C₈', ['#EF5350', '#B71C1C']),
]:
    crits = [j[0] for j in jumps]
    d0 = [j[1] for j in jumps]
    d1 = [j[2] for j in jumps]
    totals = [j[3] for j in jumps]

    x = np.arange(len(crits))
    width = 0.6

    bars1 = ax.bar(x, d0, width, label='Degree-0 (vertex count)', color=colors[0], alpha=0.8)
    bars2 = ax.bar(x, d1, width, bottom=d0, label='Degree-1 (edge density)', color=colors[1], alpha=0.8)

    # Annotate totals
    for i, total in enumerate(totals):
        ax.text(i, total + 0.1, str(total), ha='center', va='bottom',
                fontweight='bold', fontsize=11)

    ax.set_xticks(x)
    ax.set_xticklabels([f'{int(c)}' for c in crits])
    ax.set_xlabel('Critical Value (vertex entrance time)', fontsize=11)
    ax.set_ylabel('Sheaf Jump', fontsize=11)
    ax.set_title(f'{title}\nJump Decomposition', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(axis='y', alpha=0.3)

    euler = sum(totals)
    ax.text(0.95, 0.95, f'Euler χ = {euler}', transform=ax.transAxes,
            fontsize=12, va='top', ha='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Add comparison annotation
fig.text(0.5, 0.01,
         'Theorem 4: sheafJump(c) = degree(v) + 1 for vertex v entering at c\n'
         'Path endpoints have jump 2, interior vertices have jump 3; '
         'cycle vertices all have jump 3',
         ha='center', fontsize=10, style='italic', color='#555')

plt.tight_layout(rect=[0, 0.06, 1, 1])
plt.savefig('viz_jump_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_jump_decomposition.png")


#!/usr/bin/env python3
"""
Visualization 1: Constructible Sheaf Profile

Visualizes the tropical rank sheaf as a step function on the threshold line,
showing:
- The stalk rank at each threshold (step function)
- Critical values as vertical dashed lines
- Sheaf jumps as colored annotations
- Comparison between path graph and cycle graph

This illustrates Theorem 1 (constructibility) and Theorem 2 (event profile recovery).
"""

import matplotlib.pyplot as plt
import numpy as np


def make_path_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def make_cycle_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n):
        adj[i].add((i + 1) % n)
        adj[(i + 1) % n].add(i)
    return adj


def tropical_rank(adj, times, t):
    return sum(len(adj[v]) + 1 for v in adj if times[v] <= t)


def sheaf_jump(adj, times, c):
    return sum(len(adj[v]) + 1 for v in adj if times[v] == c)


# Parameters
n = 7
times = list(range(n))
crits = sorted(set(times))

adj_path = make_path_graph(n)
adj_cycle = make_cycle_graph(n)

# Compute profiles
t_fine = np.linspace(-1, n + 0.5, 1000)
rank_path = [tropical_rank(adj_path, times, t) for t in t_fine]
rank_cycle = [tropical_rank(adj_cycle, times, t) for t in t_fine]

# Plot
fig, axes = plt.subplots(2, 1, figsize=(12, 8), sharex=True)

for ax, adj, ranks, name, color in [
    (axes[0], adj_path, rank_path, f'Path Graph P₇', '#2196F3'),
    (axes[1], adj_cycle, rank_cycle, f'Cycle Graph C₇', '#E91E63'),
]:
    ax.step(t_fine, ranks, where='post', color=color, linewidth=2.5, label='Tropical Rank (Stalk)')

    # Mark critical values
    for c in crits:
        j = sheaf_jump(adj, times, c)
        ax.axvline(x=c, color='gray', linestyle='--', alpha=0.4, linewidth=1)
        rank_at_c = tropical_rank(adj, times, c)
        ax.annotate(f'Δ={j}', xy=(c, rank_at_c), xytext=(c + 0.15, rank_at_c + 0.8),
                    fontsize=9, color='darkred', fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='darkred', lw=1.2))

    # Shade gaps between critical values
    for i in range(len(crits) - 1):
        ax.axvspan(crits[i] + 0.01, crits[i + 1] - 0.01, alpha=0.06, color=color)

    ax.set_ylabel('Tropical Rank', fontsize=12)
    ax.set_title(f'{name} — Constructible Tropical Rank Sheaf', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, n + 0.5)

    # Annotate constructibility
    if adj == adj_path:
        ax.text(0.5, 0.95, 'Rank constant between critical values (Theorem 1)',
                transform=ax.transAxes, fontsize=10, va='top', ha='left',
                style='italic', color='#555')

axes[1].set_xlabel('Threshold t', fontsize=12)

plt.tight_layout()
plt.savefig('viz_sheaf_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_sheaf_profile.png")


#!/usr/bin/env python3
"""
Visualization 2: Sheaf-Theoretic Stability

Visualizes the ε-interleaving of sheaf profiles under perturbation (Theorem 3).
Shows:
- Original sheaf profile
- Perturbed sheaf profile
- ε-shifted envelopes demonstrating the interleaving inequality
- The gap between profiles bounded by the stability theorem

This illustrates that stability emerges from sheaf functoriality:
the pullback of the sheaf along the ε-shift map produces the interleaving.
"""

import matplotlib.pyplot as plt
import numpy as np
import random


def make_path_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def tropical_rank(adj, times, t):
    return sum(len(adj[v]) + 1 for v in adj if times[v] <= t)


# Parameters
n = 8
adj = make_path_graph(n)
times_orig = [float(i) for i in range(n)]

epsilon = 0.8
random.seed(42)
times_pert = [t + random.uniform(-epsilon, epsilon) for t in times_orig]

# Fine grid
t_fine = np.linspace(-2, n + 2, 2000)
profile_orig = [tropical_rank(adj, times_orig, t) for t in t_fine]
profile_pert = [tropical_rank(adj, times_pert, t) for t in t_fine]

# Shifted profiles for interleaving
profile_orig_shifted = [tropical_rank(adj, times_orig, t + epsilon) for t in t_fine]
profile_pert_shifted = [tropical_rank(adj, times_pert, t + epsilon) for t in t_fine]

fig, ax = plt.subplots(figsize=(14, 7))

# Plot ε-shifted envelopes
ax.fill_between(t_fine, profile_orig,
                [tropical_rank(adj, times_orig, t + epsilon) for t in t_fine],
                alpha=0.1, color='#2196F3', label='ε-envelope (original)')

# Main profiles
ax.step(t_fine, profile_orig, where='post', color='#2196F3', linewidth=2.5,
        label=f'Original Profile f', linestyle='-')
ax.step(t_fine, profile_pert, where='post', color='#E91E63', linewidth=2.5,
        label=f'Perturbed Profile g (ε={epsilon})', linestyle='-')

# ε-shifted original
ax.step(t_fine, profile_orig_shifted, where='post', color='#2196F3',
        linewidth=1.5, linestyle=':', alpha=0.6, label=f'f(t+ε)')
ax.step(t_fine, profile_pert_shifted, where='post', color='#E91E63',
        linewidth=1.5, linestyle=':', alpha=0.6, label=f'g(t+ε)')

# Mark sup distance
sup_dist = max(abs(times_orig[v] - times_pert[v]) for v in range(n))
ax.axhline(y=0, color='black', linewidth=0.5)

# Annotations
ax.set_xlabel('Threshold t', fontsize=13)
ax.set_ylabel('Sheaf Event Profile', fontsize=13)
ax.set_title(f'Sheaf-Theoretic Stability: ε-Interleaving of Tropical Profiles\n'
             f'Path Graph P₈, ε = {epsilon}, sup-dist = {sup_dist:.3f}',
             fontsize=14, fontweight='bold')

ax.legend(fontsize=10, loc='upper left', framealpha=0.9)
ax.grid(True, alpha=0.3)

# Add theorem statement
textstr = (f'Theorem 3: f(t) ≤ g(t+ε) and g(t) ≤ f(t+ε) for all t\n'
           f'Stability from sheaf functoriality, not ad hoc estimates')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
ax.text(0.98, 0.15, textstr, transform=ax.transAxes, fontsize=10,
        verticalalignment='bottom', horizontalalignment='right', bbox=props)

ax.set_xlim(-2, n + 2)
plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
