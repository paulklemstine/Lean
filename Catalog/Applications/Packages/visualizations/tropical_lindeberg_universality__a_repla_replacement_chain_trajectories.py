"""
Visualization 3: Lindeberg Replacement Chain — Tropical Margin Trajectory

Visualizes the core mechanism of the Lindeberg replacement principle:
as entries of matrix A are replaced one-by-one with entries of matrix B,
the tropical margin traces a bounded trajectory. The telescoping inequality
guarantees that the total change is controlled by the sum of step-wise changes.

This is the combinatorial backbone of the universality theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


def build_replacement_chain_margins(A, B):
    """Build the replacement chain and compute margins at each step."""
    n = A.shape[0]
    Z = A.copy()
    margins = [tropical_margin(Z)]

    for k in range(n * n):
        i, j = divmod(k, n)
        Z = Z.copy()
        Z[i, j] = B[i, j]
        margins.append(tropical_margin(Z))

    return margins


# Setup
rng = np.random.default_rng(42)
n = 6

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Lindeberg Replacement Chain: Tropical Margin Trajectories',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Gaussian → Rademacher
A = rng.standard_normal((n, n))
B = rng.choice([-1.0, 1.0], size=(n, n))
margins = build_replacement_chain_margins(A, B)
steps = np.arange(len(margins))

ax = axes[0, 0]
ax.plot(steps, margins, 'b-', linewidth=1.5, alpha=0.8)
ax.axhline(y=margins[0], color='green', linestyle='--', alpha=0.5, label=f'Start: {margins[0]:.2f}')
ax.axhline(y=margins[-1], color='red', linestyle='--', alpha=0.5, label=f'End: {margins[-1]:.2f}')
ax.fill_between(steps, margins, alpha=0.15, color='blue')
ax.set_title(f'Gaussian → Rademacher (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Step-wise changes (|Z^k - Z^{k+1}|)
step_changes = [abs(margins[k] - margins[k+1]) for k in range(len(margins)-1)]
ax = axes[0, 1]
ax.bar(range(len(step_changes)), step_changes, color='#FF9800', alpha=0.7, width=1.0)
total = abs(margins[0] - margins[-1])
step_sum = sum(step_changes)
ax.axhline(y=total/len(step_changes), color='red', linestyle='--',
           label=f'Avg = total/n² = {total/len(step_changes):.4f}')
ax.set_title(f'Step-wise changes\n|total| = {total:.3f} ≤ Σ|steps| = {step_sum:.3f}',
             fontsize=11)
ax.set_xlabel('Step k')
ax.set_ylabel('|ΔtropMargin|')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Multiple realizations
ax = axes[1, 0]
colors = plt.cm.viridis(np.linspace(0, 1, 8))
for trial in range(8):
    A = rng.standard_normal((n, n))
    B = rng.choice([-1.0, 1.0], size=(n, n))
    margins_t = build_replacement_chain_margins(A, B)
    ax.plot(range(len(margins_t)), margins_t, color=colors[trial],
            linewidth=1.0, alpha=0.7)

ax.set_title(f'8 Independent Chains (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.grid(True, alpha=0.3)

# Panel 4: Gaussian → Uniform
A = rng.standard_normal((n, n))
B = rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))
margins_gu = build_replacement_chain_margins(A, B)

ax = axes[1, 1]
ax.plot(range(len(margins_gu)), margins_gu, 'g-', linewidth=1.5, alpha=0.8,
        label='Gaussian → Uniform')

# Also Rademacher → Uniform
A2 = rng.choice([-1.0, 1.0], size=(n, n))
B2 = rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))
margins_ru = build_replacement_chain_margins(A2, B2)
ax.plot(range(len(margins_ru)), margins_ru, 'r-', linewidth=1.5, alpha=0.8,
        label='Rademacher → Uniform')

ax.set_title(f'Different replacement pairs (n={n})', fontsize=11)
ax.set_xlabel('Replacement step k')
ax.set_ylabel('tropMargin(Z^(k))')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_replacement_chain.png', dpi=150, bbox_inches='tight')
print("Saved viz_replacement_chain.png")
