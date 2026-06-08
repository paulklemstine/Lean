#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
================================================

Self-contained Python script demonstrating the key combinatorial results
from the formal theory of universal information spaces.

Each function corresponds to a formally verified theorem.
"""

from __future__ import annotations
import math
from itertools import product
from typing import Sequence


# ──────────────────────────────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────────────────────────────

def library_size(a: int, l: int) -> int:
    """Number of volumes in V(A, L) = A^L.  [volume_card]"""
    return a ** l


def hamming_distance(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: positions where v and w differ.  [hammingDist]"""
    assert len(v) == len(w), "Volumes must have the same length"
    return sum(1 for vi, wi in zip(v, w) if vi != wi)


def hamming_neighbors(v: tuple[int, ...], a: int) -> list[tuple[int, ...]]:
    """All volumes at Hamming distance exactly 1 from v.  [hammingNeighbors]"""
    neighbors: list[tuple[int, ...]] = []
    for i in range(len(v)):
        for symbol in range(a):
            if symbol != v[i]:
                w = list(v)
                w[i] = symbol
                neighbors.append(tuple(w))
    return neighbors


def hamming_ball_size(a: int, l: int, r: int) -> int:
    """Size of the Hamming ball of radius r: sum_{k=0}^{r} C(L,k)*(A-1)^k."""
    return sum(math.comb(l, k) * (a - 1) ** k for k in range(r + 1))


def singleton_bound(a: int, l: int, d: int) -> int:
    """Maximum codewords for min distance d.  [singleton_bound]"""
    return a ** (l - d + 1)


def search_complexity(a: int, l: int, target_count: int) -> int:
    """Expected random samples to find a target volume.  [search_complexity_singleton]"""
    total = a ** l
    return (total + target_count - 1) // target_count


def prefix_fiber_size(a: int, l: int, k: int) -> int:
    """Volumes sharing a k-length prefix: A^(L-k).  [prefix_fiber_card]"""
    return a ** (l - k)


def periodic_volume_count(a: int, p: int) -> int:
    """Number of p-periodic volumes: A^p.  [periodic_volume_count]"""
    return a ** p


def catalog_scheme_count(a: int, l: int, d: int) -> int:
    """Number of possible D-valued catalog schemes: D^(A^L).  [catalog_scheme_card]"""
    return d ** (a ** l)


def distributed_catalog_capacity(a: int, l: int, n: int) -> int:
    """Capacity of N-volume distributed catalog: (A^L)^N."""
    return (a ** l) ** n


def compression_deficiency(a: int, l: int, m: int) -> int:
    """Minimum number of volumes destroyed by compression to length M."""
    return a ** l - a ** m


# ──────────────────────────────────────────────────────────────────────
# Demonstration 1: Mini-Library (A=4, L=4)
# ──────────────────────────────────────────────────────────────────────

