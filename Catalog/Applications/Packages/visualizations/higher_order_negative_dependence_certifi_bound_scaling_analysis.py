"""
Visualization: Perturbation Bound Scaling

Visualizes how the certified perturbation polynomial P(k,M) = k·k!·M^(k-1)
scales with subset size k and entry bound M, and compares against empirical
errors from random PSD matrix perturbations.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k, M):
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    A = np.random.randn(n, rank) / np.sqrt(n)
    return A @ A.T


def entrywise_perturb(K, eta):
    n = K.shape[0]
    E = np.random.uniform(-eta, eta, (n, n))
    E = (E + E.T) / 2
    return K + E


np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: P(k, M) growth curves
ax = axes[0, 0]
ks = range(1, 9)
for M in [0.5, 1.0, 1.5, 2.0, 3.0]:
    values = [minor_perturb_poly(k, M) for k in ks]
    ax.semilogy(list(ks), values, 'o-', linewidth=2, markersize=6, label=f'M = {M}')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('P(k, M)', fontsize=12)
ax.set_title('Perturbation Polynomial P(k, M) = k · k! · M^(k-1)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Empirical tightness ratio
ax = axes[0, 1]
n = 8
eta = 0.01
n_trials = 40

mean_ratios = []
max_ratios = []
k_range = range(1, 7)

for k in k_range:
    trial_ratios = []
    for _ in range(n_trials):
        K = random_psd_matrix(n)
        K_prime = entrywise_perturb(K, eta)
        M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))
        actual_eta = np.max(np.abs(K - K_prime))
        bound = minor_perturb_poly(k, M) * actual_eta

        subsets = list(combinations(range(n), k))
        if len(subsets) > 100:
            subsets = [subsets[i] for i in np.random.choice(len(subsets), 100, replace=False)]

        max_err = max(abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                         np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
                      for S in subsets)
        trial_ratios.append(max_err / bound if bound > 0 else 0)

    mean_ratios.append(np.mean(trial_ratios))
    max_ratios.append(np.max(trial_ratios))

x = list(k_range)
ax.bar(x, max_ratios, alpha=0.6, color='steelblue', label='Max ratio (over trials)')
ax.bar(x, mean_ratios, alpha=0.8, color='coral', label='Mean ratio')
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Certified bound = 1')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Empirical Error / Certified Bound', fontsize=12)
ax.set_title('Tightness: How Close Are Empirical Errors?', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(0, 1.15)
ax.grid(True, alpha=0.3)

# Panel 3: Bound vs eta (linearity check)
ax = axes[1, 0]
n = 6
K = random_psd_matrix(n) + 0.3 * np.eye(n)
M = np.max(np.abs(K))
etas = np.logspace(-4, -1, 20)

for k in [2, 3, 4]:
    certified = [minor_perturb_poly(k, M) * e for e in etas]
    empirical = []
    for e in etas:
        K_prime = entrywise_perturb(K, e)
        actual_e = np.max(np.abs(K - K_prime))
        subsets = list(combinations(range(n), k))
        max_err = max(abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                         np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
                      for S in subsets)
        empirical.append(max_err)
    ax.loglog(etas, certified, '--', linewidth=2, label=f'Certified k={k}')
    ax.loglog(etas, empirical, 'o', markersize=5, label=f'Empirical k={k}')

ax.set_xlabel('η (perturbation)', fontsize=12)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=12)
ax.set_title('Linearity in η: Certified vs Empirical', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: k! growth comparison
ax = axes[1, 1]
ks = range(1, 10)
pkm = [minor_perturb_poly(k, 1.0) for k in ks]
factorials = [factorial(k) for k in ks]
k_fact_k = [k * factorial(k) for k in ks]
k_sq = [k**2 for k in ks]
k_exp = [2**k for k in ks]

ax.semilogy(list(ks), pkm, 'o-', linewidth=2.5, markersize=8, color='red', label='P(k, 1) = k·k!')
ax.semilogy(list(ks), factorials, 's--', linewidth=1.5, color='blue', alpha=0.7, label='k!')
ax.semilogy(list(ks), k_sq, '^--', linewidth=1.5, color='green', alpha=0.7, label='k²')
ax.semilogy(list(ks), k_exp, 'v--', linewidth=1.5, color='purple', alpha=0.7, label='2^k')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Growth Rate', fontsize=12)
ax.set_title('Polynomial Growth: P(k,1) vs Standard Scalings', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Higher-Order Minor Perturbation: Certified Bounds', fontsize=15, y=1.01)
plt.tight_layout()
plt.savefig('viz_bound_scaling.png', dpi=150, bbox_inches='tight')
print("Saved: viz_bound_scaling.png")
