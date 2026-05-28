"""
Visualization: Eigenvalue Structure of Uniform Leaf Hessians

This script visualizes how the eigenvalues of the uniform leaf Hessian
(J - I, the adjacency matrix of K_m) change with dimension m, and how
the Lorentzian spectral gap remains constant at 1 while the positive
eigenvalue grows linearly.

The key insight: the stability radius is controlled by the NEGATIVE
eigenvalue (always -1), not the positive one (m-1). This is because
Lorentzianity requires at most one positive eigenvalue, so the
perturbation must not push any of the (m-1) negative eigenvalues
across zero.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Parameters
m_values = range(2, 16)

# Compute eigenvalue data
pos_eigs = [m - 1 for m in m_values]
neg_eigs = [-1 for _ in m_values]
neg_mults = [m - 1 for m in m_values]
gaps = [1.0 for _ in m_values]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Eigenvalue spectrum vs dimension
ax1 = axes[0, 0]
ax1.plot(list(m_values), pos_eigs, 'ro-', markersize=8, linewidth=2, label='λ₊ = m-1 (mult. 1)')
ax1.plot(list(m_values), neg_eigs, 'bs-', markersize=8, linewidth=2, label='λ₋ = -1 (mult. m-1)')
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.fill_between(list(m_values), 0, neg_eigs, alpha=0.1, color='blue',
                  label='Lorentzian gap = 1')
ax1.set_xlabel('Leaf dimension m', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Spectrum of J - I (Complete Graph K_m)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Stability radius vs dimension
ax2 = axes[0, 1]
entry_radii = [1.0 / m**2 for m in m_values]
op_radii = [1.0 for _ in m_values]
ax2.semilogy(list(m_values), op_radii, 'go-', markersize=8, linewidth=2,
              label='Operator norm radius = 1')
ax2.semilogy(list(m_values), entry_radii, 'r^-', markersize=8, linewidth=2,
              label='Entry norm radius = 1/m²')
ax2.set_xlabel('Leaf dimension m', fontsize=12)
ax2.set_ylabel('Stability radius', fontsize=12)
ax2.set_title('Stability Radii vs Dimension', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Quadratic form on orthogonal complement
ax3 = axes[1, 0]
theta = np.linspace(0, 2*np.pi, 200)
for m in [3, 5, 8, 12]:
    # On the sum-zero hyperplane, Q(v) = -||v||^2
    # Parametrize v = cos(θ)·e₁ + sin(θ)·e₂ where e₁, e₂ ∈ {∑vi=0}
    r_vals = np.ones_like(theta)  # ||v|| = 1
    q_vals = -r_vals  # Q = -||v||^2 = -1 on unit circle
    ax3.plot(theta * 180 / np.pi, q_vals, linewidth=2, label=f'm = {m}')

# Show perturbation effect
for delta in [0.3, 0.6, 0.9]:
    q_perturbed = -1 + delta
    ax3.axhline(y=q_perturbed, color='gray', linestyle=':', alpha=0.5)
ax3.axhline(y=0, color='red', linestyle='--', linewidth=1.5, label='Lorentzian boundary')
ax3.set_xlabel('Direction on sum-zero hyperplane (degrees)', fontsize=12)
ax3.set_ylabel('Q(v) on unit sphere', fontsize=12)
ax3.set_title('Quadratic Form on Orthogonal Complement', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.annotate('Gap = 1', xy=(90, -0.5), fontsize=11, ha='center',
              arrowprops=dict(arrowstyle='->', color='blue'),
              xytext=(90, 0.3), color='blue')

# Panel 4: Hessian structure visualization (heatmap for m=6)
ax4 = axes[1, 1]
m_show = 6
H = np.ones((m_show, m_show)) - np.eye(m_show)
im = ax4.imshow(H, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax4.set_title(f'Leaf Hessian J - I for m = {m_show}', fontsize=13, fontweight='bold')
ax4.set_xlabel('Column index j', fontsize=12)
ax4.set_ylabel('Row index i', fontsize=12)
for i in range(m_show):
    for j in range(m_show):
        ax4.text(j, i, f'{int(H[i,j])}', ha='center', va='center', fontsize=14,
                 color='white' if H[i,j] == 0 else 'black')
plt.colorbar(im, ax=ax4, shrink=0.8)

plt.suptitle('Spectral Structure of Lorentzian Stability for Uniform Matroids',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gap.png")
