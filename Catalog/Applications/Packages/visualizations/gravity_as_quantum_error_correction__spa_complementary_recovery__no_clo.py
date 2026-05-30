#!/usr/bin/env python3
"""
Visualization 2: Complementary Recovery (No-Cloning for Spacetime)

Visualizes the complementary recovery theorem: for the [[5,1,3]] code,
a boundary region can reconstruct the bulk if and only if its size ≥ 3.
If region A corrects, complement Ā cannot (quantum no-cloning).
"""

import matplotlib.pyplot as plt
import numpy as np

# [[5,1,3]] code parameters
n, k, d = 5, 1, 3

fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

# Plot 1: Reconstruction threshold
ax1 = axes[0]
sizes = np.arange(0, n + 1)
can_correct = [n - s < d for s in sizes]
complement_corrects = [s < d for s in sizes]

colors = ['#2ecc71' if c else '#e74c3c' for c in can_correct]
bars = ax1.bar(sizes, [1] * len(sizes), color=colors, edgecolor='black', linewidth=0.5)

# Add labels
for i, (s, c) in enumerate(zip(sizes, can_correct)):
    ax1.text(s, 0.5, '✓' if c else '✗',
             ha='center', va='center', fontsize=20, fontweight='bold',
             color='white')

ax1.set_xlabel('Boundary Region Size |A|', fontsize=13)
ax1.set_ylabel('')
ax1.set_title('[[5,1,3]] Code: Can Region A Reconstruct Bulk?', fontsize=14)
ax1.set_xticks(sizes)
ax1.set_yticks([])

# Add threshold line
ax1.axvline(x=2.5, color='blue', linestyle='--', linewidth=2, alpha=0.7)
ax1.text(2.7, 0.85, f'threshold\n|A| = n-d+1 = {n-d+1}',
         fontsize=10, color='blue', va='top')

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='Can reconstruct'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='Cannot reconstruct'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=10)

# Plot 2: Complementary recovery visualization
ax2 = axes[1]

# For each size, show whether A and Ā can correct
for s in sizes:
    a_corrects = n - s < d
    complement_size = n - s
    a_bar_corrects = s < d  # complement of complement

    y = n - s  # map size to y for visual
    # Region A
    color_a = '#2ecc71' if a_corrects else '#e74c3c'
    ax2.barh(s, s, height=0.35, left=0, color=color_a, edgecolor='black',
             linewidth=0.5, label='A' if s == 0 else '')

    # Complement Ā
    color_comp = '#3498db' if a_bar_corrects else '#f39c12'
    ax2.barh(s, complement_size, height=0.35, left=s, color=color_comp,
             edgecolor='black', linewidth=0.5, label='Ā' if s == 0 else '')

    # Annotate
    if s > 0:
        ax2.text(s/2, s + 0.02, f'A={s}', ha='center', va='bottom', fontsize=8)
    if complement_size > 0:
        ax2.text(s + complement_size/2, s + 0.02, f'Ā={complement_size}',
                 ha='center', va='bottom', fontsize=8)

    # Check: at most one can correct
    if a_corrects and a_bar_corrects:
        ax2.text(5.3, s, '⚠ BOTH', fontsize=9, color='red', va='center')
    elif a_corrects:
        ax2.text(5.3, s, 'A only', fontsize=9, color='green', va='center')
    elif a_bar_corrects:
        ax2.text(5.3, s, 'Ā only', fontsize=9, color='blue', va='center')
    else:
        ax2.text(5.3, s, 'neither', fontsize=9, color='gray', va='center')

ax2.set_xlabel('Qubit Position', fontsize=13)
ax2.set_ylabel('Region Size |A|', fontsize=13)
ax2.set_title('No-Cloning: A and Ā Cannot Both Correct', fontsize=14)
ax2.set_xlim(-0.5, 7)
ax2.set_yticks(sizes)

legend_elements2 = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='A corrects'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='A fails'),
    Patch(facecolor='#3498db', edgecolor='black', label='Ā corrects'),
    Patch(facecolor='#f39c12', edgecolor='black', label='Ā fails'),
]
ax2.legend(handles=legend_elements2, loc='lower right', fontsize=9)

plt.tight_layout()
plt.savefig('complementary_recovery.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved complementary_recovery.png")
