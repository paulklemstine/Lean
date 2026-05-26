#!/usr/bin/env python3
"""
Visualization 1: Energy Landscape with Metastable Degeneracies

Visualizes a weighted energy landscape as a heatmap of activation barriers,
highlighting metastably degenerate states (those with two or more equally
favorable exits). Demonstrates the Dictionary Theorem: tropical balance
↔ metastable degeneracy.

This script is fully self-contained — no local imports needed.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# ── Inline core functions ──

def out_min_value(W, i):
    return float(np.min(W[i]))

def out_minimizer_set(W, i, tol=1e-12):
    m = out_min_value(W, i)
    return {j for j in range(W.shape[1]) if abs(W[i, j] - m) < tol}

def is_metastably_degenerate(W, i):
    return len(out_minimizer_set(W, i)) >= 2

# ── Build example landscape ──

labels = ["Unfolded", "Int-A", "Int-B", "Misfolded", "Native"]
n = len(labels)

W = np.array([
    [99., 5.0, 5.0, 8.0, 15.],
    [7.0, 99., 12., 10., 3.0],
    [7.0, 12., 99., 10., 3.0],
    [12., 15., 15., 99., 20.],
    [20., 20., 20., 20., 99.]
])

# ── Create figure ──

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5), gridspec_kw={'width_ratios': [1.2, 1]})

# Panel 1: Barrier heatmap
ax1 = axes[0]
W_display = W.copy()
W_display[W_display > 50] = np.nan  # Hide self-loops

im = ax1.imshow(W_display, cmap='YlOrRd', aspect='equal', vmin=0, vmax=25)
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
ax1.set_yticklabels(labels, fontsize=9)
ax1.set_xlabel("Target State", fontsize=11)
ax1.set_ylabel("Source State", fontsize=11)
ax1.set_title("Activation Barrier Matrix W(i,j)", fontsize=13, fontweight='bold')

# Annotate values
for i in range(n):
    for j in range(n):
        if i != j:
            color = 'white' if W[i, j] > 12 else 'black'
            ax1.text(j, i, f'{W[i,j]:.0f}', ha='center', va='center',
                    fontsize=10, fontweight='bold', color=color)

# Highlight metastable rows
for i in range(n):
    if is_metastably_degenerate(W, i):
        mins = out_minimizer_set(W, i)
        for j in mins:
            rect = plt.Rectangle((j-0.5, i-0.5), 1, 1, linewidth=3,
                               edgecolor='blue', facecolor='none', linestyle='--')
            ax1.add_patch(rect)

plt.colorbar(im, ax=ax1, label='Barrier Height', shrink=0.8)

# Panel 2: Degeneracy summary
ax2 = axes[1]
ax2.axis('off')

# Summary text
summary_lines = [
    "TROPICAL METASTABILITY ANALYSIS",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    ""
]

for i in range(n):
    mins = out_minimizer_set(W, i)
    is_deg = is_metastably_degenerate(W, i)
    min_val = out_min_value(W, i)
    
    status = "✓ METASTABLE" if is_deg else "  stable"
    min_labels = ", ".join(labels[j] for j in sorted(mins))
    
    summary_lines.append(f"{'▶' if is_deg else '○'} {labels[i]}")
    summary_lines.append(f"  Min barrier: {min_val:.0f}")
    summary_lines.append(f"  Minimizers: {{{min_labels}}}")
    summary_lines.append(f"  Status: {status}")
    summary_lines.append("")

# Count
meta_count = sum(1 for i in range(n) if is_metastably_degenerate(W, i))
summary_lines.extend([
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    f"Metastable vertices: {meta_count}/{n}",
    f"Metastability rank: {meta_count}",
    "",
    "Blue dashed boxes: minimum-barrier",
    "exits (balance witnesses)"
])

ax2.text(0.05, 0.95, '\n'.join(summary_lines), transform=ax2.transAxes,
         fontsize=9.5, verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.suptitle("Tropical Balance Detects Metastable Crossroads in Energy Landscapes",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")
