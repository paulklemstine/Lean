#!/usr/bin/env python3
"""
Register Allocation as Graph Coloring — Demonstration

This script demonstrates the key algorithms and theorems from the
formal verification of register allocation as graph coloring.

It constructs interference graphs from example programs, computes
chromatic numbers, verifies the SSA conjecture, and demonstrates
spill cost optimization.
"""

from algorithms import (
    InterferenceGraph,
    greedy_coloring,
    find_perfect_elimination_ordering,
    optimal_coloring_chordal,
    degree_based_spilling,
    verify_ssa_conjecture,
)


def example_1_basic_register_allocation():
    """
    Example: Simple program with 4 variables.

    Consider the code:
        a = input()    # a live: [1,4]
        b = a + 1      # b live: [2,5]
        c = a * b      # c live: [3,6]
        d = b + c      # d live: [4,7]
        output(a + d)  # uses a, d
        output(b + c)  # uses b, c

    Interference edges: (a,b), (a,c), (a,d), (b,c), (b,d)
    Note: c and d are NOT simultaneously live, so no edge (c,d).
    """
    print("=" * 60)
    print("Example 1: Basic Register Allocation (4 variables)")
    print("=" * 60)

    G = InterferenceGraph.from_edges(4, [
        (0, 1),  # a-b
        (0, 2),  # a-c
        (0, 3),  # a-d
        (1, 2),  # b-c
        (1, 3),  # b-d
    ])

    print(f"Variables: a=0, b=1, c=2, d=3")
    print(f"Edges: a-b, a-c, a-d, b-c, b-d")
    print(f"Max degree Δ = {G.max_degree()}")
    print(f"Clique number ω = {G.clique_number()}")

    # Greedy coloring
    result = greedy_coloring(G)
    color_names = ['R1', 'R2', 'R3', 'R4', 'R5', 'R6']
    var_names = ['a', 'b', 'c', 'd']
    print(f"\nGreedy coloring uses {result.num_colors} colors:")
    for i, c in enumerate(result.colors):
        print(f"  {var_names[i]} → {color_names[c]}")
    print(f"Valid coloring: {result.is_valid}")

    # Check chordality
    peo = find_perfect_elimination_ordering(G)
    print(f"\nChordal graph: {peo is not None}")
    if peo:
        print(f"PEO: {[var_names[v] for v in peo]}")

    # Verify SSA conjecture
    info = verify_ssa_conjecture(G)
    print(f"\nχ(G) = {info['chi']}, ω(G) = {info['omega']}")
    print(f"Conjecture χ=ω holds: {info['conjecture_holds']}")
    print(f"Brooks bound Δ+1 = {info['brooks_bound']}, satisfied: {info['brooks_satisfied']}")


def example_2_spilling():
    """
    Example: 5-variable program with only 2 registers available.
    Demonstrates spill cost analysis.
    """
    print("\n" + "=" * 60)
    print("Example 2: Spilling with Limited Registers")
    print("=" * 60)

    # A graph with clique number 3 — needs at least 3 colors
    G = InterferenceGraph.from_edges(5, [
        (0, 1), (0, 2), (1, 2),  # triangle: 0-1-2
        (2, 3), (3, 4),          # path from triangle
    ])

    print(f"n = {G.n}, Δ = {G.max_degree()}, ω = {G.clique_number()}")

    info = verify_ssa_conjecture(G)
    print(f"χ(G) = {info['chi']}, ω(G) = {info['omega']}")

    for k in [4, 3, 2, 1]:
        spill = degree_based_spilling(G, k)
        print(f"\n  k={k} registers: spill {spill.spill_cost} variables {spill.spilled}")
        if spill.spill_cost == 0:
            print(f"    Coloring: {spill.remaining_colors}")


