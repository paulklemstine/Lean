#!/usr/bin/env python3
"""
Visualization 2: Exponential Mixing on GL₂(𝔽_q) Cayley Graphs

Shows how the L² distance from uniform decays exponentially during
a random walk on the certified Cayley graph, with the decay rate
controlled by the spectral gap. Compares different primes q.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Mixing decay curves for different q
ax1 = axes[0]
primes_and_gaps = [
    (5, 0.15, '#2196F3'),
    (7, 0.10, '#4CAF50'),
    (11, 0.07, '#FF9800'),
    (17, 0.04, '#F44336'),
    (23, 0.03, '#9C27B0'),
]

t_max = 200
t = np.arange(0, t_max + 1)

for q, gap, color in primes_and_gaps:
    c = 1 - gap  # contraction factor
    decay = c ** t
    group_size = q * (q - 1) * (q**2 - 1)
    ax1.semilogy(t, decay, color=color, linewidth=2,
                 label=f'q={q}, γ≈{gap:.2f}, |G|={group_size}')
    # Mark mixing time
    t_mix = int(np.ceil(np.log(group_size) / gap))
    if t_mix < t_max:
        ax1.axvline(x=t_mix, color=color, linestyle=':', alpha=0.4)

ax1.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax1.set_xlabel('Walk steps t', fontsize=13)
ax1.set_ylabel('‖A^t f‖₂² / ‖f‖₂²', fontsize=13)
ax1.set_title('Exponential Mixing Decay', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.set_xlim(0, t_max)
ax1.set_ylim(1e-8, 2)
ax1.grid(True, alpha=0.3)

# Right panel: Mixing time vs q
ax2 = axes[1]
primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
gaps = [1 / (2*q) for q in primes]  # Predicted gap ≈ 1/(2q)
group_sizes = [q * (q-1) * (q**2 - 1) for q in primes]

# Mixing time t_mix ≈ log(|G|) / gap
t_mix_values = [np.log(gs) / g for gs, g in zip(group_sizes, gaps)]

# Theoretical prediction: t_mix ≈ 2q * 4*log(q)
t_mix_predicted = [2 * q * 4 * np.log(q) for q in primes]

ax2.plot(primes, t_mix_values, 'o-', color='#2196F3', linewidth=2,
         markersize=7, label='t_mix ≈ log|G| / γ', zorder=3)
ax2.plot(primes, t_mix_predicted, 's--', color='#F44336', linewidth=1.5,
         markersize=5, label='8q·ln(q)', zorder=2)
ax2.set_xlabel('Prime q', fontsize=13)
ax2.set_ylabel('Mixing time (steps)', fontsize=13)
ax2.set_title('Mixing Time vs. Prime q', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add annotation about the connection to quantum scrambling
ax2.annotate('Quantum scrambling\ntime ∝ q·log(q)',
             xy=(30, 8*30*np.log(30)), xytext=(35, 2000),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=10, color='gray', ha='center')

plt.tight_layout()
plt.savefig('mixing_rates.png', dpi=150, bbox_inches='tight')
print("Saved mixing_rates.png")
