#!/usr/bin/env python3
"""
Visualization 2: Einstein Velocity Addition = Hyperbolic Addition

Shows the fundamental cross-domain connection: the relativistic velocity
addition formula from special relativity IS hyperbolic addition on the
Poincaré disk. Plots the velocity composition function and compares it
with classical (Newtonian) addition.
"""

import numpy as np
import matplotlib.pyplot as plt


def einstein_add(v1, v2):
    """Einstein velocity addition (= hyperbolic addition for reals)."""
    return (v1 + v2) / (1 + v1 * v2)


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Comparison of Newton vs Einstein addition
ax = axes[0]
v1_range = np.linspace(0, 0.99, 200)

for v2 in [0.1, 0.3, 0.5, 0.7, 0.9]:
    v_newton = v1_range + v2
    v_einstein = (v1_range + v2) / (1 + v1_range * v2)
    ax.plot(v1_range, v_einstein, linewidth=2, label=f'v₂ = {v2}c')
    ax.plot(v1_range, v_newton, '--', alpha=0.3, linewidth=1, color='gray')

ax.axhline(y=1.0, color='red', linewidth=2, linestyle='-', alpha=0.7, label='Speed of light c')
ax.set_xlabel('v₁ / c', fontsize=12)
ax.set_ylabel('v₁ ⊕ v₂ / c', fontsize=12)
ax.set_title('Einstein Addition vs Newton\n(dashed = Newtonian)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.6)
ax.grid(True, alpha=0.3)

# Panel 2: Repeated boosts — convergence to c
ax = axes[1]
boost_values = [0.05, 0.1, 0.2, 0.3, 0.5]
n_boosts = np.arange(1, 51)

for v in boost_values:
    velocities = []
    current = 0.0
    for n in n_boosts:
        current = einstein_add(current, v)
        velocities.append(current)
    ax.plot(n_boosts, velocities, linewidth=2, label=f'boost = {v}c')

ax.axhline(y=1.0, color='red', linewidth=2, linestyle='-', alpha=0.7)
ax.set_xlabel('Number of boosts', fontsize=12)
ax.set_ylabel('Resultant velocity / c', fontsize=12)
ax.set_title('Repeated Relativistic Boosts\nAlways < c (hyperbolic saturation)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

# Panel 3: Non-commutativity (2D complex velocities)
ax = axes[2]

# Generate grid of a ⊕ b vs b ⊕ a differences for complex velocities
N = 30
reals = np.linspace(-0.8, 0.8, N)
imags = np.linspace(-0.8, 0.8, N)
noncomm = np.zeros((N, N))

a_fixed = 0.3 + 0.2j
for i, re in enumerate(reals):
    for j, im in enumerate(imags):
        b = complex(re, im)
        if abs(b) >= 0.95 or abs(a_fixed) >= 0.95:
            noncomm[j, i] = np.nan
            continue
        # a ⊕ b
        ab = (a_fixed + b) / (1 + a_fixed.conjugate() * b)
        # b ⊕ a
        ba = (b + a_fixed) / (1 + b.conjugate() * a_fixed)
        noncomm[j, i] = abs(ab - ba)

im = ax.pcolormesh(reals, imags, noncomm, cmap='hot_r', shading='auto')
plt.colorbar(im, ax=ax, label='|a⊕b - b⊕a|')

# Draw disk boundary
theta = np.linspace(0, 2*np.pi, 100)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Mark fixed point a
ax.plot(a_fixed.real, a_fixed.imag, 'c*', markersize=15, markeredgecolor='black',
        markeredgewidth=1, label=f'a = {a_fixed}')

ax.set_xlabel('Re(b)', fontsize=12)
ax.set_ylabel('Im(b)', fontsize=12)
ax.set_title('Non-Commutativity of Hyperbolic Addition\n|a⊕b − b⊕a| (gyrogroup structure)',
             fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('viz_einstein_addition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_einstein_addition.png")
