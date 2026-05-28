#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability Phase Diagram

Shows how the number of positive eigenvalues changes as perturbation
magnitude increases, illustrating the sharp phase transition at the
spectral gap boundary (δ = 1 for single-block leaves).
"""

import numpy as np
import matplotlib.pyplot as plt


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram for different block sizes
ax1 = axes[0]
deltas = np.linspace(0, 2.5, 200)
n_trials = 50

for m, color, marker in [(3, '#2196F3', 'o'), (4, '#4CAF50', 's'),
                           (5, '#FF9800', '^'), (6, '#9C27B0', 'D')]:
    H = build_single_block_hessian(m)
    frac_lorentzian = []

    for delta in deltas:
        count = 0
        for _ in range(n_trials):
            E = np.random.randn(m, m)
            E = (E + E.T) / 2
            eigs_E = np.linalg.eigvalsh(E)
            if max(abs(eigs_E)) > 0:
                E = E / max(abs(eigs_E)) * delta

            perturbed = H + E
            eigs = np.linalg.eigvalsh(perturbed)
            if np.sum(eigs > 1e-10) <= 1:
                count += 1
        frac_lorentzian.append(count / n_trials)

    ax1.plot(deltas, frac_lorentzian, color=color, linewidth=2,
            label=f'm = {m}', alpha=0.8)

ax1.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7,
           label='Gap = 1 (certified boundary)')
ax1.fill_between([0, 1], [0, 0], [1.1, 1.1], alpha=0.1, color='green')
ax1.fill_between([1, 2.5], [0, 0], [1.1, 1.1], alpha=0.1, color='red')

ax1.set_xlabel('Perturbation magnitude δ', fontsize=12)
ax1.set_ylabel('Fraction preserving Lorentzian signature', fontsize=12)
ax1.set_title('Single-Block Stability Phase Diagram', fontsize=14, fontweight='bold')
ax1.set_ylim(-0.05, 1.05)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax1.annotate('Certified\nstable zone', xy=(0.5, 0.5), fontsize=11,
            color='green', ha='center', fontweight='bold')
ax1.annotate('May\nbreak', xy=(1.75, 0.5), fontsize=11,
            color='red', ha='center', fontweight='bold')

# Panel 2: Eigenvalue trajectories under increasing perturbation
ax2 = axes[1]
m = 4
H = build_single_block_hessian(m)

# Fixed perturbation direction, varying magnitude
E_base = np.random.randn(m, m)
E_base = (E_base + E_base.T) / 2
E_base = E_base / max(abs(np.linalg.eigvalsh(E_base)))

deltas_fine = np.linspace(0, 3.0, 300)
all_eigs = []

for delta in deltas_fine:
    eigs = np.linalg.eigvalsh(H + delta * E_base)
    all_eigs.append(sorted(eigs))

all_eigs = np.array(all_eigs)

for j in range(m):
    color = 'red' if all_eigs[0, j] > 0.1 else 'blue'
    ax2.plot(deltas_fine, all_eigs[:, j], linewidth=2, alpha=0.8, color=color)

ax2.axhline(y=0, color='gray', linestyle='-', linewidth=1, alpha=0.5)
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax2.fill_between([0, 1], [-5, -5], [5, 5], alpha=0.05, color='green')

ax2.set_xlabel('Perturbation magnitude δ', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Eigenvalue Trajectories (m={m})', fontsize=14, fontweight='bold')
ax2.set_ylim(-4, 5)
ax2.grid(True, alpha=0.3)
ax2.annotate('Second eigenvalue\ncrosses zero →\nLorentzian breaks',
            xy=(1.0, 0.5), xytext=(1.8, 2.5),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='red'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Perturbation Stability of Single-Block Leaf Hessians',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_perturbation_stability.png")
