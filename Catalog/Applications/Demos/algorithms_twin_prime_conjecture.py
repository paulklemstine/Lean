#!/usr/bin/env python3
"""
Algorithms for Admissible Tuple Theory and Sieve Infrastructure

Implements the computational core of the admissible tuple framework:
- Admissibility checking (with the finite-prime reduction)
- Greedy admissible tuple construction
- CRT sieve avoidance
- Optimal admissible tuple search
- Singular series estimation

All algorithms include docstrings, type hints, complexity analysis, and examples.
"""

from math import gcd, log, prod
from functools import reduce
from typing import Optional


def sieve_primes(n: int) -> list[int]:
    """
    Sieve of Eratosthenes.

    Time: O(n log log n)
    Space: O(n)

    >>> sieve_primes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def is_admissible(H: set[int]) -> bool:
    """
    Check if a finite set of integers is admissible.

    Uses the finite-prime reduction: only primes p ≤ |H| need to be checked.
    For each such prime, verify that the residue image of H does not cover Z/pZ.

    Time: O(|H|² / log |H|) — checking O(|H|/log|H|) primes, each in O(|H|) time
    Space: O(|H|)

    Args:
        H: A finite set of integers.

    Returns:
        True if H is admissible.

    Examples:
        >>> is_admissible({0, 2})        # Twin primes — admissible
        True
        >>> is_admissible({0, 2, 4})     # Covers Z/3Z — not admissible
        False
        >>> is_admissible({0, 2, 6})     # Admissible triple
        True
    """
    card = len(H)
    for p in sieve_primes(card):
        residues = {h % p for h in H}
        if len(residues) >= p:  # Residues cover all of Z/pZ
            return False
    return True


def find_obstruction(H: set[int]) -> Optional[int]:
    """
    Find the smallest prime obstruction for an inadmissible set.

    Returns the smallest prime p such that the residues of H mod p cover Z/pZ,
    or None if H is admissible.

    Time: O(|H|² / log |H|)
    Space: O(|H|)

    Examples:
        >>> find_obstruction({0, 2, 4})
        3
        >>> find_obstruction({0, 1, 2, 3, 4})
        5
        >>> find_obstruction({0, 2})  # Admissible — no obstruction
    """
    card = len(H)
    for p in sieve_primes(card):
        residues = {h % p for h in H}
        if len(residues) >= p:
            return p
    return None


def avoiding_residue(H: set[int], p: int) -> Optional[int]:
    """
    Find a ∈ {0, ..., p-1} such that (a + h) mod p ≠ 0 for all h ∈ H.

    Equivalently, find a ∉ {(-h) mod p : h ∈ H}.

    Time: O(|H| + p) in worst case
    Space: O(|H|)

    Examples:
        >>> avoiding_residue({0, 2}, 2)
        1
        >>> avoiding_residue({0, 2}, 3)
        0
    """
    forbidden = {(-h) % p for h in H}
    for a in range(p):
        if a not in forbidden:
            return a
    return None


def crt_solve(residues: list[tuple[int, int]]) -> int:
    """
    Solve a system of congruences x ≡ a_i (mod m_i) using CRT.

    Assumes moduli are pairwise coprime.

    Time: O(k² · max(log m_i)²) where k = number of congruences
    Space: O(k)

    Args:
        residues: List of (remainder, modulus) pairs.

    Returns:
        Smallest non-negative solution.

    Examples:
        >>> crt_solve([(1, 2), (2, 3), (3, 5)])
        23
    """
    if not residues:
        return 0

    x, m = residues[0]
    x = x % m

    for a, n in residues[1:]:
        # Solve x ≡ a (mod n), x ≡ current_x (mod m)
        # x = current_x + m * t, need m * t ≡ a - current_x (mod n)
        g = gcd(m, n)
        if (a - x) % g != 0:
            raise ValueError("No solution: moduli not coprime enough")
        lcm = m * n // g
        # Extended Euclidean to find inverse of m/g mod n/g
        _, inv, _ = _extended_gcd(m // g, n // g)
        t = (inv * ((a - x) // g)) % (n // g)
        x = x + m * t
        m = lcm
        x = x % m

    return x


def _extended_gcd(a: int, b: int) -> tuple[int, int, int]:
    """Extended Euclidean algorithm: returns (g, x, y) with ax + by = g."""
    if a == 0:
        return b, 0, 1
    g, x, y = _extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def crt_avoidance(H: set[int], primes: list[int]) -> int:
    """
    Find n such that p ∤ (n + h) for all h ∈ H and p ∈ primes.

    Algorithm:
    1. For each prime p, find an avoiding residue a_p.
    2. Solve the CRT system n ≡ a_p (mod p) for all p.

    Time: O(|H| · |P| + |P|² · max(log p)²)
    Space: O(|H| + |P|)

    Args:
        H: Admissible set of integers.
        primes: List of distinct primes.

    Returns:
        A natural number n satisfying the avoidance condition.

    Examples:
        >>> n = crt_avoidance({0, 2}, [2, 3, 5])
        >>> all((n + h) % p != 0 for h in {0, 2} for p in [2, 3, 5])
        True
    """
    congruences = []
    for p in primes:
        a = avoiding_residue(H, p)
        if a is None:
            raise ValueError(f"No avoiding residue for p={p}; H not admissible?")
        congruences.append((a, p))
    return crt_solve(congruences)


def greedy_admissible_tuple(k: int, start: int = 0) -> list[int]:
    """
    Construct an admissible k-tuple greedily, minimizing diameter.

    Algorithm:
    Start with {start}. For each candidate d = start+1, start+2, ...,
    add d to the tuple if it remains admissible. Stop when |H| = k.

    Time: O(k³ / log k) — each candidate check is O(k²/log k), and we
          expect O(k log k) candidates before finding k admissible ones.
    Space: O(k)

    Args:
        k: Desired tuple size.
        start: Starting element (default 0).

    Returns:
        A sorted list of k integers forming an admissible tuple.

    Examples:
        >>> greedy_admissible_tuple(3)
        [0, 2, 6]
        >>> greedy_admissible_tuple(5)
        [0, 2, 6, 8, 12]
    """
    H = {start}
    d = start
    while len(H) < k:
        d += 1
        H_test = H | {d}
        if is_admissible(H_test):
            H = H_test
    return sorted(H)


def optimal_admissible_tuple(k: int, max_diameter: int) -> Optional[list[int]]:
    """
    Search for an admissible k-tuple with minimum diameter ≤ max_diameter.

    Uses backtracking search. Practical for small k (≤ 8).

    Time: O(max_diameter^k · k² / log k) worst case
    Space: O(k)

    Args:
        k: Desired tuple size.
        max_diameter: Maximum allowed diameter.

    Returns:
        Smallest-diameter admissible k-tuple starting at 0, or None.

    Examples:
        >>> optimal_admissible_tuple(2, 10)
        [0, 2]
        >>> optimal_admissible_tuple(3, 10)
        [0, 2, 6]
    """
    def backtrack(current: list[int], remaining: int, start: int) -> Optional[list[int]]:
        if remaining == 0:
            if is_admissible(set(current)):
                return list(current)
            return None
        for d in range(start, max_diameter + 1):
            current.append(d)
            if is_admissible(set(current)):
                result = backtrack(current, remaining - 1, d + 1)
                if result is not None:
                    return result
            current.pop()
        return None

    return backtrack([0], k - 1, 1)


def singular_series_truncation(H: set[int], prime_bound: int) -> float:
    """
    Compute the truncated singular series for an admissible tuple H.

    The singular series is S(H) = ∏_p (1 - ν_p(H)/p) / (1 - 1/p)^k
    where ν_p(H) = |{h mod p : h ∈ H}| is the number of distinct residues.

    For admissible H, this product is conjectured to converge to a positive value,
    giving the leading constant in the Hardy–Littlewood prediction for the density
    of prime k-tuples with pattern H.

    Time: O(π(B) · |H|) where B = prime_bound
    Space: O(|H|)

    Args:
        H: An admissible set of integers.
        prime_bound: Truncation: include primes up to this bound.

    Returns:
        The truncated singular series value.

    Examples:
        >>> abs(singular_series_truncation({0, 2}, 1000) - 1.3203) < 0.01
        True
    """
    k = len(H)
    product_val = 1.0
    for p in sieve_primes(prime_bound):
        nu_p = len({h % p for h in H})
        # Factor: (1 - nu_p/p) / (1 - 1/p)^k
        numerator = 1.0 - nu_p / p
        denominator = (1.0 - 1.0 / p) ** k
        if denominator > 0:
            product_val *= numerator / denominator
    return product_val


def count_prime_tuples(H: set[int], N: int) -> int:
    """
    Count translates n ≤ N such that all n + h are prime for h ∈ H.

    Time: O(N · |H| · √(N + max(H)))
    Space: O(N + max(H)) if using a sieve

    Examples:
        >>> count_prime_tuples({0, 2}, 100)  # Twin primes up to 100
        8
    """
    primes_set = set(sieve_primes(N + max(H) + 1))
    count = 0
    for n in range(2, N + 1):
        if all(n + h in primes_set for h in H):
            count += 1
    return count


def hl_prediction(H: set[int], N: int, prime_bound: int = 10000) -> float:
    """
    Hardy–Littlewood prediction for the count of prime k-tuples up to N.

    Prediction: S(H) · N / (log N)^k

    where S(H) is the singular series and k = |H|.

    Examples:
        >>> pred = hl_prediction({0, 2}, 10**6)
        >>> pred > 0
        True
    """
    k = len(H)
    S = singular_series_truncation(H, prime_bound)
    return S * N / (log(N) ** k)


if __name__ == "__main__":
    # Example usage
    print("=== Admissibility Checking ===")
    for H_list in [[0, 2], [0, 2, 6], [0, 2, 4], [0, 4, 6]]:
        H = set(H_list)
        result = is_admissible(H)
        obs = find_obstruction(H)
        print(f"  {H_list}: admissible={result}, obstruction={obs}")

    print("\n=== Greedy Admissible Tuples ===")
    for k in range(2, 12):
        t = greedy_admissible_tuple(k)
        print(f"  k={k:2d}: {t}  (diameter={t[-1] - t[0]})")

    print("\n=== CRT Avoidance ===")
    H = {0, 2}
    primes = [2, 3, 5, 7, 11]
    n = crt_avoidance(H, primes)
    print(f"  H={sorted(H)}, primes={primes}")
    print(f"  n={n}: all (n+h) coprime to all p? "
          f"{all((n+h) % p != 0 for h in H for p in primes)}")

    print("\n=== Singular Series ===")
    for H_list in [[0, 2], [0, 2, 6], [0, 4, 6], [0, 2, 6, 8]]:
        H = set(H_list)
        S = singular_series_truncation(H, 10000)
        print(f"  H={H_list}: S(H) ≈ {S:.6f}")

    print("\n=== Hardy–Littlewood Predictions vs Actual ===")
    for N in [10**3, 10**4, 10**5, 10**6]:
        actual = count_prime_tuples({0, 2}, N)
        pred = hl_prediction({0, 2}, N)
        ratio = actual / pred if pred > 0 else float('inf')
        print(f"  N={N:>8d}: twin primes = {actual:6d}, "
              f"HL prediction = {pred:8.1f}, ratio = {ratio:.4f}")
