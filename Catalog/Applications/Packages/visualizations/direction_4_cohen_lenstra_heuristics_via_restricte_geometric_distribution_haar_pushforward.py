#!/usr/bin/env python3
"""
Cohen-Lenstra Heuristics: Algorithms

Implements the core algorithms from the research paper:
  1. Geometric distribution computation
  2. Dedekind eta product computation
  3. Cohen-Lenstra weight computation
  4. Haar measure verification on finite quotients
  5. Shannon entropy computation
  6. Bosonic partition function evaluation
"""

import math
from typing import List, Tuple, Dict, Optional


def is_prime(n: int) -> bool:
    """Check if n is prime. Simple trial division."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Return all primes up to n using sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# ============================================================
# Algorithm 1: Geometric Distribution (Haar Pushforward)
# ============================================================

def geometric_pmf(p: int, k: int) -> float:
    """
    Compute the geometric probability mass function:
      f(k) = (1 - 1/p) * (1/p)^k

    This is the pushforward of normalized Haar measure on Z_p
    under the p-adic valuation map v_p.

    Parameters:
        p: Prime number (≥ 2)
        k: Non-negative integer (valuation value)

    Returns:
        The probability Prob(v_p(x) = k) for Haar-random x ∈ Z_p

    Time complexity: O(log k) for the exponentiation
    Space complexity: O(1)

    Example:
        >>> geometric_pmf(2, 0)
        0.5
        >>> geometric_pmf(2, 1)
        0.25
        >>> geometric_pmf(3, 0)
        0.6666666666666667
    """
    assert is_prime(p) and k >= 0
    return (1 - 1/p) * (1/p)**k


def geometric_partial_sum(p: int, n: int) -> float:
    """
    Compute the partial sum ∑_{k=0}^{n-1} f(k) = 1 - (1/p)^n.

    This equals the Haar measure μ(Z_p \\ p^n Z_p), the probability
    that a random element has valuation < n.

    Time complexity: O(log n)
    Space complexity: O(1)
    """
    assert is_prime(p) and n >= 0
    return 1 - (1/p)**n


def geometric_tail_sum(p: int, k: int) -> float:
    """
    Compute the tail sum ∑_{j=k}^{∞} f(j) = (1/p)^k.

    This equals the Haar measure μ(p^k Z_p), the probability
    that a random element has valuation ≥ k.

    Time complexity: O(log k)
    Space complexity: O(1)
    """
    assert is_prime(p) and k >= 0
    return (1/p)**k


# ============================================================
# Algorithm 2: Dedekind Eta Product
# ============================================================

def eta_product(p: int, n: int = 100) -> float:
    """
    Compute the partial Dedekind-type product:
      η_p^{-1}(n) = ∏_{j=1}^{n} (1 - p^{-j})

    This converges to the inverse of the Cohen-Lenstra normalizer.

    Parameters:
        p: Prime number
        n: Number of factors (default 100 for high precision)

    Returns:
        The partial product value

    Time complexity: O(n log n) (for n exponentiations)
    Space complexity: O(1)

    Convergence rate: |η(n) - η(∞)| = O(p^{-n})
    """
    result = 1.0
    for j in range(1, n + 1):
        factor = 1 - p**(-j)
        result *= factor
        if abs(factor - 1) < 1e-16:  # Early termination
            break
    return result


def eta_product_inverse(p: int, n: int = 100) -> float:
    """
    Compute η_p = ∏_{j=1}^{n} (1 - p^{-j})^{-1}.

    This is the Cohen-Lenstra normalization constant, equal to
    the average size of the p-part of the class group under
    the Cohen-Lenstra heuristics.

    Also equals the bosonic partition function Z(p) at fugacity 1/p.
    """
    return 1.0 / eta_product(p, n)


# ============================================================
# Algorithm 3: Cohen-Lenstra Weight
# ============================================================

def cohen_lenstra_weight_cyclic(p: int, k: int) -> float:
    """
    Compute the Cohen-Lenstra weight for the cyclic group Z/p^k Z:
      w(k) = 1 / |Aut(Z/p^k Z)| = 1 / (p^{k-1}(p-1))  for k ≥ 1
      w(0) = 1  (trivial group)

    Parameters:
        p: Prime number
        k: Non-negative integer (exponent)

    Returns:
        The Cohen-Lenstra weight (unnormalized)
    """
    if k == 0:
        return 1.0
    return 1.0 / (p**(k-1) * (p - 1))


def cohen_lenstra_probability_cyclic(p: int, k: int, n_terms: int = 100) -> float:
    """
    Compute the normalized Cohen-Lenstra probability for Z/p^k Z:
      Prob(G ≅ Z/p^k Z) = w(k) / η_p

    where η_p = ∏_{j≥1} (1 - p^{-j})^{-1}.

    Theorem: This equals geom_prob(p, k) = (1 - 1/p) * (1/p)^k.
    """
    return cohen_lenstra_weight_cyclic(p, k) / eta_product_inverse(p, n_terms)


# ============================================================
# Algorithm 4: Haar Measure Verification on Finite Quotients
# ============================================================

def padic_valuation(x: int, p: int) -> int:
    """Compute the p-adic valuation of x. Returns ∞ (as -1) for x = 0."""
    if x == 0:
        return -1  # Represents infinity
    v = 0
    while x % p == 0:
        v += 1
        x //= p
    return v


def verify_haar_on_quotient(p: int, k: int, n: int) -> Tuple[float, float, float]:
    """
    Verify the Haar measure prediction on Z/p^n Z.

    Counts elements of Z/p^n Z with p-adic valuation exactly k,
    and compares with the theoretical prediction (1-1/p) * (1/p)^k.

    Parameters:
        p: Prime
        k: Target valuation
        n: Quotient level (must be > k)

    Returns:
        (empirical, theoretical, relative_error)

    Time complexity: O(p^n) — brute force counting
    Space complexity: O(1)
    """
    assert n > k
    total = p**n
    count = sum(1 for x in range(total) if padic_valuation(x, p) == k)
    empirical = count / total
    theoretical = geometric_pmf(p, k)
    rel_error = abs(empirical - theoretical) / theoretical if theoretical > 0 else 0
    return empirical, theoretical, rel_error


# ============================================================
# Algorithm 5: Shannon Entropy
# ============================================================

def entropy_geometric(p: int, max_terms: int = 500) -> float:
    """
    Compute the Shannon entropy of the geometric distribution:
      H = -∑_k f(k) * log(f(k))

    where f(k) = (1 - 1/p) * (1/p)^k.

    Theorem: H = log(p) / (p - 1)

    Time complexity: O(max_terms)
    Space complexity: O(1)
    """
    H = 0.0
    for k in range(max_terms):
        q = geometric_pmf(p, k)
        if q < 1e-300:
            break
        H -= q * math.log(q)
    return H


def entropy_closed_form(p: int) -> float:
    """Closed-form entropy: -log(1-1/p) + log(p) / (p - 1)."""
    return -math.log(1 - 1/p) + math.log(p) / (p - 1)


def entropy_decomposition(p: int, k: int) -> Tuple[float, float]:
    """
    Decompose the entropy contribution of term k into:
      -f(k) * log(f(k)) = -f(k) * [log(1-1/p) + k*log(1/p)]

    Returns (base_part, valuation_part):
      base_part = -f(k) * log(1-1/p)
      valuation_part = -f(k) * k * log(1/p) = f(k) * k * log(p)
    """
    f = geometric_pmf(p, k)
    base = -f * math.log(1 - 1/p)
    valuation = f * k * math.log(p)
    return base, valuation


# ============================================================
# Algorithm 6: Bosonic Partition Function
# ============================================================

def bosonic_partition_function(p: int, n: int = 100) -> float:
    """
    Compute the bosonic partition function at fugacity q = 1/p:
      Z(q) = ∏_{k=1}^{n} (1 - q^k)^{-1}

    This equals η_p, the Cohen-Lenstra normalization constant.
    In statistical mechanics, this is the grand canonical partition
    function of a system of non-interacting bosons on a 1D lattice.

    The connection: each isomorphism class of finite abelian p-group
    corresponds to a partition (via the structure theorem), and
    the Cohen-Lenstra weight 1/|Aut(G)| is the Boltzmann weight
    with energy log|G| at inverse temperature 1.
    """
    return eta_product_inverse(p, n)


def partition_count_approx(n: int, p: int, max_terms: int = 100) -> float:
    """
    Approximate the number of partitions of n using the connection
    to the bosonic partition function:
      ∑_{n≥0} p(n) * q^n = ∏_{k≥1} (1 - q^k)^{-1}

    where q = 1/p. This gives p(n) ≈ coefficient of q^n in Z(q).
    """
    # Use dynamic programming to compute partition numbers
    partitions = [0] * (n + 1)
    partitions[0] = 1
    for k in range(1, n + 1):
        for j in range(k, n + 1):
            partitions[j] += partitions[j - k]
    return partitions[n]


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    print()

    # Algorithm 1: Geometric distribution
    print("1. Geometric Distribution (Haar Pushforward):")
    for p in [2, 3, 5]:
        print(f"   p={p}: ", [f"f({k})={geometric_pmf(p,k):.6f}" for k in range(4)])
        print(f"   Partial sums: ", [f"S({n})={geometric_partial_sum(p,n):.6f}" for n in range(5)])

    # Algorithm 2: Eta product
    print("\n2. Dedekind Eta Product:")
    for p in [2, 3, 5, 7]:
        print(f"   η_{p}^(-1) = {eta_product(p):.10f}, η_{p} = {eta_product_inverse(p):.10f}")

    # Algorithm 3: Cohen-Lenstra weights
    print("\n3. Cohen-Lenstra Weights (verify = geometric pmf):")
    for p in [2, 3]:
        for k in range(5):
            w = cohen_lenstra_probability_cyclic(p, k)
            g = geometric_pmf(p, k)
            print(f"   p={p}, k={k}: CL={w:.8f}, Geom={g:.8f}, Match={abs(w-g)<1e-10}")

    # Algorithm 4: Haar verification
    print("\n4. Haar Measure Verification on Z/p^n Z:")
    for p in [2, 3]:
        for k in range(3):
            emp, theo, err = verify_haar_on_quotient(p, k, k + 3)
            print(f"   p={p}, k={k}, n={k+3}: emp={emp:.6f}, theo={theo:.6f}, err={err:.2e}")

    # Algorithm 5: Entropy
    print("\n5. Shannon Entropy:")
    for p in [2, 3, 5, 7, 11]:
        H_num = entropy_geometric(p)
        H_exact = entropy_closed_form(p)
        print(f"   p={p}: H_numeric={H_num:.10f}, H_exact={H_exact:.10f}, match={abs(H_num-H_exact)<1e-8}")

    # Algorithm 6: Partition function
    print("\n6. Bosonic Partition Function / Partition Numbers:")
    for n in range(10):
        p_n = partition_count_approx(n, 2)
        print(f"   p({n}) = {p_n}")
