#!/usr/bin/env python3
"""
Visualization 3: Mixing Time Comparison

Compares mixing time bounds for distributions with different concavity depths,
showing how the O(n^{2/k} log n) scaling varies with k.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (
    discrete_gaussian, stretched_exponential, metropolis_birth_death,
    spectral_gap_dense, mixing_time_bound, concavity_depth_profile
)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: Theoretical mixing time curves
ns = np.arange(5, 201)

for k, color, label in [(1, '#F44336', 'k=1: O(n² log n)'),
                          (2, '#2196F3', 'k=2: O(n log n)'),
                          (3, '#4CAF50', 'k=3: O(n^{2/3} log n)'),
                          (5, '#FF9800', 'k=5: O(n^{2/5} log n)')]:
    t_mix = ns ** (2.0 / k) * np.log(ns + 1)
    ax1.plot(ns, t_mix, color=color, label=label, linewidth=2)

ax1.set_xlabel('State space size n', fontsize=12)
ax1.set_ylabel('Mixing time bound', fontsize=12)
ax1.set_title('Theoretical Mixing Time Scaling\nby Concavity Depth k',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Right panel: Empirical mixing times for Gaussian families
ns_test = [10, 15, 20, 25, 30, 40, 50]

families = {
    'Gauss a=0.01': (0.01, '#F44336'),
    'Gauss a=0.05': (0.05, '#2196F3'),
    'Gauss a=0.1': (0.1, '#4CAF50'),
    'Gauss a=0.5': (0.5, '#FF9800'),
}

for name, (a_val, color) in families.items():
    t_mixes = []
    valid_ns = []
    for n in ns_test:
        pi = discrete_gaussian(n, a=a_val)
        depth = concavity_depth_profile(pi, max_depth=5)
        P = metropolis_birth_death(pi)
        gap = spectral_gap_dense(P)
        t = mixing_time_bound(gap, pi.min())
        if t < 1e10:
            t_mixes.append(t)
            valid_ns.append(n)

    if valid_ns:
        depth = concavity_depth_profile(discrete_gaussian(valid_ns[0], a=a_val))
        ax2.plot(valid_ns, t_mixes, 'o-', color=color,
                 label=f'{name} (depth≥{depth})', linewidth=2, markersize=5)

ax2.set_xlabel('State space size n', fontsize=12)
ax2.set_ylabel('Mixing time bound (1/γ · log(1/π_min))', fontsize=12)
ax2.set_title('Empirical Mixing Times\nDiscrete Gaussian Families',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_comparison.png', dpi=150, bbox_inches='tight')
print("Saved mixing_comparison.png")
