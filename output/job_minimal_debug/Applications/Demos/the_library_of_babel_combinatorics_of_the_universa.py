#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
================================================

Demonstrates the key combinatorial results about universal information spaces,
as formalized in the BabelCode framework.

Results demonstrated:
  1. Volume cardinality: |Volume(A, L)| = A^L
  2. Babel Degree: every volume has exactly L*(A-1) Hamming neighbors
  3. Babel Diameter: maximum Hamming distance is L
  4. Singleton Bound: |C| ≤ A^(L - d + 1)
  5. Hamming Ball volume and Hamming Bound
  6. Self-reference impossibility (finite Cantor argument)
  7. Mini-Library exploration (A=4, L=16)
"""

from __future__ import annotations

import math
import random
from itertools import product as cartesian_product
from typing import Sequence


# ─────────────────────────────────────────────────────────
#  Core Definitions
# ─────────────────────────────────────────────────────────

def hamming_dist(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: number of positions where v and w differ."""
    assert len(v) == len(w), "Volumes must have equal length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_ball_size(A: int, L: int, r: int) -> int:
    """Size of the Hamming ball of radius r in Volume(A, L).

    |B(v, r)| = sum_{j=0}^{r} C(L, j) * (A-1)^j
    """
    total = 0
    for j in range(r + 1):
        total += math.comb(L, j) * (A - 1) ** j
    return total


def singleton_bound(A: int, L: int, d: int) -> int:
    """Singleton bound: maximum codewords for min distance d."""
    return A ** (L - d + 1)


def hamming_bound(A: int, L: int, d: int) -> float:
    """Hamming (sphere-packing) bound for min distance d = 2t+1."""
    t = (d - 1) // 2
    ball = hamming_ball_size(A, L, t)
    return A ** L / ball


def babel_degree(A: int, L: int) -> int:
    """Number of Hamming neighbors (distance exactly 1) of any volume."""
    return L * (A - 1)


# ─────────────────────────────────────────────────────────
#  Demo 1: The Borges Library
# ─────────────────────────────────────────────────────────

def demo_borges_library() -> None:
    """Compute key statistics for Borges' Library of Babel."""
    A, L = 25, 1_312_000

    print("=" * 70)
    print("DEMO 1: THE BORGES LIBRARY (A=25, L=1,312,000)")
    print("=" * 70)

    # Volume cardinality
    log10_volumes = L * math.log10(A)
    num_digits = int(log10_volumes) + 1
    print(f"\nTotal volumes: 25^1,312,000")
    print(f"  ≈ 10^{log10_volumes:.1f}")
    print(f"  Number of decimal digits: {num_digits:,}")
    print(f"  (Compare: atoms in observable universe ≈ 10^80)")

    # Babel Degree
    degree = babel_degree(A, L)
    print(f"\nNeighbors per volume (Babel Degree): {degree:,}")
    print(f"  = L × (A-1) = {L:,} × {A-1} = {degree:,}")

    # Diameter
    print(f"\nLibrary diameter: {L:,}")

    # Singleton bounds for various distances
    print("\nSingleton Bounds:")
    for d in [10, 100, 1000, 10000]:
        exponent = L - d + 1
        print(f"  d = {d:>6,}: |C| ≤ 25^{exponent:,} ≈ 10^{exponent * math.log10(25):.0f}")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 2: Mini-Library Exploration
# ─────────────────────────────────────────────────────────

