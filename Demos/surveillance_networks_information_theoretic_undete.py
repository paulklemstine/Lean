#!/usr/bin/env python3
"""
Surveillance Networks: Rate-Distortion Demo

Demonstrates the key theorems numerically:
1. Surveillance-Privacy Exclusion: shows that zero distortion requires large codebook
2. Rate-Distortion Curve: plots minimum rate vs allowed distortion
3. Dynamic Scaling: shows exponential growth of codebook for trajectories
4. Privacy Level: computes normalized privacy for various channel configurations
"""

import math
from itertools import product


def hamming_distortion(g1: list[list[bool]], g2: list[list[bool]]) -> int:
    """Compute Hamming distortion between two adjacency matrices."""
    n = len(g1)
    return sum(1 for i in range(n) for j in range(n) if g1[i][j] != g2[i][j])


def all_graphs(n: int) -> list[list[list[bool]]]:
    """Generate all possible adjacency matrices on n vertices."""
    edges = n * n
    graphs = []
    for bits in product([False, True], repeat=edges):
        g = [[bits[i * n + j] for j in range(n)] for i in range(n)]
        graphs.append(g)
    return graphs


def minimum_codebook_size(graphs: list, max_distortion: int) -> int:
    """
    Compute the minimum codebook size (greedy set cover) to achieve
    worst-case distortion ≤ max_distortion.
    """
    n_graphs = len(graphs)
    uncovered = set(range(n_graphs))
    codebook = []

    while uncovered:
        # Greedy: pick the graph that covers the most uncovered graphs
        best_center = -1
        best_coverage = -1
        for i in range(n_graphs):
            coverage = sum(
                1 for j in uncovered
                if hamming_distortion(graphs[i], graphs[j]) <= max_distortion
            )
            if coverage > best_coverage:
                best_coverage = coverage
                best_center = i
        codebook.append(best_center)
        uncovered -= {
            j for j in uncovered
            if hamming_distortion(graphs[best_center], graphs[j]) <= max_distortion
        }

    return len(codebook)


def demo_exclusion_theorem():
    """Demonstrate the surveillance-privacy exclusion theorem."""
    print("=" * 60)
    print("THEOREM: Surveillance-Privacy Exclusion")
    print("=" * 60)
    print()
    print("For networks with ≥ 2 distinguishable states,")
    print("perfect surveillance and perfect privacy are MUTUALLY EXCLUSIVE.")
    print()

    for n in [1, 2, 3]:
        num_states = 2 ** (n * n)
        print(f"Network with {n} vertices: {num_states} possible states")
        if num_states >= 2:
            print(f"  → Perfect surveillance requires codebook size ≥ {num_states}")
            print(f"  → Perfect privacy requires codebook size ≤ 1")
            print(f"  → IMPOSSIBLE to have both (since {num_states} > 1)")
        else:
            print(f"  → Trivial case (only 1 state)")
        print()


def demo_rate_distortion_curve():
    """Compute and display the rate-distortion curve for small networks."""
    print("=" * 60)
    print("RATE-DISTORTION CURVE (n=2 vertices, 4 edges)")
    print("=" * 60)
    print()

    n = 2
    graphs = all_graphs(n)
    max_possible_distortion = n * n

    print(f"Total network states: {len(graphs)}")
    print(f"Maximum Hamming distortion: {max_possible_distortion}")
    print()
    print(f"{'Distortion D':>15} {'Min Codebook':>15} {'Rate log₂':>15} {'Privacy Level':>15}")
    print("-" * 62)

    for D in range(max_possible_distortion + 1):
        min_cb = minimum_codebook_size(graphs, D)
        rate = math.log2(min_cb) if min_cb > 0 else 0
        max_rate = math.log2(len(graphs))
        privacy = 1 - rate / max_rate if max_rate > 0 else 1.0
        print(f"{D:>15} {min_cb:>15} {rate:>15.2f} {privacy:>15.3f}")

    print()
    print("Key observations:")
    print("  D=0: Rate = log₂(16) = 4.0 (full codebook needed)")
    print("  D=4: Rate = 0 (one codeword suffices)")
    print("  Privacy level increases monotonically with distortion")


def demo_dynamic_scaling():
    """Demonstrate exponential scaling for dynamic surveillance."""
    print()
    print("=" * 60)
    print("DYNAMIC SURVEILLANCE: Exponential Codebook Growth")
    print("=" * 60)
    print()

    print("For perfect reconstruction of T time steps:")
    print(f"{'|S|':>5} {'T':>5} {'|S|^T':>20} {'log₂(|S|^T)':>15}")
    print("-" * 47)

    for S_size in [4, 16, 64]:
        for T in [1, 2, 5, 10]:
            codebook_size = S_size ** T
            rate = T * math.log2(S_size)
            print(f"{S_size:>5} {T:>5} {codebook_size:>20} {rate:>15.1f}")
        print()

    print("The codebook grows EXPONENTIALLY with observation time.")
    print("This is the fundamental barrier to long-term perfect surveillance.")


