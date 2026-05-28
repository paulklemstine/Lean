"""
Visualization: Unknown Rate vs Epsilon — Testing the O(ε) Conjecture

This script plots the empirical unknown frequency as a function of the
uncertainty radius ε, testing the conjecture that the ambiguity rate
scales linearly with ε. A log-log plot with slope ≈ 1 confirms the
O(ε) prediction from the formal volume bound theory.

This is the key computational test of the thin-ambiguity-region theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


def perturbation_bound(max_radius, degree):
    n = max(degree - 1, 1)
    max_scaling = degree * degree
    entry_bound = max_radius * max_scaling
    return n**2 * entry_bound


def certify(center, eps, degree):
    lower = center - eps
    upper = center + eps
    if np.any(upper < 0):
        return -1
    H = bivariate_hessian(center)
    margin = spectral_margin(H)
    err = perturbation_bound(eps, degree)
    if margin > 0 and err < margin and np.all(lower >= -1e-12):
        return 1
    if margin < 0 and err < -margin:
        return -1
    return 0


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Testing the O(ε) Ambiguity Conjecture',
             fontsize=14, fontweight='bold')

n_samples = 500
rng = np.random.default_rng(42)

for deg_idx, degree in enumerate([4, 6]):
    ax = axes[deg_idx]
    n_coeffs = degree + 1
    
    # Fix random centers
    centers = rng.uniform(0.1, 3.0, (n_samples, n_coeffs))
    
    epsilons = np.logspace(-3, -0.3, 20)
    unknown_rates = []
    
    for eps in epsilons:
        n_unknown = 0
        for i in range(n_samples):
            decision = certify(centers[i], eps, degree)
            if decision == 0:
                n_unknown += 1
        unknown_rates.append(n_unknown / n_samples)
    
    unknown_rates = np.array(unknown_rates)
    
    # Filter positive rates for log-log
    valid = unknown_rates > 0
    
    # Plot log-log
    ax.loglog(epsilons[valid], unknown_rates[valid], 'bo-',
              markersize=4, label='Empirical unknown rate')
    
    # Fit and plot reference line
    if np.sum(valid) >= 3:
        log_eps = np.log10(epsilons[valid])
        log_rate = np.log10(unknown_rates[valid])
        slope, intercept = np.polyfit(log_eps, log_rate, 1)
        
        fit_line = 10**(slope * np.log10(epsilons) + intercept)
        ax.loglog(epsilons, fit_line, 'r--', alpha=0.7,
                  label=f'Fit: slope = {slope:.2f}')
        
        # Reference O(ε) line
        ref_line = epsilons * unknown_rates[valid][len(unknown_rates[valid])//2] / epsilons[valid][len(epsilons[valid])//2]
        ax.loglog(epsilons, ref_line, 'g:', alpha=0.5,
                  label='Reference: O(ε)')
    
    ax.set_xlabel('Uncertainty radius ε', fontsize=11)
    ax.set_ylabel('Unknown frequency', fontsize=11)
    ax.set_title(f'Degree {degree} polynomials (n={n_samples} samples)\n'
                 f'Log-log slope ≈ {slope:.2f} (O(ε) predicts ≈ 1.0)',
                 fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(bottom=1e-3)

plt.tight_layout()
plt.savefig('viz_unknown_rate.png', dpi=150, bbox_inches='tight')
print("Saved: viz_unknown_rate.png")
