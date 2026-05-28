#!/usr/bin/env python3
"""
Visualize Critical Pair Growth vs. System Size.

This script creates a heatmap showing how the number of critical pairs
grows with the size bound and the number of rewrite rules, illustrating
the computational tractability of bounded critical pair analysis for
Miller-pattern systems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional, List


# Inline the term representation (self-contained)
class TK(Enum):
    VAR = auto()
    APP = auto()
    LAM = auto()

@dataclass(frozen=True)
class T:
    kind: TK
    idx: int = -1
    left: Optional['T'] = None
    right: Optional['T'] = None
    body: Optional['T'] = None

    @staticmethod
    def v(i): return T(TK.VAR, idx=i)
    @staticmethod
    def a(s, t): return T(TK.APP, left=s, right=t)
    @staticmethod
    def l(b): return T(TK.LAM, body=b)

    def size(self):
        if self.kind == TK.VAR: return 1
        if self.kind == TK.APP: return 1 + self.left.size() + self.right.size()
        return 1 + self.body.size()

    def subterms(self):
        if self.kind == TK.VAR: return [self]
        if self.kind == TK.APP: return [self] + self.left.subterms() + self.right.subterms()
        return [self] + self.body.subterms()


def syn_match(p, q):
    if p.kind == TK.VAR or q.kind == TK.VAR: return True
    if p.kind != q.kind: return False
    if p.kind == TK.APP: return syn_match(p.left, q.left) and syn_match(p.right, q.right)
    if p.kind == TK.LAM: return syn_match(p.body, q.body)
    return False


def count_cps(rules, bound):
    count = 0
    for r1_lhs, _ in rules:
        for r2_lhs, _ in rules:
            for sub in r1_lhs.subterms():
                if syn_match(sub, r2_lhs) and r1_lhs.size() + r2_lhs.size() <= bound:
                    count += 1
    return count


# Generate benchmark rule sets of increasing size
def make_rules(n_rules):
    """Generate n_rules synthetic rewrite rules."""
    rules = []
    for i in range(n_rules):
        # Rule: f_i(x, g_i(y)) → h_i(x, y)
        x, y = T.v(0), T.v(1)
        lhs = T.a(T.a(T.v(i + 10), x), T.a(T.v(i + 20), y))
        rhs = T.a(T.v(i + 30), T.a(x, y))
        rules.append((lhs, rhs))
    return rules


# Compute critical pair counts
rule_counts = [1, 2, 3, 4, 5, 6, 8, 10]
bounds = [5, 10, 15, 20, 25, 30, 40, 50]

data = np.zeros((len(rule_counts), len(bounds)))

for i, n_rules in enumerate(rule_counts):
    rules = make_rules(n_rules)
    for j, bound in enumerate(bounds):
        data[i, j] = count_cps(rules, bound)

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
im = ax1.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax1.set_xticks(range(len(bounds)))
ax1.set_xticklabels(bounds)
ax1.set_yticks(range(len(rule_counts)))
ax1.set_yticklabels(rule_counts)
ax1.set_xlabel('Size Bound N', fontsize=12)
ax1.set_ylabel('Number of Rules', fontsize=12)
ax1.set_title('Critical Pair Count by System Size & Bound', fontsize=13,
              fontweight='bold')

# Add value annotations
for i in range(len(rule_counts)):
    for j in range(len(bounds)):
        val = int(data[i, j])
        color = 'white' if val > data.max() * 0.6 else 'black'
        ax1.text(j, i, str(val), ha='center', va='center',
                fontsize=8, color=color)

plt.colorbar(im, ax=ax1, label='Number of Critical Pairs')

# Growth curve
for i, n_rules in enumerate([2, 4, 6, 10]):
    idx = rule_counts.index(n_rules)
    ax2.plot(bounds, data[idx, :], 'o-', label=f'{n_rules} rules',
             linewidth=2, markersize=6)

ax2.set_xlabel('Size Bound N', fontsize=12)
ax2.set_ylabel('Number of Critical Pairs', fontsize=12)
ax2.set_title('Critical Pair Growth vs. Size Bound', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add annotation about quadratic conjecture
ax2.text(0.05, 0.95,
         'Conjecture: First non-joinable CP\n'
         'appears at size ≤ O(max_rule²)',
         transform=ax2.transAxes, fontsize=9,
         verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='#f0f0f0', alpha=0.8))

plt.tight_layout()
plt.savefig('critical_pair_growth.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: critical_pair_growth.png")
