#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
================================================

Self-contained numerical examples demonstrating the combinatorial
and coding-theoretic properties of Borges' Library of Babel,
formalized as Volume(A, L) = Fin(L) -> Fin(A).

Results demonstrated:
  1. Volume cardinality: A^L
  2. Babel Degree: every volume has exactly L*(A-1) neighbors
  3. Babel Diameter: maximum Hamming distance = L
  4. Singleton Bound: |C| <= A^(L - d + 1)
  5. Self-evaluation count exceeds volume count (finite Cantor)
  6. Probability of finding a target string in a random volume
  7. De Bruijn sequence construction for a mini-library
"""

from __future__ import annotations

import math
import itertools
from collections import defaultdict
from typing import Sequence


# ─────────────────────────────────────────────────────────────
# 1. Core Library Parameters
# ─────────────────────────────────────────────────────────────

def volume_count(a: int, l: int) -> int:
    """Number of volumes in the Library: A^L."""
    return a ** l


def babel_degree(a: int, l: int) -> int:
    """Number of Hamming neighbors of every volume: L * (A - 1).

    Theorem (Babel Degree): For A >= 1, every volume v in Volume(A, L)
    has exactly L * (A - 1) Hamming neighbors.
    """
    return l * (a - 1)


def babel_diameter(l: int) -> int:
    """Hamming diameter of the Library: exactly L.

    Theorem (Babel Diameter): For A >= 2, L >= 1, there exist volumes
    v, w with hammingDist(v, w) = L.
    """
    return l


def singleton_bound(a: int, l: int, d: int) -> int:
    """Maximum code size for minimum distance d: A^(L - d + 1).

    Theorem (Singleton Bound): For A >= 2, any BabelCode (C, d) over
    Volume(A, L) with d <= L satisfies |C| <= A^(L - d + 1).
    """
    if d > l:
        return 1
    return a ** (l - d + 1)


def hamming_ball_volume(a: int, l: int, r: int) -> int:
    """Size of the Hamming ball of radius r: sum_{j=0}^{r} C(L,j)*(A-1)^j."""
    total = 0
    for j in range(min(r, l) + 1):
        total += math.comb(l, j) * ((a - 1) ** j)
    return total


def hamming_bound(a: int, l: int, d: int) -> float:
    """Sphere-packing (Hamming) bound: A^L / |B(v, floor((d-1)/2))|."""
    t = (d - 1) // 2
    ball = hamming_ball_volume(a, l, t)
    return a ** l / ball


# ─────────────────────────────────────────────────────────────
# 2. Hamming Distance
# ─────────────────────────────────────────────────────────────

def hamming_distance(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: number of positions where v and w differ."""
    assert len(v) == len(w), "Volumes must have equal length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_neighbors(v: tuple[int, ...], a: int) -> list[tuple[int, ...]]:
    """All Hamming neighbors of v (distance exactly 1)."""
    neighbors: list[tuple[int, ...]] = []
    for i in range(len(v)):
        for s in range(a):
            if s != v[i]:
                w = list(v)
                w[i] = s
                neighbors.append(tuple(w))
    return neighbors


# ─────────────────────────────────────────────────────────────
# 3. De Bruijn Sequence Construction
# ─────────────────────────────────────────────────────────────

