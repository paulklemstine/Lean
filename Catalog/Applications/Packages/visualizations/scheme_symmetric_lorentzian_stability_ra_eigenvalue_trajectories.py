#!/usr/bin/env python3
"""
Visualization: Eigenvalue Trajectories and Stability Radius

Visualizes how the eigenvalues of the leaf Hessian evolve under perturbation,
and how the stability radius corresponds to the first zero-crossing of a
nontrivial eigenvalue. Shows the J(n,2) and J(n,3) cases side by side.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb


def eberlein(j, i, n, k):
    val = 0.0
    for s in range(min(i, j) + 1):
        if k - i >= j - s >= 0 and n - k - i >= j - s:
            val += ((-1)**s) * comb(i, s) * comb(k-i, j-s) * comb(n-k-i, j-s)
    return val


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: J(8,2) eigenvalue trajectories ---
ax = axes[0]
n, k = 8, 2
d = k
t = np.linspace(0, 2, 200)

# Eigenvalues: theta_0 = n-1 (stays), theta_1 = -1 + t
theta0 = np.full_like(t, n - 1.0)
theta1 = -1.0 + t

ax.plot(t, theta0, 'b-', linewidth=2, label=r'$\theta_0 = n-1$ (trivial)')
ax.plot(t, theta1, 'r-', linewidth=2, label=r'$\theta_1 = -1 + t$ (standard)')
ax.axhline(y=0, color='k', linewidth=0.5, linestyle='-')
ax.axvline(x=1.0, color='green', linewidth=2, linestyle='--', alpha=0.7, label=r'$\rho = 1$')
ax.fill_between(t, -3, 0, where=(t <= 1.0), alpha=0.1, color='blue')
ax.set_xlabel('Perturbation parameter t', fontsize=11)
ax.set_ylabel('Eigenvalue', fontsize=11)
ax.set_title(f'J({n},{k}): Stability Radius = 1', fontsize=12, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.set_ylim(-3, n)
ax.set_xlim(0, 2)

# --- Panel 2: J(10,3) eigenvalue trajectories ---
ax = axes[1]
n, k = 10, 3
d = k
P = np.array([[eberlein(j, i, n, k) for i in range(d+1)] for j in range(d+1)])
base_eigs = P[:, 0]
rates = np.abs(P[:, 1])
rates[0] = 0

t = np.linspace(0, 3, 200)
colors = ['blue', 'red', 'orange', 'purple']
labels = [r'$\theta_0$ (trivial)', r'$\theta_1$', r'$\theta_2$', r'$\theta_3$']

min_ratio = float('inf')
for j in range(1, d+1):
    if rates[j] > 0:
        ratio = abs(base_eigs[j]) / rates[j]
        if ratio < min_ratio:
            min_ratio = ratio

for j in range(d + 1):
    trajectory = base_eigs[j] + t * rates[j]
    ax.plot(t, trajectory, color=colors[j], linewidth=2, label=labels[j])

ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=min_ratio, color='green', linewidth=2, linestyle='--', alpha=0.7,
           label=f'$\\rho = {min_ratio:.3f}$')
ax.set_xlabel('Perturbation parameter t', fontsize=11)
ax.set_ylabel('Eigenvalue', fontsize=11)
ax.set_title(f'J({n},{k}): Stability Radius = {min_ratio:.3f}', fontsize=12, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.set_xlim(0, 3)

# --- Panel 3: Stability radius vs n for J(n,2) and J(n,3) ---
ax = axes[2]

ns_2 = list(range(4, 20))
radii_2 = [1.0] * len(ns_2)  # J(n,2) always gives 1

ns_3 = list(range(6, 20))
radii_3 = []
for nn in ns_3:
    kk = 3
    dd = kk
    PP = np.array([[eberlein(j, i, nn, kk) for i in range(dd+1)] for j in range(dd+1)])
    be = PP[:, 0]
    rt = np.abs(PP[:, 1])
    rt[0] = 0
    mr = float('inf')
    for j in range(1, dd+1):
        if rt[j] > 0:
            mr = min(mr, abs(be[j]) / rt[j])
    radii_3.append(mr)

ax.plot(ns_2, radii_2, 'bo-', linewidth=2, markersize=6, label='J(n,2)')
ax.plot(ns_3, radii_3, 'rs-', linewidth=2, markersize=6, label='J(n,3)')
ax.set_xlabel('n', fontsize=11)
ax.set_ylabel('Stability Radius ρ', fontsize=11)
ax.set_title('Stability Radius vs n', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/viz_eigenvalue_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_trajectories.png")
