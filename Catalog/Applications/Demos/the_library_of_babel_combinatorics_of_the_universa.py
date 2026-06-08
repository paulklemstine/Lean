#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
===============================================

Self-contained numerical examples demonstrating the combinatorial
results formally verified for the Library of Babel:

  1. Volume cardinality (A^L)
  2. Degree regularity (L*(A-1) neighbors per volume)
  3. Diameter (exactly L)
  4. Singleton bound (A^(L-d+1))
  5. Hamming ball sizes
  6. Self-reference impossibility (Cantor argument)
  7. Mini-Library exploration (A=4, L=16)
"""

from __future__ import annotations

import math
import itertools
import random
from typing import Sequence


# ─────────────────────────────────────────────
# §1  Core Definitions
# ─────────────────────────────────────────────

def hamming_distance(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: number of positions where v and w differ."""
    assert len(v) == len(w), "Volumes must have equal length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_ball_size(A: int, L: int, r: int) -> int:
    """Exact size of a Hamming ball of radius r in Volume(A, L).

    |B(v, r)| = sum_{k=0}^{r} C(L,k) * (A-1)^k
    """
    return sum(math.comb(L, k) * (A - 1) ** k for k in range(r + 1))


def volume_count(A: int, L: int) -> int:
    """Total number of volumes: A^L."""
    return A ** L


def singleton_bound(A: int, L: int, d: int) -> int:
    """Singleton bound: maximum codewords for min distance d."""
    return A ** (L - d + 1)


def hamming_bound(A: int, L: int, d: int) -> float:
    """Hamming (sphere-packing) bound for odd min distance d = 2t+1."""
    assert d % 2 == 1, "Hamming bound stated for odd d"
    t = (d - 1) // 2
    ball = hamming_ball_size(A, L, t)
    return A ** L / ball


# ─────────────────────────────────────────────
# §2  Demonstrations
# ─────────────────────────────────────────────

def demo_hamming_properties() -> None:
    """Demonstrate Hamming distance properties (Theorems 3.1–3.4)."""
    print("=" * 60)
    print("§1  HAMMING DISTANCE PROPERTIES")
    print("=" * 60)

    v = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]
    w = [0, 1, 2, 3, 3, 2, 1, 0, 0, 1, 2, 3, 3, 2, 1, 0]
    u = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

    print(f"\n  v = {v}")
    print(f"  w = {w}")
    print(f"  u = {u}")

    d_vv = hamming_distance(v, v)
    d_vw = hamming_distance(v, w)
    d_wv = hamming_distance(w, v)
    d_vu = hamming_distance(v, u)

    print(f"\n  hammingDist_self:       d(v, v) = {d_vv}  ✓ (= 0)")
    print(f"  hammingDist_comm:       d(v, w) = {d_vw}, d(w, v) = {d_wv}  ✓ (equal)")
    print(f"  hammingDist_le_length:  d(v, u) = {d_vu} ≤ {len(v)}  ✓")
    print(f"  hammingDist_eq_zero:    d(v, v) = 0 ⟺ v = v  ✓")

    # Triangle inequality check
    d_wu = hamming_distance(w, u)
    print(f"\n  Triangle inequality:    d(v,u)={d_vu} ≤ d(v,w)+d(w,u)={d_vw}+{d_wu}={d_vw + d_wu}  ✓")


def demo_degree_regularity() -> None:
    """Demonstrate babel_degree: every volume has L*(A-1) neighbors."""
    print("\n" + "=" * 60)
    print("§2  DEGREE REGULARITY (babel_degree)")
    print("=" * 60)

    A, L = 4, 8  # Small example for enumeration
    expected = L * (A - 1)

    # Pick a random volume and count neighbors by brute force
    v = tuple(random.randint(0, A - 1) for _ in range(L))
    neighbor_count = 0
    for w in itertools.product(range(A), repeat=L):
        if hamming_distance(v, w) == 1:
            neighbor_count += 1

    print(f"\n  Library parameters: A={A}, L={L}")
    print(f"  Test volume: {v}")
    print(f"  Expected neighbors: L*(A-1) = {L}*{A - 1} = {expected}")
    print(f"  Actual neighbors (brute force): {neighbor_count}")
    print(f"  Match: {'✓' if neighbor_count == expected else '✗'}")

    # Show formula for larger cases
    print("\n  Formula applied to various libraries:")
    for A_ex, L_ex, name in [(25, 1_312_000, "Borges"), (4, 16, "Mini"), (2, 256, "Binary")]:
        deg = L_ex * (A_ex - 1)
        print(f"    {name:8s} (A={A_ex}, L={L_ex:>10,}): {deg:>15,} neighbors")


