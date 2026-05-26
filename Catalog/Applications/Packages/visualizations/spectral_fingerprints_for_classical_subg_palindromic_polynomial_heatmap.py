#!/usr/bin/env python3
"""
Visualization 2: Palindromic Polynomial Constraint Heatmap

This visualization shows the palindromic (self-reciprocal) constraint on
characteristic polynomials. For each 2x2 matrix over GF(p), we compute
its characteristic polynomial and check whether it is palindromic.
The heatmap reveals the structural constraint imposed by the symplectic
condition: all Sp_2 ≅ SL_2 elements have palindromic charpolys.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compute_charpoly_stats(p):
    """For each possible charpoly (const_term, linear_coeff), count occurrences
    in GL_2 and SL_2, and mark if palindromic."""
    # Possible charpolys: x^2 + a1*x + a0 with a0 != 0
    stats = {}

    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if det == 0:
                        continue
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    key = (const_term, linear_coeff)

                    if key not in stats:
                        stats[key] = {'gl2': 0, 'sl2': 0, 'palindromic': const_term == 1}
                    stats[key]['gl2'] += 1
                    if det == 1:
                        stats[key]['sl2'] += 1

    return stats

# Compute for p = 7
p = 7
stats = compute_charpoly_stats(p)

# Create matrices for heatmaps
gl2_counts = np.zeros((p, p))
sl2_counts = np.zeros((p, p))
palindromic_mask = np.zeros((p, p))
irreducible_mask = np.zeros((p, p))

for (a0, a1), data in stats.items():
    gl2_counts[a0, a1] = data['gl2']
    sl2_counts[a0, a1] = data['sl2']
    if data['palindromic']:
        palindromic_mask[a0, a1] = 1

    # Check irreducibility
    disc = (a1 * a1 - 4 * a0) % p
    if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
        irreducible_mask[a0, a1] = 1

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: GL_2 charpoly distribution
im1 = axes[0, 0].imshow(gl2_counts, cmap='Blues', aspect='auto',
                          interpolation='nearest', origin='lower')
axes[0, 0].set_title('GL₂(F₇): Charpoly Distribution', fontsize=12, fontweight='bold')
axes[0, 0].set_xlabel('Linear coefficient a₁')
axes[0, 0].set_ylabel('Constant term a₀')
plt.colorbar(im1, ax=axes[0, 0], label='Count')

# Plot 2: SL_2 charpoly distribution
im2 = axes[0, 1].imshow(sl2_counts, cmap='Reds', aspect='auto',
                          interpolation='nearest', origin='lower')
axes[0, 1].set_title('SL₂(F₇): Charpoly Distribution', fontsize=12, fontweight='bold')
axes[0, 1].set_xlabel('Linear coefficient a₁')
axes[0, 1].set_ylabel('Constant term a₀')
plt.colorbar(im2, ax=axes[0, 1], label='Count')

# Plot 3: Palindromic constraint
colors = np.zeros((*gl2_counts.shape, 3))
for i in range(p):
    for j in range(p):
        if palindromic_mask[i, j]:
            if irreducible_mask[i, j]:
                colors[i, j] = [0.2, 0.6, 0.2]  # green = palindromic & irreducible
            else:
                colors[i, j] = [0.3, 0.3, 0.8]  # blue = palindromic & reducible
        elif gl2_counts[i, j] > 0:
            if irreducible_mask[i, j]:
                colors[i, j] = [0.8, 0.3, 0.3]  # red = non-palindromic & irreducible
            else:
                colors[i, j] = [0.9, 0.9, 0.5]  # yellow = non-palindromic & reducible
        else:
            colors[i, j] = [0.95, 0.95, 0.95]  # white = no elements

axes[1, 0].imshow(colors, aspect='auto', interpolation='nearest', origin='lower')
axes[1, 0].set_title('Polynomial Classification (F₇)', fontsize=12, fontweight='bold')
axes[1, 0].set_xlabel('Linear coefficient a₁')
axes[1, 0].set_ylabel('Constant term a₀')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=[0.2, 0.6, 0.2], label='Palindromic & Irreducible'),
    Patch(facecolor=[0.3, 0.3, 0.8], label='Palindromic & Reducible'),
    Patch(facecolor=[0.8, 0.3, 0.3], label='Non-palindromic & Irreducible'),
    Patch(facecolor=[0.9, 0.9, 0.5], label='Non-palindromic & Reducible'),
]
axes[1, 0].legend(handles=legend_elements, fontsize=8, loc='upper right')

# Plot 4: Rate comparison bar chart
primes_list = [3, 5, 7, 11, 13]
gl2_rates = [p_val / (2 * (p_val + 1)) for p_val in primes_list]
sl2_rates = [(p_val - 1) / (2 * p_val) for p_val in primes_list]

x = np.arange(len(primes_list))
width = 0.35

bars1 = axes[1, 1].bar(x - width/2, gl2_rates, width, label='GL₂',
                         color='steelblue', alpha=0.8)
bars2 = axes[1, 1].bar(x + width/2, sl2_rates, width, label='SL₂',
                         color='indianred', alpha=0.8)

axes[1, 1].set_xlabel('Field size q', fontsize=12)
axes[1, 1].set_ylabel('Irreducible rate', fontsize=12)
axes[1, 1].set_title('Rate Separation by Field Size', fontsize=12, fontweight='bold')
axes[1, 1].set_xticks(x)
axes[1, 1].set_xticklabels([f'F_{p_val}' for p_val in primes_list])
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3, axis='y')
axes[1, 1].axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('palindromic_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved palindromic_heatmap.png")
