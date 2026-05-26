"""
Visualization: Element Nerve Heatmap

Shows the element nerve as a heatmap: rows are supports (indexed by i),
columns are elements of the ground set, and cells are colored if element x
belongs to support F(i). Highlights shared elements that create overlap.

Demonstrates the theorem: F(i) ∩ F(j) is nonempty iff there exists x
with both i and j in the nerve of x.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, FrozenSet, Dict, Set
from collections import defaultdict


def element_nerve(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    nerve: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for x in s:
            nerve[x].add(i)
    return dict(nerve)

def find_overlap_classes(family):
    n = len(family)
    if n == 0: return []
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


# ====== Example family ======
family = [
    frozenset({0, 1, 2}),       # S₀
    frozenset({2, 3, 4}),       # S₁ (overlaps S₀ at 2)
    frozenset({4, 5, 6}),       # S₂ (overlaps S₁ at 4)
    frozenset({8, 9, 10}),      # S₃ (isolated)
    frozenset({10, 11, 12}),    # S₄ (overlaps S₃ at 10)
    frozenset({15, 16, 17}),    # S₅ (isolated singleton class)
]

support_labels = [f'S{i} = {{{",".join(map(str,sorted(s)))}}}' for i, s in enumerate(family)]

# Ground set elements
all_elements = sorted(set().union(*family))
n_supports = len(family)
n_elements = len(all_elements)
elem_to_col = {e: i for i, e in enumerate(all_elements)}

# Build membership matrix
matrix = np.zeros((n_supports, n_elements))
for i, s in enumerate(family):
    for x in s:
        matrix[i, elem_to_col[x]] = 1

# Identify shared elements (those in 2+ supports)
nerve = element_nerve(family)
shared_elements = {x for x, idxs in nerve.items() if len(idxs) > 1}

# Build color matrix: 0=empty, 1=exclusive, 2=shared
color_matrix = np.zeros((n_supports, n_elements))
for i, s in enumerate(family):
    for x in s:
        col = elem_to_col[x]
        if x in shared_elements:
            color_matrix[i, col] = 2  # shared
        else:
            color_matrix[i, col] = 1  # exclusive

# Find overlap classes for coloring
classes = find_overlap_classes(family)
class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
class_map = {}
for ci, cls in enumerate(classes):
    for idx in cls:
        class_map[idx] = ci

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6),
                                 gridspec_kw={'width_ratios': [3, 1]})
fig.suptitle('Element Nerve: Support Membership Heatmap', fontsize=14, fontweight='bold')

# ---- Left: Heatmap ----
from matplotlib.colors import ListedColormap
cmap = ListedColormap(['white', '#a8d8ea', '#ff6f61'])

im = ax1.imshow(color_matrix, cmap=cmap, aspect='auto', interpolation='nearest')

ax1.set_xticks(range(n_elements))
ax1.set_xticklabels([str(e) for e in all_elements], fontsize=9)
ax1.set_yticks(range(n_supports))
ax1.set_yticklabels(support_labels, fontsize=9)
ax1.set_xlabel('Ground Set Elements', fontsize=11)
ax1.set_ylabel('Supports', fontsize=11)

# Highlight shared columns
for x in shared_elements:
    col = elem_to_col[x]
    ax1.axvline(x=col - 0.5, color='red', linewidth=0.5, alpha=0.3)
    ax1.axvline(x=col + 0.5, color='red', linewidth=0.5, alpha=0.3)

# Color the y-axis labels by class
for i, label in enumerate(ax1.get_yticklabels()):
    label.set_color(class_colors[class_map[i] % len(class_colors)])
    label.set_fontweight('bold')

# Add grid
ax1.set_xticks(np.arange(-0.5, n_elements, 1), minor=True)
ax1.set_yticks(np.arange(-0.5, n_supports, 1), minor=True)
ax1.grid(which='minor', color='gray', linewidth=0.3)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='white', edgecolor='gray', label='Not in support'),
    Patch(facecolor='#a8d8ea', label='Exclusive to one support'),
    Patch(facecolor='#ff6f61', label='Shared (creates overlap)'),
]
ax1.legend(handles=legend_elements, loc='upper right', fontsize=8)

# ---- Right: Overlap class summary ----
ax2.axis('off')
ax2.set_title('Overlap Classes', fontsize=12, fontweight='bold')

y = 0.9
for ci, cls in enumerate(classes):
    color = class_colors[ci % len(class_colors)]
    members = [f'S{i}' for i in cls]
    ax2.text(0.1, y, f'Class {ci}:', fontsize=11, fontweight='bold',
             color=color, transform=ax2.transAxes)
    ax2.text(0.1, y - 0.06, f'  {", ".join(members)}', fontsize=10,
             color=color, transform=ax2.transAxes)

    # Find shared elements within class
    shared_in_class = set()
    for a in cls:
        for b in cls:
            if a < b:
                shared_in_class |= family[a] & family[b]
    if shared_in_class:
        ax2.text(0.1, y - 0.12, f'  Shared: {sorted(shared_in_class)}',
                 fontsize=9, color='gray', transform=ax2.transAxes)
        y -= 0.22
    else:
        y -= 0.16

ax2.text(0.1, y - 0.05, f'Total classes: {len(classes)}',
         fontsize=11, fontweight='bold', transform=ax2.transAxes)
ax2.text(0.1, y - 0.12, f'Total supports: {n_supports}',
         fontsize=10, transform=ax2.transAxes)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_element_nerve.png', dpi=150, bbox_inches='tight')
print("Saved viz_element_nerve.png")
