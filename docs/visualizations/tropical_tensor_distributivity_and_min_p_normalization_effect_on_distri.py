"""
Visualization: Normalization Effect on Distributive Potential

This script creates a heatmap showing how the distributive potential
decreases during normalization. It also shows the monomial count
for graph-encoded expressions across different graph sizes.
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import random

# ============================================================
# Inline implementations (self-contained)
# ============================================================

class MPExpr:
    pass

class Atom(MPExpr):
    def __init__(self, index):
        self.index = index

class TMin(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right

class TPlus(MPExpr):
    def __init__(self, left, right):
        self.left = left
        self.right = right


def eval_z(expr, env):
    if isinstance(expr, Atom):
        return env.get(expr.index, float('inf'))
    elif isinstance(expr, TMin):
        return min(eval_z(expr.left, env), eval_z(expr.right, env))
    elif isinstance(expr, TPlus):
        return eval_z(expr.left, env) + eval_z(expr.right, env)
    return float('inf')


def dist_plus(a, b):
    if isinstance(b, TMin):
        return TMin(dist_plus(a, b.left), dist_plus(a, b.right))
    elif isinstance(a, TMin):
        return TMin(dist_plus(a.left, b), dist_plus(a.right, b))
    else:
        return TPlus(a, b)


def normalize(expr):
    if isinstance(expr, Atom):
        return expr
    elif isinstance(expr, TMin):
        return TMin(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, TPlus):
        return dist_plus(normalize(expr.left), normalize(expr.right))
    return expr


def extract_monomials(expr):
    if isinstance(expr, Atom): return [expr]
    if isinstance(expr, TMin):
        return extract_monomials(expr.left) + extract_monomials(expr.right)
    if isinstance(expr, TPlus): return [expr]
    return []


def top_sum_count(expr):
    if isinstance(expr, Atom): return 1
    if isinstance(expr, TMin):
        return top_sum_count(expr.left) + top_sum_count(expr.right)
    if isinstance(expr, TPlus):
        return top_sum_count(expr.left) * top_sum_count(expr.right)
    return 1


def dist_potential(expr):
    if isinstance(expr, Atom): return 0
    if isinstance(expr, TMin):
        return dist_potential(expr.left) + dist_potential(expr.right)
    if isinstance(expr, TPlus):
        dp1 = dist_potential(expr.left)
        dp2 = dist_potential(expr.right)
        sc1 = top_sum_count(expr.left)
        sc2 = top_sum_count(expr.right)
        return dp1 * sc2 + dp2 * sc1 + (sc1 * sc2 - 1)
    return 0


def encode_edge(n, i, j):
    return i * n + j


def two_hop_expr(n, i, j):
    result = TPlus(Atom(encode_edge(n, i, 0)), Atom(encode_edge(n, 0, j)))
    for k in range(1, n):
        hop = TPlus(Atom(encode_edge(n, i, k)), Atom(encode_edge(n, k, j)))
        result = TMin(result, hop)
    return result


def floyd_warshall(n, weights):
    dist = [row[:] for row in weights]
    for i in range(n):
        dist[i][i] = 0
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i][k] + dist[k][j] < dist[i][j]:
                    dist[i][j] = dist[i][k] + dist[k][j]
    return dist


# ============================================================
# Data Generation
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Distributive potential before vs after normalization
expr_types = [
    ("a + min(b,c)", lambda: TPlus(Atom(0), TMin(Atom(1), Atom(2)))),
    ("min(a,b) + c", lambda: TPlus(TMin(Atom(0), Atom(1)), Atom(2))),
    ("min(a,b) + min(c,d)", lambda: TPlus(TMin(Atom(0), Atom(1)),
                                          TMin(Atom(2), Atom(3)))),
    ("(a+b) + min(c,d)", lambda: TPlus(TPlus(Atom(0), Atom(1)),
                                       TMin(Atom(2), Atom(3)))),
    ("min(a,b) + min(c,d,e)", lambda: TPlus(
        TMin(Atom(0), Atom(1)),
        TMin(Atom(2), TMin(Atom(3), Atom(4))))),
    ("min(a,b,c) + min(d,e,f)", lambda: TPlus(
        TMin(Atom(0), TMin(Atom(1), Atom(2))),
        TMin(Atom(3), TMin(Atom(4), Atom(5))))),
]

names = [name for name, _ in expr_types]
dp_before = []
dp_after = []
sc_values = []

for name, build in expr_types:
    expr = build()
    dp_before.append(dist_potential(expr))
    nf = normalize(expr)
    dp_after.append(dist_potential(nf))
    sc_values.append(top_sum_count(expr))

x_pos = np.arange(len(names))
width = 0.35

bars1 = axes[0].bar(x_pos - width/2, dp_before, width, label='Before', color='#E53935', alpha=0.8)
bars2 = axes[0].bar(x_pos + width/2, dp_after, width, label='After', color='#43A047', alpha=0.8)

axes[0].set_xlabel('Expression', fontsize=12)
axes[0].set_ylabel('Distributive Potential', fontsize=12)
axes[0].set_title('Normalization Reduces Distributive Potential to 0', fontsize=13)
axes[0].set_xticks(x_pos)
axes[0].set_xticklabels([n.replace(' + ', '\n+\n') for n in names], fontsize=8, rotation=0)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3, axis='y')

# Add value labels
for bar in bars1:
    height = bar.get_height()
    if height > 0:
        axes[0].text(bar.get_x() + bar.get_width()/2., height + 0.1,
                    f'{int(height)}', ha='center', va='bottom', fontsize=9)

# Panel 2: Monomial count for two-hop expressions vs graph size
sizes = list(range(2, 9))
monomial_counts = []

for n in sizes:
    expr = two_hop_expr(n, 0, 1)
    nf = normalize(expr)
    monomials = extract_monomials(nf)
    monomial_counts.append(len(monomials))

axes[1].bar(sizes, monomial_counts, color='#1976D2', alpha=0.8, edgecolor='white')
axes[1].plot(sizes, [n for n in sizes], 'r--', linewidth=2, label='n (graph size)')
axes[1].plot(sizes, monomial_counts, 'ko-', markersize=6, label='TNF monomials')

axes[1].set_xlabel('Number of Vertices (n)', fontsize=12)
axes[1].set_ylabel('Number of TNF Monomials', fontsize=12)
axes[1].set_title('Two-Hop TNF Monomials vs Graph Size', fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_normalization_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_normalization_heatmap.png")
