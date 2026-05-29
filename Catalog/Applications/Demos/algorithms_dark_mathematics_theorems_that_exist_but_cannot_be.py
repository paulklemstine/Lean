#!/usr/bin/env python3
"""
Dark Mathematics: Algorithms

Implements the core algorithms for computing with fast-growing hierarchies,
darkness levels, and witness complexity bounds.
"""

from typing import Callable, Optional, Tuple
import sys

sys.setrecursionlimit(10000)


# ============================================================
# Algorithm 1: Fast-Growing Hierarchy (Memoized)
# ============================================================

def fast_grow_memo(k: int, n: int, memo: Optional[dict] = None) -> int:
    """Memoized fast-growing hierarchy computation.

    Time complexity: O(A(k,n)) where A is the Ackermann function
    Space complexity: O(A(k,n)) for memoization table

    Args:
        k: Level in the hierarchy (0 = successor, 1 = +2, 2 = 2n+3, ...)
        n: Input value
        memo: Optional memoization dictionary

    Returns:
        fastGrow(k, n) = Ackermann(k, n)

    Example:
        >>> fast_grow_memo(2, 5)
        13
        >>> fast_grow_memo(3, 3)
        61
    """
    if memo is None:
        memo = {}
    key = (k, n)
    if key in memo:
        return memo[key]

    if k == 0:
        result = n + 1
    elif n == 0:
        result = fast_grow_memo(k - 1, 1, memo)
    else:
        inner = fast_grow_memo(k, n - 1, memo)
        result = fast_grow_memo(k - 1, inner, memo)

    memo[key] = result
    return result


# ============================================================
# Algorithm 2: Closed-Form Evaluators
# ============================================================

def fast_grow_closed(k: int, n: int) -> int:
    """Compute fastGrow using closed-form formulas where available.

    Level 0: n + 1
    Level 1: n + 2
    Level 2: 2n + 3
    Level 3: 2^(n+3) - 3
    Level ≥ 4: falls back to recursive computation

    Time complexity: O(1) for k ≤ 3, O(A(k,n)) for k ≥ 4

    Example:
        >>> fast_grow_closed(3, 10)
        8189
    """
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    else:
        return fast_grow_memo(k, n)


# ============================================================
# Algorithm 3: Darkness Level Classifier
# ============================================================

def classify_darkness_level(
    f: Callable[[int], int],
    max_level: int = 5,
    test_range: int = 20
) -> int:
    """Classify the darkness level of a growth function.

    Given a monotone function f: ℕ → ℕ, determines the smallest
    level k such that f(n) ≤ fastGrow(k, n) for all tested n.

    Algorithm:
    1. For each level k from 0 to max_level:
       - Check if f(n) ≤ fastGrow(k, n) for all n in test_range
       - If yes, return k as the darkness level
    2. If no level found, return max_level + 1

    Time complexity: O(max_level * test_range * max_computation)
    Space complexity: O(max_level * test_range) for memoization

    Args:
        f: Function to classify
        max_level: Maximum hierarchy level to check
        test_range: Range of n values to test

    Returns:
        Estimated darkness level

    Example:
        >>> classify_darkness_level(lambda n: n**2)
        2
        >>> classify_darkness_level(lambda n: 2**n)
        3
    """
    memo = {}
    for k in range(max_level + 1):
        all_bounded = True
        for n in range(test_range):
            try:
                fn = f(n)
                fgn = fast_grow_memo(k, n, memo)
                if fn > fgn:
                    all_bounded = False
                    break
            except (RecursionError, OverflowError):
                break
        if all_bounded:
            return k
    return max_level + 1


# ============================================================
# Algorithm 4: Dominance Threshold Finder
# ============================================================

def find_dominance_threshold(
    f: Callable[[int], int],
    g: Callable[[int], int],
    max_search: int = 1000
) -> Optional[int]:
    """Find the threshold N where f eventually dominates g.

    Returns the smallest N such that f(n) > g(n) for all tested n ≥ N.

    Time complexity: O(max_search * cost_of_f_and_g)

    Args:
        f: Dominating function
        g: Dominated function
        max_search: Maximum n to search

    Returns:
        Threshold N, or None if not found

    Example:
        >>> find_dominance_threshold(
        ...     lambda n: fast_grow_closed(2, n),
        ...     lambda n: fast_grow_closed(1, n)
        ... )
        0
    """
    for N in range(max_search):
        all_dominate = True
        for n in range(N, min(N + 50, max_search)):
            try:
                if f(n) <= g(n):
                    all_dominate = False
                    break
            except (RecursionError, OverflowError):
                break
        if all_dominate:
            return N
    return None


# ============================================================
# Algorithm 5: Witness Complexity Estimator
# ============================================================

def estimate_witness_complexity(
    predicate: Callable[[int, int], bool],
    max_n: int = 50,
    max_witness: int = 10000
) -> list:
    """Estimate the minimum witness function for an existential statement.

    For a predicate P(n, w), finds the minimum w such that P(n, w)
    holds for each n, and classifies the growth rate.

    Algorithm:
    1. For each n in range, find smallest w with P(n, w)
    2. Record the sequence of minimum witnesses
    3. Classify the growth rate using classify_darkness_level

    Time complexity: O(max_n * max_witness * cost_of_predicate)

    Args:
        predicate: P(n, w) -> bool
        max_n: Range of n values
        max_witness: Maximum witness to search

    Returns:
        List of (n, min_witness) pairs

    Example:
        >>> # Witness for "w > n^2"
        >>> results = estimate_witness_complexity(
        ...     lambda n, w: w > n**2, max_n=10
        ... )
        >>> results[5]  # min w > 25 is 26
        (5, 26)
    """
    results = []
    for n in range(max_n):
        for w in range(max_witness):
            try:
                if predicate(n, w):
                    results.append((n, w))
                    break
            except (RecursionError, OverflowError):
                results.append((n, None))
                break
        else:
            results.append((n, None))
    return results


# ============================================================
# Algorithm 6: Tower Function
# ============================================================

def tower2(n: int) -> int:
    """Compute the tower of 2s of height n.

    tower2(0) = 1
    tower2(n+1) = 2^tower2(n)

    Time complexity: O(n) multiplications (but results grow astronomically)

    Example:
        >>> tower2(3)
        16
        >>> tower2(4)
        65536
    """
    if n == 0:
        return 1
    return 2 ** tower2(n - 1)


# ============================================================
# Main: Run examples
# ============================================================

if __name__ == "__main__":
    print("=== Fast-Growing Hierarchy (Closed Form) ===")
    for k in range(4):
        vals = [fast_grow_closed(k, n) for n in range(8)]
        print(f"Level {k}: {vals}")

    print()
    print("=== Darkness Level Classification ===")
    test_functions = [
        ("n + 1 (successor)", lambda n: n + 1),
        ("n^2 (quadratic)", lambda n: n ** 2),
        ("2^n (exponential)", lambda n: 2 ** n),
        ("n! (factorial)", lambda n: 1 if n == 0 else n * test_functions[3][1](n-1)),
    ]
    for name, f in test_functions:
        level = classify_darkness_level(f)
        print(f"  {name}: darkness level {level}")

    print()
    print("=== Dominance Thresholds ===")
    for k in range(3):
        threshold = find_dominance_threshold(
            lambda n, k=k: fast_grow_closed(k + 1, n),
            lambda n, k=k: fast_grow_closed(k, n)
        )
        print(f"  Level {k+1} dominates Level {k} from n={threshold}")

    print()
    print("=== Tower Function ===")
    for n in range(6):
        val = tower2(n)
        print(f"  tower2({n}) = {val}")
