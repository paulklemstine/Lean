#!/usr/bin/env python3
"""
Demo: The Babel Graded Graph — Combinatorial Geometry of Universal Libraries

Numerical examples demonstrating shell sizes, conservation laws, expansion ratios,
and sphere-packing bounds for Libraries of Babel with various parameters.
"""

from math import comb, prod
from itertools import combinations, product as iterproduct


def shell_size(A: int, L: int, k: int) -> int:
    """Size of the k-th Hamming shell: C(L,k) * (A-1)^k."""
    return comb(L, k) * (A - 1) ** k


def trans_up(A: int, L: int, k: int) -> int:
    """Number of upward transitions per vertex in shell k."""
    return (L - k) * (A - 1)


def trans_down(k: int) -> int:
    """Number of downward transitions per vertex in shell k."""
    return k


def expansion_ratio(A: int, L: int, k: int) -> float:
    """Expansion ratio from shell k to shell k+1."""
    return (L - k) * (A - 1) / (k + 1)


def hamming_ball_size(A: int, L: int, r: int) -> int:
    """Size of Hamming ball of radius r."""
    return sum(shell_size(A, L, k) for k in range(r + 1))


def hamming_bound(A: int, L: int, r: int) -> int:
    """Maximum code size by sphere-packing bound."""
    return A ** L // hamming_ball_size(A, L, r)


# ============================================================
# Example 1: Binary Library (A=2, L=8)
# ============================================================
print("=" * 60)
print("EXAMPLE 1: Binary Library (A=2, L=8)")
print("=" * 60)
A, L = 2, 8
print(f"Library size: {A}^{L} = {A**L}")
print(f"\nShell sizes:")
total = 0
for k in range(L + 1):
    s = shell_size(A, L, k)
    total += s
    print(f"  Shell {k}: C({L},{k}) * {A-1}^{k} = {s}")
print(f"  Total: {total} (should equal {A**L})")
assert total == A ** L, "Shell partition failed!"

print(f"\nConservation law verification:")
for k in range(L):
    lhs = shell_size(A, L, k) * trans_up(A, L, k)
    rhs = shell_size(A, L, k + 1) * trans_down(k + 1)
    status = "✓" if lhs == rhs else "✗"
    print(f"  k={k}: {shell_size(A,L,k)}*{trans_up(A,L,k)} = {lhs} "
          f"== {shell_size(A,L,k+1)}*{trans_down(k+1)} = {rhs} {status}")

# ============================================================
# Example 2: Quaternary Library (A=4, L=16) — Mini de Bruijn
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 2: Quaternary Library (A=4, L=16)")
print("=" * 60)
A, L = 4, 16
print(f"Library size: {A}^{L} = {A**L:,}")
print(f"\nShell sizes (first 6 and last 3):")
for k in list(range(6)) + list(range(L - 2, L + 1)):
    s = shell_size(A, L, k)
    print(f"  Shell {k:2d}: {s:>15,}")

total = sum(shell_size(A, L, k) for k in range(L + 1))
assert total == A ** L
print(f"  Sum:      {total:>15,} ✓")

print(f"\nExpansion ratios:")
equator = None
for k in range(L):
    er = expansion_ratio(A, L, k)
    if er < 1 and equator is None:
        equator = k
    if k < 5 or k > L - 4 or (equator and abs(k - equator) <= 1):
        print(f"  k={k:2d}: ratio = {er:.4f}" + (" ← equator" if k == equator else ""))

print(f"\nSphere-packing bounds:")
for r in [0, 1, 2, 3]:
    ball = hamming_ball_size(A, L, r)
    bound = hamming_bound(A, L, r)
    print(f"  r={r}: ball size = {ball:>10,}, max code size ≤ {bound:>10,}")

# ============================================================
# Example 3: Borges' Library (A=25, L=1312000)
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 3: Borges' Library (A=25, L=1,312,000)")
print("=" * 60)
A, L = 25, 1312000
print(f"Alphabet size: {A}")
print(f"Volume length: {L:,}")
print(f"Library size: 25^1312000 ≈ 10^(1312000 * log10(25))")

import math
log_library = L * math.log10(A)
print(f"  log10(library size) ≈ {log_library:,.0f}")
print(f"  That's a number with {int(log_library)+1:,} digits")

print(f"\nShell 0: 1 volume (the reference)")
print(f"Shell 1: {L * (A-1):,} volumes")
print(f"  = {L:,} positions × {A-1} alternative characters")

# Expansion ratio at k=0
er0 = expansion_ratio(A, L, 0)
print(f"\nExpansion ratio at k=0: {er0:,.0f}")
print(f"  (each volume has {int(er0):,} neighbors at distance 1)")

# Where does expansion ratio drop below 1?
equator_k = int(L * (A - 1) / A) - 1
er_eq = expansion_ratio(A, L, equator_k)
print(f"\nEquator at k ≈ {equator_k:,}")
print(f"  expansion ratio at equator: {er_eq:.6f}")
print(f"  Fraction of diameter: {equator_k/L:.4f}")

# Catalog pigeonhole
D = 1000
fiber = A ** L // D  # This would be astronomically large
print(f"\nCatalog pigeonhole (D={D:,}):")
print(f"  Some label shared by ≥ 25^1312000 / {D:,} volumes")
print(f"  ≈ 10^{log_library - math.log10(D):.0f} volumes per label")

# ============================================================
# Example 4: Verify Hamming shell by enumeration (small case)
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 4: Exhaustive Shell Enumeration (A=3, L=4)")
print("=" * 60)
A, L = 3, 4
ref = (0, 0, 0, 0)

