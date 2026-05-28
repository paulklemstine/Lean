#!/usr/bin/env python3
"""
Visualization: Matroid Basis Polynomial Shadows

Shows the support geometry of basis-generating polynomials for small matroids
and their Hessian shadows. Demonstrates that anti-cancellation holds for all
tested matroid polynomials (which have nonneg, in fact 0-1, coefficients).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from collections import defaultdict


def poly_pderiv(coeffs, n, var):
    result = {}
    for exp, c in coeffs.items():
        if exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            ne = tuple(ne)
            result[ne] = result.get(ne, 0) + c * exp[var]
    return {e: c for e, c in result.items() if c != 0}


def uniform_matroid_poly(n, r):
    """Basis-generating polynomial of U(r,n)."""
    coeffs = {}
    for basis in combinations(range(n), r):
        exp = tuple(1 if i in basis else 0 for i in range(n))
        coeffs[exp] = coeffs.get(exp, 0) + 1
    return coeffs


def compute_shadows(coeffs, n):
    """Compute all pair shadows and the aggregate shadow."""
    pair_shadows = {}
    aggregate = set()
    for i in range(n):
        for j in range(n):
            d = poly_pderiv(poly_pderiv(coeffs, n, j), n, i)
            pair_shadows[(i, j)] = set(d.keys())
            aggregate |= set(d.keys())
    return pair_shadows, aggregate


def hessian_support_all_ones(coeffs, n):
    """Hessian support with all-ones weight matrix."""
    result = {}
    for i in range(n):
        for j in range(n):
            d = poly_pderiv(poly_pderiv(coeffs, n, j), n, i)
            for e, c in d.items():
                result[e] = result.get(e, 0) + c
    return {e for e, c in result.items() if c != 0}


# --- Compute data for several matroids ---
matroids = [
    ("U(2,4)", 4, 2),
    ("U(2,5)", 5, 2),
    ("U(3,5)", 5, 3),
    ("U(3,6)", 6, 3),
]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, (name, n, r) in enumerate(matroids):
    ax = axes[idx // 2][idx % 2]
    
    coeffs = uniform_matroid_poly(n, r)
    pair_shadows, aggregate = compute_shadows(coeffs, n)
    hsupp = hessian_support_all_ones(coeffs, n)
    
    n_bases = len(coeffs)
    support_size = len(coeffs)
    shadow_size = len(aggregate)
    hessian_size = len(hsupp)
    exact = aggregate == hsupp
    
    # Count how many pairs contribute to each shadow monomial
    pair_counts = defaultdict(int)
    for (i, j), s in pair_shadows.items():
        for m in s:
            pair_counts[m] += 1
    
    # Create bar chart of pair counts
    monomials = sorted(aggregate)
    counts = [pair_counts.get(m, 0) for m in monomials]
    
    colors = ['#27ae60' if m in hsupp else '#e74c3c' for m in monomials]
    
    bars = ax.bar(range(len(monomials)), counts, color=colors, edgecolor='white', linewidth=0.5)
    
    ax.set_xlabel('Monomial index (sorted)', fontsize=10)
    ax.set_ylabel('# Contributing Pairs', fontsize=10)
    ax.set_title(f'{name}: {n_bases} bases, shadow={shadow_size}, '
                 f'hessian={hessian_size}\n'
                 f'{"✓ EXACT" if exact else "✗ NOT EXACT"} '
                 f'(Anti-cancellation {"holds" if exact else "fails"})',
                 fontsize=11, fontweight='bold',
                 color='#27ae60' if exact else '#e74c3c')
    
    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#27ae60', label='In Hessian support'),
        Patch(facecolor='#e74c3c', label='Cancelled'),
    ]
    ax.legend(handles=legend_elements, fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('Matroid Basis Polynomials: Shadow Support Analysis\n'
             'Anti-cancellation theorem guarantees all bars are green (nonneg coefficients + positive weights)',
             fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig("matroid_shadows.png", dpi=150, bbox_inches='tight')
print("Saved matroid_shadows.png")
