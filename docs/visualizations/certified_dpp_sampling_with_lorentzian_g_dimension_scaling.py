"""
Visualization: Dimension Scaling of Certified DPP Bounds

Tests the dimension-free defect transfer conjecture by plotting
how the certified bound and actual defect scale with dimension n.
If the ratio max_defect / certified_bound stays bounded as n grows,
this supports the conjecture.

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


def compute_max_defect(K_prime, n):
    max_def = 0
    for i in range(n):
        for j in range(i + 1, n):
            pair = K_prime[i,i]*K_prime[j,j] - K_prime[i,j]*K_prime[j,i]
            prod = K_prime[i,i] * K_prime[j,j]
            defect = pair - prod
            max_def = max(max_def, defect)
    return max_def


# Parameters
dimensions = [4, 6, 8, 10, 12, 16, 20, 25, 30]
etas = [0.005, 0.01, 0.02]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, eta in enumerate(etas):
    ax = axes[idx]

    max_defects = []
    certified_bounds = []
    Ms = []
    ratios = []

    for n in dimensions:
        K = make_psd_contraction(n, seed=42)
        rng = np.random.RandomState(123)
        noise = rng.uniform(-eta, eta, (n, n))
        noise = (noise + noise.T) / 2
        K_prime = K + noise

        eta_actual = np.max(np.abs(K - K_prime))
        M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))

        max_def = compute_max_defect(K_prime, n)

        bound = 6 * M * eta_actual

        max_defects.append(max_def)
        certified_bounds.append(bound)
        Ms.append(M)
        ratios.append(max_def / bound if bound > 1e-15 else 0)

    ax.plot(dimensions, certified_bounds, 'r--o', linewidth=2,
            markersize=6, label='Certified bound (6Mη)')
    ax.plot(dimensions, max_defects, 'b-s', linewidth=2,
            markersize=6, label='Actual max defect')
    ax.fill_between(dimensions, max_defects, certified_bounds,
                    alpha=0.15, color='green')

    # Add ratio on secondary axis
    ax2 = ax.twinx()
    ax2.plot(dimensions, ratios, 'g:^', linewidth=1.5,
             markersize=5, alpha=0.7, label='Ratio')
    ax2.set_ylabel('Defect / Bound ratio', fontsize=10, color='green')
    ax2.tick_params(axis='y', labelcolor='green')
    ax2.set_ylim(0, 1.0)

    ax.set_xlabel('Dimension n', fontsize=11)
    ax.set_ylabel('Defect value', fontsize=11)
    ax.set_title(f'η = {eta}', fontsize=13)
    ax.legend(loc='upper left', fontsize=9)
    ax.grid(True, alpha=0.3)

fig.suptitle('Dimension Scaling of Certified DPP Bounds\n'
             '(Testing dimension-free conjecture)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_dimension_scaling.png', dpi=150, bbox_inches='tight')
print("Saved: viz_dimension_scaling.png")
