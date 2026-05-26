"""
Visualization: Overlap Complexity Measures

Plots how the three overlap complexity measures (max intersection size,
total overlap complexity, overlap pair count) vary as supports are
systematically shifted from disjoint to maximally overlapping.

Demonstrates the key theorem: all three measures are zero iff the
family is pairwise disjoint.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, FrozenSet


def max_intersection_size(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return max((len(family[i] & family[j]) for i in range(n) for j in range(i+1,n)), default=0)

def total_overlap_complexity(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(len(family[i] & family[j]) for i in range(n) for j in range(i+1,n))

def overlap_pair_count(family: List[FrozenSet[int]]) -> int:
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1,n) if len(family[i] & family[j]) > 0)

def pairwise_disjoint(family: List[FrozenSet[int]]) -> bool:
    n = len(family)
    return all(len(family[i] & family[j]) == 0 for i in range(n) for j in range(i+1,n))

from collections import defaultdict
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


# ====== Experiment: Sliding overlap ======
# Start with 4 disjoint supports of size 3, then progressively shift
# the second support to overlap with the first.

ground = list(range(20))
base_supports = [
    frozenset({0, 1, 2}),
    frozenset({3, 4, 5}),
    frozenset({6, 7, 8}),
    frozenset({9, 10, 11}),
]

# Shift amounts for support 1: replace elements from {3,4,5} with {0,1,2}
shift_steps = []
for shift in range(4):  # 0, 1, 2, 3 elements shifted
    new_s1 = frozenset(list(range(shift)) + list(range(3, 6 - shift)))
    family = [base_supports[0], new_s1, base_supports[2], base_supports[3]]
    shift_steps.append((shift, family))

# Also shift support 2 toward support 1
for shift in range(1, 4):
    new_s2 = frozenset(list(range(shift)) + list(range(6, 9 - shift)))
    family = [base_supports[0], frozenset({0, 1, 2}), new_s2, base_supports[3]]
    shift_steps.append((3 + shift, family))

shifts = [s[0] for s in shift_steps]
mis_vals = [max_intersection_size(s[1]) for s in shift_steps]
toc_vals = [total_overlap_complexity(s[1]) for s in shift_steps]
opc_vals = [overlap_pair_count(s[1]) for s in shift_steps]
cc_vals = [len(find_overlap_classes(s[1])) for s in shift_steps]
disj_vals = [pairwise_disjoint(s[1]) for s in shift_steps]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Overlap Complexity Measures vs. Overlap Degree', fontsize=15, fontweight='bold')

# Plot 1: Max Intersection Size
ax = axes[0][0]
ax.bar(shifts, mis_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Max Intersection Size')
ax.set_title('maxIntersectionSize(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 2: Total Overlap Complexity
ax = axes[0][1]
ax.bar(shifts, toc_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Total Overlap Complexity')
ax.set_title('totalOverlapComplexity(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 3: Overlap Pair Count
ax = axes[1][0]
ax.bar(shifts, opc_vals, color=['#2ecc71' if d else '#e74c3c' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Overlap Pair Count')
ax.set_title('overlapPairCount(F)')
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xticks(shifts)

# Plot 4: Overlap Class Count
ax = axes[1][1]
ax.bar(shifts, cc_vals, color=['#2ecc71' if d else '#3498db' for d in disj_vals],
       edgecolor='black', linewidth=0.5)
ax.set_xlabel('Overlap shift parameter')
ax.set_ylabel('Overlap Class Count')
ax.set_title('overlapClassCount(F)')
ax.axhline(y=len(base_supports), color='gray', linestyle='--', alpha=0.5,
           label=f'|family| = {len(base_supports)}')
ax.legend(fontsize=9)
ax.set_xticks(shifts)

# Add green/red legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2ecc71', label='Pairwise Disjoint'),
                   Patch(facecolor='#e74c3c', label='Has Overlap')]
fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig('viz_complexity_measures.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_measures.png")
