#!/usr/bin/env python3
"""
Visualization 2: Asymptotic Freeness Convergence

Visualizes the convergence of spectral moments of random Cayley graphs
Cay(S_n, {σ,σ⁻¹,τ,τ⁻¹}) to the Kesten-McKay distribution for d=4.
Shows the O(1/n) convergence rate predicted by asymptotic freeness.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def catalan(n):
    return comb(2 * n, n) // (n + 1)

def kesten_mckay_moment(d, k):
    if k == 0:
        return 1.0
    return float(catalan(k) * d * (d - 1) ** (k - 1))

def spectral_moments_cayley(n, num_samples=200, max_k=3):
    moments = {k: [] for k in range(max_k + 1)}
    for _ in range(num_samples):
        sigma = np.random.permutation(n)
        tau = np.random.permutation(n)
        A = np.zeros((n, n))
        for i in range(n):
            A[i, sigma[i]] += 1
            A[sigma[i], i] += 1
            A[i, tau[i]] += 1
            A[tau[i], i] += 1
        eigenvalues = np.linalg.eigvalsh(A)
        for k in range(max_k + 1):
            moments[k].append(np.mean(eigenvalues ** (2 * k)))
    return {k: (np.mean(v), np.std(v) / np.sqrt(len(v))) for k, v in moments.items()}

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

ns = list(range(5, 25))
km = {k: kesten_mckay_moment(4, k) for k in range(4)}

# Collect data
errors = {k: [] for k in [1, 2, 3]}
stderrs = {k: [] for k in [1, 2, 3]}

for n in ns:
    emp = spectral_moments_cayley(n, num_samples=150, max_k=3)
    for k in [1, 2, 3]:
        errors[k].append(abs(emp[k][0] - km[k]))
        stderrs[k].append(emp[k][1])

# Panel 1: Error vs n for each moment
colors = ['blue', 'red', 'green']
labels = [r'$|\mu_2 - 4|$', r'$|\mu_4 - 24|$', r'$|\mu_6 - 180|$']

for idx, k in enumerate([1, 2, 3]):
    axes[0].semilogy(ns, errors[k], 'o-', color=colors[idx], label=labels[idx],
                     markersize=5, linewidth=1.5)

# Reference O(1/n) line
ref = [errors[1][0] * ns[0] / n for n in ns]
axes[0].semilogy(ns, ref, 'k--', alpha=0.5, label=r'$O(1/n)$ reference')

axes[0].set_xlabel('n (group size)', fontsize=13)
axes[0].set_ylabel('Absolute error', fontsize=13)
axes[0].set_title('Convergence of Spectral Moments', fontsize=14)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)

# Panel 2: n * error (should stabilize if O(1/n))
for idx, k in enumerate([1, 2, 3]):
    scaled = [n * e for n, e in zip(ns, errors[k])]
    axes[1].plot(ns, scaled, 'o-', color=colors[idx], label=labels[idx],
                markersize=5, linewidth=1.5)

axes[1].set_xlabel('n (group size)', fontsize=13)
axes[1].set_ylabel(r'$n \cdot |\text{error}|$', fontsize=13)
axes[1].set_title(r'Scaled Error ($n \cdot$ error → const if $O(1/n)$)', fontsize=14)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Panel 3: Spectral moment values approaching KM predictions
for idx, k in enumerate([1, 2, 3]):
    vals = [km[k] - e for e in errors[k]]  # approximate empirical values
    axes[2].plot(ns, vals, 'o-', color=colors[idx],
                label=f'$\\mu_{{{2*k}}}$ (empirical)', markersize=5, linewidth=1.5)
    axes[2].axhline(y=km[k], color=colors[idx], linestyle='--', alpha=0.5)

axes[2].set_xlabel('n (group size)', fontsize=13)
axes[2].set_ylabel('Moment value', fontsize=13)
axes[2].set_title('Moments Approaching Kesten-McKay', fontsize=14)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.suptitle('Asymptotic Freeness: Random Permutations → Kesten-McKay Distribution',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_convergence.png")
