"""
Visualization 3: Birth Set Identification Theorem

Verifies computationally that PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))
across many random examples and visualizes the result.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from dataclasses import dataclass, field
from typing import List, Set, Optional

# Inline all needed classes
@dataclass
class FGAbGroup:
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)
    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])
    def has_p_torsion(self, p: int) -> bool:
        return any(d % p == 0 for d in self.torsion_factors)
    def has_global_torsion(self) -> bool:
        return len(self.torsion_factors) > 0
    def p_primary_component(self, p: int) -> 'FGAbGroup':
        p_factors = []
        for d in self.torsion_factors:
            pk = 1; temp = d
            while temp % p == 0: pk *= p; temp //= p
            if pk > 1: p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)

@dataclass
class PersistenceModule:
    groups: List[FGAbGroup]
    def p_torsion_birth(self, p: int) -> Optional[int]:
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p): return i
        return None
    def global_torsion_birth(self) -> Optional[int]:
        for i, g in enumerate(self.groups):
            if g.has_global_torsion(): return i
        return None
    def localize_at(self, p: int) -> 'PersistenceModule':
        return PersistenceModule([g.p_primary_component(p) for g in self.groups])

def random_persistence_module(length=10, primes=(2,3,5), max_power=2):
    groups = []; acc_torsion = []; cur_free = random.randint(0, 2)
    for i in range(length):
        if random.random() < 0.3:
            p = random.choice(primes); k = random.randint(1, max_power)
            acc_torsion.append(p ** k)
        if random.random() < 0.2: cur_free += 1
        groups.append(FGAbGroup(free_rank=cur_free, torsion_factors=list(acc_torsion)))
    return PersistenceModule(groups=groups)

# Run verification
random.seed(42)
primes = [2, 3, 5, 7]
n_modules = 500
n_verified = 0
n_total = 0

# Track birth index pairs for scatter plot
p_births_list = {p: [] for p in primes}
loc_births_list = {p: [] for p in primes}

for _ in range(n_modules):
    F = random_persistence_module(length=15, primes=(2, 3, 5, 7), max_power=3)
    for p in primes:
        n_total += 1
        pb = F.p_torsion_birth(p)
        F_loc = F.localize_at(p)
        lb = F_loc.global_torsion_birth()

        if pb == lb:
            n_verified += 1

        # Store for plotting (use -1 for None)
        p_births_list[p].append(pb if pb is not None else -1)
        loc_births_list[p].append(lb if lb is not None else -1)

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for idx, (ax, p) in enumerate(zip(axes.flat, primes)):
    pb = np.array(p_births_list[p])
    lb = np.array(loc_births_list[p])

    # Filter out -1 (None) vs -1 (None) — these are matching empty sets
    both_none = (pb == -1) & (lb == -1)
    both_some = (pb != -1) & (lb != -1)
    mismatch = ~both_none & ~both_some

    # Perfect agreement line
    ax.plot([-1, 15], [-1, 15], 'r--', linewidth=1, alpha=0.5, label='Perfect agreement')

    # Plot matching cases
    if both_some.any():
        ax.scatter(pb[both_some], lb[both_some], alpha=0.3, s=30,
                  c='#2196F3', label=f'Both detected ({both_some.sum()})')

    if both_none.any():
        ax.scatter([-0.5], [-0.5], alpha=0.7, s=100, c='#4CAF50', marker='s',
                  label=f'Both empty ({both_none.sum()})')

    if mismatch.any():
        ax.scatter(pb[mismatch], lb[mismatch], alpha=0.7, s=50,
                  c='#E91E63', marker='x', label=f'Mismatch ({mismatch.sum()})')

    ax.set_xlabel('PTorsionBirthSet(p, F)')
    ax.set_ylabel('TorsionBirthSet(L_p(F))')
    ax.set_title(f'p = {p}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    ax.set_xlim(-1.5, 15)
    ax.set_ylim(-1.5, 15)
    ax.set_aspect('equal')

fig.suptitle(f'Birth Set Identification: PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))\n'
             f'Verified: {n_verified}/{n_total} cases ({100*n_verified/n_total:.1f}%)',
             fontsize=14, fontweight='bold')

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_birth_identification.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_birth_identification.png ({n_verified}/{n_total} verified)")
