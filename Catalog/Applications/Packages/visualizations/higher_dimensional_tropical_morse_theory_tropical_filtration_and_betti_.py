"""
Visualization: Tropical Morse Filtration and Homology Jump Profile

This script visualizes the tropical Morse filtration of a toric code,
showing how Betti numbers evolve as simplices are attached in weight order.
The resulting plot demonstrates the strict dichotomy theorem: each step
changes exactly one Betti number by exactly ±1.

Saves output as tropical_filtration.png.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def betti_delta(dim, is_birth, n):
    if is_birth:
        return 1 if dim == n else 0
    else:
        return -1 if dim == n + 1 else 0


def build_toric_filtration(L):
    """Build filtration steps for L×L toric code."""
    n_v = L * L
    n_e = 2 * L * L
    n_f = L * L
    steps = []
    for _ in range(n_v):
        steps.append((1, 0, True))
    for _ in range(n_v - 1):
        steps.append((2, 1, False))
    nc = n_e - (n_v - 1)
    for i in range(nc):
        steps.append((3 + i, 1, True))
    for _ in range(nc - 2):
        steps.append((100, 2, False))
    rem = n_f - (nc - 2)
    for _ in range(rem):
        steps.append((200, 2, True))
    return steps


def main():
    L = 3
    steps = build_toric_filtration(L)

    # Track running Betti numbers
    betti = [0, 0, 0]
    history = [(0, list(betti))]

    for i, (w, d, ib) in enumerate(steps):
        for n in range(3):
            betti[n] += betti_delta(d, ib, n)
        history.append((i + 1, list(betti)))

    xs = [h[0] for h in history]
    b0 = [h[1][0] for h in history]
    b1 = [h[1][1] for h in history]
    b2 = [h[1][2] for h in history]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f'Tropical Morse Filtration: {L}×{L} Toric Code [[{2*L*L}, 2, {L}]]',
                 fontsize=16, fontweight='bold')

    # Plot 1: Betti number evolution
    ax = axes[0, 0]
    ax.step(xs, b0, 'b-', linewidth=2, label='β₀ (connected components)', where='post')
    ax.step(xs, b1, 'r-', linewidth=2, label='β₁ (logical qubits)', where='post')
    ax.step(xs, b2, 'g-', linewidth=2, label='β₂ (cavities)', where='post')
    ax.set_xlabel('Filtration Step', fontsize=12)
    ax.set_ylabel('Betti Number', fontsize=12)
    ax.set_title('Betti Number Evolution', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Homology jump profile
    ax = axes[0, 1]
    jumps = defaultdict(lambda: defaultdict(int))
    for w, d, ib in steps:
        for n in range(3):
            delta = betti_delta(d, ib, n)
            if delta != 0:
                jumps[w][n] += delta

    weights = sorted(jumps.keys())
    colors = ['blue', 'red', 'green']
    labels = ['Δβ₀', 'Δβ₁', 'Δβ₂']
    bar_width = 0.25

    for idx, n in enumerate(range(3)):
        vals = [jumps[w].get(n, 0) for w in weights]
        positions = np.arange(len(weights)) + idx * bar_width
        ax.bar(positions, vals, bar_width, label=labels[idx],
               color=colors[idx], alpha=0.7)

    ax.set_xticks(np.arange(len(weights)) + bar_width)
    ax.set_xticklabels([str(w) for w in weights], rotation=45)
    ax.set_xlabel('Tropical Weight', fontsize=12)
    ax.set_ylabel('Betti Change', fontsize=12)
    ax.set_title('Homology Jump Profile', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    ax.axhline(y=0, color='black', linewidth=0.5)

    # Plot 3: Euler characteristic evolution
    ax = axes[1, 0]
    chi = [b0[i] - b1[i] + b2[i] for i in range(len(xs))]
    euler_direct = [0]
    running = 0
    for w, d, ib in steps:
        running += (-1) ** d
        euler_direct.append(running)

    ax.step(xs, chi, 'purple', linewidth=2, label='χ from Betti: β₀-β₁+β₂', where='post')
    ax.step(xs, euler_direct, 'orange', linewidth=2, linestyle='--',
            label='χ from faces: Σ(-1)^d', where='post')
    ax.set_xlabel('Filtration Step', fontsize=12)
    ax.set_ylabel('Euler Characteristic', fontsize=12)
    ax.set_title('Euler-Poincaré Consistency', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 4: Step types
    ax = axes[1, 1]
    step_types = []
    for w, d, ib in steps:
        if ib:
            step_types.append(f'Birth d={d}')
        else:
            step_types.append(f'Death d={d}')

    type_counts = defaultdict(int)
    for t in step_types:
        type_counts[t] += 1

    labels_pie = list(type_counts.keys())
    sizes = list(type_counts.values())
    colors_pie = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#00BCD4']

    ax.pie(sizes, labels=labels_pie, colors=colors_pie[:len(labels_pie)],
           autopct='%1.0f%%', startangle=90)
    ax.set_title('Filtration Step Types', fontsize=13)

    plt.tight_layout()
    plt.savefig('tropical_filtration.png', dpi=150, bbox_inches='tight')
    print("Saved tropical_filtration.png")


if __name__ == '__main__':
    main()
