#!/usr/bin/env python3
"""
Visualization: Fourier Inversion on Finite Groups

Demonstrates the core mathematical result: any class function on a finite group
can be perfectly reconstructed from its inner products with irreducible characters.

This is the finite-group analogue of Fourier inversion, and the mathematical
foundation of the "moonshine decoder" — the algorithm that extracts representation-
theoretic information from q-series coefficient data.
"""

import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# Self-contained data
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

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

# ============================================================
# Build the visualization
# ============================================================

table, sizes, order, irr_names, class_names = s4_data()
num_irreps = len(irr_names)

# Choose a class function to decompose
f = np.array([7, 1, -2, 3, 1], dtype=complex)

# Compute Fourier coefficients
coeffs = decode(f, table, sizes, order)

# Progressive reconstruction
fig, axes = plt.subplots(2, 3, figsize=(16, 9))

# Top row: progressive reconstruction
for k in range(5):
    ax = axes[0, k] if k < 3 else axes[1, k - 3]
    
    # Reconstruct with first k+1 components
    reconstructed = np.zeros(len(class_names), dtype=complex)
    for i in range(k + 1):
        reconstructed += coeffs[i] * table[i]
    
    x = np.arange(len(class_names))
    width = 0.35
    
    ax.bar(x - width/2, np.real(f), width, label='Original f', color='steelblue', alpha=0.7)
    ax.bar(x + width/2, np.real(reconstructed), width, label=f'Reconstructed (k={k+1})',
           color='coral', alpha=0.7)
    
    error = np.linalg.norm(f - reconstructed)
    ax.set_title(f'Using {k+1}/{num_irreps} components\nError: {error:.4f}',
                fontsize=10, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(class_names, fontsize=8, rotation=30)
    ax.set_ylabel('Value', fontsize=9)
    ax.legend(fontsize=7)
    ax.axhline(y=0, color='gray', linewidth=0.5)

# Bottom right: Fourier coefficients
ax = axes[1, 2]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
bars = ax.bar(range(num_irreps), np.real(coeffs), color=colors, alpha=0.8)
ax.set_xticks(range(num_irreps))
ax.set_xticklabels(irr_names, fontsize=9)
ax.set_xlabel('Irreducible character', fontsize=10)
ax.set_ylabel('Fourier coefficient ⟨f, χ⟩', fontsize=10)
ax.set_title('Spectral Decomposition\nof f', fontsize=10, fontweight='bold')
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.grid(True, alpha=0.3, axis='y')

# Add coefficient values
for i, (bar, c) in enumerate(zip(bars, coeffs)):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            f'{np.real(c):.2f}', ha='center', va='bottom', fontsize=9, fontweight='bold')

plt.suptitle(
    f'Fourier Inversion on S₄: f = {[int(np.real(x)) for x in f]}\n'
    f'f(g) = Σᵢ ⟨f, χᵢ⟩ · χᵢ(g) — Progressive Reconstruction',
    fontsize=13, fontweight='bold', y=1.02
)
plt.tight_layout()
plt.savefig('fourier_inversion.png', dpi=150, bbox_inches='tight')
print("Saved fourier_inversion.png")
