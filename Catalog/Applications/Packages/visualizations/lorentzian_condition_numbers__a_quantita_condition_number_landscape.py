#!/usr/bin/env python3
"""
Visualization: Lorentzian Condition Number Landscape

Visualizes how the condition number κ and certified perturbation radius
vary across uniform matroid families, showing the m² scaling law.
This illustrates the central theorem that algebraic conditioning
controls perturbation robustness.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def spectral_gap(H):
    eigs = np.linalg.eigvalsh(H)
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0

def operator_norm(H):
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))

def has_lorentzian_signature(H, tol=1e-10):
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1


ms = list(range(3, 25))
kappas = []
gaps = []
op_norms = []
entry_radii = []

for m in ms:
    H = leaf_hessian(m)
    g = spectral_gap(H)
    n = operator_norm(H)
    gaps.append(g)
    op_norms.append(n)
    kappas.append(n / g)
    entry_radii.append(1.0 / m**2)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Lorentzian Condition Number Theory: Uniform Matroid Family', 
             fontsize=14, fontweight='bold')

# Panel 1: Condition number
ax = axes[0, 0]
ax.plot(ms, kappas, 'bo-', markersize=5, label='Computed κ = N/g')
ax.plot(ms, [m-1 for m in ms], 'r--', alpha=0.7, label='Exact: m−1')
ax.set_xlabel('Variables m')
ax.set_ylabel('Condition number κ')
ax.set_title('Condition Number vs Dimension')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Spectral data
ax = axes[0, 1]
ax.plot(ms, gaps, 'gs-', markersize=5, label='Spectral gap g = 1')
ax.plot(ms, op_norms, 'r^-', markersize=5, label='Operator norm N = m−1')
ax.set_xlabel('Variables m')
ax.set_ylabel('Value')
ax.set_title('Spectral Data')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Certified radius (log scale)
ax = axes[1, 0]
ax.loglog(ms, entry_radii, 'bo-', markersize=5, label='Certified: 1/m²')
ax.loglog(ms, [1/m for m in ms], 'r--', alpha=0.7, label='QF radius: 1/m')
ax.loglog(ms, [1/(m**2*(m-1)) for m in ms], 'g:', alpha=0.7, label='Tight: 1/(m²κ)')
ax.set_xlabel('Variables m')
ax.set_ylabel('Perturbation radius')
ax.set_title('Certified Stability Radius')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Empirical stability test for m=8
ax = axes[1, 1]
m = 8
H = leaf_hessian(m)
epsilons = np.logspace(-3, 0.3, 25)
survival = []
for eps in epsilons:
    count = 0
    for _ in range(300):
        E = np.random.randn(m, m)
        E = (E + E.T) / 2
        E *= eps / max(np.max(np.abs(E)), 1e-15)
        if has_lorentzian_signature(H + E):
            count += 1
    survival.append(count / 300)

ax.semilogx(epsilons, survival, 'b.-', markersize=4)
ax.axvline(x=1/m**2, color='r', linestyle='--', linewidth=2, label=f'1/m² = {1/m**2:.4f}')
ax.axvline(x=1.0, color='g', linestyle=':', linewidth=2, label='Gap = 1')
ax.set_xlabel('Entry perturbation ε')
ax.set_ylabel('Fraction preserving signature')
ax.set_title(f'Empirical Stability (m={m})')
ax.legend()
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_condition_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_condition_landscape.png")