def example_3_ssa_conjecture_test():
    """
    Systematic test of the SSA chromatic number conjecture
    on a variety of chordal graphs.
    """
    print("\n" + "=" * 60)
    print("Example 3: SSA Conjecture Verification")
    print("=" * 60)

    test_graphs = [
        # Complete graphs (chordal, χ = ω = n)
        ("K3", 3, [(0,1), (0,2), (1,2)]),
        ("K4", 4, [(i,j) for i in range(4) for j in range(i+1,4)]),

        # Paths (chordal, χ = 2 for n ≥ 2)
        ("P4", 4, [(0,1), (1,2), (2,3)]),
        ("P5", 5, [(0,1), (1,2), (2,3), (3,4)]),

        # Trees (chordal, χ = 2)
        ("Star4", 5, [(0,1), (0,2), (0,3), (0,4)]),

        # Interval graphs (chordal)
        ("Interval", 5, [(0,1), (1,2), (2,3), (3,4), (0,2), (1,3)]),

        # Chordal: complete bipartite K_{2,3} with chord
        ("Chordal6", 6, [(0,2),(0,3),(0,4),(1,2),(1,3),(1,4),(2,3)]),

        # Non-chordal: 4-cycle (C4)
        ("C4 (non-chordal)", 4, [(0,1), (1,2), (2,3), (3,0)]),
    ]

    print(f"{'Name':<20} {'n':>3} {'Δ':>3} {'ω':>3} {'χ':>3} {'Chordal':>8} {'χ=ω':>5}")
    print("-" * 55)

    for name, n, edges in test_graphs:
        G = InterferenceGraph.from_edges(n, edges)
        info = verify_ssa_conjecture(G)
        chi_eq_omega = "✓" if info['conjecture_holds'] else ("✗" if info['conjecture_holds'] is False else "N/A")
        chordal_str = "Yes" if info['is_chordal'] else "No"
        print(f"{name:<20} {info['n']:>3} {info['delta']:>3} {info['omega']:>3} {info['chi']:>3} {chordal_str:>8} {chi_eq_omega:>5}")

    print("\nNote: For chordal graphs, χ = ω always holds (they are perfect graphs).")
    print("For non-chordal graphs, χ may exceed ω.")


def example_4_degree_bound_verification():
    """
    Verify the degree bound theorem: χ(G) ≤ Δ(G) + 1
    This is the formal theorem chromatic_le_maxDegree_succ.
    """
    print("\n" + "=" * 60)
    print("Example 4: Degree Bound Verification (χ ≤ Δ+1)")
    print("=" * 60)

    import random
    random.seed(42)

    print(f"{'Trial':>6} {'n':>4} {'edges':>6} {'Δ':>4} {'χ':>4} {'Δ+1':>5} {'χ≤Δ+1':>7}")
    print("-" * 45)

    for trial in range(10):
        n = random.randint(4, 8)
        p = random.uniform(0.2, 0.6)
        edges = []
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    edges.append((i, j))

        G = InterferenceGraph.from_edges(n, edges)
        info = verify_ssa_conjecture(G)
        satisfied = "✓" if info['brooks_satisfied'] else "✗"
        print(f"{trial+1:>6} {n:>4} {len(edges):>6} {info['delta']:>4} {info['chi']:>4} {info['delta']+1:>5} {satisfied:>7}")

    print("\nTheorem: χ(G) ≤ Δ(G) + 1 for all graphs (verified in Lean 4)")


