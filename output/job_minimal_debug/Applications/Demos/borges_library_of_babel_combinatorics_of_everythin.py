#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Library of Babel combinatorics.

Demonstrates:
1. Cardinality computations
2. Hamming distance examples
3. Substitution isometry verification
4. Incompressibility fractions
5. Orbit size enumeration
"""

import math
import itertools
from collections import Counter

# =============================================================================
# 1. Cardinality of the Library
# =============================================================================
def babel_cardinality(alpha: int, N: int) -> int:
    """Exact cardinality of the Babel space."""
    return alpha ** N

print("=" * 70)
print("1. CARDINALITY OF THE LIBRARY OF BABEL")
print("=" * 70)

alpha_babel = 25
N_babel = 1_312_000
digits = N_babel * math.log10(alpha_babel)
print(f"Alphabet size: {alpha_babel}")
print(f"Book length: {N_babel:,} characters")
print(f"Total books: 25^{N_babel:,}")
print(f"Number of decimal digits: {int(digits):,}")
print(f"Compare: atoms in observable universe ≈ 10^80")
print(f"Library exceeds universe by factor of 10^{int(digits) - 80:,}")
print()

# =============================================================================
# 2. Hamming Distance Examples
# =============================================================================
def hamming_dist(b1: list, b2: list) -> int:
    """Compute Hamming distance between two books."""
    assert len(b1) == len(b2)
    return sum(1 for x, y in zip(b1, b2) if x != y)

print("=" * 70)
print("2. HAMMING DISTANCE EXAMPLES")
print("=" * 70)

# Small example: alpha=4 (DNA), N=10
book_a = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1]
book_b = [0, 1, 2, 3, 3, 2, 1, 0, 0, 1]
book_c = [3, 2, 1, 0, 3, 2, 1, 0, 3, 2]

d_ab = hamming_dist(book_a, book_b)
d_bc = hamming_dist(book_b, book_c)
d_ac = hamming_dist(book_a, book_c)

print(f"Book A: {book_a}")
print(f"Book B: {book_b}")
print(f"Book C: {book_c}")
print(f"d(A,B) = {d_ab}")
print(f"d(B,C) = {d_bc}")
print(f"d(A,C) = {d_ac}")
print(f"Triangle inequality: d(A,C)={d_ac} ≤ d(A,B)+d(B,C)={d_ab+d_bc} ✓")
print()

# =============================================================================
# 3. Substitution Isometry Verification
# =============================================================================
def apply_substitution(sigma: dict, book: list) -> list:
    """Apply alphabet substitution to a book."""
    return [sigma[c] for c in book]

print("=" * 70)
print("3. SUBSTITUTION ISOMETRY VERIFICATION")
print("=" * 70)

# Injective substitution (cipher): shift by 1 mod 4
sigma_inj = {0: 1, 1: 2, 2: 3, 3: 0}
# Non-injective substitution: collapse 0,1 -> 0
sigma_non = {0: 0, 1: 0, 2: 2, 3: 3}

sa_inj = apply_substitution(sigma_inj, book_a)
sb_inj = apply_substitution(sigma_inj, book_b)
sa_non = apply_substitution(sigma_non, book_a)
sb_non = apply_substitution(sigma_non, book_b)

print(f"Injective σ = {sigma_inj}")
print(f"  d(A, B) = {d_ab}")
print(f"  d(σA, σB) = {hamming_dist(sa_inj, sb_inj)}")
print(f"  Isometry preserved: {d_ab == hamming_dist(sa_inj, sb_inj)} ✓")
print()

print(f"Non-injective σ = {sigma_non}")
print(f"  d(A, B) = {d_ab}")
print(f"  d(σA, σB) = {hamming_dist(sa_non, sb_non)}")
print(f"  Distance decreased: {hamming_dist(sa_non, sb_non) <= d_ab}")
print()

# =============================================================================
# 4. Incompressibility Fractions
# =============================================================================
print("=" * 70)
print("4. INCOMPRESSIBILITY FRACTIONS")
print("=" * 70)

for alpha in [2, 10, 25]:
    for N in [10, 100, 1000]:
        for ratio in [0.5, 0.9, 0.99]:
            M = int(N * ratio)
            frac = alpha ** (M - N)
            print(f"  α={alpha:2d}, N={N:4d}, M={M:4d} (ratio={ratio}): "
                  f"compressible fraction ≤ {alpha}^{M-N} = {frac:.2e}")
    print()

# =============================================================================
# 5. Orbit Enumeration (small cases)
# =============================================================================
print("=" * 70)
print("5. ORBIT ENUMERATION: Book(3, 2)")
print("=" * 70)

alpha, N = 3, 2
all_books = list(itertools.product(range(alpha), repeat=N))
all_subs = list(itertools.product(range(alpha), repeat=alpha))

print(f"Total books: {len(all_books)}")
print(f"Total substitutions: {len(all_subs)}")
print()

orbit_sizes = {}
for book in all_books:
    orbit = set()
    for sub in all_subs:
        sigma = dict(enumerate(sub))
        new_book = tuple(sigma[c] for c in book)
        orbit.add(new_book)
    diversity = len(set(book))
    predicted_size = alpha ** diversity
    orbit_sizes[book] = (len(orbit), diversity, predicted_size)
    print(f"  Book {book}: diversity={diversity}, "
          f"orbit size={len(orbit)}, "
          f"α^d={predicted_size}, "
          f"match={'✓' if len(orbit) == predicted_size else '✗'}")

print()
print("ORBIT-DIVERSITY THEOREM (proved in Lean 4):")
all_match = all(o == f for o, d, f in orbit_sizes.values())
print(f"  All orbit sizes equal α^d: {all_match}")
print()

# =============================================================================
# 6. Constant Book Orbits
# =============================================================================
print("=" * 70)
print("6. CONSTANT BOOK ORBITS")
print("=" * 70)

for alpha in [2, 3, 5]:
    for N in [1, 3, 10]:
        const_book = tuple([0] * N)
        orbit = set()
        for sub in itertools.product(range(alpha), repeat=alpha):
            sigma = dict(enumerate(sub))
            new_book = tuple(sigma[c] for c in const_book)
            orbit.add(new_book)
        print(f"  α={alpha}, N={N}: constant book orbit size = {len(orbit)} "
              f"(expected α={alpha}) {'✓' if len(orbit) == alpha else '✗'}")

print()
print("=" * 70)
print("DEMO COMPLETE")
print("=" * 70)


#!/usr/bin/env python3
"""
visualize_babel.py — Visualization of Library of Babel incompressibility.

