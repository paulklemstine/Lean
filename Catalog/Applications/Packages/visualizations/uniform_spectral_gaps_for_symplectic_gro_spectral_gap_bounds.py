#!/usr/bin/env python3
"""
Visualization: Spectral Gap Bounds vs Field Size

Illustrates the central transference theorem: for fixed rank n and
character-ratio constant C_n, the spectral gap bound 1 - C_n/q
increases toward 1 as the field size q grows. This is the visual
signature of uniform expansion — the gaps are bounded away from 0.

Each curve represents a different rank (n=1,2,3,4), showing how
the certificate framework produces expander families uniformly
across all sufficiently large finite fields.
"""

import numpy as np
import matplotlib.pyplot as plt

# Character ratio constants C_n for each rank (theoretical estimates)
rank_constants = {
    1: 2.0,   # SL₂: C₁ = 2  (classical Deligne–Lusztig)
    2: 4.0,   # Sp₄: C₂ = 4  (from Sp4SpectralGap.lean)
    3: 6.0,   # Sp₆: C₃ = 6  (predicted by conjecture)
    4: 8.0,   # Sp₈: C₄ = 8  (predicted by conjecture)
}

# Field sizes (odd primes)
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
q_continuous = np.linspace(3, 100, 500)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Gap bound curves ---
ax1 = axes[0]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
markers = ['o', 's', '^', 'D']

for idx, (n, C_n) in enumerate(rank_constants.items()):
    # Continuous curve
    gap = np.maximum(1 - C_n / q_continuous, 0)
    ax1.plot(q_continuous, gap, color=colors[idx], linewidth=2,
             label=f'Sp$_{{2\\cdot{n}}}$: gap ≥ 1 − {C_n:.0f}/q')

    # Discrete points at primes
    gap_primes = [max(1 - C_n / q, 0) for q in primes if q > C_n]
    q_valid = [q for q in primes if q > C_n]
    ax1.scatter(q_valid, gap_primes, color=colors[idx], marker=markers[idx],
                s=40, zorder=5, alpha=0.8)

ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.3)
ax1.set_xlabel('Field size q (prime)', fontsize=12)
ax1.set_ylabel('Spectral gap lower bound', fontsize=12)
ax1.set_title('Uniform Spectral Gap Bounds by Rank', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='lower right')
ax1.set_ylim(-0.05, 1.05)
ax1.set_xlim(2, 100)
ax1.grid(True, alpha=0.3)

# --- Right panel: Mixing time vs field size ---
ax2 = axes[1]
epsilon = 0.01

for idx, (n, C_n) in enumerate(rank_constants.items()):
    # Group order ≈ q^{n(2n+1)} for Sp_{2n}
    dim_exp = n * (2 * n + 1)
    mixing_times = []
    q_valid = []
    for q in primes:
        gap = 1 - C_n / q
        if gap > 0.01:
            log_G = dim_exp * np.log(q)
            t_mix = int(np.ceil((log_G + np.log(1/epsilon)) / gap))
            mixing_times.append(t_mix)
            q_valid.append(q)

    if q_valid:
        ax2.plot(q_valid, mixing_times, color=colors[idx], linewidth=2,
                 marker=markers[idx], markersize=5,
                 label=f'Sp$_{{2\\cdot{n}}}$: dim = {dim_exp}')

ax2.set_xlabel('Field size q (prime)', fontsize=12)
ax2.set_ylabel('Mixing time t_mix(0.01)', fontsize=12)
ax2.set_title('Random Walk Mixing Times', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_visualization.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_visualization.png")
