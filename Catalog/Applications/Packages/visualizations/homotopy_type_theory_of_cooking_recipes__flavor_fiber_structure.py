"""
Visualization 2: Flavor Fibers — Preimages of the Flavor Map
=============================================================
Shows how a linear flavor map F: Recipe(4,3) → R^2 partitions
the 81-recipe space into fibers. Each fiber is a set of recipes
that produce the same flavor profile. Recipes are plotted in
flavor space (R^2) and colored by fiber size.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict

def hamming_distance(r1, r2):
    return int(np.sum(np.array(r1) != np.array(r2)))

# Parameters
n, m, d = 4, 3, 2
np.random.seed(42)

# Generate all recipes
recipes = np.array(list(product(range(m), repeat=n)))

# Linear flavor map
W = np.array([[1.2, -0.5, 0.8, -0.3],
              [0.4, 0.9, -0.6, 1.1]])
b = np.array([0.5, -0.2])

# Compute flavor profiles
flavors = np.array([W @ r.astype(float) + b for r in recipes])

# Group into fibers
tolerance = 1e-6
fibers = defaultdict(list)
for i, f in enumerate(flavors):
    key = tuple(np.round(f / tolerance) * tolerance)
    fibers[key].append(i)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: scatter plot colored by fiber size
ax = axes[0]
fiber_sizes = []
for i in range(len(recipes)):
    f = flavors[i]
    key = tuple(np.round(f / tolerance) * tolerance)
    fiber_sizes.append(len(fibers[key]))

scatter = ax.scatter(flavors[:, 0], flavors[:, 1],
                     c=fiber_sizes, cmap='viridis', s=50,
                     edgecolors='black', linewidth=0.5, alpha=0.8)
cbar = plt.colorbar(scatter, ax=ax)
cbar.set_label('Fiber size (recipes with same flavor)', fontsize=10)
ax.set_xlabel('Flavor dimension 1 (sweet–savory axis)', fontsize=11)
ax.set_ylabel('Flavor dimension 2 (mild–spicy axis)', fontsize=11)
ax.set_title(f'Flavor Map: {m}^{n} = {m**n} Recipes → R²\n'
             f'{len(fibers)} distinct flavor profiles', fontsize=12)
ax.grid(True, alpha=0.3)

# Right: histogram of fiber sizes
ax2 = axes[1]
sizes = [len(v) for v in fibers.values()]
ax2.hist(sizes, bins=range(1, max(sizes)+2), edgecolor='black',
         color='steelblue', alpha=0.8, align='left')
ax2.set_xlabel('Fiber size', fontsize=11)
ax2.set_ylabel('Number of fibers', fontsize=11)
ax2.set_title(f'Distribution of Fiber Sizes\n'
              f'Max fiber size = {max(sizes)}, '
              f'Conjectured bound = m^(n-d) = {m**(n-d)}', fontsize=12)
ax2.axvline(x=m**(n-d), color='red', linestyle='--', linewidth=2,
            label=f'Conjectured bound = {m**(n-d)}')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle('Culinary Homotopy: Fiber Structure of the Flavor Map',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_flavor_fibers.png', dpi=150, bbox_inches='tight')
print("Saved viz_flavor_fibers.png")
