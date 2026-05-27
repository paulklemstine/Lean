"""
Visualization: Positivity Margin Preservation

Visualizes Theorem D: if det(K_S) ≥ δ and P(k,M)·η < δ, then det(K'_S) > 0.
Shows the phase transition between safe and unsafe perturbation regimes.
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


def random_psd_matrix(n, condition=1.0):
    U = np.linalg.qr(np.random.randn(n, n))[0]
    eigs = np.random.uniform(condition, condition + 1.0, n)
    K = U @ np.diag(eigs) @ U.T
    return (K + K.T) / 2


np.random.seed(2024)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase diagram - which perturbation levels preserve positivity?
ax = axes[0]
n = 6
k = 3

n_trials = 50
eta_fractions = np.linspace(0.01, 3.0, 40)
survival_rates = []

K = random_psd_matrix(n, condition=0.5)
M = np.max(np.abs(K))

# Find min minor
subsets = list(combinations(range(n), k))
min_minor = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)
delta = min_minor
P_kM = minor_perturb_poly(k, M)
eta_crit = delta / P_kM if P_kM > 0 else 1.0

for frac in eta_fractions:
    eta = frac * eta_crit
    successes = 0
    for _ in range(n_trials):
        E = np.random.uniform(-eta, eta, (n, n))
        E = (E + E.T) / 2
        K_prime = K + E
        all_pos = all(np.linalg.det(K_prime[np.ix_(list(S), list(S))]) > 0 for S in subsets)
        if all_pos:
            successes += 1
    survival_rates.append(successes / n_trials)

ax.plot(eta_fractions, survival_rates, 'b-', linewidth=2.5)
ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='η = η_crit')
ax.fill_between(eta_fractions, 0, 1, where=[f <= 1.0 for f in eta_fractions],
                alpha=0.15, color='green', label='Certified safe zone')
ax.set_xlabel('η / η_critical', fontsize=12)
ax.set_ylabel('Fraction with all minors > 0', fontsize=12)
ax.set_title(f'Positivity Survival (n={n}, k={k})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Panel 2: Minimum minor under perturbation
ax = axes[1]
n = 6
k = 3

K = random_psd_matrix(n, condition=0.3)
M = np.max(np.abs(K))
P_kM = minor_perturb_poly(k, M)

etas_test = np.linspace(0, 0.03, 30)
certified_lower = []
empirical_min = []

subsets = list(combinations(range(n), k))
min_det_K = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)

for eta in etas_test:
    certified_lower.append(max(0, min_det_K - P_kM * eta))

    # Monte Carlo minimum
    min_vals = []
    for _ in range(30):
        E = np.random.uniform(-eta, eta, (n, n))
        E = (E + E.T) / 2
        K_prime = K + E
        min_det = min(np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets)
        min_vals.append(min_det)
    empirical_min.append(np.mean(min_vals))

ax.plot(etas_test, [min_det_K] * len(etas_test), 'g--', linewidth=1.5, label='Original min minor')
ax.plot(etas_test, certified_lower, 'r-', linewidth=2.5, label='Certified lower bound')
ax.plot(etas_test, empirical_min, 'b-', linewidth=2, label='Empirical mean min')
ax.fill_between(etas_test, certified_lower, min_det_K, alpha=0.1, color='orange')
ax.set_xlabel('η (perturbation)', fontsize=12)
ax.set_ylabel('Minimum k-minor value', fontsize=12)
ax.set_title(f'Minor Lower Bound vs η (n={n}, k={k})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Critical eta vs k
ax = axes[2]
n = 8
K = random_psd_matrix(n, condition=0.5)
M = np.max(np.abs(K))

ks = range(1, 7)
eta_crits = []
min_minors = []

for k in ks:
    subsets = list(combinations(range(n), k))
    min_det = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)
    P_kM = minor_perturb_poly(k, M)
    eta_c = min_det / P_kM if P_kM > 0 else float('inf')
    eta_crits.append(eta_c)
    min_minors.append(min_det)

ax2 = ax.twinx()
bars = ax.bar(list(ks), eta_crits, alpha=0.7, color='steelblue', label='η_critical')
line = ax2.plot(list(ks), min_minors, 'ro-', linewidth=2, markersize=8, label='Min minor δ')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Critical η', fontsize=12, color='steelblue')
ax2.set_ylabel('Minimum minor δ', fontsize=12, color='red')
ax.set_title(f'Critical Perturbation Budget (n={n})', fontsize=13)
ax.tick_params(axis='y', labelcolor='steelblue')
ax2.tick_params(axis='y', labelcolor='red')

lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Positivity Preservation Under Perturbation', fontsize=15, y=1.01)
plt.tight_layout()
plt.savefig('viz_positivity_margin.png', dpi=150, bbox_inches='tight')
print("Saved: viz_positivity_margin.png")