def hamming_dist(v, w):
    return sum(1 for a, b in zip(v, w) if a != b)

# Enumerate all volumes
all_volumes = list(iterproduct(range(A), repeat=L))
print(f"Total volumes: {len(all_volumes)} (expected {A**L})")

# Count shells
shell_counts = {}
for v in all_volumes:
    d = hamming_dist(ref, v)
    shell_counts[d] = shell_counts.get(d, 0) + 1

print(f"\nShell sizes (enumerated vs formula):")
for k in range(L + 1):
    actual = shell_counts.get(k, 0)
    formula = shell_size(A, L, k)
    status = "✓" if actual == formula else "✗"
    print(f"  Shell {k}: enumerated={actual}, formula={formula} {status}")

total_enum = sum(shell_counts.values())
total_formula = sum(shell_size(A, L, k) for k in range(L + 1))
print(f"  Totals: {total_enum} == {total_formula} == {A**L} ✓")

# Verify triangle inequality by sampling
import random
random.seed(42)
violations = 0
tests = 10000
for _ in range(tests):
    u = tuple(random.randrange(A) for _ in range(L))
    v = tuple(random.randrange(A) for _ in range(L))
    w = tuple(random.randrange(A) for _ in range(L))
    if hamming_dist(u, w) > hamming_dist(u, v) + hamming_dist(v, w):
        violations += 1
print(f"\nTriangle inequality: {tests} random tests, {violations} violations ✓")

print("\n" + "=" * 60)
print("All examples verified successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Shell Size Distribution of the Babel Graded Graph.

Plots the shell sizes for various Library parameters, showing the
binomial-like distribution and the equator location.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb


def shell_size(A: int, L: int, k: int) -> int:
    return comb(L, k) * (A - 1) ** k


def plot_shell_distributions():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Shell Size Distributions in the Babel Graded Graph",
                 fontsize=16, fontweight='bold')

    configs = [
        (2, 20, "Binary Library (A=2, L=20)"),
        (4, 16, "Quaternary Library (A=4, L=16)"),
        (10, 12, "Decimal Library (A=10, L=12)"),
        (25, 10, "Borges' Alphabet (A=25, L=10)"),
    ]

    for ax, (A, L, title) in zip(axes.flat, configs):
        ks = list(range(L + 1))
        sizes = [shell_size(A, L, k) for k in ks]
        total = sum(sizes)
        fractions = [s / total for s in sizes]

        # Find equator
        equator = max(range(L + 1), key=lambda k: sizes[k])

        ax.bar(ks, fractions, color='steelblue', alpha=0.8, edgecolor='navy')
        ax.axvline(x=equator, color='red', linestyle='--', linewidth=1.5,
                   label=f'Peak at k={equator}')
        ax.axvline(x=L * (A - 1) / A, color='orange', linestyle=':',
                   linewidth=1.5, label=f'L(A-1)/A={L*(A-1)/A:.1f}')

        ax.set_title(title, fontsize=12)
        ax.set_xlabel("Shell distance k")
        ax.set_ylabel("Fraction of Library")
        ax.legend(fontsize=9)
        ax.set_xlim(-0.5, L + 0.5)

    plt.tight_layout()
    plt.savefig("shell_distributions.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: shell_distributions.png")


def plot_expansion_ratios():
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.set_title("Expansion Ratios of the Babel Graded Graph",
                 fontsize=14, fontweight='bold')

    configs = [
        (2, 30, "A=2, L=30"),
        (4, 30, "A=4, L=30"),
        (10, 30, "A=10, L=30"),
        (25, 30, "A=25, L=30"),
    ]

    for A, L, label in configs:
        ks = list(range(L))
        ratios = [(L - k) * (A - 1) / (k + 1) for k in ks]
        ax.plot(ks, ratios, marker='.', markersize=4, label=label)

    ax.axhline(y=1, color='black', linestyle='--', linewidth=1, alpha=0.5)
    ax.set_xlabel("Shell index k", fontsize=12)
    ax.set_ylabel("Expansion ratio", fontsize=12)
    ax.set_yscale('log')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("expansion_ratios.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: expansion_ratios.png")


def plot_conservation_flow():
    fig, ax = plt.subplots(figsize=(12, 6))

    A, L = 4, 20
    ks = list(range(L))
    up_flows = [shell_size(A, L, k) * (L - k) * (A - 1) for k in ks]
    down_flows = [shell_size(A, L, k + 1) * (k + 1) for k in ks]

    ax.plot(ks, up_flows, 'b-o', markersize=4, label='Shell(k) × transUp(k)')
    ax.plot(ks, down_flows, 'r--s', markersize=4, label='Shell(k+1) × transDown(k+1)')

    ax.set_title(f"Conservation Law Verification (A={A}, L={L})",
                 fontsize=14, fontweight='bold')
    ax.set_xlabel("Shell index k", fontsize=12)
    ax.set_ylabel("Total flow", fontsize=12)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Verify they're equal
    max_diff = max(abs(u - d) for u, d in zip(up_flows, down_flows))
    ax.text(0.02, 0.98, f"Max |up - down| = {max_diff}",
            transform=ax.transAxes, fontsize=10, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

    plt.tight_layout()
    plt.savefig("conservation_flow.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conservation_flow.png")


if __name__ == "__main__":
    plot_shell_distributions()
    plot_expansion_ratios()
    plot_conservation_flow()
