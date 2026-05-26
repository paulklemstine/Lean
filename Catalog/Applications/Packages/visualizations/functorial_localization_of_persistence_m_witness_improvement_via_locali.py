#!/usr/bin/env python3
"""
Visualization: Witness Improvement via Localization

Illustrates Theorem 4: localization at a prime can strictly improve
interleaving witnesses by removing mixed-prime torsion obstructions.

Shows a heatmap of interleaving distances across different primes for
randomly generated persistence module pairs, highlighting cases where
localization produces a tighter bound.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

def p_primary_part(n, p):
    result = 1
    while n % p == 0:
        result *= p
        n //= p
    return result

def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.add(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

def has_p_torsion(invariant_factors, p):
    return any(d % p == 0 for d in invariant_factors)

def random_module(length=8, primes=[2,3,5]):
    """Generate a random persistence module."""
    levels = []
    torsion = []
    for i in range(length):
        if random.random() < 0.35:
            p = random.choice(primes)
            k = random.randint(1, 2)
            torsion.append(p ** k)
        levels.append(list(torsion))
    return levels

def torsion_birth(levels, p):
    """First level where p-torsion appears."""
    for i, factors in enumerate(levels):
        if has_p_torsion(factors, p):
            return i
    return None

def global_birth(levels):
    for i, factors in enumerate(levels):
        if factors:
            return i
    return None

random.seed(42)

# Generate many pairs and compute distances
n_pairs = 50
primes = [2, 3, 5]
results = []

for trial in range(n_pairs):
    F = random_module(length=8)
    G = random_module(length=8)
    
    gb_F = global_birth(F)
    gb_G = global_birth(G)
    global_dist = abs(gb_F - gb_G) if gb_F is not None and gb_G is not None else -1
    
    prime_dists = {}
    for p in primes:
        b_F = torsion_birth(F, p)
        b_G = torsion_birth(G, p)
        if b_F is not None and b_G is not None:
            prime_dists[p] = abs(b_F - b_G)
        else:
            prime_dists[p] = -1  # undefined
    
    results.append({
        'global': global_dist,
        'primes': prime_dists,
        'improvement': any(prime_dists[p] < global_dist and prime_dists[p] >= 0 
                           for p in primes if global_dist >= 0)
    })

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# Panel 1: Distance comparison heatmap
ax = axes[0]
ax.set_title('Birth Distance by Prime\n(50 random module pairs)', fontsize=11, fontweight='bold')

# Build matrix: rows = trials, columns = [global, p=2, p=3, p=5]
labels = ['Global', 'p=2', 'p=3', 'p=5']
matrix = np.zeros((n_pairs, 4))
for i, r in enumerate(results):
    matrix[i, 0] = r['global'] if r['global'] >= 0 else np.nan
    for j, p in enumerate(primes):
        matrix[i, j+1] = r['primes'][p] if r['primes'][p] >= 0 else np.nan

# Sort by global distance
valid_mask = ~np.isnan(matrix[:, 0])
valid_indices = np.where(valid_mask)[0]
sorted_indices = valid_indices[np.argsort(matrix[valid_indices, 0])]

display_matrix = matrix[sorted_indices[:30]]  # Show top 30

im = ax.imshow(display_matrix.T, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax.set_yticks(range(4))
ax.set_yticklabels(labels)
ax.set_xlabel('Module pair index (sorted by global distance)')
plt.colorbar(im, ax=ax, label='Birth distance', shrink=0.8)

# Panel 2: Improvement frequency
ax = axes[1]
ax.set_title('Localization Improvement\nFrequency', fontsize=11, fontweight='bold')

n_improved = sum(1 for r in results if r['improvement'])
n_total = len([r for r in results if r['global'] >= 0])

bars = ax.bar(['No\nimprovement', 'Strict\nimprovement'], 
              [n_total - n_improved, n_improved],
              color=['#bdc3c7', '#2ecc71'], edgecolor='black', linewidth=1)
ax.set_ylabel('Number of pairs')
for bar, val in zip(bars, [n_total - n_improved, n_improved]):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
            str(val), ha='center', fontweight='bold')
ax.set_ylim(0, max(n_total - n_improved, n_improved) + 5)

# Panel 3: Per-prime improvement magnitude
ax = axes[2]
ax.set_title('Improvement Magnitude\nby Prime', fontsize=11, fontweight='bold')

improvements = {p: [] for p in primes}
for r in results:
    if r['global'] >= 0:
        for p in primes:
            if r['primes'][p] >= 0:
                diff = r['global'] - r['primes'][p]
                if diff > 0:
                    improvements[p].append(diff)

positions = range(len(primes))
colors = ['#e74c3c', '#3498db', '#2ecc71']

for i, (p, c) in enumerate(zip(primes, colors)):
    data = improvements[p]
    if data:
        # Jitter plot
        jittered_x = [i + random.uniform(-0.15, 0.15) for _ in data]
        ax.scatter(jittered_x, data, c=c, alpha=0.6, s=40, edgecolors='black', linewidth=0.5)
        ax.plot([i - 0.2, i + 0.2], [np.mean(data)] * 2, c='black', lw=2)
        ax.text(i, max(data) + 0.3, f'n={len(data)}', ha='center', fontsize=9)

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([f'p={p}' for p in primes])
ax.set_ylabel('Distance improvement (global − localized)')
ax.set_ylim(-0.5, None)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

plt.suptitle('Witness Improvement via Prime Localization\n'
             'Localization can strictly sharpen interleaving distances',
             fontsize=13, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_witness_improvement.png', dpi=150, bbox_inches='tight')
print("Saved: viz_witness_improvement.png")