def example_5_clique_spill_bound():
    """
    Demonstrate the clique-spill lower bound theorem.
    If a clique of size m exists and k < m registers available,
    at least m - k vertices from the clique must be spilled.
    """
    print("\n" + "=" * 60)
    print("Example 5: Clique-Spill Lower Bound")
    print("=" * 60)

    # Graph with a 4-clique plus some extra vertices
    G = InterferenceGraph.from_edges(6, [
        # 4-clique on vertices 0,1,2,3
        (0,1), (0,2), (0,3), (1,2), (1,3), (2,3),
        # Extra vertices
        (4,0), (5,1),
    ])

    omega = G.clique_number()
    print(f"Graph: 6 vertices, 4-clique on {{0,1,2,3}}")
    print(f"ω(G) = {omega}")
    print(f"\nSpill analysis:")
    print(f"{'k registers':>12} {'Spilled':>10} {'Lower bound':>12} {'Achieved':>10}")
    print("-" * 50)

    for k in range(1, 6):
        spill = degree_based_spilling(G, k)
        lower = max(0, omega - k)
        achieved = "✓" if spill.spill_cost >= lower else "✗"
        print(f"{k:>12} {spill.spill_cost:>10} {lower:>12} {achieved:>10}")

    print(f"\nTheorem: spill_count ≥ ω(G) - k (verified in Lean 4)")


if __name__ == "__main__":
    example_1_basic_register_allocation()
    example_2_spilling()
    example_3_ssa_conjecture_test()
    example_4_degree_bound_verification()
    example_5_clique_spill_bound()


