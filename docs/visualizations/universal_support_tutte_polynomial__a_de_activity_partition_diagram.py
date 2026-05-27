#!/usr/bin/env python3
"""
Visualization: Activity Partition Diagram

Visualizes the activity partition theorem: for any M-convex support and
ground set, coordinates partition into loops, ordinary elements, and
trivial elements. Shows this partition across multiple supports.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, List

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]


def classify_coord(S: Support, i: int) -> str:
    """Classify coordinate i as 'loop', 'ordinary', or 'trivial'."""
    if not S:
        return 'trivial'
    has_zero = any(v[i] == 0 for v in S)
    has_pos = any(v[i] > 0 for v in S)
    if has_pos and not has_zero:
        return 'loop'
    elif has_zero and has_pos:
        return 'ordinary'
    else:
        return 'trivial'


def simplex_points(n: int, d: int) -> Support:
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


def count_activities(S: Support, n_coords: int) -> dict:
    counts = {'loop': 0, 'ordinary': 0, 'trivial': 0}
    for i in range(n_coords):
        c = classify_coord(S, i)
        counts[c] += 1
    return counts


# Generate data for various supports
n_vars = 4
supports = []
labels = []

# Simplex supports
for d in range(1, 7):
    S = simplex_points(n_vars, d)
    supports.append(S)
    labels.append(f'Δ({n_vars},{d})\n|S|={len(S)}')

# Vertex-only supports
for d in range(1, 4):
    verts = set()
    for i in range(n_vars):
        v = [0] * n_vars
        v[i] = d
        verts.add(tuple(v))
    S = frozenset(verts)
    supports.append(S)
    labels.append(f'V({n_vars},{d})\n|S|={len(S)}')

# Matroid supports
mat_bases = frozenset({(1,1,0,0), (1,0,1,0), (1,0,0,1),
                       (0,1,1,0), (0,1,0,1), (0,0,1,1)})
supports.append(mat_bases)
labels.append(f'U(2,4)\n|S|=6')

# Compute activities
loop_counts = []
ord_counts = []
triv_counts = []

for S in supports:
    acts = count_activities(S, n_vars)
    loop_counts.append(acts['loop'])
    ord_counts.append(acts['ordinary'])
    triv_counts.append(acts['trivial'])

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Stacked bar chart
ax1 = axes[0]
x = np.arange(len(supports))
width = 0.6

bars_triv = ax1.bar(x, triv_counts, width, label='Trivial', color='#95a5a6', alpha=0.8)
bars_ord = ax1.bar(x, ord_counts, width, bottom=triv_counts,
                   label='Ordinary', color='#3498db', alpha=0.8)
bars_loop = ax1.bar(x, loop_counts, width,
                    bottom=[t + o for t, o in zip(triv_counts, ord_counts)],
                    label='Loop', color='#e74c3c', alpha=0.8)

ax1.set_xlabel('Support', fontsize=11)
ax1.set_ylabel('Number of Coordinates', fontsize=11)
ax1.set_title('Activity Partition of Coordinates\n(Verified: loops + ordinary + trivial = n)', fontsize=13)
ax1.set_xticks(x)
ax1.set_xticklabels(labels, fontsize=8)
ax1.legend(fontsize=10)
ax1.axhline(y=n_vars, color='k', linewidth=0.5, linestyle='--', alpha=0.5)
ax1.set_ylim(0, n_vars + 0.5)

# Verification check
for idx in range(len(supports)):
    total = loop_counts[idx] + ord_counts[idx] + triv_counts[idx]
    color = 'green' if total == n_vars else 'red'
    ax1.annotate(f'Σ={total}', (x[idx], n_vars + 0.1), ha='center', fontsize=7, color=color)

# Pie chart for a specific support
ax2 = axes[1]
S_example = simplex_points(n_vars, 3)
acts_example = count_activities(S_example, n_vars)

sizes = [acts_example['loop'], acts_example['ordinary'], acts_example['trivial']]
colors_pie = ['#e74c3c', '#3498db', '#95a5a6']
labels_pie = [f'Loops ({sizes[0]})', f'Ordinary ({sizes[1]})', f'Trivial ({sizes[2]})']

# Filter out zeros
non_zero = [(s, c, l) for s, c, l in zip(sizes, colors_pie, labels_pie) if s > 0]
if non_zero:
    sizes_nz, colors_nz, labels_nz = zip(*non_zero)
    wedges, texts, autotexts = ax2.pie(sizes_nz, labels=labels_nz, colors=colors_nz,
                                        autopct='%1.0f%%', startangle=90,
                                        textprops={'fontsize': 11})
    for autotext in autotexts:
        autotext.set_fontweight('bold')

ax2.set_title(f'Activity Partition for Δ({n_vars},3)\n{n_vars} coordinates, |S|={len(S_example)} elements',
              fontsize=13)

plt.tight_layout()
plt.savefig('activity_diagram.png', dpi=150, bbox_inches='tight')
print("Saved activity_diagram.png")
