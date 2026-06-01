#!/usr/bin/env python3
"""
demo.py — Register Allocation as Graph Coloring: Numerical Examples

Demonstrates the key theorems:
1. Interval graphs are chordal (PEO construction)
2. Greedy coloring on PEO is optimal (χ = ω)
3. Register pressure profile
4. Spill cost bounds
"""

from typing import List, Tuple, Dict, Set
import random

# ─── Interval Graph Construction ───

def build_interval_graph(intervals: List[Tuple[int, int]]) -> List[List[bool]]:
    """Build adjacency matrix for an interval graph."""
    n = len(intervals)
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            a1, b1 = intervals[i]
            a2, b2 = intervals[j]
            if a1 <= b2 and a2 <= b1:  # intervals overlap
                adj[i][j] = True
                adj[j][i] = True
    return adj

# ─── Perfect Elimination Ordering ───

def peo_by_right_endpoint(intervals: List[Tuple[int, int]]) -> List[int]:
    """Construct PEO by sorting vertices by right endpoint."""
    indexed = list(enumerate(intervals))
    indexed.sort(key=lambda x: x[1][1])  # sort by right endpoint
    return [idx for idx, _ in indexed]

def verify_peo(adj: List[List[bool]], order: List[int]) -> bool:
    """Verify that an ordering is a valid PEO."""
    n = len(order)
    pos = [0] * n
    for i, v in enumerate(order):
        pos[v] = i

    for idx in range(n):
        v = order[idx]
        # Get later neighbors
        later_nbrs = [order[j] for j in range(idx + 1, n) if adj[v][order[j]]]
        # Check pairwise adjacency (simplicial property)
        for i, u in enumerate(later_nbrs):
            for w in later_nbrs[i + 1:]:
                if not adj[u][w]:
                    return False
    return True

# ─── Greedy Coloring ───

def greedy_color_peo(adj: List[List[bool]], order: List[int]) -> List[int]:
    """Greedy coloring using reverse PEO order (process last vertex first).
    
    For chordal graphs, this guarantees χ colors = ω(G).
    """
    n = len(order)
    color = [-1] * n

    # Process in REVERSE PEO order
    for idx in range(n - 1, -1, -1):
        v = order[idx]
        used_colors: Set[int] = set()
        for j in range(n):
            if adj[v][j] and color[j] >= 0:
                used_colors.add(color[j])
        c = 0
        while c in used_colors:
            c += 1
        color[v] = c
    return color

def clique_number(adj: List[List[bool]]) -> int:
    """Compute clique number (exact, exponential)."""
    n = len(adj)
    max_clique = 1

    def backtrack(clique: List[int], candidates: List[int]):
        nonlocal max_clique
        if not candidates:
            max_clique = max(max_clique, len(clique))
            return
        for i, v in enumerate(candidates):
            new_candidates = [u for u in candidates[i + 1:]
                            if adj[v][u]]
            backtrack(clique + [v], new_candidates)

    all_vertices = list(range(n))
    backtrack([], all_vertices)
    return max_clique

# ─── Register Pressure Profile ───

def register_pressure_profile(adj: List[List[bool]], order: List[int]) -> List[int]:
    """Compute register pressure at each PEO position."""
    n = len(order)
    pressure = []
    for idx in range(n):
        v = order[idx]
        later_nbrs = sum(1 for j in range(idx + 1, n) if adj[v][order[j]])
        pressure.append(later_nbrs + 1)
    return pressure

# ─── Spill Cost Analysis ───

def compute_spill_bound(adj: List[List[bool]], k: int) -> int:
    """Compute minimum spills needed: max(0, ω(G) - k)."""
    omega = clique_number(adj)
    return max(0, omega - k)

# ─── Demo ───

