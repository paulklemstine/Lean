#!/usr/bin/env python3
"""
Visualization: The Lattice of Forgetting Strategies

Shows the partial order on memory systems by forgetting,
from perfect memory (bottom) to total amnesia (top).
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple


def encode(stream: Tuple[int, ...], gen_images: Dict[int, int], mod: int) -> int:
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def count_classes(gen_images: Dict[int, int], mod: int, max_len: int) -> int:
    seen = set()
    streams = [()]
    for length in range(1, max_len + 1):
        streams.extend(product([0, 1], repeat=length))
    for s in streams:
        seen.add(encode(s, gen_images, mod))
    return len(seen)


def check_leq(gen1: Dict[int, int], mod1: int,
              gen2: Dict[int, int], mod2: int, max_len: int) -> bool:
    """Check if system 1's congruence ≤ system 2's congruence."""
    streams = [()]
    for length in range(1, max_len + 1):
        streams.extend(product([0, 1], repeat=length))

    classes1 = defaultdict(list)
    for s in streams:
        classes1[encode(s, gen1, mod1)].append(s)

    for members in classes1.values():
        images2 = {encode(m, gen2, mod2) for m in members}
        if len(images2) > 1:
            return False
    return True


def main():
    # Define several memory systems over {0, 1}
    systems = [
        ("Z/1 (amnesia)", {0: 0, 1: 0}, 1),
        ("Z/2 (parity)", {0: 1, 1: 1}, 2),
        ("Z/2 (diff)", {0: 1, 1: 0}, 2),
        ("Z/3 (mod 3)", {0: 1, 1: 2}, 3),
        ("Z/4 (rich)", {0: 1, 1: 3}, 4),
        ("Z/6 (fine)", {0: 2, 1: 3}, 6),
    ]

    max_len = 4
    n = len(systems)

    # Compute the partial order
    leq = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(n):
            leq[i][j] = check_leq(systems[i][1], systems[i][2],
                                   systems[j][1], systems[j][2], max_len)

    # Compute classes count
    class_counts = []
    for name, gen, mod in systems:
        cc = count_classes(gen, mod, max_len)
        class_counts.append(cc)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))
    fig.suptitle('The Lattice of Forgetting Strategies', fontsize=14, fontweight='bold')

    # Left: Hasse diagram (partial order)
    ax1.set_title('Forgetting Order (Hasse-like Diagram)')

    # Position nodes by class count (y) and spread (x)
    y_positions = {}
    for i, cc in enumerate(class_counts):
        if cc not in y_positions:
            y_positions[cc] = []
        y_positions[cc].append(i)

    positions = {}
    for cc, indices in y_positions.items():
        spread = np.linspace(-len(indices)/2, len(indices)/2, len(indices))
        for k, idx in enumerate(indices):
            positions[idx] = (spread[k], cc)

    # Draw edges (only Hasse: remove transitive edges)
    for i in range(n):
        for j in range(n):
            if i != j and leq[i][j]:
                # Check if this is a direct edge (no intermediate)
                is_direct = True
                for k in range(n):
                    if k != i and k != j and leq[i][k] and leq[k][j]:
                        is_direct = False
                        break
                if is_direct:
                    xi, yi = positions[i]
                    xj, yj = positions[j]
                    ax1.annotate('', xy=(xj, yj - 0.15), xytext=(xi, yi + 0.15),
                                arrowprops=dict(arrowstyle='->', color='#555',
                                                lw=1.5, connectionstyle='arc3,rad=0.1'))

    # Draw nodes
    node_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    for i, (name, gen, mod) in enumerate(systems):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.3, color=node_colors[i % len(node_colors)],
                            ec='black', lw=1.5, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, str(class_counts[i]), ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)
        ax1.text(x + 0.4, y, name, ha='left', va='center', fontsize=8)

    ax1.set_xlim(-3, 4)
    ax1.set_ylim(0, max(class_counts) + 1)
    ax1.set_ylabel('Number of Distinct Memory Classes')
    ax1.set_xlabel('(nodes show class count; arrows show forgetting order)')
    ax1.grid(True, alpha=0.3)

    # Right: Compression ratios
    ax2.set_title('Compression Ratio by Stream Length')

    for i, (name, gen, mod) in enumerate(systems):
        lengths = range(1, 7)
        ratios = []
        for L in lengths:
            total = 2 ** L
            streams = list(product([0, 1], repeat=L))
            distinct = len({encode(s, gen, mod) for s in streams})
            ratios.append(total / max(distinct, 1))

        ax2.plot(list(lengths), ratios, 'o-', color=node_colors[i % len(node_colors)],
                label=name, linewidth=2, markersize=6)

    ax2.set_xlabel('Stream Length')
    ax2.set_ylabel('Compression Ratio (streams / distinct states)')
    ax2.legend(fontsize=8)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_forgetting_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_forgetting_lattice.png")


if __name__ == '__main__':
    main()
