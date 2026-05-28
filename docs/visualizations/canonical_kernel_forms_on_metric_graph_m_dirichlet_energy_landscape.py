"""
Visualization: Dirichlet Energy Landscape on a Cycle Graph

Visualizes the Dirichlet energy E(f) as a function of vertex potentials
on a 3-vertex cycle graph. Shows the energy's positive semi-definiteness,
its zero locus (constant functions), and the constraint manifold for
mean-zero potentials.

Key insight: The energy landscape is a paraboloid whose kernel is exactly
the space of constant functions — the geometric reason that harmonic
representatives are unique modulo constants.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Build cycle graph C_3 with edge lengths (1, 2, 1.5)
edge_lengths = [1.0, 2.0, 1.5]
n = 3

# Conductance matrix
C = np.zeros((n, n))
for i in range(n):
    j = (i + 1) % n
    c = 1.0 / edge_lengths[i]
    C[i, j] = C[j, i] = c

# Laplacian
L = -C.copy()
np.fill_diagonal(L, C.sum(axis=1))

# On the mean-zero plane sum(f) = 0, we parameterize:
# f = (x, y, -x-y) for (x, y) ∈ R²
# Energy E(f) = f^T L f

x_range = np.linspace(-2, 2, 100)
y_range = np.linspace(-2, 2, 100)
X, Y = np.meshgrid(x_range, y_range)

E = np.zeros_like(X)
for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        f = np.array([X[i, j], Y[i, j], -X[i, j] - Y[i, j]])
        E[i, j] = f @ L @ f

fig = plt.figure(figsize=(14, 5))

# Plot 1: 3D energy surface
ax1 = fig.add_subplot(131, projection='3d')
ax1.plot_surface(X, Y, E, cmap='viridis', alpha=0.8, edgecolor='none')
ax1.set_xlabel('f(v₀)', fontsize=10)
ax1.set_ylabel('f(v₁)', fontsize=10)
ax1.set_zlabel('Energy E(f)', fontsize=10)
ax1.set_title('Dirichlet Energy\n(Mean-Zero Plane)', fontsize=11)
ax1.view_init(elev=25, azim=45)

# Plot 2: Contour plot
ax2 = fig.add_subplot(132)
levels = np.linspace(0, E.max() * 0.8, 20)
cp = ax2.contourf(X, Y, E, levels=levels, cmap='viridis')
ax2.contour(X, Y, E, levels=levels, colors='white', linewidths=0.3, alpha=0.5)
plt.colorbar(cp, ax=ax2, label='Energy')
ax2.set_xlabel('f(v₀)', fontsize=11)
ax2.set_ylabel('f(v₁)', fontsize=11)
ax2.set_title('Energy Contours\n(Mean-Zero Plane)', fontsize=11)

# Mark the minimum (origin = zero energy)
ax2.plot(0, 0, 'r*', markersize=15, label='Minimum (f=0)')
ax2.legend(fontsize=9)
ax2.set_aspect('equal')

# Plot 3: Energy along edges
ax3 = fig.add_subplot(133)

# Parameterize f along unit vectors in the mean-zero plane
directions = [
    (np.array([1, 0, -1]) / np.sqrt(2), 'f = t(1, 0, -1)/√2'),
    (np.array([0, 1, -1]) / np.sqrt(2), 'f = t(0, 1, -1)/√2'),
    (np.array([1, -1, 0]) / np.sqrt(2), 'f = t(1, -1, 0)/√2'),
]

t_range = np.linspace(-2, 2, 200)
for direction, label in directions:
    energies = [t**2 * (direction @ L @ direction) for t in t_range]
    ax3.plot(t_range, energies, linewidth=2, label=label)

ax3.set_xlabel('Parameter t', fontsize=11)
ax3.set_ylabel('Energy E(f)', fontsize=11)
ax3.set_title('Energy Along\nMean-Zero Directions', fontsize=11)
ax3.legend(fontsize=8)
ax3.set_ylim(bottom=0)
ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Add eigenvalue info
eigvals = np.linalg.eigvalsh(L)
fig.text(0.5, 0.01,
    f'Cycle C₃ with lengths ({edge_lengths[0]}, {edge_lengths[1]}, {edge_lengths[2]})  |  '
    f'Laplacian eigenvalues: [{", ".join(f"{v:.3f}" for v in sorted(eigvals))}]  |  '
    f'E(f) ≥ 0 ✓ (Theorem 5)',
    ha='center', fontsize=9, style='italic')

plt.tight_layout(rect=[0, 0.04, 1, 1])
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")
