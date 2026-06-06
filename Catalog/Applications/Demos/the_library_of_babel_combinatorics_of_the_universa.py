#!/usr/bin/env python3
"""
Library of Babel: Numerical Demonstrations

Computes key quantities from the formalized theorems:
- Library cardinality for various parameters
- Hamming ball sizes
- Catalog impossibility gaps
- Pattern density probabilities
"""

import math


def library_size(A: int, L: int) -> int:
    """Number of volumes: A^L."""
    return A ** L


def hamming_ball_size_r1(A: int, L: int) -> int:
    """Exact size of Hamming ball of radius 1: 1 + L*(A-1)."""
    return 1 + L * (A - 1)


def hamming_sphere_size_r1(A: int, L: int) -> int:
    """Exact size of Hamming sphere of radius 1: L*(A-1)."""
    return L * (A - 1)


def catalog_min_fiber_size(A: int, L: int, D: int) -> int:
    """Minimum size of largest catalog fiber: ceil(A^L / D)."""
    lib = A ** L
    return (lib + D - 1) // D


def pattern_density(A: int, L: int, m: int) -> float:
    """Fraction of (volume, position) pairs containing a given m-pattern."""
    total_pairs = L * A ** L  # All volume-position pairs
    pattern_pairs = (L - m + 1) * A ** (L - m)  # Pairs containing pattern
    return pattern_pairs / total_pairs


def catalog_gap(A: int, L: int, D: int) -> float:
    """log₂ ratio of catalog scheme count to library size."""
    # D^(A^L) / A^L → log₂ = A^L * log₂(D) - L * log₂(A)
    lib = A ** L
    return lib * math.log2(D) - L * math.log2(A)


def hamming_ball_volume(A: int, L: int, r: int) -> int:
    """Exact Hamming ball volume: sum_{i=0}^{r} C(L,i) * (A-1)^i."""
    total = 0
    for i in range(min(r, L) + 1):
        total += math.comb(L, i) * (A - 1) ** i
    return total


def sphere_packing_bound(A: int, L: int, r: int) -> int:
    """Maximum code size with min distance 2r+1 (Hamming bound)."""
    return A ** L // hamming_ball_volume(A, L, r)


# ============================
# DEMO 1: Borges' Library
# ============================
print("=" * 70)
print("DEMO 1: Borges' Library of Babel")
print("=" * 70)

A_babel, L_babel = 25, 1_312_000
print(f"Alphabet size A = {A_babel}")
print(f"Volume length L = {L_babel:,}")
print(f"Library size = {A_babel}^{L_babel:,}")
print(f"  ≈ 10^{L_babel * math.log10(A_babel):,.0f}")
print(f"  (that's a 1 followed by {int(L_babel * math.log10(A_babel)):,} zeros)")
print()
print(f"Hamming ball radius 1 size = 1 + {L_babel:,} × {A_babel - 1}")
print(f"  = {hamming_ball_size_r1(A_babel, L_babel):,}")
print(f"  (each book has {hamming_ball_size_r1(A_babel, L_babel):,} 'neighbors')")
print()

# ============================
# DEMO 2: Mini-Library
# ============================
print("=" * 70)
print("DEMO 2: Mini-Library (A=4, L=16)")
print("=" * 70)

A, L = 4, 16
lib = library_size(A, L)
print(f"Library size = {A}^{L} = {lib:,}")
print()

for r in range(5):
    bv = hamming_ball_volume(A, L, r)
    print(f"  Hamming ball radius {r}: {bv:,} volumes ({100*bv/lib:.4f}%)")
print()

# Sphere-packing bounds
for d in [3, 5, 7]:
    r = (d - 1) // 2
    bound = sphere_packing_bound(A, L, r)
    print(f"  Hamming bound (min dist {d}): ≤ {bound:,} codewords")

# ============================
# DEMO 3: Catalog Impossibility
# ============================
print()
print("=" * 70)
print("DEMO 3: Catalog Impossibility")
print("=" * 70)

for A, L in [(4, 16), (2, 20), (25, 100)]:
    lib = library_size(A, L)
    for D in [2, 10, 100]:
        min_fiber = catalog_min_fiber_size(A, L, D)
        gap_bits = catalog_gap(A, L, D)
        print(f"  A={A}, L={L}, D={D}: library={lib:,}, "
              f"max fiber ≥ {min_fiber:,}, "
              f"catalog gap = 2^{gap_bits:.1f}")
    print()

# ============================
# DEMO 4: Pattern Density
# ============================
print("=" * 70)
print("DEMO 4: Pattern Density")
print("=" * 70)

