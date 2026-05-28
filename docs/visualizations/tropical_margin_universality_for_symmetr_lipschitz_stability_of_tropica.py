"""
Visualization: Lipschitz Stability of Tropical Symmetric Margin

Demonstrates the 4-Lipschitz bound:
|tropSymMargin(W) - tropSymMargin(W')| ≤ 4 · d_pair(W, W')

Shows the bound holding across many random perturbations,
with the tightness ratio illustrating how sharp the constant 4 is.
"""

import numpy as np
import matplotlib.pyplot as plt


def pair_slack(W, i, j):
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    return min(pair_slack(W, i, j) for i in range(n) for j in range(i+1, n))


def gen_sym_gaussian(n, rng):
    A = rng.standard_normal((n, n))
    return (A + A.T) / np.sqrt(2)


rng = np.random.default_rng(42)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Scatter of |Δmargin| vs 4·d_pair
ax = axes[0]
n = 8
W_base = gen_sym_gaussian(n, rng)
diffs, bounds = [], []
for _ in range(500):
    eps = rng.uniform(0.01, 1.0)
    E = eps * gen_sym_gaussian(n, rng)
    W2 = W_base + E
    m1, m2 = trop_sym_margin(W_base), trop_sym_margin(W2)
    d = np.max(np.abs(W_base - W2))
    diffs.append(abs(m1 - m2))
    bounds.append(4 * d)

ax.scatter(bounds, diffs, alpha=0.3, s=10, color='#2196F3')
max_val = max(max(bounds), max(diffs)) * 1.1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='y = x (tight)')
ax.set_xlabel('4 · d_pair(W, W\')', fontsize=11)
ax.set_ylabel('|tropSymMargin(W) - tropSymMargin(W\')|', fontsize=11)
ax.set_title('Lipschitz Bound (n=8)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Tightness ratio histogram
ax = axes[1]
ratios = [d/b if b > 0 else 0 for d, b in zip(diffs, bounds)]
ax.hist(ratios, bins=40, color='#4CAF50', alpha=0.7, edgecolor='white')
ax.axvline(x=1.0, color='red', linestyle='--', label='Bound = 1')
ax.set_xlabel('Tightness ratio |Δmargin| / (4·d_pair)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('How Tight Is the Bound?', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Margin vs perturbation size
ax = axes[2]
eps_range = np.linspace(0.01, 2.0, 50)
for n_val, color in [(4, '#2196F3'), (8, '#F44336'), (16, '#9C27B0')]:
    W0 = gen_sym_gaussian(n_val, rng)
    m0 = trop_sym_margin(W0)
    margins_mean = []
    for eps in eps_range:
        ms = []
        for _ in range(100):
            E = eps * gen_sym_gaussian(n_val, rng)
            ms.append(trop_sym_margin(W0 + E))
        margins_mean.append(np.mean(ms))
    ax.plot(eps_range, margins_mean, color=color, label=f'n={n_val}', linewidth=1.5)
    ax.axhline(y=m0, color=color, linestyle=':', alpha=0.5)

ax.set_xlabel('Perturbation scale ε', fontsize=11)
ax.set_ylabel('Mean tropSymMargin(W + εE)', fontsize=11)
ax.set_title('Margin Under Growing Perturbation', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle('Lipschitz Stability of Tropical Symmetric Margin',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_lipschitz.png', dpi=150, bbox_inches='tight')
print("Saved viz_lipschitz.png")
