"""
Visualization: Depth Filtration Heatmap

Visualizes the directional depth of weight functions across parameter families,
showing how depth varies with the parameters of the weight function. The heatmap
reveals the boundary between finite and infinite depth regions, illustrating the
Depth Dichotomy Conjecture.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math
from typing import Dict, Tuple, List

Multiset = Tuple[int, ...]
WeightFn = Dict[Multiset, float]

def degree_slice(n, d):
    if n == 0: return [()] if d == 0 else []
    if n == 1: return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result

def unit_vector(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def add_multisets(m, e):
    return tuple(a + b for a, b in zip(m, e))

def lookup(wf, m):
    return wf.get(m, 0.0)

def make_weight_fn(f, n, max_deg):
    wf = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            wf[m] = f(m)
    return wf

def is_directional_log_concave(wf, n):
    for m, fm in wf.items():
        if fm <= 1e-15: continue
        for i in range(n):
            ei = unit_vector(n, i)
            m1 = add_multisets(m, ei)
            m2 = add_multisets(m1, ei)
            f1 = lookup(wf, m1)
            f2 = lookup(wf, m2)
            if fm * f2 > f1 * f1 + 1e-12:
                return False
    return True

def ratio_transform_fn(wf, n, i):
    result = {}
    ei = unit_vector(n, i)
    for m, fm in wf.items():
        if abs(fm) > 1e-15:
            result[m] = lookup(wf, add_multisets(m, ei)) / fm
    return result

def directional_depth_at_least(wf, n, k):
    if k == 0: return True
    if not is_directional_log_concave(wf, n): return False
    for i in range(n):
        ri = ratio_transform_fn(wf, n, i)
        if not directional_depth_at_least(ri, n, k - 1):
            return False
    return True

def compute_depth(wf, n, max_k=6):
    for k in range(max_k + 1):
        if not directional_depth_at_least(wf, n, k):
            return k - 1
    return max_k

# ── Main visualization ────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Depth of f(m) = exp(-a·m₁² - b·m₂²) as a,b vary
n_dim = 2
max_deg = 6
a_vals = np.linspace(0.1, 3.0, 15)
b_vals = np.linspace(0.1, 3.0, 15)
depth_grid = np.zeros((len(b_vals), len(a_vals)))

for ia, a in enumerate(a_vals):
    for ib, b in enumerate(b_vals):
        def f(m, a=a, b=b):
            return math.exp(-a * m[0]**2 - b * m[1]**2)
        wf = make_weight_fn(f, n_dim, max_deg)
        depth_grid[ib, ia] = compute_depth(wf, n_dim, max_k=5)

im1 = axes[0].imshow(depth_grid, extent=[a_vals[0], a_vals[-1], b_vals[0], b_vals[-1]],
                       origin='lower', cmap='viridis', aspect='auto', vmin=0, vmax=5)
axes[0].set_xlabel('Parameter a', fontsize=12)
axes[0].set_ylabel('Parameter b', fontsize=12)
axes[0].set_title('Depth of exp(-a·m₁² - b·m₂²)', fontsize=13)
plt.colorbar(im1, ax=axes[0], label='Depth')

# Panel 2: Depth of mixture f(m) = c·exp(-m₁²) + (1-c)·exp(-m₂²)
c_vals = np.linspace(0.01, 0.99, 20)
sigma_vals = np.linspace(0.3, 3.0, 15)
depth_grid2 = np.zeros((len(sigma_vals), len(c_vals)))

for ic, c in enumerate(c_vals):
    for isig, sig in enumerate(sigma_vals):
        def f(m, c=c, sig=sig):
            return c * math.exp(-m[0]**2 / (2*sig**2)) + (1-c) * math.exp(-m[1]**2 / (2*sig**2))
        wf = make_weight_fn(f, n_dim, max_deg)
        depth_grid2[isig, ic] = compute_depth(wf, n_dim, max_k=5)

im2 = axes[1].imshow(depth_grid2, extent=[c_vals[0], c_vals[-1], sigma_vals[0], sigma_vals[-1]],
                       origin='lower', cmap='plasma', aspect='auto', vmin=0, vmax=5)
axes[1].set_xlabel('Mixture weight c', fontsize=12)
axes[1].set_ylabel('Width σ', fontsize=12)
axes[1].set_title('Depth of c·G₁ + (1-c)·G₂', fontsize=13)
plt.colorbar(im2, ax=axes[1], label='Depth')

# Panel 3: Ratio transform decay along direction 0
fig3_data = []
for sigma in [0.5, 1.0, 2.0, 3.0]:
    def f(m, s=sigma):
        return math.exp(-sum(x**2 for x in m) / (2*s**2))
    wf = make_weight_fn(f, 2, 10)
    ratios = []
    for k in range(8):
        m = (k, 0)
        fm = lookup(wf, m)
        fm1 = lookup(wf, (k+1, 0))
        if fm > 1e-15:
            ratios.append(fm1 / fm)
        else:
            ratios.append(0)
    fig3_data.append((sigma, ratios))

for sigma, ratios in fig3_data:
    axes[2].plot(range(len(ratios)), ratios, 'o-', label=f'σ={sigma}', markersize=5)
axes[2].set_xlabel('Position m₁', fontsize=12)
axes[2].set_ylabel('R₀f(m₁, 0)', fontsize=12)
axes[2].set_title('Ratio Transform R₀f (Gaussian)', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].set_yscale('log')
axes[2].grid(True, alpha=0.3)

plt.suptitle('Directional Depth Filtration: Parameter Landscape', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_depth_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_heatmap.png")
