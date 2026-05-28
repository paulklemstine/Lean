#!/usr/bin/env python3
"""
Visualization 2: Anti-Cancellation and Aggregate Shadow

Visualizes the anti-cancellation property: for positive-coefficient polynomials
with positive weight matrices, the weighted Hessian support exactly equals
the aggregate shadow. Demonstrates this on K3 and K4 at various β values.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
import math


def powerset(s):
    s = list(s)
    return [frozenset(s[j] for j in range(len(s)) if i & (1 << j)) for i in range(2**len(s))]


def partition_coeffs(vertices, edges, J, beta):
    coeffs = {}
    for S in powerset(vertices):
        energy = sum(J.get((u,v), J.get((v,u), 0.0))
                     for u, v in edges
                     if (u in S and v in S) or (u not in S and v not in S))
        coeffs[S] = math.exp(beta * energy)
    return coeffs


def compute_shadow_and_support(vertices, edges, J, beta):
    coeffs = partition_coeffs(vertices, edges, J, beta)
    weight_matrix = {(i,j): 1.0 for i in vertices for j in vertices if i != j}

    shadow = set()
    hessian_coeffs = {}

    for i in vertices:
        for j in vertices:
            if i == j:
                continue
            for S, w in coeffs.items():
                if i in S and j in S:
                    key = S - {i, j}
                    shadow.add(key)
                    hessian_coeffs[key] = hessian_coeffs.get(key, 0.0) + w

    support = {k for k, v in hessian_coeffs.items() if abs(v) > 1e-12}
    return shadow, support, hessian_coeffs


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# K3 examples
vertices3 = [0, 1, 2]
edges3 = [(0,1), (0,2), (1,2)]
J3 = {e: 1.0 for e in edges3}

for col, beta in enumerate([0.0, 0.5, 1.5]):
    ax = axes[0, col]
    shadow, support, hcoeffs = compute_shadow_and_support(vertices3, edges3, J3, beta)

    # All possible subsets (for K3, reduced subsets after removing 2 vertices)
    all_subsets = sorted(powerset(vertices3), key=lambda s: (len(s), tuple(sorted(s))))

    y_pos = list(range(len(all_subsets)))
    colors = []
    labels = []

    for S in all_subsets:
        label = '{' + ','.join(str(x) for x in sorted(S)) + '}' if S else '∅'
        labels.append(label)
        in_shadow = S in shadow
        in_support = S in support
        if in_shadow and in_support:
            colors.append('#2ecc71')  # green = both
        elif in_shadow:
            colors.append('#e74c3c')  # red = shadow only (cancellation!)
        elif in_support:
            colors.append('#3498db')  # blue = support only
        else:
            colors.append('#ecf0f1')  # gray = neither

    bars = ax.barh(y_pos, [hcoeffs.get(S, 0) for S in all_subsets],
                   color=colors, edgecolor='black', linewidth=0.5)

    ax.set_yticks(y_pos)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel('Hessian coefficient', fontsize=10)
    ax.set_title(f'K₃, β = {beta}', fontsize=12, fontweight='bold')

    match = shadow == support
    ax.text(0.95, 0.95, f'Anti-cancel: {"✓" if match else "✗"}',
            transform=ax.transAxes, ha='right', va='top', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightgreen' if match else 'lightyellow'))

# K4 examples
vertices4 = [0, 1, 2, 3]
edges4 = list(combinations(range(4), 2))
J4 = {e: 1.0 for e in edges4}

for col, beta in enumerate([0.0, 0.3, 1.0]):
    ax = axes[1, col]
    shadow, support, hcoeffs = compute_shadow_and_support(vertices4, edges4, J4, beta)

    all_subsets = sorted(powerset(vertices4), key=lambda s: (len(s), tuple(sorted(s))))

    y_pos = list(range(len(all_subsets)))
    colors = []
    labels = []

    for S in all_subsets:
        label = '{' + ','.join(str(x) for x in sorted(S)) + '}' if S else '∅'
        labels.append(label)
        in_shadow = S in shadow
        in_support = S in support
        if in_shadow and in_support:
            colors.append('#2ecc71')
        elif in_shadow:
            colors.append('#e74c3c')
        elif in_support:
            colors.append('#3498db')
        else:
            colors.append('#ecf0f1')

    bars = ax.barh(y_pos, [hcoeffs.get(S, 0) for S in all_subsets],
                   color=colors, edgecolor='black', linewidth=0.5)

    ax.set_yticks(y_pos)
    ax.set_yticklabels(labels, fontsize=7)
    ax.set_xlabel('Hessian coefficient', fontsize=10)
    ax.set_title(f'K₄, β = {beta}', fontsize=12, fontweight='bold')

    match = shadow == support
    ax.text(0.95, 0.95, f'Anti-cancel: {"✓" if match else "✗"}',
            transform=ax.transAxes, ha='right', va='top', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightgreen' if match else 'lightyellow'))

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='In shadow ∩ support'),
    mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='In shadow only (cancellation!)'),
    mpatches.Patch(facecolor='#ecf0f1', edgecolor='black', label='Neither'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Anti-Cancellation: Aggregate Shadow = Weighted Hessian Support',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig('viz_anticancellation.png', dpi=150, bbox_inches='tight')
print("Saved viz_anticancellation.png")
