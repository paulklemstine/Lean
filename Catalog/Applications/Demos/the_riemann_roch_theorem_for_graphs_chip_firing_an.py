#!/usr/bin/env python3
"""
Demo: Chip-Firing and the Riemann-Roch Theorem for Graphs

Demonstrates key computations from Baker-Norine theory:
1. Canonical divisors and genus for complete graphs
2. Chip-firing dynamics
3. Riemann-Roch verification
4. Canonical rank conjecture testing
"""

from algorithms import (
    Graph, Divisor, canonical_divisor, chip_fire,
    compute_rank, verify_riemann_roch, canonical_rank_conjecture_test
)


def demo_canonical_divisors():
    """Show canonical divisors for small complete graphs."""
    print("=" * 60)
    print("CANONICAL DIVISORS FOR COMPLETE GRAPHS K_n")
    print("=" * 60)
    print()

    for n in range(3, 7):
        G = Graph.complete(n)
        K = canonical_divisor(G)
        g = G.genus()
        print(f"K_{n}:")
        print(f"  Vertices: {n}, Edges: {G.num_edges()}")
        print(f"  Genus g = |E| - |V| + 1 = {G.num_edges()} - {n} + 1 = {g}")
        print(f"  Canonical divisor K = {K.values}")
        print(f"  deg(K) = {K.degree()} = 2g - 2 = {2*g - 2} ✓")
        print(f"  Each vertex: deg(v) - 2 = {n-1} - 2 = {n-3}")
        print()


def demo_chip_firing():
    """Demonstrate chip-firing dynamics on K_4."""
    print("=" * 60)
    print("CHIP-FIRING ON K_4")
    print("=" * 60)
    print()

    G = Graph.complete(4)
    D = Divisor([3, 0, 0, 0])
    print(f"Initial divisor: {D.values}, degree = {D.degree()}")
    print()

    for step in range(4):
        # Find a vertex that can fire (has >= deg chips)
        fired = False
        for v in range(G.n):
            if D[v] >= G.degree(v):
                D_new = chip_fire(G, D, v)
                print(f"Step {step+1}: Fire vertex {v} (has {D[v]} chips, needs {G.degree(v)})")
                print(f"  Before: {D.values}")
                print(f"  After:  {D_new.values}, degree = {D_new.degree()}")
                D = D_new
                fired = True
                break
        if not fired:
            print(f"No vertex can fire. Current state: {D.values}")
            break
        print()


def demo_riemann_roch():
    """Verify Riemann-Roch for various divisors on small graphs."""
    print("=" * 60)
    print("RIEMANN-ROCH VERIFICATION")
    print("=" * 60)
    print()

    # Test on K_3
    G3 = Graph.complete(3)
    print("Graph: K_3 (genus = 1)")
    print("-" * 40)
    test_divisors_3 = [
        [2, 0, 0],
        [1, 1, 0],
        [0, 0, 0],
        [1, 0, 0],
        [3, -1, 0],
    ]
    for vals in test_divisors_3:
        result = verify_riemann_roch(G3, Divisor(vals))
        status = "✓" if result['RR_holds'] else "✗"
        print(f"  D={vals}: r(D)={result['r(D)']}, r(K-D)={result['r(K-D)']}, "
              f"LHS={result['LHS (r(D)-r(K-D))']}, RHS={result['RHS (deg(D)+1-g)']} {status}")
    print()

    # Test on K_4
    G4 = Graph.complete(4)
    print("Graph: K_4 (genus = 3)")
    print("-" * 40)
    test_divisors_4 = [
        [3, 0, 0, 0],
        [1, 1, 1, 0],
        [2, 1, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 1],
    ]
    for vals in test_divisors_4:
        result = verify_riemann_roch(G4, Divisor(vals))
        status = "✓" if result['RR_holds'] else "✗"
        print(f"  D={vals}: r(D)={result['r(D)']}, r(K-D)={result['r(K-D)']}, "
              f"LHS={result['LHS (r(D)-r(K-D))']}, RHS={result['RHS (deg(D)+1-g)']} {status}")
    print()


