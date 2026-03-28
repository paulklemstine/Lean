#!/usr/bin/env python3
"""
Demo 1: The Complexity Class Landscape
Visualizes the known inclusion relationships between complexity classes
and highlights the open questions.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(20, 10))

# ──── Left Panel: Inclusion Diagram as Nested Ellipses ────
ax = ax1
ax.set_xlim(-6, 6)
ax.set_ylim(-5, 7)
ax.set_aspect('equal')
ax.set_title('Complexity Class Landscape\n(Known Inclusions)', fontsize=16, fontweight='bold')

# Draw nested ellipses from outermost to innermost
classes = [
    ('EXPSPACE', 0, 1, 5.5, 5.8, '#1a1a2e', 0.15),
    ('EXP', 0, 0.8, 4.8, 5.0, '#16213e', 0.2),
    ('PSPACE', 0, 0.5, 4.0, 4.2, '#0f3460', 0.25),
    ('PH', -0.5, 0.0, 3.2, 3.0, '#533483', 0.3),
    ('BQP', 1.5, -0.5, 2.0, 2.5, '#e94560', 0.2),
    ('NP', -1.0, -0.3, 2.5, 2.2, '#e94560', 0.25),
    ('coNP', 0.8, -0.3, 2.5, 2.2, '#0f3460', 0.2),
    ('BPP', 0, -1.0, 1.8, 1.5, '#f5a623', 0.3),
    ('P', 0, -1.2, 1.3, 1.0, '#2ecc71', 0.5),
    ('L', 0, -1.5, 0.6, 0.4, '#3498db', 0.6),
]

for name, cx, cy, rx, ry, color, alpha in classes:
    ellipse = mpatches.Ellipse((cx, cy), 2*rx, 2*ry, 
                                facecolor=color, alpha=alpha,
                                edgecolor='white', linewidth=2)
    ax.add_patch(ellipse)
    
    # Position labels
    label_offsets = {
        'EXPSPACE': (0, 6.2), 'EXP': (0, 5.2), 'PSPACE': (0, 4.2),
        'PH': (-0.5, 2.5), 'NP': (-2.8, 1.0), 'coNP': (2.8, 1.0),
        'BQP': (3.2, 1.5), 'BPP': (0, -0.2), 'P': (0, -1.2), 'L': (0, -1.5)
    }
    lx, ly = label_offsets.get(name, (cx, cy + ry))
    ax.text(lx, ly, name, ha='center', va='center', fontsize=13, 
            fontweight='bold', color='white',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.8))

# Add question marks for unknown separations
questions = [
    (-1.5, 1.8, 'P ≠ NP?', 12), (1.5, 1.8, 'NP ≠ coNP?', 10),
    (2.5, -0.5, 'P ≠ BQP?', 10), (-2.5, 3.5, 'NP ≠ PSPACE?', 10),
]
for qx, qy, text, size in questions:
    ax.text(qx, qy, text, ha='center', va='center', fontsize=size,
            color='#ff6b6b', fontstyle='italic', fontweight='bold')

# Known separation
ax.annotate('P ⊂ EXP ✓', xy=(0, 3.5), fontsize=11, ha='center',
            color='#2ecc71', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='black', alpha=0.7))

ax.set_facecolor('#0a0a1a')
ax.axis('off')

# ──── Right Panel: The Three Barriers ────
ax = ax2
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_title('The Three Barriers to P vs NP\nand Proposed Bypass Routes', 
             fontsize=16, fontweight='bold')

# Draw barrier walls
barriers = [
    (2, 1, 2, 8, 'Relativization\n(Baker-Gill-\nSolovay 1975)', '#e74c3c'),
    (5, 1, 2, 8, 'Natural Proofs\n(Razborov-\nRudich 1997)', '#e67e22'),
    (8, 1, 2, 8, 'Algebrization\n(Aaronson-\nWigderson 2009)', '#f1c40f'),
]

for bx, by_, bw, bh, label, color in barriers:
    rect = mpatches.FancyBboxPatch((bx, by_), bw, bh,
                                     boxstyle='round,pad=0.1',
                                     facecolor=color, alpha=0.4,
                                     edgecolor=color, linewidth=3)
    ax.add_patch(rect)
    ax.text(bx + bw/2, by_ + bh + 0.3, label, ha='center', va='bottom',
            fontsize=9, fontweight='bold', color=color)

# Draw bypass arrows
# Tropical bypass
ax.annotate('', xy=(4.8, 5), xytext=(1, 5),
            arrowprops=dict(arrowstyle='->', color='#2ecc71', lw=2,
                           connectionstyle='arc3,rad=0.5'))
ax.text(0.5, 6.5, 'Tropical\nSemiring\nBypass?', fontsize=9, color='#2ecc71',
        fontweight='bold', ha='center')

# Stereographic bypass  
ax.annotate('', xy=(7.8, 7), xytext=(4.5, 7),
            arrowprops=dict(arrowstyle='->', color='#3498db', lw=2,
                           connectionstyle='arc3,rad=-0.5'))
ax.text(6, 3.5, 'Stereographic\nProjection\nBypass?', fontsize=9, color='#3498db',
        fontweight='bold', ha='center')

# Combined bypass
ax.annotate('', xy=(10, 5), xytext=(1, 3),
            arrowprops=dict(arrowstyle='->', color='#e056a0', lw=3,
                           connectionstyle='arc3,rad=-0.3', linestyle='dashed'))
ax.text(5.5, 1.5, 'Tropical + Stereographic\nComposition?', fontsize=10, 
        color='#e056a0', fontweight='bold', ha='center',
        bbox=dict(boxstyle='round', facecolor='black', alpha=0.5))

ax.set_facecolor('#0a0a1a')
ax.axis('off')

plt.tight_layout()
plt.savefig('/workspace/request-project/demos/complexity_landscape.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/complexity_landscape.png")
