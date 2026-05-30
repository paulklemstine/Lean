#!/usr/bin/env python3
"""
Visualization 3: Universality Conjecture Testing

Tests the Benford universality conjecture across multiple dynamical map
families: for each map and seed, checks whether Benford ⟺ ¬obstruction.
Visualizes concordance rates and counterexample analysis.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def leading_digit(n, base=10):
    if base <= 1 or n <= 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_theoretical(base, digit):
    return math.log(1 + 1/digit) / math.log(base)


def digit_discrepancy(sequence, base=10):
    N = len(sequence)
    if N == 0:
        return 1.0
    return max(
        abs(sum(1 for x in sequence if leading_digit(x, base) == d) / N 
            - benford_theoretical(base, d))
        for d in range(1, base)
    )


def detect_obstruction_simple(sequence, base=10, max_q=20):
    tail = sequence[len(sequence)//2:]
    tail = [x for x in tail if x > 0]
    if len(tail) < 5:
        return False, 0
    log_b = math.log(base)
    for q in range(1, max_q + 1):
        max_res = 0
        for x in tail:
            val = q * math.log(x) / log_b
            max_res = max(max_res, abs(val - round(val)))
            if max_res > 1e-6:
                break
        if max_res < 1e-6:
            return True, q
    return False, 0


def generate_orbit(T, seed, steps):
    orbit = [seed]
    n = seed
    for _ in range(steps):
        try:
            n = T(n)
            if n <= 0 or n > 10**18:
                break
            orbit.append(n)
        except (OverflowError, ValueError, ZeroDivisionError):
            break
    return orbit


# Define dynamical maps
def collatz(n):
    if n <= 1: return 4
    return n // 2 if n % 2 == 0 else 3 * n + 1

def doubling(n): return 2 * n
def tripling(n): return 3 * n
def times10(n): return 10 * n
def times6(n): return 6 * n
def affine_3_1(n): return 3 * n + 1
def affine_5_7(n): return 5 * n + 7

maps = {
    'Collatz 3n+1': collatz,
    'Doubling 2n': doubling,
    'Tripling 3n': tripling,
    '×10': times10,
    '×6': times6,
    '3n+1 (affine)': affine_3_1,
    '5n+7': affine_5_7,
}

# Test parameters
seeds = list(range(2, 52))
orbit_len = 3000
base = 10
threshold = 0.04

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# --- Panel 1: Concordance rates across maps ---
ax = axes[0, 0]
map_names = []
concordance_rates = []
benford_rates = []
obstruction_rates = []

for name, T in maps.items():
    concordant = 0
    benford_count = 0
    obs_count = 0
    
    for seed in seeds:
        orbit = generate_orbit(T, seed, orbit_len)
        disc = digit_discrepancy(orbit, base)
        is_benford = disc < threshold
        has_obs, _ = detect_obstruction_simple(orbit, base)
        
        if is_benford:
            benford_count += 1
        if has_obs:
            obs_count += 1
        if is_benford == (not has_obs):
            concordant += 1
    
    map_names.append(name)
    concordance_rates.append(concordant / len(seeds))
    benford_rates.append(benford_count / len(seeds))
    obstruction_rates.append(obs_count / len(seeds))

y_pos = np.arange(len(map_names))
bars = ax.barh(y_pos, concordance_rates, color='steelblue', alpha=0.8, edgecolor='navy')

for i, (rate, bar) in enumerate(zip(concordance_rates, bars)):
    ax.text(rate + 0.01, i, f'{rate:.0%}', va='center', fontsize=9)

ax.set_yticks(y_pos)
ax.set_yticklabels(map_names)
ax.set_xlabel('Concordance Rate')
ax.set_title('Universality Conjecture: Concordance\n(Benford ⟺ ¬Obstruction)')
ax.set_xlim(0, 1.15)
ax.axvline(x=1.0, color='green', linestyle='--', alpha=0.3)
ax.grid(True, alpha=0.3, axis='x')

# --- Panel 2: Discrepancy vs orbit length for different maps ---
ax = axes[0, 1]
checkpoints = [50, 100, 200, 500, 1000, 2000, 3000]

for name, T, color in [('2n', doubling, 'steelblue'), 
                         ('3n', tripling, 'green'),
                         ('10n', times10, 'red'),
                         ('Collatz', collatz, 'orange')]:
    orbit = generate_orbit(T, 7, max(checkpoints))
    discs = []
    for cp in checkpoints:
        if cp <= len(orbit):
            discs.append(digit_discrepancy(orbit[:cp], base))
        else:
            discs.append(None)
    
    valid = [(cp, d) for cp, d in zip(checkpoints, discs) if d is not None]
    if valid:
        ax.plot([v[0] for v in valid], [v[1] for v in valid], 
                'o-', label=name, color=color, markersize=4)

ax.axhline(y=threshold, color='gray', linestyle=':', alpha=0.5, label='Threshold')
ax.set_xlabel('Orbit Length')
ax.set_ylabel('Digit Discrepancy')
ax.set_title('Discrepancy Convergence\n(→0 for Benford sequences)')
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# --- Panel 3: Benford vs Obstruction classification ---
ax = axes[1, 0]

# Classify all (map, seed) pairs
benford_no_obs = 0
benford_obs = 0
not_benford_no_obs = 0
not_benford_obs = 0

for name, T in maps.items():
    for seed in seeds:
        orbit = generate_orbit(T, seed, orbit_len)
        disc = digit_discrepancy(orbit, base)
        is_benford = disc < threshold
        has_obs, _ = detect_obstruction_simple(orbit, base)
        
        if is_benford and not has_obs:
            benford_no_obs += 1
        elif is_benford and has_obs:
            benford_obs += 1
        elif not is_benford and not has_obs:
            not_benford_no_obs += 1
        else:
            not_benford_obs += 1

categories = ['Benford ∧ ¬Obs\n(Predicted ✓)', 'Benford ∧ Obs\n(Counterex.)', 
              '¬Benford ∧ ¬Obs\n(Counterex.)', '¬Benford ∧ Obs\n(Predicted ✓)']
counts = [benford_no_obs, benford_obs, not_benford_no_obs, not_benford_obs]
colors_cat = ['#2ecc71', '#e74c3c', '#e74c3c', '#2ecc71']

bars = ax.bar(range(4), counts, color=colors_cat, alpha=0.8, edgecolor='black')
ax.set_xticks(range(4))
ax.set_xticklabels(categories, fontsize=8)
ax.set_ylabel('Count')
ax.set_title('Classification Matrix\n(Green = agrees with conjecture)')
for i, (count, bar) in enumerate(zip(counts, bars)):
    ax.text(i, count + 1, str(count), ha='center', fontweight='bold')
ax.grid(True, alpha=0.3, axis='y')

# --- Panel 4: Collatz orbit digit frequency heatmap ---
ax = axes[1, 1]

n_seeds_heat = 20
heat_seeds = list(range(2, 2 + n_seeds_heat))
freq_matrix = np.zeros((n_seeds_heat, 9))

for i, seed in enumerate(heat_seeds):
    orbit = generate_orbit(collatz, seed, 5000)
    for d in range(1, 10):
        freq = sum(1 for x in orbit if leading_digit(x) == d) / len(orbit)
        freq_matrix[i, d - 1] = freq

benford_freqs = [benford_theoretical(10, d) for d in range(1, 10)]

im = ax.imshow(freq_matrix, aspect='auto', cmap='YlOrRd', 
               vmin=0, vmax=0.35)
ax.set_xticks(range(9))
ax.set_xticklabels(range(1, 10))
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Seed')
ax.set_yticks(range(n_seeds_heat))
ax.set_yticklabels(heat_seeds)
ax.set_title('Collatz Orbits: Digit Frequency Heatmap')
plt.colorbar(im, ax=ax, label='Frequency')

# Overlay Benford predictions
for d_idx, bf in enumerate(benford_freqs):
    ax.axvline(x=d_idx, color='white', alpha=0.1, linewidth=0.5)

plt.suptitle('Benford Universality Conjecture: Computational Evidence', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_universality_test.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality_test.png")
