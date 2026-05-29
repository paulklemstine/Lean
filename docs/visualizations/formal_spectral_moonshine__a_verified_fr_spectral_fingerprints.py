#!/usr/bin/env python3
"""
Visualization: Spectral Fingerprints of Class Functions

Visualizes how class functions decompose into irreducible character components,
showing the spectral weight distribution as a heatmap across different
representations and group elements.

This illustrates the core insight of formal spectral moonshine: class functions
on finite groups have a unique "frequency decomposition" analogous to Fourier
analysis, where irreducible characters play the role of frequency components.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# ============================================================
# Self-contained character table data
# ============================================================

def s4_data():
    table = np.array([
        [1,  1,  1,  1,  1],
        [1, -1,  1, -1,  1],
        [2,  0, -1,  0,  2],
        [3,  1,  0, -1, -1],
        [3, -1,  0,  1, -1],
    ], dtype=complex)
    sizes = np.array([1, 6, 8, 6, 3])
    return table, sizes, 24, ['1', 'sgn', '2', 'std', 'sgn⊗std'], \
           ['e', '(12)', '(123)', '(1234)', '(12)(34)']

def a5_data():
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    table = np.array([
        [1,  1,   1,    1,    1   ],
        [3, -1,   0,    phi,  psi ],
        [3, -1,   0,    psi,  phi ],
        [4,  0,   1,   -1,   -1   ],
        [5,  1,  -1,    0,    0   ],
    ], dtype=complex)
    sizes = np.array([1, 15, 20, 12, 12])
    return table, sizes, 60, ['1', '3a', '3b', '4', '5'], \
           ['e', '(12)(34)', '(123)', '(12345)', '(13245)']

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

def fingerprint(f, table, sizes, order):
    coeffs = decode(f, table, sizes, order)
    weights = np.abs(coeffs) ** 2
    total = np.sum(weights)
    return weights / total if total > 0 else weights

# ============================================================
# Create the visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Panel 1: S₄ spectral decomposition heatmap ---
ax = axes[0, 0]
table, sizes, order, irr_names, class_names = s4_data()

# Various class functions to decompose
test_functions = {
    'trivial χ': table[0],
    'sign χ': table[1],
    'standard χ': table[3],
    'regular': np.array([24, 0, 0, 0, 0], dtype=complex),
    'custom 1': np.array([5, 1, 2, 0, 1], dtype=complex),
    'custom 2': np.array([3, -1, 0, 1, 3], dtype=complex),
}

fp_matrix = np.array([fingerprint(f, table, sizes, order) for f in test_functions.values()])
im = ax.imshow(fp_matrix, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1)
ax.set_xticks(range(len(irr_names)))
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_yticks(range(len(test_functions)))
ax.set_yticklabels(list(test_functions.keys()), fontsize=9)
ax.set_xlabel('Irreducible representation', fontsize=10)
ax.set_ylabel('Class function', fontsize=10)
ax.set_title('S₄: Spectral Fingerprints', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, label='Spectral weight')

# --- Panel 2: A₅ Fourier coefficients ---
ax = axes[0, 1]
table, sizes, order, irr_names, class_names = a5_data()

# Decompose the character of each irreducible (should give delta functions)
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
bar_width = 0.15
x = np.arange(len(irr_names))
for i, name in enumerate(irr_names):
    coeffs = decode(table[i], table, sizes, order)
    ax.bar(x + i * bar_width, np.real(coeffs), bar_width,
           label=f'χ_{{{name}}}', color=colors[i], alpha=0.8)

ax.set_xticks(x + bar_width * 2)
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_xlabel('Basis character', fontsize=10)
ax.set_ylabel('Fourier coefficient', fontsize=10)
ax.set_title('A₅: Orthogonality (δ_{ij})', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, ncol=2)
ax.axhline(y=0, color='gray', linewidth=0.5)

# --- Panel 3: Log-concavity of symmetric power dimensions ---
ax = axes[1, 0]
dims = [3, 4, 5]
for d in dims:
    n_vals = list(range(20))
    sym_dims = [comb(d + n - 1, n) for n in n_vals]
    ax.plot(n_vals, sym_dims, 'o-', markersize=3, label=f'dim V = {d}')

ax.set_xlabel('Degree n', fontsize=10)
ax.set_ylabel('dim Sym^n(V)', fontsize=10)
ax.set_title('Symmetric Power Growth', fontsize=12, fontweight='bold')
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Log-concavity ratio ---
ax = axes[1, 1]
for d in dims:
    n_vals = list(range(2, 25))
    ratios = []
    for n in n_vals:
        a_prev = comb(d + n - 2, n - 1)
        a_curr = comb(d + n - 1, n)
        a_next = comb(d + n, n + 1)
        ratio = a_curr ** 2 / (a_prev * a_next) if a_prev * a_next > 0 else 0
        ratios.append(ratio)
    ax.plot(n_vals, ratios, 'o-', markersize=3, label=f'dim V = {d}')

ax.axhline(y=1, color='red', linewidth=1, linestyle='--', label='log-concavity threshold')
ax.set_xlabel('Degree n', fontsize=10)
ax.set_ylabel('a(n)² / (a(n-1)·a(n+1))', fontsize=10)
ax.set_title('Log-Concavity Ratio (>1 = log-concave)', fontsize=12, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.95, 1.35)

plt.suptitle('Formal Spectral Moonshine: Visualizations', fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('spectral_fingerprints.png', dpi=150, bbox_inches='tight')
print("Saved spectral_fingerprints.png")
