#!/usr/bin/env python3
"""
Visualization 2: Spectral Multiplicity Distribution

Computes and visualizes the distribution of spectral multiplicities across
all birth profiles with max_level=3 and torsion orders dividing 30.
Tests the spectral multiplicity bound conjecture.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, Set, List
from itertools import combinations


def prime_factors(n: int) -> Set[int]:
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


class BirthProfile:
    def __init__(self, max_level: int, orders_at: Dict[int, Set[int]]):
        self.max_level = max_level
        self.orders_at = {i: set(orders_at.get(i, set())) for i in range(max_level + 1)}

    def global_birth_set(self) -> frozenset:
        return frozenset(i for i in range(self.max_level + 1)
                         if any(m > 1 for m in self.orders_at[i]))

    def p_birth_set(self, p: int) -> frozenset:
        return frozenset(i for i in range(self.max_level + 1)
                         if any(m > 1 and m % p == 0 for m in self.orders_at[i]))

    def active_primes(self) -> set:
        all_orders = set().union(*self.orders_at.values())
        return set().union(*(prime_factors(m) for m in all_orders if m > 1))

    def spectral_multiplicity(self) -> int:
        patterns = set()
        for p in self.active_primes():
            birth = self.p_birth_set(p)
            if birth:
                patterns.add(birth)
        return len(patterns)


# Generate profiles with single orders at each level, dividing 30
N = 30
max_level = 3
divisors = [d for d in range(2, N + 1) if N % d == 0]
# divisors: [2, 3, 5, 6, 10, 15, 30]
omega_N = len(prime_factors(N))  # 3
bound = omega_N * (max_level + 1)  # 12

print(f"N = {N}, divisors = {divisors}")
print(f"ω(N) = {omega_N}, bound = {bound}")

# Generate a large sample of profiles
import random
random.seed(42)

multiplicities = []
n_samples = 10000

for _ in range(n_samples):
    orders = {}
    for level in range(max_level + 1):
        k = random.randint(0, 3)
        if k > 0:
            orders[level] = set(random.sample(divisors, min(k, len(divisors))))
    prof = BirthProfile(max_level, orders)
    multiplicities.append(prof.spectral_multiplicity())

# Also count separating pairs
n_small = 2000
profiles_small = []
for _ in range(n_small):
    orders = {}
    for level in range(max_level + 1):
        k = random.randint(0, 2)
        if k > 0:
            orders[level] = set(random.sample(divisors, min(k, len(divisors))))
    profiles_small.append(BirthProfile(max_level, orders))

# Count global-equivalent but primewise-different pairs
sep_count = 0
total_same_global = 0
global_groups: Dict[frozenset, List[int]] = {}
for i, p in enumerate(profiles_small):
    gb = p.global_birth_set()
    global_groups.setdefault(gb, []).append(i)

for gb, indices in global_groups.items():
    for a in range(len(indices)):
        for b in range(a+1, min(a+50, len(indices))):
            i, j = indices[a], indices[b]
            total_same_global += 1
            all_p = profiles_small[i].active_primes() | profiles_small[j].active_primes()
            for p in all_p:
                if profiles_small[i].p_birth_set(p) != profiles_small[j].p_birth_set(p):
                    sep_count += 1
                    break

# Plot
fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Histogram of spectral multiplicities
counts, bins, patches = axes[0].hist(multiplicities, bins=range(0, max(multiplicities) + 2),
                                      edgecolor='black', alpha=0.7, color='steelblue')
axes[0].axvline(x=bound, color='red', linestyle='--', linewidth=2,
                label=f'Conjectured bound: ω({N})·(L+1) = {bound}')
axes[0].set_xlabel('Spectral Multiplicity', fontsize=12)
axes[0].set_ylabel('Count', fontsize=12)
axes[0].set_title('Distribution of Spectral Multiplicity\n'
                   f'(n={n_samples} random profiles, orders | {N}, L={max_level})', fontsize=11)
axes[0].legend(fontsize=10)
max_observed = max(multiplicities)
axes[0].annotate(f'Max observed: {max_observed}',
                xy=(max_observed, 0), xytext=(max_observed + 0.5, max(counts) * 0.3),
                arrowprops=dict(arrowstyle='->', color='darkgreen'),
                fontsize=10, color='darkgreen', fontweight='bold')

# Pie chart: separation rate
sep_rate = sep_count / max(total_same_global, 1) * 100
no_sep = total_same_global - sep_count

axes[1].pie([sep_count, no_sep],
            labels=[f'Primewise-different\n({sep_count})', f'Primewise-same\n({no_sep})'],
            colors=['coral', 'lightgreen'],
            autopct='%1.1f%%', startangle=90,
            textprops={'fontsize': 11})
axes[1].set_title(f'Among {total_same_global} globally-equivalent pairs:\n'
                  f'How many are primewise-distinguishable?', fontsize=11)

plt.suptitle('Spectral Multiplicity & Separation Statistics',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('spectral_multiplicity_distribution.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Max spectral multiplicity observed: {max_observed} (bound: {bound})")
print(f"Separation rate: {sep_rate:.1f}% of globally-equivalent pairs differ primewise")
print("Saved: spectral_multiplicity_distribution.png")
