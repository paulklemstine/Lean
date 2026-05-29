#!/usr/bin/env python3
"""
Visualization 2: Geodesics in Split Geometry

Shows how geodesics curve differently in the elliptic (K > 0) and hyperbolic (K < 0)
regions of split geometry. Geodesics converge in the elliptic region and diverge
in the hyperbolic region, demonstrating the simultaneous convergence/divergence
that characterizes split geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def sech(x):
    return 1.0 / np.cosh(x)

def christoffel_symbols(x, y):
    Gamma = np.zeros((2, 2, 2))
    Gamma[0, 0, 1] = -np.tanh(y)
    Gamma[0, 1, 0] = -np.tanh(y)
    Gamma[0, 1, 1] = -np.sinh(x) * np.cosh(x) * np.cosh(y)**2
    Gamma[1, 0, 0] = sech(y)**2 * np.tanh(y) / np.cosh(x)**2
    Gamma[1, 0, 1] = np.tanh(x)
    Gamma[1, 1, 0] = np.tanh(x)
    return Gamma

def integrate_geodesic(x0, y0, vx0, vy0, t_max=5.0, dt=0.001):
    n_steps = int(t_max / dt)
    traj = np.zeros((n_steps + 1, 4))
    state = np.array([x0, y0, vx0, vy0])
    traj[0] = state
    
    for i in range(n_steps):
        x, y, vx, vy = state
        Gamma = christoffel_symbols(x, y)
        vel = np.array([vx, vy])
        acc = np.zeros(2)
        for k in range(2):
            for ii in range(2):
                for jj in range(2):
                    acc[k] -= Gamma[k, ii, jj] * vel[ii] * vel[jj]
        
        deriv = np.array([vx, vy, acc[0], acc[1]])
        
        # RK4
        def f(s):
            xx, yy, vxx, vyy = s
            G = christoffel_symbols(xx, yy)
            v = np.array([vxx, vyy])
            a = np.zeros(2)
            for k in range(2):
                for ii in range(2):
                    for jj in range(2):
                        a[k] -= G[k, ii, jj] * v[ii] * v[jj]
            return np.array([vxx, vyy, a[0], a[1]])
        
        k1 = f(state)
        k2 = f(state + 0.5*dt*k1)
        k3 = f(state + 0.5*dt*k2)
        k4 = f(state + dt*k3)
        state = state + (dt/6)*(k1 + 2*k2 + 2*k3 + k4)
        traj[i+1] = state
        
        if abs(state[0]) > 6 or abs(state[1]) > 6:
            return traj[:i+2]
    
    return traj

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Background: curvature field
x = np.linspace(-5, 5, 300)
y = np.linspace(-5, 5, 300)
X, Y = np.meshgrid(x, y)
K = sech(X)**2 - sech(Y)**2
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
ax.pcolormesh(X, Y, K, cmap='RdBu_r', norm=norm, shading='auto', alpha=0.3)
ax.contour(X, Y, K, levels=[0], colors='black', linewidths=1.5, linestyles='--')

# Phase boundary labels
ax.plot([-5, 5], [-5, 5], 'k--', linewidth=0.5, alpha=0.5)
ax.plot([-5, 5], [5, -5], 'k--', linewidth=0.5, alpha=0.5)

# Geodesics from origin in different directions
colors = plt.cm.viridis(np.linspace(0, 0.9, 12))
angles = np.linspace(0, 2*np.pi, 12, endpoint=False)

for i, angle in enumerate(angles):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(0, 0, vx, vy, t_max=4.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors[i], linewidth=1.8,
                alpha=0.8)
    except:
        pass

# Geodesic fan from a point in the elliptic region
colors2 = plt.cm.autumn(np.linspace(0, 0.9, 8))
for i, angle in enumerate(np.linspace(-np.pi/4, np.pi/4, 8)):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(0, 2, vx, vy, t_max=3.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors2[i], linewidth=1.5,
                alpha=0.7, linestyle='-')
    except:
        pass

# Geodesic fan from a point in the hyperbolic region
colors3 = plt.cm.winter(np.linspace(0, 0.9, 8))
for i, angle in enumerate(np.linspace(np.pi/4, 3*np.pi/4, 8)):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(2, 0, vx, vy, t_max=3.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors3[i], linewidth=1.5,
                alpha=0.7, linestyle='-')
    except:
        pass

# Mark special points
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.plot(0, 2, 's', color='blue', markersize=8, zorder=5)
ax.plot(2, 0, 's', color='red', markersize=8, zorder=5)

ax.text(0, 3.5, 'Elliptic Region\n(converging)', ha='center', fontsize=12,
        color='darkblue', fontweight='bold')
ax.text(3.5, 0, 'Hyperbolic\nRegion\n(diverging)', ha='center', fontsize=12,
        color='darkred', fontweight='bold')

ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Geodesics in Split Geometry', fontsize=16)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('geodesics.png', dpi=150, bbox_inches='tight')
print("Saved geodesics.png")
