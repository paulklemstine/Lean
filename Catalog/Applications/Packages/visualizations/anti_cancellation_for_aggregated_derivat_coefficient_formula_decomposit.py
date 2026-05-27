#!/usr/bin/env python3
"""
Visualization: Coefficient Formula Decomposition
==================================================

Visualizes the key identity powering the anti-cancellation theorem:

  [beta](D_A f) = sum_{i,j} A_{ij} * c_{ij}(beta) * [beta + e_i + e_j] f

Shows how each term in the sum contributes nonnegatively, and how the
existence of a witness alpha in the support guarantees strict positivity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def compute_contributions(coeffs, A, beta, n):
    """Compute individual contributions A_{ij} * c_{ij} * f[alpha] for each (i,j)."""
    contributions = np.zeros((n, n))
    alphas = {}
    for i in range(n):
        for j in range(n):
            alpha = list(beta)
            if i == j:
                mult = (beta[i] + 1) * (beta[i] + 2)
                alpha[i] += 2
            else:
                mult = (beta[i] + 1) * (beta[j] + 1)
                alpha[i] += 1
                alpha[j] += 1
            f_alpha = coeffs.get(tuple(alpha), 0.0)
            contributions[i, j] = A[i, j] * mult * f_alpha
            alphas[(i, j)] = (tuple(alpha), mult, f_alpha)
    return contributions, alphas


# Setup: f = x1^3 + 2*x1^2*x2 + x1*x2^2 + x1^2*x3 + x2^2*x3 + x3^3
n = 3
coeffs = {
    (3, 0, 0): 1.0,
    (2, 1, 0): 2.0,
    (1, 2, 0): 1.0,
    (2, 0, 1): 1.0,
    (0, 2, 1): 1.0,
    (0, 0, 3): 1.0,
    (1, 1, 1): 1.5,
}

A = np.array([[2.0, 1.0, 0.5],
              [1.0, 3.0, 1.0],
              [0.5, 1.0, 2.0]])

# Choose beta = (1, 0, 0) — degree 1
beta = (1, 0, 0)

contributions, alphas = compute_contributions(coeffs, A, beta, n)
total = contributions.sum()

# Create figure
fig = plt.figure(figsize=(14, 8))
gs = gridspec.GridSpec(2, 2, height_ratios=[1, 1.2], hspace=0.4, wspace=0.3)

# --- Panel 1: Contribution heatmap ---
ax1 = fig.add_subplot(gs[0, 0])
im = ax1.imshow(contributions, cmap='YlOrRd', aspect='auto', vmin=0)
ax1.set_title(f'Contributions to [β](D_A f)\nβ = {beta}', fontweight='bold')
ax1.set_xlabel('j (second derivative index)')
ax1.set_ylabel('i (first derivative index)')
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))
ax1.set_xticklabels([f'x{k+1}' for k in range(n)])
ax1.set_yticklabels([f'x{k+1}' for k in range(n)])

for i in range(n):
    for j in range(n):
        val = contributions[i, j]
        color = 'white' if val > contributions.max() * 0.6 else 'black'
        ax1.text(j, i, f'{val:.2f}', ha='center', va='center', color=color, fontsize=10)

plt.colorbar(im, ax=ax1, label='Contribution A·c·f[α]')

# --- Panel 2: Weight matrix A ---
ax2 = fig.add_subplot(gs[0, 1])
im2 = ax2.imshow(A, cmap='Blues', aspect='auto')
ax2.set_title('Weight Matrix A\n(all entries > 0)', fontweight='bold')
ax2.set_xlabel('j')
ax2.set_ylabel('i')
ax2.set_xticks(range(n))
ax2.set_yticks(range(n))
ax2.set_xticklabels([f'x{k+1}' for k in range(n)])
ax2.set_yticklabels([f'x{k+1}' for k in range(n)])
for i in range(n):
    for j in range(n):
        ax2.text(j, i, f'{A[i,j]:.1f}', ha='center', va='center', fontsize=12)
plt.colorbar(im2, ax=ax2, label='Weight A_{ij}')

# --- Panel 3: Bar chart of contributions ---
ax3 = fig.add_subplot(gs[1, :])
labels = []
values = []
colors = []
for i in range(n):
    for j in range(n):
        alpha, mult, f_alpha = alphas[(i, j)]
        labels.append(f'({i+1},{j+1})\nα={alpha}\nc={mult}·{f_alpha:.1f}')
        values.append(contributions[i, j])
        if contributions[i, j] > 0:
            colors.append('#e74c3c' if f_alpha > 0 else '#3498db')
        else:
            colors.append('#95a5a6')

bars = ax3.bar(range(len(values)), values, color=colors, edgecolor='black', linewidth=0.5)
ax3.set_xticks(range(len(labels)))
ax3.set_xticklabels(labels, fontsize=7, rotation=0)
ax3.set_ylabel('Contribution to [β](D_A f)', fontsize=10)
ax3.set_title(
    f'Decomposition: [β](D_A f) = Σᵢⱼ Aᵢⱼ · cᵢⱼ(β) · f[β+eᵢ+eⱼ] = {total:.2f} > 0\n'
    f'Every term ≥ 0 (nonneg coefficients + positive weights). '
    f'At least one witness α ∈ supp(f) ⟹ total > 0.',
    fontsize=10, fontweight='bold'
)
ax3.axhline(y=0, color='black', linewidth=0.5)

# Add total annotation
ax3.annotate(f'Total = {total:.2f}', xy=(len(values)-1, total),
             xytext=(len(values)-2, total * 0.85),
             fontsize=11, fontweight='bold', color='darkred',
             arrowprops=dict(arrowstyle='->', color='darkred'))

plt.suptitle('Anti-Cancellation Coefficient Formula: Why Positive Aggregation Preserves Support',
             fontsize=13, fontweight='bold', y=1.0)
plt.tight_layout()
plt.savefig('coefficient_formula_decomposition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: coefficient_formula_decomposition.png")
