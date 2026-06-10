"""
Demo: List Coloring of Chordal Graphs for Heterogeneous Register Allocation

This script demonstrates the key algorithms and results from the research:
1. Construction of chordal (interval) graphs from SSA liveness intervals
2. PEO computation via maximum cardinality search
3. Greedy list coloring with heterogeneous register constraints
4. Register pressure profile computation
"""

import random
from typing import List, Tuple, Dict, Set, Optional


def generate_interval_graph(n: int, max_endpoint: int = 50) -> Tuple[List[Tuple[int, int]], List[List[int]]]:
    """Generate a random interval graph (always chordal) with n vertices."""
    intervals = []
    for _ in range(n):
        left = random.randint(0, max_endpoint - 1)
        right = random.randint(left, min(left + max_endpoint // 3, max_endpoint))
        intervals.append((left, right))

    # Build adjacency lists
    adj: List[List[int]] = [[] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            li, ri = intervals[i]
            lj, rj = intervals[j]
            if li <= rj and lj <= ri:  # intervals overlap
                adj[i].append(j)
                adj[j].append(i)

    return intervals, adj


def compute_peo(n: int, adj: List[List[int]]) -> List[int]:
    """Compute a PEO via Maximum Cardinality Search (MCS).

    Returns a list where peo[i] is the vertex at position i.
    Vertices are ordered so that peo[-1] is processed first (reverse for greedy).
    """
    weight = [0] * n
    visited = [False] * n
    peo = []

    for _ in range(n):
        # Pick unvisited vertex with maximum weight
        best = -1
        best_w = -1
        for v in range(n):
            if not visited[v] and weight[v] > best_w:
                best = v
                best_w = weight[v]
        peo.append(best)
        visited[best] = True
        for u in adj[best]:
            if not visited[u]:
                weight[u] += 1

    peo.reverse()  # Reverse so peo[0] has fewest later neighbors
    return peo


def compute_later_neighbors(v_idx: int, peo: List[int], adj: List[List[int]]) -> List[int]:
    """Compute later neighbors of peo[v_idx] in the PEO ordering."""
    v = peo[v_idx]
    later = []
    peo_pos = {peo[i]: i for i in range(len(peo))}
    for u in adj[v]:
        if peo_pos[u] > v_idx:
            later.append(u)
    return later


def compute_clique_number(n: int, peo: List[int], adj: List[List[int]]) -> int:
    """Compute ω(G) = max register pressure = max local clique size."""
    max_pressure = 0
    for i in range(n):
        later = compute_later_neighbors(i, peo, adj)
        pressure = len(later) + 1
        max_pressure = max(max_pressure, pressure)
    return max_pressure


def greedy_list_coloring(
    n: int,
    peo: List[int],
    adj: List[List[int]],
    lists: Dict[int, Set[int]]
) -> Optional[Dict[int, int]]:
    """Greedy list coloring along reverse PEO.

    Args:
        n: number of vertices
        peo: perfect elimination ordering
        adj: adjacency lists
        lists: for each vertex v, the set of available colors

    Returns:
        A valid coloring dict, or None if no coloring exists.
    """
    coloring: Dict[int, int] = {}
    peo_pos = {peo[i]: i for i in range(n)}

    # Process in reverse PEO order (from last to first)
    for idx in range(n - 1, -1, -1):
        v = peo[idx]
        # Colors used by already-colored neighbors
        used = set()
        for u in adj[v]:
            if u in coloring:
                used.add(coloring[u])

        # Find an available color
        available = lists[v] - used
        if not available:
            return None
        coloring[v] = min(available)  # deterministic choice

    return coloring


def demo_basic_list_coloring():
    """Demonstrate list coloring on a random interval graph."""
    print("=" * 60)
    print("DEMO 1: Greedy List Coloring on Interval Graph")
    print("=" * 60)

    n = 12
    random.seed(42)
    intervals, adj = generate_interval_graph(n, max_endpoint=20)

    print(f"\nGenerated interval graph with {n} vertices:")
    for i, (l, r) in enumerate(intervals):
        print(f"  Variable {i}: live range [{l}, {r}]")

    peo = compute_peo(n, adj)
    omega = compute_clique_number(n, peo, adj)
    print(f"\nPEO: {peo}")
    print(f"Clique number ω(G) = {omega}")

    # Uniform coloring (standard register allocation)
    uniform_lists = {v: set(range(omega)) for v in range(n)}
    coloring = greedy_list_coloring(n, peo, adj, uniform_lists)
    print(f"\nUniform coloring with {omega} colors: {coloring}")
    assert coloring is not None, "Uniform coloring should always succeed"

    # Heterogeneous coloring (list coloring)
    print(f"\n--- Heterogeneous Register Allocation ---")
    # Simulate: variables 0-5 are integers (registers 0-7)
    # Variables 6-11 are floats (registers 8-15)
    het_lists: Dict[int, Set[int]] = {}
    for v in range(n):
        if v < 6:
            het_lists[v] = set(range(0, max(omega, 8)))  # integer regs
        else:
            het_lists[v] = set(range(8, 8 + max(omega, 8)))  # float regs

    het_coloring = greedy_list_coloring(n, peo, adj, het_lists)
    if het_coloring:
        print(f"Heterogeneous coloring succeeded: {het_coloring}")
        # Verify
        for v in range(n):
            assert het_coloring[v] in het_lists[v], f"v={v} got invalid register"
            for u in adj[v]:
                assert het_coloring[v] != het_coloring[u], f"Conflict: {v}-{u}"
        print("✓ All constraints satisfied!")
    else:
        print("Heterogeneous coloring failed (lists too small for ω)")


def demo_pressure_profile():
    """Demonstrate register pressure profile computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Register Pressure Profile")
    print("=" * 60)

    n = 20
    random.seed(123)
    intervals, adj = generate_interval_graph(n, max_endpoint=30)
    peo = compute_peo(n, adj)

    print(f"\nPressure profile for {n}-vertex interval graph:")
    pressures = []
    for i in range(n):
        later = compute_later_neighbors(i, peo, adj)
        p = len(later) + 1
        pressures.append(p)
        bar = "█" * p
        print(f"  Position {i:2d} (v={peo[i]:2d}): pressure={p:2d}  {bar}")

    omega = max(pressures)
    print(f"\nMax pressure (= ω(G)) = {omega}")
    print(f"This means {omega} registers suffice for optimal allocation.")


def demo_spill_analysis():
    """Demonstrate spill cost analysis."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spill Cost Analysis")
    print("=" * 60)

    n = 15
    random.seed(99)
    intervals, adj = generate_interval_graph(n, max_endpoint=25)
    peo = compute_peo(n, adj)
    omega = compute_clique_number(n, peo, adj)

    print(f"\nGraph: {n} vertices, ω(G) = {omega}")

    for k in range(max(1, omega - 3), omega + 2):
        lists = {v: set(range(k)) for v in range(n)}
        coloring = greedy_list_coloring(n, peo, adj, lists)
        if coloring:
            colors_used = len(set(coloring.values()))
            print(f"  k={k:2d} registers: ✓ coloring found ({colors_used} colors used)")
        else:
            # Count minimum spills needed
            min_spills = omega - k
            print(f"  k={k:2d} registers: ✗ need to spill ≥ {max(0, min_spills)} variables")


def demo_list_coloring_stress_test():
    """Stress test: verify list coloring always succeeds for random chordal graphs."""
    print("\n" + "=" * 60)
    print("DEMO 4: Stress Test — List Coloring Success Rate")
    print("=" * 60)

    successes = 0
    trials = 500
    for trial in range(trials):
        n = random.randint(10, 50)
        intervals, adj = generate_interval_graph(n, max_endpoint=40)
        peo = compute_peo(n, adj)
        omega = compute_clique_number(n, peo, adj)

        if omega == 0:
            successes += 1
            continue

        # Random list assignment: each vertex gets omega random colors from palette of 2*omega
        palette_size = 2 * omega
        lists = {}
        for v in range(n):
            available = random.sample(range(palette_size), omega)
            lists[v] = set(available)

        coloring = greedy_list_coloring(n, peo, adj, lists)
        if coloring:
            successes += 1

    print(f"\nTrials: {trials}")
    print(f"Successes: {successes}")
    print(f"Success rate: {successes/trials:.1%}")
    print(f"\nTheorem guarantees: 100% success when |L(v)| ≥ ω(G)")
    print(f"Observed: {successes/trials:.1%} (should be 100%)")


if __name__ == "__main__":
    demo_basic_list_coloring()
    demo_pressure_profile()
    demo_spill_analysis()
    demo_list_coloring_stress_test()


"""
Visualization: List Coloring vs Uniform Coloring Success Rates

Shows that for chordal graphs, list coloring with |L(v)| >= omega
always succeeds, matching uniform coloring (demonstrating chi_l = chi = omega).
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_interval_graph(n, max_endpoint=40, seed=None):
    if seed is not None:
        random.seed(seed)
    intervals = []
    for _ in range(n):
        left = random.randint(0, max_endpoint - 1)
        right = random.randint(left, min(left + max_endpoint // 3, max_endpoint))
        intervals.append((left, right))
    adj = [[] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if intervals[i][0] <= intervals[j][1] and intervals[j][0] <= intervals[i][1]:
                adj[i].append(j)
                adj[j].append(i)
    return intervals, adj


def compute_peo(n, adj):
    weight = [0] * n
    visited = [False] * n
    order = []
    for _ in range(n):
        best = max((v for v in range(n) if not visited[v]), key=lambda v: weight[v])
        order.append(best)
        visited[best] = True
        for u in adj[best]:
            if not visited[u]:
                weight[u] += 1
    order.reverse()
    return order


def greedy_list_color(n, peo, adj, lists):
    coloring = {}
    for idx in range(n - 1, -1, -1):
        v = peo[idx]
        used = {coloring[u] for u in adj[v] if u in coloring}
        available = lists[v] - used
        if not available:
            return None
        coloring[v] = min(available)
    return coloring


def main():
    n_values = [10, 20, 30, 40, 50]
    trials_per_n = 200
    list_sizes_offsets = [-2, -1, 0, 1, 2]  # offset from omega

    results = {offset: [] for offset in list_sizes_offsets}

    for n in n_values:
        for offset in list_sizes_offsets:
            successes = 0
            valid_trials = 0
            for trial in range(trials_per_n):
                _, adj = generate_interval_graph(n, seed=trial * 1000 + n)
                peo = compute_peo(n, adj)
                peo_inv = {peo[i]: i for i in range(n)}
                omega = max(
                    len([u for u in adj[peo[i]] if peo_inv[u] > i]) + 1
                    for i in range(n)
                )

                list_size = omega + offset
                if list_size < 1:
                    continue
                valid_trials += 1

                palette = 3 * omega if omega > 0 else 10
                lists = {}
                for v in range(n):
                    if list_size >= palette:
                        lists[v] = set(range(palette))
                    else:
                        lists[v] = set(random.sample(range(palette), list_size))

                coloring = greedy_list_color(n, peo, adj, lists)
                if coloring is not None:
                    successes += 1

            rate = successes / max(valid_trials, 1)
            results[offset].append(rate)

    fig, ax = plt.subplots(figsize=(10, 6))

    colors_map = {-2: '#e74c3c', -1: '#f39c12', 0: '#27ae60', 1: '#3498db', 2: '#9b59b6'}
    markers = {-2: 'v', -1: 's', 0: 'o', 1: '^', 2: 'D'}

    for offset in list_sizes_offsets:
        label = f'|L(v)| = ω {"+" if offset >= 0 else ""}{offset}' if offset != 0 else '|L(v)| = ω (theorem guarantees 100%)'
        ax.plot(n_values, results[offset], marker=markers[offset], color=colors_map[offset],
                linewidth=2, markersize=8, label=label)

    ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('Number of Vertices (n)', fontsize=13)
    ax.set_ylabel('List Coloring Success Rate', fontsize=13)
    ax.set_title('List Coloring Success: Chordal Graphs (Random Lists from 3ω Palette)', fontsize=14)
    ax.legend(fontsize=10, loc='lower left')
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('list_coloring_success.png', dpi=150, bbox_inches='tight')
    print("Saved list_coloring_success.png")


if __name__ == "__main__":
    main()


"""
Visualization: Register Pressure Profile for Interval Graphs

Generates a plot showing the register pressure at each PEO position,
with the clique number (= chromatic number) highlighted.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def generate_interval_graph(n, max_endpoint=30):
    intervals = []
    random.seed(42)
    for _ in range(n):
        left = random.randint(0, max_endpoint - 1)
        right = random.randint(left, min(left + max_endpoint // 4, max_endpoint))
        intervals.append((left, right))
    adj = [[] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if intervals[i][0] <= intervals[j][1] and intervals[j][0] <= intervals[i][1]:
                adj[i].append(j)
                adj[j].append(i)
    return intervals, adj


def compute_peo(n, adj):
    weight = [0] * n
    visited = [False] * n
    order = []
    for _ in range(n):
        best = max((v for v in range(n) if not visited[v]), key=lambda v: weight[v])
        order.append(best)
        visited[best] = True
        for u in adj[best]:
            if not visited[u]:
                weight[u] += 1
    order.reverse()
    return order


def main():
    n = 25
    intervals, adj = generate_interval_graph(n)
    peo = compute_peo(n, adj)
    peo_inv = {peo[i]: i for i in range(n)}

    pressures = []
    for i in range(n):
        v = peo[i]
        later = [u for u in adj[v] if peo_inv[u] > i]
        pressures.append(len(later) + 1)

    omega = max(pressures)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), height_ratios=[2, 1])

    # Top: Pressure profile
    colors = ['#e74c3c' if p == omega else '#3498db' for p in pressures]
    ax1.bar(range(n), pressures, color=colors, edgecolor='white', linewidth=0.5)
    ax1.axhline(y=omega, color='#e74c3c', linestyle='--', linewidth=2, label=f'ω(G) = χ(G) = χₗ(G) = {omega}')
    ax1.set_xlabel('PEO Position', fontsize=12)
    ax1.set_ylabel('Register Pressure', fontsize=12)
    ax1.set_title('Register Pressure Profile (= Local Clique Size at Each PEO Position)', fontsize=14)
    ax1.legend(fontsize=12, loc='upper right')
    ax1.set_ylim(0, omega + 2)

    # Bottom: Liveness intervals
    sorted_by_left = sorted(range(n), key=lambda v: intervals[v][0])
    for idx, v in enumerate(sorted_by_left):
        l, r = intervals[v]
        color = '#2ecc71' if pressures[peo_inv[v]] < omega else '#e74c3c'
        ax2.barh(idx, r - l, left=l, height=0.7, color=color, alpha=0.7, edgecolor='gray')
        ax2.text(l + (r - l) / 2, idx, f'v{v}', ha='center', va='center', fontsize=7)

    ax2.set_xlabel('Program Point', fontsize=12)
    ax2.set_ylabel('Variable', fontsize=12)
    ax2.set_title('Liveness Intervals (Red = At Maximum Pressure Point)', fontsize=14)
    ax2.set_yticks([])

    plt.tight_layout()
    plt.savefig('pressure_profile.png', dpi=150, bbox_inches='tight')
    print("Saved pressure_profile.png")


if __name__ == "__main__":
    main()
