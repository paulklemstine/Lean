"""
Visualization: Witness Improvement Under Localization

Shows how localization at specific primes can strictly improve interleaving
distances between persistence modules. Compares global vs. prime-local
distances across many random module pairs.

WHAT THIS VISUALIZES:
A scatter plot comparing the global interleaving distance bound (x-axis)
with the best prime-local interleaving distance bound (y-axis) across
many random persistence module pairs. Points below the diagonal represent
strict improvements: cases where localization sharpens the stability witness.
This provides computational evidence for the strict improvement conjecture.
"""

import matplotlib.pyplot as plt
import numpy as np
import random


# --- Inline all needed functions ---
def prime_factors(n):
    factors = []
    d = 2
    while d * d <= abs(n):
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if abs(n) > 1:
        factors.append(abs(n))
    return factors

def distinct_prime_factors(n):
    return set(prime_factors(n))

def p_part(n, p):
    result = 1
    while n % p == 0:
        result *= p
        n //= p
    return result


class FGAbGroup:
    def __init__(self, free_rank, torsion_coeffs=None):
        self.free_rank = free_rank
        self.torsion_coeffs = sorted([c for c in (torsion_coeffs or []) if c >= 2])

    def has_p_torsion(self, p):
        return any(c % p == 0 for c in self.torsion_coeffs)

    def has_global_torsion(self):
        return len(self.torsion_coeffs) > 0

    def prime_support(self):
        primes = set()
        for c in self.torsion_coeffs:
            primes |= distinct_prime_factors(c)
        return primes

    def localize_at(self, p):
        new_torsion = [pk for c in self.torsion_coeffs if (pk := p_part(c, p)) > 1]
        return FGAbGroup(self.free_rank, new_torsion)


class PersistenceModule:
    def __init__(self, groups):
        self.groups = groups

    def p_torsion_birth(self, p):
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p):
                return i
        return None

    def global_torsion_birth(self):
        for i, g in enumerate(self.groups):
            if g.has_global_torsion():
                return i
        return None

    def p_torsion_birth_set(self, p):
        b = self.p_torsion_birth(p)
        return {b} if b is not None else set()

    def global_torsion_birth_set(self):
        b = self.global_torsion_birth()
        return {b} if b is not None else set()

    def prime_support(self):
        s = set()
        for g in self.groups:
            s |= g.prime_support()
        return s


def hausdorff_distance(A, B):
    if not A and not B:
        return 0
    if not A or not B:
        return 10**9
    d1 = max(min(abs(a - b) for b in B) for a in A)
    d2 = max(min(abs(a - b) for a in A) for b in B)
    return max(d1, d2)


def random_persistence_module(length=10, primes=None):
    if primes is None:
        primes = [2, 3, 5, 7]
    groups = []
    current_torsion = []
    free_rank = random.randint(0, 2)
    for _ in range(length):
        if random.random() < 0.35:
            p = random.choice(primes)
            k = random.randint(1, 3)
            current_torsion.append(p ** k)
        groups.append(FGAbGroup(free_rank, list(current_torsion)))
    return PersistenceModule(groups)


# --- Generate data ---
random.seed(42)
n_trials = 500
global_dists = []
best_local_dists = []
improving_primes = []
categories = []  # 'improved', 'equal', or 'na'

for _ in range(n_trials):
    F = random_persistence_module(length=12, primes=[2, 3, 5, 7])
    G = random_persistence_module(length=12, primes=[2, 3, 5, 7])

    d_global = hausdorff_distance(F.global_torsion_birth_set(),
                                   G.global_torsion_birth_set())
    if d_global == 0 or d_global >= 10**9:
        continue

    all_primes = F.prime_support() | G.prime_support()
    if not all_primes:
        continue

    best_local = d_global
    best_p = None
    for p in all_primes:
        d_local = hausdorff_distance(F.p_torsion_birth_set(p),
                                      G.p_torsion_birth_set(p))
        if d_local < 10**9 and d_local < best_local:
            best_local = d_local
            best_p = p

    global_dists.append(d_global)
    best_local_dists.append(best_local)
    if best_local < d_global:
        categories.append('improved')
        improving_primes.append(best_p)
    else:
        categories.append('equal')
        improving_primes.append(None)


# --- Plot ---
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Scatter plot
improved_x = [g for g, c in zip(global_dists, categories) if c == 'improved']
improved_y = [l for l, c in zip(best_local_dists, categories) if c == 'improved']
equal_x = [g for g, c in zip(global_dists, categories) if c == 'equal']
equal_y = [l for l, c in zip(best_local_dists, categories) if c == 'equal']

max_d = max(max(global_dists), max(best_local_dists)) + 1

# Add jitter for visibility
jitter = 0.15
improved_x_j = [x + random.gauss(0, jitter) for x in improved_x]
improved_y_j = [y + random.gauss(0, jitter) for y in improved_y]
equal_x_j = [x + random.gauss(0, jitter) for x in equal_x]
equal_y_j = [y + random.gauss(0, jitter) for y in equal_y]

ax1.plot([0, max_d], [0, max_d], 'k--', alpha=0.3, linewidth=1, label='No improvement')
ax1.scatter(equal_x_j, equal_y_j, c='#bdc3c7', s=25, alpha=0.5,
            edgecolors='none', label=f'Equal ({len(equal_x)})')
ax1.scatter(improved_x_j, improved_y_j, c='#e74c3c', s=40, alpha=0.7,
            edgecolors='#c0392b', linewidth=0.5,
            label=f'Improved ({len(improved_x)})')

ax1.set_xlabel('Global Interleaving Distance Bound', fontsize=12)
ax1.set_ylabel('Best Prime-Local Distance Bound', fontsize=12)
ax1.set_title('Witness Improvement Under Localization', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim(-0.5, max_d)
ax1.set_ylim(-0.5, max_d)
ax1.set_aspect('equal')
ax1.grid(alpha=0.2)

# Annotate improvement region
ax1.fill_between([0, max_d], [0, 0], [0, max_d], alpha=0.05, color='#e74c3c')
ax1.text(max_d * 0.7, max_d * 0.15, 'Improvement\nRegion',
         fontsize=11, color='#e74c3c', alpha=0.7, ha='center', style='italic')

# Right: Histogram of improvement amounts
improvements = [g - l for g, l, c in zip(global_dists, best_local_dists, categories)
                if c == 'improved']
if improvements:
    ax2.hist(improvements, bins=range(0, max(improvements) + 2),
             color='#e74c3c', alpha=0.7, edgecolor='white', linewidth=0.5,
             align='left')
    ax2.set_xlabel('Amount of Distance Improvement (δ_global - δ_local)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Strict Improvements', fontsize=13, fontweight='bold')
    ax2.grid(axis='y', alpha=0.3)

    pct = 100 * len(improvements) / len(global_dists)
    ax2.text(0.95, 0.95,
             f'{len(improvements)}/{len(global_dists)} pairs improved\n({pct:.1f}%)',
             transform=ax2.transAxes, fontsize=11, ha='right', va='top',
             bbox=dict(boxstyle='round', facecolor='#e74c3c', alpha=0.15))
else:
    ax2.text(0.5, 0.5, 'No improvements found', transform=ax2.transAxes,
             ha='center', va='center', fontsize=14)

plt.tight_layout()
plt.savefig('viz_witness_improvement.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
print("Saved viz_witness_improvement.png")
