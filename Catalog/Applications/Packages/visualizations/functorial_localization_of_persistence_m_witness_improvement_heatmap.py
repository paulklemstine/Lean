"""
Visualization: Witness Improvement via Localization

Shows how localizing at different primes can strictly reduce
the interleaving distance between persistence modules.

Creates a heatmap of interleaving distance lower bounds
across primes for random module pairs, illustrating Theorem 4.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass, field
import random


# ============================================================
# Inline implementations
# ============================================================

@dataclass
class FinAb:
    free_rank: int = 0
    torsion_orders: list = field(default_factory=list)

@dataclass
class PersMod:
    groups: list

def p_torsion_detected(G, p):
    return any(n % p == 0 for n in G.torsion_orders)

def p_primary_subgroup(G, p):
    orders = []
    for n in G.torsion_orders:
        pk, m = 1, n
        while m % p == 0:
            pk *= p
            m //= p
        if pk > 1:
            orders.append(pk)
    return FinAb(free_rank=0, torsion_orders=sorted(orders))

def localize(F, p):
    return PersMod(groups=[p_primary_subgroup(G, p) for G in F.groups])

def p_tor_birth(F, p):
    for i, G in enumerate(F.groups):
        if p_torsion_detected(G, p):
            return i
    return None

def prime_support(F):
    primes = set()
    for G in F.groups:
        for n in G.torsion_orders:
            m = n
            for p in range(2, m + 1):
                if p * p > m:
                    if m > 1:
                        primes.add(m)
                    break
                while m % p == 0:
                    primes.add(p)
                    m //= p
    return primes

def interleaving_lb(F, G):
    primes = prime_support(F) | prime_support(G)
    max_d = 0
    for p in primes:
        bF, bG = p_tor_birth(F, p), p_tor_birth(G, p)
        if bF is not None and bG is not None:
            max_d = max(max_d, abs(bF - bG))
        elif bF is not None or bG is not None:
            return None
    return max_d

def random_FinAb(rng):
    primes = [2, 3, 5]
    fr = rng.randint(0, 2)
    nt = rng.randint(0, 3)
    orders = [primes[rng.randint(0, 2)] ** rng.randint(1, 3) for _ in range(nt)]
    return FinAb(free_rank=fr, torsion_orders=sorted(orders))

def random_PersMod(rng, n=8):
    groups = []
    for i in range(n):
        if rng.random() < 0.25 and i < n // 2:
            groups.append(FinAb(free_rank=rng.randint(0, 2)))
        else:
            groups.append(random_FinAb(rng))
    return PersMod(groups=groups)


# ============================================================
# Generate data
# ============================================================

rng = random.Random(42)
n_pairs = 30
target_primes = [2, 3, 5]

# Matrix: rows = module pairs, cols = primes + global
data = np.full((n_pairs, len(target_primes) + 1), np.nan)
pair_labels = []
pair_count = 0

attempts = 0
while pair_count < n_pairs and attempts < 500:
    attempts += 1
    F = random_PersMod(rng)
    G = random_PersMod(rng)
    d_global = interleaving_lb(F, G)
    if d_global is None or d_global == 0:
        continue

    row = [d_global]
    for p in target_primes:
        Lp_F, Lp_G = localize(F, p), localize(G, p)
        d_loc = interleaving_lb(Lp_F, Lp_G)
        row.append(d_loc if d_loc is not None else 0)

    data[pair_count] = row
    pair_labels.append(f'Pair {pair_count+1}')
    pair_count += 1


# ============================================================
# Visualization
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 8), gridspec_kw={'width_ratios': [3, 1]})

# Heatmap
col_labels = ['Global'] + [f'L_{p}' for p in target_primes]
im = ax1.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax1.set_xticks(range(len(col_labels)))
ax1.set_xticklabels(col_labels, fontsize=12, fontweight='bold')
ax1.set_yticks(range(n_pairs))
ax1.set_yticklabels(pair_labels, fontsize=8)
ax1.set_xlabel('Distance Measure', fontsize=13)
ax1.set_ylabel('Module Pair', fontsize=13)
ax1.set_title('Interleaving Distance: Global vs. Localized\n(lower = better)',
              fontsize=14, fontweight='bold')

# Annotate cells
for i in range(n_pairs):
    for j in range(len(col_labels)):
        val = data[i, j]
        if not np.isnan(val):
            color = 'white' if val > np.nanmax(data) * 0.6 else 'black'
            ax1.text(j, i, f'{int(val)}', ha='center', va='center',
                    color=color, fontsize=9, fontweight='bold')

# Mark strict improvements
for i in range(n_pairs):
    for j in range(1, len(col_labels)):
        if not np.isnan(data[i, j]) and not np.isnan(data[i, 0]):
            if data[i, j] < data[i, 0]:
                ax1.add_patch(plt.Rectangle((j-0.5, i-0.5), 1, 1,
                             fill=False, edgecolor='#2ecc71', linewidth=2.5))

plt.colorbar(im, ax=ax1, label='Distance Lower Bound', shrink=0.8)

# Summary bar chart
improvements_by_prime = []
for j, p in enumerate(target_primes):
    count = sum(1 for i in range(n_pairs)
               if not np.isnan(data[i, j+1]) and not np.isnan(data[i, 0])
               and data[i, j+1] < data[i, 0])
    improvements_by_prime.append(count)

colors = ['#e74c3c', '#3498db', '#2ecc71']
bars = ax2.barh(range(len(target_primes)), improvements_by_prime,
               color=colors, alpha=0.8, edgecolor='white')
ax2.set_yticks(range(len(target_primes)))
ax2.set_yticklabels([f'p = {p}' for p in target_primes], fontsize=12)
ax2.set_xlabel('# Strict Improvements', fontsize=12)
ax2.set_title('Improvement Count\nby Prime', fontsize=13, fontweight='bold')
ax2.set_xlim(0, max(improvements_by_prime) + 2)

for bar, val in zip(bars, improvements_by_prime):
    ax2.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height()/2,
            f'{val}/{n_pairs}', ha='left', va='center', fontsize=11, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_witness_improvement.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_improvement.png")
