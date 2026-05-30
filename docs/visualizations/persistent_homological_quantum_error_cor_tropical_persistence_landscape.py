#!/usr/bin/env python3
"""
Visualization: Tropical Persistence Landscape

Shows the tropical geometry perspective on persistence barcodes:
each bar maps to a point in the tropical plane, and the code distance
is determined by the geometry of these tropical points.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import math

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ============================================================
# Panel 1: Tropical Persistence Map
# ============================================================
ax1 = axes[0]

# Example persistence bars from various complexes
bars = [
    # (birth, death, label, color)
    (1.0, 2.0, 'Toric L=2', '#e41a1c'),
    (1.0, 3.0, 'Toric L=3', '#377eb8'),
    (1.0, 5.0, 'Toric L=5', '#4daf4a'),
    (0.5, 2.5, 'Genus-2', '#984ea3'),
    (0.3, 4.0, 'Random S³', '#ff7f00'),
    (2.0, 8.0, 'Hyperbolic', '#a65628'),
]

for birth, death, label, color in bars:
    persistence = death - birth
    tropical_val = -persistence
    predicted_d = math.ceil(death / birth)

    ax1.scatter(birth, tropical_val, s=150, c=color, edgecolors='black',
                linewidth=1, zorder=5)
    ax1.annotate(f'{label}\nd≥{predicted_d}',
                 (birth, tropical_val),
                 textcoords="offset points", xytext=(10, 5),
                 fontsize=8, color=color)

# Draw the tropical line y = -x (where birth = persistence)
x_line = np.linspace(0.1, 3, 100)
ax1.plot(x_line, -x_line, '--', color='gray', alpha=0.5, label='y = -birth')

ax1.set_xlabel('Birth Time ε', fontsize=12)
ax1.set_ylabel('Tropical Persistence −(δ−ε)', fontsize=12)
ax1.set_title('Tropical Persistence Landscape\n(lower = better code)', fontsize=13,
              fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.legend(fontsize=9)

# ============================================================
# Panel 2: Hamming Bound Landscape
# ============================================================
ax2 = axes[1]

# Compute Hamming sums for various n, t
n_values = np.arange(5, 50)

for t in [1, 2, 3]:
    hamming_sums = []
    syndrome_sizes = []
    for n in n_values:
        hs = sum(3**i * math.comb(n, i) for i in range(t + 1))
        hamming_sums.append(hs)
        # For k=2 (toric-like)
        syndrome_sizes.append(2**(n - 2))

    ax2.semilogy(n_values, hamming_sums, '-', linewidth=2,
                 label=f't={t} (d={2*t+1})')

# Syndrome space for k=2
ax2.semilogy(n_values, [2**(n-2) for n in n_values], 'k--',
             linewidth=2, alpha=0.5, label='2^(n-2) (k=2)')

# Mark specific toric codes
for L in [2, 3, 4, 5]:
    n = 2 * L**2
    t = (L - 1) // 2
    hs = sum(3**i * math.comb(n, i) for i in range(t + 1))
    if n <= 50:
        ax2.plot(n, hs, 'r*', markersize=12, zorder=5)
        ax2.annotate(f'L={L}', (n, hs),
                     textcoords="offset points", xytext=(5, 5), fontsize=9)

ax2.set_xlabel('Number of Physical Qubits n', fontsize=12)
ax2.set_ylabel('Hamming Sum / Syndrome Space', fontsize=12)
ax2.set_title('Quantum Hamming Bound\n(codes below dashed line are valid)', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_landscape.png', dpi=150, bbox_inches='tight')
print("Saved tropical_landscape.png")
