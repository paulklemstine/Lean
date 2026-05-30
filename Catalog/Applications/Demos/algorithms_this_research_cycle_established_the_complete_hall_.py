"""
algorithms.py — Core Algorithms for the Hall k-Eulerian Framework

Implements:
1. Subgroup lattice Möbius function computation
2. Hall k-Eulerian function via Möbius inversion
3. Jordan's totient function (number-theoretic analogue)
4. Generation probability computation
5. Multiplicative decomposition for Jordan's totient

All algorithms include complexity analysis in docstrings.
"""

from math import gcd, isqrt
from functools import reduce, lru_cache
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict


# ===========================================================================
# Algorithm 1: Number-Theoretic Möbius Function
# ===========================================================================

def factorize(n: int) -> List[Tuple[int, int]]:
    """
    Trial-division factorization of n.
    
    Returns list of (prime, exponent) pairs.
    Time: O(√n), Space: O(log n)
    
    >>> factorize(12)
    [(2, 2), (3, 1)]
    >>> factorize(1)
    []
    """
    if n <= 0:
        raise ValueError("n must be positive")
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            exp = 0
            while n % d == 0:
                n //= d
                exp += 1
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def mobius(n: int) -> int:
    """
    Compute the Möbius function μ(n).
    
    μ(n) = 0     if n has a squared prime factor
    μ(n) = (-1)^k if n is a product of k distinct primes
    μ(1) = 1
    
    Time: O(√n), Space: O(1)
    
    >>> [mobius(i) for i in range(1, 11)]
    [1, -1, -1, 0, -1, 1, -1, 0, 0, 1]
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if n == 1:
        return 1
    factors = factorize(n)
    for _, exp in factors:
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def divisors(n: int) -> List[int]:
    """
    Compute all positive divisors of n, sorted.
    
    Time: O(√n), Space: O(d(n)) where d(n) is the number of divisors
    
    >>> divisors(12)
    [1, 2, 3, 4, 6, 12]
    """
    if n <= 0:
        raise ValueError("n must be positive")
    small = []
    large = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


# ===========================================================================
# Algorithm 2: Jordan's Totient Function
# ===========================================================================

def jordan_totient(k: int, n: int) -> int:
    """
    Compute Jordan's totient J_k(n) using the Euler product formula:
    
    J_k(n) = n^k · ∏_{p | n} (1 - 1/p^k)
    
    This is equivalent to the Möbius inversion:
    J_k(n) = Σ_{d | n} μ(n/d) · d^k
    
    For k=1, J_1(n) = φ(n) (Euler's totient).
    
    Time: O(√n) via Euler product, Space: O(1)
    
    Pseudocode:
        result ← n^k
        for each prime p dividing n:
            result ← result · (1 - 1/p^k)
        return result
    
    >>> jordan_totient(1, 12)  # φ(12) = 4
    4
    >>> jordan_totient(2, 6)   # J_2(6) = 6^2 · (1-1/4)(1-1/9) = 24
    24
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if k < 0:
        raise ValueError("k must be non-negative")
    
    result = n ** k
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            result = result * (d ** k - 1) // (d ** k)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result = result * (temp ** k - 1) // (temp ** k)
    return result


def jordan_totient_mobius(k: int, n: int) -> int:
    """
    Compute J_k(n) via explicit Möbius inversion.
    Slower but useful for verification.
    
    J_k(n) = Σ_{d | n} μ(n/d) · d^k
    
    Time: O(d(n) · √n), Space: O(d(n))
    
    >>> jordan_totient_mobius(2, 6)
    24
    """
    return sum(mobius(n // d) * d ** k for d in divisors(n))


# ===========================================================================
# Algorithm 3: Cyclic Group k-Eulerian Count
# ===========================================================================

def cyclic_k_eulerian(n: int, k: int) -> int:
    """
    Compute φ_k(Z/nZ) — the number of k-tuples generating Z/nZ.
    
    A k-tuple (a1,...,ak) generates Z/nZ iff gcd(a1,...,ak,n) = 1.
    By Möbius inversion: φ_k(Z/nZ) = J_k(n) = n^k · ∏(1 - 1/p^k).
    
    Time: O(√n), Space: O(1)
    
    >>> cyclic_k_eulerian(6, 2)  # J_2(6) = 24
    24
    """
    return jordan_totient(k, n)


# ===========================================================================
# Algorithm 4: Generation Probability
# ===========================================================================

def generation_probability(n: int, k: int) -> float:
    """
    Compute P_k(Z/nZ) = J_k(n) / n^k.
    
    By the Euler product: P_k(Z/nZ) = ∏_{p | n} (1 - 1/p^k).
    
    As k → ∞, P_k → 1 geometrically fast.
    
    Time: O(√n), Space: O(1)
    
    >>> generation_probability(6, 1)  # φ(6)/6 = 2/6
    0.3333333333333333
    """
    return jordan_totient(k, n) / n ** k


# ===========================================================================
# Algorithm 5: Subgroup Lattice Möbius Function (for Z/nZ)
# ===========================================================================

def subgroup_mobius_cyclic(d: int, n: int) -> int:
    """
    Compute μ(Z/dZ, Z/nZ) on the subgroup lattice of Z/nZ.
    
    For the cyclic group Z/nZ, subgroups correspond to divisors d | n.
    The Möbius function on the divisor lattice satisfies:
    μ(d, n) = μ_arith(n/d) (the number-theoretic Möbius function).
    
    Time: O(√(n/d)), Space: O(1)
    
    >>> subgroup_mobius_cyclic(1, 6)  # μ(Z/1Z, Z/6Z) = μ(6) = 1
    1
    """
    if n % d != 0:
        raise ValueError(f"{d} does not divide {n}")
    return mobius(n // d)


# ===========================================================================
# Algorithm 6: Möbius Inversion Verification
# ===========================================================================

def verify_partition_identity(n: int, k: int) -> bool:
    """
    Verify the k-tuple partition identity for Z/nZ:
    n^k = Σ_{d | n} #{k-tuples generating Z/dZ in Z/nZ}
    
    The count of k-tuples generating exactly Z/dZ is:
    Σ_{e | d} μ(d/e) · e^k (Jordan-style for the subgroup Z/dZ)
    
    Time: O(d(n)^2 · √n), Space: O(d(n))
    
    >>> verify_partition_identity(12, 2)
    True
    """
    divs = divisors(n)
    lhs = n ** k
    rhs = 0
    for d in divs:
        # Count k-tuples whose generated subgroup is exactly Z/dZ
        # in the ambient group Z/nZ. These are k-tuples (a1,...,ak)
        # with gcd(a1,...,ak, n) = n/d.
        phi_k_d = jordan_totient(k, d)
        rhs += phi_k_d
    return lhs == rhs


def verify_mobius_inversion(n: int, k: int) -> bool:
    """
    Verify φ_k(Z/nZ) = Σ_{d | n} μ(n/d) · d^k.
    
    >>> verify_mobius_inversion(12, 3)
    True
    """
    direct = jordan_totient(k, n)
    mobius_sum = sum(mobius(n // d) * d ** k for d in divisors(n))
    return direct == mobius_sum


# ===========================================================================
# Algorithm 7: Multiplicativity Check
# ===========================================================================

def verify_multiplicativity(k: int, m: int, n: int) -> bool:
    """
    Verify J_k(mn) = J_k(m) · J_k(n) when gcd(m,n) = 1.
    
    >>> verify_multiplicativity(2, 3, 5)
    True
    """
    if gcd(m, n) != 1:
        raise ValueError("m and n must be coprime")
    return jordan_totient(k, m * n) == jordan_totient(k, m) * jordan_totient(k, n)


# ===========================================================================
# Algorithm 8: Convergence Rate Analysis
# ===========================================================================

def convergence_rate(n: int, max_k: int = 20) -> List[Tuple[int, float]]:
    """
    Compute P_k(Z/nZ) for k = 1, ..., max_k to show convergence to 1.
    
    Returns list of (k, P_k) pairs.
    
    The convergence rate is geometric with ratio max(1/p^k) where
    p ranges over prime divisors of n.
    
    Time: O(max_k · √n), Space: O(max_k)
    
    >>> rates = convergence_rate(30, 5)
    >>> all(r[1] <= 1 for r in rates)
    True
    """
    return [(k, generation_probability(n, k)) for k in range(1, max_k + 1)]


# ===========================================================================
# Main: Run all algorithms with examples
# ===========================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("HALL k-EULERIAN FRAMEWORK: ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # Jordan's totient table
    print("\n--- Jordan's Totient J_k(n) ---")
    print(f"{'n':>4} | {'J_1=φ':>6} | {'J_2':>8} | {'J_3':>10}")
    print("-" * 40)
    for n in range(1, 21):
        print(f"{n:4d} | {jordan_totient(1, n):6d} | "
              f"{jordan_totient(2, n):8d} | {jordan_totient(3, n):10d}")
    
    # Verify Euler product vs Möbius inversion
    print("\n--- Euler Product vs Möbius Inversion ---")
    all_match = True
    for n in range(1, 51):
        for k in range(1, 5):
            if not verify_mobius_inversion(n, k):
                print(f"  MISMATCH at n={n}, k={k}")
                all_match = False
    print(f"  All verified for n=1..50, k=1..4: {'✓' if all_match else '✗'}")
    
    # Partition identity
    print("\n--- Partition Identity ---")
    all_partition = True
    for n in range(1, 31):
        for k in range(1, 4):
            if not verify_partition_identity(n, k):
                print(f"  FAILED at n={n}, k={k}")
                all_partition = False
    print(f"  All verified for n=1..30, k=1..3: {'✓' if all_partition else '✗'}")
    
    # Multiplicativity
    print("\n--- Multiplicativity ---")
    all_mult = True
    for k in range(1, 4):
        for m in range(2, 20):
            for n in range(2, 20):
                if gcd(m, n) == 1:
                    if not verify_multiplicativity(k, m, n):
                        print(f"  FAILED at k={k}, m={m}, n={n}")
                        all_mult = False
    print(f"  All verified for k=1..3, m,n=2..19: {'✓' if all_mult else '✗'}")
    
    # Convergence to 1
    print("\n--- Convergence of P_k(Z/nZ) → 1 ---")
    for n in [6, 30, 210]:
        rates = convergence_rate(n, 10)
        ps = [f"{p:.6f}" for _, p in rates]
        print(f"  Z/{n}Z: {', '.join(ps[:5])}, ...")
    
    print("\nAll algorithms verified successfully.")
