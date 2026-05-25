#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs. Field Size

Plots the spectral gap of certified Cayley graphs as a function of
the prime field size q, testing the conjecture that gap ≥ C/q for
some absolute constant C.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import certificate_expansion_pipeline

primes = [3, 5, 7]
gaps = []
sizes = []

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

for q in primes:
    print(f"Computing for q = {q}...")
    results = certificate_expansion_pipeline(q, max_pairs=2)
    if results:
        for r in results:
            gaps.append(r['spectral_gap'])
            sizes.append(q)

# Plot 1: Spectral gap vs q
ax1.scatter(sizes, gaps, c='steelblue', s=100, zorder=5, edgecolors='navy')
if gaps:
    # Fit 1/q curve
    q_range = np.linspace(2.5, max(primes) + 0.5, 100)
    C_est = np.mean([g * q_val for g, q_val in zip(gaps, sizes)])
    ax1.plot(q_range, C_est / q_range, 'r--', linewidth=2,
             label=f'C/q (C ≈ {C_est:.2f})')

    ax1.set_xlabel('Prime q', fontsize=13)
    ax1.set_ylabel('Spectral Gap', fontsize=13)
    ax1.set_title('Spectral Gap vs. Field Size\n'
                  'Testing conjecture: gap ≥ C/q', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

# Plot 2: q × gap (should be roughly constant if conjecture holds)
q_times_gap = [q_val * g for g, q_val in zip(gaps, sizes)]
ax2.bar(range(len(q_times_gap)), q_times_gap, color='steelblue',
        edgecolor='navy', alpha=0.7)
ax2.set_xlabel('Pair index', fontsize=13)
ax2.set_ylabel('q × gap', fontsize=13)
ax2.set_title('Product q × gap\n'
              '(Should be ≈ constant if gap ~ C/q)', fontsize=14)
ax2.axhline(y=np.mean(q_times_gap) if q_times_gap else 1,
            color='red', linestyle='--', linewidth=2,
            label=f'Mean = {np.mean(q_times_gap):.2f}' if q_times_gap else '')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Conjecture Test: Uniform Spectral Gap for Certified Pairs',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gap_vs_q.png', dpi=150, bbox_inches='tight')
print("Saved: gap_vs_q.png")
