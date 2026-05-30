#!/usr/bin/env python3
"""
Visualization: Church-Rosser Equivalence

Visualizes the equivalence between confluence and the Church-Rosser property,
showing how zigzag paths (equivalence closure) relate to forward-only paths
(reflexive-transitive closure) through the common reduct construction.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# === Panel 1: Equivalence Closure (Zigzag) ===
ax = axes[0]
ax.set_xlim(-1, 7)
ax.set_ylim(-2, 4)
ax.set_title('Equivalence Closure (Zigzag Path)', fontsize=13, fontweight='bold')

# Zigzag path: a → x₁ ← x₂ → x₃ ← b
points = [(0, 2), (1.5, 3), (3, 2), (4.5, 3), (6, 2)]
labels = ['a', 'x₁', 'x₂', 'x₃', 'b']
colors = ['red', 'gray', 'gray', 'gray', 'blue']

# Draw points
for (x, y), label, color in zip(points, labels, colors):
    ax.plot(x, y, 'o', color=color, markersize=12, markeredgecolor='black', markeredgewidth=2)
    ax.text(x, y - 0.5, label, fontsize=13, ha='center', fontweight='bold')

# Draw zigzag arrows (alternating forward/backward)
arrow_directions = [
    (0, 1, 'forward'),   # a → x₁
    (2, 1, 'backward'),  # x₂ → x₁ (shown as x₁ ← x₂)
    (2, 3, 'forward'),   # x₂ → x₃
    (4, 3, 'backward'),  # b → x₃ (shown as x₃ ← b)
]

for src, tgt, direction in arrow_directions:
    sx, sy = points[src]
    tx, ty = points[tgt]
    color = '#2ecc71' if direction == 'forward' else '#e74c3c'
    ax.annotate('', xy=(tx + 0.15 * np.sign(sx - tx), ty),
                xytext=(sx + 0.15 * np.sign(tx - sx), sy),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

ax.text(3, 0.5, 'a ≡ᵣ b (connected by zigzag\nof forward and backward steps)',
        fontsize=10, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Legend
ax.plot([], [], '->', color='#2ecc71', label='Forward step (r)', linewidth=2)
ax.plot([], [], '->', color='#e74c3c', label='Backward step (r⁻¹)', linewidth=2)
ax.legend(loc='upper left', fontsize=9)
ax.axis('off')

# === Panel 2: Confluence Resolution ===
ax = axes[1]
ax.set_xlim(-1, 7)
ax.set_ylim(-3, 4.5)
ax.set_title('Confluence Resolves the Zigzag', fontsize=13, fontweight='bold')

# Show the same zigzag but with confluence filling in the gaps
# Top: zigzag path
for (x, y), label, color in zip(points, labels, colors):
    ax.plot(x, y, 'o', color=color, markersize=10, markeredgecolor='black')
    ax.text(x, y + 0.35, label, fontsize=11, ha='center')

# Zigzag arrows (lighter)
for src, tgt, direction in arrow_directions:
    sx, sy = points[src]
    tx, ty = points[tgt]
    color = '#2ecc71' if direction == 'forward' else '#e74c3c'
    ax.annotate('', xy=(tx + 0.1 * np.sign(sx - tx), ty),
                xytext=(sx + 0.1 * np.sign(tx - sx), sy),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5, alpha=0.4))

# Intermediate common reducts
mid_points = [(0.75, 0.5, 'd₁'), (3.75, 0.5, 'd₂')]
for x, y, label in mid_points:
    ax.plot(x, y, 's', color='purple', markersize=10, markeredgecolor='black')
    ax.text(x, y - 0.4, label, fontsize=11, ha='center', fontweight='bold', color='purple')

# Arrows to common reducts
# a →* d₁ and x₂ →* d₁ (using confluence at x₁)
ax.annotate('', xy=(0.75, 0.65), xytext=(0, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))
ax.annotate('', xy=(0.85, 0.65), xytext=(3, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# x₂ →* d₂ and b →* d₂
ax.annotate('', xy=(3.65, 0.65), xytext=(3, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))
ax.annotate('', xy=(3.85, 0.65), xytext=(6, 1.85),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2, ls='--'))

# Final common reduct
ax.plot(2.25, -1.5, '*', color='gold', markersize=20, markeredgecolor='black', markeredgewidth=2)
ax.text(2.25, -2.1, 'c (common reduct)', fontsize=11, ha='center', fontweight='bold')

ax.annotate('', xy=(2.15, -1.35), xytext=(0.75, 0.35),
            arrowprops=dict(arrowstyle='->', color='gold', lw=2.5, ls='--'))
ax.annotate('', xy=(2.35, -1.35), xytext=(3.75, 0.35),
            arrowprops=dict(arrowstyle='->', color='gold', lw=2.5, ls='--'))

ax.text(3, -2.8, 'Confluence guarantees ∃c:\na →* c ∧ b →* c',
        fontsize=10, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='#f0e0ff', alpha=0.8))
ax.axis('off')

# === Panel 3: The Equivalence Theorem ===
ax = axes[2]
ax.set_xlim(-1, 7)
ax.set_ylim(-1, 6)
ax.set_title('Church-Rosser ⟺ Confluence', fontsize=13, fontweight='bold')

# Two boxes connected by double arrow
box_style = dict(boxstyle='round,pad=0.5', facecolor='lightblue',
                  edgecolor='navy', linewidth=2)
box_style2 = dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                   edgecolor='darkgreen', linewidth=2)

ax.text(3, 5, 'ARSConfluent r', fontsize=14, ha='center', fontweight='bold',
        bbox=box_style)
ax.text(3, 3.5, '⟺', fontsize=24, ha='center', fontweight='bold', color='red')
ax.text(3, 2, 'ChurchRosser r', fontsize=14, ha='center', fontweight='bold',
        bbox=box_style2)

# Proof arrows
ax.annotate('', xy=(1.5, 3.7), xytext=(1.5, 4.5),
            arrowprops=dict(arrowstyle='->', color='navy', lw=2))
ax.text(0, 4.1, '(⇐) rtc → eqvgen\nthen apply CR', fontsize=8, ha='left')

ax.annotate('', xy=(4.5, 4.5), xytext=(4.5, 3.7),
            arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
ax.text(5, 4.1, '(⇒) induction on\neqvgen derivation', fontsize=8, ha='left')

# Key insight box
insight_text = (
    "Key Insight:\n"
    "Confluence = joining multi-step divergences\n"
    "Church-Rosser = joining zigzag equivalences\n"
    "\n"
    "Same property, different perspectives!\n"
    "\n"
    "Application: s =_E t  ⟺  nf(s) = nf(t)\n"
    "(decidable word problem)"
)
ax.text(3, -0.2, insight_text, fontsize=9, ha='center', va='top',
        fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='#f5f5f5', alpha=0.9, edgecolor='gray'))

ax.axis('off')

plt.suptitle('The Church-Rosser Equivalence: Two Views of the Same Property',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('church_rosser.png', dpi=150, bbox_inches='tight')
print("Saved church_rosser.png")
