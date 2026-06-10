#!/usr/bin/env python3
"""
Collatz Parity Cylinder Algorithms

Implements the core algorithms from the formal theory:
1. Parity word computation
2. Affine coefficient recursion
3. Descent word classification
4. Cylinder density computation
5. Residue class enumeration

All algorithms have explicit complexity analysis and are verified
against the formal Lean proofs.
"""

from typing import Iterator
from collections import defaultdict
import math


# ============================================================================
# Algorithm 1: Collatz Step and Orbit Computation
# Time: O(1) per step, O(k) for k steps
# Space: O(1) per step, O(k) for orbit storage
# ============================================================================

def collatz_step(n: int) -> int:
    """Standard Collatz step: n → n/2 if even, n → 3n+1 if odd.

    >>> collatz_step(6)
    3
    >>> collatz_step(3)
    10
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, k: int) -> list[int]:
    """Compute first k+1 values of the Collatz orbit starting at n.

    Time: O(k), Space: O(k)

    >>> collatz_orbit(7, 5)
    [7, 22, 11, 34, 17, 52]
    """
    orbit = [n]
    for _ in range(k):
        n = collatz_step(n)
        orbit.append(n)
    return orbit


# ============================================================================
# Algorithm 2: Parity Word Computation
# Time: O(k) per word
# Space: O(k)
# ============================================================================

def parity_word(k: int, n: int) -> tuple[bool, ...]:
    """Compute the length-k parity word for starting value n.

    The parity word records whether each iterate is odd (True) or even (False).
    By the Cylinder Classification Theorem, this depends only on n mod 2^k.

    Time: O(k), Space: O(k)

    >>> parity_word(4, 7)
    (True, False, True, False)
    >>> parity_word(4, 15)  # 15 ≡ 7 (mod 16), but 15 mod 16 = 15
    (True, False, True, False)
    """
    word = []
    x = n
    for _ in range(k):
        word.append(x % 2 == 1)
        x = collatz_step(x)
    return tuple(word)


def parity_word_str(word: tuple[bool, ...]) -> str:
    """Pretty-print a parity word as a string of O/E characters."""
    return ''.join('O' if b else 'E' for b in word)


# ============================================================================
# Algorithm 3: Affine Coefficient Recursion
# Time: O(k) where k = len(word)
# Space: O(1) (in-place update)
# ============================================================================

def affine_coefficients(word: tuple[bool, ...]) -> tuple[int, int, int]:
    """Compute affine coefficients (A, B, D) for a parity word.

    The k-step Collatz iterate along word w satisfies:
        D * step^[k](n) = A * n + B

    where A = 3^(odd count), D = 2^(even count).

    Recursion:
        - Start: A=1, B=0, D=1
        - Odd step:  A → 3A, B → 3B + D, D → D
        - Even step: A → A,  B → B,      D → 2D

    Time: O(k), Space: O(1)

    >>> affine_coefficients((True, False, True, False))
    (9, 5, 4)
    >>> # Verify: D * step^4(7) = A * 7 + B → 4 * 17 = 9 * 7 + 5 = 68 ✓
    """
    A, B, D = 1, 0, 1
    for bit in word:
        if bit:  # odd step: x → 3x + 1
            A, B, D = 3 * A, 3 * B + D, D
        else:    # even step: x → x/2
            A, B, D = A, B, 2 * D
    return A, B, D


def is_descent_word(word: tuple[bool, ...]) -> bool:
    """Check whether a parity word forces descent for large n.

    A word w is a descent word if 3^(odd count) < 2^(even count),
    equivalently if A < D in the affine coefficients.

    >>> is_descent_word((False, False, False))  # All even: 1 < 8
    True
    >>> is_descent_word((True, False, True, False))  # 9 vs 4
    False
    """
    A, _, D = affine_coefficients(word)
    return A < D


# ============================================================================
# Algorithm 4: Residue Class Enumeration
# Time: O(2^k) total for all classes
# Space: O(2^k)
# ============================================================================

def cylinder_residues(k: int) -> dict[tuple[bool, ...], list[int]]:
    """Enumerate all residue classes mod 2^k grouped by parity word.

    Returns a dict mapping each realized parity word to the list of
    residue classes (mod 2^k) that produce it.

    Time: O(2^k), Space: O(2^k)

    >>> res = cylinder_residues(3)
    >>> sorted(res[(True, False, False)])
    [1, 5]
    """
    word_to_residues: dict[tuple[bool, ...], list[int]] = defaultdict(list)
    mod = 2 ** k
    for a in range(mod):
        w = parity_word(k, a)
        word_to_residues[w].append(a)
    return dict(word_to_residues)


# ============================================================================
# Algorithm 5: Descent Density Computation
# Time: O(2^k)
# Space: O(2^k)
# ============================================================================

def descent_density(k: int) -> float:
    """Compute the fraction of residue classes mod 2^k whose parity word
    is a descent word (i.e., forces contraction for large n).

    This is the finite-depth approximation to the Terras density.

    Time: O(2^k), Space: O(2^k)

    >>> descent_density(1)
    0.5
    """
    mod = 2 ** k
    descent_count = 0
    for a in range(mod):
        w = parity_word(k, a)
        if is_descent_word(w):
            descent_count += 1
    return descent_count / mod


def descent_density_table(max_k: int = 20) -> list[dict]:
    """Compute descent density for k = 1, ..., max_k.

    Returns list of dicts with keys: k, total_words, descent_words,
    descent_residues, density.

    >>> table = descent_density_table(5)
    >>> all(0 <= row['density'] <= 1 for row in table)
    True
    """
    results = []
    for k in range(1, max_k + 1):
        mod = 2 ** k
        word_to_residues = defaultdict(list)
        for a in range(mod):
            w = parity_word(k, a)
            word_to_residues[w].append(a)

        descent_residues = sum(
            len(res) for w, res in word_to_residues.items()
            if is_descent_word(w)
        )
        results.append({
            'k': k,
            'total_words': len(word_to_residues),
            'descent_words': sum(1 for w in word_to_residues if is_descent_word(w)),
            'descent_residues': descent_residues,
            'density': descent_residues / mod,
        })
    return results


# ============================================================================
# Algorithm 6: Fibonacci-counted Realizable Words
# Time: O(k)
# Space: O(1)
# ============================================================================

def count_realizable_words(k: int) -> int:
    """Count the number of distinct realizable parity words of length k.

    Since consecutive odd entries are forbidden, the number of realizable
    words follows the Fibonacci recurrence: F(k+2) where F(1)=1, F(2)=2.

    Time: O(k), Space: O(1)

    >>> [count_realizable_words(k) for k in range(1, 8)]
    [2, 3, 5, 8, 13, 21, 34]
    """
    if k == 0:
        return 1
    if k == 1:
        return 2
    a, b = 2, 3  # F(k=1), F(k=2)
    for _ in range(k - 2):
        a, b = b, a + b
    return b


# ============================================================================
# Algorithm 7: 3-adic Local Analysis
# Time: O(3^m) for enumeration
# Space: O(3^m)
# ============================================================================

def v2(n: int) -> int:
    """2-adic valuation of n (number of trailing zeros in binary).

    >>> v2(12)
    2
    >>> v2(7)
    0
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % 2 == 0:
        v += 1
        n //= 2
    return v


def accelerated_odd_step(n: int) -> int:
    """Accelerated odd Collatz step: (3n+1) / 2^v2(3n+1).

    Only defined for odd n.

    >>> accelerated_odd_step(7)
    11
    >>> accelerated_odd_step(3)
    5
    """
    assert n % 2 == 1, "Input must be odd"
    val = 3 * n + 1
    return val >> v2(val)


def local_3adic_analysis(m: int) -> dict:
    """Analyze the accelerated odd Collatz step modulo 3^m.

    For each odd residue class a mod 3^m, compute:
    - v2(3a+1): the 2-adic valuation
    - accelerated step mod 3^m

    Returns dict mapping residue class to analysis results.

    >>> analysis = local_3adic_analysis(1)
    >>> 1 in analysis  # a=1 is odd
    True
    """
    mod3 = 3 ** m
    results = {}
    for a in range(mod3):
        if a % 2 == 0:
            continue
        val = 3 * a + 1
        v = v2(val)
        accel = val >> v
        results[a] = {
            'residue': a,
            '3a+1': val,
            'v2': v,
            'accel': accel,
            'accel_mod_3m': accel % mod3,
        }
    return results


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)
