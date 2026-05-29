"""
Visualization 3: Tropical Potential Surface

Plots the tropical potential v = -log f as a 3D surface over the degree slice,
showing the supermodularity (convexity) that depth ≥ 1 guarantees.
Compares a depth ≥ 1 function (multinomial) with a non-log-concave
perturbation to visually show the difference.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from typing import Dict, Tuple, List

def multinomial_3d(d: int) -> Dict[Tuple[int, int, int], float]:
    result = {}
    for i in range(d + 1):
        for j in range(d + 1 - i):
            k = d - i - j
            val = math.factorial(d) / (math.factorial(i) * math.factorial(j) * math.factorial(k))
            result[(i, j, k)] = float(val)
    return result

def perturbed_3d(d: int, eps: float) -> Dict[Tuple[int, int, int], float]:
    result = {}
    for i in range(d + 1):
        for j in range(d + 1 - i):
            k = d - i - j
            val = math.factorial(d) / (math.factorial(i) * math.factorial(j) * math.factorial(k))
            # Add perturbation that breaks supermodularity
            val *= (1.0 + eps * math.sin(i * 2.5) * math.cos(j * 1.7))
            result[(i, j, k)] = max(float(val), 0.01)
    return result

d = 6

fig, axes = plt.subplots(1, 2, figsize=(14, 6), subplot_kw={'projection': '3d'})

for idx, (name, f_fn) in enumerate([
    ("Multinomial (depth ≥ 1)", lambda: multinomial_3d(d)),
    ("Perturbed (depth may fail)", lambda: perturbed_3d(d, 0.8)),
]):
    f = f_fn()
    ax = axes[idx]

    # Project to (i, j) plane (k = d - i - j is determined)
    is_list = []
    js_list = []
    vs_list = []

    for (i, j, k), val in f.items():
        if val > 0:
            is_list.append(i)
            js_list.append(j)
            vs_list.append(-math.log(val))

    i_arr = np.array(is_list)
    j_arr = np.array(js_list)
    v_arr = np.array(vs_list)

    # Create triangulated surface
    ax.plot_trisurf(i_arr, j_arr, v_arr, cmap='coolwarm', alpha=0.85,
                     edgecolor='gray', linewidth=0.3)

    ax.set_xlabel('i (direction 1)', fontsize=10)
    ax.set_ylabel('j (direction 2)', fontsize=10)
    ax.set_zlabel('-log f(i,j,d-i-j)', fontsize=10)
    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.view_init(elev=25, azim=-60)

fig.suptitle(f'Tropical Potential Surface v = -log f on Degree Slice (d={d})\n'
             'Supermodularity ↔ "bowl-shaped" surface (convex mixed partials)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_surface.png', dpi=150, bbox_inches='tight')
print("Saved tropical_surface.png")
