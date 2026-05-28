#!/usr/bin/env python3
"""
Visualization 2: Hessian Scalar Factor Heatmap

Visualizes the Hessian scalar factor hessianScalar(β, i, j) as a heatmap
for 2-variable polynomials. Shows why this factor is always positive
over ℚ (characteristic zero) but can vanish over finite fields.

The scalar factor (β(i)+1) × ((β+eᵢ)(j)+1) determines whether a
predicted Hessian monomial actually appears. Its positivity is the
key to the non-cancellation theorem.
"""

import matplotlib.pyplot as plt
import numpy as np


def hessian_scalar_2d(bx, by, i, j):
    """Compute Hessian scalar for 2D exponent (bx, by) and var pair (i,j)."""
    beta = [bx, by]
    factor1 = beta[i] + 1
    beta_plus_ei = list(beta)
    beta_plus_ei[i] += 1
    factor2 = beta_plus_ei[j] + 1
    return factor1 * factor2


def hessian_scalar_mod_p(bx, by, i, j, p):
    """Compute Hessian scalar modulo p."""
    val = hessian_scalar_2d(bx, by, i, j)
    return val % p


max_exp = 8

fig, axes = plt.subplots(2, 4, figsize=(18, 9))

# Top row: scalar values over ℚ for each (i,j) pair
var_pairs = [(0, 0), (0, 1), (1, 0), (1, 1)]
var_labels = ["∂₀∂₀ (∂²/∂x²)", "∂₀∂₁ (∂²/∂x∂y)",
              "∂₁∂₀ (∂²/∂y∂x)", "∂₁∂₁ (∂²/∂y²)"]

for idx, ((i, j), label) in enumerate(zip(var_pairs, var_labels)):
    ax = axes[0][idx]
    data = np.zeros((max_exp, max_exp))
    for bx in range(max_exp):
        for by in range(max_exp):
            data[by, bx] = hessian_scalar_2d(bx, by, i, j)

    im = ax.imshow(data, origin='lower', cmap='YlOrRd', aspect='equal',
                   vmin=1, vmax=max_exp * (max_exp + 1))

    # Annotate cells
    for bx in range(max_exp):
        for by in range(max_exp):
            val = int(data[by, bx])
            color = 'white' if val > max_exp * (max_exp + 1) * 0.6 else 'black'
            ax.text(bx, by, str(val), ha='center', va='center',
                   fontsize=7, color=color)

    ax.set_title(label, fontsize=10, fontweight='bold')
    ax.set_xlabel("β(x)")
    ax.set_ylabel("β(y)")
    ax.set_xticks(range(max_exp))
    ax.set_yticks(range(max_exp))

axes[0][0].set_ylabel("Over ℚ: β(y)", fontsize=11, fontweight='bold')

# Bottom row: scalar values mod 2, mod 3, mod 5, mod 7
primes = [2, 3, 5, 7]
for idx, p in enumerate(primes):
    ax = axes[1][idx]
    # Use (i,j) = (0,0) for comparison
    data = np.zeros((max_exp, max_exp))
    for bx in range(max_exp):
        for by in range(max_exp):
            data[by, bx] = hessian_scalar_mod_p(bx, by, 0, 0, p)

    # Color: 0 = red (cancellation!), nonzero = green
    cmap = plt.cm.RdYlGn
    im = ax.imshow(data, origin='lower', cmap=cmap, aspect='equal',
                   vmin=0, vmax=p - 1)

    for bx in range(max_exp):
        for by in range(max_exp):
            val = int(data[by, bx])
            color = 'white' if val == 0 else 'black'
            fontweight = 'bold' if val == 0 else 'normal'
            ax.text(bx, by, str(val), ha='center', va='center',
                   fontsize=7, color=color, fontweight=fontweight)

    zero_count = np.sum(data == 0)
    ax.set_title(f"mod {p} (∂₀∂₀): {zero_count} zeros", fontsize=10,
                fontweight='bold')
    ax.set_xlabel("β(x)")
    ax.set_xticks(range(max_exp))
    ax.set_yticks(range(max_exp))

axes[1][0].set_ylabel(f"Over F_p: β(y)", fontsize=11, fontweight='bold')

plt.suptitle(
    "Hessian Scalar Factor: Always Positive over ℚ, Can Vanish mod p\n"
    "Red cells (0) = cancellation occurs — the shadow prediction fails",
    fontsize=14, fontweight='bold', y=1.02
)
plt.tight_layout()
plt.savefig("visualize_scalar.png", dpi=150, bbox_inches='tight')
print("Saved visualize_scalar.png")