def demo_ssa_program():
    """Simulate a simple SSA program and show register allocation."""
    print("=" * 70)
    print("DEMO: Register Allocation for an SSA Program")
    print("=" * 70)

    # Simulate liveness intervals for 8 variables in an SSA program
    # Variable: [start, end] of liveness
    intervals = [
        (0, 3),   # v0: live from instruction 0 to 3
        (1, 5),   # v1: live from instruction 1 to 5
        (2, 4),   # v2: live from instruction 2 to 4
        (3, 7),   # v3: live from instruction 3 to 7
        (5, 8),   # v4: live from instruction 5 to 8
        (6, 9),   # v5: live from instruction 6 to 9
        (4, 6),   # v6: live from instruction 4 to 6
        (7, 10),  # v7: live from instruction 7 to 10
    ]

    print(f"\nProgram variables and liveness intervals:")
    for i, (a, b) in enumerate(intervals):
        bar = "." * a + "█" * (b - a + 1) + "." * (10 - b)
        print(f"  v{i}: [{a:2d}, {b:2d}]  {bar}")

    # Build interference graph
    adj = build_interval_graph(intervals)
    n = len(intervals)

    print(f"\nInterference graph ({n} vertices):")
    for i in range(n):
        neighbors = [j for j in range(n) if adj[i][j]]
        print(f"  v{i} adjacent to: {['v' + str(j) for j in neighbors]}")

    # Construct PEO
    peo = peo_by_right_endpoint(intervals)
    print(f"\nPerfect Elimination Ordering (by right endpoint):")
    print(f"  σ = {['v' + str(v) for v in peo]}")

    is_valid = verify_peo(adj, peo)
    print(f"  Valid PEO: {is_valid}")

    # Register pressure profile
    pressure = register_pressure_profile(adj, peo)
    print(f"\nRegister Pressure Profile:")
    for idx, p in enumerate(pressure):
        bar = "█" * p
        print(f"  Position {idx} (v{peo[idx]}): pressure = {p}  {bar}")

    max_pressure = max(pressure)
    omega = clique_number(adj)
    print(f"\n  Maximum pressure = {max_pressure}")
    print(f"  Clique number ω(G) = {omega}")
    print(f"  Theorem: max pressure = ω(G)? {max_pressure == omega} ✓" if max_pressure == omega
          else f"  max pressure ≠ ω(G) — unexpected!")

    # Greedy coloring
    colors = greedy_color_peo(adj, peo)
    num_colors = max(colors) + 1
    print(f"\nGreedy Coloring (on PEO):")
    for i in range(n):
        print(f"  v{i} → register R{colors[i]}")
    print(f"  Colors used: {num_colors}")
    print(f"  Theorem: χ(G) = ω(G) = {omega}? {num_colors == omega} ✓" if num_colors == omega
          else f"  χ ≠ ω — unexpected!")

    # Verify coloring
    valid = all(colors[i] != colors[j] for i in range(n) for j in range(i + 1, n) if adj[i][j])
    print(f"  Valid coloring: {valid}")

    # Spill analysis
    print(f"\nSpill Analysis:")
    for k in range(1, omega + 2):
        spills = compute_spill_bound(adj, k)
        status = "✓ no spills" if spills == 0 else f"⚠ need ≥ {spills} spills"
        print(f"  k = {k} registers: {status}")

def demo_random_verification():
    """Verify χ = ω on 100 random interval graphs."""
    print("\n" + "=" * 70)
    print("VERIFICATION: χ(G) = ω(G) for 100 Random Interval Graphs")
    print("=" * 70)

    successes = 0
    total = 100

    for trial in range(total):
        n = random.randint(5, 20)
        # Generate random intervals
        intervals = []
        for _ in range(n):
            a = random.randint(0, 50)
            b = a + random.randint(0, 15)
            intervals.append((a, b))

        adj = build_interval_graph(intervals)
        peo = peo_by_right_endpoint(intervals)

        assert verify_peo(adj, peo), f"PEO verification failed on trial {trial}"

        colors = greedy_color_peo(adj, peo)
        chi = max(colors) + 1 if colors else 0
        omega = clique_number(adj)

        if chi == omega:
            successes += 1
        else:
            print(f"  FAIL on trial {trial}: χ={chi}, ω={omega}")

    print(f"\n  Results: {successes}/{total} passed (χ = ω)")
    print(f"  Conjecture {'CONFIRMED' if successes == total else 'REFUTED'} on sample")

def demo_max_degree_bound():
    """Demonstrate Δ+1 coloring bound vs optimal."""
    print("\n" + "=" * 70)
    print("COMPARISON: Δ+1 Bound vs Optimal (χ = ω)")
    print("=" * 70)

    for trial in range(5):
        n = random.randint(8, 15)
        intervals = [(random.randint(0, 30), random.randint(0, 30)) for _ in range(n)]
        intervals = [(min(a, b), max(a, b)) for a, b in intervals]

        adj = build_interval_graph(intervals)
        degrees = [sum(adj[i]) for i in range(n)]
        delta = max(degrees) if degrees else 0
        omega = clique_number(adj)

        print(f"\n  Graph {trial + 1}: n={n}, Δ={delta}, ω={omega}")
        print(f"    Brooks bound: χ ≤ Δ+1 = {delta + 1}")
        print(f"    Optimal:      χ = ω   = {omega}")
        print(f"    Savings:      {delta + 1 - omega} registers saved by using chordal structure")

if __name__ == "__main__":
    random.seed(42)
    demo_ssa_program()
    demo_random_verification()
    demo_max_degree_bound()
    print("\n✓ All demos completed successfully.")


