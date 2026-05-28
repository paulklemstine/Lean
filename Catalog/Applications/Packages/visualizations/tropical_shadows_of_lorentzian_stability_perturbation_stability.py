"""
Visualization: Perturbation Stability Curve

Shows how the tropical spectral gap decreases under increasing perturbation,
confirming the theorem that PSD is preserved when perturbation < gap/4.
The gap/4 bound is compared against the empirical destruction threshold.
"""

import numpy as np
import matplotlib.pyplot as plt

def tropical_spectral_gap_val(W):
    """Compute tropical spectral gap of symmetric matrix W."""
    n = W.shape[0]
    min_gap = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                gap = W[i, i] + W[j, j] - 2 * W[i, j]
                min_gap = min(min_gap, gap)
    return min_gap

def is_trop_psd(W):
    return tropical_spectral_gap_val(W) >= -1e-10

# Base weight: uniform with gap = 4.0
n = 6
d, c = 3.0, 1.0
W_base = np.full((n, n), c)
np.fill_diagonal(W_base, d)
base_gap = tropical_spectral_gap_val(W_base)

# Sweep perturbation sizes
eps_values = np.linspace(0, 2.0, 100)
rng = np.random.RandomState(42)
n_trials = 200

survival_rate = []
avg_gap = []

for eps in eps_values:
    n_survive = 0
    gaps = []
    for _ in range(n_trials):
        delta = rng.uniform(-eps, eps, size=(n, n))
        delta = (delta + delta.T) / 2
        W_pert = W_base + delta
        gap = tropical_spectral_gap_val(W_pert)
        gaps.append(gap)
        if gap >= -1e-10:
            n_survive += 1
    survival_rate.append(n_survive / n_trials)
    avg_gap.append(np.mean(gaps))

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

# Top: Survival rate
ax1.plot(eps_values, survival_rate, 'b-', linewidth=2, label='PSD survival rate')
ax1.axvline(x=base_gap/4, color='red', linestyle='--', linewidth=2,
           label=f'Theorem bound ε = gap/4 = {base_gap/4:.2f}')
ax1.axvspan(0, base_gap/4, alpha=0.1, color='green', label='Guaranteed safe zone')
ax1.set_ylabel('Fraction of trials remaining PSD', fontsize=12)
ax1.set_ylim(-0.05, 1.05)
ax1.legend(fontsize=10, loc='lower left')
ax1.set_title(f'Perturbation Stability (base gap = {base_gap:.1f}, n = {n})',
             fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.3)

# Bottom: Average gap
ax2.plot(eps_values, avg_gap, 'g-', linewidth=2, label='Average perturbed gap')
ax2.plot(eps_values, [base_gap - 4*e for e in eps_values], 'r--', linewidth=1.5,
        label='Worst-case bound: gap - 4ε')
ax2.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax2.axvline(x=base_gap/4, color='red', linestyle='--', linewidth=2)
ax2.set_xlabel('Perturbation size ε', fontsize=12)
ax2.set_ylabel('Tropical spectral gap', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_perturbation.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation.png")
