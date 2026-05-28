#!/usr/bin/env python3
"""
Visualization: Coefficient Perturbation Bound Verification
==========================================================
Demonstrates that the proved coefficient Lipschitz bound
|a_k(J') - a_k(J)| ≤ (exp(βn²δ) - 1)(a_k(J) + a_k(J'))
holds with substantial margin across all coefficient indices and
multiple random perturbation trials.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def field_poly_coeffs(n, beta, J):
    """Compute Ising field polynomial coefficients."""
    coeffs = np.zeros(n + 1)
    for bits in iterproduct([0, 1], repeat=n):
        sigma = np.array([1 if b else -1 for b in bits])
        k = sum(bits)
        energy = sigma @ J @ sigma
        coeffs[k] += np.exp(beta * energy)
    return coeffs


def curie_weiss_coupling(n, J_val=1.0):
    """Curie–Weiss coupling matrix."""
    J = np.full((n, n), J_val / n)
    np.fill_diagonal(J, 0)
    return J


np.random.seed(42)

n = 6
beta = 1.0
delta = 0.02
trials = 100

J = curie_weiss_coupling(n)
coeffs_orig = field_poly_coeffs(n, beta, J)
factor = np.exp(beta * n**2 * delta) - 1

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: bound verification for each k
ax = axes[0]
all_ratios = {k: [] for k in range(n + 1)}

for _ in range(trials):
    dJ = np.random.uniform(-delta, delta, (n, n))
    dJ = (dJ + dJ.T) / 2
    np.fill_diagonal(dJ, 0)
    coeffs_pert = field_poly_coeffs(n, beta, J + dJ)

    for k in range(n + 1):
        diff = abs(coeffs_pert[k] - coeffs_orig[k])
        bound = factor * (coeffs_orig[k] + coeffs_pert[k])
        ratio = diff / (bound + 1e-15)
        all_ratios[k].append(ratio)

positions = list(range(n + 1))
box_data = [all_ratios[k] for k in positions]
bp = ax.boxplot(box_data, positions=positions, widths=0.6,
                patch_artist=True, showfliers=True)

for patch in bp['boxes']:
    patch.set_facecolor('steelblue')
    patch.set_alpha(0.7)

ax.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label='Proved upper bound')
ax.set_xlabel('Coefficient index k', fontsize=12)
ax.set_ylabel('|Δa_k| / bound', fontsize=12)
ax.set_title(f'Coefficient Bound Ratio (n={n}, β={beta}, δ={delta})', fontsize=13)
ax.set_ylim(-0.05, 1.5)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, axis='y')

# Right: coefficient profile comparison
ax2 = axes[1]
ax2.bar(np.arange(n+1) - 0.15, coeffs_orig, width=0.3, color='blue',
        alpha=0.7, label='a_k(J)')

# Show one perturbed example
dJ = np.random.uniform(-delta, delta, (n, n))
dJ = (dJ + dJ.T) / 2
np.fill_diagonal(dJ, 0)
coeffs_ex = field_poly_coeffs(n, beta, J + dJ)
ax2.bar(np.arange(n+1) + 0.15, coeffs_ex, width=0.3, color='red',
        alpha=0.7, label='a_k(J\')')

# Add error bars showing the bound
bounds = factor * (coeffs_orig + coeffs_ex)
ax2.errorbar(np.arange(n+1) + 0.15, coeffs_ex,
             yerr=bounds, fmt='none', ecolor='darkred', capsize=3, alpha=0.5,
             label='Perturbation bound')

ax2.set_xlabel('Coefficient index k', fontsize=12)
ax2.set_ylabel('Coefficient value', fontsize=12)
ax2.set_title('Field Polynomial Coefficients', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_coefficient_bound.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: viz_coefficient_bound.png")
