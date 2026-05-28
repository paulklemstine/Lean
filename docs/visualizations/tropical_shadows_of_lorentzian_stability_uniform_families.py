"""
Visualization: Uniform Weight Families — Gap vs Stability Radius

Shows the exact agreement between tropical spectral gap and the theoretical
value 2(d-c) for uniform weight families, alongside the empirical stability
radius, confirming both the exact theorem and the stability bound.
"""

import numpy as np
import matplotlib.pyplot as plt

def tropical_spectral_gap_val(W):
    n = W.shape[0]
    min_gap = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                gap = W[i, i] + W[j, j] - 2 * W[i, j]
                min_gap = min(min_gap, gap)
    return min_gap

def is_trop_psd(W):
    return tropical_spectral_gap_val(W) >= -1e-10

def empirical_stability_radius(W, n_trials=300, seed=42):
    rng = np.random.RandomState(seed)
    n = W.shape[0]
    gap = tropical_spectral_gap_val(W)
    lo, hi = 0.0, gap / 2
    if hi <= 0:
        return 0.0
    for _ in range(40):
        mid = (lo + hi) / 2
        destroyed = False
        for _ in range(n_trials):
            delta = rng.uniform(-mid, mid, size=(n, n))
            delta = (delta + delta.T) / 2
            if not is_trop_psd(W + delta):
                destroyed = True
                break
        if destroyed:
            hi = mid
        else:
            lo = mid
    return lo

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Gap vs d-c for fixed n
ax1 = axes[0]
n = 5
dc_values = np.linspace(-1, 3, 40)
gaps = []
for dc in dc_values:
    d, c = 1.0 + dc, 1.0
    W = np.full((n, n), c)
    np.fill_diagonal(W, d)
    gaps.append(tropical_spectral_gap_val(W))

ax1.plot(dc_values, gaps, 'bo-', markersize=4, label='Computed gap')
ax1.plot(dc_values, 2 * dc_values, 'r--', linewidth=2, label='2(d - c)')
ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax1.axvline(x=0, color='gray', linestyle=':', linewidth=0.5)
ax1.set_xlabel('d - c', fontsize=12)
ax1.set_ylabel('Tropical Spectral Gap', fontsize=12)
ax1.set_title(f'Exact: gap = 2(d-c)\n(n = {n})', fontsize=12, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.fill_between(dc_values, 0, [max(0, g) for g in gaps], alpha=0.1, color='green')
ax1.text(1.5, -1.5, 'Tropically\nnon-PSD', fontsize=10, color='red', ha='center')
ax1.text(1.5, 3.5, 'Tropically\nPSD', fontsize=10, color='green', ha='center')

# Panel 2: Gap vs n for fixed d,c
ax2 = axes[1]
n_values = range(2, 21)
d, c = 3.0, 1.0
gaps_n = []
for n in n_values:
    W = np.full((n, n), c)
    np.fill_diagonal(W, d)
    gaps_n.append(tropical_spectral_gap_val(W))

ax2.plot(list(n_values), gaps_n, 'gs-', markersize=6, linewidth=2)
ax2.axhline(y=2*(d-c), color='red', linestyle='--', linewidth=2,
           label=f'2(d-c) = {2*(d-c):.0f}')
ax2.set_xlabel('Dimension n', fontsize=12)
ax2.set_ylabel('Tropical Spectral Gap', fontsize=12)
ax2.set_title(f'Gap independent of n\n(d={d}, c={c})', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 2*(d-c) + 1)

# Panel 3: Tropical bound vs empirical radius
ax3 = axes[2]
n = 5
dc_vals = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
trop_radii = []
emp_radii = []

for dc in dc_vals:
    d, c = 1.0 + dc, 1.0
    W = np.full((n, n), c)
    np.fill_diagonal(W, d)
    gap = tropical_spectral_gap_val(W)
    trop_radii.append(gap / 4)
    emp_radii.append(empirical_stability_radius(W))

x = np.arange(len(dc_vals))
width = 0.35
ax3.bar(x - width/2, trop_radii, width, label='Tropical bound (gap/4)',
       color='steelblue', alpha=0.8)
ax3.bar(x + width/2, emp_radii, width, label='Empirical radius',
       color='coral', alpha=0.8)
ax3.set_xticks(x)
ax3.set_xticklabels([f'{dc:.1f}' for dc in dc_vals])
ax3.set_xlabel('d - c', fontsize=12)
ax3.set_ylabel('Stability Radius', fontsize=12)
ax3.set_title(f'Bound vs Empirical\n(n = {n})', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

plt.suptitle('Tropical Shadows: Uniform Weight Family Analysis',
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_uniform_families.png', dpi=150, bbox_inches='tight')
print("Saved viz_uniform_families.png")
