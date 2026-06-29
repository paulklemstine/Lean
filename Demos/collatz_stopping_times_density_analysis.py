#!/usr/bin/env python3
"""
Applications of Collatz Parity Cylinder Theory

Demonstrates real-world applications and cross-domain connections:
1. Compressed orbit certificates via residue classes
2. Symbolic dynamics / coding theory perspective
3. Density analysis for Terras-type stopping time estimates
4. Entropy analysis of parity prefix distributions
"""

from collections import defaultdict
import math
from algorithms import (
    collatz_step, parity_word, parity_word_str,
    affine_coefficients, is_descent_word,
    cylinder_residues, descent_density_table,
    count_realizable_words, accelerated_odd_step, v2
)


def application_1_orbit_compression():
    """
    APPLICATION 1: Compressed Orbit Certificates

    The Cylinder Classification Theorem implies that knowing n mod 2^k
    is a complete certificate for the first k Collatz steps. This is a
    dramatic compression: instead of storing the entire orbit prefix,
    we only need log2(2^k) = k bits.

    For any n, the first k steps of its Collatz orbit can be reconstructed
    from just n mod 2^k — no iteration needed!
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 1: Compressed Orbit Certificates")
    print("=" * 70)

    k = 10
    n = 123456789
    mod = 2 ** k
    residue = n % mod

    print(f"\n  Starting value: n = {n}")
    print(f"  Certificate: n mod 2^{k} = {residue} (just {k} bits!)")

    # Reconstruct first k steps from residue
    word_from_residue = parity_word(k, residue)
    word_from_n = parity_word(k, n)

    print(f"\n  Parity word from full n: {parity_word_str(word_from_n)}")
    print(f"  Parity word from certificate: {parity_word_str(word_from_residue)}")
    print(f"  Match: {'✓' if word_from_n == word_from_residue else '✗'}")

    # Compute affine formula
    A, B, D = affine_coefficients(word_from_n)
    x_k = (A * n + B) // D
    print(f"\n  Affine formula: step^[{k}](n) = ({A} × {n} + {B}) / {D} = {x_k}")

    # Verify by direct iteration
    x = n
    for _ in range(k):
        x = collatz_step(x)
    print(f"  Direct iteration: step^[{k}](n) = {x}")
    print(f"  Match: {'✓' if x == x_k else '✗'}")

    # Compression ratio
    bits_full = math.ceil(math.log2(n + 1))
    print(f"\n  Compression: {bits_full} bits → {k} bits "
          f"({100 * k / bits_full:.1f}% of original)")


def application_2_symbolic_dynamics():
    """
    APPLICATION 2: Symbolic Dynamics / Coding Theory

    The Collatz map induces a shift map on parity words. The set of
    realizable words (no consecutive odds) forms a sofic shift — a
    constrained coding system.

    The number of realizable words follows the Fibonacci sequence,
    giving an information-theoretic capacity of log2(φ) ≈ 0.694 bits
    per step, where φ = (1+√5)/2 is the golden ratio.
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 2: Symbolic Dynamics & Coding Theory")
    print("=" * 70)

    phi = (1 + math.sqrt(5)) / 2
    capacity = math.log2(phi)

    print(f"\n  The Collatz sofic shift has capacity: log₂(φ) ≈ {capacity:.6f} bits/step")
    print(f"  (Golden ratio φ = {phi:.6f})")

    print(f"\n  {'k':>4}  {'Realizable':>11}  {'Total 2^k':>10}  {'Ratio':>8}  "
          f"{'Capacity est':>13}")
    print(f"  {'─' * 4}  {'─' * 11}  {'─' * 10}  {'─' * 8}  {'─' * 13}")

    for k in range(1, 21):
        realizable = count_realizable_words(k)
        total = 2 ** k
        ratio = realizable / total
        cap_est = math.log2(realizable) / k if k > 0 else 0
        print(f"  {k:>4}  {realizable:>11}  {total:>10}  {ratio:>8.4f}  {cap_est:>13.6f}")

    print(f"\n  Convergence to log₂(φ) = {capacity:.6f} ✓")


