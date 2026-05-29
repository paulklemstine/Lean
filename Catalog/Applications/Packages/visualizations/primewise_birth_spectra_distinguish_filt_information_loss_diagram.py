#!/usr/bin/env python3
"""
Visualization 2: Information Loss Diagram

Visualizes the information loss when projecting from primewise birth spectrum
to global birth set. Shows a bar chart comparing the amount of prime-resolved
data vs the coarse global data for several example profiles, quantifying
how much structure the global invariant discards.

This makes tangible the key theorem: the global birth set is a lossy
compression of the primewise spectrum.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def p_torsion_birth_set(p, max_level, orders_at):
    return {i for i in range(max_level + 1) if any(m > 1 and m % p == 0 for m in orders_at.get(i, []))}

def global_torsion_birth_set(max_level, orders_at):
    return {i for i in range(max_level + 1) if any(m > 1 for m in orders_at.get(i, []))}


# Define several profiles with increasing complexity
profiles = [
    ("F: {2}@1, {6}@3", 3, {1: [2], 3: [6]}),
    ("G: {3}@1, {6}@3", 3, {1: [3], 3: [6]}),
    ("H: {30}@1", 3, {1: [30]}),
    ("J: {2}@0, {3}@1, {5}@2", 3, {0: [2], 1: [3], 2: [5]}),
    ("K: {6}@0, {10}@1, {15}@2", 3, {0: [6], 1: [10], 2: [15]}),
]

primes = [2, 3, 5, 7]

# Compute metrics
names = []
global_sizes = []
primewise_total_sizes = []
num_active_primes = []

for name, ml, orders in profiles:
    gbs = global_torsion_birth_set(ml, orders)
    pw_total = 0
    active_p = 0
    for p in primes:
        pbs = p_torsion_birth_set(p, ml, orders)
        pw_total += len(pbs)
        if pbs:
            active_p += 1

    names.append(name)
    global_sizes.append(len(gbs))
    primewise_total_sizes.append(pw_total)
    num_active_primes.append(active_p)

x = np.arange(len(names))
width = 0.35

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

# Top: Comparison of global vs primewise data volume
bars1 = ax1.bar(x - width/2, global_sizes, width, label='Global birth set size',
                color='#e74c3c', alpha=0.8)
bars2 = ax1.bar(x + width/2, primewise_total_sizes, width,
                label='Total primewise data (Σ |pBS(p)|)', color='#3498db', alpha=0.8)

ax1.set_xlabel('Profile')
ax1.set_ylabel('Number of level-entries')
ax1.set_title('Information Content: Global vs Primewise Birth Data', fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(names, rotation=15, ha='right', fontsize=8)
ax1.legend()
ax1.grid(axis='y', alpha=0.3)

# Add value labels
for bar in bars1:
    ax1.annotate(f'{bar.get_height():.0f}',
                 xy=(bar.get_x() + bar.get_width() / 2, bar.get_height()),
                 xytext=(0, 3), textcoords="offset points",
                 ha='center', va='bottom', fontsize=9)
for bar in bars2:
    ax1.annotate(f'{bar.get_height():.0f}',
                 xy=(bar.get_x() + bar.get_width() / 2, bar.get_height()),
                 xytext=(0, 3), textcoords="offset points",
                 ha='center', va='bottom', fontsize=9)

# Bottom: Information loss ratio
loss_ratios = [1 - g/pw if pw > 0 else 0 for g, pw in zip(global_sizes, primewise_total_sizes)]
colors = ['#2ecc71' if lr < 0.3 else '#f39c12' if lr < 0.6 else '#e74c3c' for lr in loss_ratios]

bars3 = ax2.bar(x, loss_ratios, width * 2, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Profile')
ax2.set_ylabel('Information Loss Ratio')
ax2.set_title('Information Lost When Projecting Primewise → Global', fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(names, rotation=15, ha='right', fontsize=8)
ax2.set_ylim(0, 1)
ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50% loss')
ax2.legend()
ax2.grid(axis='y', alpha=0.3)

for bar, lr in zip(bars3, loss_ratios):
    ax2.annotate(f'{lr:.1%}',
                 xy=(bar.get_x() + bar.get_width() / 2, bar.get_height()),
                 xytext=(0, 3), textcoords="offset points",
                 ha='center', va='bottom', fontsize=9, fontweight='bold')

plt.tight_layout()
plt.savefig("viz_venn.png", dpi=150, bbox_inches='tight')
print("Saved viz_venn.png")
