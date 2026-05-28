"""
Visualization 3: Spectral decomposition of the leaf Hessian and its
connection to the complete graph / symmetric group representation.

Shows:
- Left: The quadratic form Q(v) = (Σvᵢ)² - ||v||² on the 2D unit circle
  (for m=3), revealing the one-positive-eigenvalue structure.
- Right: Eigenvalue spectrum of J-I for various m, showing the universal
  gap of 1 between the negative eigenvalue -1 and the boundary 0.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Plot 1: Quadratic form on unit circle (m=3) ----
ax1 = axes[0]
m = 3
theta = np.linspace(0, 2 * np.pi, 500)

# For m=3, consider vectors in the plane {Σvᵢ = 0} ∩ S¹
# Parameterize: v = cos(θ)(1,-1,0)/√2 + sin(θ)(1,1,-2)/√6
e1 = np.array([1, -1, 0]) / np.sqrt(2)
e2 = np.array([1, 1, -2]) / np.sqrt(6)

Q_vals = []
for t in theta:
    v = np.cos(t) * e1 + np.sin(t) * e2
    Q = np.sum(v)**2 - np.sum(v**2)
    Q_vals.append(Q)

Q_vals = np.array(Q_vals)

# Q should be -1 everywhere on this plane (eigenvalue -1)
ax1.plot(theta / np.pi, Q_vals, 'b-', linewidth=2)
ax1.axhline(y=-1, color='red', linestyle='--', linewidth=1.5, label='Eigenvalue = -1')
ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5, alpha=0.3)

# Also show Q on the all-ones direction + orthogonal
all_ones = np.array([1, 1, 1]) / np.sqrt(3)
Q_allones_vals = []
for t in theta:
    v = np.cos(t) * all_ones + np.sin(t) * e1
    norm_sq = np.sum(v**2)
    Q = np.sum(v)**2 - norm_sq
    Q_allones_vals.append(Q / norm_sq if norm_sq > 1e-10 else 0)

ax1.plot(theta / np.pi, Q_allones_vals, 'g-', linewidth=2, alpha=0.7,
         label='Q/||v||² in (𝟏, e₁) plane')

ax1.fill_between(theta / np.pi, -2, 0, alpha=0.1, color='red',
                  label='Negative (Lorentzian)')
ax1.fill_between(theta / np.pi, 0, 3, alpha=0.1, color='green',
                  label='Positive')

ax1.set_xlabel('Angle θ/π', fontsize=12)
ax1.set_ylabel('Q(v) / ||v||²', fontsize=12)
ax1.set_title(f'Rayleigh Quotient (m = {m})\nQ = (Σvᵢ)² - Σvᵢ²', fontsize=13)
ax1.legend(fontsize=8, loc='upper right')
ax1.set_ylim(-1.5, 3)
ax1.grid(True, alpha=0.3)

# ---- Plot 2: Eigenvalue spectrum for various m ----
ax2 = axes[1]
m_values = range(2, 13)

for idx, m in enumerate(m_values):
    # Positive eigenvalue: m-1
    ax2.plot(m, m-1, 'bo', markersize=8 if m <= 6 else 6)
    # Negative eigenvalues: -1 (multiplicity m-1)
    # Show as a thick bar
    ax2.plot([m, m], [-1, -1], 'rs', markersize=6)
    # Show multiplicity as bar width
    width = 0.3
    ax2.barh(-1, width, left=m-width/2, height=0.15, color='red', alpha=0.3)

# Labels
ax2.plot([], [], 'bo', markersize=8, label='λ₊ = m-1 (×1)')
ax2.plot([], [], 'rs', markersize=6, label='λ₋ = -1 (×(m-1))')

# Shade the gap region
ax2.axhspan(-1, 0, alpha=0.08, color='orange', label='Spectral gap = 1')
ax2.axhline(y=0, color='black', linewidth=1, alpha=0.5, label='Boundary')
ax2.axhline(y=-1, color='red', linewidth=0.5, linestyle=':', alpha=0.5)

ax2.set_xlabel('Leaf dimension m', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title('Spectrum of J - I\n(Adjacency of Complete Graph Kₘ)', fontsize=13)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_xticks(list(m_values))
ax2.grid(True, alpha=0.2)

# ---- Plot 3: Representation theory decomposition ----
ax3 = axes[2]

# Show the dimension formula: ℝᵐ = trivial ⊕ standard
m_vals = np.arange(2, 15)
trivial_dims = np.ones_like(m_vals)
standard_dims = m_vals - 1

ax3.bar(m_vals - 0.15, trivial_dims, width=0.3, color='blue', alpha=0.7,
        label='Trivial rep (dim 1)\nEigenvalue m-1')
ax3.bar(m_vals + 0.15, standard_dims, width=0.3, color='red', alpha=0.7,
        label='Standard rep (dim m-1)\nEigenvalue -1')

# Annotate the decomposition
ax3.text(8, 10, r'$\mathbb{R}^m = \mathrm{triv} \oplus \mathrm{std}$',
         fontsize=13, ha='center',
         bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.8))
ax3.text(8, 8.5, 'Lorentzian ⟺ one positive eigenvalue',
         fontsize=10, ha='center', style='italic', color='darkgreen')

ax3.set_xlabel('Leaf dimension m', fontsize=12)
ax3.set_ylabel('Representation dimension', fontsize=12)
ax3.set_title('Sₘ Representation Decomposition\nGoverning Lorentzian Structure', fontsize=13)
ax3.legend(fontsize=8)
ax3.set_xticks(m_vals)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
