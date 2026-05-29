#!/usr/bin/env python3
"""
Visualization 1: Spectral Decomposition Heatmap

Visualizes the spectral decomposition of class functions on Z/8Z.
Shows the original function, its Fourier coefficients, and the
reconstructed function as a three-panel figure demonstrating
the exact reconstruction theorem (Theorem 1).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Inline infrastructure ---
def cf_inner(f, g, n):
    return np.sum(f * np.conj(g)) / n

def cyclic_chars(n):
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def spectral_coeffs(f, basis, n):
    return np.array([cf_inner(f, chi, n) for chi in basis])

def reconstruct(f, basis, n):
    c = spectral_coeffs(f, basis, n)
    return sum(c[i] * basis[i] for i in range(len(basis)))

# --- Setup ---
n = 8
basis = cyclic_chars(n)

# Create test signal: mixture of harmonics
signal = 3*basis[0] + 2*basis[1] - 1.5j*basis[3] + basis[6]
coeffs = spectral_coeffs(signal, basis, n)
reconstructed = reconstruct(signal, basis, n)

# --- Figure ---
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Original signal (real and imaginary parts)
ax1 = axes[0]
x = np.arange(n)
ax1.bar(x - 0.15, signal.real, 0.3, label='Real', color='#2196F3', alpha=0.8)
ax1.bar(x + 0.15, signal.imag, 0.3, label='Imaginary', color='#FF9800', alpha=0.8)
ax1.set_xlabel('Group element g ∈ Z/8Z', fontsize=12)
ax1.set_ylabel('f(g)', fontsize=12)
ax1.set_title('Original Class Function', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xticks(x)
ax1.grid(axis='y', alpha=0.3)

# Panel 2: Spectral coefficients (magnitude)
ax2 = axes[1]
magnitudes = np.abs(coeffs)
colors = plt.cm.viridis(magnitudes / max(magnitudes))
bars = ax2.bar(x, magnitudes, color=colors, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Frequency k', fontsize=12)
ax2.set_ylabel('|⟨f, χₖ⟩|', fontsize=12)
ax2.set_title('Spectral Coefficients', fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels([f'χ_{k}' for k in range(n)])
ax2.grid(axis='y', alpha=0.3)

# Annotate nonzero coefficients
for k in range(n):
    if magnitudes[k] > 0.1:
        ax2.annotate(f'{magnitudes[k]:.1f}', (k, magnitudes[k]),
                     ha='center', va='bottom', fontsize=9, fontweight='bold')

# Panel 3: Reconstruction error
ax3 = axes[2]
error = np.abs(signal - reconstructed)
ax3.bar(x, error, color='#4CAF50' if max(error) < 1e-10 else '#F44336', alpha=0.8)
ax3.set_xlabel('Group element g', fontsize=12)
ax3.set_ylabel('|f(g) - P(f)(g)|', fontsize=12)
ax3.set_title('Reconstruction Error', fontsize=14, fontweight='bold')
ax3.set_xticks(x)
ax3.set_ylim(0, max(1e-14, max(error) * 1.5))
ax3.ticklabel_format(axis='y', style='scientific', scilimits=(-2, 2))
ax3.grid(axis='y', alpha=0.3)

# Add verification text
max_err = max(error)
status = "EXACT ✓" if max_err < 1e-10 else f"Error: {max_err:.2e}"
ax3.text(0.5, 0.85, f'Max error: {max_err:.1e}\n{status}',
         transform=ax3.transAxes, ha='center', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))

fig.suptitle('Spectral Moonshine: Exact Reconstruction on Z/8Z',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
