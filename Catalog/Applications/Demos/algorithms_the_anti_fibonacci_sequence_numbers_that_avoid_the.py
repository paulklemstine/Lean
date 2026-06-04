#!/usr/bin/env python3
"""
Algorithms for Recurrence Avoidance Sequences

Type-hinted implementations of the core algorithms from the
Anti-Fibonacci research program.
"""
from typing import Optional


def anti_fib_closed(n: int) -> int:
    """O(1) closed-form computation of the n-th anti-Fibonacci term.
    
    Formula: A(n) = ⌊3n/2⌋ + 1
    
    This is the n-th positive integer not divisible by 3.
    
    Args:
        n: Non-negative index (0-based)
    Returns:
        The n-th anti-Fibonacci number
    """
    return n + n // 2 + 1


def anti_fib_even(k: int) -> int:
    """Anti-Fibonacci at even index: A(2k) = 3k + 1."""
    return 3 * k + 1


def anti_fib_odd(k: int) -> int:
    """Anti-Fibonacci at odd index: A(2k+1) = 3k + 2."""
    return 3 * k + 2


def consecutive_sum(n: int) -> int:
    """Compute the n-th consecutive sum: A(n) + A(n+1).
    
    The n-th consecutive sum equals 3(n+1), enumerating all positive
    multiples of 3 in order.
    """
    return anti_fib_closed(n) + anti_fib_closed(n + 1)


def greedy_avoidance_sequence(
    init: tuple[int, int],
    count: int,
    operation: str = "add"
) -> list[int]:
    """Compute a greedy recurrence avoidance sequence.
    
    Given initial pair and a binary operation, produces the lexicographically
    earliest strictly increasing sequence such that no term equals the
    operation applied to any previous consecutive pair.
    
    Args:
        init: Initial pair (a0, a1) with a0 < a1
        count: Number of terms to generate
        operation: One of "add", "mul", "max"
    Returns:
        The avoidance sequence
    """
    ops = {
        "add": lambda a, b: a + b,
        "mul": lambda a, b: a * b,
        "max": lambda a, b: max(a, b) + 1,
    }
    op = ops[operation]
    
    seq = list(init)
    forbidden: set[int] = {op(init[0], init[1])}
    
    for _ in range(count - 2):
        candidate = seq[-1] + 1
        while candidate in forbidden:
            candidate += 1
        forbidden.add(op(seq[-1], candidate))
        seq.append(candidate)
    
    return seq


def avoidance_density(seq: list[int], N: int) -> float:
    """Compute the density of a sequence among {1, ..., N}.
    
    Returns the fraction of integers in {1, ..., N} that appear in seq.
    """
    terms_below_N = sum(1 for x in seq if 1 <= x <= N)
    return terms_below_N / N if N > 0 else 0.0


def shadow_set(seq: list[int], operation: str = "add") -> set[int]:
    """Compute the shadow (set of consecutive-pair operation results).
    
    The shadow consists of all values op(seq[i], seq[i+1]) for consecutive pairs.
    """
    ops = {
        "add": lambda a, b: a + b,
        "mul": lambda a, b: a * b,
    }
    op = ops[operation]
    return {op(seq[i], seq[i+1]) for i in range(len(seq) - 1)}


def is_avoidance_partition(seq: list[int], N: int) -> bool:
    """Check if a sequence forms an avoidance partition of {1, ..., N}.
    
    An avoidance partition means:
    1. Terms and shadow are disjoint
    2. Terms ∪ shadow = {1, ..., N}
    """
    terms = set(seq)
    shad = shadow_set(seq)
    
    if not terms.isdisjoint(shad):
        return False
    
    covered = terms | shad
    universe = set(range(1, N + 1))
    return universe.issubset(covered)


def inverse_anti_fib(k: int) -> Optional[int]:
    """Given a positive integer k, return the index n such that A(n) = k,
    or None if k is divisible by 3 (not in the sequence).
    
    If k ≡ 1 (mod 3), then k = 3j + 1, return 2j.
    If k ≡ 2 (mod 3), then k = 3j + 2, return 2j + 1.
    If k ≡ 0 (mod 3), return None.
    """
    if k <= 0 or k % 3 == 0:
        return None
    r = k % 3
    j = (k - r) // 3
    if r == 1:
        return 2 * j
    else:  # r == 2
        return 2 * j + 1


def shadow_index(k: int) -> Optional[int]:
    """Given a positive multiple of 3, return the index n such that
    A(n) + A(n+1) = k, or None if k is not a positive multiple of 3.
    
    If k = 3m with m odd (m = 2j+1), return 2j.
    If k = 3m with m even (m = 2j+2), return 2j+1.
    """
    if k <= 0 or k % 3 != 0:
        return None
    m = k // 3
    if m % 2 == 1:  # odd
        j = (m - 1) // 2
        return 2 * j
    else:  # even
        j = m // 2 - 1
        return 2 * j + 1


if __name__ == "__main__":
    # Demonstrate algorithms
    print("Anti-Fibonacci closed form (first 20):")
    print([anti_fib_closed(n) for n in range(20)])
    
    print("\nGreedy avoidance (additive, start (1,2)):")
    print(greedy_avoidance_sequence((1, 2), 20))
    
    print("\nGreedy avoidance (multiplicative, start (2,3)):")
    print(greedy_avoidance_sequence((2, 3), 20, "mul"))
    
    print("\nConsecutive sums (first 15):")
    print([consecutive_sum(n) for n in range(15)])
    
    print("\nShadow set verification:")
    seq = [anti_fib_closed(n) for n in range(50)]
    shad = shadow_set(seq)
    terms = set(seq)
    print(f"  Terms ∩ Shadow = {terms & shad}")
    print(f"  All shadow values divisible by 3: {all(s % 3 == 0 for s in shad)}")
    
    print("\nInverse mapping test:")
    for k in range(1, 16):
        idx = inverse_anti_fib(k)
        sidx = shadow_index(k)
        print(f"  k={k:3d}: ", end="")
        if idx is not None:
            print(f"A({idx}) = {k}")
        elif sidx is not None:
            print(f"A({sidx}) + A({sidx+1}) = {k}  (shadow)")
        else:
            print("ERROR: not covered!")
