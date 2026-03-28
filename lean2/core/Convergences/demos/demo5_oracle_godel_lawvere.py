#!/usr/bin/env python3
"""
Demo 5: Gödel's Incompleteness via Oracles & Lawvere (Direction H1)

Visualizes the deep connection between:
- Cantor's diagonalization (no surjection ℕ → 2^ℕ)
- Gödel's incompleteness (no sound + complete oracle for arithmetic)
- The halting problem (no total halting oracle)

All three are instances of Lawvere's fixed-point theorem applied to
different categories. This demo provides visual proofs and network
diagrams showing the connections.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle, FancyBboxPatch
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

# ─── Figure 1: Cantor's Diagonal Argument Visualized ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.4, wspace=0.35)

ax1 = fig.add_subplot(gs[0, 0])

# Show a 10×10 grid representing f: ℕ → (ℕ → {0,1})
n = 10
np.random.seed(42)
grid = np.random.randint(0, 2, size=(n, n))

# Show the grid
ax1.imshow(grid, cmap='coolwarm', interpolation='nearest', aspect='equal',
           vmin=-0.5, vmax=1.5)

# Highlight diagonal
for i in range(n):
    ax1.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1, fill=False,
                                 edgecolor='gold', linewidth=3))

# Show the evader (diagonal complement)
evader = 1 - np.diag(grid)
for i in range(n):
    ax1.text(i, i, str(grid[i, i]), ha='center', va='center',
             fontsize=10, fontweight='bold', color='gold')

ax1.set_xlabel('Column j (argument to f(i))', fontsize=11)
ax1.set_ylabel('Row i (enumerating functions)', fontsize=11)
ax1.set_title("Cantor's Diagonal Argument\n(gold = diagonal, evader flips each bit)",
              fontsize=13, fontweight='bold')

# Show evader below
evader_text = ''.join(map(str, evader))
diag_text = ''.join([str(grid[i,i]) for i in range(n)])
ax1.text(4.5, -1.5, f'Diagonal:  {diag_text}', fontsize=10, ha='center',
         fontfamily='monospace', color='gray')
ax1.text(4.5, -2.5, f'Evader:    {evader_text}', fontsize=10, ha='center',
         fontfamily='monospace', color='red', fontweight='bold')

# ─── Figure 2: The Three Impossibility Theorems ───
ax2 = fig.add_subplot(gs[0, 1])
ax2.axis('off')

theorems = [
    ("Cantor (1891)", "No surjection\nℕ → 2^ℕ", "#2196F3",
     "If f enumerates subsets,\nthe diagonal complement\nevades f."),
    ("Gödel (1931)", "No sound +\ncomplete oracle", "#E91E63",
     "If T proves all truths,\nthe Gödel sentence G\nsays 'T ⊬ G'."),
    ("Turing (1936)", "No total\nhalting oracle", "#4CAF50",
     "If H decides halting,\nD(n) = loop if H(n,n),\nhalt otherwise."),
]

for i, (name, result, color, proof) in enumerate(theorems):
    y = 0.85 - i * 0.33
    # Box
    bbox = FancyBboxPatch((0.02, y - 0.12), 0.96, 0.28, boxstyle="round,pad=0.02",
                          facecolor=color, alpha=0.15, edgecolor=color, linewidth=2,
                          transform=ax2.transAxes)
    ax2.add_patch(bbox)
    ax2.text(0.15, y + 0.08, name, transform=ax2.transAxes,
             fontsize=14, fontweight='bold', color=color, va='center')
    ax2.text(0.45, y + 0.08, result, transform=ax2.transAxes,
             fontsize=11, va='center', ha='center', fontfamily='serif')
    ax2.text(0.8, y + 0.02, proof, transform=ax2.transAxes,
             fontsize=8, va='center', ha='center', color='gray',
             fontstyle='italic')

# Central unifying label
ax2.text(0.5, 0.02, "All three follow from Lawvere's\nFixed-Point Theorem (1969)",
         transform=ax2.transAxes, fontsize=13, fontweight='bold',
         ha='center', va='center',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='gold', alpha=0.3))

ax2.set_title('Three Impossibility Theorems = One Theorem',
              fontsize=13, fontweight='bold')

# ─── Figure 3: Lawvere's Fixed-Point Theorem (Category Diagram) ───
ax3 = fig.add_subplot(gs[1, 0])
ax3.axis('off')
ax3.set_xlim(-1, 5)
ax3.set_ylim(-1, 4)

# Draw objects
for pos, label, color in [((0.5, 3), 'A', '#2196F3'),
                            ((3.5, 3), 'A → B', '#E91E63'),
                            ((2, 0.5), 'B', '#4CAF50')]:
    circle = Circle(pos, 0.5, facecolor=color, alpha=0.2, edgecolor=color, linewidth=2)
    ax3.add_patch(circle)
    ax3.text(*pos, label, ha='center', va='center', fontsize=14, fontweight='bold')

# Draw arrows
ax3.annotate('', xy=(3.0, 3), xytext=(1.0, 3),
            arrowprops=dict(arrowstyle='->', lw=2, color='black'))
ax3.text(2, 3.3, 'f (surjective)', ha='center', fontsize=11)

ax3.annotate('', xy=(2, 1.0), xytext=(3.2, 2.5),
            arrowprops=dict(arrowstyle='->', lw=2, color='#E91E63'))
ax3.text(3.2, 1.5, 'eval', ha='center', fontsize=11, color='#E91E63')

ax3.annotate('', xy=(1.8, 1.0), xytext=(1.8, 0.5),
            arrowprops=dict(arrowstyle='->', lw=2, color='#4CAF50', connectionstyle='arc3,rad=-0.5'))
ax3.text(0.8, 0.5, 'g : B → B', ha='center', fontsize=11, color='#4CAF50')
ax3.text(0.3, -0.2, '(with no fixed point)', ha='center', fontsize=9, color='gray')

ax3.text(2, -0.7, "Lawvere: If f is surjective,\nevery g : B → B has a fixed point.\n"
         "Contrapositive: If ∃ g with no fixed point,\nf cannot be surjective.",
         ha='center', fontsize=10, fontstyle='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax3.set_title("Lawvere's Fixed-Point Theorem\n(the meta-theorem behind all three)",
              fontsize=13, fontweight='bold')

# ─── Figure 4: Oracle Completeness vs Soundness Tradeoff ───
ax4 = fig.add_subplot(gs[1, 1])

# Model: for a theory with n axioms, soundness and completeness trade off
# More axioms → more complete but risk of inconsistency
n_axioms = np.arange(1, 100)
# Completeness increases with axioms (diminishing returns)
completeness = 1 - np.exp(-0.05 * n_axioms)
# Soundness decreases (risk of contradiction grows)
soundness = np.exp(-0.002 * n_axioms**1.5)
# Product (overall quality)
quality = completeness * soundness

ax4.plot(n_axioms, completeness, '-', color='#2196F3', linewidth=2.5,
         label='Completeness')
ax4.plot(n_axioms, soundness, '-', color='#E91E63', linewidth=2.5,
         label='Soundness')
ax4.plot(n_axioms, quality, '-', color='#4CAF50', linewidth=2.5,
         label='Quality (S × C)', linestyle='--')

# Mark the optimal point
opt_idx = np.argmax(quality)
ax4.plot(n_axioms[opt_idx], quality[opt_idx], 'o', color='gold',
         markersize=12, zorder=5, markeredgecolor='black')
ax4.annotate(f'Optimal: n = {n_axioms[opt_idx]}',
             xy=(n_axioms[opt_idx], quality[opt_idx]),
             xytext=(n_axioms[opt_idx] + 15, quality[opt_idx] + 0.1),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=11, fontweight='bold')

# Gödel's limit
ax4.axhline(y=1.0, color='red', linestyle=':', alpha=0.3)
ax4.text(90, 1.02, 'S = C = 1\n(impossible by Gödel)', fontsize=9,
         color='red', ha='right', fontstyle='italic')

ax4.set_xlabel('Theory Strength (number of axioms)', fontsize=12)
ax4.set_ylabel('Score', fontsize=12)
ax4.set_title("Gödel's Tradeoff:\nSoundness vs. Completeness", fontsize=13, fontweight='bold')
ax4.legend(fontsize=11)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(-0.05, 1.15)

fig.suptitle("Direction H1: Gödel's Incompleteness via Oracle Theory",
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig8_godel_oracle.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 8 saved: fig8_godel_oracle.png")