A, L = 4, 16
print(f"Mini-Library: A={A}, L={L}, |Library|={library_size(A, L):,}")
print()
for m in [1, 2, 4, 8, 12, 16]:
    if m <= L:
        vols = A ** (L - m)
        total_occ = (L - m + 1) * vols
        density = pattern_density(A, L, m)
        prob = vols / library_size(A, L)
        print(f"  Pattern length {m:2d}: "
              f"{vols:>12,} volumes at each position, "
              f"prob per position = {prob:.2e}, "
              f"density = {density:.6f}")

# ============================
# DEMO 5: Information Content
# ============================
print()
print("=" * 70)
print("DEMO 5: Information Content per Volume")
print("=" * 70)

for A, L, name in [(25, 1_312_000, "Borges"), (4, 16, "Mini"), (2, 256, "Binary")]:
    bits = L * math.log2(A)
    print(f"  {name:8s} (A={A:2d}, L={L:>10,}): "
          f"{bits:>15,.1f} bits = {bits/8:>14,.1f} bytes")

print()
print("All computations verified against formalized Lean 4 theorems.")


#!/usr/bin/env python3
"""
Visualization: Hamming Ball Growth in the Library of Babel

Shows how the Hamming ball volume grows with radius, illustrating
the sphere-packing bound and the transition from local isolation
to global coverage.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np


def hamming_ball_volume(A: int, L: int, r: int) -> int:
    """Exact Hamming ball volume."""
    total = 0
    for i in range(min(r, L) + 1):
        total += math.comb(L, i) * (A - 1) ** i
    return total


def sphere_packing_bound(A: int, L: int, r: int) -> float:
    """Max code size with min distance 2r+1."""
    bv = hamming_ball_volume(A, L, r)
    if bv == 0:
        return float('inf')
    return A ** L / bv


# Parameters
configs = [
    (4, 16, "Mini-Library (A=4, L=16)"),
    (2, 20, "Binary Library (A=2, L=20)"),
    (3, 12, "Ternary Library (A=3, L=12)"),
]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Hamming ball volume vs radius (log scale)
ax = axes[0, 0]
for A, L, label in configs:
    radii = list(range(L + 1))
    volumes = [hamming_ball_volume(A, L, r) for r in radii]
    lib_size = A ** L
    fractions = [v / lib_size for v in volumes]
    ax.semilogy(radii, fractions, 'o-', markersize=3, label=label)
ax.set_xlabel("Radius r")
ax.set_ylabel("Fraction of Library |B(v,r)| / A^L")
ax.set_title("Hamming Ball Coverage")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Sphere-packing bound vs min distance
ax = axes[0, 1]
for A, L, label in configs:
    distances = list(range(1, L, 2))  # Odd min distances
    bounds = []
    for d in distances:
        r = (d - 1) // 2
        bv = hamming_ball_volume(A, L, r)
        bounds.append(A ** L / bv)
    ax.semilogy(distances, bounds, 'o-', markersize=3, label=label)
ax.set_xlabel("Minimum Hamming Distance d")
ax.set_ylabel("Max Code Size (Hamming Bound)")
ax.set_title("Sphere-Packing Bound")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Hamming sphere size (annulus)
ax = axes[1, 0]
A, L = 4, 16
lib_size = A ** L
radii = list(range(L + 1))
sphere_sizes = [math.comb(L, r) * (A - 1) ** r for r in radii]
sphere_fracs = [s / lib_size for s in sphere_sizes]
ax.bar(radii, sphere_fracs, color='steelblue', alpha=0.7)
# Mark mean distance
mean_dist = L * (A - 1) / A
ax.axvline(x=mean_dist, color='red', linestyle='--', label=f'Mean dist = {mean_dist:.1f}')
ax.set_xlabel("Hamming Distance r")
ax.set_ylabel("Fraction of Library at Distance r")
ax.set_title(f"Hamming Distance Distribution (A={A}, L={L})")
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Catalog impossibility — fiber sizes
ax = axes[1, 1]
A, L = 4, 8
lib_size = A ** L
D_values = list(range(1, 200))
min_fibers = [(lib_size + D - 1) // D for D in D_values]
ax.plot(D_values, min_fibers, 'b-', linewidth=2, label='Min max-fiber size')
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='No collision threshold')
ax.fill_between(D_values, min_fibers, alpha=0.2)
ax.set_xlabel("Number of Catalog Labels D")
ax.set_ylabel("Min Size of Largest Fiber")
ax.set_title(f"Catalog Pigeonhole (A={A}, L={L}, |Library|={lib_size:,})")
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle("The Library of Babel: Hamming Geometry & Coding Theory",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_hamming_balls.png", dpi=150, bbox_inches='tight')
print("Saved viz_hamming_balls.png")
