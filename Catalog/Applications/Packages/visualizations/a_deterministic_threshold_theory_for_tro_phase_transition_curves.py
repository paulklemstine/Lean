"""
Visualization 1: Phase Transition Curves in Tropical Stability

Plots the probability P(tropMargin ≥ 0) as a function of the scaled parameter
(μ_off - μ_diag) / (σ √log n) for multiple matrix sizes. The near-collapse
of curves supports the √log n scaling conjecture for the phase transition.

This visualizes the core prediction of the tropical phase transition theory:
there exists a sharp threshold separating stable (positive margin) from
unstable (negative margin) regimes, governed by a universal scaling law.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_margin(W):
    """Tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


def generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng):
    W = rng.normal(0, sigma, (n, n))
    W = (W + W.T) / np.sqrt(2)
    return mean_model(n, mu_diag, mu_off) + W


# Parameters
ns = [5, 10, 20]
sigma = 1.0
num_samples = 2000
num_points = 35
rng = np.random.default_rng(42)

x_range = np.linspace(-2.0, 5.0, num_points)

fig, ax = plt.subplots(figsize=(10, 7))

colors = ['#1976D2', '#E64A19', '#388E3C']
markers = ['o', 's', '^']

for idx, n in enumerate(ns):
    log_n = np.log(n)
    probs = []

    for x in x_range:
        mu_diff = x * sigma * np.sqrt(log_n)
        count = 0
        for _ in range(num_samples):
            W = generate_symmetric_gaussian(n, 0, mu_diff, sigma, rng)
            if trop_margin(W) >= 0:
                count += 1
        probs.append(count / num_samples)

    ax.plot(x_range, probs, marker=markers[idx], color=colors[idx],
            label=f'n = {n}', markersize=4, linewidth=2, alpha=0.85)

# Theoretical step function reference
ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5, label='Signal = 0')
ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)

ax.set_xlabel(r'Scaled parameter $(\mu_{\mathrm{off}} - \mu_{\mathrm{diag}}) \;/\; (\sigma \sqrt{\log n})$',
              fontsize=14)
ax.set_ylabel(r'$\mathbb{P}(\mathrm{tropMargin}(W) \geq 0)$', fontsize=14)
ax.set_title('Phase Transition in Tropical Stability\nProbability of Positive Margin vs. Scaled Signal',
             fontsize=15)
ax.legend(fontsize=13, loc='lower right')
ax.grid(True, alpha=0.25)
ax.set_ylim(-0.05, 1.05)
ax.set_xlim(-2.5, 5.5)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: viz_phase_transition.png")