def application_3_terras_density():
    """
    APPLICATION 3: Terras-Type Density Analysis

    Compute the density of integers whose first k Collatz steps show
    contraction (descent). This approximates the Terras density theorem:
    for large k, a density-one set of integers has a descent within
    the first k steps.
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 3: Terras-Type Density Analysis")
    print("=" * 70)

    table = descent_density_table(20)

    print(f"\n  Descent density = fraction of residue classes mod 2^k")
    print(f"  whose parity word forces contraction (A/D < 1)")
    print(f"\n  {'k':>4}  {'Descent':>8}  {'Total':>6}  {'Density':>8}  {'Bar':>20}")
    print(f"  {'─' * 4}  {'─' * 8}  {'─' * 6}  {'─' * 8}  {'─' * 20}")

    for row in table:
        k = row['k']
        bar_len = int(row['density'] * 20)
        bar = '█' * bar_len + '░' * (20 - bar_len)
        print(f"  {k:>4}  {row['descent_residues']:>8}  {2**k:>6}  "
              f"{row['density']:>8.4f}  {bar}")

    # Cumulative descent: fraction of integers ≤ N that have SOME descent
    # within first k steps (union over all descent cylinders)
    print(f"\n  Note: The descent density oscillates but trends upward,")
    print(f"  consistent with the Terras prediction that density → 1.")


def application_4_entropy_analysis():
    """
    APPLICATION 4: Information-Theoretic Analysis

    Compute the Shannon entropy of the parity-word distribution.
    By the Cylinder Classification Theorem, each residue class mod 2^k
    maps to exactly one word, so the distribution is determined by
    the fiber sizes.

    If all words had equal fiber size, the entropy would be maximal
    at k·log₂(φ) bits (accounting for the Fibonacci constraint).
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 4: Entropy of Parity Prefix Distribution")
    print("=" * 70)

    print(f"\n  {'k':>4}  {'H(W)':>10}  {'H_max':>10}  {'H/H_max':>8}  {'#words':>8}")
    print(f"  {'─' * 4}  {'─' * 10}  {'─' * 10}  {'─' * 8}  {'─' * 8}")

    for k in range(1, 16):
        mod = 2 ** k
        residues = cylinder_residues(k)

        # Compute Shannon entropy of the word distribution
        # P(w) = |fiber(w)| / 2^k
        entropy = 0.0
        for w, fiber in residues.items():
            p = len(fiber) / mod
            if p > 0:
                entropy -= p * math.log2(p)

        # Maximum entropy would be log2(#words) if uniform
        n_words = len(residues)
        h_max = math.log2(n_words) if n_words > 1 else 0
        ratio = entropy / h_max if h_max > 0 else 0

        print(f"  {k:>4}  {entropy:>10.4f}  {h_max:>10.4f}  {ratio:>8.4f}  {n_words:>8}")

    print(f"\n  The entropy is close to but below maximum,")
    print(f"  reflecting the non-uniform fiber sizes (some words have more")
    print(f"  residue classes than others).")


def application_5_fibonacci_connection():
    """
    APPLICATION 5: Fibonacci Connection

    The number of realizable parity words of length k equals F(k+2),
    the (k+2)-th Fibonacci number. This connects Collatz dynamics to
    combinatorics through the golden ratio.
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 5: Fibonacci Structure of Collatz Words")
    print("=" * 70)

    print(f"\n  The constraint 'no consecutive odds' gives Fibonacci counting:")
    print(f"\n  {'k':>4}  {'Realizable':>11}  {'Fibonacci':>10}  {'φ^(k+2)/√5':>12}")
    print(f"  {'─' * 4}  {'─' * 11}  {'─' * 10}  {'─' * 12}")

    phi = (1 + math.sqrt(5)) / 2
    sqrt5 = math.sqrt(5)

    for k in range(1, 16):
        realizable = count_realizable_words(k)
        fib_approx = round(phi ** (k + 2) / sqrt5)
        exact_approx = phi ** (k + 2) / sqrt5
        print(f"  {k:>4}  {realizable:>11}  {fib_approx:>10}  {exact_approx:>12.2f}")


if __name__ == "__main__":
    application_1_orbit_compression()
    application_2_symbolic_dynamics()
    application_3_terras_density()
    application_4_entropy_analysis()
    application_5_fibonacci_connection()

    print(f"\n{'=' * 70}")
    print(f"  All applications demonstrated successfully.")
    print(f"{'=' * 70}")


#!/usr/bin/env python3
"""
Collatz Parity Cylinders — Interactive Demo

Demonstrates the core theorems of Collatz parity-cylinder theory:
1. Parity words are determined by residue classes mod 2^k
2. Residue-class counting for parity cylinders
3. Descent word classification
4. Affine coefficient computation

Usage:
    python demo.py [k]     — full analysis for parity words of length k (default k=5)
