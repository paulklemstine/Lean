#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics and Harmonic Normal Forms

Shows how chip-firing moves on a graph correspond to adding Laplacian
columns, and how harmonic normal forms provide canonical representatives
for each firing class.

This visualization demonstrates the core theorem: under the separation
hypothesis, every divisor class admits a unique harmonic normal form.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)


fig = plt.figure(figsize=(16, 10))
fig.suptitle('Chip-Firing Dynamics & Harmonic Normal Forms', fontsize=16, fontweight='bold')
gs = GridSpec(2, 3, figure=fig, hspace=0.4, wspace=0.35)

# ── Panel 1: Chip-firing on C_4 ──
ax1 = fig.add_subplot(gs[0, 0])
# Cycle C_4 with chips
n = 4
theta = np.linspace(0, 2*np.pi, n, endpoint=False) + np.pi/4
x = np.cos(theta)
y = np.sin(theta)

# Draw graph
for i in range(n):
    j = (i + 1) % n
    ax1.plot([x[i], x[j]], [y[i], y[j]], 'k-', linewidth=2)

# Initial chip configuration
chips = [3, 0, 1, 0]
colors = ['#ff6b6b' if c >= 2 else '#4ecdc4' for c in chips]
ax1.scatter(x, y, c=colors, s=400, zorder=5, edgecolors='black', linewidth=2)
for i in range(n):
    ax1.text(x[i], y[i], str(chips[i]), ha='center', va='center', 
            fontsize=14, fontweight='bold')
    ax1.annotate(f'v{i}', (x[i], y[i]), textcoords="offset points",
                xytext=(15*np.cos(theta[i]), 15*np.sin(theta[i])), 
                ha='center', fontsize=9)

ax1.set_title('Before Firing v₀\n(3 chips at v₀ ≥ deg=2)')
ax1.set_aspect('equal')
ax1.axis('off')

# ── Panel 2: After firing ──
ax2 = fig.add_subplot(gs[0, 1])
for i in range(n):
    j = (i + 1) % n
    ax2.plot([x[i], x[j]], [y[i], y[j]], 'k-', linewidth=2)

# After firing v0: v0 loses 2 chips, neighbors gain 1 each
chips_after = [1, 1, 1, 1]
colors_after = ['#4ecdc4'] * n
ax2.scatter(x, y, c=colors_after, s=400, zorder=5, edgecolors='black', linewidth=2)
for i in range(n):
    ax2.text(x[i], y[i], str(chips_after[i]), ha='center', va='center',
            fontsize=14, fontweight='bold')

# Arrow showing firing
ax2.annotate('', xy=(0.35, 0), xytext=(-0.35, 0),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))

ax2.set_title('After Firing v₀\n(uniform = harmonic!)')
ax2.set_aspect('equal')
ax2.axis('off')

# ── Panel 3: Laplacian action ──
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')
laplacian_text = """
Chip-Firing = Laplacian Action

L(C₄) = ⎡ 2 -1  0 -1⎤
         ⎢-1  2 -1  0⎥
         ⎢ 0 -1  2 -1⎥
         ⎣-1  0 -1  2⎦

Fire v₀: subtract column 0 of L
  [3,0,1,0] → [3,0,1,0] - [2,-1,0,-1]
             = [1,1,1,1]

Key property:
  Row sums = 0 ⟹ degree preserved
  Total chips: 4 → 4  ✓

Harmonic normal form:
  [1,1,1,1] is constant = harmonic
  This is the canonical representative
"""
ax3.text(0.05, 0.95, laplacian_text, transform=ax3.transAxes, fontsize=9,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# ── Panel 4: Firing equivalence classes on C_3 ──
ax4 = fig.add_subplot(gs[1, 0:2])
# Show multiple configurations in the same firing class
A = np.array([[0,1,1],[1,0,1],[1,1,0]])
L = graph_laplacian(A)

configs = [
    ([2, 0, 0], "Initial"),
    ([0, 1, 1], "Fire v₀"),
    ([1, -1, 2], "Fire v₁"),
    ([1, 2, -1], "Fire v₂"),
]

for idx, (chips, label) in enumerate(configs):
    offset_x = idx * 2.5
    theta = np.linspace(0, 2*np.pi, 3, endpoint=False) + np.pi/2
    cx = np.cos(theta) + offset_x
    cy = np.sin(theta)
    
    for i in range(3):
        j = (i + 1) % 3
        ax4.plot([cx[i], cx[j]], [cy[i], cy[j]], 'k-', linewidth=1.5)
    
    colors = ['#ff6b6b' if c < 0 else '#4ecdc4' for c in chips]
    ax4.scatter(cx, cy, c=colors, s=300, zorder=5, edgecolors='black', linewidth=1.5)
    for i in range(3):
        ax4.text(cx[i], cy[i], str(chips[i]), ha='center', va='center',
                fontsize=12, fontweight='bold')
    
    ax4.text(offset_x, -1.5, label, ha='center', fontsize=9)
    
    if idx < len(configs) - 1:
        ax4.annotate('≡', xy=(offset_x + 1.5, 0), fontsize=20,
                    ha='center', va='center', color='blue', fontweight='bold')

ax4.set_title('Firing Equivalence Classes on K₃\n(all equivalent modulo Laplacian)')
ax4.set_aspect('equal')
ax4.set_ylim(-2.2, 1.8)
ax4.axis('off')

# ── Panel 5: Separation and uniqueness ──
ax5 = fig.add_subplot(gs[1, 2])
ax5.axis('off')
sep_text = """
Separation Hypothesis
━━━━━━━━━━━━━━━━━━━━

SeparatedOn(G, S):
  If f, g : V → ℤ are
  • harmonic on S
  • normalized on S
  • agree on S
  then f = g everywhere.

What this means:
━━━━━━━━━━━━━━━
S "sees" enough of the
graph that boundary values
on S uniquely determine
the harmonic extension.

Consequence:
━━━━━━━━━━━
Every chip-firing class
has a UNIQUE harmonic
normal form.

This is the tropical
kernel canonicality theorem.
"""
ax5.text(0.05, 0.95, sep_text, transform=ax5.transAxes, fontsize=9,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightcyan', alpha=0.8))

plt.savefig('viz_chip_firing.png', dpi=150, bbox_inches='tight')
print("Saved viz_chip_firing.png")
