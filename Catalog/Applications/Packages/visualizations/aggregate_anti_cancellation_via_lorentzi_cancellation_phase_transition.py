#!/usr/bin/env python3
"""
Visualization: Cancellation Landscape

Shows how the rate of cancellation varies as we interpolate between
nonneg-coefficient (Lorentzian-like) and mixed-sign polynomials.

The x-axis parameterizes the "negativity" of coefficients (fraction of
terms with negative signs), and the y-axis shows the cancellation rate.
The anti-cancellation theorem predicts a sharp phase transition at 0% negativity.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


def poly_pderiv(coeffs, n, var):
    result = {}
    for exp, c in coeffs.items():
        if exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            ne = tuple(ne)
            result[ne] = result.get(ne, 0) + c * exp[var]
    return {e: c for e, c in result.items() if c != 0}


def aggregate_shadow(coeffs, n, A):
    shadow = set()
    for i in range(n):
        for j in range(n):
            if A[i][j] == 0:
                continue
            d = poly_pderiv(poly_pderiv(coeffs, n, j), n, i)
            shadow |= set(d.keys())
    return shadow


def hessian_support(coeffs, n, A):
    result = {}
    for i in range(n):
        for j in range(n):
            if A[i][j] == 0:
                continue
            d = poly_pderiv(poly_pderiv(coeffs, n, j), n, i)
            for e, c in d.items():
                result[e] = result.get(e, 0) + A[i][j] * c
    return {e for e, c in result.items() if c != 0}


def run_experiment(n_vars=3, max_deg=3, n_trials=150, seed=123):
    rng = random.Random(seed)
    
    # Generate a fixed set of exponents
    exponents = []
    for total in range(1, max_deg + 1):
        def gen(remaining, n_left, prefix):
            if n_left == 0:
                if remaining == 0:
                    exponents.append(tuple(prefix))
                return
            for k in range(remaining + 1):
                gen(remaining - k, n_left - 1, prefix + [k])
        gen(total, n_vars, [])
    
    A = [[1] * n_vars for _ in range(n_vars)]  # All positive weights
    
    neg_fractions = np.linspace(0, 1, 21)
    cancel_rates = []
    shadow_sizes = []
    hessian_sizes = []
    
    for neg_frac in neg_fractions:
        n_cancel = 0
        total_shadow = 0
        total_hessian = 0
        
        for trial in range(n_trials):
            n_terms = rng.randint(3, min(10, len(exponents)))
            support = rng.sample(exponents, n_terms)
            
            coeffs = {}
            for e in support:
                mag = rng.randint(1, 5)
                if rng.random() < neg_frac:
                    coeffs[e] = -mag
                else:
                    coeffs[e] = mag
            
            shadow = aggregate_shadow(coeffs, n_vars, A)
            hsupp = hessian_support(coeffs, n_vars, A)
            
            # Count cancelled monomials
            cancelled = len(shadow - hsupp)
            if cancelled > 0:
                n_cancel += 1
            total_shadow += len(shadow)
            total_hessian += len(hsupp)
        
        cancel_rates.append(n_cancel / n_trials)
        shadow_sizes.append(total_shadow / n_trials)
        hessian_sizes.append(total_hessian / n_trials)
    
    return neg_fractions, cancel_rates, shadow_sizes, hessian_sizes


neg_fracs, cancel_rates, shadow_sizes, hessian_sizes = run_experiment()

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 9), gridspec_kw={'height_ratios': [2, 1]})

# Top plot: Cancellation rate
ax1.fill_between(neg_fracs * 100, 0, cancel_rates, alpha=0.3, color='#e74c3c')
ax1.plot(neg_fracs * 100, cancel_rates, 'o-', color='#c0392b', linewidth=2, markersize=5)
ax1.axvline(x=0, color='#27ae60', linewidth=3, linestyle='--', alpha=0.8,
            label='Lorentzian boundary (all nonneg)')
ax1.set_xlabel('Fraction of Negative Coefficients (%)', fontsize=12)
ax1.set_ylabel('Probability of Cancellation', fontsize=12)
ax1.set_title('Phase Transition: Cancellation Rate vs Coefficient Negativity\n'
              'Anti-Cancellation Theorem guarantees 0% at the Lorentzian boundary',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xlim(-2, 102)
ax1.set_ylim(-0.02, max(cancel_rates) * 1.15 + 0.02)
ax1.grid(True, alpha=0.3)

# Annotate the theorem region
ax1.annotate('Theorem: 0% cancellation\n(nonneg coeffs + pos weights)',
             xy=(0, 0), xytext=(15, 0.15),
             fontsize=10, ha='left',
             arrowprops=dict(arrowstyle='->', color='#27ae60', lw=2),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#eafaf1', edgecolor='#27ae60'))

# Bottom plot: Support sizes
ax2.plot(neg_fracs * 100, shadow_sizes, 's-', color='#3498db', linewidth=2,
         markersize=4, label='Aggregate Shadow Size')
ax2.plot(neg_fracs * 100, hessian_sizes, 'D-', color='#e67e22', linewidth=2,
         markersize=4, label='Hessian Support Size')
ax2.fill_between(neg_fracs * 100,
                 [h for h in hessian_sizes],
                 [s for s in shadow_sizes],
                 alpha=0.2, color='#e74c3c', label='Lost to cancellation')
ax2.set_xlabel('Fraction of Negative Coefficients (%)', fontsize=12)
ax2.set_ylabel('Average Support Size', fontsize=12)
ax2.set_title('Support Size: Shadow vs Actual Hessian', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-2, 102)

plt.tight_layout()
plt.savefig("cancellation_landscape.png", dpi=150, bbox_inches='tight')
print("Saved cancellation_landscape.png")
