#!/usr/bin/env python3
"""
Visualization: Prime Channel Decomposition of Integer Persistence

This script visualizes how integer persistence data decomposes into
independent prime channels, and how the global Betti curve emerges
as the max-envelope of these channels.

Shows:
- Individual prime channels for sample data
- The max-envelope reconstruction
- How perturbations in one channel affect the global curve
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Build sample profiles ---
# A filtration of integer data where different primes "activate" at different levels
T = 15
times = np.arange(T)

# Profile A: a naturally occurring arithmetic filtration
# Imagine filtering integers by divisibility threshold
np.random.seed(42)

# Prime 2: early onset, gradual decay
betti_A_2 = np.array([0, 2, 5, 7, 8, 7, 5, 3, 2, 1, 0, 0, 0, 0, 0])
# Prime 3: mid onset, sharp peak
betti_A_3 = np.array([0, 0, 1, 3, 6, 8, 9, 7, 4, 2, 1, 0, 0, 0, 0])
# Prime 5: late onset, symmetric
betti_A_5 = np.array([0, 0, 0, 0, 1, 3, 5, 8, 9, 8, 5, 3, 1, 0, 0])
# Prime 7: very late, small
betti_A_7 = np.array([0, 0, 0, 0, 0, 0, 1, 2, 4, 6, 7, 6, 4, 2, 0])

global_A = np.maximum.reduce([betti_A_2, betti_A_3, betti_A_5, betti_A_7])

# Profile B: perturbed version (shifts in prime channels)
betti_B_2 = np.array([0, 3, 6, 8, 7, 5, 3, 2, 1, 0, 0, 0, 0, 0, 0])
betti_B_3 = np.array([0, 0, 0, 2, 5, 7, 8, 6, 3, 1, 0, 0, 0, 0, 0])
betti_B_5 = np.array([0, 0, 0, 0, 0, 2, 4, 7, 9, 9, 6, 4, 2, 0, 0])
betti_B_7 = np.array([0, 0, 0, 0, 0, 0, 0, 1, 3, 5, 8, 7, 5, 3, 1])

global_B = np.maximum.reduce([betti_B_2, betti_B_3, betti_B_5, betti_B_7])

# Distances
primes_data = {
    2: (betti_A_2, betti_B_2),
    3: (betti_A_3, betti_B_3),
    5: (betti_A_5, betti_B_5),
    7: (betti_A_7, betti_B_7),
}
colors = {2: '#e74c3c', 3: '#2ecc71', 5: '#3498db', 7: '#f39c12'}

# --- Create figure ---
fig = plt.figure(figsize=(16, 12))
gs = fig.add_gridspec(3, 2, hspace=0.35, wspace=0.3)

# Panel 1: Profile A decomposition
ax = fig.add_subplot(gs[0, 0])
bottom = np.zeros(T)
for p in [2, 3, 5, 7]:
    ax.fill_between(times, bottom, bottom + primes_data[p][0],
                     alpha=0.4, color=colors[p], label=f'p={p}')
    bottom += primes_data[p][0]
ax.plot(times, global_A, 'k-', linewidth=2.5, label='Max envelope')
ax.set_title('Profile A: Prime Channel Decomposition', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Betti value')
ax.legend(fontsize=8, ncol=3)
ax.grid(True, alpha=0.2)

# Panel 2: Profile B decomposition
ax = fig.add_subplot(gs[0, 1])
bottom = np.zeros(T)
for p in [2, 3, 5, 7]:
    ax.fill_between(times, bottom, bottom + primes_data[p][1],
                     alpha=0.4, color=colors[p], label=f'p={p}')
    bottom += primes_data[p][1]
ax.plot(times, global_B, 'k-', linewidth=2.5, label='Max envelope')
ax.set_title('Profile B: Perturbed Prime Channels', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Betti value')
ax.legend(fontsize=8, ncol=3)
ax.grid(True, alpha=0.2)

# Panel 3: Global curves comparison
ax = fig.add_subplot(gs[1, 0])
ax.plot(times, global_A, 'b-o', linewidth=2, markersize=5, label='Global A')
ax.plot(times, global_B, 'r-s', linewidth=2, markersize=5, label='Global B')
ax.fill_between(times, global_A, global_B, alpha=0.15, color='purple')
global_dist = np.abs(global_A.astype(int) - global_B.astype(int))
ax.set_title('Global Betti Curves (Max Envelopes)', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Global β(t)')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 4: Primewise distances vs global distance
ax = fig.add_subplot(gs[1, 1])
for p in [2, 3, 5, 7]:
    pw_dist = np.abs(primes_data[p][0].astype(int) -
                      primes_data[p][1].astype(int))
    ax.plot(times, pw_dist, '--', color=colors[p], linewidth=1.5,
            label=f'd(A,B) at p={p}', alpha=0.7)

pw_max = np.array([max(np.abs(int(primes_data[p][0][t]) -
                                int(primes_data[p][1][t]))
                        for p in [2, 3, 5, 7]) for t in range(T)])
ax.plot(times, pw_max, 'k-D', linewidth=2.5, markersize=4,
        label='max_p d_p (bound)')
ax.plot(times, global_dist, 'r-o', linewidth=2.5, markersize=5,
        label='Global distance')
ax.set_title('Max-Envelope Theorem in Action', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=8, loc='upper right')
ax.grid(True, alpha=0.2)

# Panel 5: The gap (strictness phenomenon)
ax = fig.add_subplot(gs[2, :])
gap = pw_max - global_dist

# Color bars by which prime is the bottleneck
bottleneck_colors = []
for t in range(T):
    dists = {p: abs(int(primes_data[p][0][t]) - int(primes_data[p][1][t]))
             for p in [2, 3, 5, 7]}
    bp = max(dists, key=dists.get)
    bottleneck_colors.append(colors[bp])

ax.bar(times, gap, color=bottleneck_colors, alpha=0.7, edgecolor='black',
       linewidth=0.5)
ax.plot(times, gap, 'k-', linewidth=1, alpha=0.5)

# Add legend for bottleneck primes
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=colors[p], edgecolor='black',
                          label=f'Bottleneck: p={p}')
                    for p in [2, 3, 5, 7]]
ax.legend(handles=legend_elements, fontsize=9, ncol=4, loc='upper right')

ax.set_title('Strictness Gap by Bottleneck Prime Channel', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Gap = upper bound − global dist')
ax.grid(True, alpha=0.2)

# Add summary text
strict_count = np.sum(gap > 0)
total = len(gap)
ax.text(0.02, 0.95, f'Strict gap at {strict_count}/{total} time points '
        f'({100*strict_count/total:.0f}%)',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Prime-Resolved Persistence: Decomposition, Stability, and Strictness',
             fontsize=14, fontweight='bold', y=1.01)
plt.savefig('prime_channels.png', dpi=150, bbox_inches='tight')
print("Saved: prime_channels.png")
plt.close()
