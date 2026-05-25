#!/usr/bin/env python3
"""
Visualization 2: Energy Landscape and Polarization Identity

Visualizes the quadratic energy functional E(T, v) = vᵀTv for a 2D
metric tensor, showing:
- The energy surface as a function of vector components
- The polarization decomposition: E(u+v) = E(u) + cross terms + E(v)
- Energy level curves demonstrating the quadratic structure
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

np.random.seed(42)

fig = plt.figure(figsize=(16, 5))

# ─── Panel 1: Energy Surface ─────────────────────────────────────────────
ax1 = fig.add_subplot(131, projection='3d')

# Symmetric positive-definite 2x2 matrix
T = np.array([[3.0, 1.0], [1.0, 2.0]])

x = np.linspace(-2, 2, 80)
y = np.linspace(-2, 2, 80)
X, Y = np.meshgrid(x, y)
Z = np.zeros_like(X)

for i in range(len(x)):
    for j in range(len(y)):
        v = np.array([X[i, j], Y[i, j]])
        Z[i, j] = v @ T @ v

ax1.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8, linewidth=0.2,
                 edgecolor='gray', rcount=40, ccount=40)
ax1.set_xlabel('v₁')
ax1.set_ylabel('v₂')
ax1.set_zlabel('E(T, v)')
ax1.set_title('Quadratic Energy\nE(T, v) = vᵀTv', fontsize=11)

# ─── Panel 2: Polarization Decomposition ─────────────────────────────────
ax2 = fig.add_subplot(132)

# Fix u, vary v along a line
u = np.array([1.0, 0.5])
t_vals = np.linspace(-2, 2, 200)

E_total = []
E_u_only = []
E_v_only = []
E_cross = []

for t in t_vals:
    v = t * np.array([0.3, 1.0])
    uv = u + v

    e_total = uv @ T @ uv
    e_u = u @ T @ u
    e_v = v @ T @ v
    cross = u @ T @ v + v @ T @ u

    E_total.append(e_total)
    E_u_only.append(e_u)
    E_v_only.append(e_v)
    E_cross.append(cross)

ax2.plot(t_vals, E_total, 'b-', linewidth=2, label='E(T, u+tv)')
ax2.plot(t_vals, E_u_only, 'g--', linewidth=1.5, label='E(T, u)')
ax2.plot(t_vals, E_v_only, 'r--', linewidth=1.5, label='E(T, tv)')
ax2.plot(t_vals, E_cross, 'm:', linewidth=1.5, label='Cross terms')
ax2.fill_between(t_vals,
                 [a + b + c for a, b, c in zip(E_u_only, E_v_only, E_cross)],
                 alpha=0.1, color='blue')
ax2.set_xlabel('t (perturbation scale)')
ax2.set_ylabel('Energy')
ax2.set_title('Polarization Identity\nE(u+v) = E(u) + cross + E(v)', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ─── Panel 3: Energy Contours with Contraction Vectors ───────────────────
ax3 = fig.add_subplot(133)

ax3.contour(X, Y, Z, levels=20, cmap='coolwarm', alpha=0.7)
ax3.contourf(X, Y, Z, levels=20, cmap='coolwarm', alpha=0.3)

# Show contraction directions
for angle in np.linspace(0, 2*np.pi, 8, endpoint=False):
    v = np.array([np.cos(angle), np.sin(angle)])
    Tv = T @ v
    energy = float(v @ Tv)
    color = 'darkred' if energy > 3 else 'darkblue'
    ax3.arrow(0, 0, v[0], v[1], head_width=0.08, head_length=0.05,
              fc=color, ec=color, alpha=0.7)
    ax3.arrow(v[0], v[1], 0.3*Tv[0]/np.linalg.norm(Tv), 0.3*Tv[1]/np.linalg.norm(Tv),
              head_width=0.06, head_length=0.04, fc='green', ec='green', alpha=0.5)

ax3.set_xlabel('v₁')
ax3.set_ylabel('v₂')
ax3.set_title('Energy Contours &\nContraction Directions', fontsize=11)
ax3.set_aspect('equal')
ax3.set_xlim(-2, 2)
ax3.set_ylim(-2, 2)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy.png")
