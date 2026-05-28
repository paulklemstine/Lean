#!/usr/bin/env python3
"""
Visualization: Extremal Witness Structure and Idempotent Decomposition

Visualizes the primitive idempotent decomposition of the leaf Hessian
and the extremal instability witness for the Johnson scheme J(n,2).
Shows how the all-ones direction (trivial idempotent) carries the positive
eigenvalue, while the orthogonal complement (standard representation)
carries the negative eigenvalue that controls stability.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from math import comb


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Idempotent decomposition of J-I for n=5 ---
ax = axes[0]
n = 5

# Primitive idempotents for J(n,2) = complete graph scheme
# E_0 = (1/n) * J (rank-1 projection onto all-ones)
# E_1 = I - (1/n) * J (projection onto orthogonal complement)
J = np.ones((n, n))
I = np.eye(n)
E0 = J / n
E1 = I - J / n

# Leaf Hessian
H = J - I  # = (n-1)*E0 + (-1)*E1

# Show as matrix heatmap
im = ax.imshow(H, cmap='RdBu_r', vmin=-2, vmax=n, aspect='equal')
ax.set_title(f'Leaf Hessian J-I (n={n})\n= {n-1}·E₀ + (-1)·E₁', fontsize=11, fontweight='bold')
ax.set_xticks(range(n))
ax.set_yticks(range(n))
for i in range(n):
    for j in range(n):
        ax.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# --- Panel 2: Eigenvalue spectrum and gap ---
ax = axes[1]
eigenvalues = np.linalg.eigvalsh(H)
eigenvalues.sort()

colors = ['red'] * (n - 1) + ['blue']
ax.barh(range(n), eigenvalues, color=colors, edgecolor='black', height=0.6)
ax.axvline(x=0, color='k', linewidth=1)

# Annotate the gap
ax.annotate('', xy=(0, n-1.5), xytext=(-1, n-1.5),
            arrowprops=dict(arrowstyle='<->', color='green', lw=2))
ax.text(-0.5, n-1.3, 'Gap = 1', ha='center', va='bottom', fontsize=11,
        color='green', fontweight='bold')

ax.set_xlabel('Eigenvalue', fontsize=11)
ax.set_ylabel('Index', fontsize=11)
ax.set_title(f'Spectrum of J-I (n={n})\nλ = {{4, -1, -1, -1, -1}}', fontsize=11, fontweight='bold')
ax.set_yticks(range(n))
ax.set_yticklabels([f'λ_{i+1}' for i in range(n)])

# --- Panel 3: Perturbation phase diagram ---
ax = axes[2]

# For various n, plot the Lorentzian/non-Lorentzian regions
n_vals = range(4, 12)
for n_val in n_vals:
    H = np.ones((n_val, n_val)) - np.eye(n_val)
    
    # Eigenvalues under perturbation by t*I: {n-1, -1+t, ..., -1+t}
    # Lorentzian iff -1+t <= 0 iff t <= 1
    t_range = np.linspace(0, 2, 100)
    
    # Color by Lorentzian status
    for t in t_range:
        H_pert = H + t * np.eye(n_val)
        eigs = np.linalg.eigvalsh(H_pert)
        num_pos = np.sum(eigs > 1e-10)
        if num_pos <= 1:
            ax.plot(t, n_val, 'b.', markersize=3, alpha=0.5)
        else:
            ax.plot(t, n_val, 'r.', markersize=3, alpha=0.5)

ax.axvline(x=1.0, color='green', linewidth=2, linestyle='--', label='ρ = 1 (boundary)')
ax.set_xlabel('Perturbation strength t', fontsize=11)
ax.set_ylabel('Dimension n', fontsize=11)
ax.set_title('Lorentzian Phase Diagram\nBlue = Lorentzian, Red = Unstable', fontsize=11, fontweight='bold')
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('/workspace/request-project/viz_witness_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_structure.png")
