#!/usr/bin/env python3
"""
Visualization: Phase Transition in Lorentzian Stability

Shows the sharp phase transition: below γ_min/n perturbation the polynomial
stays Lorentzian; above it, the signature breaks. Illustrates for uniform
matroid Hessians of various dimensions.
"""

import numpy as np
import matplotlib.pyplot as plt

def uniform_leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def is_lorentzian(A, tol=1e-10):
    eigs = np.linalg.eigvalsh(A)
    return int(np.sum(eigs > tol)) <= 1

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: phase transition curves
m_values = [4, 6, 8, 10, 15]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(m_values)))

for m, color in zip(m_values, colors):
    H = uniform_leaf_hessian(m)
    gamma = 1.0  # known spectral gap
    critical = gamma / m  # predicted stability radius

    # Sweep perturbation magnitude
    fractions = np.linspace(0, 3.0, 60)
    stability_probs = []

    for frac in fractions:
        tol_val = frac * critical
        n_stable = 0
        n_trials = 200
        for _ in range(n_trials):
            E = np.random.uniform(-tol_val, tol_val, (m, m))
            E = (E + E.T) / 2
            if is_lorentzian(H + E):
                n_stable += 1
        stability_probs.append(n_stable / n_trials)

    axes[0].plot(fractions, stability_probs, '-', color=color, linewidth=2,
                 label=f'm={m}')
    axes[0].axvline(x=1.0, color='red', linestyle='--', alpha=0.5)

axes[0].set_xlabel('Perturbation / (γ_min/n)', fontsize=12)
axes[0].set_ylabel('Pr[Lorentzian preserved]', fontsize=12)
axes[0].set_title('Phase Transition in Lorentzian Stability', fontsize=14)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].annotate('Universal\nthreshold', xy=(1.0, 0.5), fontsize=10, color='red',
                 ha='center')

# Right: eigenvalue spectrum under perturbation
m = 8
H = uniform_leaf_hessian(m)
critical = 1.0 / m

frac_values = [0, 0.5, 1.0, 1.5, 2.0]
all_eigs = []
labels = []

for frac in frac_values:
    tol_val = frac * critical
    eigs_list = []
    for _ in range(100):
        E = np.random.uniform(-tol_val, tol_val, (m, m))
        E = (E + E.T) / 2
        eigs = np.linalg.eigvalsh(H + E)
        eigs_list.append(eigs)
    all_eigs.append(np.array(eigs_list))
    labels.append(f'{frac:.1f}×ρ')

positions = np.arange(len(frac_values))
bp = axes[1].boxplot([eigs[:, -1] for eigs in all_eigs],
                      positions=positions, widths=0.35,
                      patch_artist=True, showfliers=False)
for patch, color in zip(bp['boxes'], plt.cm.RdYlGn(np.linspace(0.8, 0.2, len(frac_values)))):
    patch.set_facecolor(color)

# Also plot second eigenvalue
bp2 = axes[1].boxplot([eigs[:, -2] for eigs in all_eigs],
                       positions=positions + 0.4, widths=0.35,
                       patch_artist=True, showfliers=False)
for patch in bp2['boxes']:
    patch.set_facecolor('#aaaaaa')

axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5)
axes[1].set_xticks(positions + 0.2)
axes[1].set_xticklabels(labels)
axes[1].set_xlabel('Perturbation level', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title(f'Eigenvalue Distribution (m={m})', fontsize=14)
axes[1].legend([bp['boxes'][0], bp2['boxes'][0]],
               ['Largest eigenvalue', '2nd largest eigenvalue'], fontsize=9)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('perturbation_phase.png', dpi=150, bbox_inches='tight')
print("Saved perturbation_phase.png")
