"""
Visualization: Stability Comparison — Global vs Primewise

Shows how the interleaving distance decomposes across prime channels,
demonstrating that primewise stability can be strictly better than
global stability. This is the computational evidence for the witness
improvement conjecture.
"""
import matplotlib.pyplot as plt
import numpy as np
import random

# ── Self-contained classes ────────────────────────────────────────

class FGAbGroup:
    def __init__(self, free_rank=0, torsion_parts=None):
        self.free_rank = free_rank
        self.torsion_parts = torsion_parts or {}
    def has_p_torsion(self, p):
        return p in self.torsion_parts and len(self.torsion_parts[p]) > 0
    def has_any_torsion(self):
        return any(len(e) > 0 for e in self.torsion_parts.values())
    def localize_at(self, p):
        t = {p: list(self.torsion_parts[p])} if p in self.torsion_parts else {}
        return FGAbGroup(free_rank=self.free_rank, torsion_parts=t)

class ZPersModule:
    def __init__(self, groups, support_range):
        self.groups = groups
        self.support_range = support_range
    def obj(self, i):
        return self.groups.get(i, FGAbGroup())
    def has_p_torsion_at(self, p, i):
        return self.obj(i).has_p_torsion(p)
    def has_torsion_at(self, i):
        return self.obj(i).has_any_torsion()
    def localize_at(self, p):
        ng = {i: g.localize_at(p) for i, g in self.groups.items()
              if g.localize_at(p).has_any_torsion() or g.localize_at(p).free_rank > 0}
        return ZPersModule(groups=ng, support_range=self.support_range)

def torsion_birth(F):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_torsion_at(i):
            if all(not F.has_torsion_at(j) for j in range(lo, i)):
                return i
    return None

def p_torsion_birth(F, p):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_p_torsion_at(p, i):
            if all(not F.has_p_torsion_at(p, j) for j in range(lo, i)):
                return i
    return None

def random_module(n=10, primes=None, prob=0.25):
    if primes is None:
        primes = [2, 3, 5, 7]
    groups = {}
    active = {}
    for i in range(n):
        torsion = dict(active)
        for p in primes:
            if p not in active and random.random() < prob:
                active[p] = [random.randint(1, 2)]
                torsion[p] = active[p]
        if torsion:
            groups[i] = FGAbGroup(free_rank=1, torsion_parts=torsion)
        else:
            groups[i] = FGAbGroup(free_rank=1)
    return ZPersModule(groups=groups, support_range=(0, n - 1))

# ── Experiment: collect primewise vs global distances ─────────────

random.seed(123)
n_trials = 300
primes = [2, 3, 5, 7]

global_dists = []
primewise_dists = {p: [] for p in primes}
improvements = []

for _ in range(n_trials):
    F = random_module(12, primes, 0.3)
    G = random_module(12, primes, 0.3)

    gb_F = torsion_birth(F)
    gb_G = torsion_birth(G)
    if gb_F is not None and gb_G is not None:
        gd = abs(gb_F - gb_G)
        global_dists.append(gd)

        min_pd = float('inf')
        for p in primes:
            pb_F = p_torsion_birth(F, p)
            pb_G = p_torsion_birth(G, p)
            if pb_F is not None and pb_G is not None:
                pd = abs(pb_F - pb_G)
                primewise_dists[p].append(pd)
                min_pd = min(min_pd, pd)

        if min_pd < float('inf'):
            improvements.append(gd - min_pd)

# ── Create figure ─────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Panel 1: Distribution of global vs min-primewise distance
ax = axes[0, 0]
bins = np.arange(-0.5, max(max(global_dists, default=0), 8) + 1.5, 1)
ax.hist(global_dists, bins=bins, alpha=0.6, color='#2c3e50', label='Global', edgecolor='white')
min_pw = [min(primewise_dists[p][i] for p in primes if i < len(primewise_dists[p]))
          for i in range(min(len(primewise_dists[p]) for p in primes)) if
          any(i < len(primewise_dists[p]) for p in primes)]
if min_pw:
    ax.hist(min_pw, bins=bins, alpha=0.6, color='#e74c3c', label='Min primewise', edgecolor='white')
ax.set_xlabel('Birth Set Distance', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Global vs Best Primewise Distance\n(300 random module pairs)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.15)