#!/usr/bin/env python3
"""
visualize_pressure.py — Register Pressure Profile Visualization

Visualizes the register pressure profile for an SSA program's
interference graph, showing how register demand varies across
the perfect elimination ordering.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Tuple, Set


def build_interval_graph(intervals: List[Tuple[int, int]]) -> List[List[bool]]:
    n = len(intervals)
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            a1, b1 = intervals[i]
            a2, b2 = intervals[j]
            if a1 <= b2 and a2 <= b1:
                adj[i][j] = True
                adj[j][i] = True
    return adj


def peo_by_right_endpoint(intervals: List[Tuple[int, int]]) -> List[int]:
    indexed = sorted(enumerate(intervals), key=lambda x: x[1][1])
    return [idx for idx, _ in indexed]


def register_pressure(adj: List[List[bool]], order: List[int]) -> List[int]:
    n = len(order)
    pressure = []
    for idx in range(n):
        v = order[idx]
        later = sum(1 for j in range(idx + 1, n) if adj[v][order[j]])
        pressure.append(later + 1)
    return pressure


def greedy_color(adj: List[List[bool]], order: List[int]) -> List[int]:
    n = len(order)
    color = [-1] * n
    for idx in range(n - 1, -1, -1):
        v = order[idx]
        used: Set[int] = set()
        for j in range(n):
            if adj[v][j] and color[j] >= 0:
                used.add(color[j])
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return color


def main():
    # SSA program variables with liveness intervals
    intervals = [
        (0, 3), (1, 5), (2, 4), (3, 7),
        (5, 8), (6, 9), (4, 6), (7, 10),
    ]
    var_names = [f"v{i}" for i in range(len(intervals))]
    n = len(intervals)

    adj = build_interval_graph(intervals)
    peo = peo_by_right_endpoint(intervals)
    pressure = register_pressure(adj, peo)
    colors = greedy_color(adj, peo)

    fig, axes = plt.subplots(3, 1, figsize=(12, 14), gridspec_kw={'height_ratios': [2, 2, 1.5]})

    # --- Panel 1: Liveness intervals ---
    ax1 = axes[0]
    cmap = plt.cm.Set3
    for i in range(n):
        a, b = intervals[i]
        color_val = cmap(colors[i] / max(max(colors) + 1, 1))
        ax1.barh(i, b - a + 1, left=a, height=0.6, color=color_val,
                edgecolor='black', linewidth=1)
        ax1.text(a + (b - a + 1) / 2, i, f"R{colors[i]}",
                ha='center', va='center', fontsize=9, fontweight='bold')

    ax1.set_yticks(range(n))
    ax1.set_yticklabels(var_names, fontsize=11)
    ax1.set_xlabel("Program Point (Instruction Index)", fontsize=12)
    ax1.set_title("Variable Liveness Intervals with Register Assignment (χ = ω)",
                  fontsize=14, fontweight='bold')
    ax1.invert_yaxis()
    ax1.grid(axis='x', alpha=0.3)

    # Legend for registers
    unique_colors = sorted(set(colors))
    patches = [mpatches.Patch(color=cmap(c / max(max(colors) + 1, 1)),
               label=f'Register R{c}') for c in unique_colors]
    ax1.legend(handles=patches, loc='upper right', fontsize=9)

    # --- Panel 2: Register pressure profile ---
    ax2 = axes[1]
    positions = range(n)
    max_p = max(pressure)

    bar_colors = ['#e74c3c' if p == max_p else '#3498db' for p in pressure]
    bars = ax2.bar(positions, pressure, color=bar_colors, edgecolor='black', linewidth=1)
    ax2.axhline(y=max_p, color='red', linestyle='--', linewidth=2,
               label=f'ω(G) = χ(G) = {max_p}')
    ax2.set_xticks(positions)
    ax2.set_xticklabels([f"σ({i})\n= v{peo[i]}" for i in range(n)], fontsize=9)
    ax2.set_ylabel("Register Pressure P(i)", fontsize=12)
    ax2.set_xlabel("PEO Position", fontsize=12)
    ax2.set_title("Register Pressure Profile (max = clique number = chromatic number)",
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11, loc='upper right')
    ax2.set_ylim(0, max_p + 1)

    for i, p in enumerate(pressure):
        ax2.text(i, p + 0.1, str(p), ha='center', va='bottom', fontsize=11, fontweight='bold')

    # --- Panel 3: Spill analysis ---
    ax3 = axes[2]
    omega = max_p
    ks = list(range(1, omega + 3))
    spills = [max(0, omega - k) for k in ks]
    colors_bar = ['#e74c3c' if s > 0 else '#2ecc71' for s in spills]
    ax3.bar(ks, spills, color=colors_bar, edgecolor='black', linewidth=1)
    ax3.set_xticks(ks)
    ax3.set_xlabel("Number of Available Registers (k)", fontsize=12)
    ax3.set_ylabel("Minimum Spills", fontsize=12)
    ax3.set_title("Spill Cost Lower Bound: max(0, ω(G) - k)", fontsize=14, fontweight='bold')
    ax3.axvline(x=omega, color='blue', linestyle=':', linewidth=2,
               label=f'k = ω(G) = {omega} (no spills needed)')
    ax3.legend(fontsize=10)

    for i, s in enumerate(spills):
        ax3.text(ks[i], s + 0.05, str(s), ha='center', va='bottom', fontsize=11, fontweight='bold')

    plt.tight_layout()
    plt.savefig('register_pressure_profile.png', dpi=150, bbox_inches='tight')
    print("Saved: register_pressure_profile.png")


if __name__ == "__main__":
    main()
