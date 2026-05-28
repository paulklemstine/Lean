"""
Visualization: Depth Comparison Across Families

Compares the directional depth across different weight function families:
Gaussian, geometric, polynomial, and graphical matroid. Shows how the
depth invariant distinguishes between fundamentally different combinatorial
structures.
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

# ── Weight function families ─────────────────────────────────────────

families = {}
n = 2
max_deg = 8

# 1. Gaussian family
for sigma in [0.3, 0.5, 1.0, 1.5, 2.0, 3.0]:
    def f(m, s=sigma):
        return math.exp(-sum(x**2 for x in m) / (2*s**2))
    wf = make_weight_fn(f, n, max_deg)
    families[f'Gaussian σ={sigma}'] = (wf, 'Gaussian')

# 2. Geometric family
for r in [0.3, 0.5, 0.8, 1.0, 1.5, 2.0]:
    def f(m, r=r):
        return r**(m[0] + m[1])
    wf = make_weight_fn(f, n, max_deg)
    families[f'Geometric r={r}'] = (wf, 'Geometric')

# 3. Polynomial: f(m) = (a+1)^{-m₁} * (b+1)^{-m₂} type
for alpha in [0.5, 1.0, 2.0, 3.0, 5.0, 10.0]:
    def f(m, a=alpha):
        return 1.0 / ((m[0] + 1)**a * (m[1] + 1)**a)
    wf = make_weight_fn(f, n, max_deg)
    families[f'Power α={alpha}'] = (wf, 'Power-law')

# 4. Custom mixed
for p in [0.5, 1.0, 2.0, 3.0, 5.0, 8.0]:
    def f(m, p=p):
        return math.exp(-sum(x**p for x in m))
    wf = make_weight_fn(f, n, max_deg)
    families[f'Lp p={p}'] = (wf, 'Lp-norm')

# ── Compute depths ──────────────────────────────────────────────────

results = {}
for name, (wf, family) in families.items():
    depth = compute_depth(wf, n, max_k=5)
    results[name] = (depth, family)

# ── Plot ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Bar chart of depths by family
family_groups = {}
for name, (depth, family) in results.items():
    family_groups.setdefault(family, []).append((name, depth))

colors = {'Gaussian': '#2196F3', 'Geometric': '#4CAF50',
          'Power-law': '#FF9800', 'Lp-norm': '#9C27B0'}

x_pos = 0
ticks = []
tick_labels = []
for family_name, entries in family_groups.items():
    for name, depth in entries:
        bar_color = colors.get(family_name, '#666')
        axes[0].bar(x_pos, depth, color=bar_color, alpha=0.8, edgecolor='black', linewidth=0.5)
        ticks.append(x_pos)
        # Extract parameter from name
        param = name.split('=')[-1] if '=' in name else name
        tick_labels.append(param)
        x_pos += 1
    x_pos += 0.5  # gap between families

axes[0].set_xticks(ticks)
axes[0].set_xticklabels(tick_labels, rotation=45, ha='right', fontsize=8)
axes[0].set_ylabel('Directional Depth', fontsize=12)
axes[0].set_title('Depth Across Weight Function Families', fontsize=13)
axes[0].axhline(y=5, color='red', linestyle='--', alpha=0.5, label='max tested (≥5 = likely ∞)')
axes[0].legend(fontsize=9)

# Add family labels
prev_x = 0
for family_name, entries in family_groups.items():
    mid = prev_x + len(entries) / 2 - 0.5
    axes[0].text(mid, -0.8, family_name, ha='center', fontsize=9, fontweight='bold',
                 color=colors.get(family_name, '#666'))
    prev_x += len(entries) + 0.5

# Panel 2: Ratio transform magnitude decay
ax2 = axes[1]

test_functions = {
    'Gaussian σ=1': lambda m: math.exp(-sum(x**2 for x in m) / 2),
    'Geometric r=0.5': lambda m: 0.5**(m[0] + m[1]),
    'Power α=2': lambda m: 1.0 / ((m[0]+1)**2 * (m[1]+1)**2),
    'L1 (p=1)': lambda m: math.exp(-sum(abs(x) for x in m)),
}

for name, f in test_functions.items():
    wf = make_weight_fn(f, 2, 12)
    # Track R₀ values along (m, 0)
    ratios = []
    for k in range(10):
        m = (k, 0)
        fm = lookup(wf, m)
        fm1 = lookup(wf, (k+1, 0))
        if fm > 1e-15:
            ratios.append(fm1 / fm)
    ax2.plot(range(len(ratios)), ratios, 'o-', label=name, markersize=4)

ax2.set_xlabel('Position m₁', fontsize=12)
ax2.set_ylabel('R₀f(m₁, 0)', fontsize=12)
ax2.set_title('Ratio Transform Decay: R₀f along axis', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.suptitle('Directional Depth Filtration: Family Comparison', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_depth_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_comparison.png")
