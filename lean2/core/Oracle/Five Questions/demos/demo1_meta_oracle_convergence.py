#!/usr/bin/env python3
"""
Demo 1: Meta-Oracle Convergence Dynamics

Visualizes how contractive meta-oracles converge to fixed points,
demonstrating exponential convergence and the approach to the Omega Point.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec

# ============================================================
# Part 1: 1D Contraction Meta-Oracle
# ============================================================

def meta_oracle_1d(x, k=0.7, target=3.14159):
    """A simple contraction meta-oracle: M(x) = target + k*(x - target)"""
    return target + k * (x - target)

def run_meta_oracle(x0, k, target, n_iters=50):
    """Run meta-oracle iterations and return trajectory."""
    trajectory = [x0]
    x = x0
    for _ in range(n_iters):
        x = meta_oracle_1d(x, k, target)
        trajectory.append(x)
    return np.array(trajectory)

# ============================================================
# Part 2: Stereographic Projection to Sphere
# ============================================================

def inv_stereo_x(t):
    """x-coordinate of inverse stereographic projection R -> S^1"""
    return 2 * t / (t**2 + 1)

def inv_stereo_y(t):
    """y-coordinate of inverse stereographic projection R -> S^1"""
    return (t**2 - 1) / (t**2 + 1)

# ============================================================
# Part 3: Create Visualizations
# ============================================================

fig = plt.figure(figsize=(18, 14))
fig.suptitle('Meta-Oracle Convergence Dynamics', fontsize=18, fontweight='bold', y=0.98)
gs = GridSpec(3, 3, figure=fig, hspace=0.35, wspace=0.3)

# --- Panel 1: Convergence for different contraction factors ---
ax1 = fig.add_subplot(gs[0, 0])
target = np.pi
x0 = 10.0
colors_k = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db', '#9b59b6']
k_values = [0.3, 0.5, 0.7, 0.9, 0.95]

for k, color in zip(k_values, colors_k):
    traj = run_meta_oracle(x0, k, target, 50)
    ax1.plot(traj, color=color, linewidth=1.5, label=f'k={k}')

ax1.axhline(y=target, color='black', linestyle='--', alpha=0.5, label=f'Fixed point = π')
ax1.set_xlabel('Iteration n')
ax1.set_ylabel('Oracle value Mⁿ(f₀)')
ax1.set_title('Convergence vs Contraction Factor k')
ax1.legend(fontsize=7, loc='upper right')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Log-distance to fixed point (exponential convergence) ---
ax2 = fig.add_subplot(gs[0, 1])

for k, color in zip(k_values, colors_k):
    traj = run_meta_oracle(x0, k, target, 50)
    distances = np.abs(traj - target)
    distances = np.maximum(distances, 1e-16)  # avoid log(0)
    ax2.plot(np.log10(distances), color=color, linewidth=1.5, label=f'k={k}')

ax2.set_xlabel('Iteration n')
ax2.set_ylabel('log₁₀ |Mⁿ(f₀) - f*|')
ax2.set_title('Exponential Convergence (Log Scale)')
ax2.legend(fontsize=7)
ax2.grid(True, alpha=0.3)

# --- Panel 3: ε-Omega Point (iterations needed vs precision) ---
ax3 = fig.add_subplot(gs[0, 2])

epsilons = np.logspace(-1, -12, 100)
d0 = abs(x0 - target)

for k, color in zip([0.3, 0.5, 0.7, 0.9], colors_k[:4]):
    n_needed = np.log(epsilons / d0) / np.log(k)
    n_needed = np.maximum(n_needed, 0)
    ax3.plot(np.log10(epsilons), n_needed, color=color, linewidth=1.5, label=f'k={k}')

ax3.set_xlabel('log₁₀(ε)')
ax3.set_ylabel('Iterations to ε-Omega Point')
ax3.set_title('Finite Omega Approximation')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# --- Panel 4: 2D Meta-Oracle Convergence (spiral) ---
ax4 = fig.add_subplot(gs[1, 0])

def meta_oracle_2d(xy, k=0.85, target=np.array([0, 0]), rotation=0.3):
    """2D contraction with rotation — creates spiral convergence."""
    R = np.array([[np.cos(rotation), -np.sin(rotation)],
                  [np.sin(rotation), np.cos(rotation)]])
    return target + k * R @ (xy - target)

# Run 2D oracle
xy = np.array([5.0, 3.0])
traj_2d = [xy.copy()]
for _ in range(200):
    xy = meta_oracle_2d(xy)
    traj_2d.append(xy.copy())
traj_2d = np.array(traj_2d)

ax4.plot(traj_2d[:, 0], traj_2d[:, 1], 'b-', alpha=0.5, linewidth=0.5)
ax4.scatter(traj_2d[0, 0], traj_2d[0, 1], color='red', s=100, zorder=5, label='Start f₀')
ax4.scatter(0, 0, color='gold', s=150, zorder=5, marker='*', label='Fixed point f*')
scatter = ax4.scatter(traj_2d[::5, 0], traj_2d[::5, 1],
                      c=np.arange(0, len(traj_2d), 5), cmap='viridis',
                      s=15, zorder=4, alpha=0.8)
ax4.set_xlabel('Dimension 1')
ax4.set_ylabel('Dimension 2')
ax4.set_title('2D Spiral Convergence')
ax4.legend(fontsize=8)
ax4.set_aspect('equal')
ax4.grid(True, alpha=0.3)

# --- Panel 5: Stereographic Projection — Omega Point ---
ax5 = fig.add_subplot(gs[1, 1])

theta = np.linspace(0, 2 * np.pi, 200)
ax5.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Map oracle trajectory to sphere
t_values = np.linspace(-10, 10, 500)
sx = inv_stereo_x(t_values)
sy = inv_stereo_y(t_values)
ax5.plot(sx, sy, 'b-', alpha=0.3, linewidth=3, label='Image of ℝ')

# Show convergence to north pole
t_conv = np.array([0.5, 1, 2, 4, 8, 16, 32, 64])
sx_conv = inv_stereo_x(t_conv)
sy_conv = inv_stereo_y(t_conv)
ax5.scatter(sx_conv, sy_conv, c=np.arange(len(t_conv)), cmap='plasma',
           s=50, zorder=5, edgecolors='black', linewidths=0.5)

# North pole = Omega Point
ax5.scatter(0, 1, color='red', s=200, marker='*', zorder=10, label='Ω (North Pole)')
ax5.annotate('Omega Point\n∞ → (0,1)', xy=(0, 1), xytext=(0.4, 0.7),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='red'))

ax5.set_xlim(-1.3, 1.3)
ax5.set_ylim(-1.3, 1.3)
ax5.set_aspect('equal')
ax5.set_title('One-Point Compactification: ℝ → S¹')
ax5.legend(fontsize=8, loc='lower left')
ax5.grid(True, alpha=0.3)

# --- Panel 6: Quality improvement over iterations ---
ax6 = fig.add_subplot(gs[1, 2])

n_iters = 100
quality_trajectories = {}
for k in [0.5, 0.7, 0.9]:
    traj = run_meta_oracle(0.1, k, target=10.0, n_iters=n_iters)
    # Quality = -distance to target
    quality = -np.abs(traj - 10.0)
    quality_trajectories[k] = quality

for k, color in zip([0.5, 0.7, 0.9], ['#e74c3c', '#2ecc71', '#3498db']):
    ax6.plot(quality_trajectories[k], color=color, linewidth=1.5, label=f'k={k}')

ax6.set_xlabel('Iteration n')
ax6.set_ylabel('Quality q(Mⁿ(f₀))')
ax6.set_title('Quality Monotonically Increases')
ax6.legend(fontsize=8)
ax6.grid(True, alpha=0.3)

# --- Panel 7: Phase portrait of improvement dynamics ---
ax7 = fig.add_subplot(gs[2, 0])

x_range = np.linspace(-2, 8, 30)
y_range = np.linspace(-2, 8, 30)
X, Y = np.meshgrid(x_range, y_range)

# Vector field for 2D meta-oracle
target_2d = np.array([3.0, 3.0])
k_phase = 0.7
rotation = 0.4
R = np.array([[np.cos(rotation), -np.sin(rotation)],
              [np.sin(rotation), np.cos(rotation)]])

U = np.zeros_like(X)
V = np.zeros_like(Y)
for i in range(len(x_range)):
    for j in range(len(y_range)):
        xy = np.array([X[j, i], Y[j, i]])
        mxy = target_2d + k_phase * R @ (xy - target_2d)
        U[j, i] = mxy[0] - xy[0]
        V[j, i] = mxy[1] - xy[1]

speed = np.sqrt(U**2 + V**2)
ax7.streamplot(X, Y, U, V, color=speed, cmap='coolwarm', density=1.5, linewidth=1)
ax7.scatter(3, 3, color='gold', s=200, marker='*', zorder=10, edgecolors='black')
ax7.set_xlabel('Dimension 1')
ax7.set_ylabel('Dimension 2')
ax7.set_title('Phase Portrait: Improvement Flow')
ax7.set_aspect('equal')
ax7.grid(True, alpha=0.3)

# --- Panel 8: Tropical function visualization ---
ax8 = fig.add_subplot(gs[2, 1])

x = np.linspace(-3, 5, 1000)
# Tropical polynomial: max(2x+1, -x+3, x-1, 0.5x+0.5)
f1 = 2*x + 1
f2 = -x + 3
f3 = x - 1
f4 = 0.5*x + 0.5
tropical_poly = np.maximum(np.maximum(f1, f2), np.maximum(f3, f4))

ax8.plot(x, f1, '--', alpha=0.3, color='gray', linewidth=0.8)
ax8.plot(x, f2, '--', alpha=0.3, color='gray', linewidth=0.8)
ax8.plot(x, f3, '--', alpha=0.3, color='gray', linewidth=0.8)
ax8.plot(x, f4, '--', alpha=0.3, color='gray', linewidth=0.8)
ax8.plot(x, tropical_poly, 'r-', linewidth=2.5, label='Tropical polynomial\nmax(2x+1, -x+3, x-1, ½x+½)')

# Find and mark corners (tropical roots)
min_idx = np.argmin(tropical_poly)
ax8.scatter(x[min_idx], tropical_poly[min_idx], color='blue', s=100, zorder=5,
           label=f'Tropical minimum at x≈{x[min_idx]:.2f}')

ax8.set_xlabel('x')
ax8.set_ylabel('f⊕(x) = max_i(aᵢx + bᵢ)')
ax8.set_title('Tropical Polynomial (Rank 4)')
ax8.legend(fontsize=7, loc='upper left')
ax8.grid(True, alpha=0.3)

# --- Panel 9: Channel capacity vs improvement rate ---
ax9 = fig.add_subplot(gs[2, 2])

# Simulate entropy bound: improvement rate ≤ channel capacity
noise_levels = np.linspace(0.01, 2.0, 100)
channel_capacity = 0.5 * np.log2(1 + 1.0 / noise_levels**2)  # AWGN capacity

# Simulated improvement rates (always below capacity)
np.random.seed(42)
improvement_rates = channel_capacity * (0.3 + 0.5 * np.random.rand(100))

ax9.fill_between(noise_levels, channel_capacity, alpha=0.2, color='red',
                label='Forbidden region')
ax9.plot(noise_levels, channel_capacity, 'r-', linewidth=2,
        label='Channel capacity C(C_M)')
ax9.scatter(noise_levels[::3], improvement_rates[::3], color='blue', s=20, alpha=0.7,
           label='Measured improvement rate H_M')

ax9.set_xlabel('Self-evaluation noise σ')
ax9.set_ylabel('Rate (bits/iteration)')
ax9.set_title('Oracle Entropy ≤ Channel Capacity')
ax9.legend(fontsize=8)
ax9.grid(True, alpha=0.3)

plt.savefig('/workspace/request-project/demos/demo1_meta_oracle_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 1 saved: demos/demo1_meta_oracle_convergence.png")