# Panel 2: Improvement histogram
ax = axes[0, 1]
if improvements:
    bins_imp = np.arange(min(improvements) - 0.5, max(improvements) + 1.5, 1)
    colors_imp = ['#2ecc71' if v > 0 else '#95a5a6' if v == 0 else '#e74c3c' for v in sorted(set(improvements))]
    ax.hist(improvements, bins=bins_imp, alpha=0.7, color='#3498db', edgecolor='white')
    pos = sum(1 for x in improvements if x > 0)
    zero = sum(1 for x in improvements if x == 0)
    neg = sum(1 for x in improvements if x < 0)
    ax.axvline(0, color='black', linestyle='--', alpha=0.5)
    ax.text(0.95, 0.95, f'Improved: {pos}\nEqual: {zero}\nWorse: {neg}',
            transform=ax.transAxes, ha='right', va='top', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
ax.set_xlabel('Improvement (global − best primewise)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Witness Improvement via Localization\n(positive = localization helps)',
             fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.15)

# Panel 3: Per-prime distance distributions
ax = axes[1, 0]
prime_color_map = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#f39c12'}
positions = []
data = []
labels_p = []
for i, p in enumerate(primes):
    if primewise_dists[p]:
        data.append(primewise_dists[p])
        positions.append(i)
        labels_p.append(f'p={p}')

if data:
    bp = ax.boxplot(data, positions=positions, patch_artist=True, widths=0.6)
    for i, (patch, p) in enumerate(zip(bp['boxes'], primes)):
        patch.set_facecolor(prime_color_map[p])
        patch.set_alpha(0.6)
    if global_dists:
        ax.boxplot([global_dists], positions=[len(primes)], patch_artist=True,
                   widths=0.6, boxprops=dict(facecolor='#2c3e50', alpha=0.6))
        labels_p.append('Global')
    ax.set_xticks(list(range(len(labels_p))))
    ax.set_xticklabels(labels_p, fontsize=11)

ax.set_ylabel('Birth Set Distance', fontsize=11)
ax.set_title('Distance Distribution by Prime Channel\nvs Global Distance',
             fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.15, axis='y')

# Panel 4: Concrete example
ax = axes[1, 1]

# Specific example showing improvement
F_ex = ZPersModule(
    groups={
        0: FGAbGroup(free_rank=1),
        1: FGAbGroup(free_rank=1, torsion_parts={3: [1]}),
        3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
    },
    support_range=(0, 6)
)
G_ex = ZPersModule(
    groups={
        0: FGAbGroup(free_rank=1),
        2: FGAbGroup(free_rank=1, torsion_parts={3: [1]}),
        3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
    },
    support_range=(0, 6)
)

categories = ['Global', 'p=2', 'p=3']
F_births = [torsion_birth(F_ex), p_torsion_birth(F_ex, 2), p_torsion_birth(F_ex, 3)]
G_births = [torsion_birth(G_ex), p_torsion_birth(G_ex, 2), p_torsion_birth(G_ex, 3)]
distances_ex = []
for fb, gb in zip(F_births, G_births):
    if fb is not None and gb is not None:
        distances_ex.append(abs(fb - gb))
    else:
        distances_ex.append(0)

x_pos = np.arange(len(categories))
colors_ex = ['#2c3e50', '#e74c3c', '#3498db']

bars = ax.bar(x_pos, distances_ex, color=colors_ex, alpha=0.7, edgecolor='white', width=0.5)
for bar, d, fb, gb in zip(bars, distances_ex, F_births, G_births):
    label = f'd={d}'
    if fb is not None and gb is not None:
        label += f'\n({fb}↔{gb})'
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            label, ha='center', va='bottom', fontsize=9)

ax.set_xticks(x_pos)
ax.set_xticklabels(categories, fontsize=11)
ax.set_ylabel('Birth Distance', fontsize=11)
ax.set_title('Concrete Example: Primewise Can Beat Global\n'
             'F: 3-torsion at 1, 2-torsion at 3\n'
             'G: 3-torsion at 2, 2-torsion at 3',
             fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.15, axis='y')

plt.tight_layout()
plt.savefig('viz_stability_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_comparison.png")
