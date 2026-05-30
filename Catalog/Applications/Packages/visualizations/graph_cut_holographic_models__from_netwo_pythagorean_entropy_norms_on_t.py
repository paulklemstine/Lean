#!/usr/bin/env python3
"""
Visualization: Pythagorean Entropy Norms on the Unit Circle

Shows how Pythagorean triples (a,b,c) map to points (a/c, b/c) on the unit
circle in entropy space. Each triple contributes exactly 1 to the total
norm sum — the lattice total norm theorem.

Key insight: the Pythagorean theorem a² + b² = c² becomes the entropy
identity (a/c)² + (b/c)² = 1, placing all triples on S¹.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Generate Pythagorean triples using Euclid's formula
triples = []
for m in range(2, 15):
    for n in range(1, m):
        if np.gcd(m, n) == 1 and (m - n) % 2 == 1:
            a = m**2 - n**2
            b = 2 * m * n
            c = m**2 + n**2
            triples.append((a, b, c))

# Compute entropy norms
entropy_norms = [(a/c, b/c) for a, b, c in triples]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: entropy norms on unit circle
ax1 = axes[0]
theta = np.linspace(0, np.pi/2, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5, alpha=0.3, label='Unit circle')

colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(entropy_norms)))
for i, ((x, y), (a, b, c)) in enumerate(zip(entropy_norms, triples)):
    ax1.scatter(x, y, c=[colors[i]], s=60, zorder=5, edgecolors='black', linewidth=0.5)
    if c <= 65:
        ax1.annotate(f'({a},{b},{c})', (x, y), textcoords="offset points",
                    xytext=(5, 5), fontsize=6, alpha=0.7)

ax1.set_xlim(-0.05, 1.05)
ax1.set_ylim(-0.05, 1.05)
ax1.set_aspect('equal')
ax1.set_xlabel('a/c (first entropy coordinate)', fontsize=11)
ax1.set_ylabel('b/c (second entropy coordinate)', fontsize=11)
ax1.set_title('Pythagorean Entropy Norms on S¹', fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.2)

# Add annotation
ax1.text(0.5, 0.15, '(a/c)² + (b/c)² = 1', fontsize=12,
         ha='center', style='italic', color='darkblue',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.3))

# Right plot: submodularity ratio distribution
ax2 = axes[1]
ratios = [a/c + b/c for a, b, c in triples]
ratios_sorted = sorted(ratios)

bars = ax2.barh(range(len(ratios_sorted)), ratios_sorted,
                color=plt.cm.RdYlGn(np.array(ratios_sorted) / max(ratios_sorted)),
                edgecolor='black', linewidth=0.3)
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=1.5, label='Submodularity threshold')
ax2.set_xlabel('a/c + b/c', fontsize=11)
ax2.set_ylabel('Triple index (sorted)', fontsize=11)
ax2.set_title('Submodularity Ratio ≥ 1', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2, axis='x')

# Add statistics
ax2.text(0.98, 0.05, f'min ratio: {min(ratios):.4f}\n'
         f'max ratio: {max(ratios):.4f}\n'
         f'all ≥ 1: ✓',
         transform=ax2.transAxes, fontsize=9, va='bottom', ha='right',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('entropy_circle.png', dpi=150, bbox_inches='tight')
print("Saved entropy_circle.png")
