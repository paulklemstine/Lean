"""
Visualization 1: Filtration-Weighted Density Separation

Visualizes how two chain complexes with identical differentials but different
filtration timings produce different density values. Shows the "asymmetric
window" through which filtration timing becomes detectable.

The heatmap shows density ρ(C) as a function of the two C₁ filtration values,
with the d₁ = [[1],[0]] differential highlighting how only the first basis
vector's filtration matters.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Density heatmap for d₁ = [[1],[0]]
ax1 = axes[0]
filt2_val = 2  # fixed C₂ filtration
n = 8
density_map = np.zeros((n, n))
for f0 in range(n):
    for f1 in range(n):
        # d₁[0,0] = 1 ≠ 0, d₁[1,0] = 0
        # density = (filt₁[0] - filt₂[0]) = f0 - 2
        density_map[f1, f0] = f0 - filt2_val

im1 = ax1.imshow(density_map, cmap='RdBu_r', origin='lower', aspect='equal',
                  vmin=-4, vmax=6)
ax1.set_xlabel('filt₁[0] (active basis)', fontsize=11)
ax1.set_ylabel('filt₁[1] (inactive basis)', fontsize=11)
ax1.set_title('Density ρ(C) for d₁ = [[1],[0]]', fontsize=12, fontweight='bold')

# Mark the two example complexes
ax1.plot(0, 3, 'ko', markersize=12, markeredgewidth=2)
ax1.annotate('A (ρ=-2)', (0, 3), textcoords="offset points", xytext=(10, 5),
             fontsize=10, fontweight='bold', color='black')
ax1.plot(3, 0, 'ks', markersize=12, markeredgewidth=2)
ax1.annotate('B (ρ=1)', (3, 0), textcoords="offset points", xytext=(10, 5),
             fontsize=10, fontweight='bold', color='black')

plt.colorbar(im1, ax=ax1, label='Density ρ', shrink=0.8)

# Panel 2: Density for d₁ = [[1],[-1]] (symmetric — no separation!)
ax2 = axes[1]
density_map_sym = np.zeros((n, n))
for f0 in range(n):
    for f1 in range(n):
        # d₁[0,0] = 1, d₁[1,0] = -1, both nonzero
        # density = (f0 - 2) + (f1 - 2) = f0 + f1 - 4
        density_map_sym[f1, f0] = f0 + f1 - 2 * filt2_val

im2 = ax2.imshow(density_map_sym, cmap='RdBu_r', origin='lower', aspect='equal',
                  vmin=-4, vmax=10)
ax2.set_xlabel('filt₁[0]', fontsize=11)
ax2.set_ylabel('filt₁[1]', fontsize=11)
ax2.set_title('Density for d₁ = [[1],[-1]]\n(symmetric → no separation)', fontsize=12, fontweight='bold')

# Mark swapped points — they have the same density!
ax2.plot(0, 1, 'ko', markersize=12, markeredgewidth=2)
ax2.annotate('(0,1): ρ=-3', (0, 1), textcoords="offset points", xytext=(10, 5),
             fontsize=9, fontweight='bold')
ax2.plot(1, 0, 'ks', markersize=12, markeredgewidth=2)
ax2.annotate('(1,0): ρ=-3', (1, 0), textcoords="offset points", xytext=(10, 5),
             fontsize=9, fontweight='bold')

# Draw the anti-diagonal (constant density lines)
for d_val in range(-2, 8, 2):
    xs = np.linspace(0, n-1, 100)
    ys = d_val + 2 * filt2_val - xs
    mask = (ys >= 0) & (ys < n)
    if mask.any():
        ax2.plot(xs[mask], ys[mask], 'k-', alpha=0.2, linewidth=0.5)

plt.colorbar(im2, ax=ax2, label='Density ρ', shrink=0.8)

# Panel 3: Arithmetic filtration levels
ax3 = axes[2]
numbers = list(range(1, 61))
omega_vals = []
for nn in numbers:
    count = 0
    temp = nn
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    omega_vals.append(count)

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#795548']
for nn, omega in zip(numbers, omega_vals):
    c = colors[min(omega, len(colors)-1)]
    ax3.bar(nn, omega, color=c, edgecolor='white', linewidth=0.3)

ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Ω(n) = prime factorization length', fontsize=11)
ax3.set_title('Arithmetic Filtration\n(Number Theory Bridge)', fontsize=12, fontweight='bold')

# Custom legend
legend_items = [
    mpatches.Patch(color=colors[0], label='Ω=0 (n=1)'),
    mpatches.Patch(color=colors[1], label='Ω=1 (primes)'),
    mpatches.Patch(color=colors[2], label='Ω=2 (semiprimes)'),
    mpatches.Patch(color=colors[3], label='Ω=3'),
    mpatches.Patch(color=colors[4], label='Ω=4'),
    mpatches.Patch(color=colors[5], label='Ω≥5'),
]
ax3.legend(handles=legend_items, fontsize=8, loc='upper left')

plt.tight_layout()
plt.savefig('filtration_density_separation.png', dpi=150, bbox_inches='tight')
print("Saved: filtration_density_separation.png")
