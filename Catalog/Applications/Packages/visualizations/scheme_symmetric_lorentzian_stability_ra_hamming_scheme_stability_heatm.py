#!/usr/bin/env python3
"""
Visualization: Hamming Scheme Stability Heatmap

Visualizes the stability radius across different Hamming scheme parameters
(codeword length n and alphabet size q), showing how the Krawtchouk spectrum
controls robustness. The heatmap reveals the monotonicity pattern predicted
by Conjecture B.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb


def krawtchouk(j, i, n, q):
    val = 0.0
    for s in range(min(i, j) + 1):
        if n - i >= j - s:
            val += ((-1)**s) * ((q-1)**(j-s)) * comb(i, s) * comb(n-i, j-s)
    return val


def hamming_stability_radius(n, q):
    P = np.zeros((n+1, n+1))
    for j in range(n+1):
        for i in range(n+1):
            P[j, i] = krawtchouk(j, i, n, q)
    base = P[:, 0]
    rates = np.abs(P[:, 1])
    rates[0] = 0
    min_r = float('inf')
    for j in range(1, n+1):
        if rates[j] > 1e-15:
            min_r = min(min_r, abs(base[j]) / rates[j])
    return min_r


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# --- Panel 1: Heatmap of stability radius for H(n,q) ---
ax = axes[0]
n_vals = list(range(2, 12))
q_vals = list(range(2, 8))
radii = np.zeros((len(q_vals), len(n_vals)))

for qi, q in enumerate(q_vals):
    for ni, n in enumerate(n_vals):
        radii[qi, ni] = hamming_stability_radius(n, q)

im = ax.imshow(radii, aspect='auto', cmap='viridis', origin='lower',
               extent=[n_vals[0]-0.5, n_vals[-1]+0.5,
                       q_vals[0]-0.5, q_vals[-1]+0.5])
ax.set_xlabel('Codeword length n', fontsize=11)
ax.set_ylabel('Alphabet size q', fontsize=11)
ax.set_title('H(n,q): Lorentzian Stability Radius', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, label='Stability radius ρ')

# Add value annotations
for qi, q in enumerate(q_vals):
    for ni, n in enumerate(n_vals):
        val = radii[qi, ni]
        color = 'white' if val < np.median(radii) else 'black'
        ax.text(n, q, f'{val:.2f}', ha='center', va='center',
                fontsize=7, color=color)

# --- Panel 2: Stability radius curves for fixed q ---
ax = axes[1]
n_range = list(range(2, 15))
for q in [2, 3, 4, 5]:
    radii_q = [hamming_stability_radius(n, q) for n in n_range]
    ax.plot(n_range, radii_q, 'o-', linewidth=2, markersize=5, label=f'q = {q}')

ax.set_xlabel('Codeword length n', fontsize=11)
ax.set_ylabel('Stability Radius ρ', fontsize=11)
ax.set_title('H(n,q): Radius vs Length (Monotonicity Test)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/viz_hamming_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_hamming_heatmap.png")