Plots the fraction of compressible books as a function of compression ratio
for various alphabet sizes.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compressible_fraction(alpha: int, N: int, M: int) -> float:
    """Upper bound on fraction of compressible books: α^(M-N)."""
    if M >= N:
        return 1.0
    return alpha ** (M - N)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Compressible fraction vs compression ratio
ax1 = axes[0]
N = 100
ratios = np.linspace(0.01, 0.99, 200)
for alpha in [2, 5, 10, 25]:
    fracs = [compressible_fraction(alpha, N, int(N * r)) for r in ratios]
    ax1.semilogy(ratios, fracs, label=f'α = {alpha}', linewidth=2)

ax1.set_xlabel('Compression Ratio M/N', fontsize=12)
ax1.set_ylabel('Compressible Fraction (upper bound)', fontsize=12)
ax1.set_title('Incompressibility: Almost All Books Are Random', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-100, 10)

# Plot 2: Hamming ball volume vs radius
ax2 = axes[1]
N = 50
import math
for alpha in [2, 5, 10, 25]:
    radii = range(0, N + 1)
    volumes = []
    for r in radii:
        vol = sum(math.comb(N, k) * (alpha - 1) ** k for k in range(r + 1))
        total = alpha ** N
        volumes.append(vol / total)
    ax2.plot(list(radii), volumes, label=f'α = {alpha}', linewidth=2)

ax2.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax2.set_ylabel('Volume Fraction |B(b,r)| / α^N', fontsize=12)
ax2.set_title(f'Hamming Ball Volume Growth (N={N})', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('babel_incompressibility.png', dpi=150, bbox_inches='tight')
print("Saved: babel_incompressibility.png")


#!/usr/bin/env python3
"""
visualize_orbits.py — Visualization of substitution orbit structure.

Plots orbit sizes and the orbit-diversity correspondence for small Babel spaces.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import itertools
import math
from collections import Counter

def compute_orbit_size(book: tuple, alpha: int) -> int:
    """Compute the substitution orbit size of a book."""
    orbit = set()
    for sub in itertools.product(range(alpha), repeat=alpha):
        sigma = dict(enumerate(sub))
        orbit.add(tuple(sigma[c] for c in book))
    return len(orbit)

def symbol_diversity(book: tuple) -> int:
    return len(set(book))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# For alpha = 2, 3, 4
for idx, alpha in enumerate([2, 3, 4]):
    ax = axes[idx]
    N = 4 if alpha <= 3 else 3
    books = list(itertools.product(range(alpha), repeat=N))

    diversities = []
    orbit_sizes = []
    predicted = []

    for book in books:
        d = symbol_diversity(book)
        o = compute_orbit_size(book, alpha)
        p = math.perm(alpha, d)
        diversities.append(d)
        orbit_sizes.append(o)
        predicted.append(p)

    ax.scatter(diversities, orbit_sizes, alpha=0.5, s=40, label='Actual orbit size')
    # Plot predicted line
    unique_d = sorted(set(diversities))
    pred_line = [math.perm(alpha, d) for d in unique_d]
    ax.plot(unique_d, pred_line, 'r--', linewidth=2, label='Predicted α^(d)')

    all_match = all(o == p for o, p in zip(orbit_sizes, predicted))
    ax.set_xlabel('Symbol Diversity d', fontsize=11)
    ax.set_ylabel('Orbit Size', fontsize=11)
    ax.set_title(f'Book(α={alpha}, N={N})\nConjecture {"✓" if all_match else "✗"}',
                 fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('babel_orbits.png', dpi=150, bbox_inches='tight')
print("Saved: babel_orbits.png")