def demo_canonical_rank_conjecture():
    """Test the canonical rank conjecture for small complete graphs."""
    print("=" * 60)
    print("CANONICAL RANK CONJECTURE: rank(K_{K_n}) = g - 1")
    print("=" * 60)
    print()

    for n in range(3, 7):
        result = canonical_rank_conjecture_test(n)
        status = "✓" if result['conjecture_holds'] else "✗"
        print(f"K_{result['n']}: g = {result['g']}, "
              f"rank(K) = {result['r(K)']}, g-1 = {result['g-1']} {status}")
    print()


def demo_cycle_graphs():
    """Test Riemann-Roch on cycle graphs."""
    print("=" * 60)
    print("RIEMANN-ROCH ON CYCLE GRAPHS C_n")
    print("=" * 60)
    print()

    for n in range(3, 7):
        G = Graph.cycle(n)
        K = canonical_divisor(G)
        g = G.genus()
        print(f"C_{n}: genus = {g}, K = {K.values}, deg(K) = {K.degree()}")

        # Test with a few divisors
        D1 = Divisor([1] + [0] * (n - 1))
        result = verify_riemann_roch(G, D1)
        status = "✓" if result['RR_holds'] else "✗"
        print(f"  D={D1.values}: r(D)={result['r(D)']}, r(K-D)={result['r(K-D)']}, "
              f"RR {status}")

        result_K = verify_riemann_roch(G, K)
        status_K = "✓" if result_K['RR_holds'] else "✗"
        print(f"  D=K={K.values}: r(K)={result_K['r(D)']}, r(0)={result_K['r(K-D)']}, "
              f"RR {status_K}")
        print()


if __name__ == '__main__':
    demo_canonical_divisors()
    demo_chip_firing()
    demo_riemann_roch()
    demo_canonical_rank_conjecture()
    demo_cycle_graphs()


#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics and Riemann-Roch on Graphs

Creates three visualizations:
1. Chip-firing evolution on K_4
2. Genus and canonical divisor degree for K_n
3. Riemann-Roch verification heatmap for K_4
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def complete_graph_edges(n):
    return [(i, j) for i in range(n) for j in range(i+1, n)]

def complete_graph_adj(n):
    adj = {v: set() for v in range(n)}
    for u, v in complete_graph_edges(n):
        adj[u].add(v)
        adj[v].add(u)
    return adj

def chip_fire_step(D, v, adj, n):
    result = list(D)
    deg_v = len(adj[v])
    result[v] -= deg_v
    for w in adj[v]:
        result[w] += 1
    return tuple(result)

