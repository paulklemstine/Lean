"""
Visualization 3: Quadratic Form Decomposition

Visualizes the quadratic form Q(v) = (∑vᵢ)² - ∑vᵢ² for the leaf Hessian J - I
on a 2D slice. Shows how the positive (sum-squared) and negative (norm-squared)
components interact to create the Lorentzian signature with exactly one positive
eigenvalue direction.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# --- Panel 1: 2D quadratic form contours ---
ax = axes[0, 0]
x = np.linspace(-2, 2, 200)
y = np.linspace(-2, 2, 200)
X, Y = np.meshgrid(x, y)

# Q(v) = (x + y)² - (x² + y²) = 2xy for m=2
Q = (X + Y)**2 - (X**2 + Y**2)

contour = ax.contourf(X, Y, Q, levels=20, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Q, levels=[0], colors='black', linewidths=2)
plt.colorbar(contour, ax=ax, label='Q(v₁, v₂)')
ax.set_xlabel('v₁', fontsize=12)
ax.set_ylabel('v₂', fontsize=12)
ax.set_title('Quadratic Form Q = 2v₁v₂ (m=2)', fontsize=13)
ax.arrow(0, 0, 1, 1, head_width=0.1, head_length=0.05, fc='green', ec='green', linewidth=2)
ax.arrow(0, 0, 1, -1, head_width=0.1, head_length=0.05, fc='red', ec='red', linewidth=2)
ax.text(1.1, 1.1, '+', fontsize=14, color='green', fontweight='bold')
ax.text(1.1, -1.1, '−', fontsize=14, color='red', fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: 3D slice for m=3 ---
ax = axes[0, 1]
# Fix v₃ = 0, plot Q(v₁, v₂, 0) = (v₁ + v₂)² - (v₁² + v₂²) = 2v₁v₂
Q3 = (X + Y)**2 - (X**2 + Y**2)  # Same as m=2 slice
contour = ax.contourf(X, Y, Q3, levels=20, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Q3, levels=[0], colors='black', linewidths=2)
plt.colorbar(contour, ax=ax, label='Q(v₁, v₂, 0)')
ax.set_xlabel('v₁', fontsize=12)
ax.set_ylabel('v₂', fontsize=12)
ax.set_title('Leaf Q-form slice: m=3, v₃=0', fontsize=13)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 3: Decomposition along radial directions ---
ax = axes[1, 0]
theta = np.linspace(0, 2 * np.pi, 360)

for m in [2, 3, 5, 8]:
    # On the unit circle in 2D subspace: v = (cos θ, sin θ, 0, ..., 0)
    sum_v = np.cos(theta) + np.sin(theta)
    norm_v = 1.0  # unit vector
    Q_vals = sum_v**2 - norm_v
    ax.plot(np.degrees(theta), Q_vals, linewidth=2, label=f'm={m} (2D slice)')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.axhline(y=-1, color='red', linestyle='--', linewidth=1, alpha=0.5, label='Gap = -1')
ax.set_xlabel('Angle θ (degrees)', fontsize=12)
ax.set_ylabel('Q(v)', fontsize=12)
ax.set_title('Q along unit circle in 2D subspace', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Eigenvalue structure as bar chart ---
ax = axes[1, 1]
ms = [3, 5, 8, 12]
x_pos = np.arange(len(ms))
bar_width = 0.35

pos_eigs = [m - 1 for m in ms]
neg_eigs = [-1 for _ in ms]

bars1 = ax.bar(x_pos - bar_width/2, pos_eigs, bar_width, label='λ₁ = m-1',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x_pos + bar_width/2, neg_eigs, bar_width, label='λ₂ = -1',
               color='indianred', alpha=0.8)

ax.set_xlabel('Number of variables m', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Eigenvalue Structure of J - I', fontsize=13)
ax.set_xticks(x_pos)
ax.set_xticklabels([str(m) for m in ms])
ax.legend(fontsize=10)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.grid(True, alpha=0.3, axis='y')

# Add multiplicity annotations
for i, m in enumerate(ms):
    ax.text(i - bar_width/2, pos_eigs[i] + 0.3, '×1', ha='center', fontsize=9)
    ax.text(i + bar_width/2, neg_eigs[i] - 0.8, f'×{m-1}', ha='center', fontsize=9)

fig.suptitle('Quadratic Form Decomposition: Q(v) = (Σvᵢ)² − Σvᵢ²',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_quadform_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_quadform_decomposition.png")
