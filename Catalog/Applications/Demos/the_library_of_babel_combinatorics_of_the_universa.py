#!/usr/bin/env python3
"""
Library of Babel: Combinatorics of the Universal Library
Numerical demonstrations of the formalized results.
"""

import math
from itertools import product

# === Library Parameters ===
ALPHABET_SIZE = 25  # Borges' 25 symbols
BOOK_LENGTH = 1_312_000  # 410 pages × 3200 chars/page

def library_size(A: int, L: int) -> int:
    """Total number of volumes in the library: A^L."""
    return A ** L

def catalog_scheme_count(A: int, L: int, D: int) -> int:
    """Number of possible D-valued catalog schemes: D^(A^L)."""
    return D ** (A ** L)

def sphere_size(A: int, L: int, k: int) -> int:
    """Number of volumes at Hamming distance exactly k from a reference."""
    return math.comb(L, k) * (A - 1) ** k

def compression_deficiency(A: int, L: int, M: int) -> int:
    """Minimum number of incompressible volumes: A^L - A^M."""
    return A ** L - A ** M

def periodic_count(A: int, L: int, p: int) -> int:
    """Number of p-periodic volumes (when p | L): A^p."""
    assert L % p == 0, f"p={p} must divide L={L}"
    return A ** p

def fiber_count(A: int, L: int, a: int, k: int) -> int:
    """Volumes where symbol a appears exactly k times: C(L,k) * (A-1)^(L-k)."""
    return math.comb(L, k) * (A - 1) ** (L - k)

# === Mini-Library Demonstrations ===
print("=" * 70)
print("LIBRARY OF BABEL: COMBINATORICS OF THE UNIVERSAL LIBRARY")
print("=" * 70)

# Demo 1: Mini-library
print("\n--- Demo 1: Mini-Library (A=4, L=16) ---")
A, L = 4, 16
total = library_size(A, L)
print(f"Alphabet size: {A}")
print(f"Volume length: {L}")
print(f"Total volumes: {A}^{L} = {total:,}")

# Hamming sphere sizes
print("\nHamming sphere sizes (volumes at exact distance k):")
cumulative = 0
for k in range(min(6, L + 1)):
    s = sphere_size(A, L, k)
    cumulative += s
    print(f"  k={k}: C({L},{k}) × {A-1}^{k} = {s:,}")
print(f"  Sum over all k: {sum(sphere_size(A, L, k) for k in range(L+1)):,} (should = {total:,})")

# Verify binomial partition
total_check = sum(sphere_size(A, L, k) for k in range(L + 1))
assert total_check == total, f"Binomial partition failed: {total_check} != {total}"
print("  ✓ Binomial partition verified!")

# Demo 2: Catalog impossibility
print("\n--- Demo 2: Catalog Impossibility ---")
A, L, D = 3, 4, 2
lib = library_size(A, L)
cat = catalog_scheme_count(A, L, D)
print(f"Library (A={A}, L={L}): {lib} volumes")
print(f"Catalog schemes (D={D}): {D}^{lib} = {cat} schemes")
print(f"Ratio schemes/volumes: {cat / lib:.1f}")
print(f"A single volume can represent at most {lib} of {cat} schemes")
print(f"  → {lib / cat * 100:.6f}% of all possible catalogs are representable")
print("  ✓ Catalog impossibility: most schemes are unrepresentable!")

# Demo 3: Compression deficiency
print("\n--- Demo 3: Compression Deficiency ---")
A, L, M = 4, 16, 12
full = library_size(A, L)
compressed = library_size(A, M)
deficiency = compression_deficiency(A, L, M)
print(f"Full library: {A}^{L} = {full:,} volumes")
print(f"Compressed space: {A}^{M} = {compressed:,} states")
print(f"Minimum incompressible: {deficiency:,} ({deficiency / full * 100:.4f}%)")
print(f"  ✓ {deficiency / full * 100:.2f}% of volumes cannot survive compression!")

# Demo 4: Periodic volumes
print("\n--- Demo 4: Periodic Volumes ---")
A, L = 4, 12
for p in [1, 2, 3, 4, 6, 12]:
    if L % p == 0:
        count = periodic_count(A, L, p)
        frac = count / library_size(A, L)
        print(f"  Period {p:2d}: {count:>12,} volumes ({frac:.2e} of library)")

# Demo 5: Symbol frequency fibers
print("\n--- Demo 5: Symbol Frequency Distribution ---")
A, L = 4, 8
print(f"Library (A={A}, L={L}): volumes by frequency of symbol 0")
total_check = 0
for k in range(L + 1):
    count = fiber_count(A, L, 0, k)
    total_check += count
    print(f"  freq={k}: C({L},{k}) × {A-1}^{L-k} = {count:>8,}")
print(f"  Total: {total_check:,} (should = {library_size(A, L):,})")
assert total_check == library_size(A, L)
print("  ✓ Fiber partition verified!")

# Demo 6: Fixed volumes under permutations
print("\n--- Demo 6: Fixed Volumes Under Permutations ---")
A, L = 3, 6
lib = library_size(A, L)
print(f"Library (A={A}, L={L}): {lib} volumes")
print(f"  Identity: {lib} fixed (A^L = {A}^{L})")
print(f"  Transposition (swap positions 0,1): {A**(L-1)} fixed (A^(L-1) = {A}^{L-1})")
print(f"  Full cycle (0→1→...→5→0): {A} fixed (A^1 = {A})")

