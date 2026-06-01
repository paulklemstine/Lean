#!/usr/bin/env python3
"""Visualization: Cryptographic Hardness Hierarchy and Security Degradation"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Figure 1: Hierarchy diagram and security degradation
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Hierarchy diagram
ax1 = axes[0]
levels = ['OWF', 'PRG', 'PRF', 'ENC']
ranks = [0, 1, 2, 3]
colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db']

for i, (level, rank, color) in enumerate(zip(levels, ranks, colors)):
    circle = plt.Circle((0.5, rank * 0.25 + 0.125), 0.06, color=color, ec='black', lw=2)
    ax1.add_patch(circle)
    ax1.text(0.5, rank * 0.25 + 0.125, level, ha='center', va='center',
             fontsize=12, fontweight='bold', color='white')

# Draw arrows
for i in range(3):
    ax1.annotate('', xy=(0.5, ranks[i] * 0.25 + 0.185),
                xytext=(0.5, ranks[i+1] * 0.25 + 0.065),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))
    # Label the reduction
    reductions = ['HILL\n(loss: O(n²))', 'GGM\n(loss: O(2^d))', 'GM\n(loss: 1)']
    ax1.text(0.72, (ranks[i] * 0.25 + ranks[i+1] * 0.25) / 2 + 0.125, reductions[i],
            ha='left', va='center', fontsize=8, color='gray', style='italic')

ax1.set_xlim(0, 1.2)
ax1.set_ylim(0, 1)
ax1.set_aspect('equal')
ax1.set_title('Cryptographic Hardness Hierarchy', fontsize=14, fontweight='bold')
ax1.axis('off')
ax1.text(0.15, 0.95, 'Stronger →', fontsize=10, va='top', color='gray')
ax1.text(0.15, 0.05, '← Weaker', fontsize=10, va='bottom', color='gray')

# Right: Security degradation
ax2 = axes[1]
target_bits = [80, 128, 192, 256]
degradation_factors = [
    [4.0, 128.0, 1.0],   # n=2, d=7
    [16.0, 128.0, 1.0],  # n=4, d=7
    [64.0, 128.0, 1.0],  # n=8, d=7
    [256.0, 128.0, 1.0], # n=16, d=7
]

x = np.arange(len(target_bits))
width = 0.2

level_names = ['ENC', 'PRF', 'PRG', 'OWF']
level_colors = ['#3498db', '#2ecc71', '#f39c12', '#e74c3c']

for j, (target, factors) in enumerate(zip(target_bits, degradation_factors)):
    security = [float(target)]
    for f in reversed(factors):
        security.append(security[-1] * f)
    security.reverse()

    for i, (sec, color) in enumerate(zip(security, level_colors[::-1])):
        ax2.bar(x[j] + (i - 1.5) * width, np.log2(sec), width * 0.9,
               color=color, edgecolor='black', linewidth=0.5)

ax2.set_xticks(x)
ax2.set_xticklabels([f'{t}-bit\ntarget' for t in target_bits])
ax2.set_ylabel('Security (log₂ bits)', fontsize=11)
ax2.set_title('Security Degradation Through Hierarchy', fontsize=14, fontweight='bold')
patches = [mpatches.Patch(color=c, label=l) for c, l in zip(level_colors, level_names)]
ax2.legend(handles=patches, loc='upper left', fontsize=9)
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hierarchy.png")

# Figure 2: Hybrid argument and amplification
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Hybrid argument
ax1 = axes[0]
np.random.seed(42)
for n_steps in [4, 8, 16, 32]:
    advantages = np.random.exponential(0.001, n_steps)
    cumulative = np.cumsum(advantages)
    ax1.plot(range(1, n_steps + 1), cumulative, 'o-', markersize=3,
            label=f'n={n_steps}, total={cumulative[-1]:.4f}')
    # Triangle bound
    ax1.axhline(y=n_steps * advantages.max(), color='gray', linestyle='--', alpha=0.3)

ax1.set_xlabel('Hybrid Step', fontsize=11)
ax1.set_ylabel('Cumulative Advantage', fontsize=11)
ax1.set_title('Hybrid Argument: Cumulative Advantage', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3)

# Right: Amplification
ax2 = axes[1]
k_values = np.arange(1, 501)
for p in [0.001, 0.005, 0.01, 0.05, 0.1]:
    fail_prob = (1 - p) ** k_values
    ax2.semilogy(k_values, fail_prob, label=f'p={p}')

ax2.set_xlabel('Number of Repetitions (k)', fontsize=11)
ax2.set_ylabel('Failure Probability (1-p)^k', fontsize=11)
ax2.set_title('Advantage Amplification', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)
ax2.set_ylim(1e-10, 1)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_amplification.png")

# Figure 3: PRG stretch gap and collision density
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: PRG output gap
ax1 = axes[0]
n_values = range(2, 16)
N_vals = [2**n for n in n_values]
M_vals = [2**(n+1) for n in n_values]
gaps = [m - n for n, m in zip(N_vals, M_vals)]
coverages = [n/m for n, m in zip(N_vals, M_vals)]

ax1_twin = ax1.twinx()
bars = ax1.bar(list(n_values), gaps, color='#e74c3c', alpha=0.7, label='Output gap (M-N)')
ax1_twin.plot(list(n_values), coverages, 'b-o', markersize=5, label='Coverage (N/M)')
ax1.set_xlabel('Security Parameter n', fontsize=11)
ax1.set_ylabel('Output Gap (M - N)', fontsize=11, color='red')
ax1_twin.set_ylabel('Coverage Fraction (N/M)', fontsize=11, color='blue')
ax1.set_title('PRG Stretch: Output Gap', fontsize=14, fontweight='bold')
ax1.set_yscale('log')
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax1_twin.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='center right', fontsize=9)

# Right: Collision density
ax2 = axes[1]
import random
random.seed(42)
n_range = range(1, 13)
avg_cf = []
min_cf = []
max_cf = []
for n in n_range:
    N = 2**n
    M = 2**(n+1)
    cfs = []
    for _ in range(200):
        f_vals = [random.randint(0, M-1) for _ in range(N)]
        # Count collision-free
        from collections import Counter
        counts = Counter(f_vals)
        cf = sum(1 for v in counts.values() if v == 1)
        cfs.append(cf)
    avg_cf.append(np.mean(cfs))
    min_cf.append(min(cfs))
    max_cf.append(max(cfs))

N_vals_cf = [2**n for n in n_range]
expected = [n / np.e for n in N_vals_cf]

ax2.fill_between(list(n_range), min_cf, max_cf, alpha=0.2, color='blue')
ax2.plot(list(n_range), avg_cf, 'b-o', markersize=5, label='Avg collision-free')
ax2.plot(list(n_range), expected, 'r--', label='N/e (expected)')
ax2.plot(list(n_range), N_vals_cf, 'g--', label='N (upper bound)')
ax2.set_xlabel('Parameter n (domain = 2^n)', fontsize=11)
ax2.set_ylabel('Collision-free outputs', fontsize=11)
ax2.set_title('Collision Density in Stretching Functions', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('viz_collision_density.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_collision_density.png")
