"""
Visualization 2: Asymptotic Tropical Segmentation

Tests the conjecture that normalized tropical profiles converge to
piecewise-linear limits. For increasingly large block spectra,
plots the rescaled profile (1/m) * log(e_{xm}) and compares to
the predicted piecewise-linear limit function.

This visualization is the computational evidence for the
Asymptotic Tropical Segmentation Conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log


def elementary_symmetric_polynomials(weights):
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]
    return e


def block_spectrum(blocks):
    return np.concatenate([np.full(mult, w) for w, mult in blocks])


def piecewise_linear_limit(x, blocks):
    """Compute the predicted piecewise-linear limit F(x)."""
    total = sum(m for _, m in blocks)
    alphas = [m / total for _, m in blocks]
    log_weights = [log(w) if w > 0 else 0 for w, _ in blocks]

    cumul = 0.0
    val = 0.0
    for alpha, lw in zip(alphas, log_weights):
        if x <= cumul + alpha:
            val += lw * (x - cumul)
            return val
        else:
            val += lw * alpha
            cumul += alpha
    return val


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Two-block model
w1, w2 = 5.0, 1.5
alpha1, alpha2 = 0.4, 0.6

ax = axes[0]
sizes = [10, 20, 40, 80]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(sizes)))

for size_idx, m_total in enumerate(sizes):
    p = int(alpha1 * m_total)
    q = m_total - p
    blocks = [(w1, p), (w2, q)]
    spectrum = block_spectrum(blocks)
    e = elementary_symmetric_polynomials(spectrum)

    xs = np.array([k / m_total for k in range(m_total + 1)])
    normalized = np.array([
        log(e[k]) / m_total if e[k] > 0 else float('-inf')
        for k in range(m_total + 1)
    ])

    ax.plot(xs, normalized, 'o-', color=colors[size_idx], markersize=2,
            linewidth=1.5, alpha=0.8, label=f'm={m_total}')

# Plot limit function
x_fine = np.linspace(0, 1, 200)
limit_blocks = [(w1, int(alpha1 * 100)), (w2, int(alpha2 * 100))]
limit_vals = np.array([piecewise_linear_limit(x, limit_blocks) for x in x_fine])
ax.plot(x_fine, limit_vals, 'k-', linewidth=2.5, label='Predicted limit')

ax.axvline(x=alpha1, color='red', linestyle=':', alpha=0.5, label=f'Gap at α₁={alpha1}')
ax.set_xlabel('x = k/m', fontsize=13)
ax.set_ylabel('(1/m) · log e_{⌊xm⌋}', fontsize=13)
ax.set_title(f'Two-Block Convergence\nw₁={w1}, w₂={w2}, α₁={alpha1}', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Slope convergence
ax = axes[1]
for size_idx, m_total in enumerate(sizes):
    p = int(alpha1 * m_total)
    q = m_total - p
    spectrum = block_spectrum([(w1, p), (w2, q)])
    e = elementary_symmetric_polynomials(spectrum)

    profile = np.array([log(e[k]) if e[k] > 0 else float('-inf')
                        for k in range(m_total + 1)])
    slopes = np.diff(profile)
    xs = np.array([k / m_total for k in range(m_total)])

    ax.plot(xs, slopes, 'o-', color=colors[size_idx], markersize=2,
            linewidth=1.5, alpha=0.8, label=f'm={m_total}')

ax.axhline(y=log(w1), color='blue', linestyle='--', alpha=0.6, label=f'log({w1})={log(w1):.2f}')
ax.axhline(y=log(w2), color='green', linestyle='--', alpha=0.6, label=f'log({w2})={log(w2):.2f}')
ax.axvline(x=alpha1, color='red', linestyle=':', alpha=0.5)

ax.set_xlabel('x = k/m', fontsize=13)
ax.set_ylabel('Discrete slope', fontsize=13)
ax.set_title(f'Slope Convergence to Plateaus', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Asymptotic Tropical Segmentation Conjecture — Computational Evidence',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('asymptotic_convergence.png', dpi=150, bbox_inches='tight')
print("Saved asymptotic_convergence.png")
