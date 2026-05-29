# Visualization 1: Moduli Dimension and Stratification Bounds
# 
# Visualizes the moduli dimension formula 3g-3 as a function of genus,
# the layer dimension bounds for valid stratifications, and the
# trivalent graph bridge (V, E as functions of genus).

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("The Fundamental Theorem of Cakes: Core Invariants", 
             fontsize=16, fontweight='bold')

# ─── Plot 1: Moduli Dimension ───
ax1 = axes[0, 0]
g_vals = np.arange(0, 11)
moduli_vals = 3 * g_vals - 3
colors = ['red' if d <= 0 else 'steelblue' for d in moduli_vals]
ax1.bar(g_vals, moduli_vals, color=colors, edgecolor='black', linewidth=0.5)
ax1.axhline(y=0, color='black', linewidth=0.8, linestyle='-')
ax1.set_xlabel('Genus g (cherries)', fontsize=12)
ax1.set_ylabel('Moduli Dimension', fontsize=12)
ax1.set_title('dim M_g = 3g − 3', fontsize=13)
ax1.annotate('Degenerate\n(g < 2)', xy=(0.5, -2), fontsize=9, 
             ha='center', color='red', fontstyle='italic')
ax1.annotate('Classical\nregime', xy=(6, 12), fontsize=9,
             ha='center', color='steelblue', fontstyle='italic')

# ─── Plot 2: Layer Dimension Bounds ───
ax2 = axes[0, 1]
n, k = 8, 5
i_vals = np.arange(k + 1)
lower_bounds = np.maximum(k - i_vals, 0)
upper_bounds = np.full_like(i_vals, n)

ax2.fill_between(i_vals, lower_bounds, upper_bounds, 
                  alpha=0.3, color='lightgreen', label='Feasible region')
ax2.plot(i_vals, lower_bounds, 'g-o', linewidth=2, markersize=6,
         label=f'Lower bound: k−i = {k}−i')
ax2.plot(i_vals, upper_bounds, 'b--o', linewidth=2, markersize=6,
         label=f'Upper bound: n = {n}')

# Example stratification
example_layers = [8, 6, 4, 3, 2, 0]
ax2.plot(i_vals, example_layers, 'r-s', linewidth=2.5, markersize=8,
         label='Example stratification', zorder=5)

ax2.set_xlabel('Layer index i', fontsize=12)
ax2.set_ylabel('Layer dimension', fontsize=12)
ax2.set_title(f'Stratification Bounds (n={n}, k={k})', fontsize=13)
ax2.legend(fontsize=9, loc='upper right')
ax2.set_ylim(-0.5, n + 1)

# ─── Plot 3: Trivalent Graph Bridge ───
ax3 = axes[1, 0]
g_bridge = np.arange(2, 11)
V_vals = 2 * (g_bridge - 1)
E_vals = 3 * (g_bridge - 1)
moduli_bridge = 3 * g_bridge - 3

ax3.plot(g_bridge, E_vals, 'bo-', linewidth=2, markersize=8, label='Edges E')
ax3.plot(g_bridge, V_vals, 'rs-', linewidth=2, markersize=8, label='Vertices V')
ax3.plot(g_bridge, moduli_bridge, 'g^--', linewidth=2, markersize=8, 
         label='moduliDim(g)', alpha=0.7)
ax3.set_xlabel('Genus g', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Trivalent Graph ↔ Moduli Bridge\nE = 3g−3 = moduliDim(g)', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# ─── Plot 4: Euler-Cake Characteristic ───
ax4 = axes[1, 1]

def enumerate_stratifications(n, k):
    from itertools import combinations
    if k > n or k < 0:
        return []
    if k == 0:
        return [[0]] if n == 0 else []
    result = []
    for combo in combinations(range(1, n), k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(layers)
    return result

n_range = range(3, 9)
euler_data = {}
for n in n_range:
    k = n - 1  # Maximum depth stratification
    strats = enumerate_stratifications(n, k)
    eulers = [sum((-1)**i * d for i, d in enumerate(s)) for s in strats]
    euler_data[n] = eulers

positions = list(range(len(list(n_range))))
bp = ax4.boxplot([euler_data[n] for n in n_range], positions=positions,
                  patch_artist=True, widths=0.6)
for patch in bp['boxes']:
    patch.set_facecolor('lightyellow')
    patch.set_edgecolor('orange')
ax4.set_xticklabels([f'n={n}' for n in n_range])
ax4.set_xlabel('Ambient dimension n', fontsize=12)
ax4.set_ylabel('Euler-cake characteristic χ', fontsize=12)
ax4.set_title('Distribution of χ_cake\n(max-depth stratifications)', fontsize=13)
ax4.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('cake_geometry_overview.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cake_geometry_overview.png")
