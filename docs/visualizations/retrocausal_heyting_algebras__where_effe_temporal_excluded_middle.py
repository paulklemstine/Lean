#!/usr/bin/env python3
"""Visualization: Temporal excluded middle vs propositional LEM failure."""
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# Setup: Galois connection on P({0,1,2})
universe = frozenset({0, 1, 2})
subsets = []
for r in range(4):
    for combo in combinations(range(3), r):
        subsets.append(frozenset(combo))

def T(S):
    return frozenset(x for x in universe if any(x <= y for y in S))

def R(S):
    return frozenset(x for x in universe if all(y in S for y in universe if y <= x))

def box(S):
    return R(T(S))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# 1. Temporal EM: show R(T(S)) ∪ R(T(Sᶜ)) = U for all S
ax = axes[0]
ax.set_title("Temporal Excluded Middle\n□S ∪ □Sᶜ = U always holds", fontsize=12, fontweight='bold')

data = []
for i, S in enumerate(subsets):
    Sc = universe - S
    bS = box(S)
    bSc = box(Sc)
    union = bS | bSc
    data.append((str(set(S) if S else '∅'), len(bS), len(bSc), len(union)))

labels = [d[0] for d in data]
box_s = [d[1] for d in data]
box_sc = [d[2] for d in data]
unions = [d[3] for d in data]

x = np.arange(len(labels))
width = 0.25
ax.bar(x - width, box_s, width, label='|□S|', color='#3498db', alpha=0.7)
ax.bar(x, box_sc, width, label='|□Sᶜ|', color='#e74c3c', alpha=0.7)
ax.bar(x + width, unions, width, label='|□S ∪ □Sᶜ|', color='#27ae60', alpha=0.7)
ax.axhline(y=3, color='gray', linestyle='--', alpha=0.5, label='|U| = 3')
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax.set_ylabel('Set size')
ax.legend(fontsize=9)

# 2. Fixed points and the nucleus
ax = axes[1]
ax.set_title("Nucleus Fixed Points\n□S = S (temporally stable propositions)", fontsize=12, fontweight='bold')

fixed = [(str(set(S) if S else '∅'), S == box(S)) for S in subsets]
colors = ['#27ae60' if f else '#e74c3c' for _, f in fixed]
bars = ax.barh(range(len(fixed)), [1]*len(fixed), color=colors, alpha=0.7, edgecolor='black')

ax.set_yticks(range(len(fixed)))
ax.set_yticklabels([f[0] for f in fixed], fontsize=9)
ax.set_xticks([])

legend_elements = [
    plt.Rectangle((0,0), 1, 1, facecolor='#27ae60', alpha=0.7, edgecolor='black', label='Fixed (□S = S)'),
    plt.Rectangle((0,0), 1, 1, facecolor='#e74c3c', alpha=0.7, edgecolor='black', label='Not fixed (□S ≠ S)')
]
ax.legend(handles=legend_elements, fontsize=9)

plt.tight_layout()
plt.savefig('temporal_em.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: temporal_em.png")
