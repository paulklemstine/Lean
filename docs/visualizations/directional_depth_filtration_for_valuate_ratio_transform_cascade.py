"""
Visualization 2: Ratio Transform Cascade

Shows how the ratio transform Rᵢ acts as a "discrete derivative" that peels
away layers of log-concavity. Plots the original function and successive
ratio transforms, showing how the shape degrades at each level.
For a depth-k function, the cascade remains well-behaved for k levels.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from typing import Dict, Tuple, List

MultiIndex = Tuple[int, ...]

def degree_slice_1d(d: int) -> List[Tuple[int, int]]:
    """Degree-d multi-indices in 2 variables."""
    return [(k, d - k) for k in range(d + 1)]

def multinomial_2d(d: int) -> Dict[Tuple[int, int], float]:
    result = {}
    for k in range(d + 1):
        result[(k, d - k)] = math.factorial(d) / (math.factorial(k) * math.factorial(d - k))
    return result

def ratio_transform_dir0(f: Dict[Tuple[int, int], float]) -> Dict[Tuple[int, int], float]:
    """Ratio transform in direction 0: R₀f(k, l) = f(k+1, l) / f(k, l)."""
    result = {}
    for (k, l), v in f.items():
        if abs(v) > 1e-15:
            result[(k, l)] = f.get((k + 1, l), 0.0) / v
    return result

def product_2d(weights, d):
    result = {}
    for k in range(d + 1):
        result[(k, d - k)] = weights[0]**k * weights[1]**(d - k)
    return result

# Generate data
d = 8
f_multi = multinomial_2d(d)
f_prod = product_2d([1.0, 2.0], d)

fig, axes = plt.subplots(2, 4, figsize=(16, 8))

for row, (name, f0) in enumerate([("Multinomial C(8,k)", f_multi),
                                    ("Product 1^k · 2^(8-k)", f_prod)]):
    f = f0.copy()
    for col in range(4):
        ax = axes[row, col]
        xs = sorted(f.keys())
        ys = [f[x] for x in xs]
        x_vals = [x[0] for x in xs]

        color = plt.cm.viridis(col / 4)
        ax.bar(x_vals, ys, color=color, alpha=0.8, edgecolor='black', linewidth=0.5)
        ax.set_xlabel('k (first index)')

        if col == 0:
            ax.set_ylabel(f'{name}\nValue')
            ax.set_title('Original f')
        else:
            ax.set_title(f'R₀{"R₀" * (col-1)}f  (level {col})')

        # Check log-concavity of this level
        vals = [f.get((k, d - k), 0.0) for k in range(d + 1)]
        is_lc = True
        for i in range(1, len(vals) - 1):
            if vals[i] > 0 and vals[i-1] >= 0 and vals[i+1] >= 0:
                if vals[i]**2 < vals[i-1] * vals[i+1] - 1e-10:
                    is_lc = False
                    break

        status = "✓ LC" if is_lc else "✗ not LC"
        ax.annotate(status, xy=(0.95, 0.95), xycoords='axes fraction',
                    ha='right', va='top', fontsize=10,
                    color='green' if is_lc else 'red',
                    fontweight='bold',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

        ax.grid(axis='y', alpha=0.3)

        # Apply ratio transform for next column
        f = ratio_transform_dir0(f)
        f = {m: v for m, v in f.items() if abs(v) > 1e-15}

fig.suptitle('Ratio Transform Cascade: Peeling Layers of Log-Concavity\n'
             'Each column shows the function after one more ratio transform R₀',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('ratio_cascade.png', dpi=150, bbox_inches='tight')
print("Saved ratio_cascade.png")
