#!/usr/bin/env python3
"""
Primewise Persistent Homology: Demonstration

Demonstrates the key results:
1. Mod-p filtration barcodes for sample length spectra
2. Separating primes detection for isospectral-like pairs
3. Density of separating primes approaches 1
4. Triangle inequality verification for matching costs
"""

from algorithms import (
    PersistenceInterval, mod_p_filtration_barcode, mod_p_residues,
    find_separating_primes, separation_density, interval_match_cost,
    betti_at, rank_function, primes_up_to, vietoris_rips_barcode,
    compute_primewise_barcodes, euler_characteristic
)


def demo_basic_barcode():
    """Demonstrate basic barcode construction and Betti numbers."""
    print("=" * 60)
    print("Demo 1: Basic Barcode Construction")
    print("=" * 60)

    lengths = [3, 7, 11, 15, 22, 31, 42]
    print(f"\nLength spectrum: {lengths}")

    for p in [2, 3, 5, 7]:
        residues = mod_p_residues(lengths, p)
        barcode = mod_p_filtration_barcode(lengths, p)
        print(f"\nPrime p = {p}:")
        print(f"  Residues mod {p}: {residues}")
        print(f"  Barcode: {[(I.birth, I.death) for I in barcode]}")
        print(f"  Number of intervals: {len(barcode)}")

        # Betti numbers at each filtration level
        bettis = [betti_at(barcode, t) for t in range(p + 1)]
        print(f"  Betti numbers β(0..{p}): {bettis}")


def demo_separating_primes():
    """Demonstrate prime separation of distinct configurations."""
    print("\n" + "=" * 60)
    print("Demo 2: Separating Primes for Distinct Configurations")
    print("=" * 60)

    # Two lists with the same multiset but different order
    # (modeling isospectral but nonisometric)
    a = [1, 4, 9, 16, 25, 36, 49, 64]
    b = [4, 1, 16, 9, 36, 25, 64, 49]  # pairwise swaps

    print(f"\nList a: {a}")
    print(f"List b: {b}")
    print(f"Same multiset: {sorted(a) == sorted(b)}")
    print(f"Same list: {a == b}")

    sep, agr = find_separating_primes(a, b, 100)
    print(f"\nSeparating primes (up to 100): {sorted(sep)}")
    print(f"Agreeing primes (up to 100): {sorted(agr)}")
    print(f"Separation count: {len(sep)} / {len(sep) + len(agr)}")

    # Show residue differences at a separating prime
    if sep:
        p = min(sep)
        ra = [x % p for x in a]
        rb = [x % p for x in b]
        print(f"\nAt prime p = {p}:")
        print(f"  a mod {p}: {ra}")
        print(f"  b mod {p}: {rb}")


def demo_density_convergence():
    """Show that separation density approaches 1 as prime bound grows."""
    print("\n" + "=" * 60)
    print("Demo 3: Separation Density Convergence")
    print("=" * 60)

    # Two genuinely different lists
    a = [2, 5, 8, 13, 21, 34, 55, 89]  # Fibonacci-like
    b = [3, 5, 8, 12, 20, 33, 54, 88]  # shifted

    print(f"\nList a: {a}")
    print(f"List b: {b}")
    print(f"Max element: {max(max(a), max(b))}")
    print(f"Theory predicts: all primes > {max(max(a), max(b))} separate")

    print(f"\n{'Bound':>8} {'Sep':>5} {'Agr':>5} {'Density':>8}")
    print("-" * 30)
    for bound in [10, 20, 50, 100, 200, 500]:
        density = separation_density(a, b, bound)
        sep, agr = find_separating_primes(a, b, bound)
        print(f"{bound:>8} {len(sep):>5} {len(agr):>5} {density:>8.4f}")


