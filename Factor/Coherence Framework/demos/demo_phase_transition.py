#!/usr/bin/env python3
"""
Coherence Theory — Phase Transition and Applications
=====================================================
Demonstrates the coherence phase transition in random constraint
satisfaction problems and practical applications.

Run: python demo_phase_transition.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from demo_coherence_basics import (coherence, walsh_hadamard_transform, truth_table_to_pm,
                                     spectral_distribution, spectral_entropy, make_random)


# ── Random Graph Coloring ─────────────────────────────────────────────────────

def random_graph_coloring_tt(num_nodes, num_edges, num_colors=3, seed=None):
    """
    Generate truth table for random graph coloring problem.
    Variables: num_nodes * ceil(log2(num_colors)) bits encoding node colors.
    
    For small instances only.
    """
    rng = np.random.RandomState(seed)
    
    # Generate random graph
    edges = set()
    all_possible = [(i, j) for i in range(num_nodes) for j in range(i+1, num_nodes)]
    if num_edges > len(all_possible):
        num_edges = len(all_possible)
    
    chosen = rng.choice(len(all_possible), size=num_edges, replace=False)
    edges = [all_possible[c] for c in chosen]
    
    bits_per_node = max(1, int(np.ceil(np.log2(num_colors))))
    n = num_nodes * bits_per_node
    
    if n > 16:
        return None, None
    
    truth_table = []
    for x_int in range(2**n):
        bits = [(x_int >> i) & 1 for i in range(n)]
        
        # Decode colors
        colors = []
        for node in range(num_nodes):
            color = 0
            for b in range(bits_per_node):
                idx = node * bits_per_node + b
                if idx < n:
                    color += bits[idx] << b
            colors.append(color % num_colors)
        
        # Check validity
        valid = all(colors[u] != colors[v] for u, v in edges)
        truth_table.append(int(valid))
    
    return truth_table, edges


# ── Algorithm Selection Based on Coherence ────────────────────────────────────

def algorithm_recommendation(c):
    """Recommend an algorithm based on coherence value."""
    if c > 0.7:
        return "Greedy / polynomial-time algorithm likely exists"
    elif c > 0.5:
        return "LP relaxation + rounding"
    elif c > 0.3:
        return "Branch-and-bound with spectral heuristics"
    elif c > 0.15:
        return "SAT solver with structure-aware preprocessing"
    elif c > 0.05:
        return "Randomized / simulated annealing"
    else:
        return "Brute force (no exploitable structure)"


# ── Experiments ───────────────────────────────────────────────────────────────

def experiment_graph_coloring_transition():
    """Coherence phase transition in graph coloring."""
    print("=" * 60)
    print("EXPERIMENT 1: Graph Coloring Phase Transition")
    print("=" * 60)
    
    num_nodes = 5
    bits_per_node = 2  # 4 colors
    n = num_nodes * bits_per_node
    
    edge_ratios = np.linspace(0.1, 1.0, 20)
    max_edges = num_nodes * (num_nodes - 1) // 2
    
    results = []
    for ratio in edge_ratios:
        num_edges = max(1, int(ratio * max_edges))
        cs = []
        sats = []
        
        for seed in range(20):
            tt, _ = random_graph_coloring_tt(num_nodes, num_edges, num_colors=4, seed=seed)
            if tt is not None and 0 < sum(tt) < len(tt):
                cs.append(coherence(tt))
                sats.append(sum(tt) / len(tt))
        
        if cs:
            results.append((ratio, np.mean(cs), np.std(cs), np.mean(sats)))
    
    if results:
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 10), sharex=True)
        
        ratios = [r[0] for r in results]
        c_means = [r[1] for r in results]
        c_stds = [r[2] for r in results]
        s_means = [r[3] for r in results]
        
        ax1.errorbar(ratios, c_means, yerr=c_stds, fmt='o-', color='steelblue', capsize=3)
        ax1.set_ylabel('Coherence C(f)', fontsize=12)
        ax1.set_title(f'Graph 4-Coloring Phase Transition ({num_nodes} nodes)', fontsize=14)
        ax1.grid(True, alpha=0.3)
        
        ax2.plot(ratios, s_means, 's-', color='green')
        ax2.set_xlabel('Edge density (fraction of complete graph)', fontsize=12)
        ax2.set_ylabel('Fraction of valid colorings', fontsize=12)
        ax2.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig('/workspace/request-project/CoherenceFramework/demos/coloring_transition.png', dpi=150)
        print("  Saved: coloring_transition.png")


def experiment_algorithm_selection():
    """Demonstrate algorithm selection based on coherence."""
    print("\n" + "=" * 60)
    print("EXPERIMENT 2: Algorithm Selection via Coherence")
    print("=" * 60)
    
    n = 10
    
    # Generate problems with varying structure
    problems = []
    
    # Highly structured: threshold functions
    for k in [2, 5, 8]:
        tt = [int(bin(x).count('1') >= k) for x in range(2**n)]
        c = coherence(tt)
        problems.append((f"Threshold-{k}", c, tt))
    
    # Moderately structured: random SAT
    from demo_sat_coherence import random_ksat
    for alpha in [2.0, 4.0, 5.0]:
        m = int(alpha * n)
        tt, _ = random_ksat(n, m, 3, seed=42)
        c = coherence(tt)
        problems.append((f"3-SAT α={alpha}", c, tt))
    
    # Low structure: random
    for seed in [0, 1, 2]:
        tt = make_random(n, seed=seed)
        c = coherence(tt)
        problems.append((f"Random-{seed}", c, tt))
    
    # Sort by coherence
    problems.sort(key=lambda x: -x[1])
    
    print(f"\n  {'Problem':25s} | {'C':>8s} | {'Recommendation'}")
    print(f"  {'-'*25} | {'-'*8} | {'-'*45}")
    for name, c, tt in problems:
        rec = algorithm_recommendation(c)
        print(f"  {name:25s} | {c:8.4f} | {rec}")


def experiment_batching_speedup():
    """Visualize theoretical batching speedup curves."""
    print("\n" + "=" * 60)
    print("EXPERIMENT 3: Batching Speedup Curves")
    print("=" * 60)
    
    fig, ax = plt.subplots(figsize=(10, 7))
    
    k_values = np.logspace(0, 4, 100)  # 1 to 10000 instances
    
    coherence_values = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(coherence_values)))
    
    for c, color in zip(coherence_values, colors):
        # Speedup = k / k^(1-C) = k^C
        speedup = k_values ** c
        ax.plot(k_values, speedup, color=color, linewidth=2, label=f'C = {c:.1f}')
    
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('Number of instances k', fontsize=12)
    ax.set_ylabel('Batching speedup (×)', fontsize=12)
    ax.set_title('Batching Speedup vs. Coherence', fontsize=14)
    ax.legend(title='Coherence', fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Add application annotations
    ax.annotate('Airline Scheduling\n(C ≈ 0.4)', xy=(100, 100**0.4), fontsize=9,
                ha='center', va='bottom', color='darkgreen',
                arrowprops=dict(arrowstyle='->', color='darkgreen'))
    ax.annotate('Cryptography\n(C ≈ 0)', xy=(100, 1.2), fontsize=9,
                ha='center', va='bottom', color='darkred')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/CoherenceFramework/demos/batching_speedup.png', dpi=150)
    print("  Saved: batching_speedup.png")


def experiment_coherence_hierarchy():
    """Map out the coherence hierarchy for problem families."""
    print("\n" + "=" * 60)
    print("EXPERIMENT 4: Coherence Hierarchy of Problem Families")
    print("=" * 60)
    
    n = 10
    
    # Compute coherence for various problem families
    families = {}
    
    # Dictator
    from demo_coherence_basics import make_dictator, make_parity, make_majority, make_and, make_or
    families["Dictator"] = coherence(make_dictator(n))
    families["Parity"] = coherence(make_parity(n))
    families["Majority"] = coherence(make_majority(n))
    families["AND"] = coherence(make_and(n))
    families["OR"] = coherence(make_or(n))
    
    # Threshold functions
    for k in [2, 3, 5, 7, 8]:
        tt = [int(bin(x).count('1') >= k) for x in range(2**n)]
        families[f"Thresh-{k}"] = coherence(tt)
    
    # Random functions (average)
    rand_cs = [coherence(make_random(n, seed=s)) for s in range(50)]
    families["Random (avg)"] = np.mean(rand_cs)
    
    # SAT instances at various densities
    from demo_sat_coherence import random_ksat
    for alpha in [2, 3, 4, 5]:
        sat_cs = []
        for seed in range(20):
            tt, _ = random_ksat(n, int(alpha * n), 3, seed=seed)
            if sum(tt) > 0:
                sat_cs.append(coherence(tt))
        if sat_cs:
            families[f"3-SAT α={alpha}"] = np.mean(sat_cs)
    
    # Sort and display
    sorted_families = sorted(families.items(), key=lambda x: -x[1])
    
    fig, ax = plt.subplots(figsize=(12, 8))
    names = [f[0] for f in sorted_families]
    values = [f[1] for f in sorted_families]
    
    # Color by tier
    colors = []
    for v in values:
        if v > 0.7:
            colors.append('#1a9641')  # Green - Tier 1
        elif v > 0.3:
            colors.append('#fdae61')  # Orange - Tier 2
        elif v > 0.1:
            colors.append('#d7191c')  # Red - Tier 3
        else:
            colors.append('#2c7bb6')  # Blue - Tier 0
    
    bars = ax.barh(range(len(names)), values, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.set_yticks(range(len(names)))
    ax.set_yticklabels(names, fontsize=10)
    ax.set_xlabel('Coherence C(f)', fontsize=12)
    ax.set_title(f'Coherence Hierarchy of Boolean Functions (n={n})', fontsize=14)
    ax.axvline(x=0.7, color='green', linestyle='--', alpha=0.3, label='Tier 1 boundary')
    ax.axvline(x=0.3, color='orange', linestyle='--', alpha=0.3, label='Tier 2 boundary')
    ax.axvline(x=0.1, color='red', linestyle='--', alpha=0.3, label='Tier 3 boundary')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='x')
    ax.invert_yaxis()
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/CoherenceFramework/demos/coherence_hierarchy.png', dpi=150)
    print("  Saved: coherence_hierarchy.png")
    
    print(f"\n  {'Function':20s} | {'Coherence':>10s} | {'Tier'}")
    print(f"  {'-'*20} | {'-'*10} | {'-'*20}")
    for name, c in sorted_families:
        tier = "1 (polynomial)" if c > 0.7 else "2 (structured)" if c > 0.3 else "3 (hard)" if c > 0.1 else "0 (cryptographic)"
        print(f"  {name:20s} | {c:10.4f} | {tier}")


def experiment_security_metric():
    """Demonstrate coherence as a cryptographic security metric."""
    print("\n" + "=" * 60)
    print("EXPERIMENT 5: Coherence as Security Metric")
    print("=" * 60)
    
    from demo_coherence_basics import make_dictator, make_parity, make_majority, make_random
    n = 12
    
    print(f"\n  Security analysis (n = {n}):")
    print(f"  {'Construction':30s} | {'C':>8s} | {'Security bits':>14s} | {'Grade'}")
    print(f"  {'-'*30} | {'-'*8} | {'-'*14} | {'-'*12}")
    
    constructions = []
    
    # 1. Identity (maximally insecure)
    tt = make_dictator(n)
    c = coherence(tt)
    constructions.append(("Identity/Dictator", c))
    
    # 2. Linear function
    tt = make_parity(n)
    c = coherence(tt)
    constructions.append(("Linear (parity)", c))
    
    # 3. Majority
    tt = make_majority(n)
    c = coherence(tt)
    constructions.append(("Majority", c))
    
    # 4. Random function (ideal PRF)
    rand_cs = [coherence(make_random(n, seed=s)) for s in range(30)]
    c = np.mean(rand_cs)
    constructions.append(("Random (ideal PRF)", c))
    
    # 5. Bent function approximation
    rng = np.random.RandomState(99)
    tt = list(rng.randint(0, 2, size=2**n))
    # Flatten the spectrum by adding noise
    for _ in range(n):
        i, j = rng.randint(0, 2**n, size=2)
        tt[i], tt[j] = tt[j], tt[i]
    c = coherence(tt)
    constructions.append(("Bent-like function", c))
    
    for name, c in constructions:
        if c > 0:
            security = -np.log2(c)
        else:
            security = float('inf')
        grade = "BROKEN" if c > 0.5 else "WEAK" if c > 0.1 else "MODERATE" if c > 0.01 else "STRONG"
        sec_str = f"{security:.1f}" if security < float('inf') else "∞"
        print(f"  {name:30s} | {c:8.4f} | {sec_str:>14s} | {grade}")


if __name__ == "__main__":
    experiment_graph_coloring_transition()
    experiment_algorithm_selection()
    experiment_batching_speedup()
    experiment_coherence_hierarchy()
    experiment_security_metric()
    print("\n" + "=" * 60)
    print("All phase transition experiments complete!")
    print("=" * 60)