def demo_mini_library() -> None:
    """Explore a small library with A=4, L=4 (256 volumes)."""
    A, L = 4, 4

    print("=" * 70)
    print(f"DEMO 2: MINI-LIBRARY (A={A}, L={L})")
    print("=" * 70)

    # Generate all volumes
    all_volumes = list(cartesian_product(range(A), repeat=L))
    print(f"\nTotal volumes: {A}^{L} = {A**L}")
    assert len(all_volumes) == A ** L

    # Verify Babel Degree for a sample volume
    v0 = (0, 0, 0, 0)
    neighbors = [w for w in all_volumes if hamming_dist(v0, w) == 1]
    expected_degree = babel_degree(A, L)
    print(f"\nBabel Degree verification for v = {v0}:")
    print(f"  Computed neighbors: {len(neighbors)}")
    print(f"  Expected L*(A-1) = {L}*{A-1} = {expected_degree}")
    assert len(neighbors) == expected_degree

    # Verify diameter
    max_dist = 0
    argmax_pair = (None, None)
    # Sample random pairs for efficiency
    random.seed(42)
    for _ in range(10000):
        i, j = random.randint(0, len(all_volumes) - 1), random.randint(0, len(all_volumes) - 1)
        d = hamming_dist(all_volumes[i], all_volumes[j])
        if d > max_dist:
            max_dist = d
            argmax_pair = (all_volumes[i], all_volumes[j])

    # Also check the known maximum
    v_zero = (0, 0, 0, 0)
    v_one = (1, 1, 1, 1)
    d_max_known = hamming_dist(v_zero, v_one)
    print(f"\nDiameter verification:")
    print(f"  d_H({v_zero}, {v_one}) = {d_max_known}")
    print(f"  Maximum found by sampling: {max_dist} at {argmax_pair}")
    print(f"  Expected diameter: {L}")

    # Hamming ball sizes
    print(f"\nHamming ball sizes centered at {v0}:")
    for r in range(L + 1):
        ball = [w for w in all_volumes if hamming_dist(v0, w) <= r]
        formula = hamming_ball_size(A, L, r)
        print(f"  |B(v, {r})| = {len(ball):>5}  (formula: {formula})")
        assert len(ball) == formula

    # Singleton bound
    print(f"\nSingleton Bound values:")
    for d in range(1, L + 1):
        sb = singleton_bound(A, L, d)
        print(f"  d = {d}: |C| ≤ {sb}")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 3: BabelCode Construction
# ─────────────────────────────────────────────────────────

def demo_babel_code() -> None:
    """Construct and verify a BabelCode in a mini-library."""
    A, L = 4, 4

    print("=" * 70)
    print(f"DEMO 3: BABELCODE CONSTRUCTION (A={A}, L={L})")
    print("=" * 70)

    # Construct a repetition code: each codeword repeats a single symbol
    # min distance = L (maximum possible)
    repetition_code = [tuple([s] * L) for s in range(A)]
    min_dist = min(
        hamming_dist(v, w)
        for v in repetition_code
        for w in repetition_code
        if v != w
    )

    print(f"\nRepetition code (all-same-symbol volumes):")
    for cw in repetition_code:
        print(f"  {cw}")
    print(f"  |C| = {len(repetition_code)}")
    print(f"  Minimum distance = {min_dist}")
    print(f"  Singleton bound for d={min_dist}: {singleton_bound(A, L, min_dist)}")
    print(f"  Code achieves Singleton bound: {len(repetition_code) <= singleton_bound(A, L, min_dist)}")

    # Construct a parity-check code: last symbol = sum of first L-1 symbols mod A
    print(f"\nParity-check code (last symbol = sum of others mod {A}):")
    parity_code = []
    for prefix in cartesian_product(range(A), repeat=L - 1):
        check = sum(prefix) % A
        parity_code.append(prefix + (check,))

    min_dist_parity = min(
        hamming_dist(v, w)
        for i, v in enumerate(parity_code)
        for w in parity_code[i + 1:]
    )

    print(f"  |C| = {len(parity_code)}")
    print(f"  Minimum distance = {min_dist_parity}")
    print(f"  Singleton bound for d={min_dist_parity}: {singleton_bound(A, L, min_dist_parity)}")
    print(f"  Satisfies Singleton bound: {len(parity_code) <= singleton_bound(A, L, min_dist_parity)}")

    # Verify degree regularity is independent of the codeword
    all_volumes = list(cartesian_product(range(A), repeat=L))
    print(f"\nDegree regularity check (sampling 10 random volumes):")
    random.seed(123)
    expected = babel_degree(A, L)
    for _ in range(10):
        v = random.choice(all_volumes)
        deg = sum(1 for w in all_volumes if hamming_dist(v, w) == 1)
        status = "✓" if deg == expected else "✗"
        print(f"  {v}: degree = {deg} {status}")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 4: Self-Reference Impossibility
# ─────────────────────────────────────────────────────────

