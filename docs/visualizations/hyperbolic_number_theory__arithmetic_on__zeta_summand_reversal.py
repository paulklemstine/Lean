#!/usr/bin/env python3
"""
Visualization 2: Zeta Summand Reversal

Compares classical zeta summands (which are ≤ 1 and convergent) with
hyperbolic zeta summands (which are ≥ 1 and divergent). This visualizes
the fundamental asymmetry between Euclidean and hyperbolic analytic
number theory discovered in this research.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Classical vs Hyperbolic summands
ax = axes[0]
s_vals = np.arange(1, 16)
r = 0.5

classical = 1.0 / s_vals**2  # 1/n^2
hyperbolic = (1.0/r) ** (2 * s_vals)  # r^{-2s}

ax.semilogy(s_vals, classical, 'bo-', label='Classical: 1/n²', markersize=6)
ax.semilogy(s_vals, hyperbolic, 'rs-', label=f'Hyperbolic: r⁻²ˢ (r={r})', markersize=6)
ax.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='Boundary = 1')
ax.fill_between(s_vals, 0.001, 1, alpha=0.1, color='blue', label='Classical region (≤1)')
ax.fill_between(s_vals, 1, max(hyperbolic)*2, alpha=0.1, color='red', label='Hyperbolic region (≥1)')
ax.set_xlabel('Term index', fontsize=12)
ax.set_ylabel('Summand value (log scale)', fontsize=12)
ax.set_title('Zeta Summand Reversal', fontsize=14)
ax.legend(fontsize=8)
ax.set_ylim(0.001, max(hyperbolic) * 2)

# Panel 2: Geometric decay for different r
ax = axes[1]
n_vals = np.arange(0, 20)
r_values = [0.3, 0.5, 0.7, 0.9, 0.95]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(r_values)))

for r, color in zip(r_values, colors):
    decay = r ** n_vals
    ax.plot(n_vals, decay, 'o-', color=color, label=f'r={r}', markersize=4)

ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_xlabel('Exponent n', fontsize=12)
ax.set_ylabel('r^n', fontsize=12)
ax.set_title('Geometric Decay: r^n < 1 for |r| < 1', fontsize=14)
ax.legend(fontsize=9)
ax.set_ylim(-0.05, 1.05)

# Panel 3: Partial sums comparison
ax = axes[2]
N_vals = np.arange(1, 25)

# Classical zeta(2) partial sums
classical_partial = np.cumsum(1.0 / np.arange(1, 25)**2)

# Hyperbolic partial sums for different r
for r, color, style in [(0.8, 'red', '-'), (0.6, 'orange', '--'), (0.4, 'purple', ':')]:
    hyp_partial = np.cumsum((1.0/r) ** (2 * np.arange(1, 25)))
    ax.plot(N_vals, hyp_partial, color=color, linestyle=style, 
            label=f'Hyp (r={r})', linewidth=2)

ax.plot(N_vals, classical_partial, 'b-', label='Classical ζ(2)', linewidth=2)
ax.axhline(y=np.pi**2/6, color='blue', linestyle=':', alpha=0.5, label=f'π²/6 ≈ {np.pi**2/6:.2f}')

ax.set_xlabel('Number of terms N', fontsize=12)
ax.set_ylabel('Partial sum', fontsize=12)
ax.set_title('Partial Sums: Convergence vs Divergence', fontsize=14)
ax.legend(fontsize=8)
ax.set_ylim(0, 100)

plt.tight_layout()
plt.savefig('viz_zeta_reversal.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_zeta_reversal.png")
