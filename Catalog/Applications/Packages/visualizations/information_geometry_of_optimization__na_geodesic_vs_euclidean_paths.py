#!/usr/bin/env python3
"""
Visualization: Geodesic vs Euclidean Paths on a Statistical Manifold

Shows how the natural gradient (geodesic) path differs from the standard
gradient (Euclidean) path on a 2D parameter space with an anisotropic
Fisher information metric.

The geodesic path is shorter in the Riemannian metric, even though it may
look longer in Euclidean coordinates. This is WHY natural gradient is faster.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse
from matplotlib.colors import LinearSegmentedColormap

# Create a 2D optimization landscape with anisotropic metric
# f(x, y) = 0.5 * (a*x^2 + b*y^2) with a << b (ill-conditioned)
a, b_param = 1.0, 20.0
kappa = b_param / a

# Optimal point
x_opt, y_opt = 0.0, 0.0

# Starting point
x0, y0 = 3.0, 2.0

# Standard gradient descent path
def gd_path(x0, y0, a, b, eta, n_steps):
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(n_steps):
        gx, gy = a * x, b * y
        x -= eta * gx
        y -= eta * gy
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)

# Natural gradient descent path (G^{-1} * grad)
def ng_path(x0, y0, a, b, eta, n_steps):
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(n_steps):
        # Gradient: (ax, by)
        # Fisher (Hessian for quadratic): diag(a, b)
        # Natural gradient = G^{-1} * grad = (x, y)
        x -= eta * x
        y -= eta * y
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Paths in parameter space
ax = axes[0]

# Contour plot of loss function
xx = np.linspace(-4, 4, 200)
yy = np.linspace(-3, 3, 200)
XX, YY = np.meshgrid(xx, yy)
ZZ = 0.5 * (a * XX**2 + b_param * YY**2)

levels = np.logspace(-1, 2, 20)
ax.contour(XX, YY, ZZ, levels=levels, colors='lightgray', linewidths=0.5, alpha=0.7)
ax.contourf(XX, YY, ZZ, levels=levels, cmap='YlOrRd', alpha=0.3)

# GD path
n_steps = 50
xs_gd, ys_gd = gd_path(x0, y0, a, b_param, 1.0/b_param, n_steps)
ax.plot(xs_gd, ys_gd, 'r-o', markersize=3, linewidth=1.5, label='Standard GD', alpha=0.8)

# NG path
xs_ng, ys_ng = ng_path(x0, y0, a, b_param, 0.3, n_steps)
ax.plot(xs_ng, ys_ng, 'g-s', markersize=3, linewidth=2, label='Natural GD (geodesic)', alpha=0.9)

# Mark start and optimum
ax.plot(x0, y0, 'k*', markersize=15, label='Start', zorder=5)
ax.plot(0, 0, 'b*', markersize=15, label='Optimum', zorder=5)

# Draw Fisher metric ellipses
for cx, cy in [(1.5, 1), (-1, -0.5), (2, -1)]:
    ellipse = Ellipse((cx, cy), width=2/np.sqrt(a), height=2/np.sqrt(b_param),
                      fill=False, edgecolor='blue', alpha=0.3, linestyle='--')
    ax.add_patch(ellipse)

ax.set_xlabel('θ₁', fontsize=13)
ax.set_ylabel('θ₂', fontsize=13)
ax.set_title(f'Optimization Paths (κ = {kappa:.0f})', fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-1, 4)
ax.set_ylim(-1.5, 3)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

# Panel 2: Loss vs iteration
ax = axes[1]

losses_gd = 0.5 * (a * xs_gd**2 + b_param * ys_gd**2)
losses_ng = 0.5 * (a * xs_ng**2 + b_param * ys_ng**2)

T = np.arange(len(losses_gd))
ax.semilogy(T, losses_gd, 'r-', linewidth=2, label='Standard GD')
ax.semilogy(T[:len(losses_ng)], losses_ng, 'g-', linewidth=2.5, label='Natural GD')

# Theoretical bounds
delta0 = 0.5 * (a * x0**2 + b_param * y0**2)
T_theory = np.arange(1, n_steps + 1).astype(float)
bound_gd = delta0 * (1 - 1/kappa)**T_theory
bound_ng = delta0 * np.exp(-T_theory / 2)  # d=2

ax.semilogy(T_theory, bound_gd, 'r--', alpha=0.5, label='GD theory')
ax.semilogy(T_theory, bound_ng, 'g--', alpha=0.5, label='NG theory')

ax.set_xlabel('Iteration', fontsize=13)
ax.set_ylabel('Loss L(θ_t)', fontsize=13)
ax.set_title('Convergence to Optimum', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-15, 1e2)

# Add annotation
ax.annotate(f'κ = {kappa:.0f}\nNG: exp(-T/d)\nGD: (1-1/κ)ᵀ',
           xy=(30, 1e-6), fontsize=11, 
           bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('geodesic_vs_euclidean.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved geodesic_vs_euclidean.png")
