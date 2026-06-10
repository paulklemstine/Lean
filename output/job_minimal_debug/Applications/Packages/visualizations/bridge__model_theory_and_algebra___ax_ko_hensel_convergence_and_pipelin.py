#!/usr/bin/env python3
"""Visualization: Hensel lifting convergence and theory relationships."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Hensel lifting convergence
ax1 = axes[0]
p = 7
precisions = list(range(1, 8))
errors = [p**(-k) for k in precisions]
ax1.semilogy(precisions, errors, 'bo-', markersize=8, linewidth=2)
ax1.set_xlabel('Precision k', fontsize=12)
ax1.set_ylabel('|f(a_k)| (7-adic)', fontsize=12)
ax1.set_title('Newton-Hensel Lifting Convergence\n(x² - 2 in ℤ₇)', fontsize=13)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(precisions)

# Right: Theory relationship diagram (as a simple chart)
ax2 = axes[1]
categories = ['κ-Categorical', 'Complete', 'Elem. Equiv.', 'Model Transfer']
y_positions = [3, 2, 1, 0]
colors = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c']
ax2.barh(y_positions, [1]*4, color=colors, height=0.5, alpha=0.8)
for i, (cat, y) in enumerate(zip(categories, y_positions)):
    ax2.text(0.5, y, cat, ha='center', va='center', fontsize=11, fontweight='bold', color='white')
# Add arrows
for i in range(len(y_positions)-1):
    ax2.annotate('', xy=(0.5, y_positions[i+1]+0.3), xytext=(0.5, y_positions[i]-0.3),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))
ax2.set_xlim(0, 1)
ax2.set_ylim(-0.5, 3.8)
ax2.set_title('Theorem Pipeline\n(Categoricity → Transfer)', fontsize=13)
ax2.axis('off')

plt.tight_layout()
plt.savefig('ax_kochen_morley_visualization.png', dpi=150, bbox_inches='tight')
print('Saved: ax_kochen_morley_visualization.png')
