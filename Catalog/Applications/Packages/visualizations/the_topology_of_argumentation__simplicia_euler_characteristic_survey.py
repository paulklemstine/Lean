"""
Visualization: Euler Characteristic Survey
=============================================
Computes the Euler characteristic of the argumentation complex for
many random frameworks and visualizes the distribution, testing the
conjecture that χ relates to the semantic properties of the framework.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from itertools import combinations
from collections import defaultdict


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = frozenset(arguments)
        self.attacks = frozenset(attacks)
        self._attackers = defaultdict(set)
        for a, b in attacks:
            self._attackers[b].add(a)

    def attackers_of(self, a):
        return self._attackers.get(a, set())

    def is_conflict_free(self, S):
        for a, b in self.attacks:
            if a in S and b in S:
                return False
        return True

    def is_acceptable(self, S, a):
        for b in self.attackers_of(a):
            if not any(c in S for c in self.attackers_of(b)):
                return False
        return True

    def is_admissible(self, S):
        if not self.is_conflict_free(S):
            return False
        return all(self.is_acceptable(S, a) for a in S)

    def preferred_extensions(self):
        args = sorted(self.arguments)
        admissible = []
        for r in range(len(args) + 1):
            for sub in combinations(args, r):
                S = frozenset(sub)
                if self.is_admissible(S):
                    admissible.append(S)
        return [S for S in admissible if not any(S < T for T in admissible)]

    def grounded_extension(self):
        S = frozenset()
        for _ in range(len(self.arguments) + 1):
            S_new = frozenset(a for a in self.arguments
                              if self.is_acceptable(S, a))
            if S_new == S:
                return S
            S = S_new
        return S

    def euler_characteristic(self):
        chi = 0
        args = sorted(self.arguments)
        for r in range(1, len(args) + 1):
            for sub in combinations(args, r):
                if self.is_conflict_free(frozenset(sub)):
                    chi += (-1) ** (r - 1)
        return chi


# Generate random frameworks and compute properties
random.seed(42)
n_samples = 200
data = []

for _ in range(n_samples):
    n = random.randint(3, 6)
    args = set(range(n))
    p = random.uniform(0.0, 0.6)
    attacks = set()
    for a in args:
        for b in args:
            if a != b and random.random() < p:
                attacks.add((a, b))

    AF = ArgFramework(arguments=args, attacks=attacks)
    chi = AF.euler_characteristic()
    pref = AF.preferred_extensions()
    grd = AF.grounded_extension()

    data.append({
        'n': n,
        'r': len(attacks),
        'chi': chi,
        'n_pref': len(pref),
        'grd_size': len(grd),
        'density': len(attacks) / (n * (n - 1)) if n > 1 else 0
    })

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Euler Characteristic of Argumentation Complexes\n(Survey of 200 Random Frameworks)',
             fontsize=14, fontweight='bold')

# Plot 1: χ vs attack density
ax1 = axes[0, 0]
densities = [d['density'] for d in data]
chis = [d['chi'] for d in data]
colors_by_n = {3: '#E74C3C', 4: '#3498DB', 5: '#2ECC71', 6: '#9B59B6'}
for d in data:
    ax1.scatter(d['density'], d['chi'], c=colors_by_n.get(d['n'], 'gray'),
                s=30, alpha=0.6, edgecolors='none')
ax1.set_xlabel('Attack Density |R|/(|A|·(|A|-1))', fontsize=10)
ax1.set_ylabel('Euler Characteristic χ', fontsize=10)
ax1.set_title('χ vs Attack Density', fontsize=11)
ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='χ=1 (full simplex)')
ax1.legend(fontsize=8)

# Plot 2: χ vs number of preferred extensions
ax2 = axes[0, 1]
n_prefs = [d['n_pref'] for d in data]
ax2.scatter(n_prefs, chis, c='#3498DB', s=30, alpha=0.5, edgecolors='none')
ax2.set_xlabel('Number of Preferred Extensions', fontsize=10)
ax2.set_ylabel('Euler Characteristic χ', fontsize=10)
ax2.set_title('χ vs |Preferred Extensions|', fontsize=11)

# Plot 3: Distribution of χ
ax3 = axes[1, 0]
chi_values = [d['chi'] for d in data]
bins = range(min(chi_values) - 1, max(chi_values) + 2)
ax3.hist(chi_values, bins=bins, color='#2ECC71', edgecolor='white', linewidth=1.5, align='left')
ax3.set_xlabel('Euler Characteristic χ', fontsize=10)
ax3.set_ylabel('Frequency', fontsize=10)
ax3.set_title('Distribution of χ', fontsize=11)
ax3.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='χ=1')
ax3.legend(fontsize=8)

# Plot 4: |Preferred| vs |Grounded|
ax4 = axes[1, 1]
grd_sizes = [d['grd_size'] for d in data]
sc = ax4.scatter(grd_sizes, n_prefs, c=chis, cmap='RdYlBu', s=40,
                 alpha=0.7, edgecolors='gray', linewidth=0.5)
ax4.set_xlabel('Grounded Extension Size |GE|', fontsize=10)
ax4.set_ylabel('Number of Preferred Extensions', fontsize=10)
ax4.set_title('Semantic vs Topological Structure', fontsize=11)
plt.colorbar(sc, ax=ax4, label='χ')

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('euler_survey.png', dpi=150, bbox_inches='tight')
print("Saved: euler_survey.png")
