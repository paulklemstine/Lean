#!/usr/bin/env python3
"""
Visualization: Modularity and Frobenius Traces

This script visualizes the relationship between elliptic curve Frobenius
traces a_p and barcode statistics, testing the barcode modularity
conjecture: that primewise persistence barcodes contain information
about modular form coefficients.

Key insight: the Hasse bound |a_p| ≤ 2√p constrains Frobenius traces,
and barcode entropy may correlate with trace magnitude.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def count_curve_points(a, b, p):
    count = 1
    for x in range(p):
        rhs = (x**3 + a*x + b) % p
        for y in range(p):
            if (y*y - rhs) % p == 0:
                count += 1
    return count


# Curves to test
curves = [
    (0, -1, "y² = x³ - 1", '#e74c3c'),
    (-1, 0, "y² = x³ - x", '#3498db'),
    (0, 1, "y² = x³ + 1", '#2ecc71'),
    (1, 1, "y² = x³ + x + 1", '#9b59b6'),
    (-2, 1, "y² = x³ - 2x + 1", '#e67e22'),
]

primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Frobenius Traces and the Barcode Modularity Conjecture',
             fontsize=16, fontweight='bold')

# Plot 1: a_p vs p for multiple curves
ax1 = axes[0, 0]
for a_coeff, b_coeff, name, color in curves:
    ap_data = []
    p_data = []
    for p in primes:
        disc = (-16 * (4 * a_coeff**3 + 27 * b_coeff**2)) % p
        if disc == 0:
            continue
        n_p = count_curve_points(a_coeff, b_coeff, p)
        a_p = p + 1 - n_p
        ap_data.append(a_p)
        p_data.append(p)
    ax1.plot(p_data, ap_data, 'o-', color=color, label=name, markersize=6, alpha=0.8)

# Hasse bound
p_smooth = np.linspace(3, 45, 100)
ax1.fill_between(p_smooth, -2*np.sqrt(p_smooth), 2*np.sqrt(p_smooth),
                 alpha=0.1, color='gray', label='Hasse bound')
ax1.plot(p_smooth, 2*np.sqrt(p_smooth), 'k--', alpha=0.3)
ax1.plot(p_smooth, -2*np.sqrt(p_smooth), 'k--', alpha=0.3)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Frobenius trace a_p', fontsize=12)
ax1.set_title('Frobenius Traces with Hasse Bound', fontsize=13)
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.3)

# Plot 2: |a_p|² distribution (Sato-Tate)
ax2 = axes[0, 1]
all_normalized = []
for a_coeff, b_coeff, name, color in curves:
    for p in primes:
        disc = (-16 * (4 * a_coeff**3 + 27 * b_coeff**2)) % p
        if disc == 0:
            continue
        n_p = count_curve_points(a_coeff, b_coeff, p)
        a_p = p + 1 - n_p
        normalized = a_p / (2 * math.sqrt(p))
        all_normalized.append(normalized)

ax2.hist(all_normalized, bins=20, color='#3498db', edgecolor='black', alpha=0.7, density=True)
# Sato-Tate distribution
theta = np.linspace(-1, 1, 200)
sato_tate = (2/math.pi) * np.sqrt(1 - theta**2)
sato_tate[np.isnan(sato_tate)] = 0
ax2.plot(theta, sato_tate, 'r-', linewidth=2, label='Sato-Tate')
ax2.set_xlabel('a_p / (2√p)', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Normalized Trace Distribution', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Point counts #E(F_p) vs p
ax3 = axes[1, 0]
for a_coeff, b_coeff, name, color in curves:
    np_data = []
    p_data = []
    for p in primes:
        disc = (-16 * (4 * a_coeff**3 + 27 * b_coeff**2)) % p
        if disc == 0:
            continue
        n_p = count_curve_points(a_coeff, b_coeff, p)
        np_data.append(n_p)
        p_data.append(p)
    ax3.plot(p_data, np_data, 's-', color=color, label=name, markersize=5, alpha=0.8)

ax3.plot(p_smooth, p_smooth + 1, 'k--', alpha=0.3, label='p + 1')
ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('#E(𝔽_p)', fontsize=12)
ax3.set_title('Elliptic Curve Point Counts', fontsize=13)
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Plot 4: Heatmap of a_p values
ax4 = axes[1, 1]
curve_names = [name for _, _, name, _ in curves]
ap_matrix = []
good_primes = []
for p in primes:
    row = []
    all_good = True
    for a_coeff, b_coeff, name, color in curves:
        disc = (-16 * (4 * a_coeff**3 + 27 * b_coeff**2)) % p
        if disc == 0:
            row.append(float('nan'))
            all_good = False
        else:
            n_p = count_curve_points(a_coeff, b_coeff, p)
            a_p = p + 1 - n_p
            row.append(a_p)
    if all_good:
        ap_matrix.append(row)
        good_primes.append(p)

if ap_matrix:
    im = ax4.imshow(np.array(ap_matrix).T, aspect='auto', cmap='RdBu_r',
                     interpolation='nearest')
    ax4.set_xticks(range(len(good_primes)))
    ax4.set_xticklabels([str(p) for p in good_primes], fontsize=9)
    ax4.set_yticks(range(len(curve_names)))
    ax4.set_yticklabels([n.replace('y² = ', '') for n in curve_names], fontsize=9)
    ax4.set_xlabel('Prime p', fontsize=12)
    ax4.set_ylabel('Curve', fontsize=12)
    ax4.set_title('Frobenius Trace Heatmap', fontsize=13)
    plt.colorbar(im, ax=ax4, label='a_p')

plt.tight_layout()
plt.savefig('viz_modularity.png', dpi=150, bbox_inches='tight')
print("Saved viz_modularity.png")