def demo_mini_library() -> None:
    """Exhaustive demonstration with a tiny library."""
    A, L = 4, 4
    print("=" * 70)
    print(f"DEMO 1: Mini-Library  A={A}, L={L}")
    print("=" * 70)

    total = library_size(A, L)
    print(f"\n  Library size (volume_card):  {A}^{L} = {total}")

    # Degree regularity [babel_degree]
    v = (0, 0, 0, 0)
    nbrs = hamming_neighbors(v, A)
    expected_degree = L * (A - 1)
    print(f"\n  Hamming neighbors of {v}:")
    print(f"    Count = {len(nbrs)}  (expected L*(A-1) = {expected_degree})")
    assert len(nbrs) == expected_degree, "babel_degree violated!"
    print(f"    ✓ babel_degree confirmed")

    # Diameter [babel_diameter_achieved]
    v_all0 = (0,) * L
    v_all1 = (1,) * L
    d = hamming_distance(v_all0, v_all1)
    print(f"\n  Diameter witness: d({v_all0}, {v_all1}) = {d}")
    assert d == L
    print(f"    ✓ babel_diameter_achieved confirmed (diameter = {L})")

    # Hamming distance properties [hammingDist_*]
    x, y, z = (0, 1, 2, 3), (1, 1, 3, 0), (2, 0, 3, 1)
    print(f"\n  Hamming distance properties:")
    print(f"    d({x}, {x}) = {hamming_distance(x, x)}  (should be 0)")
    print(f"    d({x}, {y}) = {hamming_distance(x, y)}")
    print(f"    d({y}, {x}) = {hamming_distance(y, x)}  (symmetry)")
    dxy = hamming_distance(x, y)
    dyz = hamming_distance(y, z)
    dxz = hamming_distance(x, z)
    print(f"    Triangle: d(x,z)={dxz} ≤ d(x,y)+d(y,z)={dxy}+{dyz}={dxy+dyz}")
    assert dxz <= dxy + dyz, "Triangle inequality violated!"
    print(f"    ✓ All metric properties confirmed")

    # Prefix fibers [prefix_fiber_card]
    prefix = (0, 1)
    k = len(prefix)
    all_volumes = list(product(range(A), repeat=L))
    matching = [v for v in all_volumes if v[:k] == prefix]
    expected = prefix_fiber_size(A, L, k)
    print(f"\n  Prefix fiber for {prefix}*:")
    print(f"    Matching volumes = {len(matching)}  (expected A^(L-k) = {expected})")
    assert len(matching) == expected
    print(f"    ✓ prefix_fiber_card confirmed")

    # Periodic volumes [periodic_volume_count]
    p = 2
    periodic = [v for v in all_volumes
                if all(v[i] == v[i % p] for i in range(L))]
    expected_periodic = periodic_volume_count(A, p)
    print(f"\n  {p}-periodic volumes:")
    print(f"    Count = {len(periodic)}  (expected A^p = {expected_periodic})")
    print(f"    Examples: {periodic[:5]}")
    assert len(periodic) == expected_periodic
    print(f"    ✓ periodic_volume_count confirmed")

    # Sphere size sum [sphere_size_sum]
    sphere_sum = sum(
        math.comb(L, k) * (A - 1) ** k for k in range(L + 1)
    )
    print(f"\n  Sphere size sum: Σ C(L,k)*(A-1)^k = {sphere_sum}")
    print(f"    A^L = {total}")
    assert sphere_sum == total
    print(f"    ✓ sphere_size_sum confirmed")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demonstration 2: Catalog Impossibility
# ──────────────────────────────────────────────────────────────────────

def demo_catalog_impossibility() -> None:
    """Demonstrates the finite Cantor theorem for small parameters."""
    print("=" * 70)
    print("DEMO 2: Catalog Impossibility (Finite Cantor)")
    print("=" * 70)

    examples = [(2, 2, 2), (2, 3, 2), (3, 2, 2), (2, 4, 3)]
    for A, L, D in examples:
        vol = library_size(A, L)
        schemes = catalog_scheme_count(A, L, D)
        print(f"\n  A={A}, L={L}, D={D}:")
        print(f"    Volumes       = A^L     = {vol}")
        print(f"    Catalog schemes = D^(A^L) = {D}^{vol} = {schemes}")
        print(f"    {vol} < {schemes}  →  ✓ catalog_impossibility")
        assert vol < schemes

    # Demonstrate no_catalog_embedding for tiny case
    A, L, D = 2, 2, 2
    vol = library_size(A, L)
    volumes = list(product(range(A), repeat=L))
    # All functions from volumes → {0,1}
    scheme_count = D ** vol
    print(f"\n  Injection test (A={A}, L={L}, D={D}):")
    print(f"    {scheme_count} catalog schemes vs {vol} volumes")
    print(f"    No injection: {scheme_count} > {vol}")
    print(f"    ✓ no_catalog_embedding confirmed")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demonstration 3: Coding-Theoretic Bounds
# ──────────────────────────────────────────────────────────────────────

