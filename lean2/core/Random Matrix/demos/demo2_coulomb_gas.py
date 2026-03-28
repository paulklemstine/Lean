#!/usr/bin/env python3
"""
Demo 2: The Coulomb Gas Simulation
====================================
Simulates eigenvalues as a 1D Coulomb gas using Langevin dynamics.
Shows how the balance between log-repulsion and quadratic confinement
produces the Wigner semicircle law.

Run: python demo2_coulomb_gas.py
Outputs: coulomb_gas.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(123)

def coulomb_gas_langevin(n_particles, beta, n_steps=20000, dt=0.001):
    """
    Simulate a 1D Coulomb gas via overdamped Langevin dynamics.
    
    dλ_i = [-dE/dλ_i] dt + √(2/β) dW_i
    
    where E = -β Σ_{i<j} log|λ_i - λ_j| + Σ λ_i²/2
    """
    # Initialize near equilibrium (semicircle)
    x = np.sort(np.random.uniform(-2, 2, n_particles))
    noise_scale = np.sqrt(2 * dt / beta)
    
    trajectory = [x.copy()]
    energies = []
    
    for step in range(n_steps):
        # Coulomb force: F_i = β Σ_{j≠i} 1/(λ_i - λ_j)
        force = np.zeros(n_particles)
        for i in range(n_particles):
            diffs = x[i] - x[np.arange(n_particles) != i]
            # Regularize to avoid division by zero
            diffs = np.where(np.abs(diffs) < 1e-10, 1e-10 * np.sign(diffs + 1e-20), diffs)
            force[i] = beta * np.sum(1.0 / diffs)
        
        # Confining force: -λ_i
        force -= x
        
        # Langevin step
        x = x + force * dt + noise_scale * np.random.randn(n_particles)
        x = np.sort(x)  # Maintain ordering (particles don't cross due to repulsion)
        
        if step % 100 == 0:
            trajectory.append(x.copy())
            # Compute energy
            E_coulomb = 0
            for i in range(n_particles):
                for j in range(i+1, n_particles):
                    E_coulomb -= beta * np.log(max(abs(x[j] - x[i]), 1e-15))
            E_confine = np.sum(x**2) / 2
            energies.append(E_coulomb + E_confine)
    
    return np.array(trajectory), np.array(energies)

# ─── Run simulations ───
N = 50  # Number of particles

print("Simulating β=1 (GOE temperature)...")
traj1, energy1 = coulomb_gas_langevin(N, beta=1.0, n_steps=15000)

print("Simulating β=2 (GUE temperature)...")
traj2, energy2 = coulomb_gas_langevin(N, beta=2.0, n_steps=15000)

print("Simulating β=4 (GSE temperature)...")
traj4, energy4 = coulomb_gas_langevin(N, beta=4.0, n_steps=15000)

# ─── Wigner semicircle ───
x_sc = np.linspace(-2.5, 2.5, 500)
semicircle = np.where(np.abs(x_sc) <= 2, np.sqrt(4 - x_sc**2) / (2 * np.pi), 0)

# ─── Plot ───
fig = plt.figure(figsize=(18, 14))
fig.suptitle("The Coulomb Gas: Eigenvalues as Charged Particles\n"
             "Langevin dynamics of log-interacting particles in a quadratic potential",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(3, 3, hspace=0.4, wspace=0.35)

# Row 1: Particle trajectories (time evolution)
for idx, (beta_val, traj, color, label) in enumerate([
    (1, traj1, '#e74c3c', 'β = 1 (GOE)'),
    (2, traj2, '#3498db', 'β = 2 (GUE)'),
    (4, traj4, '#2ecc71', 'β = 4 (GSE)')
]):
    ax = fig.add_subplot(gs[0, idx])
    n_show = min(100, len(traj))
    for p in range(N):
        ax.plot(np.arange(n_show), traj[:n_show, p],
                alpha=0.3, linewidth=0.5, color=color)
    ax.set_xlabel('Time step (×100)', fontsize=10)
    ax.set_ylabel('Position λ', fontsize=10)
    ax.set_title(f'Particle Trajectories — {label}', fontsize=11, fontweight='bold')
    ax.set_ylim(-3.5, 3.5)

# Row 2: Equilibrium density → semicircle
for idx, (beta_val, traj, color, label) in enumerate([
    (1, traj1, '#e74c3c', 'β = 1'),
    (2, traj2, '#3498db', 'β = 2'),
    (4, traj4, '#2ecc71', 'β = 4')
]):
    ax = fig.add_subplot(gs[1, idx])
    # Use last half of trajectory for equilibrium
    eq_samples = traj[len(traj)//2:].flatten()
    ax.hist(eq_samples, bins=60, density=True, alpha=0.6, color=color,
            edgecolor='white', linewidth=0.5, label=f'Simulation ({label})')
    ax.plot(x_sc, semicircle, 'k-', linewidth=2.5, label='Wigner semicircle')
    ax.set_xlabel('Position λ', fontsize=10)
    ax.set_ylabel('Density ρ(λ)', fontsize=10)
    ax.set_title(f'Equilibrium Density — {label}', fontsize=11, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.legend(fontsize=9)

# Row 3: Energy convergence + snapshot + force diagram
ax_energy = fig.add_subplot(gs[2, 0])
ax_energy.plot(energy1, color='#e74c3c', alpha=0.7, label='β=1')
ax_energy.plot(energy2, color='#3498db', alpha=0.7, label='β=2')
ax_energy.plot(energy4, color='#2ecc71', alpha=0.7, label='β=4')
ax_energy.set_xlabel('Time step (×100)', fontsize=10)
ax_energy.set_ylabel('Total Energy', fontsize=10)
ax_energy.set_title('Energy Convergence', fontsize=11, fontweight='bold')
ax_energy.legend(fontsize=9)

# Snapshot of final configuration
ax_snap = fig.add_subplot(gs[2, 1])
y_offsets = [0.3, 0.0, -0.3]
colors = ['#e74c3c', '#3498db', '#2ecc71']
labels = ['β=1 (GOE)', 'β=2 (GUE)', 'β=4 (GSE)']
trajs = [traj1, traj2, traj4]
for i, (traj, y, col, lab) in enumerate(zip(trajs, y_offsets, colors, labels)):
    final = traj[-1]
    ax_snap.scatter(final, np.full_like(final, y), s=25, c=col,
                    edgecolors='black', linewidth=0.5, label=lab, zorder=3)
    ax_snap.axhline(y=y, color=col, alpha=0.2, linewidth=8)
ax_snap.set_xlabel('Position λ', fontsize=10)
ax_snap.set_title('Final Configuration Snapshot', fontsize=11, fontweight='bold')
ax_snap.set_yticks(y_offsets)
ax_snap.set_yticklabels(labels, fontsize=9)
ax_snap.set_xlim(-3, 3)
ax_snap.set_ylim(-0.6, 0.6)

# Force diagram
ax_force = fig.add_subplot(gs[2, 2])
r = np.linspace(0.05, 3, 200)
for beta_val, col, lab in [(1, '#e74c3c', 'β=1'), (2, '#3498db', 'β=2'), (4, '#2ecc71', 'β=4')]:
    ax_force.plot(r, beta_val / r, color=col, linewidth=2, label=lab)
ax_force.axhline(y=0, color='gray', linewidth=0.5)
ax_force.set_xlabel('Separation |λᵢ - λⱼ|', fontsize=10)
ax_force.set_ylabel('Repulsive Force β/r', fontsize=10)
ax_force.set_title('Coulomb Repulsion Force', fontsize=11, fontweight='bold')
ax_force.set_ylim(0, 20)
ax_force.set_xlim(0, 3)
ax_force.legend(fontsize=9)
ax_force.text(1.5, 15, 'F = β/r → ∞ as r → 0\n(infinite barrier)',
              fontsize=9, ha='center', style='italic',
              bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.text(0.5, 0.01,
         "The Coulomb gas reaches equilibrium at the Wigner semicircle ρ(λ) = √(4−λ²)/(2π).\n"
         "Higher β = stronger repulsion = more rigid spacing = lower temperature.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('coulomb_gas.png', dpi=150, bbox_inches='tight')
print("Saved: coulomb_gas.png")
plt.close()
