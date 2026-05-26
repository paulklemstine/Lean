#!/usr/bin/env python3
"""
Visualization 1: Irreducible Rate Separation Between GL_2 and SL_2

This visualization shows how the irreducible characteristic polynomial rates
differ between GL_2(F_q) and SL_2(F_q) as q varies over prime powers.
The persistent gap between the curves is the spectral fingerprint that
distinguishes these group families — the finite-field analogue of Wigner's
classification of random matrix ensembles.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Theoretical rates
def gl2_irred_rate(q):
    return q / (2 * (q + 1))

def sl2_irred_rate(q):
    return (q - 1) / (2 * q)

# Compute exact rates by enumeration for small primes
def enumerate_exact_rate(p, group_type="GL"):
    n_total = 0
    n_irred = 0
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if group_type == "GL" and det == 0:
                        continue
                    if group_type == "SL" and det != 1:
                        continue
                    n_total += 1
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    disc = (linear_coeff * linear_coeff - 4 * const_term) % p
                    if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
                        n_irred += 1
    return n_irred / n_total if n_total > 0 else 0

# Prime values for plotting
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
q_continuous = np.linspace(2, 50, 200)

# Theoretical curves
gl2_theory = [gl2_irred_rate(q) for q in q_continuous]
sl2_theory = [sl2_irred_rate(q) for q in q_continuous]

# Exact values for small primes
small_primes = [3, 5, 7, 11, 13]
gl2_exact = [enumerate_exact_rate(p, "GL") for p in small_primes]
sl2_exact = [enumerate_exact_rate(p, "SL") for p in small_primes]

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Rate curves
ax1.plot(q_continuous, gl2_theory, 'b-', linewidth=2, label=r'$\rho_{irr}(GL_2) = \frac{q}{2(q+1)}$')
ax1.plot(q_continuous, sl2_theory, 'r-', linewidth=2, label=r'$\rho_{irr}(SL_2) = \frac{q-1}{2q}$')
ax1.plot(small_primes, gl2_exact, 'bo', markersize=8, label='GL₂ exact (enumeration)')
ax1.plot(small_primes, sl2_exact, 'rs', markersize=8, label='SL₂ exact (enumeration)')

# Shade the gap
ax1.fill_between(q_continuous, gl2_theory, sl2_theory, alpha=0.15, color='purple',
                  label='Separation gap')

ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Field size q', fontsize=13)
ax1.set_ylabel('Irreducible rate ρ_irr', fontsize=13)
ax1.set_title('Spectral Separation: GL₂ vs SL₂', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='lower right')
ax1.set_xlim(2, 50)
ax1.set_ylim(0, 0.55)
ax1.grid(True, alpha=0.3)

# Plot 2: Gap magnitude
gap_values = [gl2_irred_rate(q) - sl2_irred_rate(q) for q in q_continuous]
exact_gaps = [gl - sl for gl, sl in zip(gl2_exact, sl2_exact)]

ax2.plot(q_continuous, gap_values, 'purple', linewidth=2,
         label=r'$\Delta\rho = \frac{1}{2q(q+1)}$')
ax2.plot(small_primes, exact_gaps, 'ko', markersize=8, label='Exact gaps')

# Theoretical formula for the gap
gap_formula = [1 / (2 * q * (q + 1)) for q in q_continuous]
ax2.plot(q_continuous, gap_formula, 'g--', linewidth=1.5, alpha=0.7,
         label=r'$\frac{1}{2q(q+1)}$ (exact)')

ax2.set_xlabel('Field size q', fontsize=13)
ax2.set_ylabel('Gap Δρ = ρ(GL₂) - ρ(SL₂)', fontsize=13)
ax2.set_title('Separation Gap: Always Positive', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_xlim(2, 50)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_separation.png', dpi=150, bbox_inches='tight')
print("Saved spectral_separation.png")