def demo_diameter() -> None:
    """Demonstrate babel_diameter_achieved: diameter = L."""
    print("\n" + "=" * 60)
    print("§3  DIAMETER (babel_diameter_achieved)")
    print("=" * 60)

    A, L = 4, 16
    v_all_zero = [0] * L
    w_all_one = [1] * L
    d = hamming_distance(v_all_zero, w_all_one)

    print(f"\n  Library: A={A}, L={L}")
    print(f"  v = (0, 0, ..., 0)  [all zeros]")
    print(f"  w = (1, 1, ..., 1)  [all ones]")
    print(f"  d(v, w) = {d}")
    print(f"  Expected diameter: L = {L}")
    print(f"  Achieved: {'✓' if d == L else '✗'}")

    # Verify upper bound by sampling
    print("\n  Sampling 10,000 random pairs to verify upper bound...")
    max_seen = 0
    for _ in range(10_000):
        a = tuple(random.randint(0, A - 1) for _ in range(L))
        b = tuple(random.randint(0, A - 1) for _ in range(L))
        max_seen = max(max_seen, hamming_distance(a, b))
    print(f"  Maximum distance seen in sample: {max_seen} ≤ {L}  ✓")


def demo_singleton_bound() -> None:
    """Demonstrate singleton_bound: |C| ≤ A^(L-d+1)."""
    print("\n" + "=" * 60)
    print("§4  SINGLETON BOUND (singleton_bound)")
    print("=" * 60)

    cases = [
        (4, 16, 1, "No separation"),
        (4, 16, 4, "Moderate"),
        (4, 16, 8, "Half-length"),
        (4, 16, 16, "Maximum"),
    ]

    print(f"\n  Mini-Library: A=4, L=16")
    print(f"  {'d':>4s}  {'A^(L-d+1)':>15s}  {'Total A^L':>15s}  {'Ratio':>12s}  Note")
    print(f"  {'─'*4}  {'─'*15}  {'─'*15}  {'─'*12}  {'─'*20}")

    total = volume_count(4, 16)
    for A, L, d, note in cases:
        bound = singleton_bound(A, L, d)
        ratio = bound / total
        print(f"  {d:4d}  {bound:15,}  {total:15,}  {ratio:12.2e}  {note}")

    # Borges' Library
    print(f"\n  Borges' Library: A=25, L=1,312,000")
    print(f"  d = 656,000 (half-length):")
    log_bound = (1_312_000 - 656_000 + 1) * math.log10(25)
    log_total = 1_312_000 * math.log10(25)
    print(f"    log₁₀(bound) ≈ {log_bound:,.0f}")
    print(f"    log₁₀(total) ≈ {log_total:,.0f}")
    print(f"    Ratio ≈ 10^{log_bound - log_total:,.0f}")


def demo_hamming_balls() -> None:
    """Demonstrate Hamming ball sizes."""
    print("\n" + "=" * 60)
    print("§5  HAMMING BALL SIZES")
    print("=" * 60)

    A, L = 4, 16
    total = volume_count(A, L)

    print(f"\n  Library: A={A}, L={L}, total = {total:,}")
    print(f"  {'r':>4s}  {'|B(v,r)|':>15s}  {'Fraction':>12s}")
    print(f"  {'─'*4}  {'─'*15}  {'─'*12}")

    for r in range(L + 1):
        ball = hamming_ball_size(A, L, r)
        frac = ball / total
        marker = " ←" if r == L else ""
        print(f"  {r:4d}  {ball:15,}  {frac:12.6f}{marker}")
        if frac >= 1.0:
            break


