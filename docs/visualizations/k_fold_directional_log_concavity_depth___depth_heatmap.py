"""
Visualization 1: Lorentzian Depth Heatmap

Visualizes the k-fold directional log-concavity depth across
different valuated matroids, showing how the depth hierarchy
distinguishes matroids with different curvature profiles.

The heatmap shows the minimum LC ratio f(m+e)^2/(f(m)*f(m+2e))
at each depth level for different matroid families.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial
from itertools import product as cartesian_product


def multinomial_coeff(m, degree):
    """Multinomial coefficient d! / prod(m_i!)."""
    if any(x < 0 for x in m) or sum(m) != degree:
        return 0.0
    return factorial(degree) / np.prod([factorial(int(x)) for x in m])


def ratio_transform_fn(f, direction, dim):
    """Return the ratio transform R_i f."""
    def rf(m):
        shifted = list(m)
        shifted[direction] += 1
        denom = f(tuple(m))
        if abs(denom) < 1e-15:
            return 0.0
        return f(tuple(shifted)) / denom
    return rf


def compute_min_lc_ratio(f, direction, points, dim):
    """Compute min f(m+e)^2/(f(m)*f(m+2e)) over test points."""
    min_ratio = float('inf')
    for m in points:
        e = [0] * dim
        e[direction] = 1
        m1 = tuple(m[j] + e[j] for j in range(dim))
        m2 = tuple(m[j] + 2*e[j] for j in range(dim))
        fm = f(tuple(m))
        fm1 = f(m1)
        fm2 = f(m2)
        if fm > 1e-15 and fm2 > 1e-15 and fm1 > 1e-15:
            ratio = fm1**2 / (fm * fm2)
            min_ratio = min(min_ratio, ratio)
    return min_ratio if min_ratio < float('inf') else 0.0


def compute_depth_profile(f, dim, max_depth=6, max_coord=6):
    """Compute min LC ratios at each depth level."""
    points = list(cartesian_product(range(max_coord), repeat=dim))
    ratios = []
    current_f = f
    
    for k in range(max_depth):
        min_r = float('inf')
        for i in range(dim):
            r = compute_min_lc_ratio(current_f, i, points, dim)
            min_r = min(min_r, r)
        ratios.append(min_r)
        current_f = ratio_transform_fn(current_f, 0, dim)
    
    return ratios


# Generate data for different matroid families
families = {}
dims = [2, 3]
degrees = [3, 4, 5, 6]

for n in dims:
    for d in degrees:
        label = f"Unif({n},{d})"
        f = lambda m, d=d: multinomial_coeff(m, d)
        profile = compute_depth_profile(f, n, max_depth=6, max_coord=d+2)
        families[label] = profile

# Add weighted variants
for alpha in [0.5, 1.0, 2.0]:
    label = f"Wt({alpha:.1f})"
    def weighted_fn(m, alpha=alpha):
        d = 4
        c = multinomial_coeff(m, d)
        if c == 0:
            return 0.0
        return c * (alpha ** m[0])
    
    profile = compute_depth_profile(weighted_fn, 2, max_depth=6, max_coord=7)
    families[label] = profile

# Create heatmap
labels = list(families.keys())
data = np.array([families[l] for l in labels])

# Clip for visualization
data_clipped = np.clip(data, 0, 5)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
im = ax1.imshow(data_clipped, aspect='auto', cmap='RdYlGn', vmin=0, vmax=3)
ax1.set_xlabel('Depth Level k', fontsize=12)
ax1.set_ylabel('Matroid Family', fontsize=12)
ax1.set_yticks(range(len(labels)))
ax1.set_yticklabels(labels, fontsize=9)
ax1.set_xticks(range(6))
ax1.set_xticklabels([f'k={i}' for i in range(6)])
ax1.set_title('Min LC Ratio at Each Depth Level\n(Green ≥ 1 means log-concave)', fontsize=13)
plt.colorbar(im, ax=ax1, label='min f(m+e)²/(f(m)·f(m+2e))')

# Line plot
for label in labels[:6]:
    profile = families[label]
    ax2.plot(range(len(profile)), profile, 'o-', label=label, markersize=5)

ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='LC threshold')
ax2.set_xlabel('Depth Level k', fontsize=12)
ax2.set_ylabel('Min LC Ratio', fontsize=12)
ax2.set_title('Depth Profile: How LC Ratio\nDecays with Depth', fontsize=13)
ax2.legend(fontsize=8, loc='upper right')
ax2.set_ylim(0, 4)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('depth_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved depth_heatmap.png")
