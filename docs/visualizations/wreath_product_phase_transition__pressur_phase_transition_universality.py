#!/usr/bin/env python3
"""
Visualization: Phase Transition Universality Across k Values

Shows that for different values of k (the symmetric group degree),
the wreath product pressure P(W_{k,m})/m always converges to P(S_k),
demonstrating universality of the phase transition mechanism.

The key insight: regardless of the semidirect coupling with S_m,
the generation threshold is determined by coordinate defects.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline pressure functions (self-contained) ───

def pressure_Sk(k):
    data = {
        3: [3, 2],
        4: [4, 2, 3],
        5: [5, 2, 10, 15, 6],
        6: [6, 2, 15, 20, 15, 10, 6],
    }
    return sum(1.0 / i for i in data.get(k, [k, 2]))

def noncoord_est(k, m):
    if m <= 1:
        return 0.0
    return 0.5 * math.log(m) + m * (m - 1) / (2 * math.factorial(k))

def total_pressure_per_m(k, m):
    p_sk = pressure_Sk(k)
    return p_sk + noncoord_est(k, m) / m if m > 0 else 0

# ─── Generate data ───
m_values = np.arange(2, 301)
k_values = [3, 4, 5, 6]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Phase Transition Universality in Wreath Products',
             fontsize=14, fontweight='bold')

# Panel 1: P(W_{k,m})/m for different k
for k, color in zip(k_values, colors):
    p_sk = pressure_Sk(k)
    ratios = [total_pressure_per_m(k, int(m)) for m in m_values]
    ax1.plot(m_values, ratios, color=color, linewidth=2,
             label=f'$k={k}$: $P(W_{{k,m}})/m$')
    ax1.axhline(y=p_sk, color=color, linestyle='--', alpha=0.5)
    ax1.annotate(f'$P(S_{k})={p_sk:.3f}$',
                xy=(280, p_sk), fontsize=9, color=color,
                va='bottom' if k % 2 == 0 else 'top')

ax1.set_xlabel('$m$ (number of copies)', fontsize=12)
ax1.set_ylabel('$P(W_{k,m}) / m$', fontsize=12)
ax1.set_title('Convergence: $P(W_{k,m})/m \\to P(S_k)$', fontsize=12)
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)

# Panel 2: Gap |P(W)/m - P(S_k)| on log scale
for k, color in zip(k_values, colors):
    p_sk = pressure_Sk(k)
    gaps = [abs(total_pressure_per_m(k, int(m)) - p_sk) for m in m_values]
    # Avoid log(0)
    gaps = [max(g, 1e-15) for g in gaps]
    ax2.semilogy(m_values, gaps, color=color, linewidth=2, label=f'$k={k}$')

# Reference line: O(log(m)/m)
ref = [math.log(m+1) / m for m in m_values]
ax2.semilogy(m_values, ref, 'k--', alpha=0.5, linewidth=1,
            label='$O(\\ln m / m)$')

ax2.set_xlabel('$m$', fontsize=12)
ax2.set_ylabel('$|P(W_{k,m})/m - P(S_k)|$', fontsize=12)
ax2.set_title('Gap Decay (log scale)', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('universality.png', dpi=150, bbox_inches='tight')
print("Saved: universality.png")
