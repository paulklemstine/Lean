#!/usr/bin/env python3
"""
Demo 6: Repulsor Theory & Evasion Dynamics (Direction E1-E5)

Visualizes the mathematics of evasion:
1. Diagonal evasion in function space
2. Pursuit-evasion games on graphs
3. The repulsor-oracle duality
4. Strange attractors as repulsor fixed points
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

np.random.seed(42)

# ─── Figure 1: Multi-panel Repulsor Theory ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Oracle vs Repulsor dynamics
ax1 = fig.add_subplot(gs[0, 0])
t = np.linspace(0, 10, 200)

# Oracle (fixed point): iterations converge
x_oracle = 0.7  # fixed point
x_start = 0.1
oracle_trajectory = x_oracle + (x_start - x_oracle) * np.exp(-0.5 * t)

# Repulsor (anti-fixed point): iterations diverge
repulsor_center = 0.5
repulsor_trajectory = repulsor_center + (x_start - repulsor_center) * np.exp(0.3 * t)
repulsor_trajectory = np.clip(repulsor_trajectory, -2, 3)

ax1.plot(t, oracle_trajectory, '-', color='#2196F3', linewidth=2.5,
         label='Oracle (attractor)')
ax1.plot(t, repulsor_trajectory, '-', color='#E91E63', linewidth=2.5,
         label='Repulsor (evader)')
ax1.axhline(y=x_oracle, color='#2196F3', linestyle='--', alpha=0.3)
ax1.axhline(y=repulsor_center, color='#E91E63', linestyle='--', alpha=0.3)
ax1.set_xlabel('Iteration t', fontsize=12)
ax1.set_ylabel('State x(t)', fontsize=12)
ax1.set_title('Oracle vs. Repulsor Dynamics\n(attract vs. evade)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.5, 3)

# Panel 2: Pursuit-Evasion on a grid
ax2 = fig.add_subplot(gs[0, 1])

# Simulate pursuit-evasion on a 10x10 grid
grid_size = 10
pursuer = np.array([0.0, 0.0])
evader = np.array([9.0, 9.0])
pursuer_path = [pursuer.copy()]
evader_path = [evader.copy()]

for step in range(30):
    # Pursuer moves toward evader
    direction = evader - pursuer
    dist = np.linalg.norm(direction)
    if dist > 0.5:
        pursuer = pursuer + 0.8 * direction / dist

    # Evader moves away from pursuer (with random jitter)
    away = evader - pursuer
    away_norm = np.linalg.norm(away)
    if away_norm > 0:
        evader = evader + 0.5 * away / away_norm + 0.3 * np.random.randn(2)
    evader = np.clip(evader, 0, grid_size - 1)

    pursuer_path.append(pursuer.copy())
    evader_path.append(evader.copy())

pursuer_path = np.array(pursuer_path)
evader_path = np.array(evader_path)

ax2.plot(pursuer_path[:, 0], pursuer_path[:, 1], 'o-', color='#2196F3',
         markersize=3, linewidth=1.5, label='Pursuer', alpha=0.7)
ax2.plot(evader_path[:, 0], evader_path[:, 1], 's-', color='#E91E63',
         markersize=3, linewidth=1.5, label='Evader', alpha=0.7)
ax2.plot(pursuer_path[0, 0], pursuer_path[0, 1], 'o', color='#2196F3',
         markersize=12, zorder=5)
ax2.plot(evader_path[0, 0], evader_path[0, 1], 's', color='#E91E63',
         markersize=12, zorder=5)
ax2.set_xlim(-1, grid_size)
ax2.set_ylim(-1, grid_size)
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('y', fontsize=12)
ax2.set_title('Pursuit-Evasion Game\n(evader has advantage on open grid)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_aspect('equal')

# Panel 3: Search Hardening (each query makes the target harder to find)
ax3 = fig.add_subplot(gs[1, 0])

queries = np.arange(1, 51)
# Model: target has n possible locations, each query eliminates one but
# the target can "move" to a new location with probability that increases
initial_difficulty = 1.0
difficulties = [initial_difficulty]
found_prob = []

for q in queries:
    # Difficulty increases logarithmically with queries (search hardening)
    d = initial_difficulty * (1 + 0.5 * np.log(1 + q))
    difficulties.append(d)
    # Probability of finding decreases
    found_prob.append(1.0 / d)

# Compare with standard search (no hardening)
standard_found = [1.0 / (51 - q) for q in queries]  # gets easier

ax3.plot(queries, found_prob, '-', color='#E91E63', linewidth=2.5,
         label='Repulsor search (hardening)')
ax3.plot(queries, standard_found, '-', color='#4CAF50', linewidth=2.5,
         label='Standard search (elimination)')
ax3.set_xlabel('Number of queries', fontsize=12)
ax3.set_ylabel('P(find target on next query)', fontsize=12)
ax3.set_title('Search Hardening Effect\n(repulsor vs. standard search)',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# Panel 4: Lorenz-like Strange Attractor as Repulsor Fixed Point
ax4 = fig.add_subplot(gs[1, 1])

# Simplified Lorenz-like system
def lorenz_step(state, dt=0.01, sigma=10, rho=28, beta=8/3):
    x, y, z = state
    dx = sigma * (y - x)
    dy = x * (rho - z) - y
    dz = x * y - beta * z
    return np.array([x + dx*dt, y + dy*dt, z + dz*dt])

state = np.array([1.0, 1.0, 1.0])
trajectory = [state]
for _ in range(5000):
    state = lorenz_step(state)
    trajectory.append(state)
trajectory = np.array(trajectory)

ax4.plot(trajectory[:, 0], trajectory[:, 2], '-', color='#9C27B0',
         linewidth=0.3, alpha=0.6)
ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('z', fontsize=12)
ax4.set_title('Strange Attractor = Repulsor Fixed Point\n(Lorenz system: neither fixed nor escaping)',
              fontsize=13, fontweight='bold')
ax4.grid(True, alpha=0.3)

fig.suptitle('Direction E1-E5: Repulsor Theory & The Mathematics of Evasion',
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig9_repulsor_evasion.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 9 saved: fig9_repulsor_evasion.png")
