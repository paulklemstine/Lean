#!/usr/bin/env python3
"""
Visualization: Einstein Velocity Addition = Möbius Addition
============================================================
Shows how velocities compose in special relativity using the
same Möbius addition formula that governs arithmetic on the
Poincaré disk. The key insight: the speed of light c is the
boundary of the disk.
"""

import numpy as np
import matplotlib.pyplot as plt


def einstein_add(v, w):
    """Einstein velocity addition: (v + w) / (1 + vw)."""
    return (v + w) / (1 + v * w)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: v ⊕ w for varying v at fixed w
ax = axes[0]
w_vals = [0.2, 0.4, 0.6, 0.8, 0.95]
v_range = np.linspace(-0.99, 0.99, 200)

for w in w_vals:
    result = einstein_add(v_range, w)
    ax.plot(v_range, result, label=f'w = {w}c', linewidth=1.5)

ax.plot(v_range, v_range, 'k--', alpha=0.3, label='Classical (v+w)')
ax.axhline(y=1.0, color='red', linestyle=':', alpha=0.5, label='c (speed limit)')
ax.axhline(y=-1.0, color='red', linestyle=':', alpha=0.5)

ax.set_xlabel('Velocity v (units of c)', fontsize=11)
ax.set_ylabel('Combined velocity v ⊕ w', fontsize=11)
ax.set_title('Einstein Velocity Addition\n(= Möbius addition on real line)',
             fontsize=12, fontweight='bold')
ax.legend(fontsize=8, loc='upper left')
ax.set_xlim(-1, 1)
ax.set_ylim(-1.1, 1.1)
ax.grid(True, alpha=0.3)

# Panel 2: Iterated boosts — approaching c
ax2 = axes[1]
boost_sizes = [0.1, 0.3, 0.5, 0.7, 0.9]
for boost in boost_sizes:
    velocities = [0.0]
    for _ in range(20):
        velocities.append(einstein_add(velocities[-1], boost))
    ax2.plot(range(len(velocities)), velocities, 'o-', markersize=3,
             linewidth=1.5, label=f'Δv = {boost}c')

ax2.axhline(y=1.0, color='red', linestyle=':', linewidth=2, label='c')
ax2.set_xlabel('Number of boosts', fontsize=11)
ax2.set_ylabel('Velocity (units of c)', fontsize=11)
ax2.set_title('Iterated Relativistic Boosts\n(Rapidity = Hyperbolic Distance)',
              fontsize=12, fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.1)

# Panel 3: Rapidity (= hyperbolic distance) is additive
ax3 = axes[2]
v_range2 = np.linspace(0.01, 0.99, 100)
rapidity = np.arctanh(v_range2)

ax3.plot(v_range2, rapidity, 'b-', linewidth=2, label='φ(v) = artanh(v)')
ax3.plot(v_range2, v_range2, 'k--', alpha=0.3, label='φ = v (low speed)')

# Show additivity: φ(v⊕w) = φ(v) + φ(w)
v1, v2 = 0.4, 0.5
phi1, phi2 = np.arctanh(v1), np.arctanh(v2)
v_combined = einstein_add(v1, v2)
phi_combined = np.arctanh(v_combined)

ax3.annotate(f'φ({v1}) = {phi1:.3f}', xy=(v1, phi1),
            xytext=(v1-0.3, phi1+0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='green'))
ax3.annotate(f'φ({v1}⊕{v2}) = {phi_combined:.3f}\n= φ({v1})+φ({v2}) = {phi1+phi2:.3f}',
            xy=(v_combined, phi_combined),
            xytext=(v_combined-0.4, phi_combined+0.3), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='red'))

ax3.set_xlabel('Velocity v (units of c)', fontsize=11)
ax3.set_ylabel('Rapidity φ = artanh(v)', fontsize=11)
ax3.set_title('Rapidity: The Hyperbolic Distance\nthat Makes Addition Linear',
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_einstein_addition.png', dpi=150, bbox_inches='tight')
print("Saved Einstein addition visualization")