def demo_self_reference() -> None:
    """Demonstrate the diagonal argument for self-reference impossibility."""
    A, L = 2, 3  # Very small for enumeration

    print("=" * 70)
    print(f"DEMO 4: SELF-REFERENCE IMPOSSIBILITY (A={A}, L={L})")
    print("=" * 70)

    num_volumes = A ** L
    num_self_evals = A ** num_volumes

    print(f"\nVolume(A={A}, L={L}):")
    print(f"  Number of volumes:         {num_volumes}")
    print(f"  Number of self-evaluations: A^(A^L) = {A}^{num_volumes} = {num_self_evals}")
    print(f"  Self-evals > volumes: {num_self_evals} > {num_volumes} = {num_self_evals > num_volumes}")

    # Enumerate all volumes
    all_volumes = list(cartesian_product(range(A), repeat=L))
    print(f"\nAll volumes:")
    for i, v in enumerate(all_volumes):
        print(f"  v_{i} = {v}")

    # Demonstrate diagonal argument
    # Suppose we have an "encoding" that maps each volume to a function Volume → Fin(A)
    # by interpreting the volume's L bits as defining a function on L "positions"
    # Since num_self_evals > num_volumes, encoding cannot be surjective.

    # Simple encoding: interpret volume v as the function f(w) = v[index(w) mod L]
    def encode(v: tuple[int, ...]) -> dict[tuple[int, ...], int]:
        """A simple encoding: volume v defines f(w) = v[index(w) mod L]."""
        result = {}
        for j, w in enumerate(all_volumes):
            result[w] = v[j % L]
        return result

    print(f"\nEncoding (v ↦ f_v where f_v(w) = v[index(w) mod L]):")
    for i, v in enumerate(all_volumes):
        f_v = encode(v)
        outputs = [f_v[w] for w in all_volumes]
        print(f"  v_{i} = {v} → f_v = {outputs}")

    # Diagonal construction: d(v_i) = 1 - f_{v_i}(v_i)
    print(f"\nDiagonal function (d(v_i) = 1 - f_{{v_i}}(v_i)):")
    diag = []
    for i, v in enumerate(all_volumes):
        f_v = encode(v)
        val = (1 - f_v[v]) % A
        diag.append(val)
        print(f"  d(v_{i}) = 1 - f_{{v_{i}}}(v_{i}) = 1 - {f_v[v]} = {val} (mod {A})")

    print(f"\nDiagonal function output: {diag}")

    # Check that diagonal differs from every encoded function
    print(f"\nVerification (diagonal ≠ any encoded function):")
    for i, v in enumerate(all_volumes):
        f_v = encode(v)
        outputs = [f_v[w] for w in all_volumes]
        differs_at = [j for j in range(num_volumes) if diag[j] != outputs[j]]
        print(f"  d ≠ f_{{v_{i}}} (differs at positions {differs_at})")

    print(f"\n→ No volume encodes the diagonal function.")
    print(f"→ The catalog paradox: no single volume can faithfully represent all evaluations.")

    # Borges-scale numbers
    print(f"\nFor Borges' Library (A=25, L=1,312,000):")
    log_volumes = 1_312_000 * math.log10(25)
    log_self_evals = 25**1 * log_volumes  # Actually A^(A^L), which is astronomically larger
    print(f"  log₁₀(volumes) = {log_volumes:.0f}")
    print(f"  log₁₀(self-evaluations) = 25^1,312,000 × {log_volumes:.0f}")
    print(f"  The ratio is itself a number with ~10^1,834,097 digits.")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 5: Hamming Bound Comparison
# ─────────────────────────────────────────────────────────

