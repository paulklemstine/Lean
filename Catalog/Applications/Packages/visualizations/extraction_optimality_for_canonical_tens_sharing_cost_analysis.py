#!/usr/bin/env python3
"""
Visualization: Sharing Cost Reduction via Canonical Normalization

This script visualizes how canonical normalization reduces the sharing cost
(number of distinct variables) compared to random equivalent expressions.
It produces a scatter plot showing original vs. canonical sharing cost for
1000 random tensor expressions, demonstrating the optimality theorem.
"""

import random
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Dict, Set


# ── Self-contained expression AST and algorithms ──

@dataclass(frozen=True)
class TExpr:
    pass

@dataclass(frozen=True)
class Var(TExpr):
    n: int

@dataclass(frozen=True)
class Zero(TExpr):
    pass

@dataclass(frozen=True)
class Add(TExpr):
    left: TExpr
    right: TExpr

@dataclass(frozen=True)
class Smul(TExpr):
    coeff: int
    expr: TExpr


def coeff_of(e, n):
    if isinstance(e, Var): return 1 if e.n == n else 0
    if isinstance(e, Zero): return 0
    if isinstance(e, Add): return coeff_of(e.left, n) + coeff_of(e.right, n)
    if isinstance(e, Smul): return e.coeff * coeff_of(e.expr, n)
    return 0

def distinct_vars(e):
    if isinstance(e, Var): return {e.n}
    if isinstance(e, Zero): return set()
    if isinstance(e, Add): return distinct_vars(e.left) | distinct_vars(e.right)
    if isinstance(e, Smul): return distinct_vars(e.expr)
    return set()

def effective_support(e):
    return {v: coeff_of(e, v) for v in distinct_vars(e) if coeff_of(e, v) != 0}

def sharing_cost(e):
    return len(distinct_vars(e))

def canon_sharing_cost(e):
    return len(effective_support(e))

def tree_size(e):
    if isinstance(e, (Var, Zero)): return 1
    if isinstance(e, Add): return 1 + tree_size(e.left) + tree_size(e.right)
    if isinstance(e, Smul): return 1 + tree_size(e.expr)
    return 1

def random_expr(max_vars=6, max_depth=5, depth=0):
    if depth >= max_depth or random.random() < 0.3:
        if random.random() < 0.08:
            return Zero()
        return Var(random.randint(0, max_vars - 1))
    if random.random() < 0.6:
        return Add(random_expr(max_vars, max_depth, depth+1),
                   random_expr(max_vars, max_depth, depth+1))
    else:
        k = random.randint(-3, 3)
        return Smul(k, random_expr(max_vars, max_depth, depth+1))


# ── Generate data ──

random.seed(42)
n_samples = 1000

orig_costs = []
canon_costs = []
sizes = []

for _ in range(n_samples):
    e = random_expr(max_vars=6, max_depth=5)
    oc = sharing_cost(e)
    cc = canon_sharing_cost(e)
    sz = tree_size(e)
    orig_costs.append(oc)
    canon_costs.append(cc)
    sizes.append(sz)

orig_costs = np.array(orig_costs)
canon_costs = np.array(canon_costs)
sizes = np.array(sizes)

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Original vs Canonical sharing cost
ax1 = axes[0]
jitter = np.random.normal(0, 0.1, n_samples)
ax1.scatter(orig_costs + jitter, canon_costs + jitter*0.5,
            alpha=0.3, s=10, c='steelblue')
ax1.plot([0, 7], [0, 7], 'r--', linewidth=1.5, label='y = x (no improvement)')
ax1.set_xlabel('Original Sharing Cost', fontsize=12)
ax1.set_ylabel('Canonical Sharing Cost', fontsize=12)
ax1.set_title('Sharing Cost: Original vs. Canonical', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_aspect('equal')
ax1.set_xlim(-0.5, 7)
ax1.set_ylim(-0.5, 7)

# Panel 2: Histogram of savings
ax2 = axes[1]
savings = orig_costs - canon_costs
bins = np.arange(-0.5, max(savings) + 1.5, 1)
ax2.hist(savings, bins=bins, color='darkorange', edgecolor='black', alpha=0.8)
ax2.set_xlabel('Sharing Cost Reduction', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Cost Savings\n(Theorem 3: always ≥ 0)', fontsize=13, fontweight='bold')
ax2.axvline(x=0, color='red', linestyle='--', linewidth=1.5, label='Zero savings')
ax2.legend(fontsize=10)

# Panel 3: Compression ratio vs tree size
ax3 = axes[2]
ratios = canon_costs / np.maximum(orig_costs, 1)
ax3.scatter(sizes, ratios, alpha=0.3, s=10, c='seagreen')
ax3.set_xlabel('Tree Size (nodes)', fontsize=12)
ax3.set_ylabel('Compression Ratio\n(canonical/original)', fontsize=12)
ax3.set_title('Compression Ratio vs. Expression Size', fontsize=13, fontweight='bold')
ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='Ratio = 1 (no compression)')
ax3.legend(fontsize=10)
ax3.set_ylim(-0.05, 1.5)

plt.tight_layout()
plt.savefig('sharing_cost_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: sharing_cost_analysis.png")
