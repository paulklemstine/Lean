#!/usr/bin/env python3
"""
Demo 4: Gödel's Incompleteness and the Limits of Mathematics
=============================================================
Visualizes the structure of mathematical knowledge: provable truths,
unprovable truths, and the expanding horizon of incompleteness.

Oracle Logos contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Circle
from matplotlib.collections import PatchCollection

# ============================================================
# Visualization 1: The Gödel Landscape
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(20, 10))
fig.patch.set_facecolor('#0a0a1a')

# --- Panel 1: Nested circles of mathematical truth ---
ax1 = axes[0]
ax1.set_facecolor('#0a0a1a')
ax1.set_aspect('equal')

# Draw nested regions
regions = [
    (0, 0, 5.0, '#1a1a4e', 'All Mathematical Statements', 0.3),
    (0, 0, 4.0, '#2a2a6e', 'True Statements', 0.4),
    (0, 0, 3.0, '#3a5a8e', 'Provable in ZFC', 0.5),
    (0, 0, 2.0, '#4a8aae', 'Provable in PA', 0.6),
    (0, 0, 1.0, '#6abaee', 'Decidable\n(computable)', 0.7),
]

for x, y, r, color, label, alpha in regions:
    circle = plt.Circle((x, y), r, facecolor=color, edgecolor='white', 
                        linewidth=1.5, alpha=alpha)
    ax1.add_patch(circle)
    if r > 1.5:
        ax1.text(0, r - 0.35, label, ha='center', va='center', 
                fontsize=9, color='white', fontweight='bold', alpha=0.9)
    else:
        ax1.text(0, 0, label, ha='center', va='center', 
                fontsize=8, color='white', fontweight='bold')

# Add specific examples in the gaps
examples = [
    # (x, y, text, color)
    (2.5, 2.5, 'Continuum\nHypothesis\n(independent\nof ZFC)', '#FF6B6B'),
    (-2.5, 2.5, 'Consistency\nof ZFC\n(Gödel II)', '#FF6B6B'),
    (3.5, -1.0, 'False\nstatements', '#666666'),
    (-3.5, -2.0, '0 = 1\n(false)', '#444444'),
    (1.5, -2.0, 'Paris-\nHarrington\n(true, not\nin PA)', '#FFAA44'),
    (-1.8, 1.2, 'Goodstein\'s\ntheorem\n(true, not\nin PA)', '#FFAA44'),
    (0, -1.5, '2+2=4\n(decidable)', '#88FF88'),
]

for x, y, text, color in examples:
    ax1.text(x, y, text, ha='center', va='center', fontsize=7, 
            color=color, style='italic', alpha=0.9,
            bbox=dict(boxstyle='round,pad=0.2', facecolor='#0a0a1a', 
                     edgecolor=color, alpha=0.5))

ax1.set_xlim(-5.5, 5.5)
ax1.set_ylim(-5.5, 5.5)
ax1.set_title("The Landscape of Mathematical Truth\nGödel's Incompleteness Theorems (1931)", 
              fontsize=14, color='white', fontweight='bold')
ax1.set_xticks([])
ax1.set_yticks([])
for spine in ax1.spines.values():
    spine.set_visible(False)

# Add Gödel's key insight
ax1.text(0, -5.0, 
         'For any consistent formal system F ⊇ PA:\n'
         '∃ G: G is true in ℕ but unprovable in F\n'
         '(First Incompleteness Theorem)',
         ha='center', va='center', fontsize=10, color='#AAAAFF',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a3e', 
                  edgecolor='#AAAAFF', alpha=0.8))

# --- Panel 2: The Hierarchy of Formal Systems ---
ax2 = axes[1]
ax2.set_facecolor('#0a0a1a')

systems = [
    (1, 'Presburger\nArithmetic', 'Decidable, complete\n(no multiplication)', '#88FF88', True),
    (2, 'Peano\nArithmetic (PA)', 'Incomplete (Gödel)\nCannot prove Con(PA)', '#FFAA44', False),
    (3, 'ZFC\nSet Theory', 'Incomplete\nCH is independent', '#FF8844', False),
    (4, 'ZFC + Large\nCardinals', 'Incomplete\nNew independences', '#FF6644', False),
    (5, 'ZFC + ∞\nAxioms', 'Still incomplete!\nGödel always applies', '#FF4444', False),
    (6, '???', 'No finite system\ncan capture all truth', '#FF2222', False),
]

for level, name, desc, color, complete in systems:
    y = 7 - level
    width = 1.5 + level * 0.3
    
    rect = FancyBboxPatch((5 - width/2, y - 0.35), width, 0.7,
                          boxstyle="round,pad=0.05",
                          facecolor=color, alpha=0.3, edgecolor=color)
    ax2.add_patch(rect)
    
    ax2.text(5, y, name, ha='center', va='center', fontsize=10, 
            color=color, fontweight='bold')
    ax2.text(5 + width/2 + 0.3, y, desc, ha='left', va='center', 
            fontsize=8, color=color, alpha=0.7)
    
    # Completeness indicator
    if complete:
        ax2.text(5 - width/2 - 0.3, y, '✓', ha='right', va='center',
                fontsize=16, color='#88FF88')
    else:
        ax2.text(5 - width/2 - 0.3, y, '✗', ha='right', va='center',
                fontsize=16, color='#FF4444')
    
    # Arrow to next level
    if level < 6:
        ax2.annotate('', xy=(5, y - 0.4), xytext=(5, y - 0.6),
                    arrowprops=dict(arrowstyle='->', color='white', alpha=0.3))

ax2.set_xlim(0, 12)
ax2.set_ylim(0, 7.5)
ax2.set_title("The Hierarchy of Formal Systems\nEach Level Incomplete (Gödel's Barrier)", 
              fontsize=14, color='white', fontweight='bold')
ax2.set_xticks([])
ax2.set_yticks([])
for spine in ax2.spines.values():
    spine.set_visible(False)

# Key quote
ax2.text(6, 0.5, 
         '"Mathematics does not end — it is inexhaustible.\n'
         'But no finite mind can survey its infinite landscape."\n'
         '— Oracle Logos',
         ha='center', va='center', fontsize=10, color='#AAAAFF',
         style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a3e', 
                  edgecolor='#AAAAFF', alpha=0.8))

plt.tight_layout()
plt.savefig('/workspace/request-project/demos/output/goedel_incompleteness.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 4: Gödel's Incompleteness saved to demos/output/goedel_incompleteness.png")
