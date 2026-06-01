"""Visualization: Forgetting lattice structure.

Shows the lattice of selective forgetting congruences for a 3-symbol alphabet,
illustrating how forgetting more symbols creates coarser equivalences.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def selective_forget(stream, forgotten):
    """Remove forgotten symbols from stream."""
    return tuple(s for s in stream if s not in forgotten)


def main():
    alphabet = ['a', 'b', 'c']

    # All subsets of the alphabet (forgetting sets)
    subsets = [frozenset()]
    for r in range(1, len(alphabet) + 1):
        for combo in combinations(alphabet, r):
            subsets.append(frozenset(combo))

    # Position subsets in a lattice layout
    # Level = size of the subset
    levels = {}
    for s in subsets:
        lvl = len(s)
        if lvl not in levels:
            levels[lvl] = []
        levels[lvl].append(s)

    # Assign positions
    positions = {}
    max_level = max(levels.keys())
    for lvl, sets in levels.items():
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n - 1) / 2) * 2
            y = -lvl * 2
            positions[s] = (x, y)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Lattice diagram
    ax1.set_title('Lattice of Forgetting Operations', fontsize=13, fontweight='bold')

    # Draw edges (subset relations)
    for s in subsets:
        for t in subsets:
            if s < t and len(t) == len(s) + 1:
                x1, y1 = positions[s]
                x2, y2 = positions[t]
                ax1.plot([x1, x2], [y1, y2], 'k-', linewidth=1, alpha=0.5)

    # Draw nodes
    colors = {0: '#2ecc71', 1: '#3498db', 2: '#e74c3c', 3: '#95a5a6'}
    for s in subsets:
        x, y = positions[s]
        lvl = len(s)
        label = '{' + ','.join(sorted(s)) + '}' if s else '∅'
        ax1.scatter(x, y, s=800, c=colors[lvl], zorder=5, edgecolors='black')
        ax1.annotate(label, (x, y), textcoords="offset points",
                     xytext=(0, -20), ha='center', fontsize=9, fontweight='bold')

    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-8, 1)
    ax1.axis('off')

    # Add level labels
    for lvl in range(max_level + 1):
        ax1.text(-3.5, -lvl * 2, f'Forget {lvl}\nsymbols',
                 fontsize=9, ha='center', va='center',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Right: Equivalence class sizes
    ax2.set_title('Equivalence Classes by Forgetting Level', fontsize=13, fontweight='bold')

    # Generate all length-3 streams
    from itertools import product as iter_product
    streams = list(iter_product(alphabet, repeat=3))

    bar_data = []
    labels = []
    for s in sorted(subsets, key=lambda x: (len(x), sorted(x))):
        # Count equivalence classes
        class_map = {}
        for stream in streams:
            key = selective_forget(stream, s)
            if key not in class_map:
                class_map[key] = 0
            class_map[key] += 1

        n_classes = len(class_map)
        max_class = max(class_map.values())
        bar_data.append((n_classes, max_class))
        label = '{' + ','.join(sorted(s)) + '}' if s else '∅'
        labels.append(label)

    x = np.arange(len(labels))
    n_classes = [d[0] for d in bar_data]
    max_sizes = [d[1] for d in bar_data]

    bars1 = ax2.bar(x - 0.2, n_classes, 0.4, label='# equivalence classes',
                    color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x + 0.2, max_sizes, 0.4, label='Largest class size',
                    color='#e74c3c', alpha=0.8)

    ax2.set_xlabel('Forgetting set', fontsize=11)
    ax2.set_ylabel('Count', fontsize=11)
    ax2.set_xticks(x)
    ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_forgetting_lattice.png', dpi=150)
    plt.close()
    print("Saved viz_forgetting_lattice.png")


if __name__ == '__main__':
    main()
