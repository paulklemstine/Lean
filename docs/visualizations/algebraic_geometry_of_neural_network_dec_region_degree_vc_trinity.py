#!/usr/bin/env python3
"""
Visualization 2: Region-Degree-VC Trinity

Shows the fundamental three-way relationship between:
- Tropical degree (algebraic complexity)
- Linear regions (geometric complexity)
- VC dimension bound (learning-theoretic complexity)

The Trinity Theorem: w^L ≤ (w+1)^L ≤ 2^(wL)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# --- Panel 1: Trinity for fixed w, varying L ---
ax1 = fig.add_subplot(gs[0, 0])
w = 3
Ls = np.arange(1, 9)
degree = [w**L for L in Ls]
regions = [(w+1)**L for L in Ls]
activations = [2**(w*L) for L in Ls]

ax1.semilogy(Ls, degree, 'o-', color='#264653', linewidth=2, markersize=7, label=f'Degree: {w}^L')
ax1.semilogy(Ls, regions, 's-', color='#2a9d8f', linewidth=2, markersize=7, label=f'Regions: {w+1}^L')
ax1.semilogy(Ls, activations, '^-', color='#e76f51', linewidth=2, markersize=7, label=f'Activations: 2^({w}L)')

ax1.fill_between(Ls, degree, regions, alpha=0.1, color='#2a9d8f')
ax1.fill_between(Ls, regions, activations, alpha=0.1, color='#e76f51')

ax1.set_xlabel('Depth L', fontsize=11)
ax1.set_ylabel('Complexity', fontsize=11)
ax1.set_title(f'Trinity (w={w})\nw^L ≤ (w+1)^L ≤ 2^(wL)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Trinity for fixed L, varying w ---
ax2 = fig.add_subplot(gs[0, 1])
L = 3
ws = np.arange(1, 12)
degree = [w**L for w in ws]
regions = [(w+1)**L for w in ws]
activations = [2**(w*L) for w in ws]

ax2.semilogy(ws, degree, 'o-', color='#264653', linewidth=2, markersize=7, label=f'Degree: w^{L}')
ax2.semilogy(ws, regions, 's-', color='#2a9d8f', linewidth=2, markersize=7, label=f'Regions: (w+1)^{L}')
ax2.semilogy(ws, activations, '^-', color='#e76f51', linewidth=2, markersize=7, label=f'Activations: 2^({L}w)')

ax2.fill_between(ws, degree, regions, alpha=0.1, color='#2a9d8f')
ax2.fill_between(ws, regions, activations, alpha=0.1, color='#e76f51')

ax2.set_xlabel('Width w', fontsize=11)
ax2.set_ylabel('Complexity', fontsize=11)
ax2.set_title(f'Trinity (L={L})\nDegree ≤ Regions ≤ Activations', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Depth advantage heatmap ---
ax3 = fig.add_subplot(gs[0, 2])
ws_range = np.arange(1, 11)
Ls_range = np.arange(1, 11)
W, L_grid = np.meshgrid(ws_range, Ls_range)
# Ratio: (w+1)^L / (L*w+1)
ratio = np.zeros_like(W, dtype=float)
for i in range(len(Ls_range)):
    for j in range(len(ws_range)):
        w_val = ws_range[j]
        L_val = Ls_range[i]
        ratio[i, j] = np.log10((w_val + 1) ** L_val / max(L_val * w_val + 1, 1))

im = ax3.imshow(ratio, origin='lower', aspect='auto', cmap='YlOrRd',
                extent=[0.5, 10.5, 0.5, 10.5])
ax3.set_xlabel('Width w', fontsize=11)
ax3.set_ylabel('Depth L', fontsize=11)
ax3.set_title('log₁₀(Depth Advantage)\n(w+1)^L / (L·w+1)', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax3, label='log₁₀ ratio')

# --- Panel 4: Sauer-Shelah bound ---
ax4 = fig.add_subplot(gs[1, 0])
from math import comb

for d in [2, 3, 5, 8]:
    ns = np.arange(d, 25)
    partial_sums = [sum(comb(n, i) for i in range(d + 1)) for n in ns]
    bounds = [(n + 1) ** d for n in ns]
    ratios = [ps / b for ps, b in zip(partial_sums, bounds)]
    ax4.plot(ns, ratios, 'o-', markersize=4, linewidth=2, label=f'd={d}')

ax4.set_xlabel('n (set size)', fontsize=11)
ax4.set_ylabel('Ratio: Σ C(n,i) / (n+1)^d', fontsize=11)
ax4.set_title('Sauer-Shelah Tightness\nRatio ≤ 1 (proven)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=9)
ax4.axhline(1, color='red', linewidth=1, linestyle='--', alpha=0.7, label='Upper bound')
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0, 1.1)

# --- Panel 5: Product bound vs activation bound ---
ax5 = fig.add_subplot(gs[1, 1])
total_neurons_range = range(3, 25)
for L in [2, 3, 5]:
    product_bounds = []
    activation_bounds = []
    neurons_list = []
    for N in total_neurons_range:
        if N % L == 0:
            w = N // L
            pb = (w + 1) ** L
            ab = 2 ** N
            product_bounds.append(pb)
            activation_bounds.append(ab)
            neurons_list.append(N)
    if neurons_list:
        ratios = [pb/ab for pb, ab in zip(product_bounds, activation_bounds)]
        ax5.plot(neurons_list, ratios, 'o-', markersize=5, linewidth=2, label=f'L={L}')

ax5.set_xlabel('Total neurons N', fontsize=11)
ax5.set_ylabel('Π(wᵢ+1) / 2^N', fontsize=11)
ax5.set_title('Product bound / Activation bound\nProduct bound is tighter', fontsize=13, fontweight='bold')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3)
ax5.set_yscale('log')

# --- Panel 6: Parameter efficiency ---
ax6 = fig.add_subplot(gs[1, 2])
param_budgets = [10, 20, 50, 100, 200]
for budget in param_budgets:
    depths = []
    regions_per_param = []
    for L in range(1, 15):
        w = max(1, budget // L)
        if L * w <= budget:
            regions = (w + 1) ** L
            depths.append(L)
            regions_per_param.append(regions / budget)
    if depths:
        ax6.semilogy(depths, regions_per_param, 'o-', markersize=5, linewidth=2,
                     label=f'Budget={budget}')

ax6.set_xlabel('Depth L', fontsize=11)
ax6.set_ylabel('Regions per parameter', fontsize=11)
ax6.set_title('Parameter Efficiency\nDeeper = more efficient', fontsize=13, fontweight='bold')
ax6.legend(fontsize=9)
ax6.grid(True, alpha=0.3)

fig.suptitle('The Region-Degree-VC Trinity of Neural Networks',
             fontsize=16, fontweight='bold', y=1.01)
plt.savefig('viz_trinity.png', dpi=150, bbox_inches='tight')
print("Saved viz_trinity.png")
