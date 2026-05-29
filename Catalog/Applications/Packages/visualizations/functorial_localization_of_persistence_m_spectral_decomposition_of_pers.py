"""
Visualization 1: Spectral Decomposition of Persistence Torsion

Shows how prime localization decomposes a persistence module's torsion
into independent prime channels, analogous to spectral analysis.
Each row shows a different prime channel, with color intensity indicating
the torsion rank at that index.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from dataclasses import dataclass, field
from typing import List, Set, Dict

# Inline all needed classes
@dataclass
class FGAbGroup:
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)
    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])
    def p_primary_component(self, p: int) -> 'FGAbGroup':
        p_factors = []
        for d in self.torsion_factors:
            pk = 1
            temp = d
            while temp % p == 0:
                pk *= p
                temp //= p
            if pk > 1:
                p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)
    def prime_support(self) -> Set[int]:
        primes = set()
        for d in self.torsion_factors:
            temp = d
            for p in range(2, temp + 1):
                if p * p > temp:
                    if temp > 1: primes.add(temp)
                    break
                while temp % p == 0:
                    primes.add(p)
                    temp //= p
        return primes

# Build example persistence module
length = 15
groups = [
    FGAbGroup(free_rank=3),
    FGAbGroup(free_rank=3),
    FGAbGroup(free_rank=3, torsion_factors=[2]),
    FGAbGroup(free_rank=3, torsion_factors=[2, 3]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 3]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 3, 5]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 9, 5]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 9, 5, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 9, 25, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 27, 25, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[16, 27, 25, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[16, 27, 125, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[32, 81, 125, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[32, 81, 125, 343]),
    FGAbGroup(free_rank=3, torsion_factors=[64, 243, 625, 343]),
]

primes = [2, 3, 5, 7]
prime_labels = ['p=2', 'p=3', 'p=5', 'p=7']

# Compute torsion rank at each index for each prime channel
data = np.zeros((len(primes) + 1, length))

# Global torsion rank
for j in range(length):
    data[0, j] = len(groups[j].torsion_factors)

# Per-prime torsion rank
for i, p in enumerate(primes):
    for j in range(length):
        loc = groups[j].p_primary_component(p)
        data[i + 1, j] = len(loc.torsion_factors)

# Find birth indices
births = {}
for i, p in enumerate(primes):
    for j in range(length):
        loc = groups[j].p_primary_component(p)
        if len(loc.torsion_factors) > 0:
            births[p] = j
            break

fig, axes = plt.subplots(len(primes) + 1, 1, figsize=(12, 8), sharex=True)

colors = ['#2196F3', '#E91E63', '#4CAF50', '#FF9800', '#9C27B0']
row_labels = ['Global'] + prime_labels

for i, (ax, label, color) in enumerate(zip(axes, row_labels, colors)):
    bars = ax.bar(range(length), data[i], color=color, alpha=0.7, edgecolor='white')

    # Mark birth index
    if i > 0 and primes[i-1] in births:
        b = births[primes[i-1]]
        ax.axvline(x=b, color='red', linestyle='--', alpha=0.5, linewidth=2)
        ax.annotate(f'birth', (b, data[i, b]), textcoords="offset points",
                   xytext=(10, 5), fontsize=8, color='red', fontweight='bold')

    ax.set_ylabel(label, fontsize=11, fontweight='bold', rotation=0, labelpad=50)
    ax.set_ylim(0, max(data[i]) + 1 if max(data[i]) > 0 else 1)
    ax.set_yticks(range(int(max(data[i])) + 2))
    ax.grid(axis='y', alpha=0.3)

axes[-1].set_xlabel('Filtration Index', fontsize=12)
axes[-1].set_xticks(range(length))

fig.suptitle('Spectral Decomposition of Persistence Torsion\n'
             'Each prime channel isolates independent torsion information',
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
