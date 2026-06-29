import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations

def visualize_closure_lattice():
    """Visualize the closure lattice for a simple database dependency example."""
    universe = ["A", "B", "C", "D", "E"]
    rules = [
        (frozenset({"A"}), "B"),
        (frozenset({"B", "C"}), "D"),
        (frozenset({"A", "C"}), "E"),
    ]

    def closure(seed):
        current = set(seed)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        return frozenset(current)

    # Compute all closed sets
    closed_sets = set()
    for size in range(len(universe) + 1):
        for combo in combinations(universe, size):
            cl = closure(frozenset(combo))
            closed_sets.add(cl)

    closed_list = sorted(closed_sets, key=lambda s: (len(s), sorted(s)))

    # Assign y-positions by size
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    positions = {}
    by_level = {}
    for s in closed_list:
        level = len(s)
        by_level.setdefault(level, []).append(s)

    for level, sets in by_level.items():
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n - 1) / 2) * 2.5
            positions[s] = (x, level * 1.8)

    # Draw edges (Hasse diagram)
    for s1 in closed_list:
        for s2 in closed_list:
            if s1 < s2 and len(s2) == len(s1) + 1:
                if not any(s1 < s3 < s2 for s3 in closed_list):
                    x1, y1 = positions[s1]
                    x2, y2 = positions[s2]
                    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for s in closed_list:
        x, y = positions[s]
        label = "{" + ", ".join(sorted(s)) + "}" if s else "{}"
        ax.plot(x, y, 'o', markersize=20, color='#4A90D9', zorder=5)
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
                fontweight='bold', color='white', zorder=6)

    ax.set_title('Lattice of Closed Sets
(Database Dependencies: A→B, BC→D, AC→E)',
                 fontsize=14, fontweight='bold')
    ax.set_xlim(-8, 8)
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('closure_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved closure_lattice.png")

visualize_closure_lattice()
