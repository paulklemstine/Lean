"""
Visualization: Shadow Complexity Heatmap

Displays a heatmap of shadow complexity for subsets of {0,1}^n
organized by support size and structural properties.
Shows how shadow complexity varies across different polynomial supports.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Set, Tuple, List
import math

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def shadow_complexity(S: Set[MultiIndex]) -> int:
    return sum(shadow_profile(S))


# Generate all subsets of {0,1}^4 by size
n = 4
all_vecs = []
for bits in range(2 ** n):
    all_vecs.append(tuple((bits >> i) & 1 for i in range(n)))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Shadow complexity distribution by support size
ax = axes[0]
size_to_complexities = {}
for size in range(1, 2 ** n + 1):
    complexities = []
    # Sample subsets of given size (enumerate for small n)
    count = 0
    for subset in combinations(range(2 ** n), size):
        S = {all_vecs[i] for i in subset}
        complexities.append(shadow_complexity(S))
        count += 1
        if count >= 200:  # Cap for larger sizes
            break
    size_to_complexities[size] = complexities

positions = []
data = []
labels = []
for size in range(1, min(2 ** n + 1, 12)):
    if size in size_to_complexities and size_to_complexities[size]:
        positions.append(size)
        data.append(size_to_complexities[size])
        labels.append(str(size))

bp = ax.boxplot(data, positions=positions, widths=0.6, patch_artist=True)
for patch, pos in zip(bp['boxes'], positions):
    shade = pos / max(positions)
    patch.set_facecolor(plt.cm.viridis(shade))
    patch.set_alpha(0.7)

ax.set_xlabel('Support size |S|')
ax.set_ylabel('Shadow complexity Σ(S)')
ax.set_title(f'Shadow Complexity Distribution (n={n})')

# Add theoretical bounds
sizes = range(1, 2 ** n + 1)
# Upper bound: each element contributes at most n+1 to shadow complexity
upper = [(n + 1) * s for s in sizes]
ax.plot(sizes, upper, 'r--', alpha=0.5, label=f'Upper: (n+1)·|S|')
ax.legend()

# Plot 2: Heatmap of shadow profiles by support size
ax = axes[1]

# Collect average profiles by support size
max_depth = n + 1
avg_profiles = np.zeros((2 ** n, max_depth))
counts = np.zeros(2 ** n)

for size in range(1, 2 ** n + 1):
    count = 0
    for subset in combinations(range(2 ** n), size):
        S = {all_vecs[i] for i in subset}
        prof = shadow_profile(S)
        for k in range(min(len(prof), max_depth)):
            avg_profiles[size - 1, k] += prof[k]
        count += 1
        if count >= 100:
            break
    if count > 0:
        avg_profiles[size - 1] /= count
    counts[size - 1] = count

# Normalize rows for visualization
norm_profiles = np.zeros_like(avg_profiles)
for i in range(avg_profiles.shape[0]):
    row_sum = avg_profiles[i].sum()
    if row_sum > 0:
        norm_profiles[i] = avg_profiles[i] / row_sum

im = ax.imshow(norm_profiles.T, aspect='auto', cmap='YlOrRd',
               origin='lower', interpolation='nearest')
ax.set_xlabel('Support size |S|')
ax.set_ylabel('Shadow depth k')
ax.set_title(f'Normalized Shadow Profile Heatmap (n={n})')
plt.colorbar(im, ax=ax, label='Normalized profile weight')

# Mark specific polynomials
# e_k polynomials
for k in range(1, n + 1):
    size = math.comb(n, k)
    ax.plot(size - 1, k, 'w*', markersize=12, markeredgecolor='black')
    ax.annotate(f'e_{k}', (size - 1, k), color='white',
                fontsize=7, ha='center', va='bottom',
                fontweight='bold',
                path_effects=[
                    __import__('matplotlib.patheffects', fromlist=['withStroke']).withStroke(
                        linewidth=2, foreground='black'
                    )
                ])

plt.tight_layout()
plt.savefig('complexity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved complexity_heatmap.png")