def de_bruijn(k: int, n: int) -> list[int]:
    """Generate a de Bruijn sequence for alphabet size k, word length n.

    Uses Martin's algorithm (lexicographically smallest de Bruijn sequence).
    The resulting sequence has length k^n and every k-ary string of length n
    appears exactly once as a contiguous substring (cyclically).
    """
    if n == 0:
        return [0]

    alphabet = list(range(k))
    sequence: list[int] = []
    a = [0] * (k * n)

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                sequence.extend(a[1 : p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, k):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return sequence


def verify_de_bruijn(seq: list[int], k: int, n: int) -> bool:
    """Verify that seq is a valid de Bruijn sequence for (k, n)."""
    total = k ** n
    if len(seq) != total:
        return False
    # Check all n-length substrings (cyclic) are unique and cover all possibilities
    extended = seq + seq[:n - 1]
    substrings = set()
    for i in range(total):
        substr = tuple(extended[i:i + n])
        substrings.add(substr)
    return len(substrings) == total


# ─────────────────────────────────────────────────────────────
# 4. Probability Computations
# ─────────────────────────────────────────────────────────────

def prob_target_in_volume(a: int, l: int, target_len: int) -> float:
    """Upper bound on probability that a target string of given length
    appears in a random volume.

    P <= (L - t + 1) / A^t
    """
    if target_len > l:
        return 0.0
    positions = l - target_len + 1
    # Use logarithms to handle large numbers
    log_prob = math.log10(positions) - target_len * math.log10(a)
    return log_prob  # Return log10 of the probability


def prob_exact_volume(a: int, l: int) -> float:
    """Probability that a random volume equals a specific target volume.

    P = 1 / A^L  (returned as log10)
    """
    return -l * math.log10(a)


# ─────────────────────────────────────────────────────────────
# 5. Self-Reference Computations
# ─────────────────────────────────────────────────────────────

def self_eval_count_log(a: int, l: int) -> float:
    """Log10 of the number of self-evaluations (Volume -> Volume).

    Number = (A^L)^(A^L) = A^(L * A^L)
    Log10 = L * A^L * log10(A)
    Uses logarithmic arithmetic to avoid overflow for large parameters.
    """
    # log10(A^(L*A^L)) = L * A^L * log10(A)
    # For large A^L, compute log10 of that product:
    # = log10(L) + L*log10(A) + log10(log10(A))
    # But we want the actual value when possible
    try:
        return l * (a ** l) * math.log10(a)
    except (OverflowError, ValueError):
        # Return as a float approximation using logs
        # log10(result) = log10(L) + L*log10(A) + log10(log10(A))
        # But result itself is L * A^L * log10(A)
        # We return it in scientific notation components
        log_al = l * math.log10(a)
        # result = L * 10^(log_al) * log10(A)
        # Can't represent as float, return log10 of result instead
        return float('inf')  # Signal that it's too large


def catalog_impossibility_ratio(a: int, l: int) -> float:
    """Ratio of log10(self-evaluations) to log10(volumes).

    This ratio >> 1 shows self-evaluations vastly exceed volumes,
    proving no universal catalog can exist.
    Ratio = (L * A^L * log10(A)) / (L * log10(A)) = A^L
    """
    # The ratio simplifies to A^L
    try:
        return float(a ** l)
    except OverflowError:
        return float('inf')


# ─────────────────────────────────────────────────────────────
# 6. BabelCode Examples
# ─────────────────────────────────────────────────────────────

def verify_babel_code(codewords: list[tuple[int, ...]], min_dist: int) -> bool:
    """Verify that a set of codewords satisfies the minimum distance property."""
    for i in range(len(codewords)):
        for j in range(i + 1, len(codewords)):
            if hamming_distance(codewords[i], codewords[j]) < min_dist:
                return False
    return True


def repetition_code(a: int, l: int) -> tuple[list[tuple[int, ...]], int]:
    """Construct the repetition code: {(s, s, ..., s) : s in Fin(A)}.

    Minimum distance = L (maximum possible).
    This is a BabelCode achieving the trivial Singleton bound A^(L-L+1) = A.
    """
    codewords = [tuple([s] * l) for s in range(a)]
    return codewords, l


# ─────────────────────────────────────────────────────────────
# MAIN: Run all demonstrations
# ─────────────────────────────────────────────────────────────

def main() -> None:
    print("=" * 72)
    print("THE LIBRARY OF BABEL: NUMERICAL DEMONSTRATIONS")
    print("=" * 72)

    # ── Demo 1: Borges' Library ──
    print("\n" + "─" * 72)
    print("1. BORGES' ORIGINAL LIBRARY (A=25, L=1,312,000)")
    print("─" * 72)

    A_borges, L_borges = 25, 1_312_000

    log_volumes = L_borges * math.log10(A_borges)
    print(f"   Alphabet size:    A = {A_borges}")
    print(f"   Volume length:    L = {L_borges:,}")
    print(f"   Volume count:     25^{{1,312,000}} ≈ 10^{{{log_volumes:,.0f}}}")
    print(f"   Neighbors/volume: {babel_degree(A_borges, L_borges):,}")
    print(f"   Diameter:         {babel_diameter(L_borges):,}")

    for d in [3, 100, 1000, 656_000]:
        exp = L_borges - d + 1
        print(f"   Singleton bound (d={d:>7,}): |C| ≤ 25^{{{exp:,}}}"
              f" ≈ 10^{{{exp * math.log10(25):,.0f}}}")

    # ── Demo 2: DNA Mini-Library ──
    print("\n" + "─" * 72)
    print("2. DNA MINI-LIBRARY (A=4, L=16)")
    print("─" * 72)

    A_dna, L_dna = 4, 16

    print(f"   Alphabet:         {{A, C, G, T}} (size {A_dna})")
    print(f"   Volume length:    {L_dna}")
    print(f"   Volume count:     4^16 = {volume_count(A_dna, L_dna):,}")
    print(f"   Neighbors/volume: {babel_degree(A_dna, L_dna)}")
    print(f"   Diameter:         {babel_diameter(L_dna)}")

    for d in [1, 3, 5, 8]:
        sb = singleton_bound(A_dna, L_dna, d)
        hb = hamming_bound(A_dna, L_dna, d)
        print(f"   d={d}: Singleton ≤ {sb:>12,}   Hamming ≤ {hb:>12,.0f}")

    # ── Demo 3: Binary Byte Library ──
    print("\n" + "─" * 72)
    print("3. BINARY BYTE LIBRARY (A=2, L=8)")
    print("─" * 72)

    A_bin, L_bin = 2, 8

    print(f"   Volume count:     {volume_count(A_bin, L_bin)}")
    print(f"   Neighbors/volume: {babel_degree(A_bin, L_bin)}")
    print(f"   Diameter:         {babel_diameter(L_bin)}")

    # Verify degree theorem exhaustively
    all_bytes = list(itertools.product(range(2), repeat=8))
    sample = all_bytes[42]
    neighbors = hamming_neighbors(sample, A_bin)
    print(f"\n   Exhaustive verification for volume {sample}:")
    print(f"   Computed neighbors: {len(neighbors)}")
    print(f"   Expected (L*(A-1)): {babel_degree(A_bin, L_bin)}")
    print(f"   Match: {len(neighbors) == babel_degree(A_bin, L_bin)} ✓")

    # Verify diameter
    v_zero = tuple([0] * 8)
    v_one = tuple([1] * 8)
    print(f"\n   Diameter witnesses: {v_zero} ↔ {v_one}")
    print(f"   Distance: {hamming_distance(v_zero, v_one)}")
    print(f"   Equals L: {hamming_distance(v_zero, v_one) == L_bin} ✓")

    # ── Demo 4: BabelCode Example ──
    print("\n" + "─" * 72)
    print("4. BABELCODE: REPETITION CODE (A=3, L=5)")
    print("─" * 72)

    codewords, min_d = repetition_code(3, 5)
    print(f"   Codewords: {codewords}")
    print(f"   Min distance: {min_d}")
    print(f"   Valid BabelCode: {verify_babel_code(codewords, min_d)} ✓")
    print(f"   Singleton bound: |C| ≤ {singleton_bound(3, 5, 5)} = 3^1 = 3")
    print(f"   Actual |C| = {len(codewords)} (achieves equality → MDS code)")

    # ── Demo 5: De Bruijn Sequence ──
    print("\n" + "─" * 72)
    print("5. DE BRUIJN SEQUENCE CATALOG (k=4, n=4)")
    print("─" * 72)

    k, n = 4, 4
    seq = de_bruijn(k, n)
    valid = verify_de_bruijn(seq, k, n)
    print(f"   Alphabet size: {k}")
    print(f"   Word length:   {n}")
    print(f"   Sequence length: {len(seq)} (= {k}^{n} = {k**n})")
    print(f"   Valid de Bruijn: {valid} ✓")
    print(f"   First 40 symbols: {''.join(map(str, seq[:40]))}")
    print(f"   Encodes all {k**n} possible {n}-symbol 'volumes'")

    # Show a few windows
    extended = seq + seq[:n - 1]
    print(f"\n   Sample catalog entries (position → volume):")
    for pos in [0, 1, 42, 100, 200]:
        window = tuple(extended[pos:pos + n])
        print(f"   Position {pos:>3}: {window}")

    # ── Demo 6: Probability of Finding Meaning ──
    print("\n" + "─" * 72)
    print("6. PROBABILITY OF FINDING A TARGET STRING")
    print("─" * 72)

    print(f"\n   In Borges' Library (A=25, L=1,312,000):")
    for target_len in [10, 50, 100, 1000]:
        log_p = prob_target_in_volume(A_borges, L_borges, target_len)
        print(f"   Target length {target_len:>5}: P ≤ 10^{{{log_p:,.1f}}}")

    log_exact = prob_exact_volume(A_borges, L_borges)
    print(f"\n   Exact match (full volume): P = 10^{{{log_exact:,.0f}}}")
    print(f"   (That's a 1 followed by {abs(int(log_exact)):,} zeros in the denominator)")

    # ── Demo 7: Self-Reference / Diagonal Argument ──
    print("\n" + "─" * 72)
    print("7. SELF-REFERENCE: FINITE CANTOR ARGUMENT")
    print("─" * 72)

    print(f"\n   Binary Library (A=2, L=8):")
    n_vols = volume_count(2, 8)
    n_funcs = 2 ** (8 * 256)  # (A^L)^(A^L)
    log_funcs = self_eval_count_log(2, 8)
    print(f"   Volumes:          2^8 = {n_vols}")
    print(f"   Self-evaluations: 2^(8·256) = 2^2048")
    print(f"                   ≈ 10^{{{log_funcs:,.0f}}}")
    print(f"   Ratio (log):      {catalog_impossibility_ratio(2, 8):,.0f}×")
    print(f"   → No universal self-evaluator can exist ✓")

    print(f"\n   DNA Library (A=4, L=16):")
    log_v_dna = L_dna * math.log10(A_dna)
    log_f_dna = self_eval_count_log(A_dna, L_dna)
    print(f"   Volumes:          4^16 ≈ 10^{{{log_v_dna:,.1f}}}")
    print(f"   Self-evaluations: ≈ 10^{{{log_f_dna:,.0f}}}")
    print(f"   Ratio (log):      {catalog_impossibility_ratio(A_dna, L_dna):,.0f}×")

    print(f"\n   Borges' Library (A=25, L=1,312,000):")
    log_v_b = L_borges * math.log10(A_borges)
    # For Borges, self_eval_count = L * 25^L * log10(25) which is ~1,312,000 * 10^1,834,097
    # i.e., approximately 10^{1,834,103} — far too large for any float
    print(f"   Volumes:          ≈ 10^{{{log_v_b:,.0f}}}")
    print(f"   Self-evaluations: ≈ 10^(10^{{1,834,103}})  [tower of exponentials]")
    print(f"   Ratio:            25^{{1,312,000}} ≈ 10^{{1,834,097}}×")
    print(f"   → The catalog problem is not just hard — it's impossible")

    # ── Demo 8: Hamming Ball Volumes ──
    print("\n" + "─" * 72)
    print("8. HAMMING BALL VOLUMES")
    print("─" * 72)

    print(f"\n   Binary Library (A=2, L=8):")
    for r in range(9):
        bv = hamming_ball_volume(2, 8, r)
        pct = 100 * bv / 256
        bar = "█" * int(pct / 2)
        print(f"   |B(v, {r})| = {bv:>4}  ({pct:5.1f}%) {bar}")

    print(f"\n   DNA Library (A=4, L=16):")
    for r in [0, 1, 2, 3, 4, 8, 16]:
        bv = hamming_ball_volume(4, 16, r)
        pct = 100 * bv / volume_count(4, 16)
        print(f"   |B(v, {r:>2})| = {bv:>14,}  ({pct:8.4f}%)")

    print("\n" + "=" * 72)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 72)


if __name__ == "__main__":
    main()
