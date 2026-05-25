#!/usr/bin/env python3
"""
Visualization 2: Sector Coefficients and Dominance

Visualizes the character expansion coefficients for each representation sector
as functions of the coupling parameter β. Demonstrates that the fundamental
sector (2β) dominates all higher sectors (β², β³, ...) for small β, confirming
the sector ordering theorem.
"""

import numpy as np
import matplotlib.pyplot as plt

betas = np.linspace(0.001, 1.0, 500)

# Sector coefficients
c_triv = np.ones_like(betas)
c_fund = 2.0 * betas
c_adj = betas ** 2
c_h0 = betas ** 3
c_h1 = betas ** 4
c_h2 = betas ** 5

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Linear scale
ax1 = axes[0]
ax1.plot(betas, c_triv, 'k-', linewidth=2, label='Trivial (1)')
ax1.plot(betas, c_fund, 'b-', linewidth=2, label='Fundamental (2β)')
ax1.plot(betas, c_adj, 'r-', linewidth=2, label='Adjoint (β²)')
ax1.plot(betas, c_h0, 'g--', linewidth=1.5, label='Higher-0 (β³)')
ax1.plot(betas, c_h1, 'm--', linewidth=1.5, label='Higher-1 (β⁴)')
ax1.plot(betas, c_h2, 'c--', linewidth=1.5, label='Higher-2 (β⁵)')
ax1.set_xlabel('Coupling parameter β', fontsize=13)
ax1.set_ylabel('Sector Coefficient', fontsize=13)
ax1.set_title('Character Expansion Sectors (Linear Scale)', fontsize=14)
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim([0, 1])
ax1.set_ylim([0, 2.5])
ax1.grid(True, alpha=0.3)

# Highlight dominance region
ax1.axvspan(0, 0.5, alpha=0.05, color='blue', label='Fund. dominant')

# Right: Log scale
ax2 = axes[1]
ax2.semilogy(betas, c_triv, 'k-', linewidth=2, label='Trivial (1)')
ax2.semilogy(betas, c_fund, 'b-', linewidth=2, label='Fundamental (2β)')
ax2.semilogy(betas, c_adj, 'r-', linewidth=2, label='Adjoint (β²)')
ax2.semilogy(betas, c_h0, 'g--', linewidth=1.5, label='Higher-0 (β³)')
ax2.semilogy(betas, c_h1, 'm--', linewidth=1.5, label='Higher-1 (β⁴)')
ax2.semilogy(betas, c_h2, 'c--', linewidth=1.5, label='Higher-2 (β⁵)')
ax2.set_xlabel('Coupling parameter β', fontsize=13)
ax2.set_ylabel('Sector Coefficient (log scale)', fontsize=13)
ax2.set_title('Sector Ordering (Log Scale)', fontsize=14)
ax2.legend(fontsize=10, loc='lower right')
ax2.set_xlim([0.01, 1])
ax2.set_ylim([1e-15, 10])
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sector_coefficients.png', dpi=150, bbox_inches='tight')
print("Saved: sector_coefficients.png")
