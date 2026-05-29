"""
Visualization 1: Tropical Margin Universality — Empirical CDF Collapse

Visualizes the central prediction of the tropical Lindeberg universality theorem:
normalized tropical margin CDFs from different entry distributions collapse onto
a single universal curve as matrix size n increases. This is the computational
signature of the Lindeberg replacement principle for non-spectral observables.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    """Tropical stability margin: min_{i≠j} (2W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


def generate_margins(gen_func, n, num_samples, rng):
    """Generate tropical margin samples."""
    return np.array([tropical_margin(gen_func(n, rng)) for _ in range(num_samples)])


# Generators
def gaussian(n, rng): return rng.standard_normal((n, n))
def rademacher(n, rng): return rng.choice([-1.0, 1.0], size=(n, n))
def uniform(n, rng): return rng.uniform(-np.sqrt(3), np.sqrt(3), size=(n, n))

# Setup
sizes = [5, 10, 20, 50]
num_samples = 800
rng = np.random.default_rng(42)
generators = {'Gaussian': gaussian, 'Rademacher': rademacher, 'Uniform': uniform}
colors = {'Gaussian': '#2196F3', 'Rademacher': '#F44336', 'Uniform': '#4CAF50'}

fig, axes = plt.subplots(1, len(sizes), figsize=(16, 4), sharey=True)
fig.suptitle('Tropical Margin CDF Universality: Collapse Under Normalization',
             fontsize=14, fontweight='bold', y=1.02)

for idx, n in enumerate(sizes):
    ax = axes[idx]
    all_normalized = {}

    for name, gen in generators.items():
        margins = generate_margins(gen, n, num_samples, rng)
        a_n = np.median(margins)
        b_n = np.std(margins)
        if b_n < 1e-10:
            b_n = 1.0
        normalized = (margins - a_n) / b_n
        all_normalized[name] = normalized

        sorted_vals = np.sort(normalized)
        cdf = np.arange(1, len(sorted_vals) + 1) / len(sorted_vals)
        ax.plot(sorted_vals, cdf, label=name, color=colors[name], linewidth=1.5, alpha=0.85)

    # KS distances
    names = list(generators.keys())
    ks_vals = []
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            s1, s2 = all_normalized[names[i]], all_normalized[names[j]]
            combined = np.sort(np.unique(np.concatenate([s1, s2])))
            c1 = np.searchsorted(np.sort(s1), combined, side='right') / len(s1)
            c2 = np.searchsorted(np.sort(s2), combined, side='right') / len(s2)
            ks_vals.append(np.max(np.abs(c1 - c2)))

    avg_ks = np.mean(ks_vals)
    ax.set_title(f'n = {n}\nAvg KS = {avg_ks:.3f}', fontsize=11)
    ax.set_xlabel('Normalized margin', fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-4, 4)

axes[0].set_ylabel('CDF', fontsize=11)
axes[0].legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
