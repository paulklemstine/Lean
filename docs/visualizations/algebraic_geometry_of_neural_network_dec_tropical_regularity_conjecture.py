#!/usr/bin/env python3
"""
Visualization 3: Tropical Regularity Conjecture Test

Tests and visualizes the conjecture that generic ReLU networks achieve
the maximum number of linear regions with probability approaching 1.

Also shows the Euler characteristic / Betti number perspective on
decision boundary complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.3)

# --- Panel 1: Regularity conjecture test ---
ax1 = fig.add_subplot(gs[0, 0])

widths_test = [2, 3, 5, 8, 10, 15, 20]
n_trials = 5000
fractions = []

for w in widths_test:
    max_count = 0
    for _ in range(n_trials):
        slopes = np.random.randn(w)
        intercepts = np.random.randn(w)
        breakpoints = set()
        for s, b in zip(slopes, intercepts):
            if abs(s) > 1e-10:
                breakpoints.add(round(-b / s, 10))
        if len(breakpoints) == w:
            max_count += 1
    frac = max_count / n_trials
    fractions.append(frac)

ax1.bar(range(len(widths_test)), [f * 100 for f in fractions],
        color=['#2a9d8f' if f > 0.9 else '#e76f51' for f in fractions],
        edgecolor='#264653', linewidth=1.5)
ax1.axhline(90, color='red', linewidth=2, linestyle='--', alpha=0.7,
            label='Falsification threshold (90%)')
ax1.axhline(99, color='green', linewidth=1.5, linestyle=':', alpha=0.7,
            label='Prediction (>99%)')
ax1.set_xticks(range(len(widths_test)))
ax1.set_xticklabels([str(w) for w in widths_test])
ax1.set_xlabel('Network width w', fontsize=12)
ax1.set_ylabel('% achieving max regions', fontsize=12)
ax1.set_title('Tropical Regularity Conjecture Test\n(5000 trials per width)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(0, 105)

# --- Panel 2: Distribution of region counts ---
ax2 = fig.add_subplot(gs[0, 1])

w = 5
n_trials_hist = 10000
region_counts = []

for _ in range(n_trials_hist):
    slopes = np.random.randn(w) * 2
    intercepts = np.random.randn(w)
    weights = np.random.randn(w)

    x_fine = np.linspace(-10, 10, 50000)
    y = np.zeros_like(x_fine)
    for s, b, wt in zip(slopes, intercepts, weights):
        y += wt * np.maximum(s * x_fine + b, 0)

    dy = np.diff(y) / np.diff(x_fine)
    changes = np.sum(np.abs(np.diff(dy)) > 1e-4) + 1
    region_counts.append(min(changes, w + 2))

ax2.hist(region_counts, bins=range(1, w + 4), align='left',
         color='#457b9d', edgecolor='#1d3557', linewidth=1.5, alpha=0.8)
ax2.axvline(w + 1, color='red', linewidth=2, linestyle='--',
            label=f'Theoretical max = {w+1}')
ax2.set_xlabel('Number of linear regions', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title(f'Region Count Distribution (w={w})\n{n_trials_hist} random networks', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)

# --- Panel 3: Betti numbers (zero crossings) vs depth ---
ax3 = fig.add_subplot(gs[1, 0])

depths = [1, 2, 3, 4, 5]
w_fixed = 3
n_samples = 500
zero_crossings_by_depth = []

for depth in depths:
    crossings = []
    for _ in range(n_samples):
        x_fine = np.linspace(-5, 5, 5000)
        y = x_fine.copy()

        for layer in range(depth):
            np.random.seed(None)
            new_y = np.zeros_like(x_fine)
            for neuron in range(w_fixed):
                a = np.random.randn()
                b = np.random.randn()
                w_out = np.random.randn()
                new_y += w_out * np.maximum(a * y + b, 0)
            y = new_y + np.random.randn() * 0.1

        sign_changes = np.sum(np.abs(np.diff(np.sign(y))) > 0)
        crossings.append(sign_changes)

    zero_crossings_by_depth.append(crossings)

bp = ax3.boxplot(zero_crossings_by_depth, positions=depths, widths=0.6,
                 patch_artist=True)
for patch, d in zip(bp['boxes'], depths):
    color_val = d / max(depths)
    patch.set_facecolor(plt.cm.YlOrRd(0.3 + 0.5 * color_val))
    patch.set_edgecolor('#264653')

theoretical_max = [(w_fixed + 1) ** d for d in depths]
ax3.plot(depths, theoretical_max, 'rs--', markersize=8, linewidth=2,
         label='Theoretical max: (w+1)^L')
ax3.set_xlabel('Network depth L', fontsize=12)
ax3.set_ylabel('Zero crossings (β₀)', fontsize=12)
ax3.set_title(f'Tropical Betti Number β₀ vs Depth\n(w={w_fixed}, {n_samples} samples)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.set_yscale('symlog', linthresh=1)

# --- Panel 4: Depth advantage visualization ---
ax4 = fig.add_subplot(gs[1, 1])

# For fixed total neurons, compare different depth/width splits
total_neurons_values = [6, 12, 20]
colors_main = ['#264653', '#2a9d8f', '#e76f51']

for idx, N in enumerate(total_neurons_values):
    splits = []
    regions_list = []
    labels_list = []
    for L in range(1, N + 1):
        if N % L == 0:
            w = N // L
            if w >= 1:
                regions = (w + 1) ** L
                splits.append(L)
                regions_list.append(regions)
                labels_list.append(f'L={L},w={w}')

    ax4.semilogy(splits, regions_list, 'o-', color=colors_main[idx],
                 linewidth=2, markersize=7, label=f'N={N} neurons')

ax4.set_xlabel('Depth L (width = N/L)', fontsize=12)
ax4.set_ylabel('Max regions (w+1)^L', fontsize=12)
ax4.set_title('Same Total Neurons, Different Splits\nDepth wins exponentially', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

fig.suptitle('Tropical Regularity and the Power of Depth',
             fontsize=16, fontweight='bold', y=1.01)
plt.savefig('viz_regularity.png', dpi=150, bbox_inches='tight')
print("Saved viz_regularity.png")