def demo_triangle_inequality():
    """Verify the triangle inequality for matching costs."""
    print("\n" + "=" * 60)
    print("Demo 4: Triangle Inequality Verification")
    print("=" * 60)

    intervals = [
        PersistenceInterval(0, 5),
        PersistenceInterval(1, 8),
        PersistenceInterval(3, 10),
        PersistenceInterval(2, 6),
        PersistenceInterval(0, 15),
    ]

    violations = 0
    checks = 0
    print(f"\nChecking triangle inequality for {len(intervals)} intervals:")
    for i, I in enumerate(intervals):
        for j, J in enumerate(intervals):
            for k, K in enumerate(intervals):
                cIK = interval_match_cost(I, K)
                cIJ = interval_match_cost(I, J)
                cJK = interval_match_cost(J, K)
                checks += 1
                if cIK > cIJ + cJK:
                    violations += 1
                    print(f"  VIOLATION: c({i},{k})={cIK} > c({i},{j})={cIJ} + c({j},{k})={cJK}")

    print(f"\n  Checked {checks} triples, found {violations} violations")
    if violations == 0:
        print("  ✓ Triangle inequality holds for all triples!")


def demo_rank_function():
    """Demonstrate rank function properties."""
    print("\n" + "=" * 60)
    print("Demo 5: Rank Function Monotonicity")
    print("=" * 60)

    barcode = [
        PersistenceInterval(0, 5),
        PersistenceInterval(1, 8),
        PersistenceInterval(2, 10),
        PersistenceInterval(3, 6),
    ]

    print(f"\nBarcode: {[(I.birth, I.death) for I in barcode]}")
    print("\nRank function β(s, t):")
    header = 's\\t'
    print(f"{header:>4}", end="")
    for t in range(12):
        print(f"{t:>4}", end="")
    print()
    for s in range(12):
        print(f"{s:>4}", end="")
        for t in range(12):
            print(f"{rank_function(barcode, s, t):>4}", end="")
        print()

    # Verify monotonicity
    print("\nVerifying monotonicity properties:")
    mono_fst = all(
        rank_function(barcode, s1, t) <= rank_function(barcode, s2, t)
        for s1 in range(12) for s2 in range(s1, 12) for t in range(12)
    )
    anti_snd = all(
        rank_function(barcode, s, t2) <= rank_function(barcode, s, t1)
        for s in range(12) for t1 in range(12) for t2 in range(t1, 12)
    )
    diag = all(
        rank_function(barcode, s, s) == betti_at(barcode, s)
        for s in range(12)
    )
    print(f"  ✓ Monotone in first argument: {mono_fst}")
    print(f"  ✓ Antitone in second argument: {anti_snd}")
    print(f"  ✓ Diagonal = Betti number: {diag}")


def demo_euler_characteristic():
    """Demonstrate Euler characteristic from barcodes."""
    print("\n" + "=" * 60)
    print("Demo 6: Euler Characteristic via Barcodes")
    print("=" * 60)

    evens = [PersistenceInterval(0, 8), PersistenceInterval(2, 10)]
    odds = [PersistenceInterval(1, 6), PersistenceInterval(3, 9)]

    print(f"\nEven-dimensional barcode: {[(I.birth, I.death) for I in evens]}")
    print(f"Odd-dimensional barcode: {[(I.birth, I.death) for I in odds]}")

    print(f"\n{'t':>4} {'β_even':>8} {'β_odd':>8} {'χ(t)':>8}")
    print("-" * 30)
    for t in range(12):
        be = betti_at(evens, t)
        bo = betti_at(odds, t)
        chi = euler_characteristic(evens, odds, t)
        print(f"{t:>4} {be:>8} {bo:>8} {chi:>8}")


