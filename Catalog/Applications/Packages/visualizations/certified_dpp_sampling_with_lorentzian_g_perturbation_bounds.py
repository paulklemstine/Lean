"""
Visualization: Certified Perturbation Bounds for DPP Negative Dependence

This script visualizes how the certified defect bound (6Mη) compares to
the actual negative dependence defect as the perturbation η varies.
It demonstrates the key result from certified_approx_dpp_sound:
the certified bound is always valid, and the actual defect grows
linearly in η, consistent with our theorems.

CRITICAL: This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def make_psd_contraction(n, seed=42):
    rng = np.random.RandomState(seed)
    A = rng.randn(n, n)
    K = A @ A.T / (2 * n)
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    return (K + K.T) / 2


def dpp_pair_incl(K, i, j):
    return K[i, i] * K[j, j] - K[i, j] * K[j, i]


def dpp_single_incl(K, i):
    return K[i, i]


# Generate kernel
n = 6
K = make_psd_contraction(n, seed=42)

# Sweep over perturbation levels
etas = np.linspace(0, 0.1, 50)
max_defects = []
certified_bounds = []
detailed_bounds = []

for eta in etas:
    rng = np.random.RandomState(123)
    noise = rng.uniform(-eta, eta, (n, n))
    noise = (noise + noise.T) / 2
    K_prime = K + noise

    eta_actual = np.max(np.abs(K - K_prime))
    M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))

    max_def = 0
    max_detail = 0
    for i in range(n):
        for j in range(i + 1, n):
            defect = (dpp_pair_incl(K_prime, i, j) -
                     dpp_single_incl(K_prime, i) * dpp_single_incl(K_prime, j))
            max_def = max(max_def, defect)

            detail = (abs(K[j,j]) + abs(K_prime[i,i]) + abs(K[i,j]) +
                      abs(K_prime[j,i]) + abs(K[i,i]) + abs(K_prime[j,j])) * eta_actual
            max_detail = max(max_detail, detail)

    max_defects.append(max_def)
    certified_bounds.append(6 * M * eta_actual)
    detailed_bounds.append(max_detail)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Defect vs certified bound
ax = axes[0]
ax.plot(etas, max_defects, 'b-', linewidth=2, label='Actual max defect')
ax.plot(etas, certified_bounds, 'r--', linewidth=2, label='Certified bound (6Mη)')
ax.plot(etas, detailed_bounds, 'g:', linewidth=2, label='Detailed bound')
ax.fill_between(etas, max_defects, certified_bounds, alpha=0.15, color='green',
                label='Certificate margin')
ax.set_xlabel('Perturbation η', fontsize=12)
ax.set_ylabel('Negative dependence defect', fontsize=12)
ax.set_title('Certified DPP Perturbation Bounds (n=6)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Ratio (tightness)
ax = axes[1]
ratios = [d / c if c > 1e-12 else 0 for d, c in zip(max_defects, certified_bounds)]
ax.plot(etas[1:], ratios[1:], 'purple', linewidth=2)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Bound = 1')
ax.set_xlabel('Perturbation η', fontsize=12)
ax.set_ylabel('Actual defect / Certified bound', fontsize=12)
ax.set_title('Certificate Tightness Ratio', fontsize=13)
ax.set_ylim(0, 1.1)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_perturbation_bounds.png', dpi=150, bbox_inches='tight')
print("Saved: viz_perturbation_bounds.png")
