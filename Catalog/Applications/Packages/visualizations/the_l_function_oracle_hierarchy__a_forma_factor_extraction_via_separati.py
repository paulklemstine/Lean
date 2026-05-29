#!/usr/bin/env python3
"""
Visualization 3: Factor Extraction via Separating Invariants

Shows how GCD computation with a separating invariant immediately
recovers a prime factor of a semiprime. Visualizes the GCD landscape
and the geometric meaning of separating invariants.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: GCD landscape for n = 77 = 7 × 11
ax1 = axes[0]
n = 77
p, q = 7, 11

a_values = np.arange(1, 78)
gcds = [math.gcd(int(a), n) for a in a_values]

colors = []
for g in gcds:
    if g == p:
        colors.append('#4CAF50')  # green = found p
    elif g == q:
        colors.append('#2196F3')  # blue = found q
    elif g == n:
        colors.append('#9C27B0')  # purple = found n (trivial)
    else:
        colors.append('#F44336')  # red = gcd = 1 (failure)

ax1.bar(a_values, gcds, color=colors, edgecolor='none', width=0.8)
ax1.set_xlabel('Candidate invariant a', fontsize=12)
ax1.set_ylabel('gcd(a, 77)', fontsize=12)
ax1.set_title(f'GCD Landscape for n = {n} = {p} × {q}', fontsize=13, fontweight='bold')

# Add horizontal lines at p and q
ax1.axhline(y=p, color='#4CAF50', linestyle='--', alpha=0.5, label=f'p = {p}')
ax1.axhline(y=q, color='#2196F3', linestyle='--', alpha=0.5, label=f'q = {q}')

from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#4CAF50', label=f'gcd = {p} (found p)'),
    Patch(facecolor='#2196F3', label=f'gcd = {q} (found q)'),
    Patch(facecolor='#F44336', label='gcd = 1 (no factor)'),
    Patch(facecolor='#9C27B0', label=f'gcd = {n} (trivial)'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=8)
ax1.grid(True, alpha=0.2)

# Panel 2: Separating invariant principle diagram
ax2 = axes[1]
ax2.set_xlim(-0.5, 5.5)
ax2.set_ylim(-0.5, 4.5)
ax2.axis('off')
ax2.set_title('Separating Invariant Principle', fontsize=13, fontweight='bold')

# Draw the number n = p × q
ax2.text(2.75, 4.0, 'n = p × q', fontsize=16, ha='center', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='orange'))

# Draw p and q circles
circle_p = plt.Circle((1.5, 2.5), 0.8, fill=True, facecolor='#4CAF50',
                       alpha=0.3, edgecolor='#4CAF50', linewidth=2)
circle_q = plt.Circle((4.0, 2.5), 0.8, fill=True, facecolor='#2196F3',
                       alpha=0.3, edgecolor='#2196F3', linewidth=2)
ax2.add_patch(circle_p)
ax2.add_patch(circle_q)
ax2.text(1.5, 2.5, 'p', fontsize=20, ha='center', va='center', fontweight='bold',
         color='#2E7D32')
ax2.text(4.0, 2.5, 'q', fontsize=20, ha='center', va='center', fontweight='bold',
         color='#1565C0')

# Draw the separating invariant a
ax2.annotate('a', xy=(1.5, 1.5), fontsize=18, ha='center', fontweight='bold',
            color='#E65100',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF3E0', edgecolor='#FF6F00'))

# Arrows showing divisibility
ax2.annotate('', xy=(1.5, 1.9), xytext=(1.5, 1.65),
            arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))
ax2.text(0.8, 1.7, 'p | a ✓', fontsize=11, color='#2E7D32', fontweight='bold')

ax2.annotate('', xy=(4.0, 1.9), xytext=(3.0, 1.65),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax2.text(3.2, 1.3, 'q ∤ a ✗', fontsize=11, color='#F44336', fontweight='bold')

# Result
ax2.text(2.75, 0.3, 'gcd(a, n) = p', fontsize=14, ha='center', fontweight='bold',
         color='#4CAF50',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#4CAF50'))

# Panel 3: Factorization success rate as function of search space
ax3 = axes[2]

# For various semiprimes, plot how quickly we find a separating invariant
semiprimes = [
    (3, 5), (7, 11), (13, 17), (23, 29), (37, 41),
    (53, 59), (71, 73), (97, 101), (127, 131), (151, 157)
]

n_values = []
first_success = []

for p, q in semiprimes:
    n = p * q
    n_values.append(n)
    # Find first a in [2, n) that gives a nontrivial factor
    for a in range(2, n):
        g = math.gcd(a, n)
        if 1 < g < n:
            first_success.append(a)
            break

ax3.scatter(n_values, first_success, c='#4CAF50', s=100, zorder=5, edgecolors='black')
ax3.plot(n_values, first_success, 'g--', alpha=0.5)

# Add labels for smallest factor
for i, (p, q) in enumerate(semiprimes):
    ax3.annotate(f'{p}×{q}', (n_values[i], first_success[i]),
                textcoords="offset points", xytext=(5, 10),
                fontsize=7, alpha=0.7)

ax3.set_xlabel('Semiprime n = p × q', fontsize=12)
ax3.set_ylabel('First separating invariant a', fontsize=12)
ax3.set_title('First Separating Invariant Found', fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3)

# Add note
ax3.text(0.95, 0.05,
         'For n = p·q, the first\nseparating invariant\nis always ≤ min(p, q)',
         transform=ax3.transAxes, fontsize=9, ha='right', va='bottom',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                  edgecolor='orange', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_factor_extraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_factor_extraction.png")