def demo_conjecture_test():
    """Test the main conjecture on a concrete example."""
    print("\n" + "=" * 60)
    print("Demo 7: Conjecture Test — Full Residue Sequence Separation")
    print("=" * 60)

    # Two lists with same multiset but different order
    a = [1, 4, 9, 16, 25, 36, 49, 64]
    b = [4, 1, 16, 9, 36, 25, 64, 49]  # pairwise swaps

    print(f"\nLength spectrum a: {a}")
    print(f"Length spectrum b: {b}")
    print(f"Same multiset: {sorted(a) == sorted(b)}")

    M = max(max(a), max(b))
    print(f"Max element M = {M}")
    print(f"Theory: all primes p > {M} separate (map is identity)")

    # Test full residue sequence comparison (not just distinct residues)
    sep_primes = []
    agr_primes = []
    for p in primes_up_to(200):
        ra = [x % p for x in a]
        rb = [x % p for x in b]
        if ra != rb:
            sep_primes.append(p)
        else:
            agr_primes.append(p)

    print(f"\nFull sequence comparison up to p = 200:")
    print(f"  Separating primes: {len(sep_primes)}")
    print(f"  Agreeing primes: {len(agr_primes)}")
    if agr_primes:
        print(f"  Agreeing primes: {agr_primes}")
        print(f"  All agreeing primes ≤ M={M}? {all(p <= M for p in agr_primes)}")
    else:
        print(f"  No agreeing primes!")
    total = len(sep_primes) + len(agr_primes)
    print(f"  Density: {len(sep_primes)/total:.4f}")
    confirmed = len(agr_primes) == 0 or all(p <= M for p in agr_primes)
    print(f"\n  {'✓ Conjecture confirmed!' if confirmed else '✗ Unexpected behavior!'}")
    
    # Show detail for a few primes
    print(f"\nDetail for small primes:")
    for p in primes_up_to(20):
        ra = [x % p for x in a]
        rb = [x % p for x in b]
        status = '≠' if ra != rb else '='
        print(f"  p={p:>2}: a mod p = {ra}")
        print(f"        b mod p = {rb}  [{status}]")


if __name__ == "__main__":
    demo_basic_barcode()
    demo_separating_primes()
    demo_density_convergence()
    demo_triangle_inequality()
    demo_rank_function()
    demo_euler_characteristic()
    demo_conjecture_test()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Barcode Comparison Across Primes

Shows how mod-p persistence barcodes differ between two isospectral-like
configurations at different primes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def mod_p_residues(lengths, p):
    return sorted(set(x % p for x in lengths))


def mod_p_barcode(lengths, p):
    residues = mod_p_residues(lengths, p)
    return [(r, p) for r in residues]


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


# Two length spectra with different structures
a = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]  # first 10 primes
b = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]  # first 10 even numbers ≥ 2

test_primes = [p for p in range(2, 32) if is_prime(p)]

fig, axes = plt.subplots(2, len(test_primes), figsize=(20, 6))

for col, p in enumerate(test_primes):
    # Barcode for a
    bc_a = mod_p_barcode(a, p)
    ax = axes[0, col]
    for i, (birth, death) in enumerate(bc_a):
        ax.barh(i, death - birth, left=birth, height=0.6, color='steelblue', alpha=0.8)
    ax.set_xlim(-0.5, p + 0.5)
    ax.set_ylim(-0.5, max(len(bc_a), 1) + 0.5)
    ax.set_title(f'p={p}', fontsize=9)
    if col == 0:
        ax.set_ylabel('Spectrum A\n(primes)', fontsize=9)
    ax.set_xticks([0, p])
    ax.tick_params(labelsize=7)

    # Barcode for b
    bc_b = mod_p_barcode(b, p)
    ax = axes[1, col]
    for i, (birth, death) in enumerate(bc_b):
        ax.barh(i, death - birth, left=birth, height=0.6, color='coral', alpha=0.8)
    ax.set_xlim(-0.5, p + 0.5)
    ax.set_ylim(-0.5, max(len(bc_b), 1) + 0.5)
    if col == 0:
        ax.set_ylabel('Spectrum B\n(evens)', fontsize=9)
    ax.set_xticks([0, p])
    ax.tick_params(labelsize=7)

