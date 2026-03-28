#!/usr/bin/env python3
"""
Demo 4: Custom Mathematical Universes & Removing Integers
Explores what happens when you build your own math rules and
what breaks when you remove an integer from the number line.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(22, 18))
gs = gridspec.GridSpec(3, 3, figure=fig, hspace=0.35, wspace=0.3)

# ──── Panel 1: The Number Line with a Hole ────
ax1 = fig.add_subplot(gs[0, :])
ax1.set_title('Removing 7 from the Integer Number Line: ℤ \\ {7}', 
              fontsize=16, fontweight='bold', color='white')

# Draw the number line
integers = list(range(-5, 20))
for n in integers:
    if n == 7:
        # The hole
        ax1.plot(n, 0, 'o', color='#0a0a1a', markersize=20, zorder=5,
                markeredgecolor='#ff6b6b', markeredgewidth=3)
        ax1.text(n, -0.5, '7\n(REMOVED)', ha='center', fontsize=10, 
                color='#ff6b6b', fontweight='bold')
        # Stress lines
        for angle in np.linspace(0, 2*np.pi, 8, endpoint=False):
            ax1.plot([n + 0.3*np.cos(angle), n + 0.7*np.cos(angle)],
                    [0.3*np.sin(angle), 0.7*np.sin(angle)],
                    '-', color='#ff6b6b', alpha=0.5, linewidth=1)
    else:
        color = '#2ecc71' if n != 7 else '#ff6b6b'
        alpha = 1.0 if abs(n-7) > 2 else 0.5 + 0.5 * abs(n-7)/2
        ax1.plot(n, 0, 'o', color=color, markersize=12, alpha=alpha)
        ax1.text(n, 0.3, str(n), ha='center', fontsize=8, color='white', alpha=alpha)

# Draw the line
ax1.plot([-5.5, 6.7], [0, 0], '-', color='white', linewidth=2, alpha=0.5)
ax1.plot([7.3, 19.5], [0, 0], '-', color='white', linewidth=2, alpha=0.5)

# Annotations about broken properties
annotations = [
    (3, 1.2, '3 + 4 = 7 ✗\n(addition broken!)', '#e74c3c'),
    (10, 1.2, '49 = 7² has no\nprime factorization!', '#e74c3c'),
    (14, 1.2, '14 = 2 × 7 ✗\n(multiplication broken!)', '#e74c3c'),
    (0, -1.5, '6 and 8 are now\nneighbors (gap!)', '#f39c12'),
]
for x, y, text, color in annotations:
    ax1.text(x, y, text, ha='center', fontsize=9, color=color, 
            fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#1a1a2e', alpha=0.8))

ax1.set_xlim(-6, 20)
ax1.set_ylim(-2, 2)
ax1.set_facecolor('#0a0a1a')
ax1.axis('off')

# ──── Panel 2: What Breaks — Checklist ────
ax2 = fig.add_subplot(gs[1, 0])
ax2.set_title('What Breaks When You\nRemove an Integer', fontsize=13, fontweight='bold', color='white')
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 10)

properties = [
    (9, 'Closure under +', '✗ BROKEN', '#e74c3c'),
    (8, 'Closure under ×', '✗ BROKEN', '#e74c3c'),
    (7, 'Group structure', '✗ BROKEN', '#e74c3c'),
    (6, 'Ring structure', '✗ BROKEN', '#e74c3c'),
    (5, 'Unique factorization', '✗ BROKEN', '#e74c3c'),
    (4, 'Well-ordering', '≈ Modified', '#f39c12'),
    (3, 'Archimedean property', '✓ Preserved', '#2ecc71'),
    (2, 'Countability', '✓ Preserved', '#2ecc71'),
    (1, 'Total ordering', '✓ Preserved', '#2ecc71'),
]

for y, prop, status, color in properties:
    ax2.text(0.5, y, prop, fontsize=10, va='center', color='white')
    ax2.text(7, y, status, fontsize=10, va='center', color=color, fontweight='bold')

ax2.set_facecolor('#0a0a1a')
ax2.axis('off')

# ──── Panel 3: Factorization Tree with Missing 7 ────
ax3 = fig.add_subplot(gs[1, 1])
ax3.set_title('Prime Factorization in ℤ\\{7}\nSome numbers lose their factorization', 
              fontsize=12, fontweight='bold', color='white')

# Draw some numbers and their factorizations
numbers = [
    (12, '2²×3', True, '#2ecc71'),
    (15, '3×5', True, '#2ecc71'),
    (21, '3×7 = ???', False, '#e74c3c'),
    (28, '2²×7 = ???', False, '#e74c3c'),
    (35, '5×7 = ???', False, '#e74c3c'),
    (42, '2×3×7 = ???', False, '#e74c3c'),
    (49, '7² = ???', False, '#e74c3c'),
    (30, '2×3×5', True, '#2ecc71'),
]

for i, (num, fact, valid, color) in enumerate(numbers):
    y = 8 - i * 1.0
    ax3.text(1, y, str(num), fontsize=14, va='center', color='white', fontweight='bold')
    ax3.text(3, y, '=', fontsize=14, va='center', color='white')
    ax3.text(4, y, fact, fontsize=11, va='center', color=color)
    marker = '✓' if valid else '✗'
    ax3.text(8, y, marker, fontsize=16, va='center', color=color, fontweight='bold')

ax3.set_xlim(0, 9)
ax3.set_ylim(0, 9)
ax3.set_facecolor('#0a0a1a')
ax3.axis('off')

# ──── Panel 4: The Defect Topology ────
ax4 = fig.add_subplot(gs[1, 2])
ax4.set_title('Topological View: ℝ\\{7}\nRemoval creates two components', 
              fontsize=12, fontweight='bold', color='white')

x = np.linspace(-2, 15, 1000)

# Draw ℝ as a line with a gap at 7
mask_left = x < 6.9
mask_right = x > 7.1

ax4.fill_between(x[mask_left], -0.3, 0.3, color='#3498db', alpha=0.4)
ax4.fill_between(x[mask_right], -0.3, 0.3, color='#e74c3c', alpha=0.4)

ax4.plot(x[mask_left], np.zeros_like(x[mask_left]), '-', color='#3498db', linewidth=3)
ax4.plot(x[mask_right], np.zeros_like(x[mask_right]), '-', color='#e74c3c', linewidth=3)

# Open circles at x=7
ax4.plot(6.9, 0, 'o', markersize=12, markerfacecolor='#0a0a1a', 
         markeredgecolor='#3498db', markeredgewidth=2)
ax4.plot(7.1, 0, 'o', markersize=12, markerfacecolor='#0a0a1a',
         markeredgecolor='#e74c3c', markeredgewidth=2)

ax4.text(3, 0.6, '(-∞, 7)', fontsize=12, ha='center', color='#3498db', fontweight='bold')
ax4.text(11, 0.6, '(7, ∞)', fontsize=12, ha='center', color='#e74c3c', fontweight='bold')
ax4.text(7, -0.8, 'Gap: two connected\ncomponents!', fontsize=10, ha='center', 
         color='#f39c12', fontweight='bold')

# Fundamental group annotation
ax4.text(7, 1.5, 'π₀(ℝ\\{7}) = ℤ₂\n(two components)', fontsize=10, ha='center',
         color='white', bbox=dict(boxstyle='round', facecolor='#1a1a2e', alpha=0.8))

ax4.set_xlim(-2, 16)
ax4.set_ylim(-1.5, 2.5)
ax4.set_facecolor('#0a0a1a')
ax4.axis('off')

# ──── Panel 5: Custom Universe Comparison ────
ax5 = fig.add_subplot(gs[2, 0:2])
ax5.set_title('Building Custom Mathematical Universes\nEach column is a different set of rules', 
              fontsize=14, fontweight='bold', color='white')
ax5.set_xlim(0, 20)
ax5.set_ylim(0, 8)

universes = [
    {'name': 'Classical\nℤ', 'add': '+', 'mul': '×', 'identity_a': '0', 'identity_m': '1',
     'assoc': '✓', 'comm': '✓', 'distrib': '✓', 'color': '#ffffff'},
    {'name': 'Tropical\nMax-Plus', 'add': 'max', 'mul': '+', 'identity_a': '-∞', 'identity_m': '0',
     'assoc': '✓', 'comm': '✓', 'distrib': '✓', 'color': '#e74c3c'},
    {'name': 'Defect\nℤ\\{7}', 'add': '+*', 'mul': '×*', 'identity_a': '0', 'identity_m': '1',
     'assoc': '✗', 'comm': '✓', 'distrib': '✗', 'color': '#f39c12'},
    {'name': 'Fuzzy\n[0,1]', 'add': 'max', 'mul': 'min', 'identity_a': '0', 'identity_m': '1',
     'assoc': '✓', 'comm': '✓', 'distrib': '✓', 'color': '#2ecc71'},
    {'name': 'Hyper\nKrasner', 'add': '⊞', 'mul': '×', 'identity_a': '0', 'identity_m': '1',
     'assoc': '✓', 'comm': '✓', 'distrib': '✓', 'color': '#9b59b6'},
]

headers = ['Universe', '⊕', '⊗', 'e₊', 'e×', 'Assoc', 'Comm', 'Dist']
header_x = [1, 4, 6, 8, 10, 12, 14, 16]

for i, h in enumerate(headers):
    ax5.text(header_x[i], 7.5, h, fontsize=10, fontweight='bold', color='#888888', ha='center')
ax5.plot([0, 18], [7.1, 7.1], '-', color='#444444', linewidth=1)

for row, u in enumerate(universes):
    y = 6 - row * 1.2
    color = u['color']
    vals = [u['name'], u['add'], u['mul'], u['identity_a'], u['identity_m'],
            u['assoc'], u['comm'], u['distrib']]
    for i, v in enumerate(vals):
        c = color
        if v == '✗':
            c = '#e74c3c'
        elif v == '✓':
            c = '#2ecc71'
        ax5.text(header_x[i], y, v, fontsize=9, ha='center', va='center', color=c)

ax5.set_facecolor('#0a0a1a')
ax5.axis('off')

# ──── Panel 6: Phase Diagram of Universes ────
ax6 = fig.add_subplot(gs[2, 2])
ax6.set_title('Phase Diagram of\nMathematical Universes', fontsize=13, fontweight='bold', color='white')

# Axes: Structure richness vs Computational power
np.random.seed(42)
universes_data = [
    ('Classical ℝ', 9, 5, '#ffffff', 200),
    ('Tropical', 4, 7, '#e74c3c', 200),
    ('Boolean', 2, 8, '#f39c12', 200),
    ('p-adic', 8, 6, '#3498db', 150),
    ('Surreal', 10, 3, '#9b59b6', 150),
    ('Defect ℤ\\{n}', 3, 4, '#ff6b6b', 150),
    ('Fuzzy [0,1]', 3, 6, '#2ecc71', 150),
    ('Hyperreal', 9, 4, '#e056a0', 120),
    ('Free magma', 1, 2, '#888888', 100),
    ('Meadow', 7, 5, '#f1c40f', 120),
]

for name, structure, compute, color, size in universes_data:
    ax6.scatter(structure, compute, c=color, s=size, alpha=0.8, zorder=5, edgecolors='white')
    ax6.text(structure+0.3, compute+0.3, name, fontsize=8, color=color)

ax6.set_xlabel('Algebraic Structure Richness →', color='white', fontsize=10)
ax6.set_ylabel('Computational Power →', color='white', fontsize=10)

# Regions
ax6.fill_between([0,5], [0,0], [10,10], alpha=0.05, color='#e74c3c')
ax6.fill_between([5,11], [0,0], [10,10], alpha=0.05, color='#3498db')
ax6.text(2, 9, 'Simple but\ncomputationally\npowerful', fontsize=8, color='#e74c3c', alpha=0.6)
ax6.text(8, 9, 'Rich structure,\nhigh compute', fontsize=8, color='#3498db', alpha=0.6)

ax6.set_xlim(0, 11)
ax6.set_ylim(0, 10)
ax6.set_facecolor('#0a0a1a')
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#444444')

fig.patch.set_facecolor('#0a0a1a')
plt.savefig('/workspace/request-project/demos/custom_universes.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/custom_universes.png")
