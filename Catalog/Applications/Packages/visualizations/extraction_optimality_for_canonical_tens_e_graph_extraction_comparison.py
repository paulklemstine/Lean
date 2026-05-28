#!/usr/bin/env python3
"""
Visualization: E-Graph Extraction vs. Canonical Normalization

This script visualizes the agreement between bounded e-graph extraction
and canonical normalization, demonstrating the extraction optimality theorem.
It shows that for tensor expressions, canonical normalization directly
computes what e-graph saturation + extraction would find.
"""

import random
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Set


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

def sharing_cost(e):
    return len(distinct_vars(e))

def effective_support(e):
    return {v: coeff_of(e, v) for v in distinct_vars(e) if coeff_of(e, v) != 0}

def canon_sharing_cost(e):
    return len(effective_support(e))

def tree_size(e):
    if isinstance(e, (Var, Zero)): return 1
    if isinstance(e, Add): return 1 + tree_size(e.left) + tree_size(e.right)
    if isinstance(e, Smul): return 1 + tree_size(e.expr)
    return 1

def ac_rewrites(e):
    results = []
    if isinstance(e, Add):
        results.append(Add(e.right, e.left))
        if isinstance(e.left, Add):
            results.append(Add(e.left.left, Add(e.left.right, e.right)))
        if isinstance(e.right, Add):
            results.append(Add(Add(e.left, e.right.left), e.right.right))
        if isinstance(e.left, Zero): results.append(e.right)
        if isinstance(e.right, Zero): results.append(e.left)
        if (isinstance(e.left, Smul) and isinstance(e.right, Smul)
                and e.left.expr == e.right.expr):
            c = e.left.coeff + e.right.coeff
            results.append(Zero() if c == 0 else Smul(c, e.left.expr))
    if isinstance(e, Smul):
        if isinstance(e.expr, Add):
            results.append(Add(Smul(e.coeff, e.expr.left), Smul(e.coeff, e.expr.right)))
        if e.coeff == 0:
            results.append(Zero())
    return results

def extract_min_sharing(e, fuel=50):
    visited = {e}
    frontier = [e]
    best = e
    best_sc = sharing_cost(e)
    best_ts = tree_size(e)
    for _ in range(fuel):
        if not frontier: break
        nf = []
        for expr in frontier:
            for rw in ac_rewrites(expr):
                if rw not in visited:
                    visited.add(rw)
                    nf.append(rw)
                    sc = sharing_cost(rw)
                    ts = tree_size(rw)
                    if sc < best_sc or (sc == best_sc and ts < best_ts):
                        best = rw
                        best_sc = sc
                        best_ts = ts
        frontier = nf
    return best, len(visited)

def random_expr(max_vars=5, max_depth=4, depth=0):
    if depth >= max_depth or random.random() < 0.3:
        if random.random() < 0.08: return Zero()
        return Var(random.randint(0, max_vars - 1))
    if random.random() < 0.6:
        return Add(random_expr(max_vars, max_depth, depth+1),
                   random_expr(max_vars, max_depth, depth+1))
    return Smul(random.randint(-3, 3), random_expr(max_vars, max_depth, depth+1))


# ── Generate data ──

random.seed(123)
n_samples = 300

canon_costs = []
extract_costs = []
egraph_sizes = []
original_sizes = []

for _ in range(n_samples):
    e = random_expr(max_vars=5, max_depth=4)
    cc = canon_sharing_cost(e)
    extracted, eg_size = extract_min_sharing(e, fuel=30)
    ec = sharing_cost(extracted)
    canon_costs.append(cc)
    extract_costs.append(ec)
    egraph_sizes.append(eg_size)
    original_sizes.append(tree_size(e))


# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Canonical vs Extracted sharing cost
ax1 = axes[0]
jitter = np.random.normal(0, 0.08, n_samples)
ax1.scatter(np.array(canon_costs) + jitter, np.array(extract_costs) + jitter,
            alpha=0.4, s=15, c='steelblue')
ax1.plot([0, 6], [0, 6], 'r--', linewidth=2, label='Perfect agreement')
ax1.set_xlabel('Canonical Sharing Cost', fontsize=12)
ax1.set_ylabel('E-Graph Extracted Sharing Cost', fontsize=12)
ax1.set_title('Canonical Form vs. E-Graph Extraction\n(Theorem: canonical ≤ extracted)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_aspect('equal')

# Count agreement
agree = sum(1 for c, e in zip(canon_costs, extract_costs) if c == e)
ax1.text(0.05, 0.95, f'Agreement: {agree}/{n_samples}\n({100*agree/n_samples:.1f}%)',
         transform=ax1.transAxes, fontsize=11, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Panel 2: E-graph size vs expression size
ax2 = axes[1]
ax2.scatter(original_sizes, egraph_sizes, alpha=0.4, s=15, c='darkorange')
ax2.set_xlabel('Original Tree Size', fontsize=12)
ax2.set_ylabel('E-Graph Size (explored nodes)', fontsize=12)
ax2.set_title('E-Graph Exploration Cost\n(canonical form avoids this)',
              fontsize=13, fontweight='bold')

# Panel 3: Cost comparison histogram
ax3 = axes[2]
diffs = np.array(extract_costs) - np.array(canon_costs)
bins = np.arange(min(diffs) - 0.5, max(diffs) + 1.5, 1)
colors = ['seagreen' if d == 0 else 'salmon' for d in sorted(set(diffs))]
ax3.hist(diffs, bins=bins, color='mediumpurple', edgecolor='black', alpha=0.8)
ax3.set_xlabel('Extracted - Canonical Cost', fontsize=12)
ax3.set_ylabel('Frequency', fontsize=12)
ax3.set_title('Cost Difference Distribution\n(Theorem: always ≥ 0)',
              fontsize=13, fontweight='bold')
ax3.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Zero difference')
ax3.legend(fontsize=10)

plt.tight_layout()
plt.savefig('egraph_extraction_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: egraph_extraction_comparison.png")
