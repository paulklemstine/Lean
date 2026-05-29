#!/usr/bin/env python3
"""
Visualization: The Comedy Polytope

Visualizes the set of achievable (tension, humor, arc) triples.
The comedy polytope is exactly the set of valid triangle side-lengths.
Points inside satisfy all three triangle inequalities; points outside
correspond to impossible jokes.

This heatmap shows, for fixed arc = 5, which (tension, humor) pairs
are achievable. The achievable region is a triangle in (t, h) space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12


def is_valid_triangle(t, h, a):
    """Check if (t, h, a) satisfies all triangle inequalities."""
    return (t >= 0) & (h >= 0) & (a >= 0) & \
           (a <= t + h) & (h <= a + t) & (t <= a + h)


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Comedy Polytope cross-section at fixed arc
arc = 5.0
t_vals = np.linspace(0, 10, 500)
h_vals = np.linspace(0, 10, 500)
T, H = np.meshgrid(t_vals, h_vals)
valid = is_valid_triangle(T, H, arc).astype(float)

# Color by humor density (humor / arc) within valid region
humor_density = np.where(valid > 0, H / arc, np.nan)

ax = axes[0]
im = ax.imshow(humor_density, extent=[0, 10, 0, 10], origin='lower',
               cmap='RdYlGn', vmin=0, vmax=1, aspect='equal')
ax.set_xlabel('Tension')
ax.set_ylabel('Humor')
ax.set_title(f'Comedy Polytope\n(arc = {arc}, color = humor density)')
plt.colorbar(im, ax=ax, label='Humor Density (H/A)')

# Draw the boundary
ax.plot([0, arc], [arc, 0], 'k-', linewidth=2, label='a = t + h')
ax.plot([arc, 10], [0, 10 - arc], 'k--', linewidth=2, label='|t - h| = a')
ax.plot([0, 10 - arc], [arc, 10], 'k--', linewidth=2)
ax.legend(loc='upper right', fontsize=9)

# Plot 2: Random jokes colored by humor
ax = axes[1]
np.random.seed(42)
n_jokes = 200
setups = np.random.randn(n_jokes, 2) * 2
expecteds = setups + np.random.randn(n_jokes, 2) * 1.5
punchlines = setups + np.random.randn(n_jokes, 2) * 3

humors = np.linalg.norm(expecteds - punchlines, axis=1)
tensions = np.linalg.norm(setups - expecteds, axis=1)

scatter = ax.scatter(tensions, humors, c=humors, cmap='hot', s=20, alpha=0.7)
plt.colorbar(scatter, ax=ax, label='Humor Value')
ax.set_xlabel('Tension')
ax.set_ylabel('Humor')
ax.set_title('200 Random Jokes\n(color = humor value)')

# Plot 3: Tropical vs Additive humor
ax = axes[2]
n_sets = 50
set_sizes = np.arange(2, 52)
tropical_ratios = []
for n in set_sizes:
    humors_set = np.random.exponential(2, n)
    tropical = np.max(humors_set)
    additive = np.sum(humors_set)
    average = np.mean(humors_set)
    tropical_ratios.append((average / tropical, tropical / additive))

avg_ratios, trop_ratios = zip(*tropical_ratios)
ax.fill_between(set_sizes, 0, 1, alpha=0.1, color='green', label='Possible region')
ax.plot(set_sizes, avg_ratios, 'b-', linewidth=2, label='average/tropical')
ax.plot(set_sizes, trop_ratios, 'r-', linewidth=2, label='tropical/total')
ax.set_xlabel('Number of Jokes in Set')
ax.set_ylabel('Ratio')
ax.set_title('Tropical-Additive Sandwich\n(both ratios ∈ [0, 1])')
ax.legend()
ax.set_ylim(0, 1.1)

plt.tight_layout()
plt.savefig('comedy_polytope.png', dpi=150, bbox_inches='tight')
print("Saved comedy_polytope.png")
