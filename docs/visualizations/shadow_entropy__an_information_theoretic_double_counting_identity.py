#!/usr/bin/env python3
"""
Visualization: Double-Counting Identity and Shadow Incidence

Visualizes the formally verified double-counting theorem:
  ∑_{m∈S} d↓(m) = ∑_{u∈Sh₁(S)} |{i : u+eᵢ ∈ S}|

This identity connects:
- Left side: "energy" of the ensemble (removable excitation quanta)
- Right side: "accessibility" of shadow states (raising operators)

Shows the bipartite incidence structure between S and Sh₁(S).
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from typing import Tuple, FrozenSet, List

Monomial = Tuple[int, ...]
SupportFamily = FrozenSet[Monomial]

def sub_monomial_at(m, i):
    if m[i] <= 0:
        return None
    return tuple(m[j] - (1 if j == i else 0) for j in range(len(m)))

def add_monomial_at(m, i):
    return tuple(m[j] + (1 if j == i else 0) for j in range(len(m)))

def one_shadow(S):
    if not S:
        return frozenset()
    n = len(next(iter(S)))
    shadow = set()
    for m in S:
        for i in range(n):
            u = sub_monomial_at(m, i)
            if u is not None:
                shadow.add(u)
    return frozenset(shadow)

def down_degree(m):
    return sum(1 for x in m if x > 0)

def unshadow_choices(S, u):
    n = len(u)
    return [i for i in range(n) if add_monomial_at(u, i) in S]


# ═══════════════════════════════════════════════════════════════
# FIGURE: Double-counting identity visualization
# ═══════════════════════════════════════════════════════════════

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Double-Counting Identity: Shadow Incidence Structure', 
             fontsize=14, fontweight='bold')

# ─── Example families to visualize ───
n = 3
families = [
    ("All degree-1 monomials\n{(1,0,0), (0,1,0), (0,0,1)}",
     frozenset([(1,0,0), (0,1,0), (0,0,1)])),
    ("Mixed degrees\n{(2,0,0), (1,1,0), (0,1,1), (0,0,2)}",
     frozenset([(2,0,0), (1,1,0), (0,1,1), (0,0,2)])),
    ("Higher degree\n{(2,1,0), (1,2,0), (0,1,2), (1,0,2)}",
     frozenset([(2,1,0), (1,2,0), (0,1,2), (1,0,2)])),
]

for idx, (name, S) in enumerate(families):
    ax = axes[idx]
    sh = one_shadow(S)
    S_list = sorted(S)
    sh_list = sorted(sh)
    
    # Compute edge set
    edges = []
    for mi, m in enumerate(S_list):
        for i in range(n):
            u = sub_monomial_at(m, i)
            if u is not None and u in sh:
                ui = sh_list.index(u)
                edges.append((mi, ui, i))
    
    # Draw bipartite graph
    y_s = np.linspace(0, 1, len(S_list))
    y_sh = np.linspace(0, 1, len(sh_list))
    
    # Draw edges with color based on coordinate
    coord_colors = ['#e74c3c', '#2ecc71', '#3498db']
    coord_labels = ['x₀', 'x₁', 'x₂']
    
    drawn_labels = set()
    for mi, ui, i in edges:
        label = coord_labels[i] if i not in drawn_labels else None
        drawn_labels.add(i)
        ax.plot([0, 1], [y_s[mi], y_sh[ui]], color=coord_colors[i],
                alpha=0.6, linewidth=1.5, label=label)
    
    # Draw nodes
    for mi, m in enumerate(S_list):
        dd = down_degree(m)
        ax.scatter([0], [y_s[mi]], s=100, c='steelblue', zorder=5, edgecolors='black')
        ax.annotate(str(m), (0, y_s[mi]), textcoords="offset points",
                   xytext=(-60, 0), ha='right', fontsize=8,
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='lightblue', alpha=0.7))
        ax.annotate(f'd↓={dd}', (0, y_s[mi]), textcoords="offset points",
                   xytext=(-60, -12), ha='right', fontsize=7, color='navy')
    
    for ui, u in enumerate(sh_list):
        uc = len(unshadow_choices(S, u))
        ax.scatter([1], [y_sh[ui]], s=100, c='coral', zorder=5, edgecolors='black')
        ax.annotate(str(u), (1, y_sh[ui]), textcoords="offset points",
                   xytext=(10, 0), ha='left', fontsize=8,
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', alpha=0.7))
        ax.annotate(f'↑{uc}', (1, y_sh[ui]), textcoords="offset points",
                   xytext=(10, -12), ha='left', fontsize=7, color='darkred')
    
    # Compute sums
    left_sum = sum(down_degree(m) for m in S)
    right_sum = sum(len(unshadow_choices(S, u)) for u in sh)
    
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.1, 1.1)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['S (monomials)', 'Sh₁(S) (shadow)'], fontsize=10)
    ax.set_yticks([])
    ax.set_title(f'{name}\n∑d↓={left_sum} = ∑↑={right_sum} ✓', fontsize=10)
    
    if idx == 0:
        ax.legend(loc='lower center', fontsize=8, ncol=3)

plt.tight_layout()
plt.savefig('double_counting_identity.png', dpi=150, bbox_inches='tight')
print("Saved: double_counting_identity.png")
