"""
Visualization 2: Witness Improvement via Localization

Shows the distribution of interleaving distance improvements
achieved by localizing at different primes. Demonstrates that
localization can strictly reduce the interleaving distance.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from dataclasses import dataclass, field
from typing import List, Set, Optional, Dict, Tuple

# Inline all needed classes and functions
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

# Run experiment
random.seed(2025)
n_trials = 2000
primes = [2, 3, 5, 7]
improvements: Dict[int, List[int]] = {p: [] for p in primes}
all_original_dists = []
all_best_localized = []

for _ in range(n_trials):
    F = random_persistence_module(length=12, primes=(2, 3, 5, 7))
    G = random_persistence_module(length=12, primes=(2, 3, 5, 7))
    gb_F = F.global_torsion_birth()
    gb_G = G.global_torsion_birth()
    if gb_F is None or gb_G is None: continue
    global_dist = abs(gb_F - gb_G)
    all_original_dists.append(global_dist)

    best_loc_dist = global_dist
    for p in primes:
        F_loc = F.localize_at(p); G_loc = G.localize_at(p)
        fb = F_loc.global_torsion_birth(); gb = G_loc.global_torsion_birth()
        if fb is None and gb is None: loc_dist = 0
        elif fb is not None and gb is not None: loc_dist = abs(fb - gb)
        else: continue
        if loc_dist < global_dist:
            improvements[p].append(global_dist - loc_dist)
        best_loc_dist = min(best_loc_dist, loc_dist)
    all_best_localized.append(best_loc_dist)

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Improvement distribution by prime
ax1 = axes[0, 0]
colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800']
positions = []
data_to_plot = []
for i, p in enumerate(primes):
    if improvements[p]:
        data_to_plot.append(improvements[p])
        positions.append(i)

bp = ax1.boxplot(data_to_plot, positions=positions, patch_artist=True, widths=0.6)
for patch, color in zip(bp['boxes'], colors[:len(data_to_plot)]):
    patch.set_facecolor(color)
    patch.set_alpha(0.6)
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([f'p={p}' for p in primes])
ax1.set_ylabel('Distance Improvement')
ax1.set_title('Distribution of Improvements by Prime', fontweight='bold')
ax1.grid(axis='y', alpha=0.3)

# Plot 2: Number of improvements by prime
ax2 = axes[0, 1]
counts = [len(improvements[p]) for p in primes]
bars = ax2.bar([f'p={p}' for p in primes], counts, color=colors, alpha=0.7)
for bar, count in zip(bars, counts):
    ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 5,
             str(count), ha='center', va='bottom', fontweight='bold')
ax2.set_ylabel('Number of Improvements')
ax2.set_title(f'Frequency of Strict Improvement ({n_trials} trials)', fontweight='bold')
ax2.grid(axis='y', alpha=0.3)

# Plot 3: Original vs best localized distance
ax3 = axes[1, 0]
max_dist = max(max(all_original_dists), max(all_best_localized)) + 1
ax3.scatter(all_original_dists, all_best_localized, alpha=0.1, s=10, c='#2196F3')
ax3.plot([0, max_dist], [0, max_dist], 'r--', linewidth=1, label='No improvement')
ax3.set_xlabel('Original Global Distance')
ax3.set_ylabel('Best Localized Distance')
ax3.set_title('Global vs Best Localized Distance', fontweight='bold')
ax3.legend()
ax3.grid(alpha=0.3)
ax3.set_xlim(-0.5, max_dist)
ax3.set_ylim(-0.5, max_dist)

# Plot 4: Histogram of improvement ratios
ax4 = axes[1, 1]
ratios = []
for orig, loc in zip(all_original_dists, all_best_localized):
    if orig > 0:
        ratios.append(1 - loc / orig)
if ratios:
    ax4.hist(ratios, bins=30, color='#9C27B0', alpha=0.7, edgecolor='white')
    mean_ratio = np.mean(ratios)
    ax4.axvline(mean_ratio, color='red', linestyle='--', linewidth=2,
                label=f'Mean: {mean_ratio:.2%}')
    ax4.legend()
ax4.set_xlabel('Relative Improvement (1 - localized/original)')
ax4.set_ylabel('Frequency')
ax4.set_title('Distribution of Relative Improvement', fontweight='bold')
ax4.grid(axis='y', alpha=0.3)

fig.suptitle('Witness Improvement via Prime Localization\n'
             'Localization can strictly reduce interleaving distances',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_witness_improvement.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_improvement.png")