# Demo 7: Borges' actual library
print("\n--- Demo 7: Borges' Library Scale ---")
A, L = ALPHABET_SIZE, BOOK_LENGTH
log_lib = L * math.log10(A)
print(f"Alphabet: {A} symbols")
print(f"Book length: {L:,} characters")
print(f"Library size: {A}^{L:,}")
print(f"  = 10^{log_lib:,.0f} volumes")
print(f"  Comparison: observable universe has ~10^80 particles")
print(f"  Library is 10^{log_lib - 80:,.0f} times larger than the universe (by particle count)")

bits_per_book = L * math.log2(A)
print(f"\nBits per book: L × log₂(A) = {L} × {math.log2(A):.4f} = {bits_per_book:,.0f}")
print(f"Bytes per book: {bits_per_book / 8:,.0f}")

# Compression deficiency for Borges
M = L - 1  # Compress by just 1 character
frac_incompressible = 1 - A ** (-1)
print(f"\nCompressing by 1 character (M = L-1):")
print(f"  At least {frac_incompressible * 100:.1f}% of books are incompressible")

# Demo 8: Primal vs Dual library
print("\n--- Demo 8: Primal-Dual Asymmetry ---")
for A, L in [(2, 4), (4, 2), (3, 3), (2, 8), (5, 3)]:
    primal = A ** L
    dual = L ** A
    print(f"  A={A}, L={L}: primal A^L = {primal:>8,}, dual L^A = {dual:>8,}, "
          f"ratio = {primal / dual:.2f}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Hamming Sphere Structure of the Library of Babel
Standalone matplotlib script showing the binomial partition.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np


def sphere_size(A: int, L: int, k: int) -> int:
    """Size of Hamming sphere at distance k: C(L,k) * (A-1)^k."""
    return math.comb(L, k) * (A - 1) ** k


def plot_hamming_distribution(A: int, L: int, title_suffix: str = ""):
    """Plot the distribution of Hamming sphere sizes."""
    ks = list(range(L + 1))
    sizes = [sphere_size(A, L, k) for k in ks]
    total = sum(sizes)
    fractions = [s / total for s in sizes]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: raw counts (log scale)
    ax1.bar(ks, sizes, color='steelblue', alpha=0.8, edgecolor='navy', linewidth=0.5)
    ax1.set_yscale('log')
    ax1.set_xlabel('Hamming Distance k', fontsize=12)
    ax1.set_ylabel('Number of Volumes (log scale)', fontsize=12)
    ax1.set_title(f'Hamming Sphere Sizes: Library({A}, {L}){title_suffix}', fontsize=13)
    ax1.grid(True, alpha=0.3)

    # Right: probability distribution
    ax2.plot(ks, fractions, 'o-', color='crimson', markersize=4, linewidth=1.5)
    mean_k = L * (A - 1) / A
    std_k = math.sqrt(L * (A - 1) / (A ** 2))
    ax2.axvline(mean_k, color='green', linestyle='--', linewidth=1.5,
                label=f'Mean = L(A-1)/A = {mean_k:.1f}')
    ax2.axvline(mean_k - std_k, color='orange', linestyle=':', linewidth=1)
    ax2.axvline(mean_k + std_k, color='orange', linestyle=':', linewidth=1,
                label=f'±1 std = {std_k:.1f}')
    ax2.set_xlabel('Hamming Distance k', fontsize=12)
    ax2.set_ylabel('Fraction of Library', fontsize=12)
    ax2.set_title(f'Hamming Distance Distribution{title_suffix}', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def plot_compression_deficiency():
    """Plot compression deficiency as a function of compression ratio."""
    fig, ax = plt.subplots(figsize=(10, 6))

    for A in [2, 3, 4, 5, 10, 25]:
        L = 20
        Ms = list(range(L + 1))
        deficiencies = [1 - A ** (M - L) for M in Ms]
        ax.plot([M / L for M in Ms], deficiencies, 'o-', markersize=3,
                label=f'A = {A}', linewidth=1.5)

    ax.set_xlabel('Compression Ratio M/L', fontsize=12)
    ax.set_ylabel('Fraction Incompressible', fontsize=12)
    ax.set_title('Compression Deficiency vs. Compression Ratio (L=20)', fontsize=13)
    ax.legend(fontsize=10, loc='lower left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)

    plt.tight_layout()
    return fig


def plot_periodic_structure():
    """Plot periodic volume counts for various periods."""
    A, L = 4, 60
    divisors = [d for d in range(1, L + 1) if L % d == 0]

    fig, ax = plt.subplots(figsize=(10, 6))

    log_counts = [p * math.log10(A) for p in divisors]
    log_total = L * math.log10(A)

    bars = ax.bar(range(len(divisors)), log_counts, color='teal', alpha=0.8,
                  edgecolor='darkslategray', linewidth=0.5)
    ax.axhline(log_total, color='red', linestyle='--', linewidth=1.5,
               label=f'Total library: log₁₀({A}^{L}) = {log_total:.0f}')
    ax.set_xticks(range(len(divisors)))
    ax.set_xticklabels([str(d) for d in divisors], rotation=45, ha='right')
    ax.set_xlabel('Period p (divisors of L=60)', fontsize=12)
    ax.set_ylabel('log₁₀(Number of p-periodic volumes)', fontsize=12)
    ax.set_title(f'Periodic Volume Counts in Library({A}, {L})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig


if __name__ == '__main__':
    # Generate all plots
    fig1 = plot_hamming_distribution(4, 16, " — Mini-Library")
    fig1.savefig('hamming_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved hamming_distribution.png")

    fig2 = plot_compression_deficiency()
    fig2.savefig('compression_deficiency.png', dpi=150, bbox_inches='tight')
    print("Saved compression_deficiency.png")

    fig3 = plot_periodic_structure()
    fig3.savefig('periodic_structure.png', dpi=150, bbox_inches='tight')
    print("Saved periodic_structure.png")

    plt.show()
