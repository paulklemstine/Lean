#!/usr/bin/env python3
"""
Visualization 3: Landauer Cost — The Thermodynamics of Computation

Shows the relationship between entropy and thermodynamic cost.
The Landauer Zero Theorem states that zero cost ⟺ reversible (injective).
This visualization shows the "entropy-thermodynamics bridge."
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def compute_entropy_and_cost(f_values: list, n: int):
    if n == 0:
        return 0.0, 0.0
    counts = Counter(f_values)
    total_log = sum(math.log(counts[f_values[x]]) for x in range(n))
    entropy = total_log / n
    cost = total_log  # Landauer cost = n * entropy
    return entropy, cost


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Entropy vs Landauer cost for various functions on Fin 16
ax1 = axes[0]
n = 16
domain = list(range(n))

# Sample functions with different fiber structures
functions = []
labels = []

# Modular functions
for k in [1, 2, 4, 8, 16]:
    f_vals = [x % max(k, 1) for x in domain]
    if k == 16:
        f_vals = [x for x in domain]
    functions.append(f_vals)
    labels.append(f'mod {k}' if k < 16 else 'id')

# Bit-shift functions
for shift in [1, 2, 3]:
    f_vals = [x >> shift for x in domain]
    functions.append(f_vals)
    labels.append(f'>>  {shift}')

# Constant
functions.append([0] * n)
labels.append('const')

entropies_list = []
costs_list = []
for f_vals in functions:
    H, C = compute_entropy_and_cost(f_vals, n)
    entropies_list.append(H)
    costs_list.append(C)

ax1.scatter(entropies_list, costs_list, c='steelblue', s=80, zorder=3)
for i, label in enumerate(labels):
    ax1.annotate(label, (entropies_list[i], costs_list[i]),
                 textcoords="offset points", xytext=(5, 5), fontsize=8)

# Plot the line C = n * H
H_range = np.linspace(0, max(entropies_list) * 1.1, 100)
ax1.plot(H_range, n * H_range, 'r--', alpha=0.5, label=f'C = {n} · H')
ax1.set_xlabel('Functorial Entropy H(f)', fontsize=11)
ax1.set_ylabel('Landauer Cost', fontsize=11)
ax1.set_title(f'Entropy-Cost Relationship (n={n})', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Physical energy cost at different temperatures
ax2 = axes[1]
k_B = 1.38e-23  # Boltzmann constant (J/K)
temperatures = [4, 77, 300, 1000]  # K (helium, nitrogen, room, hot)
temp_labels = ['4K\n(Helium)', '77K\n(LN₂)', '300K\n(Room)', '1000K\n(Hot)']

# For a function that halves the domain (1 bit erasure per element)
bits_erased = list(range(1, 9))

for i, T in enumerate(temperatures):
    energy_per_bit = k_B * T * math.log(2)
    energies = [b * n * energy_per_bit * 1e21 for b in bits_erased]  # in zeptojoules
    ax2.plot(bits_erased, energies, marker='o', label=temp_labels[i], linewidth=2)

ax2.set_xlabel('Bits erased per element', fontsize=11)
ax2.set_ylabel('Energy cost (zJ = 10⁻²¹ J)', fontsize=11)
ax2.set_title(f'Landauer Energy Cost (n={n} elements)', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Fiber histogram for different function types
ax3 = axes[2]
n_big = 60

fiber_data = {
    'Bijection\n(id)': Counter([x for x in range(n_big)]),
    '2-to-1\n(mod 30)': Counter([x % 30 for x in range(n_big)]),
    '3-to-1\n(mod 20)': Counter([x % 20 for x in range(n_big)]),
    'Mixed\n(x²mod 60)': Counter([x * x % 60 for x in range(n_big)]),
    'Constant': Counter([0] * n_big),
}

x_pos = np.arange(len(fiber_data))
bar_width = 0.6

entropies_bar = []
for name, counts in fiber_data.items():
    # Compute entropy
    f_vals = []
    for val, count in counts.items():
        f_vals.extend([val] * count)
    H, _ = compute_entropy_and_cost(f_vals, len(f_vals))
    entropies_bar.append(H)

bars = ax3.bar(x_pos, entropies_bar, bar_width, color=['green', 'skyblue', 'steelblue', 'orange', 'red'],
               edgecolor='black', alpha=0.8)
ax3.set_xticks(x_pos)
ax3.set_xticklabels(list(fiber_data.keys()), fontsize=9)
ax3.set_ylabel('Functorial Entropy H(f)', fontsize=11)
ax3.set_title(f'Entropy by Function Type (n={n_big})', fontsize=12)
ax3.axhline(y=0, color='green', linestyle=':', alpha=0.5)
ax3.axhline(y=math.log(n_big), color='red', linestyle=':', alpha=0.5,
            label=f'max = log({n_big})')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Add entropy values on bars
for bar, H in zip(bars, entropies_bar):
    ax3.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.05,
             f'{H:.2f}', ha='center', va='bottom', fontsize=9)

plt.tight_layout()
plt.savefig('landauer_cost.png', dpi=150, bbox_inches='tight')
print("Saved landauer_cost.png")
