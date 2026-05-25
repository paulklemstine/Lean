#!/usr/bin/env python3
"""
Visualization 3: Representation Concentration and Confinement

Visualizes the information-theoretic confinement diagnostic: the normalized
representation distribution concentrates on the trivial sector at strong
coupling (small β), with Shannon entropy dropping to zero. This is the
cross-domain bridge connecting gauge theory mass gaps to information theory.
"""

import numpy as np
import matplotlib.pyplot as plt

def compute_probs(beta, n_sectors=8):
    """Compute normalized representation distribution."""
    coeffs = [1.0, 2*beta, beta**2]  # triv, fund, adj
    for k in range(n_sectors - 3):
        coeffs.append(beta ** (k + 3))
    total = sum(coeffs)
    return [c / total for c in coeffs]

def shannon_entropy(probs):
    """Compute Shannon entropy in bits."""
    return -sum(p * np.log2(p) for p in probs if p > 0)

betas = np.logspace(-3, 0.5, 300)

p_triv = []
p_fund = []
p_adj = []
entropies = []
nontrivial_weight = []

for beta in betas:
    probs = compute_probs(beta)
    p_triv.append(probs[0])
    p_fund.append(probs[1])
    p_adj.append(probs[2])
    entropies.append(shannon_entropy(probs))
    nontrivial_weight.append(1 - probs[0])

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Sector probabilities
ax1 = axes[0, 0]
ax1.semilogx(betas, p_triv, 'k-', linewidth=2, label='p(trivial)')
ax1.semilogx(betas, p_fund, 'b-', linewidth=2, label='p(fundamental)')
ax1.semilogx(betas, p_adj, 'r-', linewidth=1.5, label='p(adjoint)')
ax1.set_xlabel('Coupling parameter β', fontsize=12)
ax1.set_ylabel('Sector Probability', fontsize=12)
ax1.set_title('Representation Distribution', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim([0, 1.05])
ax1.grid(True, alpha=0.3)

# Top right: Entropy
ax2 = axes[0, 1]
ax2.semilogx(betas, entropies, 'purple', linewidth=2)
ax2.set_xlabel('Coupling parameter β', fontsize=12)
ax2.set_ylabel('Shannon Entropy (bits)', fontsize=12)
ax2.set_title('Representation Entropy', fontsize=13)
ax2.grid(True, alpha=0.3)

# Bottom left: Nontrivial weight (confinement order parameter)
ax3 = axes[1, 0]
ax3.loglog(betas, nontrivial_weight, 'darkred', linewidth=2)
ax3.set_xlabel('Coupling parameter β', fontsize=12)
ax3.set_ylabel('1 − p(trivial)', fontsize=12)
ax3.set_title('Nontrivial Sector Weight (Confinement Parameter)', fontsize=13)
ax3.grid(True, alpha=0.3)

# Bottom right: Gap vs entropy phase diagram
ax4 = axes[1, 1]
gaps = [-np.log(2 * b) for b in betas]
scatter = ax4.scatter(entropies, gaps, c=np.log10(betas), cmap='viridis',
                      s=10, alpha=0.7)
ax4.set_xlabel('Shannon Entropy (bits)', fontsize=12)
ax4.set_ylabel('Mass Gap', fontsize=12)
ax4.set_title('Gap–Entropy Phase Diagram', fontsize=13)
cbar = plt.colorbar(scatter, ax=ax4)
cbar.set_label('log₁₀(β)', fontsize=11)
ax4.grid(True, alpha=0.3)

plt.suptitle('Information-Theoretic Confinement Diagnostics', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('confinement_diagnostics.png', dpi=150, bbox_inches='tight')
print("Saved: confinement_diagnostics.png")