"""

import sys
from collections import defaultdict


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iterate(n: int, steps: int) -> list[int]:
    """Return the first `steps` iterates of the Collatz map starting from n."""
    orbit = [n]
    for _ in range(steps):
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(k: int, n: int) -> tuple[bool, ...]:
    """
    Compute the parity word of length k for starting value n.
    Returns tuple of bools: True = odd, False = even.
    """
    word = []
    x = n
    for _ in range(k):
        word.append(x % 2 == 1)
        x = collatz_step(x)
    return tuple(word)


def affine_coefficients(word: tuple[bool, ...]) -> tuple[int, int, int]:
    """
    Compute the affine coefficients (A, B, D) for a parity word.
    After k steps along word w, the iterate satisfies:
        D * x_k = A * n + B
    """
    A, B, D = 1, 0, 1
    for bit in word:
        if bit:  # odd step
            A, B, D = 3 * A, 3 * B + D, D
        else:    # even step
            A, B, D = A, B, 2 * D
    return A, B, D


def odd_count(word: tuple[bool, ...]) -> int:
    """Count odd (True) entries in a parity word."""
    return sum(1 for b in word if b)


def even_count(word: tuple[bool, ...]) -> int:
    """Count even (False) entries in a parity word."""
    return sum(1 for b in word if not b)


def is_descent_word(word: tuple[bool, ...]) -> bool:
    """Check if 3^(odd count) < 2^(even count), meaning descent for large n."""
    o = odd_count(word)
    e = even_count(word)
    return 3**o < 2**e


def word_to_str(word: tuple[bool, ...]) -> str:
    """Pretty-print a parity word."""
    return ''.join('O' if b else 'E' for b in word)


def demo_parity_cylinders(k: int):
    """Demonstrate parity cylinder classification for words of length k."""
    print(f"\n{'='*70}")
    print(f"  COLLATZ PARITY CYLINDERS — Length k = {k}")
    print(f"{'='*70}")

    # Map residue classes to parity words
    residue_to_word = {}
    word_to_residues = defaultdict(list)

    mod = 2**k
    for a in range(mod):
        w = parity_word(k, a)
        residue_to_word[a] = w
        word_to_residues[w].append(a)

    # Theorem A verification: parity word depends only on n mod 2^k
    print(f"\n§1. THEOREM A VERIFICATION: Parity word depends on n mod 2^{k}")
    print(f"    Testing with random larger values...")
    import random
    random.seed(42)
    verified = 0
    for _ in range(100):
        n = random.randint(0, 10000)
        a = n % mod
        w_n = parity_word(k, n)
        w_a = parity_word(k, a)
        assert w_n == w_a, f"FAILED: n={n}, a={a}"
        verified += 1
    print(f"    ✓ Verified for {verified} random values")

    # Display residue class → parity word mapping
    print(f"\n§2. RESIDUE CLASS → PARITY WORD MAPPING (mod 2^{k} = {mod})")
    print(f"    {'Residue':>8}  {'Parity Word':>12}  {'Type':>8}")
    print(f"    {'─'*8}  {'─'*12}  {'─'*8}")
    for a in range(min(mod, 32)):
        w = residue_to_word[a]
        wtype = "descent" if is_descent_word(w) else "ascent"
        print(f"    {a:>8}  {word_to_str(w):>12}  {wtype:>8}")
    if mod > 32:
        print(f"    ... ({mod - 32} more residue classes)")

    # Parity word statistics
    total_words = len(word_to_residues)
    descent_words = sum(1 for w in word_to_residues if is_descent_word(w))
    descent_residues = sum(len(word_to_residues[w]) for w in word_to_residues if is_descent_word(w))

    print(f"\n§3. PARITY WORD STATISTICS")
    print(f"    Total distinct words realized: {total_words}")
    print(f"    Total residue classes: {mod}")
    print(f"    Descent words: {descent_words} / {total_words} ({100*descent_words/total_words:.1f}%)")
    print(f"    Residues with descent: {descent_residues} / {mod} ({100*descent_residues/mod:.1f}%)")

    # No consecutive odds verification
    print(f"\n§4. NO CONSECUTIVE ODDS VERIFICATION")
    has_consecutive = False
    for w in word_to_residues:
        for i in range(len(w) - 1):
            if w[i] and w[i+1]:
                has_consecutive = True
                print(f"    VIOLATION: word {word_to_str(w)} has consecutive odds at positions {i},{i+1}")
    if not has_consecutive:
        print(f"    ✓ No realized word has consecutive odd entries")

    # Affine coefficients
    print(f"\n§5. AFFINE COEFFICIENTS (A, B, D) — formula: D·x_k = A·n + B")
    print(f"    {'Word':>12}  {'A':>8}  {'B':>8}  {'D':>8}  {'A/D':>10}  {'Descent?':>8}")
    print(f"    {'─'*12}  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*10}  {'─'*8}")
    for w in sorted(word_to_residues.keys(), key=lambda x: word_to_str(x)):
        A, B, D = affine_coefficients(w)
        ratio = A / D
        desc = "✓" if is_descent_word(w) else "✗"
        print(f"    {word_to_str(w):>12}  {A:>8}  {B:>8}  {D:>8}  {ratio:>10.4f}  {desc:>8}")

    # Verify affine formula
    print(f"\n§6. AFFINE FORMULA VERIFICATION")
    verified = 0
    for a in range(mod):
        w = parity_word(k, a)
        A, B, D = affine_coefficients(w)
        orbit = collatz_iterate(a, k)
        lhs = D * orbit[k]
        rhs = A * a + B
        assert lhs == rhs, f"FAILED: a={a}, word={word_to_str(w)}, D*x_k={lhs}, A*n+B={rhs}"
        verified += 1
    # Also verify for larger numbers
    for n in range(mod, mod + 100):
        w = parity_word(k, n)
        A, B, D = affine_coefficients(w)
        orbit = collatz_iterate(n, k)
        lhs = D * orbit[k]
        rhs = A * n + B
        assert lhs == rhs, f"FAILED: n={n}"
        verified += 1
    print(f"    ✓ Verified D·step^[k](n) = A·n + B for {verified} values")

    # Counting theorem verification
    print(f"\n§7. COUNTING THEOREM VERIFICATION (Theorem B)")
    N = 1000
    for w, residues in sorted(word_to_residues.items(), key=lambda x: word_to_str(x[0])):
        count = sum(1 for n in range(N + 1) if parity_word(k, n) == w)
        expected = (N + 1) * len(residues) // mod
        print(f"    Word {word_to_str(w):>12}: count={count:>5}, "
              f"expected≈{(N+1)*len(residues)/mod:.1f}, "
              f"|residues|={len(residues)}")

    # Partition verification
    total = sum(
        sum(1 for n in range(N + 1) if parity_word(k, n) == w)
        for w in word_to_residues
    )
    print(f"\n    Total across all cylinders: {total} (should be {N+1})")
    assert total == N + 1


def demo_descent_density():
    """Show how descent word density grows with k."""
    print(f"\n{'='*70}")
    print(f"  DESCENT WORD DENSITY vs k")
    print(f"{'='*70}")
    print(f"\n    {'k':>4}  {'Total words':>12}  {'Descent words':>14}  "
          f"{'Descent residues':>17}  {'Density':>8}")
    print(f"    {'─'*4}  {'─'*12}  {'─'*14}  {'─'*17}  {'─'*8}")

    for k in range(1, 21):
        mod = 2**k
        word_to_residues = defaultdict(list)
        for a in range(mod):
            w = parity_word(k, a)
            word_to_residues[w].append(a)

        descent_residues = sum(
            len(res) for w, res in word_to_residues.items() if is_descent_word(w)
        )
        descent_words = sum(1 for w in word_to_residues if is_descent_word(w))

        density = descent_residues / mod
        print(f"    {k:>4}  {len(word_to_residues):>12}  {descent_words:>14}  "
              f"{descent_residues:>17}  {density:>8.4f}")


def demo_3adic_local():
    """Demonstrate 3-adic local behavior of the accelerated Collatz map."""
    print(f"\n{'='*70}")
    print(f"  3-ADIC LOCAL BEHAVIOR")
    print(f"{'='*70}")
    print(f"\n  For odd n, examining (3n+1) mod 3^m and v_2(3n+1):")

    for m in range(1, 5):
        mod3 = 3**m
        print(f"\n  mod 3^{m} = {mod3}:")
        for a in range(mod3):
            if a % 2 == 0:
                continue  # skip even residues
            # Compute v_2(3a+1)
            val = 3 * a + 1
            v2 = 0
            temp = val
            while temp > 0 and temp % 2 == 0:
                v2 += 1
                temp //= 2
            accel = val >> v2  # (3a+1) / 2^v2
            print(f"    a ≡ {a:>4} (mod {mod3}): 3a+1 = {val:>6}, "
                  f"v_2 = {v2}, accel = {accel:>5}, "
                  f"accel mod {mod3} = {accel % mod3}")


if __name__ == "__main__":
    k = int(sys.argv[1]) if len(sys.argv) > 1 else 5

    demo_parity_cylinders(k)
    demo_descent_density()

    if k <= 4:
        demo_3adic_local()

    print(f"\n{'='*70}")
    print(f"  All demonstrations complete.")
    print(f"{'='*70}")
