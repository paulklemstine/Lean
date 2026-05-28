#!/usr/bin/env python3
"""
Visualization: Stability Landscape and Phase Transition

Visualizes the stability landscape as a 2D surface where the height
represents the maximum eigenvalue across all branches. The zero-level
set is the stability boundary, and the stability radius is the distance
from the origin to this boundary along the parameter axis.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

np.random.seed(42)

fig = plt.figure(figsize=(16, 10))

# ── Panel 1: Stability landscape (top-left) ──
ax1 = fig.add_subplot(2, 2, 1)

# Parameter grid
t1 = np.linspace(0, 5, 300)
t2 = np.linspace(-3, 3, 300)
T1, T2 = np.meshgrid(t1, t2)

# Define eigenvalue branches as functions of (t1, t2)
# θ₁(t) = -2 + t₁ + 0.3t₂² (depends on both parameters)
# θ₂(t) = -3 + 0.5t₁ + t₂

theta1 = -2 + T1 + 0.3*T2**2
theta2 = -3 + 0.5*T1 + T2

# Maximum eigenvalue (stability = where max < 0)
max_theta = np.maximum(theta1, theta2)

# Plot stability region
stable = max_theta < 0
ax1.contourf(t1, t2, stable.astype(float), levels=[0.5, 1.5],
             colors=['#90EE90'], alpha=0.3)
ax1.contour(t1, t2, max_theta, levels=[0], colors=['red'], linewidths=2)
ax1.contour(t1, t2, theta1, levels=[0], colors=['blue'], linewidths=1, linestyles='--')
ax1.contour(t1, t2, theta2, levels=[0], colors=['orange'], linewidths=1, linestyles='--')

ax1.plot(0, 0, 'ko', markersize=8, label='Origin (stable)')
ax1.set_xlabel('Parameter t₁', fontsize=11)
ax1.set_ylabel('Parameter t₂', fontsize=11)
ax1.set_title('2D Stability Region\n(Green = Stable)', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.2)

# ── Panel 2: 1D slice showing branches (top-right) ──
ax2 = fig.add_subplot(2, 2, 2)

t = np.linspace(0, 6, 500)

# Family of 6 branches
branches = [
    (-2.0, 0.8, 0.1),
    (-1.5, 0.3, 0.4),
    (-4.0, 1.2, 0.15),
    (-3.0, 0.6, 0.2),
    (-1.0, 0.1, 0.5),
    (-5.0, 2.0, 0.05),
]

colors_br = plt.cm.tab10(np.linspace(0, 1, len(branches)))
roots = []

for i, (a, b, c) in enumerate(branches):
    theta = a + b*t + c*t**2
    disc = b**2 - 4*a*c
    r = (-b + np.sqrt(disc)) / (2*c)
    roots.append(r)
    ax2.plot(t, theta, color=colors_br[i], linewidth=1.5, alpha=0.8)
    ax2.plot(r, 0, 'o', color=colors_br[i], markersize=6, zorder=5)

rho = min(roots)
ax2.axhline(y=0, color='k', linewidth=0.8)
ax2.axvline(x=rho, color='red', linewidth=2.5, linestyle='--', label=f'ρ = {rho:.2f}')

# Shade
ax2.fill_between(t, -8, 0, where=(t < rho), alpha=0.03, color='green')
ax2.fill_between(t, 0, 25, where=(t > rho), alpha=0.03, color='red')

ax2.set_xlabel('Parameter t', fontsize=11)
ax2.set_ylabel('θ(t)', fontsize=11)
ax2.set_title('6-Branch Eigenvalue Flow\nρ = min(first roots)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 6)
ax2.set_ylim(-8, 25)
ax2.grid(True, alpha=0.2)

# ── Panel 3: Monte Carlo stability radius distribution (bottom-left) ──
ax3 = fig.add_subplot(2, 2, 3)

n_trials = 2000
n_branches_mc = 5
radii = []

for _ in range(n_trials):
    trial_roots = []
    for _ in range(n_branches_mc):
        a = -np.random.uniform(0.5, 5)
        b = np.random.uniform(0, 2)
        c = np.random.uniform(0.1, 1.5)
        disc = b**2 - 4*a*c
        r = (-b + np.sqrt(disc)) / (2*c)
        trial_roots.append(r)
    radii.append(min(trial_roots))

radii = np.array(radii)

ax3.hist(radii, bins=80, density=True, color='steelblue', edgecolor='black',
         linewidth=0.3, alpha=0.7)
ax3.axvline(x=np.mean(radii), color='red', linewidth=2, linestyle='--',
            label=f'Mean ρ = {np.mean(radii):.2f}')
ax3.axvline(x=np.median(radii), color='orange', linewidth=2, linestyle='--',
            label=f'Median ρ = {np.median(radii):.2f}')

ax3.set_xlabel('Stability radius ρ', fontsize=11)
ax3.set_ylabel('Density', fontsize=11)
ax3.set_title(f'Distribution of ρ\n({n_trials} random {n_branches_mc}-branch families)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.2)

# ── Panel 4: Sensitivity analysis (bottom-right) ──
ax4 = fig.add_subplot(2, 2, 4)

# How does ρ depend on number of branches?
branch_counts = range(1, 21)
mean_radii = []
std_radii = []

for n_br in branch_counts:
    trial_radii = []
    for _ in range(500):
        tr = []
        for _ in range(n_br):
            a = -np.random.uniform(0.5, 5)
            b = np.random.uniform(0, 2)
            c = np.random.uniform(0.1, 1.5)
            disc = b**2 - 4*a*c
            r = (-b + np.sqrt(disc)) / (2*c)
            tr.append(r)
        trial_radii.append(min(tr))
    mean_radii.append(np.mean(trial_radii))
    std_radii.append(np.std(trial_radii))

mean_radii = np.array(mean_radii)
std_radii = np.array(std_radii)

ax4.plot(list(branch_counts), mean_radii, 'b-o', linewidth=2, markersize=5,
         label='Mean ρ')
ax4.fill_between(list(branch_counts), mean_radii - std_radii, mean_radii + std_radii,
                 alpha=0.2, color='blue', label='±1 std')

ax4.set_xlabel('Number of branches n', fontsize=11)
ax4.set_ylabel('Stability radius ρ', fontsize=11)
ax4.set_title('ρ Decreases with More Branches\n(Order Statistics Effect)', fontsize=12)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.2)

plt.suptitle('Nonlinear Spectral Stability: Complete Phase Portrait',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_stability_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_stability_landscape.png")