plt.suptitle('Mod-p Persistence Barcodes: Prime Spectrum vs Even Spectrum', fontsize=13)
plt.tight_layout()
plt.savefig('viz_barcode_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Persistent Rank Function Heatmap

Shows the rank function β(s,t) as a heatmap, demonstrating
monotonicity in s (rows) and antitonicity in t (columns).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def rank_function(barcode, s, t):
    """Count intervals with birth ≤ s and t < death."""
    return sum(1 for (b, d) in barcode if b <= s and t < d)


def betti_at(barcode, t):
    """Betti number at t: count intervals with birth ≤ t < death."""
    return sum(1 for (b, d) in barcode if b <= t < d)


# Sample barcode
barcode = [(0, 8), (1, 12), (2, 6), (3, 15), (5, 10), (7, 14)]

N = 18  # range for s and t

# Compute rank function matrix
rank_matrix = np.zeros((N, N))
for s in range(N):
    for t in range(N):
        rank_matrix[s, t] = rank_function(barcode, s, t)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Rank function heatmap
ax1 = axes[0]
im = ax1.imshow(rank_matrix, cmap='YlOrRd', aspect='equal', origin='lower')
ax1.set_xlabel('t (death threshold)')
ax1.set_ylabel('s (birth threshold)')
ax1.set_title('Rank Function β(s, t)')
plt.colorbar(im, ax=ax1, label='Count')
# Mark the diagonal
for i in range(N):
    ax1.plot(i, i, 'k.', markersize=3)

# Plot 2: Betti numbers (diagonal of rank function)
ax2 = axes[1]
bettis = [betti_at(barcode, t) for t in range(N)]
ax2.step(range(N), bettis, where='post', color='steelblue', linewidth=2)
ax2.fill_between(range(N), bettis, step='post', alpha=0.3, color='steelblue')
ax2.set_xlabel('Filtration parameter t')
ax2.set_ylabel('β(t)')
ax2.set_title('Betti Numbers (Diagonal of Rank Function)')
ax2.grid(True, alpha=0.3)

# Plot 3: Barcode diagram
ax3 = axes[2]
colors = plt.cm.Set2(np.linspace(0, 1, len(barcode)))
for i, (b, d) in enumerate(barcode):
    ax3.barh(i, d - b, left=b, height=0.7, color=colors[i], 
             edgecolor='black', linewidth=0.5)
    ax3.text(b + (d - b) / 2, i, f'[{b},{d})', ha='center', va='center', fontsize=8)
ax3.set_xlabel('Filtration parameter')
ax3.set_ylabel('Interval index')
ax3.set_title('Persistence Barcode')
ax3.set_xlim(-0.5, N)
ax3.grid(True, alpha=0.3, axis='x')

plt.suptitle('Persistence Theory: Rank Function, Betti Numbers, and Barcodes', fontsize=13)
plt.tight_layout()
plt.savefig('viz_rank_function.png', dpi=150, bbox_inches='tight')
print("Saved viz_rank_function.png")


#!/usr/bin/env python3
"""
Visualization: Separation Density of Primewise Invariants

Shows how the density of separating primes approaches 1 as the prime bound grows,
confirming the density-one separation theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n):
    if n < 2: return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def compute_separation_data(a, b, max_prime_bound=500):
    """Compute cumulative separation density as prime bound grows."""
    primes = primes_up_to(max_prime_bound)
    bounds = []
    densities = []
    sep_counts = []
    total_counts = []
    
    sep = 0
    total = 0
    for p in primes:
        ra = [x % p for x in a]
        rb = [x % p for x in b]
        total += 1
        if ra != rb:
            sep += 1
        bounds.append(p)
        densities.append(sep / total if total > 0 else 0)
        sep_counts.append(sep)
        total_counts.append(total)
    
    return bounds, densities, sep_counts, total_counts


# Test cases
cases = [
    ("Perfect squares vs. swapped", 
     [1, 4, 9, 16, 25, 36, 49, 64],
     [4, 1, 16, 9, 36, 25, 64, 49]),
    ("Fibonacci vs. shifted",
     [2, 5, 8, 13, 21, 34, 55, 89],
     [3, 5, 8, 12, 20, 33, 54, 88]),
    ("Arithmetic vs. reversed",
     [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
     [100, 90, 80, 70, 60, 50, 40, 30, 20, 10]),
]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, (name, a, b) in enumerate(cases):
    bounds, densities, sep_counts, total_counts = compute_separation_data(a, b, 500)
    M = max(max(a), max(b))
    
    ax = axes[idx]
    ax.plot(bounds, densities, 'b-', linewidth=1.5, label='Separation density')
    ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Density = 1')
    ax.axvline(x=M, color='g', linestyle=':', alpha=0.7, label=f'M = {M}')
    ax.set_xlabel('Prime bound')
    ax.set_ylabel('Fraction of separating primes')
    ax.set_title(name, fontsize=10)
    ax.set_ylim(-0.05, 1.1)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Primewise Separation Density Convergence to 1', fontsize=13)
plt.tight_layout()
plt.savefig('viz_separation_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_separation_density.png")
