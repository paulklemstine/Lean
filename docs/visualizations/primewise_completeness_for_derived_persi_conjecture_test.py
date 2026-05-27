#!/usr/bin/env python3
"""
Visualization: Interval-Decomposability Conjecture Test

This script tests and visualizes the conjecture that under
interval-decomposability (each prime's Betti curve is an indicator
of an interval), the max-envelope bound might be tight.

The visualization shows:
- A heatmap of the gap between global distance and primewise max distance
  across many random interval-decomposable profiles
- Distribution of gaps, showing how often strictness occurs
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

# --- Inline helper functions ---
def nat_dist(a, b):
    return abs(a - b)

def make_interval_betti(primes, intervals, max_t=12):
    """Create Betti data with indicator-of-interval curves."""
    betti = {}
    for p in primes:
        a, b = intervals.get(p, (0, -1))
        betti[p] = {t: (1 if a <= t <= b else 0) for t in range(max_t)}
    return betti

def global_betti(betti, primes, t):
    return max(betti.get(p, {}).get(t, 0) for p in primes) if primes else 0

def primewise_max_dist_at(betti_M, betti_N, primes, t):
    return max(nat_dist(betti_M.get(p, {}).get(t, 0),
                         betti_N.get(p, {}).get(t, 0)) for p in primes)

# --- Run the experiment ---
primes = [2, 3, 5]
max_t = 12
n_trials = 500
rng = random.Random(789)

all_gaps = []
gap_by_n_primes = {1: [], 2: [], 3: []}

for trial in range(n_trials):
    intervals_M = {p: tuple(sorted([rng.randint(0, max_t-1),
                                      rng.randint(0, max_t-1)]))
                    for p in primes}
    intervals_N = {p: tuple(sorted([rng.randint(0, max_t-1),
                                      rng.randint(0, max_t-1)]))
                    for p in primes}

    betti_M = make_interval_betti(primes, intervals_M, max_t)
    betti_N = make_interval_betti(primes, intervals_N, max_t)

    for t in range(max_t):
        gM = global_betti(betti_M, primes, t)
        gN = global_betti(betti_N, primes, t)
        gd = nat_dist(gM, gN)
        pw = primewise_max_dist_at(betti_M, betti_N, primes, t)
        gap = pw - gd
        all_gaps.append(gap)

# Also test with different numbers of primes
for n_p in [1, 2, 3]:
    test_primes = primes[:n_p]
    for trial in range(200):
        intervals_M = {p: tuple(sorted([rng.randint(0, max_t-1),
                                          rng.randint(0, max_t-1)]))
                        for p in test_primes}
        intervals_N = {p: tuple(sorted([rng.randint(0, max_t-1),
                                          rng.randint(0, max_t-1)]))
                        for p in test_primes}

        betti_M = make_interval_betti(test_primes, intervals_M, max_t)
        betti_N = make_interval_betti(test_primes, intervals_N, max_t)

        max_gap = 0
        for t in range(max_t):
            gM = global_betti(betti_M, test_primes, t)
            gN = global_betti(betti_N, test_primes, t)
            gd = nat_dist(gM, gN)
            pw = primewise_max_dist_at(betti_M, betti_N, test_primes, t)
            max_gap = max(max_gap, pw - gd)
        gap_by_n_primes[n_p].append(max_gap)

# --- Create visualization ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Interval-Decomposability Conjecture: Computational Evidence',
             fontsize=13, fontweight='bold')

# Panel 1: Distribution of gaps
ax = axes[0]
gap_array = np.array(all_gaps)
counts_0 = np.sum(gap_array == 0)
counts_pos = np.sum(gap_array > 0)
total = len(gap_array)

ax.bar(['Gap = 0\n(Tight)', 'Gap > 0\n(Strict)'],
       [counts_0, counts_pos],
       color=['#2ecc71', '#e74c3c'], alpha=0.8, edgecolor='black')
ax.set_ylabel('Count')
ax.set_title(f'Gap Distribution\n(n={total} points)', fontsize=11)
for i, v in enumerate([counts_0, counts_pos]):
    ax.text(i, v + total*0.01, f'{v}\n({100*v/total:.1f}%)',
            ha='center', fontsize=10, fontweight='bold')

# Panel 2: Gap histogram (detailed)
ax = axes[1]
unique_gaps = sorted(set(all_gaps))
gap_counts = [all_gaps.count(g) for g in unique_gaps]
bars = ax.bar(unique_gaps, gap_counts, color='#3498db', alpha=0.8,
              edgecolor='black')
ax.set_xlabel('Gap value (upper bound − global dist)')
ax.set_ylabel('Frequency')
ax.set_title('Gap Value Distribution', fontsize=11)
ax.set_xticks(unique_gaps)

# Panel 3: Gap frequency by number of primes
ax = axes[2]
x_pos = [1, 2, 3]
strict_fracs = []
for n_p in [1, 2, 3]:
    gaps = gap_by_n_primes[n_p]
    frac = sum(1 for g in gaps if g > 0) / len(gaps) if gaps else 0
    strict_fracs.append(frac)

bars = ax.bar(x_pos, strict_fracs, color=['#f39c12', '#e74c3c', '#9b59b6'],
              alpha=0.8, edgecolor='black')
ax.set_xlabel('Number of active primes')
ax.set_ylabel('Fraction with strict gap')
ax.set_title('Strictness vs Prime Count', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels(['1 prime\n{2}', '2 primes\n{2,3}', '3 primes\n{2,3,5}'])
for i, v in enumerate(strict_fracs):
    ax.text(x_pos[i], v + 0.02, f'{100*v:.1f}%',
            ha='center', fontsize=10, fontweight='bold')
ax.set_ylim(0, 1.0)

plt.tight_layout()
plt.savefig('conjecture_test.png', dpi=150, bbox_inches='tight')
print("Saved: conjecture_test.png")
plt.close()
