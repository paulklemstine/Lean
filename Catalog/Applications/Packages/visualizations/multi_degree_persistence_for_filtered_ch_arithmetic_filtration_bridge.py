"""
Visualization 3: Arithmetic Filtration — Number Theory Bridge

Shows the connection between prime factorization and filtration levels.
Demonstrates Ω(a·b) = Ω(a) + Ω(b) visually and shows how the arithmetic
filtration creates a natural hierarchy on the integers.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def omega(n):
    """Compute Ω(n) = number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Ω values as a number line with colored levels
ax1 = axes[0, 0]
numbers = list(range(1, 51))
omega_vals = [omega(n) for n in numbers]
max_omega = max(omega_vals)

colors_map = {
    0: '#9E9E9E',   # 1
    1: '#2196F3',   # primes
    2: '#4CAF50',   # semiprimes
    3: '#FF9800',   # 3 factors
    4: '#F44336',   # 4 factors
    5: '#9C27B0',   # 5 factors
}

for n, ov in zip(numbers, omega_vals):
    color = colors_map.get(ov, '#795548')
    ax1.bar(n, 1, bottom=ov - 0.5, color=color, edgecolor='white', linewidth=0.3, width=0.8)
    if n <= 30:
        ax1.text(n, ov, str(n), ha='center', va='center', fontsize=6, fontweight='bold')

ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('Ω(n)', fontsize=11)
ax1.set_title('Integers Stratified by Factorization Length', fontsize=12, fontweight='bold')
ax1.set_yticks(range(max_omega + 1))
ax1.set_yticklabels([f'Ω={k}' for k in range(max_omega + 1)])
ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
ax1.axhline(y=1.5, color='gray', linestyle=':', alpha=0.3)
ax1.axhline(y=2.5, color='gray', linestyle=':', alpha=0.3)

legend_items = [
    mpatches.Patch(color=colors_map[0], label='Ω=0: {1}'),
    mpatches.Patch(color=colors_map[1], label='Ω=1: primes'),
    mpatches.Patch(color=colors_map[2], label='Ω=2: semiprimes'),
    mpatches.Patch(color=colors_map[3], label='Ω=3'),
    mpatches.Patch(color=colors_map[4], label='Ω=4'),
    mpatches.Patch(color=colors_map[5], label='Ω=5'),
]
ax1.legend(handles=legend_items, fontsize=8, loc='upper left')

# Panel 2: Multiplicativity visualization
ax2 = axes[0, 1]
pairs = [(2, 3), (2, 5), (3, 4), (2, 6), (4, 3), (3, 5),
         (2, 8), (4, 5), (3, 7), (6, 5), (4, 6), (2, 15)]

x_vals = [omega(a) + omega(b) for a, b in pairs]
y_vals = [omega(a * b) for a, b in pairs]

ax2.scatter(x_vals, y_vals, c='#2196F3', s=100, edgecolors='black', linewidths=1.5, zorder=5)

# Perfect line
max_val = max(max(x_vals), max(y_vals)) + 1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='Ω(ab) = Ω(a) + Ω(b)')

# Annotate some points
for (a, b), x, y in zip(pairs[:6], x_vals[:6], y_vals[:6]):
    ax2.annotate(f'{a}×{b}', (x, y), textcoords="offset points",
                xytext=(8, 5), fontsize=8, color='gray')

ax2.set_xlabel('Ω(a) + Ω(b)', fontsize=11)
ax2.set_ylabel('Ω(a·b)', fontsize=11)
ax2.set_title('Multiplicativity: Ω(a·b) = Ω(a) + Ω(b)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)

# Panel 3: Filtration as a persistence diagram metaphor
ax3 = axes[1, 0]

# Show how numbers "enter" the filtration at their Ω level
levels = {}
for n in range(1, 61):
    ov = omega(n)
    if ov not in levels:
        levels[ov] = []
    levels[ov].append(n)

max_show = 5
bar_height = 0.6
for level in sorted(levels.keys()):
    nums = levels[level][:12]  # Show at most 12 per level
    for idx, n in enumerate(nums):
        color = colors_map.get(level, '#795548')
        ax3.barh(level, 0.8, left=idx, height=bar_height, color=color,
                edgecolor='white', linewidth=0.5)
        ax3.text(idx + 0.4, level, str(n), ha='center', va='center',
                fontsize=7, fontweight='bold')

ax3.set_ylabel('Filtration Level Ω', fontsize=11)
ax3.set_xlabel('Count (first elements at each level)', fontsize=11)
ax3.set_title('Arithmetic Filtration: Integers Enter by Complexity', fontsize=12, fontweight='bold')
ax3.set_yticks(range(max_show + 1))

# Panel 4: Density of primes at each level
ax4 = axes[1, 1]
max_n = 500
level_counts = {}
for n in range(1, max_n + 1):
    ov = omega(n)
    level_counts[ov] = level_counts.get(ov, 0) + 1

levels_sorted = sorted(level_counts.keys())
counts = [level_counts[l] for l in levels_sorted]
colors_bars = [colors_map.get(l, '#795548') for l in levels_sorted]

bars = ax4.bar(levels_sorted, counts, color=colors_bars, edgecolor='black', linewidth=0.5)

for bar, count in zip(bars, counts):
    ax4.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 3,
            str(count), ha='center', va='bottom', fontsize=9, fontweight='bold')

ax4.set_xlabel('Ω level', fontsize=11)
ax4.set_ylabel(f'Count of n ≤ {max_n} at level', fontsize=11)
ax4.set_title(f'Distribution of Ω(n) for n ≤ {max_n}', fontsize=12, fontweight='bold')

# Add annotation about the peak
peak_level = levels_sorted[np.argmax(counts)]
ax4.annotate(f'Peak at Ω={peak_level}\n(most numbers are\nmoderately composite)',
            xy=(peak_level, max(counts)), xytext=(peak_level + 1.5, max(counts) - 20),
            arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
            fontsize=9, color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('The Arithmetic Filtration: Bridging Number Theory and Persistent Homology',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('arithmetic_filtration_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: arithmetic_filtration_bridge.png")