def plot_genus_and_canonical():
    """Plot genus and canonical divisor properties for K_n."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    ns = list(range(2, 12))
    genera = [(n-1)*(n-2)//2 for n in ns]
    canon_degrees = [n*(n-3) for n in ns]
    edges = [n*(n-1)//2 for n in ns]

    # Plot 1: Genus of K_n
    ax = axes[0]
    ax.bar(ns, genera, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.set_xlabel('n (vertices)', fontsize=12)
    ax.set_ylabel('Genus g(K_n)', fontsize=12)
    ax.set_title('Genus of Complete Graph K_n\ng = (n-1)(n-2)/2', fontsize=13)
    for i, (n, g) in enumerate(zip(ns, genera)):
        if g > 0:
            ax.text(n, g + 0.5, str(g), ha='center', fontsize=9)

    # Plot 2: deg(K) = 2g - 2
    ax = axes[1]
    ax.plot(ns, canon_degrees, 'ro-', markersize=8, label='deg(K_G) = n(n-3)')
    ax.plot(ns, [2*g - 2 for g in genera], 'b^--', markersize=8, label='2g - 2')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_title('Canonical Divisor Degree\ndeg(K_G) = 2g - 2', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Edge count vs genus relationship
    ax = axes[2]
    ax.scatter(edges, genera, c=ns, cmap='viridis', s=100, zorder=5)
    ax.plot(edges, genera, 'k--', alpha=0.3)
    for n, e, g in zip(ns, edges, genera):
        ax.annotate(f'K_{n}', (e, g), textcoords="offset points",
                   xytext=(5, 5), fontsize=9)
    ax.set_xlabel('|E| (edges)', fontsize=12)
    ax.set_ylabel('Genus g', fontsize=12)
    ax.set_title('g = |E| - |V| + 1\nGenus vs Edge Count', fontsize=13)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('genus_canonical.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: genus_canonical.png")


def plot_chipfiring_dynamics():
    """Visualize chip-firing evolution on K_4."""
    n = 4
    adj = complete_graph_adj(n)

    # Start with several initial configurations and track evolution
    configs = [
        (4, 0, 0, 0),
        (3, 1, 0, 0),
        (2, 2, 0, 0),
        (2, 1, 1, 0),
        (1, 1, 1, 1),
    ]

    fig, axes = plt.subplots(len(configs), 1, figsize=(14, 3 * len(configs)))

    for idx, init_config in enumerate(configs):
        ax = axes[idx]
        history = [list(init_config)]
        current = list(init_config)

        for step in range(12):
            fired = False
            for v in range(n):
                if current[v] >= len(adj[v]):
                    current = list(chip_fire_step(tuple(current), v, adj, n))
                    history.append(list(current))
                    fired = True
                    break
            if not fired:
                break

        data = np.array(history)
        x = np.arange(len(history))
        colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
        labels = [f'v_{i}' for i in range(n)]

        for v in range(n):
            ax.plot(x, data[:, v], 'o-', color=colors[v], label=labels[v],
                   markersize=6, linewidth=2)

        ax.set_ylabel('Chips', fontsize=10)
        ax.set_title(f'Initial: {list(init_config)}, degree={sum(init_config)}',
                    fontsize=11, fontweight='bold')
        ax.legend(loc='upper right', fontsize=9, ncol=4)
        ax.grid(True, alpha=0.3)
        ax.set_xticks(x)
        ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)

    axes[-1].set_xlabel('Firing Step', fontsize=12)
    fig.suptitle('Chip-Firing Dynamics on K₄', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('chipfiring_dynamics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: chipfiring_dynamics.png")


def plot_riemann_roch_verification():
    """Heatmap of Riemann-Roch verification for divisors on K_3."""
    n = 3
    adj = complete_graph_adj(n)

    def q_reduce_simple(D_vals, q, adj, n):
        D = list(D_vals)
        for _ in range(1000):
            for __ in range(1000):
                worst_v = -1
                worst_val = 0
                for v in range(n):
                    if v == q: continue
                    if D[v] < worst_val:
                        worst_v = v
                        worst_val = D[v]
                if worst_v == -1: break
                v = worst_v
                deg_v = len(adj[v])
                times = (-D[v] + deg_v - 1) // deg_v
                D[v] += times * deg_v
                for w in adj[v]:
                    D[w] -= times
            burnt = {q}
            changed = True
            while changed:
                changed = False
                for v in range(n):
                    if v in burnt: continue
                    etb = sum(1 for w in adj[v] if w in burnt)
                    if etb > D[v]:
                        burnt.add(v)
                        changed = True
            if len(burnt) == n: break
            for v in range(n):
                if v not in burnt:
                    D[v] -= len(adj[v])
                    for w in adj[v]:
                        D[w] += 1
        return D

    def has_eff_equiv(D_vals, adj, n):
        if sum(D_vals) < 0: return False
        D_red = q_reduce_simple(D_vals, 0, adj, n)
        return all(x >= 0 for x in D_red)

    def compute_rank_simple(D_vals, adj, n):
        if not has_eff_equiv(D_vals, adj, n): return -1
        r = 0
        while r <= sum(D_vals):
            if not _check_rank_simple(D_vals, adj, n, r + 1): return r
            r += 1
        return r

    def _check_rank_simple(D_vals, adj, n, k):
        if k <= 0: return has_eff_equiv(D_vals, adj, n)
        for combo in _comps(k, n):
            diff = [D_vals[i] - combo[i] for i in range(n)]
            if not has_eff_equiv(diff, adj, n): return False
        return True

    def _comps(k, n):
        if n == 1: yield (k,); return
        for i in range(k+1):
            for rest in _comps(k-i, n-1):
                yield (i,) + rest

    # Generate divisors on K_3 with degree in [-2, 4]
    results = []
    for d0 in range(-2, 5):
        for d1 in range(-2, 5):
            d2_vals = [0]
            for d2 in d2_vals:
                D = [d0, d1, d2]
                deg = sum(D)
                K = [0, 0, 0]  # canonical of K_3
                KmD = [K[i] - D[i] for i in range(n)]
                r_D = compute_rank_simple(D, adj, n)
                r_KD = compute_rank_simple(KmD, adj, n)
                g = 1
                lhs = r_D - r_KD
                rhs = deg + 1 - g
                results.append({
                    'D': D, 'deg': deg, 'r_D': r_D, 'r_KD': r_KD,
                    'lhs': lhs, 'rhs': rhs, 'holds': lhs == rhs
                })

    # Create visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap of r(D) for D = (a, b, 0) on K_3
    a_range = range(-2, 5)
    b_range = range(-2, 5)
    rank_grid = np.zeros((len(b_range), len(a_range)))
    rr_grid = np.zeros((len(b_range), len(a_range)))

    for i, b in enumerate(b_range):
        for j, a in enumerate(a_range):
            D = [a, b, 0]
            r = compute_rank_simple(D, adj, n)
            rank_grid[i, j] = r
            K = [0, 0, 0]
            KmD = [K[k] - D[k] for k in range(n)]
            r_KD = compute_rank_simple(KmD, adj, n)
            rr_grid[i, j] = 1 if (r - r_KD == sum(D) + 1 - 1) else 0

    ax = axes[0]
    im = ax.imshow(rank_grid, cmap='RdYlGn', origin='lower',
                   extent=[-2.5, 4.5, -2.5, 4.5], aspect='auto')
    ax.set_xlabel('D(v₀)', fontsize=12)
    ax.set_ylabel('D(v₁)', fontsize=12)
    ax.set_title('Rank r(D) for D=(a,b,0) on K₃', fontsize=13)
    plt.colorbar(im, ax=ax, label='rank')

    # Mark effective region
    for i, b in enumerate(b_range):
        for j, a in enumerate(a_range):
            ax.text(a, b, f'{int(rank_grid[i,j])}', ha='center', va='center',
                   fontsize=8, color='black', fontweight='bold')

    ax = axes[1]
    im2 = ax.imshow(rr_grid, cmap='RdYlGn', origin='lower',
                    extent=[-2.5, 4.5, -2.5, 4.5], aspect='auto', vmin=0, vmax=1)
    ax.set_xlabel('D(v₀)', fontsize=12)
    ax.set_ylabel('D(v₁)', fontsize=12)
    ax.set_title('Riemann-Roch Verification on K₃\n(green = holds)', fontsize=13)

    for i, b in enumerate(b_range):
        for j, a in enumerate(a_range):
            ax.text(a, b, '✓' if rr_grid[i,j] else '✗', ha='center', va='center',
                   fontsize=10, color='black', fontweight='bold')

    plt.tight_layout()
    plt.savefig('riemann_roch_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: riemann_roch_heatmap.png")


if __name__ == '__main__':
    plot_genus_and_canonical()
    plot_chipfiring_dynamics()
    plot_riemann_roch_verification()
    print("\nAll visualizations generated successfully!")
