#!/usr/bin/env python3
"""
Visualization 2: Parseval Energy Conservation

Shows the Parseval/Plancherel identity: the total spectral energy
(sum of squared Fourier coefficients) equals the class-function norm
squared. Visualized as an energy balance diagram for multiple test
functions on different groups.
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

def spectral_energy(f, basis, n):
    return sum(abs(cf_inner(f, chi, n))**2 for chi in basis)

# --- Setup ---
np.random.seed(2024)
group_sizes = [4, 6, 8, 10, 12]
n_tests = 5

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Scatter plot <f,f> vs spectral energy
ax1 = axes[0]
norms = []
energies = []
labels = []

for n in group_sizes:
    basis = cyclic_chars(n)
    for _ in range(n_tests):
        f = np.random.randn(n) + 1j * np.random.randn(n)
        ip = cf_inner(f, f, n).real
        e = spectral_energy(f, basis, n)
        norms.append(ip)
        energies.append(e)
        labels.append(n)

norms = np.array(norms)
energies = np.array(energies)
labels = np.array(labels)

for n in group_sizes:
    mask = labels == n
    ax1.scatter(norms[mask], energies[mask], s=80, alpha=0.8,
                label=f'Z/{n}Z', edgecolors='black', linewidth=0.5)

# Perfect line
mn, mx = min(norms.min(), energies.min()), max(norms.max(), energies.max())
ax1.plot([mn, mx], [mn, mx], 'k--', alpha=0.5, label='y = x (Parseval)')
ax1.set_xlabel('⟨f, f⟩ (norm squared)', fontsize=13)
ax1.set_ylabel('Spectral Energy ∑|⟨f,χᵢ⟩|²', fontsize=13)
ax1.set_title('Parseval Identity Verification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Relative error histogram
ax2 = axes[1]
rel_errors = np.abs(norms - energies) / (np.abs(norms) + 1e-15)
ax2.hist(rel_errors, bins=20, color='#673AB7', alpha=0.8, edgecolor='black')
ax2.set_xlabel('Relative Error |⟨f,f⟩ - E(f)| / |⟨f,f⟩|', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Parseval Error Distribution', fontsize=14, fontweight='bold')
ax2.axvline(x=1e-14, color='red', linestyle='--', label='Machine epsilon')
ax2.legend(fontsize=10)
ax2.grid(axis='y', alpha=0.3)

max_err = max(rel_errors)
ax2.text(0.6, 0.85, f'Max relative error:\n{max_err:.1e}',
         transform=ax2.transAxes, fontsize=12,
         bbox=dict(boxstyle='round', facecolor='#E8EAF6', alpha=0.8))

fig.suptitle('Spectral Energy Conservation (Plancherel Theorem)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_parseval_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_parseval_energy.png")
