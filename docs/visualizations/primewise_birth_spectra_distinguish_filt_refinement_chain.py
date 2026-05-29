#!/usr/bin/env python3
"""
Visualization 3: The Refinement Chain

Visualizes the strict refinement hierarchy:
  Trivial ⊂ Global Birth Set ⊂ Primewise Spectrum ⊂ Full Profile

Shows how each invariant partitions a set of profiles into equivalence classes,
with each finer invariant splitting classes further.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, Set, List, Tuple
import random


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
        primes = set()
        for m in all_orders:
            if m > 1:
                primes |= prime_factors(m)
        return primes

    def primewise_key(self) -> tuple:
        """A hashable key for the primewise spectrum."""
        return tuple(sorted(
            (p, self.p_birth_set(p)) for p in self.active_primes()
        ))

    def full_key(self) -> tuple:
        """A hashable key for the full profile."""
        return tuple(
            frozenset(self.orders_at[i]) for i in range(self.max_level + 1)
        )


# Generate profiles
random.seed(123)
N = 30
max_level = 3
divisors = [d for d in range(2, N + 1) if N % d == 0]

profiles = []
for _ in range(500):
    orders = {}
    for level in range(max_level + 1):
        k = random.randint(0, 2)
        if k > 0:
            orders[level] = set(random.sample(divisors, min(k, len(divisors))))
    profiles.append(BirthProfile(max_level, orders))

# Compute equivalence classes at each level
trivial_classes = 1  # Everything is equivalent
global_classes = len(set(p.global_birth_set() for p in profiles))
primewise_classes = len(set(p.primewise_key() for p in profiles))
full_classes = len(set(p.full_key() for p in profiles))

print(f"Profiles: {len(profiles)}")
print(f"Trivial classes: {trivial_classes}")
print(f"Global classes: {global_classes}")
print(f"Primewise classes: {primewise_classes}")
print(f"Full profile classes: {full_classes}")

# Visualization
fig, ax = plt.subplots(figsize=(10, 6))

levels = ['Trivial\n(all equivalent)', 'Global Birth\nSet', 'Primewise Birth\nSpectrum', 'Full Torsion\nProfile']
class_counts = [trivial_classes, global_classes, primewise_classes, full_classes]
colors = ['#ffcccc', '#ffaa66', '#66aaff', '#66cc66']

# Bar chart
bars = ax.bar(range(len(levels)), class_counts, color=colors, edgecolor='black', linewidth=1.5)

# Add value labels
for bar, count in zip(bars, class_counts):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
            f'{count}', ha='center', va='bottom', fontsize=14, fontweight='bold')

# Add arrows showing strict refinement
for i in range(len(levels) - 1):
    ax.annotate('', xy=(i + 0.6, class_counts[i + 1] * 0.5),
               xytext=(i + 0.4, class_counts[i] * 0.5),
               arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ratio = class_counts[i + 1] / max(class_counts[i], 1)
    ax.text(i + 0.5, max(class_counts[i], class_counts[i + 1]) * 0.55,
            f'×{ratio:.1f}', ha='center', fontsize=9, color='red', fontweight='bold')

ax.set_xticks(range(len(levels)))
ax.set_xticklabels(levels, fontsize=11)
ax.set_ylabel('Number of Equivalence Classes', fontsize=12)
ax.set_title('Strict Refinement Chain of Filtration Invariants\n'
             f'({len(profiles)} profiles, orders | {N}, {max_level+1} levels)',
             fontsize=13, fontweight='bold')

# Annotation
ax.text(0.5, -0.15,
        'Each finer invariant splits equivalence classes further.\n'
        'The primewise spectrum is strictly between global and full — '
        'it captures information the global set loses.',
        transform=ax.transAxes, ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('refinement_chain.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: refinement_chain.png")
