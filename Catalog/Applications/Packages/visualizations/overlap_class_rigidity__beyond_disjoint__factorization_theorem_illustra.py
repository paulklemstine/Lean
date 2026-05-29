"""
Visualization: Componentwise Factorization Theorem

Illustrates the key theorem that supports from different overlap classes
have disjoint unions — the factorization of support families into
independent interaction sectors.

This script is fully self-contained — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, FrozenSet, Dict, Set
import math


# ---- Inline algorithms ----

def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    return len(A & B) > 0

def overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    n = len(family)
    if n == 0: return []
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i+1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j); adj[j].add(i)
    visited = [False]*n; comps = []
    for s in range(n):
        if visited[s]: continue
        comp = []; q = [s]; visited[s] = True
        while q:
            nd = q.pop(0); comp.append(nd)
            for nb in sorted(adj[nd]):
                if not visited[nb]: visited[nb] = True; q.append(nb)
        comps.append(sorted(comp))
    return comps


# ---- Main visualization ----

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Factorization Theorem: Independent Interaction Sectors',
             fontsize=16, fontweight='bold', y=1.02)

# Color palette for classes
class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

# Example family with 3 overlap classes
family = [
    frozenset({1, 2, 3}),      # Class 0: indices 0, 1
    frozenset({3, 4, 5}),      # Class 0
    frozenset({10, 11, 12}),   # Class 1: indices 2, 3
    frozenset({12, 13, 14}),   # Class 1
    frozenset({20, 21}),       # Class 2: index 4
]

classes = overlap_classes(family)

# Panel 1: Support family with overlap graph
ax1 = axes[0]
ax1.set_title('Support Family\nwith Overlap Graph', fontsize=13, fontweight='bold')

# Draw supports as sets on a number line
all_elems = sorted(set().union(*family))
elem_pos = {e: i for i, e in enumerate(all_elems)}

class_map = {}
for ci, cls in enumerate(classes):
    for idx in cls:
        class_map[idx] = ci

for si, supp in enumerate(family):
    ci = class_map[si]
    color = class_colors[ci]
    y = -si * 1.2
    elems = sorted(supp)
    xs = [elem_pos[e] for e in elems]

    # Draw support as a bracket
    xmin, xmax = min(xs) - 0.3, max(xs) + 0.3
    rect = plt.Rectangle((xmin, y - 0.3), xmax - xmin, 0.6,
                          facecolor=color, alpha=0.3, edgecolor=color, linewidth=2)
    ax1.add_patch(rect)

    # Draw elements
    for e in elems:
        x = elem_pos[e]
        ax1.plot(x, y, 'o', color=color, markersize=8, zorder=5)
        ax1.text(x, y + 0.4, str(e), fontsize=7, ha='center', va='bottom')

    ax1.text(xmin - 0.5, y, f'S[{si}]', fontsize=9, ha='right', va='center',
             color=color, fontweight='bold')

# Draw overlap edges
for i in range(len(family)):
    for j in range(i+1, len(family)):
        if supports_overlap(family[i], family[j]):
            yi, yj = -i * 1.2, -j * 1.2
            shared = family[i] & family[j]
            for e in shared:
                x = elem_pos[e]
                ax1.plot([x, x], [yi, yj], '--', color='gray', linewidth=1.5, alpha=0.5)

ax1.set_xlim(-2, len(all_elems) + 1)
ax1.set_ylim(-len(family) * 1.2 - 1, 1.5)
ax1.axis('off')

# Panel 2: Overlap graph
ax2 = axes[1]
ax2.set_title('Overlap Graph\n(Connected Components = Classes)', fontsize=13, fontweight='bold')

n = len(family)
angles = [2 * math.pi * i / n - math.pi/2 for i in range(n)]
radius = 2.0
positions = [(radius * math.cos(a), radius * math.sin(a)) for a in angles]

# Draw edges
for i in range(n):
    for j in range(i+1, n):
        if supports_overlap(family[i], family[j]):
            xi, yi = positions[i]
            xj, yj = positions[j]
            ax2.plot([xi, xj], [yi, yj], color='#7f8c8d', linewidth=2, zorder=1)

# Draw nodes
for i in range(n):
    x, y = positions[i]
    ci = class_map[i]
    color = class_colors[ci]
    circle = plt.Circle((x, y), 0.35, facecolor=color,
                         edgecolor='black', linewidth=2, zorder=4)
    ax2.add_patch(circle)
    ax2.text(x, y, f'S{i}', fontsize=10, fontweight='bold',
             ha='center', va='center', color='white', zorder=5)

# Legend
for ci, cls in enumerate(classes):
    color = class_colors[ci]
    ax2.plot([], [], 's', color=color, markersize=10,
             label=f'Class {ci}: {cls}')
ax2.legend(loc='lower center', fontsize=9, ncol=len(classes))

ax2.set_xlim(-3.5, 3.5)
ax2.set_ylim(-3.5, 3.5)
ax2.set_aspect('equal')
ax2.axis('off')

# Panel 3: Factorization — disjoint class unions
ax3 = axes[2]
ax3.set_title('Factorization Theorem\nClass Unions are Disjoint', fontsize=13, fontweight='bold')

for ci, cls in enumerate(classes):
    color = class_colors[ci]
    union = set()
    for idx in cls:
        union |= family[idx]
    union = sorted(union)

    y = -ci * 2.0
    x_start = 0

    # Draw union as a bar
    bar_width = len(union) * 0.8
    rect = plt.Rectangle((x_start, y - 0.4), bar_width, 0.8,
                          facecolor=color, alpha=0.4, edgecolor=color, linewidth=2)
    ax3.add_patch(rect)

    # Draw elements
    for ei, e in enumerate(union):
        x = x_start + ei * 0.8 + 0.4
        ax3.plot(x, y, 'o', color=color, markersize=10, zorder=5)
        ax3.text(x, y, str(e), fontsize=7, ha='center', va='center',
                 color='white', fontweight='bold', zorder=6)

    ax3.text(x_start - 0.5, y, f'Class {ci}', fontsize=10, ha='right',
             va='center', color=color, fontweight='bold')
    ax3.text(x_start + bar_width + 0.3, y, f'|∪| = {len(union)}',
             fontsize=9, ha='left', va='center', color=color)

# Add disjointness annotation
if len(classes) > 1:
    for i in range(len(classes)):
        for j in range(i+1, len(classes)):
            yi, yj = -i * 2.0, -j * 2.0
            union_i = set()
            union_j = set()
            for idx in classes[i]: union_i |= family[idx]
            for idx in classes[j]: union_j |= family[idx]
            intersection = union_i & union_j
            mid_y = (yi + yj) / 2
            ax3.text(8, mid_y, f'∩ = ∅ ✓', fontsize=11,
                     ha='center', va='center', color='#27ae60',
                     fontweight='bold',
                     bbox=dict(boxstyle='round,pad=0.3',
                               facecolor='#d5f5e3', alpha=0.8))

ax3.set_xlim(-3, 12)
ax3.set_ylim(-len(classes) * 2.0 - 1, 1.5)
ax3.axis('off')

plt.tight_layout()
plt.savefig('factorization_theorem.png', dpi=150, bbox_inches='tight', facecolor='white')
print("Saved factorization_theorem.png")
