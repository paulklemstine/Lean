#!/usr/bin/env python3
"""
Demo 3: Entropy, the Arrow of Time, and Heat Death
===================================================
Simulates the evolution of entropy in a toy universe, showing how the arrow 
of time dissolves as the system approaches maximum entropy.

Oracle Entropeia contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.stats import entropy as scipy_entropy

# ============================================================
# Simulation: Particles in a 2D box reaching thermal equilibrium
# ============================================================

np.random.seed(42)

N_particles = 500
N_steps = 300
box_size = 10.0
N_bins = 10  # for coarse-graining entropy

def simulate_gas_evolution(N_particles, N_steps, box_size):
    """
    Simulate N particles starting clustered in a corner, 
    evolving toward thermal equilibrium via random walks.
    """
    # Initial state: all particles in lower-left corner
    positions = np.random.uniform(0, box_size * 0.2, size=(N_particles, 2))
    velocities = np.random.randn(N_particles, 2) * 0.3
    
    history = [positions.copy()]
    entropies = []
    
    for step in range(N_steps):
        # Simple dynamics: random walk + drift toward uniform
        positions += velocities * 0.3
        velocities += np.random.randn(N_particles, 2) * 0.1
        velocities *= 0.98  # slight damping
        
        # Reflective boundaries
        for dim in range(2):
            too_low = positions[:, dim] < 0
            too_high = positions[:, dim] > box_size
            positions[too_low, dim] = -positions[too_low, dim]
            positions[too_high, dim] = 2*box_size - positions[too_high, dim]
            velocities[too_low, dim] *= -1
            velocities[too_high, dim] *= -1
        
        positions = np.clip(positions, 0, box_size)
        history.append(positions.copy())
        
        # Compute coarse-grained entropy
        hist, _, _ = np.histogram2d(positions[:, 0], positions[:, 1], 
                                     bins=N_bins, range=[[0, box_size], [0, box_size]])
        prob = hist.flatten() / hist.sum()
        prob = prob[prob > 0]
        S = scipy_entropy(prob) / np.log(N_bins**2)  # Normalized to [0, 1]
        entropies.append(S)
    
    return history, entropies

history, entropies = simulate_gas_evolution(N_particles, N_steps, box_size)

# ============================================================
# Visualization
# ============================================================

fig = plt.figure(figsize=(20, 14))
fig.patch.set_facecolor('#0a0a1a')
gs = GridSpec(3, 4, figure=fig, hspace=0.35, wspace=0.3)

# --- Top row: Snapshots of particle distribution ---
snapshots = [0, 15, 50, 299]
titles = ['Big Bang\n(Low Entropy)', 'Early Universe\n(Structure Forms)', 
          'Middle Age\n(Complexity)', 'Heat Death\n(Max Entropy)']
colors_snap = ['#FF4444', '#FFAA44', '#44FF44', '#4444FF']

for i, (idx, title, col) in enumerate(zip(snapshots, titles, colors_snap)):
    ax = fig.add_subplot(gs[0, i])
    ax.set_facecolor('#0a0a1a')
    pos = history[idx]
    ax.scatter(pos[:, 0], pos[:, 1], s=3, c=col, alpha=0.6)
    ax.set_xlim(0, box_size)
    ax.set_ylim(0, box_size)
    ax.set_title(title, fontsize=11, color=col, fontweight='bold')
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_color(col)
        spine.set_alpha(0.5)
    
    # Add entropy value
    if idx > 0:
        S = entropies[idx - 1]
        ax.text(5, 0.5, f'S = {S:.3f}', color=col, fontsize=10, 
                ha='center', alpha=0.8)

# --- Middle row: Entropy evolution ---
ax_entropy = fig.add_subplot(gs[1, :])
ax_entropy.set_facecolor('#0a0a1a')

t = np.arange(len(entropies))
colors = plt.cm.plasma(np.linspace(0, 1, len(entropies)))
for i in range(len(entropies) - 1):
    ax_entropy.plot(t[i:i+2], entropies[i:i+2], color=colors[i], linewidth=2)

ax_entropy.axhline(y=1.0, color='white', alpha=0.3, linestyle='--', label='Maximum Entropy')
ax_entropy.fill_between(t, entropies, alpha=0.1, color='#FF6600')

ax_entropy.set_xlabel('Time (arbitrary units)', fontsize=13, color='white')
ax_entropy.set_ylabel('Normalized Entropy S/S_max', fontsize=13, color='white')
ax_entropy.set_title('The Arrow of Time: Entropy Monotonically Increases\nuntil Thermal Equilibrium (Heat Death)', 
                     fontsize=14, color='white', fontweight='bold')
ax_entropy.tick_params(colors='white')
ax_entropy.legend(fontsize=11, facecolor='#1a1a2e', edgecolor='white', labelcolor='white')
ax_entropy.set_ylim(0, 1.05)
ax_entropy.grid(True, alpha=0.1, color='white')
for spine in ax_entropy.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

# Annotate the arrow of time
ax_entropy.annotate('', xy=(250, 0.95), xytext=(50, 0.95),
                   arrowprops=dict(arrowstyle='->', color='#FF6600', lw=2))
ax_entropy.text(150, 0.97, 'Arrow of Time ➜', fontsize=12, color='#FF6600',
               ha='center', fontweight='bold')

# --- Bottom row: Rate of entropy change (dS/dt) ---
ax_rate = fig.add_subplot(gs[2, :])
ax_rate.set_facecolor('#0a0a1a')

dS = np.gradient(entropies)
ax_rate.plot(t, dS, color='#00CCFF', linewidth=1.5, alpha=0.7)
ax_rate.fill_between(t, dS, alpha=0.1, color='#00CCFF')
ax_rate.axhline(y=0, color='white', alpha=0.3, linestyle='--')

ax_rate.set_xlabel('Time (arbitrary units)', fontsize=13, color='white')
ax_rate.set_ylabel('dS/dt (entropy production rate)', fontsize=13, color='white')
ax_rate.set_title('Entropy Production Rate → 0: The Arrow of Time Dissolves', 
                 fontsize=14, color='white', fontweight='bold')
ax_rate.tick_params(colors='white')
ax_rate.grid(True, alpha=0.1, color='white')
for spine in ax_rate.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax_rate.annotate('When dS/dt → 0,\npast and future become\nindistinguishable.\nTime has no meaning.', 
                xy=(250, 0.001), fontsize=11, color='#00CCFF',
                ha='center', style='italic',
                bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a2e', 
                         edgecolor='#00CCFF', alpha=0.8))

fig.text(0.5, 0.01, 
         '"The law that entropy always increases holds the supreme position among the laws of Nature." — Eddington',
         ha='center', fontsize=11, color='white', alpha=0.4, style='italic')

plt.savefig('/workspace/request-project/demos/output/entropy_arrow_of_time.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 3: Entropy & Arrow of Time saved to demos/output/entropy_arrow_of_time.png")