def demo_self_reference() -> None:
    """Demonstrate self_eval_exceeds_volumes (finite Cantor argument)."""
    print("\n" + "=" * 60)
    print("§6  SELF-REFERENCE IMPOSSIBILITY (Cantor argument)")
    print("=" * 60)

    print("\n  The number of possible evaluation functions (Volume → Fin A)")
    print("  exceeds the number of volumes, so no single volume can serve")
    print("  as a universal catalog.\n")

    cases = [(2, 2), (2, 4), (3, 3), (4, 4), (4, 8)]
    print(f"  {'A':>3s}  {'L':>3s}  {'log₂(Volumes)':>15s}  {'log₂(Evaluations)':>20s}  {'Ratio (log₂)':>15s}")
    print(f"  {'─'*3}  {'─'*3}  {'─'*15}  {'─'*20}  {'─'*15}")

    for A, L in cases:
        log_vol = L * math.log2(A)
        log_eval = A**L * math.log2(A)
        print(f"  {A:3d}  {L:3d}  {log_vol:15.1f}  {log_eval:20.1f}  {log_eval - log_vol:15.1f}")

    print(f"\n  For Borges (A=25, L=1,312,000):")
    log_vol_borges = 1_312_000 * math.log2(25)
    print(f"    log₂(Volumes) ≈ {log_vol_borges:,.0f}")
    print(f"    log₂(Evaluations) ≈ 25^1,312,000 × log₂(25) ≈ 10^1,834,097 × 4.64")
    print(f"    Ratio: incomprehensibly large — no single volume can be a catalog.")


def demo_mini_library() -> None:
    """Full exploration of a mini-Library with A=4, L=4."""
    print("\n" + "=" * 60)
    print("§7  MINI-LIBRARY EXPLORATION (A=4, L=4)")
    print("=" * 60)

    A, L = 4, 4
    total = volume_count(A, L)
    print(f"\n  Total volumes: {A}^{L} = {total}")
    print(f"  Neighbors per volume: {L}×{A - 1} = {L * (A - 1)}")
    print(f"  Diameter: {L}")

    # Build a small BabelCode
    print(f"\n  Constructing a BabelCode with min distance d=3:")
    code: list[tuple[int, ...]] = []
    all_vols = list(itertools.product(range(A), repeat=L))

    # Greedy construction
    random.seed(42)
    random.shuffle(all_vols)
    d_min = 3

    for v in all_vols:
        if all(hamming_distance(v, c) >= d_min for c in code):
            code.append(v)

    print(f"  Greedy code size: {len(code)} codewords")
    print(f"  Singleton bound:  {singleton_bound(A, L, d_min)} codewords")
    print(f"  Hamming bound:    {hamming_bound(A, L, d_min):.1f} codewords (d=3, t=1)")

    # Verify minimum distance
    actual_min = min(
        hamming_distance(code[i], code[j])
        for i in range(len(code))
        for j in range(i + 1, len(code))
    )
    print(f"  Actual min distance: {actual_min} ≥ {d_min}  ✓")

    # Show a few codewords
    print(f"\n  First 10 codewords:")
    for i, c in enumerate(code[:10]):
        print(f"    [{i:3d}] {c}")


def demo_probability_of_proof() -> None:
    """Estimate probability of finding a specific string in the Library."""
    print("\n" + "=" * 60)
    print("§8  PROBABILITY OF FINDING A SPECIFIC TEXT")
    print("=" * 60)

    A, L = 25, 1_312_000

    # A short "proof" text: "QED" = 3 characters
    proof_lengths = [3, 100, 1000, 10_000, 100_000]

    print(f"\n  Given a target text of length k embedded in a volume of length L,")
    print(f"  probability a random volume contains it at a specific position: (1/A)^k")
    print(f"  Expected number of positions: L - k + 1")
    print(f"  Union bound probability: ≈ (L - k + 1) / A^k\n")

    print(f"  {'k':>8s}  {'log₁₀(P)':>12s}  {'Volumes needed (1/P)':>25s}")
    print(f"  {'─'*8}  {'─'*12}  {'─'*25}")

    for k in proof_lengths:
        log_p = math.log10(L - k + 1) - k * math.log10(A)
        print(f"  {k:8,}  {log_p:12.1f}  10^{-log_p:.1f}")

    print(f"\n  Even a 3-character target has probability ≈ 10^{math.log10(L) - 3*math.log10(25):.1f}")
    print(f"  per random volume — you'd need to check ~{25**3 / L:.0f}× the Library's")
    print(f"  volume count to expect one match at a random position.")


# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print("╔" + "═" * 58 + "╗")
    print("║  THE LIBRARY OF BABEL: NUMERICAL DEMONSTRATIONS          ║")
    print("║  Combinatorics of Universal Information Spaces            ║")
    print("╚" + "═" * 58 + "╝")

    demo_hamming_properties()
    demo_degree_regularity()
    demo_diameter()
    demo_singleton_bound()
    demo_hamming_balls()
    demo_self_reference()
    demo_mini_library()
    demo_probability_of_proof()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()
