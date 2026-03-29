#!/usr/bin/env python3
"""
Demo 8 — The Grand Duality Table (Full Overview)
=================================================
A single visual showing all 8 rows of the Universal Translator,
with the SPACE side on the left and the ALGEBRA side on the right,
connected by bidirectional arrows.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, ax = plt.subplots(figsize=(18, 12))
fig.patch.set_facecolor("#0d1117")
ax.set_facecolor("#0d1117")

rows = [
    ("Point x ∈ X",              "Prime ideal p ⊂ A",          '#58A6FF'),
    ("Open set U ⊆ X",           "Element a ∈ A  (D(a))",       '#3FB950'),
    ("Continuous map f: X→Y",    "Ring hom φ: B→A  (reversed!)",'#F0883E'),
    ("Closed subspace Z ⊆ X",   "Ideal I ⊂ A  (V(I))",         '#DA3633'),
    ("Dimension dim(X)",         "Krull dim = chain of primes",  '#A371F7'),
    ("Tangent vector v",         "Derivation δ: A → M",          '#FFD700'),
    ("Connected components",     "Idempotents e² = e",           '#79C0FF'),
    ("Vector bundle E → X",     "Projective module P",           '#F778BA'),
]

n = len(rows)
y_positions = np.linspace(10, 1, n)

# Title
ax.text(9, 11.5, "THE UNIVERSAL TRANSLATOR",
        fontsize=28, ha='center', color='white', fontweight='bold',
        family='monospace')
ax.text(9, 10.8, "Space ↔ Algebra — The Grand Duality Table",
        fontsize=16, ha='center', color='#8B949E')

# Column headers
ax.text(3, 10.5, "S P A C E", fontsize=18, ha='center', color='#58A6FF',
        fontweight='bold', family='monospace')
ax.text(15, 10.5, "A L G E B R A", fontsize=18, ha='center', color='#3FB950',
        fontweight='bold', family='monospace')

for i, (space, algebra, color) in enumerate(rows):
    y = y_positions[i]

    # Row number
    ax.text(0.3, y, f"{i+1}", fontsize=14, ha='center', va='center',
            color=color, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=color + '22',
                      edgecolor=color, lw=1.5))

    # Space side
    box_s = mpatches.FancyBboxPatch((1, y - 0.3), 4.5, 0.6,
                                      boxstyle="round,pad=0.15",
                                      facecolor='#161B22',
                                      edgecolor=color, lw=1.5)
    ax.add_patch(box_s)
    ax.text(3.25, y, space, fontsize=12, ha='center', va='center',
            color='#E6EDF3')

    # Bidirectional arrow
    ax.annotate('', xy=(12.5, y), xytext=(5.7, y),
                arrowprops=dict(arrowstyle='<->', color=color, lw=2.5,
                                connectionstyle='arc3,rad=0'))
    ax.text(9, y + 0.25, "↔", fontsize=16, ha='center', color=color,
            fontweight='bold')

    # Algebra side
    box_a = mpatches.FancyBboxPatch((12.5, y - 0.3), 5, 0.6,
                                      boxstyle="round,pad=0.15",
                                      facecolor='#161B22',
                                      edgecolor=color, lw=1.5)
    ax.add_patch(box_a)
    ax.text(15, y, algebra, fontsize=12, ha='center', va='center',
            color='#E6EDF3')

# Footer
ax.text(9, 0.2,
        "Each row is a theorem — machine-verified in Lean 4 with Mathlib",
        fontsize=11, ha='center', color='#484F58', style='italic')

ax.set_xlim(-0.5, 18.5)
ax.set_ylim(-0.3, 12.3)
ax.axis('off')
plt.tight_layout()
plt.savefig("demo_08_grand_table.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_08_grand_table.png")
