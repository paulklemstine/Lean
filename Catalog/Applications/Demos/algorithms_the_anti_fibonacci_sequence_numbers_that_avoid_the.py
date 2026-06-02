#!/usr/bin/env python3
"""
Anti-Fibonacci Sequence: Algorithms and Data Structures

Type-hinted implementations of the core algorithms for computing and
analyzing the anti-Fibonacci sequence and related concepts.
"""

from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ---------------------------------------------------------------------------
# Core sequence computation
# ---------------------------------------------------------------------------

def anti_fib_closed(n: int) -> int:
    """
    Compute the n-th anti-Fibonacci number using the closed form.

    Formula: a(n) = n*(n-1)/2 + 1

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        n: Non-negative integer index.

    Returns:
        The n-th anti-Fibonacci number.
    """
    if n < 0:
        raise ValueError(f"Index must be non-negative, got {n}")
    return n * (n - 1) // 2 + 1


def anti_fib_recurrence(n: int) -> int:
    """
    Compute the n-th anti-Fibonacci number using the recurrence relation.

    Recurrence: a(0) = a(1) = 1, a(k+2) = a(k+1) + (k+1)

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        n: Non-negative integer index.

    Returns:
        The n-th anti-Fibonacci number.
    """
    if n < 0:
        raise ValueError(f"Index must be non-negative, got {n}")
    if n <= 1:
        return 1
    prev, curr = 1, 1
    for k in range(n - 1):
        prev, curr = curr, curr + (k + 1)
    return curr


def anti_fib_sequence(n: int) -> List[int]:
    """
    Compute the first n+1 anti-Fibonacci numbers [a(0), a(1), ..., a(n)].

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        n: Non-negative integer, compute terms up to index n.

    Returns:
        List of anti-Fibonacci numbers from a(0) to a(n).
    """
    if n < 0:
        raise ValueError(f"Index must be non-negative, got {n}")
    if n == 0:
        return [1]
    seq = [1, 1]
    for k in range(2, n + 1):
        seq.append(seq[-1] + (k - 1))
    return seq


# ---------------------------------------------------------------------------
# Fibonacci defect computation
# ---------------------------------------------------------------------------

@dataclass
class DefectInfo:
    """Information about the Fibonacci defect at a position."""
    position: int
    defect: int
    is_avoidant: bool
    is_coincidence: bool


def fibonacci_defect(a: Callable[[int], int], n: int) -> int:
    """
    Compute the Fibonacci defect of sequence a at position n.

    The defect measures how far a deviates from the Fibonacci recurrence:
    d(n) = a(n+2) - a(n+1) - a(n)

    Positive defect: sequence grows faster than Fibonacci would predict.
    Zero defect: sequence satisfies the Fibonacci recurrence at this position.
    Negative defect: sequence grows slower than Fibonacci would predict.

    Args:
        a: A callable representing the sequence.
        n: Position at which to compute the defect.

    Returns:
        The Fibonacci defect value.
    """
    return a(n + 2) - a(n + 1) - a(n)


def anti_fib_defect_formula(n: int) -> float:
    """
    Compute the Fibonacci defect of antiFib at position n using the
    exact formula: d(n) = n*(3-n)/2.

    Args:
        n: Non-negative integer position.

    Returns:
        The exact Fibonacci defect value.
    """
    return n * (3 - n) / 2


def analyze_defect_profile(
    a: Callable[[int], int],
    max_n: int
) -> List[DefectInfo]:
    """
    Compute the full Fibonacci defect profile of a sequence.

    Args:
        a: A callable representing the sequence.
        max_n: Maximum position to analyze.

    Returns:
        List of DefectInfo objects for positions 0 to max_n.
    """
    results = []
    for n in range(max_n + 1):
        d = fibonacci_defect(a, n)
        results.append(DefectInfo(
            position=n,
            defect=d,
            is_avoidant=(d != 0),
            is_coincidence=(d == 0),
        ))
    return results


# ---------------------------------------------------------------------------
# Fibonacci avoidance checking
# ---------------------------------------------------------------------------

def find_coincidences(
    a: Callable[[int], int],
    max_n: int
) -> List[int]:
    """
    Find all positions where sequence a satisfies the Fibonacci recurrence.

    Args:
        a: A callable representing the sequence.
        max_n: Maximum position to check.

    Returns:
        List of positions where a(n+2) = a(n+1) + a(n).
    """
    return [n for n in range(max_n + 1)
            if a(n + 2) == a(n + 1) + a(n)]


