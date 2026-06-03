#!/usr/bin/env python3
"""Visualization: 3-element Heyting algebra and LEM failure."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# 1. Hasse diagram of the 3-element chain
ax = axes[0]
ax.set_title("3-Element Chain\n(Retrocausal Fixed Points)", fontsize=12, fontweight='bold')
positions = {0: (0.5, 0.1), 1: (0.5, 0.5), 2: (0.5, 0.9)}
labels = {0: "⊥ (impossible)", 1: "mid (contingent)", 2: "⊤ (necessary)"}
colors = {0: '#e74c3c', 1: '#f39c12', 2: '#27ae60'}

for val, (x, y) in positions.items():
    ax.plot(x, y, 'o', markersize=20, color=colors[val], zorder=5)
    ax.annotate(labels[val], (x, y), textcoords="offset points",
                xytext=(60, 0), fontsize=10, va='center')

# Draw edges
ax.plot([0.5, 0.5], [0.1, 0.5], 'k-', linewidth=2)
ax.plot([0.5, 0.5], [0.5, 0.9], 'k-', linewidth=2)
ax.set_xlim(-0.1, 1.5)
ax.set_ylim(-0.05, 1.05)
ax.axis('off')

# 2. LEM failure visualization
ax = axes[1]
ax.set_title("Law of Excluded Middle\na ⊔ ¬a = ?", fontsize=12, fontweight='bold')

elements = ['⊥', 'mid', '⊤']
neg_vals = ['⊤', '⊥', '⊥']
lem_vals = ['⊤', 'mid', '⊤']
lem_holds = [True, False, True]

bar_colors = ['#27ae60' if h else '#e74c3c' for h in lem_holds]
bars = ax.bar(range(3), [2, 1, 2], color=bar_colors, alpha=0.7, edgecolor='black')

ax.set_xticks(range(3))
ax.set_xticklabels([f'a={e}\n¬a={n}\na⊔¬a={v}' for e, n, v in zip(elements, neg_vals, lem_vals)],
                   fontsize=9)
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(['⊥', 'mid', '⊤'])
ax.axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='⊤ (needed for LEM)')
ax.legend(fontsize=9)

# 3. Double negation failure
ax = axes[2]
ax.set_title("Double Negation\n¬¬a vs a", fontsize=12, fontweight='bold')

a_vals = [0, 1, 2]
dbl_neg = [0, 2, 2]  # ¬¬⊥=⊥, ¬¬mid=⊤, ¬¬⊤=⊤

x = np.arange(3)
width = 0.35
bars1 = ax.bar(x - width/2, a_vals, width, label='a', color='#3498db', alpha=0.7, edgecolor='black')
bars2 = ax.bar(x + width/2, dbl_neg, width, label='¬¬a', color='#e67e22', alpha=0.7, edgecolor='black')

ax.set_xticks(x)
ax.set_xticklabels(elements)
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(['⊥', 'mid', '⊤'])
ax.legend(fontsize=10)

# Highlight mismatch
ax.annotate('≠', (1, 1.5), fontsize=16, ha='center', color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('heyting_lem_failure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: heyting_lem_failure.png")