def demo_privacy_level():
    """Demonstrate the privacy level computation."""
    print()
    print("=" * 60)
    print("PRIVACY LEVEL: π = 1 - log|C| / log|S|")
    print("=" * 60)
    print()

    S_size = 16  # 2-vertex network
    max_rate = math.log(S_size)

    print(f"Network with {S_size} states (log|S| = {max_rate:.2f})")
    print()
    print(f"{'|C|':>5} {'Rate':>10} {'Privacy π':>12} {'Type':>25}")
    print("-" * 54)

    for C_size in [1, 2, 4, 8, 16, 32]:
        rate = math.log(C_size)
        privacy = 1 - rate / max_rate
        if C_size <= 1:
            ch_type = "Privacy-preserving (π≥1)"
        elif C_size >= S_size:
            ch_type = "Surveillance-capable (π≤0)"
        else:
            ch_type = "Intermediate"
        print(f"{C_size:>5} {rate:>10.2f} {privacy:>12.3f} {ch_type:>25}")

    print()
    print("THEOREM: Surveillance-capable ⟹ π ≤ 0")
    print("THEOREM: Privacy-preserving ⟹ π ≥ 1")
    print("Gap of at least 1 between the two regimes!")


if __name__ == "__main__":
    demo_exclusion_theorem()
    demo_rate_distortion_curve()
    demo_dynamic_scaling()
    demo_privacy_level()


#!/usr/bin/env python3
"""
Visualization: Rate-Distortion Curve for Surveillance Networks

Generates a plot showing the rate-distortion tradeoff for small networks,
highlighting the exclusion regions.
"""

import math
from itertools import product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hamming_distortion(g1: list[list[bool]], g2: list[list[bool]]) -> int:
    n = len(g1)
    return sum(1 for i in range(n) for j in range(n) if g1[i][j] != g2[i][j])


def all_graphs(n: int) -> list[list[list[bool]]]:
    edges = n * n
    graphs = []
    for bits in product([False, True], repeat=edges):
        g = [[bits[i * n + j] for j in range(n)] for i in range(n)]
        graphs.append(g)
    return graphs


def min_codebook_size(graphs: list, max_dist: int) -> int:
    n_graphs = len(graphs)
    uncovered = set(range(n_graphs))
    count = 0
    while uncovered:
        best_idx = max(
            range(n_graphs),
            key=lambda i: sum(
                1 for j in uncovered
                if hamming_distortion(graphs[i], graphs[j]) <= max_dist
            )
        )
        count += 1
        uncovered -= {
            j for j in uncovered
            if hamming_distortion(graphs[best_idx], graphs[j]) <= max_dist
        }
    return count


def main():
    n = 2
    graphs = all_graphs(n)
    max_d = n * n

    distortions = list(range(max_d + 1))
    codebook_sizes = [min_codebook_size(graphs, D) for D in distortions]
    rates = [math.log2(cs) if cs > 1 else 0 for cs in codebook_sizes]
    privacy_levels = [1 - r / math.log2(len(graphs)) for r in rates]

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Rate vs Distortion
    ax = axes[0]
    ax.step(distortions, rates, where='post', color='#2196F3', linewidth=2)
    ax.fill_between(distortions, rates, alpha=0.15, step='post', color='#2196F3')
    ax.axhline(y=math.log2(len(graphs)), color='red', linestyle='--',
               alpha=0.7, label=f'log₂|S| = {math.log2(len(graphs)):.1f}')
    ax.set_xlabel('Maximum Distortion D', fontsize=12)
    ax.set_ylabel('Rate R (bits)', fontsize=12)
    ax.set_title('Rate-Distortion Curve\n(2-vertex network)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.2, max_d + 0.2)

    # Plot 2: Privacy Level vs Distortion
    ax = axes[1]
    ax.step(distortions, privacy_levels, where='post', color='#4CAF50', linewidth=2)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.7, label='Surveillance bound (π ≤ 0)')
    ax.axhline(y=1, color='blue', linestyle='--', alpha=0.7, label='Privacy bound (π ≥ 1)')
    ax.fill_between(distortions, 0, 1, alpha=0.08, color='gray')
    ax.annotate('EXCLUSION\nZONE', xy=(max_d/2, 0.5), fontsize=14,
                ha='center', va='center', color='gray', alpha=0.5, fontweight='bold')
    ax.set_xlabel('Maximum Distortion D', fontsize=12)
    ax.set_ylabel('Privacy Level π', fontsize=12)
    ax.set_title('Privacy-Utility Tradeoff\n(Pareto frontier)', fontsize=13)
    ax.legend(fontsize=9, loc='center right')
    ax.grid(True, alpha=0.3)

    # Plot 3: Dynamic Scaling
    ax = axes[2]
    S_sizes = [4, 8, 16]
    T_values = np.arange(1, 11)
    colors = ['#FF9800', '#E91E63', '#9C27B0']
    for S_size, color in zip(S_sizes, colors):
        log_codebook = [T * math.log2(S_size) for T in T_values]
        ax.plot(T_values, log_codebook, 'o-', color=color, linewidth=2,
                label=f'|S| = {S_size}', markersize=5)
    ax.set_xlabel('Time Steps T', fontsize=12)
    ax.set_ylabel('Min Rate (bits)', fontsize=12)
    ax.set_title('Dynamic Surveillance:\nExponential Scaling', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('rate_distortion_visualization.png', dpi=150, bbox_inches='tight')
    plt.savefig('rate_distortion_visualization.pdf', bbox_inches='tight')
    print("Saved: rate_distortion_visualization.png/pdf")


if __name__ == "__main__":
    main()
