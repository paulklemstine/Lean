"""
Visualization 1: Spectral Gap and Phase Transition

Visualizes how the eigenvalues of the perturbed leaf Hessian (J - I + t·I)
change as t increases from 0 to 2, showing the exact phase transition at t = 1
where the Lorentzian signature breaks down. This is the spectral mechanism
governing Lorentzian stability.
"""

import numpy as np
import matplotlib.pyplot as plt

def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, m in enumerate([3, 5, 8]):
    ax = axes[idx]
    H = leaf_hessian(m)
    ts = np.linspace(0, 2.5, 200)

    all_eigs = []
    for t in ts:
        eigs = np.sort(np.linalg.eigvalsh(H + t * np.eye(m)))[::-1]
        all_eigs.append(eigs)
    all_eigs = np.array(all_eigs)

    # Plot each eigenvalue trajectory
    ax.plot(ts, all_eigs[:, 0], 'b-', linewidth=2, label=f'λ₁ = {m-1} + t')
    for k in range(1, m):
        label = 'λ₂…λₘ = -1 + t' if k == 1 else None
        ax.plot(ts, all_eigs[:, k], 'r-', linewidth=1.5, alpha=0.7, label=label)

    # Mark the critical threshold
    ax.axvline(x=1.0, color='green', linestyle='--', linewidth=2, alpha=0.7,
               label='Critical t* = 1')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

    # Shade regions
    ax.axvspan(0, 1.0, alpha=0.1, color='blue', label='Lorentzian')
    ax.axvspan(1.0, 2.5, alpha=0.1, color='red', label='Non-Lorentzian')

    ax.set_xlabel('Perturbation magnitude t', fontsize=12)
    ax.set_ylabel('Eigenvalue', fontsize=12)
    ax.set_title(f'K_{m} Leaf Hessian (m = {m})', fontsize=14)
    ax.legend(fontsize=8, loc='upper left')
    ax.set_xlim(0, 2.5)
    ax.grid(True, alpha=0.3)

fig.suptitle('Phase Transition in Lorentzian Signature Under Perturbation',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gap.png")
