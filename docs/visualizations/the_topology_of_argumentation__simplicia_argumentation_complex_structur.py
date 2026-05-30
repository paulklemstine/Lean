"""
Visualization: The Argumentation Complex
==========================================
Visualizes the simplicial complex of conflict-free sets for several
argumentation frameworks, showing how the topological structure captures
the "shape" of a debate.

Uses matplotlib to create a comparison of attack graphs alongside their
argumentation complexes, rendered as set diagrams.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def conflict_free_sets(self):
        args = sorted(self.arguments, key=str)
        result = [frozenset()]
        for r in range(1, len(args) + 1):
            for sub in combinations(args, r):
                S = frozenset(sub)
                if self.is_conflict_free(S):
                    result.append(S)
        return result

    def euler_char(self):
        chi = 0
        for S in self.conflict_free_sets():
            if len(S) > 0:
                chi += (-1) ** (len(S) - 1)
        return chi


def draw_attack_graph(ax, args, attacks, title, positions):
    """Draw the attack graph with arrows."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')

    # Draw attacks as arrows
    for a, b in attacks:
        xa, ya = positions[a]
        xb, yb = positions[b]
        dx, dy = xb - xa, yb - ya
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            # Shorten arrow
            shrink = 0.25
            ax.annotate("", xy=(xb - shrink * dx / dist, yb - shrink * dy / dist),
                        xytext=(xa + shrink * dx / dist, ya + shrink * dy / dist),
                        arrowprops=dict(arrowstyle="->", color="red",
                                       lw=1.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for arg in args:
        x, y = positions[arg]
        circle = plt.Circle((x, y), 0.2, color='#4ECDC4', ec='#2C3E50', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(arg), ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=6)


def draw_complex_bars(ax, af, title):
    """Draw a bar chart of the f-vector (face counts by dimension)."""
    cf = af.conflict_free_sets()
    max_dim = max((len(S) for S in cf), default=0)
    f_vec = [0] * (max_dim + 1)
    for S in cf:
        f_vec[len(S)] += 1

    dims = list(range(len(f_vec)))
    colors = ['#2C3E50', '#E74C3C', '#3498DB', '#2ECC71', '#9B59B6']

    bars = ax.bar(dims, f_vec, color=[colors[i % len(colors)] for i in dims],
                  edgecolor='white', linewidth=1.5)
    ax.set_xlabel('Dimension k', fontsize=10)
    ax.set_ylabel('Face count f_k', fontsize=10)
    ax.set_title(f'{title}\nχ = {af.euler_char()}', fontsize=11, fontweight='bold')
    ax.set_xticks(dims)
    ax.set_xticklabels([f'{d}' for d in dims])

    # Add value labels
    for bar, val in zip(bars, f_vec):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                    str(val), ha='center', va='bottom', fontsize=9, fontweight='bold')


# Create figure with 3 examples
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('The Argumentation Complex: Topology of Debates',
             fontsize=16, fontweight='bold', y=0.98)

# Example 1: Linear chain a→b→c
args1 = ['a', 'b', 'c']
attacks1 = [('a', 'b'), ('b', 'c')]
pos1 = {'a': (-1, 0), 'b': (0, 0), 'c': (1, 0)}
AF1 = ArgFramework(args1, attacks1)

draw_attack_graph(axes[0, 0], args1, attacks1, 'Linear: a→b→c', pos1)
draw_complex_bars(axes[1, 0], AF1, 'Linear Complex')

# Example 2: 3-cycle a→b→c→a
args2 = ['a', 'b', 'c']
attacks2 = [('a', 'b'), ('b', 'c'), ('c', 'a')]
pos2 = {'a': (0, 1), 'b': (-0.87, -0.5), 'c': (0.87, -0.5)}
AF2 = ArgFramework(args2, attacks2)

draw_attack_graph(axes[0, 1], args2, attacks2, 'Cycle: a→b→c→a', pos2)
draw_complex_bars(axes[1, 1], AF2, 'Cycle Complex')

# Example 3: Complete graph K4
args3 = [1, 2, 3, 4]
attacks3 = [(a, b) for a in args3 for b in args3 if a != b]
angle = np.pi / 4
pos3 = {i: (np.cos(angle + i * np.pi / 2), np.sin(angle + i * np.pi / 2)) for i in args3}
AF3 = ArgFramework(args3, attacks3)

draw_attack_graph(axes[0, 2], args3, attacks3, 'Complete: K₄', pos3)
draw_complex_bars(axes[1, 2], AF3, 'Complete Complex')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('argumentation_complex.png', dpi=150, bbox_inches='tight')
print("Saved: argumentation_complex.png")
