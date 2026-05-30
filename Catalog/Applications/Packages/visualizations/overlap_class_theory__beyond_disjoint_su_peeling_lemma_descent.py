#!/usr/bin/env python3
"""
Visualization 2: Peeling Lemma — Complexity Descent
====================================================
Visualizes how the peeling operation (removing shared elements)
strictly reduces overlap complexity at each step, demonstrating
the well-founded descent that drives the inductive argument.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import List, Set


def overlap_complexity(supports: List[Set[int]]) -> int:
    return sum(len(supports[i] & supports[j])
               for i, j in combinations(range(len(supports)), 2))


def peel_step(supports: List[Set[int]]) -> tuple:
    """Find and remove one shared element. Returns (new_supports, element, index) or None."""
    for i, j in combinations(range(len(supports)), 2):
        shared = supports[i] & supports[j]
        if shared:
            elem = min(shared)
            new_supports = [s.copy() for s in supports]
            new_supports[i].discard(elem)
            return new_supports, elem, i
    return None


def full_peeling(supports: List[Set[int]]) -> List[tuple]:
    """Peel until disjoint, recording each step."""
    history = [(supports, overlap_complexity(supports), None, None)]
    current = [s.copy() for s in supports]
    while True:
        result = peel_step(current)
        if result is None:
            break
        current, elem, idx = result
        c = overlap_complexity(current)
        history.append(([s.copy() for s in current], c, elem, idx))
    return history


# Two examples
examples = [
    ("Dense Overlap",
     [{1, 2, 3, 4, 5}, {3, 4, 5, 6, 7}, {5, 6, 7, 8, 9}]),
    ("Light Overlap",
     [{1, 2, 3}, {3, 4, 5}, {6, 7, 8}, {8, 9, 10}]),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax_idx, (title, initial_supports) in enumerate(examples):
    ax = axes[ax_idx]
    history = full_peeling(initial_supports)

    steps = list(range(len(history)))
    complexities = [h[1] for h in history]

    # Main plot: complexity descent
    ax.plot(steps, complexities, 'o-', color='#E74C3C', linewidth=2.5,
            markersize=10, markerfacecolor='white', markeredgewidth=2.5,
            zorder=3)

    # Fill area under curve
    ax.fill_between(steps, complexities, alpha=0.15, color='#E74C3C')

    # Annotate each step
    for i, (supp, c, elem, idx) in enumerate(history):
        if i == 0:
            label = "Initial"
        else:
            label = f"Peel {elem} from F{idx}"
        ax.annotate(label, (i, c), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=7,
                   color='#2C3E50', fontweight='bold')

    # Mark the zero line
    ax.axhline(y=0, color='#2ECC71', linewidth=2, linestyle='--',
               label='Disjoint (complexity = 0)')

    ax.set_xlabel('Peeling Step', fontsize=12)
    ax.set_ylabel('Overlap Complexity', fontsize=12)
    ax.set_title(f'{title}\n{len(initial_supports)} supports',
                fontsize=13, fontweight='bold')
    ax.set_xticks(steps)
    ax.set_ylim(-0.5, max(complexities) * 1.3)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)

    # Show initial and final states
    text_y = max(complexities) * 1.15
    initial_str = ', '.join(str(sorted(s)) for s in initial_supports)
    ax.text(0, text_y, f'Start: {initial_str}', fontsize=7,
            color='#7F8C8D', va='top')

fig.suptitle('Peeling Lemma: Strict Complexity Descent',
            fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_peeling.png', dpi=150, bbox_inches='tight')
print("Saved viz_peeling.png")
