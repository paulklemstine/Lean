#!/usr/bin/env python3
"""
Algorithms for Quadratic Reciprocity Computation

Implements multiple algorithms for computing Legendre symbols and verifying
quadratic reciprocity, each corresponding to a different proof architecture.

Algorithms:
1. Euler's criterion (direct computation)
2. Eisenstein floor-sum method (lattice-point counting)
3. Gauss lemma method (upper-half residue counting)
4. Jacobi symbol generalization (efficient for large numbers)
"""

from typing import Tuple, Dict, List
import math
import time


def euler_criterion(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) via Euler's criterion.

    Algorithm: (a/p) = a^((p-1)/2) mod p, mapped to {-1, 0, 1}.
    Time complexity: O(log p) multiplications mod p.
    Space complexity: O(1).

    Args:
        a: Integer to test.
        p: Odd prime modulus.

    Returns:
        1 if a is a quadratic residue mod p,
        -1 if a is a quadratic non-residue mod p,
        0 if p divides a.

    Example:
        >>> euler_criterion(2, 7)
        1
        >>> euler_criterion(3, 7)
        -1
    """
    a = a % p
    if a == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return 1 if result == 1 else -1


def eisenstein_legendre(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) via Eisenstein's floor-sum formula.

    Algorithm: (a/p) = (-1)^(∑_{k=1}^{(p-1)/2} ⌊ka/p⌋).
    This is Eisenstein's lemma, connecting the Legendre symbol to
    a sum of floor quotients.

    Time complexity: O(p) arithmetic operations.
    Space complexity: O(1).

    Args:
        a: Positive integer coprime to p.
        p: Odd prime modulus.

    Returns:
        1 or -1.

    Example:
        >>> eisenstein_legendre(2, 7)
        1
        >>> eisenstein_legendre(3, 7)
        -1
    """
    a = a % p
    if a == 0:
        return 0
    floor_sum = sum((k * a) // p for k in range(1, (p - 1) // 2 + 1))
    return (-1) ** floor_sum


def gauss_lemma_legendre(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) via Gauss's lemma.

    Algorithm: (a/p) = (-1)^N where N = #{k in [1,(p-1)/2] : (ak mod p) > p/2}.
    Gauss's lemma counts how many of the reduced residues ak fall in the
    "upper half" of residues mod p.

    Time complexity: O(p) arithmetic operations.
    Space complexity: O(1).

    Args:
        a: Positive integer coprime to p.
        p: Odd prime modulus.

    Returns:
        1 or -1.

    Example:
        >>> gauss_lemma_legendre(2, 7)
        1
        >>> gauss_lemma_legendre(3, 7)
        -1
    """
    a = a % p
    if a == 0:
        return 0
    half = p // 2
    count = sum(1 for k in range(1, (p - 1) // 2 + 1) if (a * k) % p > half)
    return (-1) ** count


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n) using the law of quadratic reciprocity.

    This is the most efficient general algorithm, running in O(log²(n)) time
    using repeated application of reciprocity and reduction.

    Algorithm:
        1. Reduce a mod n.
        2. Extract factors of 2 and apply the second supplementary law.
        3. Apply quadratic reciprocity to swap a and n.
        4. Repeat until one argument is 0 or 1.

    Time complexity: O(log²(max(a,n))) bit operations.
    Space complexity: O(1).

    Args:
        a: Integer.
        n: Positive odd integer.

    Returns:
        0, 1, or -1.

    Example:
        >>> jacobi_symbol(2, 15)
        1
        >>> jacobi_symbol(7, 15)
        -1
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a = a % n
    result = 1
    while a != 0:
        # Extract factors of 2
        while a % 2 == 0:
            a //= 2
            # Second supplementary law: (2/n) = (-1)^((n²-1)/8)
            if n % 8 in (3, 5):
                result = -result
        # Quadratic reciprocity: swap a and n
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def verify_reciprocity(p: int, q: int) -> Dict[str, object]:
    """
    Verify quadratic reciprocity for a pair of distinct odd primes
    using all four methods.

    Returns a dictionary with:
        - 'euler': Legendre product via Euler's criterion
        - 'eisenstein': sign via Eisenstein floor-sum
        - 'gauss': sign via Gauss lemma
        - 'jacobi': sign via Jacobi symbol algorithm
        - 'expected': (-1)^((p-1)/2 * (q-1)/2)
        - 'floor_sum_identity': whether eisensteinFloorSum(p,q) + eisensteinFloorSum(q,p) = (p-1)(q-1)/4
        - 'parity_equiv': whether Eisenstein and Gauss parities match
        - 'all_agree': whether all methods agree

    Example:
        >>> result = verify_reciprocity(3, 7)
        >>> result['all_agree']
        True
    """
    # Direct computation
    euler = euler_criterion(q, p) * euler_criterion(p, q)

    # Eisenstein method
    fs_pq = sum((i * q) // p for i in range(1, (p - 1) // 2 + 1))
    fs_qp = sum((j * p) // q for j in range(1, (q - 1) // 2 + 1))
    eisenstein = (-1) ** (fs_pq + fs_qp)

    # Gauss lemma method
    uhrc_qp = sum(1 for k in range(1, (p - 1) // 2 + 1) if (q * k) % p > p // 2)
    uhrc_pq = sum(1 for k in range(1, (q - 1) // 2 + 1) if (p * k) % q > q // 2)
    gauss = (-1) ** (uhrc_qp + uhrc_pq)

    # Jacobi symbol
    jac = jacobi_symbol(q, p) * jacobi_symbol(p, q)

    # Expected value
    expected = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))

    # Floor-sum identity
    floor_sum_ok = (fs_pq + fs_qp) == (p - 1) * (q - 1) // 4

    # Parity equivalence
    parity_equiv = (fs_pq + fs_qp) % 2 == (uhrc_qp + uhrc_pq) % 2

    return {
        'euler': euler,
        'eisenstein': eisenstein,
        'gauss': gauss,
        'jacobi': jac,
        'expected': expected,
        'floor_sum_identity': floor_sum_ok,
        'parity_equiv': parity_equiv,
        'all_agree': euler == eisenstein == gauss == jac == expected,
    }


def benchmark_methods(limit: int = 100) -> Dict[str, float]:
    """
    Benchmark the four Legendre symbol computation methods.

    Args:
        limit: Test all odd primes up to this limit.

    Returns:
        Dictionary mapping method name to total time in seconds.
    """
    from itertools import combinations

    def sieve(n):
        s = [True] * (n + 1)
        s[0] = s[1] = False
        for i in range(2, int(n**0.5) + 1):
            if s[i]:
                for j in range(i*i, n+1, i):
                    s[j] = False
        return [p for p in range(3, n+1) if s[p]]

    primes = sieve(limit)
    pairs = list(combinations(primes, 2))

    methods = {
        'euler': lambda p, q: euler_criterion(q, p) * euler_criterion(p, q),
        'eisenstein': lambda p, q: eisenstein_legendre(q, p) * eisenstein_legendre(p, q),
        'gauss': lambda p, q: gauss_lemma_legendre(q, p) * gauss_lemma_legendre(p, q),
        'jacobi': lambda p, q: jacobi_symbol(q, p) * jacobi_symbol(p, q),
    }

    timings = {}
    for name, method in methods.items():
        start = time.perf_counter()
        for p, q in pairs:
            method(p, q)
        elapsed = time.perf_counter() - start
        timings[name] = elapsed

    return timings


if __name__ == "__main__":
    print("Quadratic Reciprocity Algorithms")
    print("=" * 50)

    # Verify all methods agree
    from itertools import combinations
    primes = [p for p in range(3, 100) if all(p % d != 0 for d in range(2, int(p**0.5)+1))]
    pairs = list(combinations(primes, 2))

    print(f"\nVerifying {len(pairs)} prime pairs...")
    all_ok = True
    for p, q in pairs:
        result = verify_reciprocity(p, q)
        if not result['all_agree']:
            print(f"  FAILURE: p={p}, q={q}")
            all_ok = False
    print(f"All verified: {all_ok}")

    # Benchmark
    print("\nBenchmark (primes up to 200):")
    timings = benchmark_methods(200)
    for name, t in sorted(timings.items(), key=lambda x: x[1]):
        print(f"  {name:12s}: {t:.4f}s")
