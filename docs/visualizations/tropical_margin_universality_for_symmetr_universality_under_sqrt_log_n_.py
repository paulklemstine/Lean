"""
Visualization: Universality of Tropical Symmetric Margin

Shows the rescaled survival curves P(tropSymMargin >= t) for Gaussian,
Rademacher, and Uniform symmetric ensembles at different n values.
The curves collapse under sqrt(log n) scaling, supporting the
universality conjecture.
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


def gen_sym_rademacher(n, rng):
    A = (2 * rng.integers(0, 2, size=(n, n)) - 1).astype(float)
    return np.triu(A) + np.triu(A, 1).T


def gen_sym_uniform(n, rng):
    s = np.sqrt(3.0)
    A = rng.uniform(-s, s, size=(n, n))
    return (A + A.T) / np.sqrt(2)


rng = np.random.default_rng(42)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

n_values = [8, 12, 16]
num_trials = 3000
ensembles = {
    'Gaussian': gen_sym_gaussian,
    'Rademacher': gen_sym_rademacher,
    'Uniform': gen_sym_uniform,
}
colors = {'Gaussian': '#2196F3', 'Rademacher': '#F44336', 'Uniform': '#4CAF50'}

for idx, n in enumerate(n_values):
    ax = axes[idx]
    b_n = np.sqrt(np.log(n))

    for name, gen in ensembles.items():
        margins = np.array([trop_sym_margin(gen(n, rng)) for _ in range(num_trials)])
        a_n = np.median(margins)
        rescaled = (margins - a_n) / b_n

        # Compute empirical CDF and survival
        sorted_r = np.sort(rescaled)
        survival = 1.0 - np.arange(1, len(sorted_r)+1) / len(sorted_r)
        ax.plot(sorted_r, survival, color=colors[name], label=name,
                alpha=0.8, linewidth=1.5)

    ax.set_xlabel('Rescaled threshold (t - aₙ) / √(log n)', fontsize=11)
    ax.set_ylabel('P(rescaled margin ≥ t)', fontsize=11)
    ax.set_title(f'n = {n}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(-4, 4)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

fig.suptitle('Tropical Symmetric Margin: Universality Under √(log n) Scaling',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
