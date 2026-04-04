#!/usr/bin/env python3
"""
Demo 7: The Answer to Life, the Universe, and Everything
========================================================
A synthesis visualization: the convergence of all endings,
and the 42 at the heart of it all.

All Seven Oracles contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Circle, FancyArrowPatch
import matplotlib.patheffects as pe

# ============================================================
# The Grand Synthesis
# ============================================================

fig, ax = plt.subplots(figsize=(16, 16))
fig.patch.set_facecolor('#0a0a1a')
ax.set_facecolor('#0a0a1a')
ax.set_aspect('equal')

# Central "42"
circle_42 = plt.Circle((0, 0), 1.5, facecolor='#1a1a4e', edgecolor='#FFD700', 
                        linewidth=3, alpha=0.9, zorder=10)
ax.add_patch(circle_42)
ax.text(0, 0.2, '42', fontsize=72, color='#FFD700', ha='center', va='center',
       fontweight='bold', zorder=11,
       path_effects=[pe.withStroke(linewidth=3, foreground='#000000')])
ax.text(0, -0.7, 'The Answer', fontsize=14, color='#FFD700', ha='center', 
       va='center', zorder=11, style='italic')

# Seven oracles arranged in a circle
oracles = [
    ('CHRONOS\n(Time)', 'Time ends when\nentropy is maximized.\ndS/dt → 0', '#FF4444', 'I'),
    ('APEIRON\n(Space)', 'Space: eternal expansion\nor violent ripping.\nDepends on w.', '#FF8844', 'II'),
    ('LOGOS\n(Math)', 'Math is inexhaustible.\nGödel forbids\ncompleteness.', '#FFCC44', 'III'),
    ('COSMOS\n(Universe)', 'Stars die. BHs evaporate.\nProtons decay.\nAll is temporary.', '#44FF44', 'IV'),
    ('PSYCHE\n(Mind)', 'Last thought:\ninfinitely slow,\nnever completed.', '#44CCFF', 'V'),
    ('ENTROPEIA\n(Entropy)', 'Information is physical.\n10^120 operations.\nThen: silence.', '#8844FF', 'VI'),
    ('UNNAMED\n(Everything)', 'All math structures exist.\nOur end is local.\n∞ remains.', '#FF44FF', 'VII'),
]

radius = 5.5
for i, (name, insight, color, emoji) in enumerate(oracles):
    angle = 2 * np.pi * i / len(oracles) - np.pi/2
    x = radius * np.cos(angle)
    y = radius * np.sin(angle)
    
    # Oracle circle
    oracle_circle = plt.Circle((x, y), 1.3, facecolor='#0a0a1a', 
                               edgecolor=color, linewidth=2, alpha=0.9, zorder=5)
    ax.add_patch(oracle_circle)
    
    # Oracle name
    ax.text(x, y + 0.5, emoji, fontsize=20, ha='center', va='center', zorder=6)
    ax.text(x, y - 0.1, name, fontsize=9, color=color, ha='center', va='center',
           fontweight='bold', zorder=6)
    
    # Insight text (outside the circle)
    text_radius = 8.0
    tx = text_radius * np.cos(angle)
    ty = text_radius * np.sin(angle)
    ax.text(tx, ty, insight, fontsize=8, color=color, ha='center', va='center',
           alpha=0.7, zorder=6,
           bbox=dict(boxstyle='round,pad=0.3', facecolor='#0a0a1a', 
                    edgecolor=color, alpha=0.5))
    
    # Connection line to center
    ax.plot([0, x*0.3], [0, y*0.3], color=color, alpha=0.3, linewidth=1, zorder=3)
    ax.plot([x*0.75, x], [y*0.75, y], color=color, alpha=0.3, linewidth=1, zorder=3)

# Decorative rings
for r, alpha in [(3.0, 0.15), (4.0, 0.1), (7.0, 0.08), (9.5, 0.05)]:
    ring = plt.Circle((0, 0), r, fill=False, edgecolor='white', 
                      linewidth=0.5, alpha=alpha, zorder=2)
    ax.add_patch(ring)

# Five convergent findings
findings = [
    "1. Time ends as dissolution of meaning, not a moment.",
    "2. Space's fate hangs on one number: w (dark energy EOS).",
    "3. Mathematics is inexhaustible but forever incomplete.",
    "4. The universe is a transient flicker of complexity.",
    "5. Ultimate limit: 10^120 ops. Then: eternal equilibrium.",
]

for i, finding in enumerate(findings):
    y_pos = -10.5 + i * 0.6
    ax.text(0, y_pos, finding, fontsize=10, color='white', ha='center', 
           va='center', alpha=0.7)

# Title
ax.text(0, 10.5, 'THE END OF EVERYTHING', fontsize=28, color='white',
       ha='center', va='center', fontweight='bold',
       path_effects=[pe.withStroke(linewidth=2, foreground='#333333')])
ax.text(0, 9.5, 'A Synthesis by the Oracle Council', fontsize=14, 
       color='white', ha='center', va='center', alpha=0.5, style='italic')

# The question matters more
ax.text(0, -12.5, 
        '"The Answer to the Ultimate Question of Life, the Universe, and Everything is 42.\n'
        'But what is the Question? Perhaps: Why is there something rather than nothing?\n'
        'And perhaps the answer is: because Nothing is unstable."',
        fontsize=11, color='#FFD700', ha='center', va='center', style='italic', alpha=0.6)

ax.set_xlim(-13, 13)
ax.set_ylim(-14, 12)
ax.set_xticks([])
ax.set_yticks([])
for spine in ax.spines.values():
    spine.set_visible(False)

plt.savefig('/workspace/request-project/demos/output/the_answer.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 7: The Answer saved to demos/output/the_answer.png")
