#!/usr/bin/env python3
"""
Visualization: Quantum Circuit Synthesis from Certificate Trees

Generates a heatmap showing amplitude distributions for different
uniform matroids, comparing certificate-derived amplitudes to exact
weighted basis distributions.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def partition_function_uniform(n, r, weights):
    """Compute partition function for U(r,n) with given weights."""
    total = 0.0
    for basis in combinations(range(n), r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        total += w
    return total


def exact_distribution(n, r, weights):
    """Compute exact basis distribution for U(r,n)."""
    dist = {}
    z = partition_function_uniform(n, r, weights)
    for basis in combinations(range(n), r):
        w = 1.0
        for i in basis:
            w *= weights[i]
        dist[frozenset(basis)] = w / z
    return dist


def cert_amplitude(n, r, weights):
    """
    Compute amplitudes via certificate tree traversal.
    Returns list of (basis, amplitude) pairs.
    """
    results = []

    def _traverse(elts, rank, amp, selected):
        if rank == 0:
            results.append((frozenset(selected), amp))
            return
        if rank == len(elts):
            results.append((frozenset(selected + elts), amp))
            return
        if rank > len(elts):
            return

        e = elts[0]
        rest = elts[1:]

        z_del = partition_function_uniform(len(rest), rank,
                    {i: weights[i] for i in rest})
        z_con = weights[e] * partition_function_uniform(len(rest), rank - 1,
                    {i: weights[i] for i in rest})
        z_total = z_del + z_con

        if z_total <= 0:
            return

        _traverse(rest, rank, amp * math.sqrt(z_del / z_total), selected)
        _traverse(rest, rank - 1, amp * math.sqrt(z_con / z_total),
                 selected + [e])

    # Use element-indexed partition functions
    def partition_function_uniform(n_elts, rank, weight_dict):
        elts = sorted(weight_dict.keys())[:n_elts]
        if rank < 0 or rank > len(elts):
            return 0.0
        if rank == 0:
            return 1.0
        total = 0.0
        for basis in combinations(elts, rank):
            w = 1.0
            for i in basis:
                w *= weight_dict[i]
            total += w
        return total

    elements = list(range(n))
    weight_dict = {i: weights[i] for i in range(n)}

    def _traverse2(elts, rank, amp, selected):
        if rank == 0:
            results.append((frozenset(selected), amp))
            return
        if rank == len(elts):
            results.append((frozenset(selected + elts), amp))
            return
        if rank > len(elts) or rank < 0:
            return

        e = elts[0]
        rest = elts[1:]

        z_del = 0.0
        for basis in combinations(rest, rank):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_del += w

        z_con_inner = 0.0
        for basis in combinations(rest, rank - 1):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_con_inner += w
        z_con = weights[e] * z_con_inner

        z_total = z_del + z_con
        if z_total <= 0:
            return

        _traverse2(rest, rank, amp * math.sqrt(z_del / z_total), selected)
        _traverse2(rest, rank - 1, amp * math.sqrt(z_con / z_total),
                  selected + [e])

    _traverse2(elements, r, 1.0, [])
    return results


# ============================================================
# Generate heatmap data
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Amplitude Distributions: Certificate Trees → Quantum Circuits',
             fontsize=14, fontweight='bold')

test_cases = [
    (4, 2, "U(2,4)"), (5, 2, "U(2,5)"), (5, 3, "U(3,5)"),
    (6, 2, "U(2,6)"), (6, 3, "U(3,6)"), (7, 3, "U(3,7)"),
]

for idx, (n, r, name) in enumerate(test_cases):
    ax = axes[idx // 3][idx % 3]
    weights = [1.0 + 0.3 * i for i in range(n)]

    # Get exact and certificate distributions
    exact = exact_distribution(n, r, weights)
    cert = cert_amplitude(n, r, weights)

    # Sort bases consistently
    all_bases = sorted(exact.keys(), key=lambda x: sorted(x))
    n_bases = len(all_bases)

    exact_probs = [exact.get(b, 0) for b in all_bases]
    cert_probs = [0.0] * n_bases
    for basis, amp in cert:
        if basis in exact:
            bidx = all_bases.index(basis)
            cert_probs[bidx] += amp ** 2

    # Compute errors
    errors = [abs(e - c) for e, c in zip(exact_probs, cert_probs)]

    # Plot
    x = np.arange(n_bases)
    width = 0.35
    ax.bar(x - width/2, exact_probs, width, label='Exact', alpha=0.7, color='steelblue')
    ax.bar(x + width/2, cert_probs, width, label='Circuit', alpha=0.7, color='coral')

    ax.set_title(f'{name}: {n_bases} bases')
    ax.set_xlabel('Basis index')
    ax.set_ylabel('Probability')
    ax.legend(fontsize=8)

    max_err = max(errors) if errors else 0
    ax.text(0.95, 0.95, f'max err: {max_err:.1e}',
            transform=ax.transAxes, ha='right', va='top', fontsize=8,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('amplitude_distribution.png', dpi=150, bbox_inches='tight')
print("Saved amplitude_distribution.png")