def demo_bounds_comparison() -> None:
    """Compare Singleton and Hamming bounds for various parameters."""
    print("=" * 70)
    print("DEMO 5: SINGLETON vs HAMMING BOUND COMPARISON")
    print("=" * 70)

    configs: list[tuple[int, int]] = [(2, 8), (3, 9), (4, 16), (5, 10)]

    for A, L in configs:
        print(f"\n--- Volume({A}, {L}) | Library size = {A}^{L} = {A**L:,} ---")
        print(f"{'d':>4} | {'Singleton':>12} | {'Hamming':>12} | {'Tighter':>10}")
        print("-" * 50)
        for d in range(1, L + 1, max(1, L // 8)):
            sb = singleton_bound(A, L, d)
            hb = hamming_bound(A, L, d)
            tighter = "Hamming" if hb < sb else "Singleton" if sb < hb else "Equal"
            print(f"{d:>4} | {sb:>12,} | {hb:>12,.1f} | {tighter:>10}")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 6: De Bruijn Mini-Catalog
# ─────────────────────────────────────────────────────────

def demo_debruijn_catalog() -> None:
    """Construct a de Bruijn sequence for a mini-library."""
    A, L = 2, 4  # Binary alphabet, length 4

    print("=" * 70)
    print(f"DEMO 6: DE BRUIJN CATALOG (A={A}, L={L})")
    print("=" * 70)

    # de Bruijn sequence of order L over alphabet {0,...,A-1}
    # Contains every L-length substring exactly once
    def de_bruijn(k: int, n: int) -> list[int]:
        """Generate de Bruijn sequence B(k, n)."""
        alphabet = list(range(k))
        a: list[int] = [0] * (k * n)
        sequence: list[int] = []

        def db(t: int, p: int) -> None:
            if t > n:
                if n % p == 0:
                    sequence.extend(a[1:p + 1])
            else:
                a[t] = a[t - p]
                db(t + 1, p)
                for j in range(a[t - p] + 1, k):
                    a[t] = j
                    db(t + 1, t)

        db(1, 1)
        return sequence

    seq = de_bruijn(A, L)
    print(f"\nde Bruijn sequence B({A},{L}):")
    print(f"  Length: {len(seq)} (= {A}^{L} = {A**L})")
    print(f"  Sequence: {''.join(map(str, seq))}")

    # Verify all L-substrings appear
    extended = seq + seq[:L - 1]  # wrap around
    substrings = set()
    for i in range(len(seq)):
        sub = tuple(extended[i:i + L])
        substrings.add(sub)

    print(f"\nAll {L}-substrings (should be {A**L}):")
    for sub in sorted(substrings):
        print(f"  {''.join(map(str, sub))}")
    print(f"  Total unique: {len(substrings)}")
    assert len(substrings) == A ** L, f"Expected {A**L}, got {len(substrings)}"
    print(f"  ✓ All {A**L} volumes of Volume({A},{L}) appear as substrings.")

    # This is the "catalog": a single sequence that encodes every possible volume
    print(f"\nThe de Bruijn sequence serves as a compressed catalog:")
    print(f"  Library has {A**L} volumes of length {L}")
    print(f"  Naive catalog would need {A**L * L} = {A**L * L} symbols")
    print(f"  de Bruijn catalog needs only {A**L} = {len(seq)} symbols")
    print(f"  Compression ratio: {L}:1")

    print()


# ─────────────────────────────────────────────────────────
#  Demo 7: Probability of Finding a Proof
# ─────────────────────────────────────────────────────────

def demo_proof_probability() -> None:
    """Estimate the probability of finding a valid proof in a random volume."""
    A, L = 25, 1_312_000

    print("=" * 70)
    print("DEMO 7: PROBABILITY OF A MEANINGFUL PROOF IN A RANDOM VOLUME")
    print("=" * 70)

    # A proof of length k has probability 1/A^k of appearing at any given
    # position, and there are L - k + 1 possible starting positions.
    # By union bound, P(proof appears) ≤ (L - k + 1) / A^k ≈ L / A^k

    print(f"\nLibrary: A={A}, L={L:,}")
    print(f"\nFor a proof string of length k characters:")
    print(f"{'k':>10} | {'P(appears in random volume)':>35} | {'log₁₀(P)':>12}")
    print("-" * 65)

    for k in [10, 50, 100, 500, 1000, 10000, 100000]:
        # P ≈ L / A^k (union bound over starting positions)
        log10_p = math.log10(L) - k * math.log10(A)
        if log10_p > 0:
            p_str = f"≈ 1 (certain)"
        else:
            p_str = f"≈ 10^{log10_p:.1f}"
        print(f"{k:>10,} | {p_str:>35} | {log10_p:>12.1f}")

    print(f"\nInterpretation:")
    print(f"  A 10-character string appears in ~{L}/25^10 ≈ 10^{math.log10(L) - 10*math.log10(25):.1f} fraction of volumes")
    print(f"  A 100-character proof: probability ≈ 10^{math.log10(L) - 100*math.log10(25):.0f}")
    print(f"  Even a 50-character proof is overwhelmingly unlikely in any random volume")
    print(f"\n  The Library CONTAINS every proof, but finding one by random sampling")
    print(f"  is hopeless — you need the mathematics of BabelCodes to navigate.")

    print()


# ─────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   THE LIBRARY OF BABEL: COMBINATORICS OF UNIVERSAL INFORMATION     ║")
    print("║                    Numerical Demonstrations                        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_borges_library()
    demo_mini_library()
    demo_babel_code()
    demo_self_reference()
    demo_bounds_comparison()
    demo_debruijn_catalog()
    demo_proof_probability()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
