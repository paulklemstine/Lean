"""
Visualization 1: Depth Heatmap across Function Families

Visualizes the directional depth of various function families as a heatmap,
showing how depth varies with dimension (n) and degree (d). This reveals
the Depth Dichotomy: most natural families cluster at depth 1 or high depth,
with few intermediate values.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from typing import Dict, Tuple, List, Optional

MultiIndex = Tuple[int, ...]

def basis_vector(n: int, i: int) -> Tuple[int, ...]:
    v = [0] * n
    v[i] = 1
    return tuple(v)

def add_mi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    return tuple(x + y for x, y in zip(a, b))

def degree_slice(n: int, d: int) -> List[MultiIndex]:
    if n == 0: return [()] if d == 0 else []
    if n == 1: return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result

def check_dlc(f: Dict[MultiIndex, float], n: int, tol: float = -1e-10):
    for m in f:
        for i in range(n):
            ei = basis_vector(n, i)
            mi = add_mi(m, ei)
            for j in range(i, n):
                ej = basis_vector(n, j)
                mj = add_mi(m, ej)
                mij = add_mi(mi, ej)
                if f.get(mi, 0.0)*f.get(mj, 0.0) - f.get(m, 0.0)*f.get(mij, 0.0) < tol:
                    return False
    return True

def ratio_transform(f, i, n):
    ei = basis_vector(n, i)
    return {m: (f.get(add_mi(m, ei), 0.0)/fm if abs(fm) > 1e-15 else 0.0) for m, fm in f.items()}

def compute_depth(f, n, max_depth=10, tol=-1e-10):
    if max_depth == 0: return 0
    if not check_dlc(f, n, tol): return 0
    ms = max_depth - 1
    for i in range(n):
        ri = {m: v for m, v in ratio_transform(f, i, n).items() if abs(v) > 1e-15}
        if not ri: ms = 0; break
        ms = min(ms, compute_depth(ri, n, max_depth-1, tol))
        if ms == 0: break
    return 1 + ms

def multinomial(n, d):
    result = {}
    for m in degree_slice(n, d):
        val = math.factorial(d)
        for mi in m: val /= math.factorial(mi)
        result[m] = float(val)
    return result

def product_val(weights, d):
    n = len(weights)
    result = {}
    for m in degree_slice(n, d):
        val = 1.0
        for i in range(n): val *= weights[i]**m[i]
        result[m] = val
    return result

def uniform_matroid(n, r):
    result = {}
    for m in degree_slice(n, r):
        if all(mi <= 1 for mi in m):
            result[m] = 1.0
    return result

# Compute depth data
families = {
    'Multinomial': lambda n, d: multinomial(n, d),
    'Product': lambda n, d: product_val([1.0 + 0.5*i for i in range(n)], d),
    'Uniform': lambda n, d: uniform_matroid(n, d) if d <= n else {},
}

ns = range(2, 6)
ds = range(2, 7)
max_d = 5

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, (name, family_fn) in enumerate(families.items()):
    data = np.zeros((len(list(ns)), len(list(ds))))
    for ni, n in enumerate(ns):
        for di, d in enumerate(ds):
            f = family_fn(n, d)
            if f:
                depth = compute_depth(f, n, max_depth=max_d)
                data[ni, di] = depth
            else:
                data[ni, di] = -1  # invalid

    ax = axes[idx]
    im = ax.imshow(data, cmap='YlOrRd', aspect='auto', vmin=0, vmax=max_d,
                    interpolation='nearest')
    ax.set_xticks(range(len(list(ds))))
    ax.set_xticklabels([str(d) for d in ds])
    ax.set_yticks(range(len(list(ns))))
    ax.set_yticklabels([str(n) for n in ns])
    ax.set_xlabel('Degree d')
    ax.set_ylabel('Dimension n')
    ax.set_title(f'{name}\nCoefficients')

    # Annotate cells
    for ni in range(data.shape[0]):
        for di in range(data.shape[1]):
            val = int(data[ni, di])
            if val >= 0:
                label = f'≥{val}' if val == max_d else str(val)
                color = 'white' if val >= 3 else 'black'
                ax.text(di, ni, label, ha='center', va='center',
                        fontsize=11, fontweight='bold', color=color)

fig.suptitle('Directional Depth across Function Families\n'
             '(Higher depth = stronger log-concavity structure)',
             fontsize=14, fontweight='bold')
plt.colorbar(im, ax=axes, label='Depth', shrink=0.8)
plt.tight_layout()
plt.savefig('depth_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved depth_heatmap.png")
