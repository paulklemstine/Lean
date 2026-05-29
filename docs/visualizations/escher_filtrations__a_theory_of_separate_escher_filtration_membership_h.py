#!/usr/bin/env python3
"""
Visualization: Escher Filtration Membership Heatmap

Displays a heatmap showing which integers belong to which levels of the
2-adic Escher filtration E(n) = (2^n)ℤ. Each row is a filtration level,
each column is an integer. Bright cells indicate membership; dark cells
indicate the element has exited that filtration level.

The vanishing core theorem (int_twopow_hasVanishingCore) is visible as
the fact that no column is bright all the way down — every nonzero integer
eventually exits the filtration.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def p_adic_valuation(x: int, p: int) -> int:
    """Compute v_p(x). Returns a large number for x = 0."""
    if x == 0:
        return 100  # represent infinity
    x = abs(x)
    v = 0
    while x % p == 0:
        v += 1
        x //= p
    return v


# Parameters
p = 2
max_x = 64
max_n = 8

# Build membership matrix: M[n, x] = 1 if x ∈ (p^n)ℤ, else 0
x_values = list(range(1, max_x + 1))
n_values = list(range(max_n + 1))

M = np.zeros((len(n_values), len(x_values)))
for j, x in enumerate(x_values):
    v = p_adic_valuation(x, p)
    for i, n in enumerate(n_values):
        M[i, j] = 1.0 if v >= n else 0.0

# Create custom colormap
cmap = mcolors.LinearSegmentedColormap.from_list("escher", ["#1a1a2e", "#e94560"], N=2)

fig, ax = plt.subplots(figsize=(16, 5))
im = ax.imshow(M, aspect='auto', cmap=cmap, interpolation='nearest')

# Labels
ax.set_xlabel("Integer x", fontsize=12)
ax.set_ylabel("Filtration level n", fontsize=12)
ax.set_title(f"Escher Filtration Membership: x ∈ ({p}ⁿ)ℤ\n"
             f"(Vanishing core: no column is bright all the way down)",
             fontsize=14, fontweight='bold')

# Tick labels
x_tick_positions = list(range(0, len(x_values), 4))
ax.set_xticks(x_tick_positions)
ax.set_xticklabels([x_values[i] for i in x_tick_positions], fontsize=8)
ax.set_yticks(range(len(n_values)))
ax.set_yticklabels([f"n={n}" for n in n_values], fontsize=9)

# Colorbar
cbar = plt.colorbar(im, ax=ax, ticks=[0.25, 0.75])
cbar.ax.set_yticklabels(["x ∉ (2ⁿ)ℤ", "x ∈ (2ⁿ)ℤ"], fontsize=10)

# Highlight powers of 2 with vertical lines
for j, x in enumerate(x_values):
    if x > 0 and (x & (x - 1)) == 0:  # power of 2
        ax.axvline(x=j, color='cyan', alpha=0.3, linewidth=0.5)

plt.tight_layout()
plt.savefig("viz_filtration_heatmap.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_filtration_heatmap.png")
