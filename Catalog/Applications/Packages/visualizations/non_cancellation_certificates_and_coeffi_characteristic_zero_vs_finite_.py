#!/usr/bin/env python3
"""
Visualization 2: Characteristic Zero vs Finite Field Contrast

Shows how derivative scalar factors behave across different characteristics.
Over ℚ (characteristic 0), all scalars are nonzero — the support prediction
is always exact. Over F_p, some scalars vanish mod p, creating spurious
cancellations that break the prediction.

This visualizes the deep reason why the non-cancellation bridge works in
characteristic zero but fails over finite fields.
"""
import matplotlib.pyplot as plt
import numpy as np


def hessian_scalar(beta, i, j):
    """Compute the derivative scalar factor."""
    beta_j_plus_1 = beta[j] + 1
    beta_plus_ej_i = beta[i] + (1 if i == j else 0)
    return (beta_plus_ej_i + 1) * beta_j_plus_1


# Generate a range of 2-variable exponents
max_exp = 8
betas = []
scalars_diag = []  # i = j = 0
scalars_off = []   # i = 0, j = 1

for a in range(max_exp):
    for b in range(max_exp):
        beta = (a, b)
        betas.append(beta)
        scalars_diag.append(hessian_scalar(beta, 0, 0))  # ∂₀∂₀
        scalars_off.append(hessian_scalar(beta, 0, 1))    # ∂₀∂₁

# Check which scalars vanish mod p for various primes
primes = [2, 3, 5, 7]

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

for idx, p in enumerate(primes):
    ax = axes[idx // 2][idx % 2]

    # Create matrix: color by whether scalar vanishes mod p
    diag_matrix = np.zeros((max_exp, max_exp))
    off_matrix = np.zeros((max_exp, max_exp))

    for a in range(max_exp):
        for b in range(max_exp):
            beta = (a, b)
            s_diag = hessian_scalar(beta, 0, 0)
            s_off = hessian_scalar(beta, 0, 1)

            # 0 = nonzero mod p, 1 = zero mod p (cancellation!)
            if s_diag % p == 0:
                diag_matrix[a, b] = 2  # diagonal cancellation
            if s_off % p == 0:
                off_matrix[a, b] = 1   # off-diagonal cancellation

    combined = np.maximum(diag_matrix, off_matrix)

    cmap = plt.cm.colors.ListedColormap(['#2ecc71', '#f39c12', '#e74c3c'])
    bounds = [0, 0.5, 1.5, 2.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

    im = ax.imshow(combined, cmap=cmap, norm=norm, origin='lower', aspect='equal')
    ax.set_title(f"Characteristic p = {p}", fontsize=13, fontweight='bold')
    ax.set_xlabel("β₁ (exponent of x₁)", fontsize=11)
    ax.set_ylabel("β₀ (exponent of x₀)", fontsize=11)
    ax.set_xticks(range(max_exp))
    ax.set_yticks(range(max_exp))

    # Count cancellations
    n_cancel = int(np.sum(combined > 0))
    n_total = max_exp * max_exp
    ax.text(0.5, -0.12,
            f"Cancellations: {n_cancel}/{n_total} "
            f"({100*n_cancel/n_total:.0f}%)",
            transform=ax.transAxes, ha='center', fontsize=10)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', label='No cancellation (scalar ≢ 0 mod p)'),
    Patch(facecolor='#f39c12', label='Off-diagonal cancel (∂₀∂₁ scalar ≡ 0)'),
    Patch(facecolor='#e74c3c', label='Diagonal cancel (∂₀² scalar ≡ 0)'),
]

fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           fontsize=11, bbox_to_anchor=(0.5, -0.02))

plt.suptitle("Derivative Scalar Cancellations by Characteristic\n"
             "Green = safe (char 0 is always all green), Red/Orange = spurious cancellation",
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("viz_char_contrast.png", dpi=150, bbox_inches='tight')
print("Saved viz_char_contrast.png")
