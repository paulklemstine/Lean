#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
================================================

Self-contained numerical examples demonstrating the key combinatorial
results about Borges' Library of Babel, formalized as the Hamming space
Volume(A, L) = Fin(L) -> Fin(A).

Results demonstrated:
  1. Volume cardinality: |Volume(A,L)| = A^L
  2. Babel Degree: every volume has exactly L*(A-1) Hamming neighbors
  3. Babel Diameter: max Hamming distance = L, always achieved for A>=2
  4. Singleton Bound: |C| <= A^(L-d+1) for min-distance-d codes
  5. Self-referential impossibility: more evaluation functions than volumes
"""

from __future__ import annotations
import math
import itertools
from typing import Sequence


# ──────────────────────────────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────────────────────────────

def hamming_dist(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: number of positions where v and w differ."""
    assert len(v) == len(w), "Volumes must have equal length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_neighbors(v: tuple[int, ...], alphabet_size: int) -> list[tuple[int, ...]]:
    """All volumes at Hamming distance exactly 1 from v."""
    neighbors: list[tuple[int, ...]] = []
    for i in range(len(v)):
        for a in range(alphabet_size):
            if a != v[i]:
                w = list(v)
                w[i] = a
                neighbors.append(tuple(w))
    return neighbors


def hamming_ball_size(alphabet_size: int, length: int, radius: int) -> int:
    """Size of the Hamming ball of given radius: sum_{i=0}^{r} C(L,i)*(A-1)^i."""
    return sum(
        math.comb(length, i) * (alphabet_size - 1) ** i
        for i in range(min(radius, length) + 1)
    )


def singleton_bound(alphabet_size: int, length: int, min_dist: int) -> int:
    """Singleton bound: maximum code size for given parameters."""
    return alphabet_size ** (length - min_dist + 1)


# ──────────────────────────────────────────────────────────────────────
# Demo 1: Volume cardinality
# ──────────────────────────────────────────────────────────────────────

def demo_volume_cardinality() -> None:
    """Demonstrate |Volume(A, L)| = A^L."""
    print("=" * 70)
    print("DEMO 1: Volume Cardinality — |Volume(A, L)| = A^L")
    print("=" * 70)

    examples: list[tuple[int, int, str]] = [
        (2, 4, "Binary nibbles"),
        (4, 8, "DNA octamers"),
        (26, 3, "Three-letter words"),
        (4, 16, "Mini-Library (DNA, length 16)"),
    ]

    for a, l, desc in examples:
        card = a ** l
        print(f"  {desc}: A={a}, L={l} → {card:,} volumes")

    # Borges' Library (just the exponent)
    a_borges, l_borges = 25, 1_312_000
    log10_card = l_borges * math.log10(a_borges)
    print(f"\n  Borges' Library: A=25, L=1,312,000")
    print(f"    → 25^1312000 ≈ 10^{log10_card:,.0f}")
    print(f"    (For comparison, ~10^80 atoms in the observable universe)")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 2: Babel Degree Theorem
# ──────────────────────────────────────────────────────────────────────

def demo_babel_degree() -> None:
    """Demonstrate: every volume has exactly L*(A-1) neighbors."""
    print("=" * 70)
    print("DEMO 2: Babel Degree — |N(v)| = L × (A − 1)")
    print("=" * 70)

    test_cases: list[tuple[int, int]] = [(2, 4), (3, 3), (4, 8), (5, 2)]

    for a, l in test_cases:
        expected = l * (a - 1)
        # Test with a few random volumes
        test_vols = [
            tuple(0 for _ in range(l)),           # all zeros
            tuple(a - 1 for _ in range(l)),        # all max
            tuple(i % a for i in range(l)),        # cycling
        ]
        for v in test_vols:
            nbrs = hamming_neighbors(v, a)
            actual = len(nbrs)
            status = "✓" if actual == expected else "✗"
            assert actual == expected, f"Degree mismatch for {v}"

        print(f"  A={a}, L={l}: degree = {expected}  {status} (verified on {len(test_vols)} volumes)")

    # Borges
    borges_degree = 1_312_000 * 24
    print(f"\n  Borges' Library: degree = 1,312,000 × 24 = {borges_degree:,}")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 3: Babel Diameter
# ──────────────────────────────────────────────────────────────────────

