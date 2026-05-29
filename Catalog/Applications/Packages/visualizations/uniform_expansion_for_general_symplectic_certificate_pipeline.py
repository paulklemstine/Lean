#!/usr/bin/env python3
"""
Visualization: Certificate Pipeline for Symplectic Expanders

Illustrates the rank-aware certificate pipeline:
    Torus Witness → Character Ratio → Spectral Gap → Cheeger → Mixing

Shows how a single mathematical object (the torus witness with constant C_n)
determines the entire expansion chain for Sp_{2n}(F_q).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# ============================================================
# Plot 1: The Certificate Pipeline (schematic + data)
# ============================================================
ax1 = axes[0, 0]

# Show the pipeline as a flow with quantitative data
ranks = [1, 2, 3, 5, 8]
q = 23

pipeline_data = []
for n in ranks:
    C_n = n + 1
    ratio = C_n / q
    gap = 1 - ratio
    cheeger = gap / 2
    if gap > 0:
        mixing = math.ceil(math.log(100) / math.log(1.0 / (1 - gap)))
    else:
        mixing = float('inf')
    pipeline_data.append({
        'rank': n, 'C_n': C_n, 'ratio': ratio,
        'gap': gap, 'cheeger': cheeger, 'mixing': mixing
    })

# Bar chart showing pipeline stages
x = np.arange(len(ranks))
width = 0.2

ax1.bar(x - 1.5*width, [d['ratio'] for d in pipeline_data], width,
        label='C_n/q (ratio)', color='#e74c3c', alpha=0.8)
ax1.bar(x - 0.5*width, [d['gap'] for d in pipeline_data], width,
        label='1 - C_n/q (gap)', color='#2ecc71', alpha=0.8)
ax1.bar(x + 0.5*width, [d['cheeger'] for d in pipeline_data], width,
        label='gap/2 (Cheeger)', color='#3498db', alpha=0.8)
ax1.bar(x + 1.5*width, [min(d['mixing']/200, 1.0) for d in pipeline_data], width,
        label='mixing/200 (scaled)', color='#9b59b6', alpha=0.8)

ax1.set_xticks(x)
ax1.set_xticklabels([f'n={n}' for n in ranks])
ax1.set_ylabel('Value', fontsize=11)
ax1.set_title(f'Certificate Pipeline (q={q})', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper right')
ax1.grid(True, alpha=0.2)

# ============================================================
# Plot 2: Rank Induction — Constant Growth
# ============================================================
ax2 = axes[0, 1]

max_n = 20
ns = range(1, max_n + 1)
constants = [n + 1 for n in ns]

ax2.plot(list(ns), constants, 'bo-', markersize=6, linewidth=2, label='C_n = n + 1')
ax2.fill_between(list(ns), [0]*len(ns), constants, alpha=0.1, color='blue')

# Show threshold field sizes
for q_val in [7, 11, 23]:
    max_rank = q_val - 1
    ax2.axhline(y=q_val, color='gray', linestyle='--', alpha=0.3)
    ax2.text(max_n - 0.5, q_val + 0.3, f'q={q_val}', fontsize=8,
             ha='right', color='gray')
    # Mark the cutoff
    if max_rank <= max_n:
        ax2.plot(max_rank, q_val, 'r*', markersize=12)

ax2.set_xlabel('Rank n', fontsize=11)
ax2.set_ylabel('Character constant C_n', fontsize=11)
ax2.set_title('Linear Growth of Constants', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, max_n + 0.5)

# ============================================================
# Plot 3: Cheeger Expansion Landscape
# ============================================================
ax3 = axes[1, 0]

q_range = np.arange(5, 100)
for n in [1, 2, 3, 5, 10]:
    C_n = n + 1
    cheeger_vals = [max(0, (1 - C_n/q_val)/2) for q_val in q_range]
    ax3.plot(q_range, cheeger_vals, '-', linewidth=2, label=f'n={n}')

ax3.axhline(y=0.25, color='gray', linestyle=':', alpha=0.5, label='h = 1/4')
ax3.set_xlabel('Field size q', fontsize=11)
ax3.set_ylabel('Cheeger constant bound', fontsize=11)
ax3.set_title('Edge Expansion (Cheeger)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(-0.02, 0.55)

# ============================================================
# Plot 4: Group Size vs Expansion Quality
# ============================================================
ax4 = axes[1, 1]

primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
for n in [1, 2, 3, 4, 5]:
    sizes = []
    gaps = []
    for q_val in primes:
        C_n = n + 1
        gap = 1 - C_n / q_val
        if gap > 0:
            # Compute group order
            order = q_val ** (n * n)
            for i in range(1, n + 1):
                order *= (q_val ** (2 * i) - 1)
            sizes.append(math.log10(order))
            gaps.append(gap)
    if sizes:
        ax4.plot(sizes, gaps, 'o-', markersize=5, label=f'n={n}')

ax4.set_xlabel('log₁₀(|Sp₂ₙ(𝔽_q)|)', fontsize=11)
ax4.set_ylabel('Spectral gap bound', fontsize=11)
ax4.set_title('Gap vs Group Size', fontsize=13, fontweight='bold')
ax4.legend(fontsize=8, loc='lower right')
ax4.grid(True, alpha=0.3)

plt.suptitle('Rank-Aware Certificate Architecture for Symplectic Expanders',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('certificate_pipeline.png', dpi=150, bbox_inches='tight')
print("Saved certificate_pipeline.png")
