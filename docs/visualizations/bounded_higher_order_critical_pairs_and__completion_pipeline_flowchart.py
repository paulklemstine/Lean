#!/usr/bin/env python3
"""
Visualize the Bounded Completion Pipeline.

This script creates a flowchart-style visualization of the bounded
higher-order Knuth-Bendix completion pipeline modulo β, showing how
critical pair analysis leads to local confluence certificates.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')
ax.set_title('Bounded Higher-Order Completion Pipeline Modulo β',
             fontsize=16, fontweight='bold', pad=20)

# Color scheme
box_color = '#3498db'
check_color = '#2ecc71'
fail_color = '#e74c3c'
cert_color = '#9b59b6'
bridge_color = '#f39c12'

def draw_box(ax, x, y, w, h, text, color, fontsize=10):
    rect = patches.FancyBboxPatch((x, y), w, h,
                                   boxstyle="round,pad=0.15",
                                   facecolor=color, edgecolor='white',
                                   alpha=0.9, linewidth=2)
    ax.add_patch(rect)
    ax.text(x + w/2, y + h/2, text, ha='center', va='center',
            fontsize=fontsize, color='white', fontweight='bold',
            wrap=True)

def draw_arrow(ax, x1, y1, x2, y2, label='', color='#34495e'):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx + 0.3, my, label, fontsize=8, color=color,
                style='italic')

# Step 1: Input system
draw_box(ax, 5, 8.5, 4, 0.8, 'Rewrite System E\n(rules with Miller patterns)', box_color)

# Step 2: Check properties
draw_box(ax, 1, 7, 3.5, 0.7, 'Check:\nLeft-linear?', check_color, 9)
draw_box(ax, 5.25, 7, 3.5, 0.7, 'Check:\nMiller patterns?', check_color, 9)
draw_box(ax, 9.5, 7, 3.5, 0.7, 'Choose bound N', bridge_color, 9)

draw_arrow(ax, 5.5, 8.5, 2.75, 7.7)
draw_arrow(ax, 7, 8.5, 7, 7.7)
draw_arrow(ax, 8.5, 8.5, 11.25, 7.7)

# Step 3: Enumerate critical pairs
draw_box(ax, 3.5, 5.5, 7, 0.8,
         'Enumerate β-Critical Pairs up to size N\n'
         'betaCriticalPairsUpTo N E', box_color)

draw_arrow(ax, 2.75, 7, 5.5, 6.3, 'yes')
draw_arrow(ax, 7, 7, 7, 6.3)
draw_arrow(ax, 11.25, 7, 8.5, 6.3)

# Step 4: Check joinability
draw_box(ax, 3.5, 4, 7, 0.7,
         'For each pair (s, t): try joining s and t\n'
         'by bounded normalization', check_color)

draw_arrow(ax, 7, 5.5, 7, 4.7)

# Step 5: Decision
draw_box(ax, 1, 2.5, 4.5, 0.7, 'All joinable?\n→ LOCAL CONFLUENCE ✓', check_color)
draw_box(ax, 8.5, 2.5, 4.5, 0.7, 'Some non-joinable?\n→ Report pair ✗', fail_color)

draw_arrow(ax, 5.5, 4, 3.25, 3.2, 'yes')
draw_arrow(ax, 8.5, 4, 10.75, 3.2, 'no')

# Step 6: Certificate / Newman's lemma
draw_box(ax, 0.5, 0.8, 5.5, 0.8,
         'CompletionCertificateβ\n'
         '+ Newman\'s Lemma → Unique NFs', cert_color)

draw_arrow(ax, 3.25, 2.5, 3.25, 1.6)

# Step 7: Cross-domain
draw_box(ax, 0.5, -0.3, 5.5, 0.7,
         'Cross-domain: Coherent compiler optimization\n'
         'Word problem decidability', bridge_color, 9)

draw_arrow(ax, 3.25, 0.8, 3.25, 0.4)

# Annotations
ax.text(13, 5.9, 'Theorem:\nbounded_confluence_\nfrom_joinable_cps',
        fontsize=8, color=box_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

ax.text(13, 3.5, 'Theorem:\ncompletion_pipeline_\nnewman',
        fontsize=8, color=cert_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

ax.text(13, 1.5, 'Theorem:\nword_problem_\ndecidability',
        fontsize=8, color=bridge_color, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1', alpha=0.8))

plt.tight_layout()
plt.savefig('completion_pipeline.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: completion_pipeline.png")
