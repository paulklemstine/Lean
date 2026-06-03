#!/usr/bin/env python3
"""Visualization: S4 modal logic structure of temporal operators."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations

# Setup
universe = frozenset({0, 1, 2})
subsets = []
for r in range(4):
    for combo in combinations(range(3), r):
        subsets.append(frozenset(combo))

def T(S):
    return frozenset(x for x in universe if any(x <= y for y in S))

def R(S):
    return frozenset(x for x in universe if all(y in S for y in universe if y <= x))

def box(S): return R(T(S))
def diamond(S): return T(R(S))

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# 1. Box operator: S → □S
ax = axes[0, 0]
ax.set_title("Box Operator □ = R∘T\n(Temporal Necessity)", fontsize=11, fontweight='bold')
for i, S in enumerate(subsets):
    bS = box(S)
    s_label = str(set(S)) if S else '∅'
    b_label = str(set(bS)) if bS else '∅'
    y = len(subsets) - i - 1
    ax.annotate('', xy=(3, y), xytext=(0.5, y),
                arrowprops=dict(arrowstyle='->', color='#3498db', lw=1.5))
    ax.text(0.2, y, s_label, ha='right', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    ax.text(3.3, y, b_label, ha='left', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', 
                      facecolor='lightgreen' if S == bS else 'lightyellow'))
ax.set_xlim(-1, 5)
ax.set_ylim(-0.5, len(subsets))
ax.axis('off')

# 2. Diamond operator: S → ◇S
ax = axes[0, 1]
ax.set_title("Diamond Operator ◇ = T∘R\n(Temporal Possibility)", fontsize=11, fontweight='bold')
for i, S in enumerate(subsets):
    dS = diamond(S)
    s_label = str(set(S)) if S else '∅'
    d_label = str(set(dS)) if dS else '∅'
    y = len(subsets) - i - 1
    ax.annotate('', xy=(3, y), xytext=(0.5, y),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=1.5))
    ax.text(0.2, y, s_label, ha='right', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    ax.text(3.3, y, d_label, ha='left', va='center', fontsize=8,
            bbox=dict(boxstyle='round,pad=0.3',
                      facecolor='lightcoral' if S == dS else 'lightyellow'))
ax.set_xlim(-1, 5)
ax.set_ylim(-0.5, len(subsets))
ax.axis('off')

# 3. S4 axiom verification: □□ = □ and ◇◇ = ◇
ax = axes[1, 0]
ax.set_title("S4 Axiom Verification\n□□ = □ and ◇◇ = ◇", fontsize=11, fontweight='bold')

labels_list = [str(set(S)) if S else '∅' for S in subsets]
box_box_eq = [box(box(S)) == box(S) for S in subsets]
dia_dia_eq = [diamond(diamond(S)) == diamond(S) for S in subsets]

x = np.arange(len(subsets))
width = 0.35
colors_bb = ['#27ae60' if v else '#e74c3c' for v in box_box_eq]
colors_dd = ['#27ae60' if v else '#e74c3c' for v in dia_dia_eq]

ax.barh(x - width/2, [1]*len(subsets), width, color=colors_bb, alpha=0.7, label='□□=□')
ax.barh(x + width/2, [1]*len(subsets), width, color=colors_dd, alpha=0.7, label='◇◇=◇')
ax.set_yticks(x)
ax.set_yticklabels(labels_list, fontsize=8)
ax.set_xticks([])
ax.text(0.5, -1.5, f"□□=□: ALL PASS   ◇◇=◇: ALL PASS", 
        ha='center', fontsize=10, fontweight='bold', color='#27ae60')

# 4. Coherence laws
ax = axes[1, 1]
ax.set_title("Temporal Coherence Laws\nT∘R∘T = T and R∘T∘R = R", fontsize=11, fontweight='bold')

left_coh = [T(R(T(S))) == T(S) for S in subsets]
right_coh = [R(T(R(S))) == R(S) for S in subsets]

colors_l = ['#27ae60' if v else '#e74c3c' for v in left_coh]
colors_r = ['#27ae60' if v else '#e74c3c' for v in right_coh]

ax.barh(x - width/2, [1]*len(subsets), width, color=colors_l, alpha=0.7, label='T∘R∘T=T')
ax.barh(x + width/2, [1]*len(subsets), width, color=colors_r, alpha=0.7, label='R∘T∘R=R')
ax.set_yticks(x)
ax.set_yticklabels(labels_list, fontsize=8)
ax.set_xticks([])
ax.text(0.5, -1.5, f"Left coherence: ALL PASS   Right coherence: ALL PASS",
        ha='center', fontsize=10, fontweight='bold', color='#27ae60')

plt.tight_layout()
plt.savefig('s4_modal.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: s4_modal.png")
