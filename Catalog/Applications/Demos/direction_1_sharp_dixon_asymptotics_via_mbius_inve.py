#!/usr/bin/env python3
"""
Applications of Subgroup Lattice Möbius Inversion

Demonstrates real-world applications of the Möbius inversion formula
for generating pairs in finite groups:

1. Cryptographic key generation assessment
2. Random mixing analysis
3. Error detection in group-based codes
"""

from itertools import permutations
from math import factorial, log2
from fractions import Fraction
from collections import defaultdict
from typing import Tuple, List, FrozenSet, Set, Dict


# ============================================================
# Core routines (self-contained)
# ============================================================

def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Tuple[int, ...]) -> Tuple[int, ...]:
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Tuple[int, ...]:
    return tuple(range(n))

def closure(generators: List[Tuple[int, ...]], n: int) -> FrozenSet[Tuple[int, ...]]:
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def enumerate_subgroups(n: int) -> Set[FrozenSet[Tuple[int, ...]]]:
    all_perms = list(permutations(range(n)))
    subgroups: Set[FrozenSet[Tuple[int, ...]]] = set()
    subgroups.add(frozenset([identity(n)]))
    for g in all_perms:
        subgroups.add(closure([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(closure([g, h], n))
    return subgroups

def compute_moebius(subgroups, n):
    sn = frozenset(permutations(range(n)))
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


# ============================================================
# Application 1: Cryptographic Key Generation Assessment
# ============================================================

def crypto_key_assessment():
    """Assess the probability that two random permutations generate S_n.

    In permutation-based cryptography (e.g., block cipher design),
    it's critical that the permutations used as round functions generate
    a large enough group — ideally the full symmetric group.

    The Möbius inversion formula gives the exact probability, which is
    essential for security parameter selection.
    """
    print("=" * 70)
    print("  Application 1: Cryptographic Security Assessment")
    print("=" * 70)
    print()
    print("  Question: If we pick two random permutations as round functions,")
    print("  what is the probability they generate the full symmetric group?")
    print()

    for n in range(2, 7):
        sn_size = factorial(n)
        all_perms = list(permutations(range(n)))
        sn = frozenset(all_perms)
        gen_count = sum(
            1 for s in all_perms for t in all_perms
            if closure([s, t], n) == sn
        )
        prob = Fraction(gen_count, sn_size**2)
        bits = -log2(1 - float(prob)) if float(prob) < 1 else float('inf')

        print(f"  n={n}: P(full generation) = {prob} ≈ {float(prob):.4f}")
        print(f"        Security bits for non-generation: {bits:.2f}")
        print(f"        Expected trials until full group: {float(1/prob):.2f}")
        print()


# ============================================================
# Application 2: Random Mixing Analysis
# ============================================================

def mixing_analysis():
    """Analyze how random walks on groups mix.

    When two generators produce the full group, random products
    of these generators will eventually reach any target permutation.
    The generation probability controls how quickly a random walk mixes.
    """
    print("=" * 70)
    print("  Application 2: Random Mixing on S_n")
    print("=" * 70)
    print()
    print("  For S_n, the probability P_n that two random elements generate")
    print("  the full group approaches 1 as n → ∞.")
    print()
    print("  The Möbius formula decomposes the obstruction to mixing:")
    print("  1 - P_n = Σ_{H < S_n} |μ(H,S_n)| · (|H|/|S_n|)²")
    print()

    for n in range(2, 6):
        subgroups = enumerate_subgroups(n)
        mu = compute_moebius(subgroups, n)
        sn_size = factorial(n)
        total = sn_size ** 2

        # Obstruction contributions
        sn = frozenset(permutations(range(n)))
        obstruction = Fraction(0)
        for H in subgroups:
            if H != sn and mu[H] != 0:
                contrib = Fraction(mu[H] * len(H)**2, total)
                obstruction += contrib

        gen_prob = 1 + obstruction  # obstruction is negative
        non_gen = 1 - gen_prob

        print(f"  S_{n}:")
        print(f"    P(generate) = {float(gen_prob):.6f}")
        print(f"    Obstruction = {float(non_gen):.6f}")
        print(f"    Dominant term (1/n) = {1/n:.6f}")
        print(f"    Ratio obstruction/(1/n) = {float(non_gen * n):.4f}")
        print()


# ============================================================
# Application 3: Error Detection in Group-Based Codes
# ============================================================

def error_detection():
    """Group-based error detection using generating pairs.

    In algebraic coding theory, permutation groups are used for
    error detection. The check digit scheme works well when the
    underlying permutations generate the full symmetric group.

    The Möbius formula tells us exactly how many valid generator
    pairs exist, which determines the code's error-detection capability.
    """
    print("=" * 70)
    print("  Application 3: Permutation-Based Error Detection")
    print("=" * 70)
    print()
    print("  A check-digit scheme using permutations σ, τ from S_n")
    print("  detects all single-character errors if ⟨σ, τ⟩ = S_n.")
    print()

    for n in range(2, 6):
        sn_size = factorial(n)
        all_perms = list(permutations(range(n)))
        sn = frozenset(all_perms)

        gen_count = sum(
            1 for s in all_perms for t in all_perms
            if closure([s, t], n) == sn
        )
        total = sn_size ** 2
        prob = Fraction(gen_count, total)

        print(f"  Alphabet size n={n}:")
        print(f"    Valid generator pairs: {gen_count} out of {total}")
        print(f"    Success rate: {float(prob)*100:.1f}%")
        print(f"    Random pair is valid with probability {float(prob):.4f}")
        print()


# ============================================================
# Main
# ============================================================

def main():
    crypto_key_assessment()
    print()
    mixing_analysis()
    print()
    error_detection()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Subgroup Lattice Möbius Inversion for Symmetric Group Generation

This script computes exact generating-pair counts for small symmetric groups S_n,
evaluates the Möbius function on the subgroup lattice, and compares exact probabilities
against asymptotic approximations.

Usage:
    python demo.py [n]    where n is 2..6 (default: all)
"""

import sys
from itertools import permutations, product
from math import factorial
from fractions import Fraction
from collections import defaultdict


def perm_compose(p, q):
    """Compose two permutations (as tuples)."""
    return tuple(p[q[i]] for i in range(len(p)))


def perm_inverse(p):
    """Inverse of a permutation."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


def identity(n):
    """Identity permutation on n elements."""
    return tuple(range(n))


def generate_subgroup(generators, n):
    """Generate the subgroup closure of a set of permutations on {0,...,n-1}."""
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(perm_inverse(g))

    changed = True
    while changed:
        changed = False
        new_elements = set()
        for a in elements:
            for b in elements:
                c = perm_compose(a, b)
                if c not in elements and c not in new_elements:
                    new_elements.add(c)
                    changed = True
        elements |= new_elements
    return frozenset(elements)


def all_permutations(n):
    """All permutations of {0,...,n-1} as tuples."""
    return [tuple(p) for p in permutations(range(n))]


def compute_generating_pairs(n):
    """Compute the set of generating pairs for S_n."""
    all_perms = all_permutations(n)
    sn = frozenset(all_perms)
    gen_pairs = []
    for sigma in all_perms:
        for tau in all_perms:
            if generate_subgroup([sigma, tau], n) == sn:
                gen_pairs.append((sigma, tau))
    return gen_pairs


def compute_all_subgroups(n):
    """Compute all subgroups of S_n (as frozensets of permutations)."""
    all_perms = all_permutations(n)
    subgroups = set()
    # Generate all subgroups by taking closures of all subsets up to size 2
    for g in all_perms:
        subgroups.add(generate_subgroup([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(generate_subgroup([g, h], n))
    return subgroups


def moebius_function(subgroups, n):
    """Compute μ(H, S_n) for all subgroups H using recursive definition.
    μ(S_n, S_n) = 1
    μ(H, S_n) = -Σ_{K: H < K ≤ S_n} μ(K, S_n)
    """
    sn = frozenset(all_permutations(n))
    # Sort subgroups by decreasing size
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


def demo_for_n(n):
    """Run full demo for S_n."""
    print(f"\n{'='*60}")
    print(f"  Symmetric Group S_{n}  (|S_{n}| = {factorial(n)})")
    print(f"{'='*60}")

    all_perms = all_permutations(n)
    total_pairs = factorial(n) ** 2
    print(f"  Total pairs: {total_pairs}")

    # Compute generating pairs
    gen_pairs = compute_generating_pairs(n)
    gen_count = len(gen_pairs)
    prob = Fraction(gen_count, total_pairs)
    print(f"  Generating pairs: {gen_count}")
    print(f"  P(generate S_{n}) = {gen_count}/{total_pairs} = {float(prob):.6f}")

    # Asymptotic approximations
    approx1 = 1 - Fraction(1, n)
    approx2 = 1 - Fraction(1, n) - Fraction(1, n**2)
    print(f"\n  Asymptotic approximations:")
    print(f"    1 - 1/n            = {float(approx1):.6f}  (error: {float(abs(prob - approx1)):.6f})")
    print(f"    1 - 1/n - 1/n²    = {float(approx2):.6f}  (error: {float(abs(prob - approx2)):.6f})")

    # Compute subgroups and Möbius function
    if n <= 5:
        print(f"\n  Subgroup lattice analysis:")
        subgroups = compute_all_subgroups(n)
        print(f"    Number of subgroups: {len(subgroups)}")

        mu = moebius_function(subgroups, n)
        sn = frozenset(all_perms)

        # Verify Möbius inversion formula
        moebius_sum = sum(mu[H] * len(H)**2 for H in subgroups)
        print(f"\n  Möbius inversion verification:")
        print(f"    Σ μ(H,S_n)·|H|² = {moebius_sum}")
        print(f"    Direct count     = {gen_count}")
        print(f"    Match: {'✓' if moebius_sum == gen_count else '✗'}")

        # Show contributions by subgroup size
        print(f"\n  Contributions by subgroup order:")
        by_order = defaultdict(lambda: Fraction(0))
        for H in subgroups:
            order = len(H)
            contrib = Fraction(mu[H] * order**2, total_pairs)
            by_order[order] += contrib

        for order in sorted(by_order.keys(), reverse=True):
            contrib = by_order[order]
            if contrib != 0:
                print(f"    |H| = {order:4d}: contribution = {float(contrib):+.6f}")

    return gen_count, total_pairs, prob


def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║   Subgroup Lattice Möbius Inversion for Generating Pairs  ║")
    print("║                                                          ║")
    print("║   #{(σ,τ) ∈ S_n² : ⟨σ,τ⟩ = S_n} = Σ μ(H,S_n)·|H|²    ║")
    print("╚════════════════════════════════════════════════════════════╝")

    if len(sys.argv) > 1:
        ns = [int(sys.argv[1])]
    else:
        ns = [2, 3, 4, 5]

    results = {}
    for n in ns:
        if n > 6:
            print(f"\nSkipping n={n} (too large for brute force)")
            continue
        gen_count, total, prob = demo_for_n(n)
        results[n] = (gen_count, total, prob)

    # Summary table
    if len(results) > 1:
        print(f"\n\n{'='*60}")
        print("  Summary: Generation Probabilities")
        print(f"{'='*60}")
        print(f"  {'n':>3} | {'|S_n|':>8} | {'Gen pairs':>10} | {'P_n':>10} | {'1-1/n':>10} | {'Error':>10}")
        print(f"  {'-'*3}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")
        for n in sorted(results.keys()):
            gen_count, total, prob = results[n]
            approx = 1 - Fraction(1, n)
            err = abs(prob - approx)
            print(f"  {n:>3} | {factorial(n):>8} | {gen_count:>10} | {float(prob):>10.6f} | {float(approx):>10.6f} | {float(err):>10.6f}")


if __name__ == "__main__":
    main()


"""
Visualization: Generation Probability vs Asymptotic Approximations

This script plots the exact probability P_n that two random elements generate S_n,
compared against the asymptotic approximations 1 - 1/n and 1 - 1/n - 1/n².
It demonstrates how the Möbius inversion formula's dominant terms capture the behavior.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def compute_gen_prob(n):
    all_perms = list(permutations(range(n)))
    sn = frozenset(all_perms)
    total = len(all_perms) ** 2
    gen_count = sum(1 for s in all_perms for t in all_perms if closure([s, t], n) == sn)
    return Fraction(gen_count, total)

# Compute exact probabilities for small n
ns = [2, 3, 4, 5]
exact_probs = {}
for n in ns:
    exact_probs[n] = compute_gen_prob(n)
    print(f"S_{n}: P = {exact_probs[n]} = {float(exact_probs[n]):.6f}")

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Probabilities and approximations
n_range = np.array(ns, dtype=float)
exact_vals = [float(exact_probs[n]) for n in ns]
approx1 = [1 - 1/n for n in ns]
approx2 = [1 - 1/n - 1/n**2 for n in ns]

# Extended range for asymptotic curves
n_ext = np.linspace(2, 10, 100)
approx1_ext = 1 - 1/n_ext
approx2_ext = 1 - 1/n_ext - 1/n_ext**2

ax1.plot(n_ext, approx1_ext, 'b--', alpha=0.5, label='$1 - 1/n$')
ax1.plot(n_ext, approx2_ext, 'r--', alpha=0.5, label='$1 - 1/n - 1/n^2$')
ax1.scatter(ns, exact_vals, c='black', s=100, zorder=5, label='Exact $P_n$')
ax1.scatter(ns, approx1, c='blue', s=50, marker='s', zorder=4, alpha=0.7)
ax1.scatter(ns, approx2, c='red', s=50, marker='^', zorder=4, alpha=0.7)

ax1.set_xlabel('$n$', fontsize=14)
ax1.set_ylabel('$P_n$', fontsize=14)
ax1.set_title('Generation Probability in $S_n$', fontsize=15)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 6)
ax1.set_ylim(0.4, 1.05)

# Plot 2: Log-scale errors
errors1 = [abs(float(exact_probs[n]) - (1 - 1/n)) for n in ns]
errors2 = [abs(float(exact_probs[n]) - (1 - 1/n - 1/n**2)) for n in ns]

ax2.semilogy(ns, errors1, 'bs-', markersize=8, label='$|P_n - (1-1/n)|$')
ax2.semilogy(ns, errors2, 'r^-', markersize=8, label='$|P_n - (1-1/n-1/n^2)|$')

# Reference lines
n_ref = np.array(ns, dtype=float)
ax2.semilogy(n_ref, 1/n_ref**2, 'b:', alpha=0.4, label='$1/n^2$ reference')
ax2.semilogy(n_ref, 1/n_ref**3, 'r:', alpha=0.4, label='$1/n^3$ reference')

ax2.set_xlabel('$n$', fontsize=14)
ax2.set_ylabel('Approximation Error', fontsize=14)
ax2.set_title('Asymptotic Convergence (log scale)', fontsize=15)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('generation_probability.png', dpi=150, bbox_inches='tight')
plt.close()
print("\nSaved: generation_probability.png")


"""
Visualization: Möbius Function Heatmap on Subgroup Lattice

This script creates a heatmap showing the Möbius function values μ(H, S_n)
for all subgroups of S_n, organized by subgroup order. This visualizes
the "anatomy of failure" — which subgroups contribute positively or negatively
to the generating pair count via the Möbius inversion formula.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction
from collections import defaultdict


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def enumerate_subgroups(n):
    all_perms = list(permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity(n)]))
    for g in all_perms:
        subgroups.add(closure([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(closure([g, h], n))
    return subgroups

def compute_moebius(subgroups, n):
    sn = frozenset(permutations(range(n)))
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Möbius Function μ(H, $S_n$) on Subgroup Lattice', fontsize=16, fontweight='bold')

for idx, n in enumerate([2, 3, 4, 5]):
    ax = axes[idx // 2][idx % 2]

    subgroups = enumerate_subgroups(n)
    mu = compute_moebius(subgroups, n)

    # Group by order
    by_order = defaultdict(list)
    for H in subgroups:
        by_order[len(H)].append(mu[H])

    orders = sorted(by_order.keys())
    max_count = max(len(v) for v in by_order.values())

    # Create grid data
    grid = np.full((len(orders), max_count), np.nan)
    for i, order in enumerate(orders):
        vals = sorted(by_order[order], reverse=True)
        for j, v in enumerate(vals):
            grid[i, j] = v

    # Plot
    im = ax.imshow(grid.T, aspect='auto', cmap='RdBu_r',
                   vmin=-max(abs(v) for v in mu.values()),
                   vmax=max(abs(v) for v in mu.values()),
                   interpolation='nearest')

    ax.set_xticks(range(len(orders)))
    ax.set_xticklabels([str(o) for o in orders], fontsize=8)
    ax.set_xlabel('Subgroup Order |H|', fontsize=11)
    ax.set_ylabel('Subgroup Index', fontsize=11)
    ax.set_title(f'$S_{n}$ ({len(subgroups)} subgroups)', fontsize=13)

    # Annotate cells
    for i in range(len(orders)):
        vals = sorted(by_order[orders[i]], reverse=True)
        for j, v in enumerate(vals):
            if not np.isnan(grid[i, j]):
                color = 'white' if abs(v) > max(abs(vv) for vv in mu.values()) * 0.6 else 'black'
                ax.text(i, j, str(int(v)), ha='center', va='center',
                       fontsize=7, color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, shrink=0.8, label='μ(H, $S_n$)')

    # Add contribution info
    total_pairs = factorial(n) ** 2
    gen_count = sum(mu[H] * len(H)**2 for H in subgroups)
    prob = gen_count / total_pairs
    ax.text(0.02, 0.98, f'P = {prob:.4f}',
           transform=ax.transAxes, fontsize=10,
           verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('moebius_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: moebius_heatmap.png")


"""
Visualization: Subgroup Family Contributions to Generation Probability

This script creates a stacked bar chart showing how different families of subgroups
(point stabilizers, alternating group, other) contribute to the non-generation
probability through the Möbius inversion formula. It demonstrates that point
stabilizers dominate, contributing the 1/n term in the asymptotic expansion.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction
from collections import defaultdict


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def enumerate_subgroups(n):
    all_perms = list(permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity(n)]))
    for g in all_perms:
        subgroups.add(closure([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(closure([g, h], n))
    return subgroups

def compute_moebius(subgroups, n):
    sn = frozenset(permutations(range(n)))
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

ns = [2, 3, 4, 5]
family_data = {n: {} for n in ns}

for n in ns:
    subgroups = enumerate_subgroups(n)
    mu = compute_moebius(subgroups, n)
    sn = frozenset(permutations(range(n)))
    total = factorial(n) ** 2

    contributions = defaultdict(lambda: Fraction(0))

    for H in subgroups:
        if H == sn:
            continue  # Skip S_n itself

        order = len(H)
        contrib = Fraction(mu[H] * order**2, total)

        # Classify
        if order == factorial(n - 1) and n > 1:
            is_stab = any(all(p[i] == i for p in H) for i in range(n))
            if is_stab:
                contributions["Point Stabilizers"] += contrib
            else:
                contributions["Other"] += contrib
        elif order == factorial(n) // 2 and n >= 2:
            contributions["Alternating Group"] += contrib
        else:
            contributions["Other"] += contrib

    family_data[n] = dict(contributions)

# Plot 1: Stacked bar chart of contributions to 1 - P_n
categories = ["Point Stabilizers", "Alternating Group", "Other"]
colors = ['#e74c3c', '#3498db', '#95a5a6']

x = np.arange(len(ns))
width = 0.6

bottoms = np.zeros(len(ns))
for cat, color in zip(categories, colors):
    vals = [-float(family_data[n].get(cat, Fraction(0))) for n in ns]
    bars = ax1.bar(x, vals, width, bottom=bottoms, label=cat, color=color, alpha=0.8)
    bottoms += np.array(vals)

# Add reference line for 1/n
ref_vals = [1/n for n in ns]
ax1.plot(x, ref_vals, 'k--', linewidth=2, label='$1/n$', zorder=5)

ax1.set_xticks(x)
ax1.set_xticklabels([f'$S_{n}$' for n in ns], fontsize=13)
ax1.set_ylabel('Contribution to $1 - P_n$', fontsize=13)
ax1.set_title('Obstruction Decomposition by Subgroup Family', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.2, axis='y')

# Plot 2: Ratio of point stabilizer contribution to 1/n
stab_ratios = []
for n in ns:
    stab_contrib = -float(family_data[n].get("Point Stabilizers", Fraction(0)))
    stab_ratios.append(stab_contrib / (1/n) if n > 0 else 0)

ax2.bar(x, stab_ratios, width, color='#e74c3c', alpha=0.8)
ax2.axhline(y=1.0, color='black', linestyle='--', linewidth=1.5, label='Ratio = 1')
ax2.set_xticks(x)
ax2.set_xticklabels([f'$S_{n}$' for n in ns], fontsize=13)
ax2.set_ylabel('Stabilizer contribution / $(1/n)$', fontsize=13)
ax2.set_title('Point Stabilizer Dominance', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.2, axis='y')

for i, ratio in enumerate(stab_ratios):
    ax2.text(i, ratio + 0.02, f'{ratio:.3f}', ha='center', va='bottom', fontsize=11, fontweight='bold')

plt.tight_layout()
plt.savefig('subgroup_contributions.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: subgroup_contributions.png")
