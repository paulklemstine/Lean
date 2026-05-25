#!/usr/bin/env python3
"""
Visualization 2: 3-adic Obstruction Tower

Visualizes how the mod 9 obstruction persists (or doesn't) through higher
powers of 3. For k ≡ 4, 5 (mod 9), the obstruction persists at all levels
3^e (e ≥ 2). For other values, solvability is maintained.

This illustrates Theorem 5: mod_nine_obstruction_controls_all_three_power_levels
"""

import numpy as np
import matplotlib.pyplot as plt


def has_cubic_solution_mod(k, m):
    if m <= 0:
        return True
    target = k % m
    cubes = {pow(x, 3, m) for x in range(m)}
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


# Analyze k = 0..17 across powers of 3
k_values = list(range(18))
max_exponent = 6
exponents = list(range(1, max_exponent + 1))

fig, ax = plt.subplots(figsize=(12, 7))

# Build data matrix
data = np.zeros((len(exponents), len(k_values)))
for i, e in enumerate(exponents):
    m = 3 ** e
    for j, k in enumerate(k_values):
        data[i, j] = 1 if has_cubic_solution_mod(k, m) else 0

im = ax.imshow(data, aspect='auto', cmap='RdYlGn', interpolation='nearest',
               extent=[-0.5, len(k_values) - 0.5, max_exponent + 0.5, 0.5])

ax.set_xticks(range(len(k_values)))
ax.set_xticklabels(k_values)
ax.set_yticks(range(1, max_exponent + 1))
ax.set_yticklabels([f'3^{e} = {3**e}' for e in exponents])

ax.set_xlabel('k', fontsize=13)
ax.set_ylabel('Modulus (power of 3)', fontsize=13)
ax.set_title('3-adic Obstruction Tower\n'
             'Green = solvable, Red = obstructed', fontsize=14)

# Annotate obstructed columns
for j, k in enumerate(k_values):
    if k % 9 in [4, 5]:
        ax.axvline(x=j, color='black', alpha=0.3, linewidth=2, linestyle=':')
        ax.text(j, 0.2, f'k≡{k%9}', ha='center', va='bottom', fontsize=8,
                color='red', fontweight='bold',
                transform=ax.get_xaxis_transform())

# Add cell annotations
for i, e in enumerate(exponents):
    m = 3 ** e
    for j, k in enumerate(k_values):
        solvable = has_cubic_solution_mod(k, m)
        symbol = '✓' if solvable else '✗'
        color = 'darkgreen' if solvable else 'darkred'
        ax.text(j, i + 1, symbol, ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_3adic_tower.png', dpi=150, bbox_inches='tight')
print("Saved viz_3adic_tower.png")
