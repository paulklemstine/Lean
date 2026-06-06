#!/usr/bin/env python3
"""
Anti-Gravity Mathematics: Numerical Demonstrations

This script demonstrates the core theorems about Gravitational Derivation Systems
through concrete numerical examples. It computes anti-gravity indices for randomly
generated dependency DAGs and validates the theoretical bounds.
"""

import random
import math
from collections import defaultdict
from typing import Dict, List, Set, Tuple

random.seed(42)


def generate_random_dag(n: int, edge_prob: float = 0.3) -> Dict[int, Set[int]]:
    """Generate a random DAG on n vertices with given edge probability.
    Edges go from lower-numbered to higher-numbered vertices (topological order)."""
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return adj


def compute_direct_weight(adj: Dict[int, Set[int]]) -> Dict[int, int]:
    """Compute direct weight (out-degree) for each vertex."""
    return {v: len(neighbors) for v, neighbors in adj.items()}


def assign_proof_effort(n: int, mode: str = "uniform") -> Dict[int, int]:
    """Assign proof effort to each theorem."""
    if mode == "uniform":
        return {i: random.randint(1, 5) for i in range(n)}
    elif mode == "proportional":
        return {i: max(1, i // 3 + 1) for i in range(n)}
    elif mode == "constant":
        return {i: 2 for i in range(n)}
    else:
        return {i: 1 for i in range(n)}


def find_anti_gravity_nodes(
    weights: Dict[int, int], efforts: Dict[int, int]
) -> List[int]:
    """Find all anti-gravitational nodes (weight > effort)."""
    return [v for v in weights if weights[v] > efforts[v]]


def compute_total_weight(weights: Dict[int, int]) -> int:
    return sum(weights.values())


def compute_total_effort(efforts: Dict[int, int]) -> int:
    return sum(efforts.values())


def demo_pigeonhole_theorem():
    """Demonstrate Theorem 1: Anti-Gravity Pigeonhole."""
    print("=" * 70)
    print("THEOREM 1: Anti-Gravity Pigeonhole")
    print("If total_effort < total_weight, anti-gravity nodes MUST exist.")
    print("=" * 70)

    for n in [10, 20, 50, 100]:
        adj = generate_random_dag(n, edge_prob=0.3)
        weights = compute_direct_weight(adj)
        efforts = assign_proof_effort(n, mode="constant")

        total_w = compute_total_weight(weights)
        total_e = compute_total_effort(efforts)
        ag_nodes = find_anti_gravity_nodes(weights, efforts)

        surplus = total_w > total_e
        print(f"\n  n={n:3d} | total_weight={total_w:5d} | total_effort={total_e:4d} | "
              f"surplus={'YES' if surplus else 'NO ':3s} | "
              f"anti-grav nodes={len(ag_nodes):3d} "
              f"({'✓ Theorem confirmed' if surplus and len(ag_nodes) > 0 else '(no surplus)' if not surplus else '✗ VIOLATION'})")

    print()


def demo_maximum_weight_bound():
    """Demonstrate Theorem 2: Maximum Weight Lower Bound."""
    print("=" * 70)
    print("THEOREM 2: Maximum Weight Lower Bound")
    print("∃ v : total_weight ≤ n × weight(v), i.e., max weight ≥ average.")
    print("=" * 70)

    for n in [10, 25, 50, 100]:
        adj = generate_random_dag(n, edge_prob=0.25)
        weights = compute_direct_weight(adj)

        total_w = compute_total_weight(weights)
        max_w = max(weights.values())
        avg_w = total_w / n
        bound_holds = total_w <= n * max_w

        print(f"\n  n={n:3d} | total_weight={total_w:5d} | max_weight={max_w:3d} | "
              f"avg_weight={avg_w:.1f} | n×max={n*max_w:5d} | "
              f"bound holds: {'✓' if bound_holds else '✗'}")

    print()


def demo_generalized_k_anti_gravity():
    """Demonstrate Theorem 3: Generalized k-Anti-Gravity."""
    print("=" * 70)
    print("THEOREM 3: Generalized k-Anti-Gravity")
    print("If k × total_effort < total_weight, k-anti-grav nodes exist.")
    print("=" * 70)

    n = 50
    adj = generate_random_dag(n, edge_prob=0.4)
    weights = compute_direct_weight(adj)
    efforts = assign_proof_effort(n, mode="constant")

    total_w = compute_total_weight(weights)
    total_e = compute_total_effort(efforts)

    for k in range(1, 8):
        k_ag_nodes = [v for v in weights if weights[v] > k * efforts[v]]
        surplus = k * total_e < total_w
        print(f"\n  k={k} | k×total_effort={k*total_e:5d} | total_weight={total_w:5d} | "
              f"surplus={'YES' if surplus else 'NO ':3s} | "
              f"k-anti-grav nodes={len(k_ag_nodes):3d} "
              f"{'✓' if (surplus and len(k_ag_nodes) > 0) or not surplus else '✗'}")

    print()


def demo_weight_monotonicity():
    """Demonstrate Theorem 4: Edge Addition Increases Weight."""
    print("=" * 70)
    print("THEOREM 4: Edge Addition Increases Weight (Monotonicity)")
    print("Adding edges never decreases any node's weight.")
    print("=" * 70)

    n = 20
    adj1 = generate_random_dag(n, edge_prob=0.15)
    weights1 = compute_direct_weight(adj1)

    # Add more edges (superset of adj1)
    adj2 = {v: set(neighbors) for v, neighbors in adj1.items()}
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < 0.3 and j not in adj2[i]:
                adj2[i].add(j)

    weights2 = compute_direct_weight(adj2)

    all_mono = all(weights1[v] <= weights2[v] for v in range(n))
    print(f"\n  Original edges: {sum(len(s) for s in adj1.values())}")
    print(f"  Extended edges: {sum(len(s) for s in adj2.values())}")
    print(f"  Weight monotonicity holds for all {n} nodes: {'✓' if all_mono else '✗'}")

    # Show a few examples
    print("\n  Node | Weight(G₁) | Weight(G₂) | Δ")
    print("  " + "-" * 40)
    for v in range(min(10, n)):
        delta = weights2[v] - weights1[v]
        print(f"    {v:2d}  |    {weights1[v]:3d}     |    {weights2[v]:3d}     | +{delta}")

    print()


def demo_anti_gravity_density():
    """Demonstrate the anti-gravity density prediction across random DAGs."""
    print("=" * 70)
    print("EMPIRICAL STUDY: Anti-Gravity Density")
    print("What fraction of nodes are anti-gravitational across many trials?")
    print("=" * 70)

    for n in [20, 50, 100, 200]:
        densities = []
        for trial in range(100):
            adj = generate_random_dag(n, edge_prob=0.3)
            weights = compute_direct_weight(adj)
            efforts = assign_proof_effort(n, mode="uniform")
            ag_nodes = find_anti_gravity_nodes(weights, efforts)
            densities.append(len(ag_nodes) / n)

        avg_density = sum(densities) / len(densities)
        max_density = max(densities)
        min_density = min(densities)
        print(f"\n  n={n:3d} | avg density={avg_density:.3f} | "
              f"min={min_density:.3f} | max={max_density:.3f} | "
              f"{'≈10%' if 0.05 < avg_density < 0.20 else f'{avg_density*100:.0f}%'}")

    print()


def demo_effort_scaling():
    """Demonstrate Theorem 5: Anti-Gravity Shrinks Under Effort Scaling."""
    print("=" * 70)
    print("THEOREM 5: Anti-Gravity Shrinks Under Effort Scaling")
    print("Multiplying all efforts by k ≥ 1 can only shrink the AG set.")
    print("=" * 70)

    n = 30
    adj = generate_random_dag(n, edge_prob=0.35)
    weights = compute_direct_weight(adj)
    efforts = assign_proof_effort(n, mode="uniform")

    for k in [1, 2, 3, 5, 10]:
        scaled_efforts = {v: k * e for v, e in efforts.items()}
        ag_original = set(find_anti_gravity_nodes(weights, efforts))
        ag_scaled = set(find_anti_gravity_nodes(weights, scaled_efforts))

        subset_holds = ag_scaled.issubset(ag_original)
        print(f"\n  k={k:2d} | AG(original)={len(ag_original):3d} | "
              f"AG(scaled)={len(ag_scaled):3d} | "
              f"AG(scaled) ⊆ AG(original): {'✓' if subset_holds else '✗'}")

    print()


def demo_gravitational_spectrum():
    """Visualize the gravitational spectrum of a DAG."""
    print("=" * 70)
    print("GRAVITATIONAL SPECTRUM ANALYSIS")
    print("Distribution of theorem weights in a dependency graph.")
    print("=" * 70)

    n = 50
    adj = generate_random_dag(n, edge_prob=0.25)
    weights = compute_direct_weight(adj)

    # Compute spectrum
    spectrum = sorted(weights.values(), reverse=True)
    total_w = sum(spectrum)
    avg_w = total_w / n

    print(f"\n  System: {n} theorems, {sum(len(s) for s in adj.values())} edges")
    print(f"  Total weight: {total_w}")
    print(f"  Average weight: {avg_w:.1f}")
    print(f"  Max weight: {spectrum[0]}")
    print(f"  Min weight: {spectrum[-1]}")

    # Histogram
    print("\n  Weight Distribution:")
    max_w = max(spectrum)
    buckets = defaultdict(int)
    for w in spectrum:
        buckets[w] += 1

    for w in range(max_w + 1):
        if buckets[w] > 0:
            bar = "█" * buckets[w]
            print(f"    weight {w:2d}: {bar} ({buckets[w]})")

    # Top-5 concentration
    top5_weight = sum(spectrum[:5])
    print(f"\n  Top 5 nodes control {top5_weight}/{total_w} = "
          f"{100*top5_weight/total_w:.1f}% of total weight")
    print(f"  Top 10 nodes control {sum(spectrum[:10])}/{total_w} = "
          f"{100*sum(spectrum[:10])/total_w:.1f}% of total weight")

    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  ANTI-GRAVITY MATHEMATICS: Numerical Demonstrations")
    print("  Gravitational Derivation Systems & Theorem Weight Analysis")
    print("=" * 70 + "\n")

    demo_pigeonhole_theorem()
    demo_maximum_weight_bound()
    demo_generalized_k_anti_gravity()
    demo_weight_monotonicity()
    demo_anti_gravity_density()
    demo_effort_scaling()
    demo_gravitational_spectrum()

    print("\n" + "=" * 70)
    print("  All demonstrations complete.")
    print("  Key finding: Anti-gravity is a mathematical necessity, not an accident.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Gravitational Spectrum of a Dependency DAG

Creates a publication-quality visualization of the gravitational spectrum,
anti-gravity classification, and weight-effort relationship.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

random.seed(42)


def generate_random_dag(n, edge_prob=0.3):
    adj = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < edge_prob:
                adj[i].add(j)
    return adj


def compute_direct_weight(adj):
    return {v: len(neighbors) for v, neighbors in adj.items()}


def assign_proof_effort(n, mode="uniform"):
    if mode == "uniform":
        return {i: random.randint(1, 5) for i in range(n)}
    elif mode == "constant":
        return {i: 2 for i in range(n)}
    return {i: 1 for i in range(n)}


def main():
    n = 60
    adj = generate_random_dag(n, edge_prob=0.3)
    weights = compute_direct_weight(adj)
    efforts = assign_proof_effort(n, mode="uniform")

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Anti-Gravity Mathematics: Gravitational Spectrum Analysis",
                 fontsize=16, fontweight='bold', y=0.98)

    # Panel 1: Weight vs Effort scatter
    ax1 = axes[0, 0]
    w_vals = [weights[v] for v in range(n)]
    e_vals = [efforts[v] for v in range(n)]
    colors = ['#e74c3c' if w_vals[i] > e_vals[i] else '#3498db' for i in range(n)]
    ax1.scatter(e_vals, w_vals, c=colors, s=50, alpha=0.7, edgecolors='black', linewidth=0.5)
    max_val = max(max(w_vals), max(e_vals)) + 1
    ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='w = π (boundary)')
    ax1.set_xlabel('Proof Effort π(v)', fontsize=11)
    ax1.set_ylabel('Direct Weight w(v)', fontsize=11)
    ax1.set_title('Weight vs. Effort', fontsize=13)
    red_patch = mpatches.Patch(color='#e74c3c', label='Anti-gravitational')
    blue_patch = mpatches.Patch(color='#3498db', label='Non-anti-gravitational')
    ax1.legend(handles=[red_patch, blue_patch], fontsize=9)
    ax1.set_xlim(0, max_val)
    ax1.set_ylim(0, max_val)

    # Panel 2: Gravitational spectrum (sorted weights)
    ax2 = axes[0, 1]
    sorted_weights = sorted(w_vals, reverse=True)
    x_pos = np.arange(len(sorted_weights))
    bar_colors = ['#e74c3c' if w > np.mean(e_vals) else '#3498db' for w in sorted_weights]
    ax2.bar(x_pos, sorted_weights, color=bar_colors, alpha=0.8, width=1.0)
    ax2.axhline(y=np.mean(w_vals), color='green', linestyle='--', alpha=0.7, label=f'Mean weight = {np.mean(w_vals):.1f}')
    ax2.axhline(y=np.mean(e_vals), color='orange', linestyle='--', alpha=0.7, label=f'Mean effort = {np.mean(e_vals):.1f}')
    ax2.set_xlabel('Theorem rank (by weight)', fontsize=11)
    ax2.set_ylabel('Direct Weight', fontsize=11)
    ax2.set_title('Gravitational Spectrum', fontsize=13)
    ax2.legend(fontsize=9)

    # Panel 3: k-Anti-gravity set sizes
    ax3 = axes[1, 0]
    k_values = range(0, 12)
    set_sizes = []
    for k in k_values:
        count = sum(1 for v in range(n) if weights[v] > k * efforts[v])
        set_sizes.append(count)
    ax3.bar(list(k_values), set_sizes, color='#9b59b6', alpha=0.8, edgecolor='black', linewidth=0.5)
    ax3.set_xlabel('Anti-gravity level k', fontsize=11)
    ax3.set_ylabel('|AG_k(G)|', fontsize=11)
    ax3.set_title('k-Anti-Gravity Hierarchy', fontsize=13)
    ax3.annotate(f'AG₁ = {set_sizes[1]} nodes', xy=(1, set_sizes[1]),
                xytext=(3, set_sizes[1] + 3), fontsize=9,
                arrowprops=dict(arrowstyle='->', color='black'))

    # Panel 4: Density across random trials
    ax4 = axes[1, 1]
    densities_by_n = {}
    for n_trial in [20, 40, 60, 80, 100]:
        densities = []
        for trial in range(200):
            a = generate_random_dag(n_trial, edge_prob=0.3)
            w = compute_direct_weight(a)
            e = assign_proof_effort(n_trial, mode="uniform")
            ag_count = sum(1 for v in w if w[v] > e[v])
            densities.append(ag_count / n_trial)
        densities_by_n[n_trial] = densities

    positions = list(range(len(densities_by_n)))
    labels = [str(n_val) for n_val in densities_by_n.keys()]
    data = [densities_by_n[n_val] for n_val in densities_by_n.keys()]
    bp = ax4.boxplot(data, positions=positions, labels=labels, patch_artist=True,
                     boxprops=dict(facecolor='#2ecc71', alpha=0.7),
                     medianprops=dict(color='black', linewidth=2))
    ax4.axhline(y=0.10, color='red', linestyle='--', alpha=0.5, label='10% prediction')
    ax4.set_xlabel('Number of theorems n', fontsize=11)
    ax4.set_ylabel('Anti-gravity fraction', fontsize=11)
    ax4.set_title('Anti-Gravity Density Distribution', fontsize=13)
    ax4.legend(fontsize=9)

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('/workspace/request-project/Applications/AntiGravity/spectrum_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectrum_analysis.png")


if __name__ == "__main__":
    main()
