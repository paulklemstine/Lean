"""
Visualization: Polar Space Codes from Symplectic Expanders

Shows the cross-domain connection between spectral expansion of
symplectic groups and error-correcting code parameters. The Cheeger
constant of the Cayley graph controls the minimum distance of codes
built on the symplectic polar space W(2n-1, q).
"""

import numpy as np
import matplotlib.pyplot as plt
import math

def spectral_gap(n, q):
    return 1 - (n + 1) / q

def polar_points(n, q):
    return (q**(2*n) - 1) // (q - 1)

def code_min_distance(n, q):
    gap = spectral_gap(n, q)
    if gap <= 0:
        return 0
    return (gap / 2) * polar_points(n, q)

def landazuri_seitz(n, q):
    if q <= 1:
        return 0
    return (q**n - 1) / (q - 1) - 1

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Code length vs minimum distance
ax1 = axes[0]
for n in [2, 3, 4, 5]:
    lengths, distances, qs = [], [], []
    for q in range(max(2*(n+1)+1, 5), 60, 2):
        L = polar_points(n, q)
        d = code_min_distance(n, q)
        if d > 0:
            lengths.append(L)
            distances.append(d)
            qs.append(q)
    if lengths:
        ax1.loglog(lengths, distances, '-o', markersize=4,
                   linewidth=1.5, label=f'n={n}')

ax1.set_xlabel('Code length |W(2n-1, q)|', fontsize=12)
ax1.set_ylabel('Min distance d_min', fontsize=12)
ax1.set_title('Polar Code Parameters', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3, which='both')

# Plot 2: Relative distance δ = d_min/length
ax2 = axes[1]
q_range = range(5, 52, 2)
for n in [2, 3, 4, 5]:
    deltas = []
    valid_q = []
    for q in q_range:
        gap = spectral_gap(n, q)
        if gap > 0:
            delta = gap / 2  # Relative distance = Cheeger constant
            deltas.append(delta)
            valid_q.append(q)
    if deltas:
        ax2.plot(valid_q, deltas, '-s', markersize=4,
                 linewidth=1.5, label=f'n={n}')

ax2.axhline(y=0.25, color='red', linestyle='--', alpha=0.5, label='δ = 1/4')
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Relative distance δ', fontsize=12)
ax2.set_title('Code Relative Distance', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 0.55)

# Plot 3: Landazuri-Seitz bounds vs rank
ax3 = axes[2]
ranks = range(1, 9)
for q in [3, 5, 7, 11]:
    ls_vals = [landazuri_seitz(n, q) for n in ranks]
    ax3.semilogy(list(ranks), [max(v, 0.5) for v in ls_vals],
                 '-^', markersize=6, linewidth=2, label=f'q={q}')

ax3.set_xlabel('Rank n', fontsize=12)
ax3.set_ylabel('LS bound (min irrep dim)', fontsize=12)
ax3.set_title('Landazuri-Seitz Bounds', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, which='both')

plt.suptitle('Cross-Domain: Symplectic Expansion → Polar Space Codes',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('polar_codes.png', dpi=150, bbox_inches='tight')
print("Saved polar_codes.png")
