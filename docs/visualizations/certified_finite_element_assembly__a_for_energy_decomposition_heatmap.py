#!/usr/bin/env python3
"""
Visualization: Energy Decomposition Across Mesh Elements

Visualizes how the total strain energy of an assembled finite element system
decomposes into element-wise contributions. Shows a heatmap of element energies
overlaid on the mesh, demonstrating Theorem 2 (energy linearity in stiffness):
E(∑ Kᵢ, u) = ∑ E(Kᵢ, u).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.tri as tri
from matplotlib.collections import PolyCollection

def generate_mesh(nx, ny):
    x = np.linspace(0, 1, nx + 1)
    y = np.linspace(0, 1, ny + 1)
    xx, yy = np.meshgrid(x, y)
    nodes = np.column_stack([xx.ravel(), yy.ravel()])
    elements = []
    for i in range(ny):
        for j in range(nx):
            n0 = i * (nx + 1) + j
            n1 = n0 + 1
            n2 = n0 + (nx + 1)
            n3 = n2 + 1
            elements.append([n0, n1, n2])
            elements.append([n1, n3, n2])
    return nodes, np.array(elements)

def local_stiffness(nodes, elem, E=1.0, nu=0.3):
    coords = nodes[elem]
    x1, y1 = coords[0]; x2, y2 = coords[1]; x3, y3 = coords[2]
    A = 0.5 * abs((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1))
    if A < 1e-15: return np.zeros((6,6))
    b = [y2-y3, y3-y1, y1-y2]; c = [x3-x2, x1-x3, x2-x1]
    B = np.array([[b[0],0,b[1],0,b[2],0],[0,c[0],0,c[1],0,c[2]],
                   [c[0],b[0],c[1],b[1],c[2],b[2]]]) / (2*A)
    D = (E/(1-nu**2)) * np.array([[1,nu,0],[nu,1,0],[0,0,(1-nu)/2]])
    K = A * B.T @ D @ B
    return 0.5*(K+K.T)

nx, ny = 15, 15
nodes, elements = generate_mesh(nx, ny)
n_nodes = len(nodes)

# Compute element energies with a localized displacement
np.random.seed(42)
total_dofs = 2 * n_nodes
u = np.zeros(total_dofs)
# Create a displacement field concentrated at center
for i, (x, y) in enumerate(nodes):
    r = np.sqrt((x-0.5)**2 + (y-0.5)**2)
    u[2*i] = 0.1 * np.exp(-10*r**2) * (x - 0.5)
    u[2*i+1] = 0.1 * np.exp(-10*r**2) * (y - 0.5)

element_energies = []
for elem in elements:
    K = local_stiffness(nodes, elem)
    dofs = np.array([2*n+d for n in elem for d in range(2)])
    u_local = u[dofs]
    e = float(u_local @ K @ u_local)
    element_energies.append(e)

element_energies = np.array(element_energies)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Mesh with element energies
ax = axes[0]
triangles = []
for elem in elements:
    triangles.append(nodes[elem])
colors = element_energies / max(element_energies.max(), 1e-15)
pc = PolyCollection(triangles, array=colors, cmap='YlOrRd', edgecolors='gray',
                     linewidths=0.3)
ax.add_collection(pc)
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 1.05)
ax.set_aspect('equal')
ax.set_title('Element Energy Distribution\n(Theorem 2: E = ∑ Eᵢ)', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')
plt.colorbar(pc, ax=ax, label='Normalized Energy')

# Plot 2: Energy histogram
ax = axes[1]
ax.hist(element_energies[element_energies > 0], bins=30, color='steelblue',
        edgecolor='white', alpha=0.8)
ax.set_xlabel('Element Energy')
ax.set_ylabel('Count')
ax.set_title('Energy Distribution Histogram', fontsize=12)
ax.axvline(element_energies.mean(), color='red', linestyle='--',
           label=f'Mean = {element_energies.mean():.2e}')
ax.legend()

# Plot 3: Cumulative energy
ax = axes[2]
sorted_e = np.sort(element_energies)[::-1]
cumulative = np.cumsum(sorted_e) / sorted_e.sum()
ax.plot(range(1, len(sorted_e)+1), cumulative, 'b-', linewidth=2)
ax.fill_between(range(1, len(sorted_e)+1), cumulative, alpha=0.2)
ax.set_xlabel('Number of Elements (sorted by energy)')
ax.set_ylabel('Cumulative Energy Fraction')
ax.set_title('Cumulative Energy Concentration', fontsize=12)
ax.axhline(0.9, color='red', linestyle='--', alpha=0.5, label='90% threshold')
n90 = np.searchsorted(cumulative, 0.9) + 1
ax.axvline(n90, color='red', linestyle=':', alpha=0.5)
ax.legend()
ax.grid(True, alpha=0.3)

total = element_energies.sum()
fig.suptitle(f'Certified Energy Decomposition — {len(elements)} Elements, '
             f'Total Energy = {total:.4e}', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_energy_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_decomposition.png")
