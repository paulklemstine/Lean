#!/usr/bin/env python3
"""
Demo 2: Tropical Optimization and Quantum Speedup

Visualizes tropical geometry, compactification to the sphere,
and the quantum speedup for tropical optimization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from mpl_toolkits.mplot3d import Axes3D

# ============================================================
# Part 1: Tropical Geometry
# ============================================================

def tropical_add(a, b):
    """Tropical addition: max(a, b)"""
    return np.maximum(a, b)

def tropical_mul(a, b):
    """Tropical multiplication: a + b"""
    return a + b

def tropical_polynomial(x, coeffs):
    """
    Tropical polynomial: max_i(a_i * x + b_i)
    coeffs = [(a_i, b_i), ...]
    """
    result = np.full_like(x, -np.inf)
    for a, b in coeffs:
        result = tropical_add(result, tropical_mul(a * np.ones_like(x), x) + b)
    return result

# ============================================================
# Part 2: Inverse Stereographic Projection (2D -> S^2)
# ============================================================

def inv_stereo_3d(u, v):
    """Inverse stereographic projection R^2 -> S^2"""
    denom = u**2 + v**2 + 1
    x = 2 * u / denom
    y = 2 * v / denom
    z = (u**2 + v**2 - 1) / denom
    return x, y, z

# ============================================================
# Part 3: Grover Speedup Simulation
# ============================================================

def classical_search(f_values, threshold):
    """Classical search: linear scan. Returns (index, n_evals)."""
    for i, v in enumerate(f_values):
        if v <= threshold:
            return i, i + 1
    return -1, len(f_values)

def grover_search_simulation(N, n_marked):
    """Simulated Grover search: ~sqrt(N/n_marked) iterations."""
    if n_marked == 0:
        return N
    return int(np.ceil(np.pi / 4 * np.sqrt(N / n_marked)))

# ============================================================
# Part 4: Create Visualizations
# ============================================================

fig = plt.figure(figsize=(18, 16))
fig.suptitle('Tropical Geometry, Compactification & Quantum Speedup',
             fontsize=18, fontweight='bold', y=0.98)
gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)

# --- Panel 1: 2D Tropical Curve ---
ax1 = fig.add_subplot(gs[0, 0])

x = np.linspace(-4, 4, 1000)
y = np.linspace(-4, 4, 1000)
X, Y = np.meshgrid(x, y)

# Tropical curve: max(x, y, 0) has corners
Z = np.maximum(np.maximum(X, Y), 0)
ax1.contour(X, Y, Z, levels=30, cmap='viridis', alpha=0.5)

# The tropical curve is where two of the three terms tie
# x=y (for x,y>0), x=0 (for y<0), y=0 (for x<0)
ax1.plot([0, 4], [0, 4], 'r-', linewidth=3, label='x = y')
ax1.plot([0, -4], [0, 0], 'b-', linewidth=3, label='y = 0 (x < 0)')
ax1.plot([0, 0], [0, -4], 'g-', linewidth=3, label='x = 0 (y < 0)')
ax1.scatter(0, 0, color='red', s=100, zorder=10, label='Tropical vertex')

ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_title('Tropical Curve: max(x, y, 0)')
ax1.legend(fontsize=7, loc='upper left')
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Tropical vs Classical Polynomial ---
ax2 = fig.add_subplot(gs[0, 1])

x = np.linspace(-3, 3, 1000)

# Classical: x^2 - 2x + 1 = (x-1)^2
classical = x**2 - 2*x + 1

# Tropical: max(2x, x+(-2), 1) ≈ max(2x, x-2, 0)
trop = tropical_polynomial(x, [(2, 0), (1, -2), (0, 0)])

ax2.plot(x, classical, 'b-', linewidth=2, label='Classical: x² - 2x + 1')
ax2.plot(x, trop, 'r-', linewidth=2, label='Tropical: max(2x, x-2, 0)')
ax2.axvline(x=1, color='blue', linestyle=':', alpha=0.5)
ax2.axvline(x=2, color='red', linestyle=':', alpha=0.5)

ax2.set_xlabel('x')
ax2.set_ylabel('f(x)')
ax2.set_title('Classical vs Tropical Polynomial')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# --- Panel 3: ReLU = Tropical Addition ---
ax3 = fig.add_subplot(gs[0, 2])

x = np.linspace(-3, 3, 1000)
relu = np.maximum(x, 0)

ax3.fill_between(x, relu, alpha=0.3, color='orange')
ax3.plot(x, relu, 'r-', linewidth=3, label='ReLU(x) = max(x, 0) = x ⊕ 0')
ax3.plot(x, x, 'b--', alpha=0.4, linewidth=1, label='y = x')
ax3.axhline(y=0, color='green', linestyle='--', alpha=0.4, label='y = 0')

ax3.scatter(0, 0, color='black', s=100, zorder=5, label='Tropical vertex')
ax3.set_xlabel('x')
ax3.set_ylabel('ReLU(x)')
ax3.set_title('ReLU = Tropical Addition with Zero')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Compactification R^2 -> S^2 ---
ax4 = fig.add_subplot(gs[1, 0], projection='3d')

# Draw unit sphere
u_sphere = np.linspace(0, 2 * np.pi, 50)
v_sphere = np.linspace(0, np.pi, 50)
xs = np.outer(np.cos(u_sphere), np.sin(v_sphere))
ys = np.outer(np.sin(u_sphere), np.sin(v_sphere))
zs = np.outer(np.ones(50), np.cos(v_sphere))
ax4.plot_surface(xs, ys, zs, alpha=0.1, color='lightblue')

# Map grid from R^2 to S^2
grid = np.linspace(-5, 5, 20)
for g in grid:
    t = np.linspace(-5, 5, 100)
    # Horizontal lines
    sx, sy, sz = inv_stereo_3d(t, g * np.ones_like(t))
    ax4.plot(sx, sy, sz, 'b-', alpha=0.2, linewidth=0.5)
    # Vertical lines
    sx, sy, sz = inv_stereo_3d(g * np.ones_like(t), t)
    ax4.plot(sx, sy, sz, 'r-', alpha=0.2, linewidth=0.5)

# North pole = Omega Point
ax4.scatter([0], [0], [1], color='red', s=200, marker='*', zorder=10)
ax4.text(0, 0, 1.15, 'Ω', fontsize=14, ha='center', color='red', fontweight='bold')

ax4.set_title('ℝ² → S² Compactification')
ax4.set_xlabel('x')
ax4.set_ylabel('y')
ax4.set_zlabel('z')

# --- Panel 5: Tropical Optimization on Sphere ---
ax5 = fig.add_subplot(gs[1, 1], projection='3d')

# Draw sphere
ax5.plot_surface(xs, ys, zs, alpha=0.1, color='lightyellow')

# Create a tropical optimization problem and map to sphere
np.random.seed(123)
n_points = 200
u_pts = np.random.randn(n_points) * 2
v_pts = np.random.randn(n_points) * 2

# Tropical objective: max of 3 affine functions
obj = np.maximum(np.maximum(u_pts + v_pts - 1, -u_pts + 2*v_pts),
                 2*u_pts - v_pts + 0.5)

# Map to sphere
sx, sy, sz = inv_stereo_3d(u_pts, v_pts)

# Color by objective value
scatter = ax5.scatter(sx, sy, sz, c=obj, cmap='RdYlGn_r', s=20, alpha=0.8)

# Find minimum
min_idx = np.argmin(obj)
ax5.scatter([sx[min_idx]], [sy[min_idx]], [sz[min_idx]],
           color='blue', s=200, marker='*', zorder=10, edgecolors='black')

ax5.set_title('Tropical Optimization on S²')
fig.colorbar(scatter, ax=ax5, shrink=0.5, label='Objective')

# --- Panel 6: Grover Speedup ---
ax6 = fig.add_subplot(gs[1, 2])

N_values = np.logspace(1, 6, 50).astype(int)
classical_evals = N_values / 2  # Expected: N/2
quantum_evals = np.pi / 4 * np.sqrt(N_values)

ax6.loglog(N_values, classical_evals, 'r-', linewidth=2, label='Classical: O(N)')
ax6.loglog(N_values, quantum_evals, 'b-', linewidth=2, label='Quantum: O(√N)')
ax6.fill_between(N_values, quantum_evals, classical_evals, alpha=0.15, color='green')

ax6.annotate('Quantum\nAdvantage', xy=(1e4, 1e2), fontsize=12, ha='center',
            color='green', fontweight='bold')

ax6.set_xlabel('Problem Size N')
ax6.set_ylabel('Evaluations Required')
ax6.set_title('Grover Speedup for Tropical Search')
ax6.legend(fontsize=10)
ax6.grid(True, alpha=0.3, which='both')

# --- Panel 7: Tropical Rank and Approximation Quality ---
ax7 = fig.add_subplot(gs[2, 0])

ranks = np.arange(2, 20)
epsilons = [0.01, 0.05, 0.1, 0.2]
colors_eps = ['#2c3e50', '#e74c3c', '#f39c12', '#2ecc71']

for eps, color in zip(epsilons, colors_eps):
    # Time complexity: O(n * (r/eps)^2)
    n = 10  # ambient dimension
    complexity = n * (ranks / eps) ** 2
    ax7.semilogy(ranks, complexity, 'o-', color=color, linewidth=1.5,
                markersize=4, label=f'ε = {eps}')

ax7.set_xlabel('Tropical Rank r')
ax7.set_ylabel('Time Complexity')
ax7.set_title('Spherical Shortcut: Complexity vs Rank')
ax7.legend(fontsize=8)
ax7.grid(True, alpha=0.3, which='both')

# --- Panel 8: Tropical Neural Network Layer ---
ax8 = fig.add_subplot(gs[2, 1])

x = np.linspace(-3, 3, 500)

# A 2-layer tropical neural network
# Layer 1: max(w1*x + b1, w2*x + b2) for each neuron
w = np.array([[1, -1, 0.5, -0.5],
              [-0.5, 0.5, -1, 1]])
b = np.array([[0, 1, -0.5, 0.5],
              [0.5, -0.5, 1, -1]])

# Layer 1 outputs (4 neurons)
l1 = np.array([np.maximum(w[0, j]*x + b[0, j], w[1, j]*x + b[1, j]) for j in range(4)])

# Layer 2: final output = max of layer 1 outputs
output = np.max(l1, axis=0)

for j in range(4):
    ax8.plot(x, l1[j], '--', alpha=0.4, linewidth=1, label=f'Neuron {j+1}')
ax8.plot(x, output, 'k-', linewidth=3, label='Network output')

ax8.set_xlabel('Input x')
ax8.set_ylabel('Output')
ax8.set_title('Tropical Neural Network (2 layers)')
ax8.legend(fontsize=7, loc='upper left')
ax8.grid(True, alpha=0.3)

# --- Panel 9: Convergence Landscape on S^1 ---
ax9 = fig.add_subplot(gs[2, 2])

theta = np.linspace(0, 2*np.pi, 300)

# Draw circle
ax9.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Show iterative convergence on the circle
# Map: theta -> alpha * theta + (1-alpha) * theta_target
alpha = 0.8
theta_target = np.pi / 4  # Fixed point
theta_start = 3 * np.pi / 2

trajectory_theta = [theta_start]
t = theta_start
for _ in range(30):
    t = alpha * t + (1 - alpha) * theta_target
    trajectory_theta.append(t)

traj_x = np.cos(trajectory_theta)
traj_y = np.sin(trajectory_theta)

ax9.plot(traj_x, traj_y, 'b-', alpha=0.5, linewidth=1)
ax9.scatter(traj_x, traj_y, c=np.arange(len(traj_x)), cmap='plasma',
           s=30, zorder=5, edgecolors='black', linewidths=0.5)

ax9.scatter(np.cos(theta_target), np.sin(theta_target),
           color='gold', s=200, marker='*', zorder=10, edgecolors='black',
           label='Fixed point')
ax9.scatter(traj_x[0], traj_y[0], color='red', s=100, zorder=10, label='Start')

ax9.set_xlim(-1.4, 1.4)
ax9.set_ylim(-1.4, 1.4)
ax9.set_aspect('equal')
ax9.set_title('Convergence on Compactified S¹')
ax9.legend(fontsize=8)
ax9.grid(True, alpha=0.3)

plt.savefig('/workspace/request-project/demos/demo2_tropical_quantum_optimization.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 2 saved: demos/demo2_tropical_quantum_optimization.png")