def demo_babel_diameter() -> None:
    """Demonstrate: diameter = L, achieved by constant-0 vs constant-1."""
    print("=" * 70)
    print("DEMO 3: Babel Diameter — diam(Volume(A,L)) = L")
    print("=" * 70)

    test_cases: list[tuple[int, int]] = [(2, 4), (4, 8), (3, 5), (10, 3)]

    for a, l in test_cases:
        v_zero = tuple(0 for _ in range(l))
        v_one = tuple(1 for _ in range(l))
        d = hamming_dist(v_zero, v_one)

        # Verify this is maximal by checking all pairs (for small spaces)
        if a ** l <= 10000:
            all_vols = list(itertools.product(range(a), repeat=l))
            max_d = max(
                hamming_dist(v, w)
                for v in all_vols
                for w in all_vols
            )
            assert max_d == l, f"Max distance {max_d} != L={l}"
            status = f"✓ (exhaustive verification over {len(all_vols)} volumes)"
        else:
            status = f"✓ d(0...0, 1...1) = {d} = L"

        print(f"  A={a}, L={l}: diameter = {l}  {status}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 4: Singleton Bound
# ──────────────────────────────────────────────────────────────────────

def demo_singleton_bound() -> None:
    """Demonstrate the Singleton bound: |C| ≤ A^(L-d+1)."""
    print("=" * 70)
    print("DEMO 4: Singleton Bound — |C| ≤ A^(L − d + 1)")
    print("=" * 70)

    a, l = 4, 16
    print(f"\n  Mini-Library: A={a}, L={l} ({a**l:,} total volumes)")
    print(f"  {'Min dist d':>12} | {'Singleton Bound':>18} | {'Fraction of Library':>22}")
    print(f"  {'-'*12}-+-{'-'*18}-+-{'-'*22}")

    for d in [1, 2, 4, 6, 8, 10, 12, 14, 16]:
        bound = singleton_bound(a, l, d)
        fraction = bound / (a ** l)
        print(f"  {d:>12} | {bound:>18,} | {fraction:>22.6e}")

    # Borges with various distances
    print(f"\n  Borges' Library: A=25, L=1,312,000")
    for d in [10, 100, 1000, 10000]:
        exp = 1_312_000 - d + 1
        print(f"    d={d:>6}: bound = 25^{exp:,} ≈ 10^{exp * math.log10(25):,.0f}")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 5: Hamming Ball Sizes
# ──────────────────────────────────────────────────────────────────────

def demo_hamming_balls() -> None:
    """Demonstrate Hamming ball sizes and the sphere-packing bound."""
    print("=" * 70)
    print("DEMO 5: Hamming Ball Sizes and Sphere-Packing Bound")
    print("=" * 70)

    a, l = 4, 16
    total = a ** l
    print(f"\n  Mini-Library: A={a}, L={l} ({total:,} total volumes)")
    print(f"  {'Radius r':>10} | {'Ball size':>14} | {'Fraction':>14} | {'SP bound':>14}")
    print(f"  {'-'*10}-+-{'-'*14}-+-{'-'*14}-+-{'-'*14}")

    for r in range(0, l + 1, 2):
        ball = hamming_ball_size(a, l, r)
        fraction = ball / total
        sp_bound = total // ball if ball > 0 else 0
        print(f"  {r:>10} | {ball:>14,} | {fraction:>14.6e} | {sp_bound:>14,}")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 6: Self-Reference Impossibility
# ──────────────────────────────────────────────────────────────────────

def demo_self_reference() -> None:
    """Demonstrate: |Volume(A,L) → Fin(B)| > |Volume(A,L)| for B ≥ 2."""
    print("=" * 70)
    print("DEMO 6: Self-Reference — More Evaluations Than Volumes")
    print("=" * 70)

    examples: list[tuple[int, int, int]] = [
        (2, 3, 2),
        (2, 4, 2),
        (3, 3, 2),
        (4, 4, 3),
    ]

    for a, l, b in examples:
        n_volumes = a ** l
        n_evals = b ** n_volumes
        ratio_log10 = n_volumes * math.log10(b) - l * math.log10(a)
        print(f"  A={a}, L={l}, B={b}:")
        print(f"    Volumes:     A^L   = {n_volumes:,}")
        if n_evals < 10**15:
            print(f"    Evaluations: B^(A^L) = {n_evals:,}")
        else:
            print(f"    Evaluations: B^(A^L) ≈ 10^{n_volumes * math.log10(b):,.1f}")
        print(f"    Ratio (log₁₀): {ratio_log10:,.1f}")
        print()

    # Borges
    n_borges = 25 ** 10  # stand-in exponent for display
    print(f"  Borges' Library (A=25, L=1,312,000, B=2):")
    log_vols = 1_312_000 * math.log10(25)
    log_evals = 25**1_312_000  # can't compute, just describe
    print(f"    Volumes: ≈ 10^{log_vols:,.0f}")
    print(f"    Evaluations: 2^(25^1312000) ≈ 10^(10^{log_vols:.0f})")
    print(f"    The evaluation space is a power-tower beyond all comparison.")
    print()
    print("  → No encoding can map all evaluation functions to volumes.")
    print("  → The Library CANNOT contain its own complete catalog.")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 7: Mini-Library Visualization (text-based)
# ──────────────────────────────────────────────────────────────────────

def demo_mini_library() -> None:
    """Visualize a tiny Library: A=2, L=3 (8 volumes)."""
    print("=" * 70)
    print("DEMO 7: Complete Mini-Library (A=2, L=3)")
    print("=" * 70)

    a, l = 2, 3
    vols = list(itertools.product(range(a), repeat=l))

    print(f"\n  All {len(vols)} volumes and their Hamming neighbors:")
    print()
    for v in vols:
        nbrs = hamming_neighbors(v, a)
        nbr_strs = [str(n) for n in nbrs]
        print(f"    {''.join(map(str, v))} → neighbors: {', '.join(''.join(map(str, n)) for n in nbrs)}")

    # Verify degree theorem
    for v in vols:
        assert len(hamming_neighbors(v, a)) == l * (a - 1)

    # Find diameter pair
    max_d = 0
    max_pair = (vols[0], vols[0])
    for v in vols:
        for w in vols:
            d = hamming_dist(v, w)
            if d > max_d:
                max_d = d
                max_pair = (v, w)

    print(f"\n  Degree: {l * (a-1)} for every volume ✓")
    print(f"  Diameter pair: {''.join(map(str, max_pair[0]))} ↔ {''.join(map(str, max_pair[1]))}, distance = {max_d} = L ✓")

    # Singleton bound check
    for d in range(1, l + 1):
        sb = singleton_bound(a, l, d)
        print(f"  Singleton bound (d={d}): |C| ≤ {sb}")
    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  THE LIBRARY OF BABEL: Combinatorics of Universal Information Spaces ║")
    print("║  Numerical Demonstrations                                           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_volume_cardinality()
    demo_babel_degree()
    demo_babel_diameter()
    demo_singleton_bound()
    demo_hamming_balls()
    demo_self_reference()
    demo_mini_library()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