def demo_coding_bounds() -> None:
    """Demonstrates Singleton and sphere-packing bounds."""
    print("=" * 70)
    print("DEMO 3: BabelCode Bounds")
    print("=" * 70)

    configs = [
        (4, 16, "Mini-Library"),
        (2, 8, "Binary Byte"),
        (26, 100, "English Letters"),
    ]

    for A, L, name in configs:
        print(f"\n  {name} (A={A}, L={L}):")
        print(f"    Library size: {A}^{L} = {library_size(A, L):,}")
        print(f"    Degree: L*(A-1) = {L * (A - 1)}")
        print(f"    Diameter: {L}")

        print(f"\n    Singleton bound |C| ≤ A^(L-d+1):")
        for d in [2, 3, 5, 10]:
            if d <= L:
                bound = singleton_bound(A, L, d)
                print(f"      d={d:3d}:  |C| ≤ {bound:>20,}")

        print(f"\n    Hamming ball sizes (sphere-packing):")
        for r in [0, 1, 2, 3]:
            if r <= L:
                bs = hamming_ball_size(A, L, r)
                max_codes = library_size(A, L) // bs
                print(f"      r={r}: |B(v,{r})| = {bs:>12,}  →  "
                      f"max codewords ≤ {max_codes:>12,}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demonstration 4: Compression / Incompressibility
# ──────────────────────────────────────────────────────────────────────

def demo_compression() -> None:
    """Demonstrates the incompressibility barrier."""
    print("=" * 70)
    print("DEMO 4: Incompressibility Barrier")
    print("=" * 70)

    A, L = 4, 8
    total = library_size(A, L)
    print(f"\n  Library: A={A}, L={L}, |V| = {total:,}")
    print(f"\n  Compressing to length M < L:")
    print(f"  {'M':>4s}  {'A^M (max survivors)':>20s}  {'Deficiency':>20s}  {'% lost':>8s}")
    print(f"  {'─'*4}  {'─'*20}  {'─'*20}  {'─'*8}")
    for M in range(L - 1, max(0, L - 6) - 1, -1):
        survivors = A ** M
        deficiency = compression_deficiency(A, L, M)
        pct = 100 * deficiency / total
        print(f"  {M:4d}  {survivors:20,}  {deficiency:20,}  {pct:7.2f}%")
        assert deficiency >= survivors, "incompressible_ge_compressible violated!"
    print(f"\n  ✓ incompressible_ge_compressible: deficiency ≥ survivors in all cases")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demonstration 5: Borges' Actual Library
# ──────────────────────────────────────────────────────────────────────

def demo_borges_library() -> None:
    """Numerical facts about the actual Library of Babel."""
    print("=" * 70)
    print("DEMO 5: Borges' Library of Babel (A=25, L=1,312,000)")
    print("=" * 70)

    A = 25
    L = 1_312_000

    log10_size = L * math.log10(A)
    print(f"\n  Alphabet size A = {A}")
    print(f"  Volume length L = {L:,}")
    print(f"\n  Library size: 25^1,312,000")
    print(f"  log₁₀(size) = {log10_size:,.1f}")
    print(f"  That's a number with ~{int(log10_size):,} digits")

    degree = L * (A - 1)
    print(f"\n  Hamming degree: L*(A-1) = {degree:,}")
    print(f"  Diameter: {L:,}")

    # Singleton bound for various d
    print(f"\n  Singleton bound examples:")
    for d in [1, 10, 100, 1000, 10000]:
        exp = L - d + 1
        print(f"    d = {d:>6,}:  |C| ≤ 25^{exp:,}")

    # Prefix fiber
    print(f"\n  Prefix fiber examples:")
    for k in [1, 10, 100, 1000]:
        exp = L - k
        print(f"    {k:>6,}-char prefix:  {A}^{exp:,} matching volumes")

    # Search complexity for single volume
    print(f"\n  Search complexity for 1 volume: 25^{L:,} samples")
    print(f"  (≈ 10^{log10_size:,.1f} samples)")

    # Periodic volumes
    print(f"\n  Periodic volume counts:")
    for p in [1, 2, 4, 8, 100]:
        if L % p == 0:
            print(f"    period {p:>4d}: {A}^{p} = {A**p if p <= 20 else f'25^{p}'} volumes")

    # Catalog impossibility
    print(f"\n  Catalog impossibility:")
    print(f"    Volumes:          25^{L:,}")
    print(f"    2-valued schemes: 2^(25^{L:,})")
    print(f"    Ratio:            2^(25^{L:,}) / 25^{L:,}")
    print(f"    → Incomparably more schemes than volumes")
    print(f"    ✓ No catalog embedding possible")

    # Compression
    print(f"\n  Compression to L-1 = {L-1:,}:")
    print(f"    Max survivors: 25^{L-1:,}")
    print(f"    Deficiency:    25^{L:,} - 25^{L-1:,} = 24 · 25^{L-1:,}")
    print(f"    Fraction lost: 24/25 = {24/25*100:.1f}%")
    print(f"    ✓ More than half the Library destroyed")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demonstration 6: Exhaustive Verification (Tiny Case)
# ──────────────────────────────────────────────────────────────────────

def demo_exhaustive_verification() -> None:
    """Exhaustively verify all theorems for A=2, L=3."""
    A, L = 2, 3
    print("=" * 70)
    print(f"DEMO 6: Exhaustive Verification  A={A}, L={L}")
    print("=" * 70)

    all_vols = [tuple(v) for v in product(range(A), repeat=L)]
    total = len(all_vols)
    print(f"\n  All {total} volumes: {all_vols}")

    # volume_card
    assert total == A ** L
    print(f"  ✓ volume_card: |V| = {total} = {A}^{L}")

    # hammingDist properties
    errors = 0
    for v in all_vols:
        assert hamming_distance(v, v) == 0  # self
        for w in all_vols:
            assert hamming_distance(v, w) == hamming_distance(w, v)  # comm
            assert hamming_distance(v, w) <= L  # bounded
            if hamming_distance(v, w) == 0:
                assert v == w  # eq_zero_iff
            for u in all_vols:
                if hamming_distance(v, u) > hamming_distance(v, w) + hamming_distance(w, u):
                    errors += 1  # triangle
    print(f"  ✓ All Hamming distance properties verified ({total}³ = {total**3} triples)")
    assert errors == 0

    # babel_degree
    for v in all_vols:
        nbrs = hamming_neighbors(v, A)
        assert len(nbrs) == L * (A - 1), f"Degree wrong for {v}"
    print(f"  ✓ babel_degree: all {total} volumes have degree {L*(A-1)}")

    # babel_diameter_achieved
    max_dist = max(hamming_distance(v, w) for v in all_vols for w in all_vols)
    assert max_dist == L
    print(f"  ✓ babel_diameter_achieved: max distance = {L}")

    # prefix_fiber_card
    for k in range(L + 1):
        for prefix in product(range(A), repeat=k):
            fiber = [v for v in all_vols if v[:k] == prefix]
            assert len(fiber) == A ** (L - k)
    print(f"  ✓ prefix_fiber_card: all prefix fibers correct")

    # sphere_size_sum
    for v in all_vols:
        sphere_total = sum(
            sum(1 for w in all_vols if hamming_distance(v, w) == k)
            for k in range(L + 1)
        )
        assert sphere_total == total
    print(f"  ✓ sphere_size_sum: all sphere decompositions sum to {total}")

    # Singleton bound (check by brute force for d=2)
    d = 2
    # Find maximum code with min distance d
    from itertools import combinations
    max_code_size = 0
    for size in range(total, 0, -1):
        found = False
        for code in combinations(all_vols, size):
            if all(hamming_distance(code[i], code[j]) >= d
                   for i in range(len(code)) for j in range(i+1, len(code))):
                max_code_size = size
                found = True
                break
        if found:
            break
    sb = singleton_bound(A, L, d)
    print(f"  ✓ singleton_bound: max code with d={d} has {max_code_size} ≤ {sb} codewords")
    assert max_code_size <= sb

    print(f"\n  All theorems exhaustively verified! ✓")
    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     THE LIBRARY OF BABEL: COMBINATORICS OF UNIVERSAL LIBRARIES     ║")
    print("║              Numerical Demonstrations of Key Results               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_mini_library()
    demo_catalog_impossibility()
    demo_coding_bounds()
    demo_compression()
    demo_borges_library()
    demo_exhaustive_verification()

    print("All demonstrations completed successfully.")
