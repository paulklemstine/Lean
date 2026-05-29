#!/usr/bin/env python3
"""
Visualization 2: Distribution of Entanglement Across Random States

Shows the probability distribution of concurrence values for randomly sampled
two-qubit states (Haar-uniform on S^7). Demonstrates that most random states
are moderately entangled — truly product states and maximally entangled states
are measure-zero sets. Also shows the verified bounds 0 ≤ C ≤ 1.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

def random_concurrence(n=50000):
    """Generate concurrences of n random normalized two-qubit states."""
    # Sample from Haar measure on S^7 (Gaussian then normalize)
    real_parts = np.random.randn(n, 4)
    imag_parts = np.random.randn(n, 4)
    states = real_parts + 1j * imag_parts  # shape (n, 4)

    # Normalize
    norms = np.sqrt(np.sum(np.abs(states)**2, axis=1, keepdims=True))
    states = states / norms

    # Compute concurrence = 2|αδ - βγ|
    alpha, beta, gamma, delta = states[:, 0], states[:, 1], states[:, 2], states[:, 3]
    det = alpha * delta - beta * gamma
    return 2 * np.abs(det)

concurrences = random_concurrence()

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Histogram
ax1 = axes[0]
ax1.hist(concurrences, bins=100, density=True, color='steelblue', alpha=0.8,
         edgecolor='white', linewidth=0.3)

# Theoretical PDF: for Haar-random states, P(C) = 3C(1 - C²/4)... approximate
c_range = np.linspace(0, 1, 200)
# Known result: P(C) = 3(1-C²)C for the concurrence on CP³
# This is approximate; exact distribution depends on measure
pdf_approx = 3 * (1 - c_range**2) * c_range
pdf_approx[c_range > 1] = 0
ax1.plot(c_range, pdf_approx, 'r-', linewidth=2, label='P(C) ≈ 3C(1-C²)')

ax1.axvline(x=0, color='green', linestyle='--', alpha=0.7, label='Product states (C=0)')
ax1.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Bell states (C=1)')
ax1.set_xlabel('Concurrence C', fontsize=12)
ax1.set_ylabel('Probability Density', fontsize=12)
ax1.set_title('Distribution of Entanglement\nfor Random Two-Qubit States', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_xlim(-0.05, 1.05)

# CDF
ax2 = axes[1]
sorted_c = np.sort(concurrences)
cdf = np.arange(1, len(sorted_c) + 1) / len(sorted_c)
ax2.plot(sorted_c, cdf, 'b-', linewidth=2)
ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
median = np.median(concurrences)
ax2.axvline(x=median, color='orange', linestyle='--', alpha=0.7,
            label=f'Median C = {median:.3f}')
ax2.set_xlabel('Concurrence C', fontsize=12)
ax2.set_ylabel('Cumulative Probability', fontsize=12)
ax2.set_title('Cumulative Distribution\nof Concurrence', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Scatter: concurrence vs |det|
ax3 = axes[2]
n_show = 2000
real_parts = np.random.randn(n_show, 4)
imag_parts = np.random.randn(n_show, 4)
states = real_parts + 1j * imag_parts
norms = np.sqrt(np.sum(np.abs(states)**2, axis=1, keepdims=True))
states = states / norms

alpha = states[:, 0]
beta = states[:, 1]
gamma = states[:, 2]
delta = states[:, 3]
det_vals = np.abs(alpha * delta - beta * gamma)
triangle_bound = np.abs(alpha) * np.abs(delta) + np.abs(beta) * np.abs(gamma)

ax3.scatter(det_vals, triangle_bound, c=2*det_vals, cmap='viridis',
            alpha=0.3, s=5)
ax3.plot([0, 0.6], [0, 0.6], 'r--', linewidth=2, label='|det| = triangle bound')
ax3.set_xlabel('|αδ - βγ| (entanglement det)', fontsize=12)
ax3.set_ylabel('|α|·|δ| + |β|·|γ| (triangle bound)', fontsize=12)
ax3.set_title('Triangle Inequality Bound\non Entanglement', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entanglement_distribution.png', dpi=150, bbox_inches='tight')
print("Saved entanglement_distribution.png")
