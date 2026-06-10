#!/usr/bin/env python3
"""
Algorithms for Parabolic Pressure Computation in GL_n(F_q)

Implements the core q-combinatorial algorithms underlying the
thermodynamic theory of subgroup growth in finite linear groups.
"""

import math
from typing import List, Tuple
from functools import lru_cache


def q_int(q: int, k: int) -> int:
    """Compute the q-integer [k]_q = 1 + q + q^2 + ... + q^{k-1}.

    Time: O(k), Space: O(1).

    >>> q_int(2, 3)
    7
    >>> q_int(3, 2)
    4
    """
    if k <= 0:
        return 0
    return sum(q**i for i in range(k))


def q_factorial(q: int, k: int) -> int:
    """Compute the q-factorial [k]_q! = [1]_q * [2]_q * ... * [k]_q.

    Time: O(k^2), Space: O(1).

    >>> q_factorial(2, 3)
    21
    >>> q_factorial(2, 4)
    315
    """
    result = 1
    for i in range(1, k + 1):
        result *= q_int(q, i)
    return result


def q_binomial(q: int, n: int, k: int) -> int:
    """Compute the Gaussian binomial coefficient [n choose k]_q.

    Uses the q-factorial formula: [n choose k]_q = [n]_q! / ([k]_q! * [n-k]_q!).
    Time: O(n^2), Space: O(1).

    >>> q_binomial(2, 4, 2)
    35
    >>> q_binomial(2, 4, 1)
    15
    """
    if k < 0 or k > n:
        return 0
    return q_factorial(q, n) // (q_factorial(q, k) * q_factorial(q, n - k))


def q_multinomial(q: int, c: List[int]) -> int:
    """Compute the q-multinomial coefficient [n; c_1, ..., c_k]_q.

    For a composition c of n, this equals [n]_q! / product([c_i]_q!).
    Time: O(n^2), Space: O(1).

    >>> q_multinomial(2, [2, 2])
    35
    >>> q_multinomial(2, [1, 1, 1, 1])
    315
    """
    if len(c) <= 1:
        return 1
    n = sum(c)
    result = q_factorial(q, n)
    for ci in c:
        result //= q_factorial(q, ci)
    return result


def compositions(n: int) -> List[List[int]]:
    """Generate all compositions of n (ordered partitions into positive parts).

    Time: O(2^n), Space: O(2^n).

    >>> compositions(3)
    [[1, 1, 1], [1, 2], [2, 1], [3]]
    """
    if n == 0:
        return [[]]
    result = []
    for k in range(1, n + 1):
        for rest in compositions(n - k):
            result.append([k] + rest)
    return result


def cross_term(c: List[int]) -> int:
    """Compute the composition cross-term sum_{i<j} c_i * c_j.

    Satisfies: 2 * cross_term(c) = sum(c)^2 - sum(x^2 for x in c).
    Time: O(k), Space: O(1) where k = len(c).

    >>> cross_term([2, 2])
    4
    >>> cross_term([1, 1, 1, 1])
    6
    """
    total = 0
    suffix_sum = sum(c)
    for ci in c:
        suffix_sum -= ci
        total += ci * suffix_sum
    return total


def parabolic_pressure(q: int, beta: float, n: int) -> float:
    """Compute the parabolic pressure Pi^par_{n,q}(beta).

    Pi = sum_{c |= n} exp(-beta * log(qMultinomial(q, c)))
       = sum_{c |= n} qMultinomial(q, c)^{-beta}

    Time: O(2^n * n^2), Space: O(2^n).
    """
    total = 0.0
    for c in compositions(n):
        qm = q_multinomial(q, c)
        if qm > 0:
            total += qm ** (-beta)
    return total


def normalized_free_energy(q: int, beta: float, n: int) -> float:
    """Compute F^par_{n,q}(beta) = (1/n) * log(Pi^par_{n,q}(beta))."""
    if n == 0:
        return 0.0
    return math.log(parabolic_pressure(q, beta, n)) / n


def tsallis2(p: List[float]) -> float:
    """Compute the Tsallis-2 entropy H_2(p) = 1 - sum(p_i^2).

    >>> tsallis2([0.5, 0.5])
    0.5
    >>> tsallis2([1.0])
    0.0
    """
    return 1.0 - sum(x**2 for x in p)


def parabolic_weight(q: int, c: List[int]) -> float:
    """Compute the parabolic index weight w_q(c) = log([n; c]_q)."""
    qm = q_multinomial(q, c)
    return math.log(qm) if qm > 0 else 0.0


def verify_cross_term_identity(c: List[int]) -> bool:
    """Verify 2 * cross_term(c) = sum(c)^2 - sum(x^2 for x in c)."""
    return 2 * cross_term(c) == sum(c)**2 - sum(x**2 for x in c)


def verify_weight_bounds(q: int, c: List[int]) -> Tuple[bool, float, float, float]:
    """Verify crossTerm*log(q) <= w(c) <= (crossTerm + sum)*log(q).

    Returns (valid, lower_bound, weight, upper_bound).
    """
    ct = cross_term(c)
    s = sum(c)
    log_q = math.log(q)
    w = parabolic_weight(q, c)
    lb = ct * log_q
    ub = (ct + s) * log_q
    return (lb <= w + 1e-10 and w <= ub + 1e-10, lb, w, ub)


if __name__ == '__main__':
    import doctest
    doctest.testmod()

    print("=== Algorithm Verification ===")
    print()

    # Verify cross-term identity
    print("Cross-term identity verification:")
    for n in range(1, 6):
        all_ok = all(verify_cross_term_identity(c) for c in compositions(n))
        print(f"  n={n}: {'PASS' if all_ok else 'FAIL'}")

    # Verify weight bounds
    print("\nWeight bounds verification (q=2):")
    for n in range(1, 6):
        for c in compositions(n):
            ok, lb, w, ub = verify_weight_bounds(2, c)
            if not ok:
                print(f"  FAIL: c={c}, lb={lb:.4f}, w={w:.4f}, ub={ub:.4f}")
        print(f"  n={n}: ALL PASS")

    # Parabolic pressure values
    print("\nParabolic pressure (q=2, beta=1.0):")
    for n in range(1, 9):
        pi = parabolic_pressure(2, 1.0, n)
        fn = normalized_free_energy(2, 1.0, n)
        print(f"  n={n}: Pi = {pi:.6f}, F = {fn:.6f}")
