#!/usr/bin/env python3
"""
Visualization: PSD Transfer and Eigenvalue Spectrum

Visualizes Theorem 3 (energy_nonneg_of_local_psd): if each local stiffness
matrix Kᵢ is positive semidefinite, then the assembled matrix K = ∑ Kᵢ is
also PSD. Shows the eigenvalue spectra of local and global matrices, and
how local PSD guarantees global non-negative energy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

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

nx, ny = 8, 8
nodes, elements = generate_mesh(nx, ny)
n_nodes = len(nodes)
total_dofs = 2 * n_nodes

# Build local and global stiffness
K_locals = [local_stiffness(nodes, elem) for elem in elements]

# Assemble global
K_global = np.zeros((total_dofs, total_dofs))
for elem_idx, elem in enumerate(elements):
    dofs = np.array([2*n+d for n in elem for d in range(2)])
    K_loc = K_locals[elem_idx]
    for i, gi in enumerate(dofs):
        for j, gj in enumerate(dofs):
            K_global[gi, gj] += K_loc[i, j]

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Local eigenvalue spectra
ax = axes[0, 0]
all_local_eigvals = []
for K in K_locals:
    eigvals = np.linalg.eigvalsh(K)
    all_local_eigvals.extend(eigvals)
all_local_eigvals = np.array(all_local_eigvals)
ax.hist(all_local_eigvals[all_local_eigvals > 1e-12], bins=50,
        color='steelblue', edgecolor='white', alpha=0.8)
ax.set_xlabel('Eigenvalue')
ax.set_ylabel('Count')
ax.set_title(f'Local Stiffness Eigenvalues\n({len(elements)} elements × 6 eigenvalues each)',
             fontsize=11)
ax.axvline(0, color='red', linestyle='--', linewidth=2, label='λ = 0 (PSD boundary)')
ax.legend()
ax.set_xlim(left=-0.01)
ax.grid(True, alpha=0.3)

# Panel 2: Global eigenvalue spectrum
ax = axes[0, 1]
global_eigvals = np.linalg.eigvalsh(K_global)
ax.semilogy(range(len(global_eigvals)), np.sort(global_eigvals)[::-1], 'b-o',
            markersize=2)
ax.set_xlabel('Eigenvalue Index')
ax.set_ylabel('Eigenvalue (log scale)')
ax.set_title(f'Global Stiffness Spectrum\n(All ≥ 0 by Theorem 3)', fontsize=11)
ax.axhline(0, color='red', linestyle='--', alpha=0.5)
ax.grid(True, alpha=0.3)

# Panel 3: PSD verification — random displacement energies
ax = axes[1, 0]
np.random.seed(42)
n_samples = 500
energies = []
for _ in range(n_samples):
    u = np.random.randn(total_dofs)
    u /= np.linalg.norm(u)
    e = float(u @ K_global @ u)
    energies.append(e)
ax.hist(energies, bins=40, color='#4CAF50', edgecolor='white', alpha=0.8)
ax.axvline(0, color='red', linewidth=2, linestyle='--', label='E = 0')
ax.set_xlabel('Energy E(K, u) for ||u|| = 1')
ax.set_ylabel('Count')
ax.set_title(f'Energy Distribution ({n_samples} random displacements)\n'
             f'All non-negative ✓ (Theorem 3)', fontsize=11)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Scaling of min eigenvalue with mesh refinement
ax = axes[1, 1]
mesh_sizes = [3, 5, 8, 10, 15, 20]
min_eigvals = []
n_elems_list = []
for ns in mesh_sizes:
    nds, els = generate_mesh(ns, ns)
    nn = len(nds)
    td = 2 * nn
    Kg = np.zeros((td, td))
    for elem in els:
        K = local_stiffness(nds, elem)
        dofs = np.array([2*n+d for n in elem for d in range(2)])
        for i, gi in enumerate(dofs):
            for j, gj in enumerate(dofs):
                Kg[gi, gj] += K[i, j]
    evals = np.linalg.eigvalsh(Kg)
    # Count near-zero eigenvalues (rigid body modes)
    n_zero = np.sum(evals < 1e-8)
    # Smallest non-zero eigenvalue
    nonzero_evals = evals[evals > 1e-8]
    min_nonzero = nonzero_evals.min() if len(nonzero_evals) > 0 else 0
    min_eigvals.append(min_nonzero)
    n_elems_list.append(len(els))

ax.loglog(n_elems_list, min_eigvals, 'bo-', linewidth=2, markersize=8)
ax.set_xlabel('Number of Elements')
ax.set_ylabel('Smallest Non-Zero Eigenvalue')
ax.set_title('Eigenvalue Scaling with Mesh Refinement\n(PSD preserved at all scales)',
             fontsize=11)
ax.grid(True, alpha=0.3, which='both')

fig.suptitle('PSD Transfer: Local → Global (Theorem 3)\n'
             '∀i, ∀v: ⟨v, Kᵢv⟩ ≥ 0  ⟹  ∀v: ⟨v, (∑Kᵢ)v⟩ ≥ 0',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_psd_transfer.png', dpi=150, bbox_inches='tight')
print("Saved viz_psd_transfer.png")
