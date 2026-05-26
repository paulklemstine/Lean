#!/usr/bin/env python3
"""
Visualization: Free-Energy Landscape for Barcode-Weighted Decoding

Illustrates the zero-temperature selection principle: the free-energy functional
F(C) = E(C) + λ·Φ(C) creates a landscape where corrections with low base weight
AND low vulnerability are preferred. As λ increases, high-vulnerability corrections
become increasingly penalized, steering the decoder away from logical corridors.

This visualizes the cross-domain connection between statistical mechanics and
quantum error correction: decoding as free-energy minimization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def free_energy(energy, entropy, lam):
    """F = E + λ·Φ"""
    return energy + lam * entropy


# Generate correction candidates
np.random.seed(123)
n_corrections = 50
energies = np.random.exponential(2.0, n_corrections)
entropies = np.random.exponential(1.5, n_corrections)

# Mark some as "logical corridor" corrections (high entropy)
logical_mask = entropies > np.percentile(entropies, 75)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: Energy vs Entropy scatter
ax = axes[0, 0]
ax.scatter(energies[~logical_mask], entropies[~logical_mask],
           c='steelblue', alpha=0.7, s=40, label='Benign corrections')
ax.scatter(energies[logical_mask], entropies[logical_mask],
           c='crimson', alpha=0.7, s=40, marker='^', label='Logical corridor')
ax.set_xlabel('Base Weight E(C)', fontsize=11)
ax.set_ylabel('Vulnerability Φ(C)', fontsize=11)
ax.set_title('Correction Candidates', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 2: Free energy at different λ
ax = axes[0, 1]
lambdas = [0, 0.5, 1.0, 2.0]
colors = ['gray', 'steelblue', 'orange', 'crimson']
for lam, color in zip(lambdas, colors):
    F = free_energy(energies, entropies, lam)
    sorted_idx = np.argsort(F)
    ax.plot(range(n_corrections), F[sorted_idx], '-o', color=color,
            markersize=3, label=f'λ = {lam}', alpha=0.8)
ax.set_xlabel('Correction Index (sorted)', fontsize=11)
ax.set_ylabel('Free Energy F(C)', fontsize=11)
ax.set_title('Free Energy at Different λ', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 3: Winner changes with λ
ax = axes[1, 0]
lam_range = np.linspace(0, 3, 100)
winner_energy = []
winner_entropy = []
winner_is_logical = []

for lam in lam_range:
    F = free_energy(energies, entropies, lam)
    best = np.argmin(F)
    winner_energy.append(energies[best])
    winner_entropy.append(entropies[best])
    winner_is_logical.append(logical_mask[best])

ax.plot(lam_range, winner_energy, 'b-', linewidth=2, label='Winner E(C)')
ax.plot(lam_range, winner_entropy, 'r--', linewidth=2, label='Winner Φ(C)')
ax.fill_between(lam_range, 0, max(max(winner_energy), max(winner_entropy)),
                where=winner_is_logical, alpha=0.15, color='red',
                label='Winner in corridor')
ax.set_xlabel('Penalty Parameter λ', fontsize=11)
ax.set_ylabel('Winner Properties', fontsize=11)
ax.set_title('Optimal Correction vs λ', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Separation theorem illustration
ax = axes[1, 1]
E1, E2 = 3.0, 4.0
Phi1, Phi2 = 2.0, 0.5
lam_range2 = np.linspace(0, 5, 200)
F1 = E1 + lam_range2 * Phi1
F2 = E2 + lam_range2 * Phi2

ax.plot(lam_range2, F1, 'b-', linewidth=2.5, label=f'C₁: E={E1}, Φ={Phi1} (corridor)')
ax.plot(lam_range2, F2, 'g-', linewidth=2.5, label=f'C₂: E={E2}, Φ={Phi2} (benign)')

# Find crossing point
lam_cross = (E2 - E1) / (Phi1 - Phi2) if Phi1 != Phi2 else 0
F_cross = E1 + lam_cross * Phi1
ax.plot(lam_cross, F_cross, 'ro', markersize=10, zorder=5)
ax.annotate(f'Separation at λ={lam_cross:.1f}',
            xy=(lam_cross, F_cross), xytext=(lam_cross + 0.5, F_cross + 1),
            fontsize=9, arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

ax.fill_between(lam_range2, F1, F2, where=F2 < F1, alpha=0.15, color='green',
                label='Benign wins')
ax.fill_between(lam_range2, F1, F2, where=F1 < F2, alpha=0.15, color='blue',
                label='Corridor wins')

ax.set_xlabel('Penalty Parameter λ', fontsize=11)
ax.set_ylabel('Free Energy F(C)', fontsize=11)
ax.set_title('Spectral Gap Separation Theorem', fontsize=12, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')

fig.suptitle('Free-Energy Landscape for Tropical Barcode Decoding',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_free_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_free_energy_landscape.png")
