#!/usr/bin/env python3
"""
Visualization: Orbit Structure of Residue Sums Under Unit Actions

For sums of 4 fourth powers, shows how the representable residue set
decomposes into orbits under multiplication by 4th-power units.
This illustrates the unit power symmetry theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def nth_power_residues(n, m):
    return {pow(a, n, m) for a in range(m)}


def diagonal_residue_sums(n, s, m):
    if s <= 0:
        return {0}
    residues = nth_power_residues(n, m)
    current = {0}
    for _ in range(s):
        current = {(a + r) % m for a in current for r in residues}
    return current


n, s = 4, 4
moduli = [8, 16, 25, 32]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, m in enumerate(moduli):
    ax = axes[idx // 2][idx % 2]

    res_set = diagonal_residue_sums(n, s, m)
    units = [a for a in range(m) if gcd(a, m) == 1]
    nth_power_units = sorted({pow(u, n, m) for u in units})

    # Compute orbits
    visited = set()
    orbits = []
    for r in range(m):
        if r in visited:
            continue
        orbit = {(u * r) % m for u in nth_power_units}
        visited.update(orbit)
        in_set = orbit & res_set
        out_set = orbit - res_set
        orbits.append((sorted(orbit), len(in_set) > 0))

    # Create circular layout
    angles = np.linspace(0, 2 * np.pi, m, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)

    # Color by orbit membership
    colors = []
    for r in range(m):
        if r in res_set:
            colors.append('#2ecc71')  # Green for representable
        else:
            colors.append('#e74c3c')  # Red for non-representable

    ax.scatter(x_pos, y_pos, c=colors, s=200, zorder=5, edgecolors='black', linewidth=0.5)

    # Label residues
    for r in range(m):
        offset = 1.15
        ax.text(x_pos[r] * offset, y_pos[r] * offset, str(r),
                ha='center', va='center', fontsize=7)

    # Draw orbit connections with lines
    orbit_colors = plt.cm.Set2(np.linspace(0, 1, len(orbits)))
    for oi, (orbit, in_res) in enumerate(orbits):
        if len(orbit) > 1:
            for i in range(len(orbit)):
                for j in range(i + 1, len(orbit)):
                    r1, r2 = orbit[i], orbit[j]
                    ax.plot([x_pos[r1], x_pos[r2]],
                           [y_pos[r1], y_pos[r2]],
                           color=orbit_colors[oi], alpha=0.3, linewidth=0.8)

    ax.set_title(f'm = {m}: {len(res_set)}/{m} representable, '
                 f'{len(orbits)} orbits\n'
                 f'4th-power units: {nth_power_units}',
                 fontsize=10)
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', edgecolor='black', label='Representable'),
    Patch(facecolor='#e74c3c', edgecolor='black', label='Obstructed'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11)

fig.suptitle('Orbit Decomposition of Residue Sums Under 4th-Power Unit Action\n'
             'x₁⁴ + x₂⁴ + x₃⁴ + x₄⁴ ≡ k (mod m)',
             fontsize=14, fontweight='bold')

plt.tight_layout(rect=[0, 0.05, 1, 0.93])
plt.savefig('viz_orbit_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_orbit_structure.png")