#!/usr/bin/env python3
"""
Visualization: Register Allocation as Graph Coloring

Generates plots showing:
1. An interference graph with its proper coloring (register assignment)
2. The relationship between Δ, ω, and χ for random graphs
3. Spill cost as a function of available registers
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import random

random.seed(42)
np.random.seed(42)


# ── Inline graph algorithms (self-contained) ──

def make_graph(n, edges):
    adj = [[False]*n for _ in range(n)]
    for u,v in edges:
        adj[u][v] = True; adj[v][u] = True
    return n, adj

def neighbors(adj, v):
    return [u for u in range(len(adj)) if adj[v][u]]

def degree(adj, v):
    return sum(1 for u in range(len(adj)) if adj[v][u])

def max_degree(n, adj):
    return max((degree(adj,v) for v in range(n)), default=0)

def greedy_color(n, adj, order=None):
    if order is None: order = list(range(n))
    colors = [-1]*n
    for v in order:
        used = {colors[u] for u in neighbors(adj,v) if colors[u]>=0}
        c = 0
        while c in used: c += 1
        colors[v] = c
    return colors

def clique_number(n, adj):
    from itertools import combinations
    omega = 0
    for k in range(1, n+1):
        found = False
        for s in combinations(range(n), k):
            if all(adj[s[i]][s[j]] for i in range(len(s)) for j in range(i+1,len(s))):
                omega = k; found = True; break
        if not found: break
    return omega

def chromatic_number(n, adj):
    def is_k_col(k):
        if k == 0: return n == 0
        cols = [-1]*n
        def bt(v):
            if v == n: return True
            for c in range(k):
                if all(cols[u]!=c for u in neighbors(adj,v) if cols[u]>=0):
                    cols[v] = c
                    if bt(v+1): return True
                    cols[v] = -1
            return False
        return bt(0)
    for k in range(n+1):
        if is_k_col(k): return k
    return n

def spill_count(n, adj, k):
    active = list(range(n))
    spilled = 0
    while True:
        sub = [v for v in active]
        idx = {v:i for i,v in enumerate(sub)}
        m = len(sub)
        if m == 0: return spilled
        sa = [[False]*m for _ in range(m)]
        for i,u in enumerate(sub):
            for j,v in enumerate(sub):
                if i!=j and adj[u][v]: sa[i][j] = True
        cols = greedy_color(m, sa)
        if max(cols, default=-1)+1 <= k: return spilled
        best = max(range(m), key=lambda v: degree(sa,v))
        active.remove(sub[best])
        spilled += 1


# ── Figure 1: Interference graph with coloring ──

def plot_interference_graph():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Example program interference graph
    n = 6
    var_names = ['a', 'b', 'c', 'd', 'e', 'f']
    edges = [(0,1),(0,2),(1,2),(1,3),(2,3),(3,4),(4,5)]
    _, adj = make_graph(n, edges)
    colors = greedy_color(n, adj)
    color_palette = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

    # Layout: circular
    angles = [2*math.pi*i/n - math.pi/2 for i in range(n)]
    x = [2*math.cos(a) for a in angles]
    y = [2*math.sin(a) for a in angles]

    ax = axes[0]
    ax.set_xlim(-3.5, 3.5); ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title('Interference Graph with Register Assignment', fontsize=13, fontweight='bold')

    # Draw edges
    for u,v in edges:
        ax.plot([x[u],x[v]], [y[u],y[v]], 'k-', linewidth=1.5, alpha=0.4)

    # Draw vertices
    for i in range(n):
        circle = plt.Circle((x[i], y[i]), 0.35, color=color_palette[colors[i]],
                           ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x[i], y[i], var_names[i], ha='center', va='center',
               fontsize=14, fontweight='bold', zorder=6)

    # Legend
    reg_names = [f'R{c+1}' for c in sorted(set(colors))]
    handles = [mpatches.Patch(color=color_palette[c], label=f'Register {reg_names[c]}')
               for c in sorted(set(colors))]
    ax.legend(handles=handles, loc='lower right', fontsize=10)
    ax.axis('off')

    # Figure 1b: Degree vs chromatic number for random graphs
    ax2 = axes[1]
    deltas, chis, omegas = [], [], []
    for _ in range(80):
        nn = random.randint(5, 10)
        p = random.uniform(0.15, 0.7)
        ee = [(i,j) for i in range(nn) for j in range(i+1,nn) if random.random()<p]
        _, aa = make_graph(nn, ee)
        d = max_degree(nn, aa)
        c = chromatic_number(nn, aa)
        o = clique_number(nn, aa)
        deltas.append(d); chis.append(c); omegas.append(o)

    ax2.scatter(deltas, chis, c='#3498db', alpha=0.6, s=50, label='χ(G)', zorder=3)
    ax2.scatter(deltas, omegas, c='#e74c3c', alpha=0.4, s=30, marker='x', label='ω(G)', zorder=3)

    # Plot Δ+1 line
    d_range = np.arange(0, max(deltas)+2)
    ax2.plot(d_range, d_range+1, 'k--', alpha=0.5, label='Δ+1 (upper bound)')
    ax2.plot(d_range, d_range, ':', color='gray', alpha=0.3)

    ax2.set_xlabel('Maximum Degree Δ(G)', fontsize=12)
    ax2.set_ylabel('Number of Colors', fontsize=12)
    ax2.set_title('Chromatic Number vs. Max Degree\n(Random Graphs)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_coloring_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_coloring_analysis.png")


# ── Figure 2: Spill cost analysis ──

def plot_spill_analysis():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Graph with known clique structure
    n = 8
    # 5-clique on 0-4, plus triangle 5-6-7 connected to clique
    edges = [(i,j) for i in range(5) for j in range(i+1,5)]
    edges += [(5,6),(6,7),(5,7),(5,0),(6,1),(7,2)]
    _, adj = make_graph(n, edges)

    omega = clique_number(n, adj)
    chi = chromatic_number(n, adj)
    delta = max_degree(n, adj)

    ks = list(range(1, 9))
    spills = [spill_count(n, adj, k) for k in ks]
    lower_bounds = [max(0, omega - k) for k in ks]

    ax = axes[0]
    ax.bar([k-0.15 for k in ks], spills, 0.3, color='#e74c3c', alpha=0.8, label='Actual spills')
    ax.bar([k+0.15 for k in ks], lower_bounds, 0.3, color='#3498db', alpha=0.8, label='Lower bound (ω-k)')
    ax.axvline(x=chi, color='green', linestyle='--', alpha=0.7, label=f'χ(G)={chi}')
    ax.set_xlabel('Available Registers (k)', fontsize=12)
    ax.set_ylabel('Variables Spilled', fontsize=12)
    ax.set_title(f'Spill Cost vs. Register Count\n(n={n}, ω={omega}, χ={chi}, Δ={delta})',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xticks(ks)
    ax.grid(True, alpha=0.3, axis='y')

    # Figure 2b: χ vs ω for chordal graphs
    ax2 = axes[1]
    chi_vals, omega_vals, is_chordal_list = [], [], []

    for _ in range(60):
        nn = random.randint(4, 9)
        # Generate interval graphs (always chordal)
        intervals = sorted([(random.randint(0,10), random.randint(0,10)) for _ in range(nn)],
                          key=lambda x: x[0])
        intervals = [(min(a,b), max(a,b)) for a,b in intervals]
        ee = []
        for i in range(nn):
            for j in range(i+1, nn):
                if intervals[i][1] >= intervals[j][0] and intervals[j][1] >= intervals[i][0]:
                    ee.append((i,j))
        _, aa = make_graph(nn, ee)
        c = chromatic_number(nn, aa)
        o = clique_number(nn, aa)
        chi_vals.append(c)
        omega_vals.append(o)

    ax2.scatter(omega_vals, chi_vals, c='#2ecc71', alpha=0.6, s=60, edgecolors='black',
               linewidth=0.5, zorder=3)
    max_val = max(max(chi_vals, default=1), max(omega_vals, default=1)) + 1
    ax2.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='χ = ω (perfect)')
    ax2.set_xlabel('Clique Number ω(G)', fontsize=12)
    ax2.set_ylabel('Chromatic Number χ(G)', fontsize=12)
    ax2.set_title('χ vs ω for Interval Graphs\n(All Chordal → All Perfect)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('fig_spill_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_spill_analysis.png")


# ── Figure 3: PEO and chordal structure ──

def plot_chordal_structure():
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Compare: chordal vs non-chordal gap between χ and ω
    ns = list(range(4, 11))
    chordal_gaps = []
    general_gaps = []

    for nn in ns:
        c_gaps, g_gaps = [], []
        for _ in range(30):
            # Chordal (interval) graphs
            intervals = [(random.randint(0,8), random.randint(0,8)) for _ in range(nn)]
            intervals = [(min(a,b), max(a,b)) for a,b in intervals]
            ee = [(i,j) for i in range(nn) for j in range(i+1,nn)
                  if intervals[i][1] >= intervals[j][0] and intervals[j][1] >= intervals[i][0]]
            _, aa = make_graph(nn, ee)
            c = chromatic_number(nn, aa)
            o = clique_number(nn, aa)
            c_gaps.append(c - o)

            # General random graphs
            p = random.uniform(0.2, 0.5)
            ee2 = [(i,j) for i in range(nn) for j in range(i+1,nn) if random.random()<p]
            _, aa2 = make_graph(nn, ee2)
            c2 = chromatic_number(nn, aa2)
            o2 = clique_number(nn, aa2)
            g_gaps.append(c2 - o2)

        chordal_gaps.append(np.mean(c_gaps))
        general_gaps.append(np.mean(g_gaps))

    ax.plot(ns, chordal_gaps, 'o-', color='#2ecc71', linewidth=2, markersize=8,
            label='Chordal (interval) graphs: E[χ-ω]')
    ax.plot(ns, general_gaps, 's-', color='#e74c3c', linewidth=2, markersize=8,
            label='General random graphs: E[χ-ω]')
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax.fill_between(ns, 0, chordal_gaps, alpha=0.1, color='#2ecc71')
    ax.fill_between(ns, 0, general_gaps, alpha=0.1, color='#e74c3c')

    ax.set_xlabel('Number of Vertices', fontsize=12)
    ax.set_ylabel('Average Gap χ(G) - ω(G)', fontsize=12)
    ax.set_title('Perfectness Gap: Chordal vs. General Graphs\n'
                'SSA interference graphs are chordal → gap = 0',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_chordal_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_chordal_structure.png")


if __name__ == "__main__":
    plot_interference_graph()
    plot_spill_analysis()
    plot_chordal_structure()
    print("\nAll visualizations generated successfully.")
