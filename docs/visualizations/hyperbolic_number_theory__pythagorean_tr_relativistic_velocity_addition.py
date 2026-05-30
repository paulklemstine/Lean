#!/usr/bin/env python3
"""
Visualization: Relativistic Velocity Addition Group

Shows how the relativistic velocity addition formula β₁ ⊕ β₂ = (β₁+β₂)/(1+β₁β₂)
keeps velocities below the speed of light, in contrast to classical (Galilean)
addition which can exceed c.

The left panel shows the group operation as a 2D heatmap.
The right panel shows successive compositions: what happens when you keep
adding β = 0.5c to itself, comparing classical vs relativistic.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def velocity_add(b1, b2):
    """Relativistic velocity addition."""
    return (b1 + b2) / (1 + b1 * b2)


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- PANEL 1: Heatmap of velocity addition ----
ax = axes[0]
n = 200
beta_range = np.linspace(-0.99, 0.99, n)
B1, B2 = np.meshgrid(beta_range, beta_range)
Result = velocity_add(B1, B2)

im = ax.pcolormesh(B1, B2, Result, cmap='RdBu_r', vmin=-1, vmax=1, shading='auto')
plt.colorbar(im, ax=ax, label='β₁ ⊕ β₂')

# Add contour lines
contours = ax.contour(B1, B2, Result, levels=np.linspace(-0.9, 0.9, 10), 
                       colors='black', linewidths=0.5, alpha=0.4)

# Mark the "light speed barrier"
ax.axhline(y=0, color='white', linewidth=0.5, alpha=0.5)
ax.axvline(x=0, color='white', linewidth=0.5, alpha=0.5)

# Mark Pythagorean velocities
pyth_velocities = [3/5, 5/13, 8/17, 7/25, 20/29]
for v in pyth_velocities:
    ax.axhline(y=v, color='lime', linewidth=0.5, alpha=0.3)
    ax.axvline(x=v, color='lime', linewidth=0.5, alpha=0.3)

ax.set_xlabel('β₁ (fraction of c)', fontsize=11)
ax.set_ylabel('β₂ (fraction of c)', fontsize=11)
ax.set_title('Relativistic Velocity Addition\nβ₁ ⊕ β₂ = (β₁+β₂)/(1+β₁β₂)', fontsize=12)
ax.set_aspect('equal')

# ---- PANEL 2: Classical vs Relativistic composition ----
ax = axes[1]

beta_fixed = 0.5
n_steps = 15

classical = [0]
relativistic = [0]

for i in range(n_steps):
    classical.append(classical[-1] + beta_fixed)
    relativistic.append(velocity_add(relativistic[-1], beta_fixed))

steps = range(n_steps + 1)
ax.plot(steps, classical, 'r-o', markersize=4, label='Classical (Galilean)', linewidth=2)
ax.plot(steps, relativistic, 'b-s', markersize=4, label='Relativistic', linewidth=2)
ax.axhline(y=1.0, color='gold', linewidth=2, linestyle='--', label='Speed of light', alpha=0.8)
ax.fill_between(steps, 1.0, max(classical), alpha=0.1, color='red')

ax.set_xlabel('Number of boosts (each adds β = 0.5c)', fontsize=11)
ax.set_ylabel('Total velocity (fraction of c)', fontsize=11)
ax.set_title('Successive Velocity Additions\n(Classical vs Relativistic)', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.set_ylim(-0.1, max(classical) * 1.05)
ax.grid(True, alpha=0.3)

# ---- PANEL 3: Rapidity (arctanh) linearization ----
ax = axes[2]

# In rapidity space, velocity addition is just ordinary addition
beta_values = np.linspace(0.01, 0.99, 50)
rapidity = np.arctanh(beta_values)

ax.plot(beta_values, rapidity, 'b-', linewidth=2, label='φ = arctanh(β)')
ax.plot(beta_values, beta_values, 'r--', linewidth=1, alpha=0.5, label='φ = β (small β)')

# Mark Pythagorean velocities
for v in pyth_velocities[:4]:
    phi = np.arctanh(v)
    ax.plot(v, phi, 'go', markersize=8, zorder=5)
    ax.annotate(f'β={v:.2f}', (v, phi), textcoords="offset points", 
               xytext=(8, -5), fontsize=8)

# Show that rapidity of composed velocity = sum of rapidities
phi1 = np.arctanh(3/5)
phi2 = np.arctanh(5/13)
beta_composed = velocity_add(3/5, 5/13)
phi_composed = np.arctanh(beta_composed)

ax.annotate(f'φ(3/5) + φ(5/13) = {phi1:.3f} + {phi2:.3f} = {phi1+phi2:.3f}\n'
           f'φ(3/5 ⊕ 5/13) = φ({beta_composed:.4f}) = {phi_composed:.3f}\n'
           f'Match: {"✓" if abs(phi1+phi2-phi_composed) < 1e-10 else "✗"}',
           xy=(0.3, 1.5), fontsize=8, 
           bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

ax.set_xlabel('Velocity β (fraction of c)', fontsize=11)
ax.set_ylabel('Rapidity φ = arctanh(β)', fontsize=11)
ax.set_title('Rapidity: Linearizing\nVelocity Addition', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('velocity_addition_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: velocity_addition_visualization.png")
