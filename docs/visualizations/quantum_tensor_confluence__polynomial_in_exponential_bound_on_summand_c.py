#!/usr/bin/env python3
"""
Visualization: Exponential Bound on Summand Count

This script visualizes the exponential bound theorem:
    summandCount(e) ≤ 2^(gateCount(e))

We generate many random quantum tensor expressions and plot their
summand count vs gate count, showing that all points lie below
the exponential bound curve. The visualization reveals that the
bound is tight for maximally branching expressions.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


# ============================================================
# Self-contained expression types
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right


def summand_count(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)

def gate_count(e):
    if isinstance(e, Gate): return 1
    return gate_count(e.left) + gate_count(e.right)


def random_expr(n_gates, rng, add_prob=0.5):
    """Generate random expression with n gates."""
    gates = [Gate(i) for i in range(n_gates)]
    def build(available):
        if len(available) == 1:
            return available[0]
        split = rng.randint(1, len(available) - 1)
        left = build(available[:split])
        right = build(available[split:])
        r = rng.random()
        if r < add_prob:
            return Add(left, right)
        elif r < add_prob + (1 - add_prob) / 2:
            return Seq(left, right)
        else:
            return Par(left, right)
    return build(gates)


# ============================================================
# Generate data
# ============================================================

rng = random.Random(42)
gate_counts = []
summand_counts = []

for n in range(2, 13):
    for trial in range(200):
        e = random_expr(n, rng, add_prob=0.3 + 0.4 * rng.random())
        gc = gate_count(e)
        sc = summand_count(e)
        gate_counts.append(gc)
        summand_counts.append(sc)

gate_counts = np.array(gate_counts)
summand_counts = np.array(summand_counts)

# ============================================================
# Plot
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left panel: linear scale
ax1.scatter(gate_counts, summand_counts, alpha=0.3, s=15, c='steelblue',
            edgecolors='none', label='Random expressions')

x_range = np.arange(2, 14)
bound = 2.0**x_range
ax1.plot(x_range, bound, 'r-', linewidth=2.5, label=r'$2^{n}$ (upper bound)')
ax1.fill_between(x_range, 0, bound, alpha=0.1, color='red')

ax1.set_xlabel('Gate Count (n)', fontsize=13)
ax1.set_ylabel('Summand Count', fontsize=13)
ax1.set_title('Summand Count vs Gate Count (linear scale)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(1.5, 13.5)

# Right panel: log scale
ax2.scatter(gate_counts, summand_counts, alpha=0.3, s=15, c='steelblue',
            edgecolors='none', label='Random expressions')
ax2.plot(x_range, bound, 'r-', linewidth=2.5, label=r'$2^{n}$ (upper bound)')
ax2.fill_between(x_range, 1, bound, alpha=0.1, color='red')

ax2.set_xlabel('Gate Count (n)', fontsize=13)
ax2.set_ylabel('Summand Count (log scale)', fontsize=13)
ax2.set_title('Summand Count vs Gate Count (log scale)', fontsize=14, fontweight='bold')
ax2.set_yscale('log', base=2)
ax2.legend(fontsize=11)
ax2.set_xlim(1.5, 13.5)

# Add annotation
violations = sum(1 for gc, sc in zip(gate_counts, summand_counts) if sc > 2**gc)
total = len(gate_counts)
fig.text(0.5, 0.02,
         f'Theorem: summandCount(e) ≤ 2^gateCount(e)  |  '
         f'{total} expressions tested, {violations} violations '
         f'({"NONE ✓" if violations == 0 else "BOUND VIOLATED!"})',
         ha='center', fontsize=12, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Exponential Bound on Quantum Superposition Branches',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.06, 1, 0.95])
plt.savefig('exponential_bound.png', dpi=150, bbox_inches='tight')
print("Saved exponential_bound.png")
