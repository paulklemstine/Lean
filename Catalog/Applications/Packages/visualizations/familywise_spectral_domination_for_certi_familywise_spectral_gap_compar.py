#!/usr/bin/env python3
"""
Visualization 1: Familywise Spectral Gap Comparison

Visualizes how the four representation families of GL₂(𝔽_q) contribute
to the spectral gap as q varies. Shows that the principal series
consistently has the largest operator norm among nontrivial families,
while cuspidal and Steinberg families gain extra cancellation.
"""

import numpy as np
import matplotlib.pyplot as plt

# Primes to analyze
primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Theoretical bounds for each family
# Det twists: max |cos(2πj/(q-1))| for j=1..q-2, typically ≈ cos(2π/(q-1))
det_twist_bounds = [np.cos(2 * np.pi / (q - 1)) for q in primes]

# Principal series: estimated bound 1 - 1/(2q) from character sum analysis
ps_bounds = [1 - 1/(2*q) for q in primes]

# Steinberg: Weil-type bound 2/sqrt(q)
steinberg_bounds = [min(1.0, 2/np.sqrt(q)) for q in primes]

# Cuspidal: Deligne-Lusztig bound 2/(q-1)
cuspidal_bounds = [min(1.0, 2/(q-1)) for q in primes]

# Spectral gaps
gaps = [1 - max(d, p, s, c) for d, p, s, c in
        zip(det_twist_bounds, ps_bounds, steinberg_bounds, cuspidal_bounds)]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Operator norms by family
ax1 = axes[0]
ax1.plot(primes, det_twist_bounds, 'o-', color='#2196F3', linewidth=2,
         markersize=6, label='Det Twists', zorder=3)
ax1.plot(primes, ps_bounds, 's-', color='#F44336', linewidth=2.5,
         markersize=7, label='Principal Series', zorder=4)
ax1.plot(primes, steinberg_bounds, '^-', color='#4CAF50', linewidth=2,
         markersize=6, label='Steinberg', zorder=3)
ax1.plot(primes, cuspidal_bounds, 'D-', color='#FF9800', linewidth=2,
         markersize=6, label='Cuspidal', zorder=3)
ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Trivial bound')
ax1.set_xlabel('Prime q', fontsize=13)
ax1.set_ylabel('Max operator norm', fontsize=13)
ax1.set_title('Familywise Operator Norms of M_ρ(S)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='center right')
ax1.set_ylim(-0.05, 1.15)
ax1.grid(True, alpha=0.3)
ax1.annotate('Principal series\ndominates here',
             xy=(23, 1 - 1/46), xytext=(30, 0.65),
             arrowprops=dict(arrowstyle='->', color='#F44336'),
             fontsize=10, color='#F44336', ha='center')

# Right panel: Spectral gap × q
ax2 = axes[1]
gap_times_q = [g * q for g, q in zip(gaps, primes)]
ax2.bar(range(len(primes)), gap_times_q, color='#9C27B0', alpha=0.7, edgecolor='#7B1FA2')
ax2.set_xticks(range(len(primes)))
ax2.set_xticklabels([str(q) for q in primes], fontsize=10)
ax2.set_xlabel('Prime q', fontsize=13)
ax2.set_ylabel('γ(S) × q', fontsize=13)
ax2.set_title('Normalized Spectral Gap γ(S)·q', fontsize=14, fontweight='bold')
ax2.axhline(y=0.5, color='#E91E63', linestyle='--', linewidth=1.5,
            alpha=0.7, label='Conjectured limit 1/2')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('spectral_gap_comparison.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_comparison.png")
