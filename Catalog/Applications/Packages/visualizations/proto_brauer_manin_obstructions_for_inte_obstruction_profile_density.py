#!/usr/bin/env python3
"""
Visualization 3: Obstruction Profile Density

Shows the fraction of integers k in [1, N] that are obstructed at each
modulus m. The spike at m = 9 reveals the dominant role of the mod 9
obstruction. Multiples of 9 also show elevated obstruction rates due
to upward closure (Theorem: obstruction_upward_closed).
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


N = 500
M_max = 80

# For each modulus, count how many k in [1, N] are obstructed
moduli = list(range(2, M_max + 1))
obstruction_rates = []

for m in moduli:
    obstructed = sum(1 for k in range(1, N + 1) if not has_cubic_solution_mod(k, m))
    obstruction_rates.append(obstructed / N)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))

# Top panel: bar chart of obstruction rates
colors = []
for m in moduli:
    if m == 9:
        colors.append('#8b0000')  # dark red for m=9
    elif m % 9 == 0:
        colors.append('#cc4444')  # lighter red for multiples of 9
    elif m % 3 == 0:
        colors.append('#ff8888')  # pink for multiples of 3
    else:
        colors.append('#4488cc')  # blue for others

ax1.bar(moduli, obstruction_rates, color=colors, width=0.8, alpha=0.85)
ax1.set_xlabel('Modulus m', fontsize=12)
ax1.set_ylabel('Fraction of k ∈ [1,500] obstructed', fontsize=12)
ax1.set_title('Obstruction Rate by Modulus\n'
              'Red = multiples of 3, Dark red = m=9', fontsize=13)
ax1.axhline(y=2/9, color='green', linestyle='--', alpha=0.7,
            label=f'2/9 ≈ {2/9:.3f} (mod 9 prediction)')
ax1.legend(fontsize=10)

# Bottom panel: cumulative obstruction — fraction of k obstructed
# by at least one modulus ≤ m
cumulative_rates = []
for m_cutoff in moduli:
    obstructed = set()
    for m in range(2, m_cutoff + 1):
        for k in range(1, N + 1):
            if not has_cubic_solution_mod(k, m):
                obstructed.add(k)
    cumulative_rates.append(len(obstructed) / N)

ax2.plot(moduli, cumulative_rates, 'b-', linewidth=2, label='Cumulative obstruction rate')
ax2.axhline(y=2/9, color='green', linestyle='--', alpha=0.7,
            label=f'2/9 ≈ {2/9:.3f} (mod 9 alone)')
ax2.fill_between(moduli, cumulative_rates, alpha=0.15, color='blue')
ax2.set_xlabel('Maximum modulus M', fontsize=12)
ax2.set_ylabel('Fraction of k ∈ [1,500] obstructed\nby some m ≤ M', fontsize=12)
ax2.set_title('Cumulative Obstruction Coverage', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 0.4)

plt.tight_layout()
plt.savefig('viz_profile_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_profile_density.png")