def is_eventually_avoidant(
    a: Callable[[int], int],
    start: int,
    check_length: int = 1000
) -> Tuple[bool, Optional[int]]:
    """
    Check if sequence a is Fibonacci-avoidant from position 'start' onward.

    Tests positions start through start + check_length.

    Args:
        a: A callable representing the sequence.
        start: Position from which to start checking.
        check_length: Number of positions to verify.

    Returns:
        (True, None) if avoidant at all checked positions,
        (False, n) if a coincidence is found at position n.
    """
    for n in range(start, start + check_length):
        if a(n + 2) == a(n + 1) + a(n):
            return (False, n)
    return (True, None)


# ---------------------------------------------------------------------------
# Greedy Fibonacci-avoidant sequence
# ---------------------------------------------------------------------------

def greedy_fib_avoidant(n: int) -> List[int]:
    """
    Compute the greedy Fibonacci-avoidant increasing sequence.

    Starting from 1, 1, each subsequent term is the smallest positive integer
    greater than the previous term that does NOT equal the sum of the two
    preceding terms.

    The sequence is: 1, 1, 3, 5, 6, 7, 8, 9, 10, 11, ...

    Args:
        n: Number of terms to compute.

    Returns:
        List of the first n terms of the greedy avoidant sequence.
    """
    if n <= 0:
        return []
    if n == 1:
        return [1]
    seq = [1, 1]
    for _ in range(n - 2):
        forbidden = seq[-1] + seq[-2]
        candidate = seq[-1] + 1
        if candidate == forbidden:
            candidate += 1
        seq.append(candidate)
    return seq


# ---------------------------------------------------------------------------
# Growth rate analysis
# ---------------------------------------------------------------------------

def growth_ratio_analysis(max_n: int = 100) -> List[Tuple[int, float, float]]:
    """
    Compare the consecutive ratio a(n+1)/a(n) for antiFib vs Fibonacci.

    Args:
        max_n: Maximum index to analyze.

    Returns:
        List of (n, antiFib_ratio, fib_ratio) tuples.
    """
    # Compute Fibonacci sequence
    fib = [0, 1]
    for _ in range(max_n):
        fib.append(fib[-1] + fib[-2])

    results = []
    for n in range(1, max_n + 1):
        af_n = anti_fib_closed(n)
        af_n1 = anti_fib_closed(n + 1)
        af_ratio = af_n1 / af_n if af_n > 0 else float('inf')

        f_n = fib[n]
        f_n1 = fib[n + 1]
        f_ratio = f_n1 / f_n if f_n > 0 else float('inf')

        results.append((n, af_ratio, f_ratio))

    return results


# ---------------------------------------------------------------------------
# Inverse anti-Fibonacci
# ---------------------------------------------------------------------------

def anti_fib_inverse(value: int) -> Optional[int]:
    """
    Find the index n such that antiFib(n) = value, or None if no such n exists.

    Uses the closed form: value = n*(n-1)/2 + 1, so n*(n-1) = 2*(value - 1).

    Args:
        value: The value to search for.

    Returns:
        The index n if value is an anti-Fibonacci number, else None.
    """
    if value < 1:
        return None
    # Solve n*(n-1) = 2*(value - 1)
    target = 2 * (value - 1)
    # n ≈ (1 + sqrt(1 + 4*target)) / 2
    import math
    n_approx = (1 + math.sqrt(1 + 4 * target)) / 2
    for n in [int(n_approx) - 1, int(n_approx), int(n_approx) + 1]:
        if n >= 0 and n * (n - 1) == target:
            return n
    return None


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Verify closed form matches recurrence
    N = 1000
    seq = anti_fib_sequence(N)
    assert all(seq[i] == anti_fib_closed(i) for i in range(N + 1)), \
        "Closed form mismatch!"
    print(f"✓ Closed form verified for n = 0..{N}")

    # Find coincidences
    coinc = find_coincidences(anti_fib_closed, 10000)
    print(f"✓ Fibonacci recurrence coincidences in [0, 10000]: {coinc}")
    assert coinc == [0, 3], f"Expected [0, 3], got {coinc}"

    # Check eventual avoidance
    avoidant, fail = is_eventually_avoidant(anti_fib_closed, 4, 100000)
    print(f"✓ Eventually avoidant from n=4: {avoidant} (failure: {fail})")

    # Greedy avoidant sequence
    greedy = greedy_fib_avoidant(20)
    print(f"✓ Greedy avoidant: {greedy}")

    # Inverse
    for v in [1, 2, 4, 7, 11, 16, 22, 5, 10]:
        idx = anti_fib_inverse(v)
        print(f"  antiFib⁻¹({v}) = {idx}")

    print("\nAll algorithm tests passed!")
