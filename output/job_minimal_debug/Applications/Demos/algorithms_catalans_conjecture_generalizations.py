"""
Algorithms for exponential Diophantine equations and Pillai's conjecture.
Type-hinted implementations for searching solutions to x^a - y^b = k.
"""

from typing import List, Tuple, Optional, Set
import math


def is_perfect_power(n: int, min_base: int = 2, min_exp: int = 2) -> Optional[Tuple[int, int]]:
    """Check if n is a perfect power b^e with b >= min_base, e >= min_exp.
    Returns (b, e) if so, None otherwise."""
    if n < min_base ** min_exp:
        return None
    for e in range(min_exp, int(math.log2(n)) + 1):
        b = round(n ** (1.0 / e))
        for candidate in [b - 1, b, b + 1]:
            if candidate >= min_base and candidate ** e == n:
                return (candidate, e)
    return None


def find_pillai_solutions(k: int, max_base: int = 1000, max_exp: int = 50) -> List[Tuple[int, int, int, int]]:
    """Find all solutions (x, a, y, b) to x^a - y^b = k with
    x, y >= 2, a, b >= 2, up to given bounds.
    Returns list of (x, a, y, b) tuples."""
    solutions = []
    # Generate all perfect powers up to max_base^max_exp
    powers: Set[Tuple[int, int, int]] = set()  # (value, base, exp)
    for base in range(2, max_base + 1):
        val = base * base
        exp = 2
        while val <= max_base ** max_exp and exp <= max_exp:
            powers.add((val, base, exp))
            exp += 1
            val = base ** exp

    power_values = {}
    for val, base, exp in powers:
        if val not in power_values:
            power_values[val] = []
        power_values[val].append((base, exp))

    for val1, reps1 in power_values.items():
        target = val1 - k
        if target in power_values:
            for x, a in reps1:
                for y, b in power_values[target]:
                    solutions.append((x, a, y, b))

    return sorted(solutions)


def power_gap(b: int, e: int) -> int:
    """Compute (b+1)^e - b^e, the gap between consecutive e-th powers."""
    return (b + 1) ** e - b ** e


def pillai_gap_bound(e: int, k: int) -> int:
    """Find the smallest b0 such that for all b >= b0, (b+1)^e - b^e > k.
    This gives the effective bound for Pillai solutions with exponent e."""
    b0 = 2
    while power_gap(b0, e) <= k:
        b0 += 1
    return b0


def count_perfect_powers(N: int) -> int:
    """Count perfect powers b^e with b >= 2, e >= 2 that are <= N."""
    powers = set()
    for e in range(2, int(math.log2(N)) + 1):
        b = 2
        while b ** e <= N:
            powers.add(b ** e)
            b += 1
    return len(powers)


def perfect_power_density(N: int) -> float:
    """Compute the density of perfect powers up to N."""
    if N == 0:
        return 0.0
    return count_perfect_powers(N) / N


def pillai_exhaustive_search(k: int, bound: int = 10000, max_exp: int = 20) -> List[Tuple[int, int, int, int]]:
    """Exhaustively search for solutions to x^a - y^b = k.
    More thorough than find_pillai_solutions for moderate bounds."""
    solutions = []
    for a in range(2, max_exp + 1):
        for b in range(2, max_exp + 1):
            for y in range(2, bound + 1):
                target = y ** b + k
                # Check if target is a perfect a-th power
                x_approx = round(target ** (1.0 / a))
                for x_cand in [x_approx - 1, x_approx, x_approx + 1]:
                    if x_cand >= 2 and x_cand ** a == target:
                        solutions.append((x_cand, a, y, b))
                # Early termination: if y^b > bound^max_exp, stop
                if y ** b > bound ** max_exp:
                    break
    return sorted(set(solutions))


def classify_sq_diff(k: int, max_val: int = 10000) -> List[Tuple[int, int]]:
    """Find all (x, y) with x >= 2, y >= 2 and x^2 - y^2 = k."""
    solutions = []
    # x^2 - y^2 = (x-y)(x+y) = k
    # So x-y and x+y are both divisors of k with same parity
    for d in range(1, k + 1):
        if k % d == 0:
            s = k // d  # d = x-y, s = x+y
            if (d + s) % 2 == 0:  # x = (d+s)/2 must be integer
                x = (d + s) // 2
                y = (s - d) // 2
                if x >= 2 and y >= 2:
                    solutions.append((x, y))
    return solutions
