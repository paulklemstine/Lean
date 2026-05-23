#!/usr/bin/env python3
"""
Algorithms for Hecke Eigenvalue Computation
============================================

Implements the verified Hecke coefficient propagation algorithm and
its generalizations. All algorithms correspond to formally verified
theorems in the Lean formalization.

Core algorithms:
1. Prime-power coefficient computation via three-term recurrence
2. General coefficient computation via factorization + coprime multiplicativity
3. Local Euler factor evaluation
4. Hecke relation verification
5. Ramanujan bound checking
"""

from math import gcd, isqrt, sqrt, log
from typing import Dict, List, Tuple, Optional, Callable
from functools import reduce
from collections import defaultdict


# ============================================================
# Algorithm 1: Prime-Power Recurrence
# ============================================================

def compute_prime_power_coeff(a_p: int, p: int, r: int, weight: int = 1) -> int:
    """Compute a(p^r) using the prime-power recursion.

    Uses the recurrence:
        a(p^0) = 1
        a(p^1) = a_p
        a(p^{r+2}) = a_p * a(p^{r+1}) - p^{weight} * a(p^r)

    Args:
        a_p: The eigenvalue a(p) at the prime p
        p: The prime
        r: The exponent (non-negative integer)
        weight: The modular weight parameter (default 1 for normalized packets,
                use k-1 for classical weight-k forms)

    Returns:
        a(p^r) computed via the recurrence

    Time complexity: O(r)
    Space complexity: O(1)

    Corresponds to: computePrimePower_correct in Compute.lean
    """
    if r == 0:
        return 1
    if r == 1:
        return a_p

    p_weight = p ** weight
    prev2, prev1 = 1, a_p
    for _ in range(r - 1):
        prev2, prev1 = prev1, a_p * prev1 - p_weight * prev2
    return prev1


# ============================================================
# Algorithm 2: Factorization and General Coefficient
# ============================================================

def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}.

    Time complexity: O(sqrt(n))
    """
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def compute_general_coeff(
    prime_eigenvalues: Dict[int, int],
    n: int,
    weight: int = 1
) -> int:
    """Compute a(n) from local prime eigenvalue data.

    Uses:
    1. Prime factorization: n = p1^e1 * p2^e2 * ...
    2. Prime-power recurrence: compute a(pi^ei) for each prime power
    3. Coprime multiplicativity: a(n) = product of a(pi^ei)

    Args:
        prime_eigenvalues: dict mapping prime p to eigenvalue a(p)
        n: positive integer
        weight: modular weight parameter

    Returns:
        a(n) computed via the Hecke eigenvalue propagation algorithm

    Time complexity: O(sqrt(n) + sum of exponents in factorization)
    Space complexity: O(number of distinct prime factors)

    Corresponds to: coeff_mul_of_coprime + computePrimePower_correct
    """
    if n == 0:
        return 0
    if n == 1:
        return 1
    factors = prime_factorization(n)
    result = 1
    for p, e in factors.items():
        a_p = prime_eigenvalues.get(p, 0)
        result *= compute_prime_power_coeff(a_p, p, e, weight)
    return result


# ============================================================
# Algorithm 3: Batch Coefficient Generation
# ============================================================

def generate_all_coefficients(
    prime_eigenvalues: Dict[int, int],
    N: int,
    weight: int = 1
) -> List[int]:
    """Generate a(n) for all 0 ≤ n ≤ N.

    Uses a sieve-like approach: for each prime p, compute a(p^r)
    for all prime powers p^r ≤ N, then assemble using multiplicativity.

    Args:
        prime_eigenvalues: dict mapping prime p to eigenvalue a(p)
        N: upper bound
        weight: modular weight parameter

    Returns:
        List where result[n] = a(n) for 0 ≤ n ≤ N

    Time complexity: O(N log N)
    Space complexity: O(N)
    """
    result = [0] * (N + 1)
    result[1] = 1 if N >= 1 else 0

    # Sieve: for each n, compute a(n) using its smallest prime factor
    for n in range(2, N + 1):
        factors = prime_factorization(n)
        coeff = 1
        for p, e in factors.items():
            a_p = prime_eigenvalues.get(p, 0)
            coeff *= compute_prime_power_coeff(a_p, p, e, weight)
        result[n] = coeff

    return result


# ============================================================
# Algorithm 4: Local Euler Factor Evaluation
# ============================================================

def euler_factor_value(a_p: int, p: int, T: complex, weight: int = 1) -> complex:
    """Evaluate the local Euler factor 1/(1 - a(p)T + p^{weight}T²).

    This is the rational function whose Taylor coefficients are a(p^r).

    Args:
        a_p: eigenvalue at p
        p: prime
        T: complex evaluation point
        weight: modular weight parameter

    Returns:
        1 / (1 - a_p * T + p^weight * T^2)

    Corresponds to: local_euler_factor_identity in EulerFactor.lean
    """
    p_w = p ** weight
    denom = 1 - a_p * T + p_w * T * T
    if abs(denom) < 1e-15:
        return float('inf')
    return 1 / denom


def euler_factor_poles(a_p: float, p: int, weight: int = 1) -> Tuple[complex, complex]:
    """Compute the poles (Satake parameters) of the local Euler factor.

    The poles of 1/(1 - a_p*T + p^w*T²) are at T = 1/α, 1/β
    where α, β are roots of X² - a_p*X + p^w = 0.

    Args:
        a_p: eigenvalue at p
        p: prime
        weight: modular weight parameter

    Returns:
        (alpha, beta): the Satake parameters
    """
    p_w = p ** weight
    disc = a_p * a_p - 4 * p_w
    if disc >= 0:
        sqrt_disc = sqrt(disc)
        return ((a_p + sqrt_disc) / 2, (a_p - sqrt_disc) / 2)
    else:
        sqrt_disc = sqrt(-disc)
        return (
            complex(a_p / 2, sqrt_disc / 2),
            complex(a_p / 2, -sqrt_disc / 2)
        )


# ============================================================
# Algorithm 5: Hecke Relation Verification
# ============================================================

def verify_hecke_relation(
    a: Callable[[int], int],
    m: int,
    n: int,
    weight: int = 1
) -> Tuple[bool, int, int]:
    """Verify the Hecke relation a(m)*a(n) = Σ_{d|gcd(m,n)} d^w * a(mn/d²).

    Args:
        a: coefficient function
        m, n: positive integers
        weight: modular weight parameter

    Returns:
        (is_equal, lhs, rhs): whether the relation holds and the values
    """
    g = gcd(m, n)
    lhs = a(m) * a(n)
    rhs = 0
    for d in range(1, g + 1):
        if g % d == 0:
            rhs += (d ** weight) * a(m * n // (d * d))
    return (lhs == rhs, lhs, rhs)


def verify_prime_power_hecke(
    a: Callable[[int], int],
    p: int,
    s: int,
    t: int,
    weight: int = 1
) -> Tuple[bool, int, int]:
    """Verify the prime-power Hecke relation.

    a(p^s)*a(p^t) = Σ_{i=0}^{min(s,t)} p^{i*w} * a(p^{s+t-2i})

    Corresponds to: coeff_hecke_relation_prime_powers in PrimePowerHecke.lean
    """
    lhs = a(p ** s) * a(p ** t)
    rhs = sum(
        (p ** (i * weight)) * a(p ** (s + t - 2 * i))
        for i in range(min(s, t) + 1)
    )
    return (lhs == rhs, lhs, rhs)


# ============================================================
# Algorithm 6: Ramanujan Bound Checking
# ============================================================

def check_ramanujan_bound(
    prime_eigenvalues: Dict[int, int],
    weight: int = 12,
    bound: Optional[int] = None
) -> List[Tuple[int, float, float, bool]]:
    """Check the Ramanujan bound |a(p)| ≤ 2 * p^{(weight-1)/2}.

    For the Ramanujan tau function (weight 12), this is the
    Ramanujan conjecture (proved by Deligne): |τ(p)| ≤ 2*p^{11/2}.

    Args:
        prime_eigenvalues: dict mapping prime p to a(p)
        weight: modular weight
        bound: only check primes up to this bound

    Returns:
        List of (p, |a(p)|, bound_value, satisfies_bound)
    """
    results = []
    for p, a_p in sorted(prime_eigenvalues.items()):
        if bound is not None and p > bound:
            break
        bound_val = 2 * p ** ((weight - 1) / 2)
        satisfies = abs(a_p) <= bound_val
        results.append((p, abs(a_p), bound_val, satisfies))
    return results


# ============================================================
# Algorithm 7: Deterministic Propagation Test
# ============================================================

def test_deterministic_propagation(
    prime_eigenvalues_1: Dict[int, int],
    prime_eigenvalues_2: Dict[int, int],
    N: int,
    weight: int = 1
) -> Tuple[bool, Optional[int]]:
    """Test conjecture: if two packets agree on a(p) for all primes p ≤ B,
    then they agree on a(n) for all n ≤ B.

    This tests the deterministic local-to-global propagation claim.

    Args:
        prime_eigenvalues_1, prime_eigenvalues_2: two eigenvalue dictionaries
        N: upper bound for testing
        weight: modular weight parameter

    Returns:
        (all_agree, first_disagreement): whether all match, and first n where they differ
    """
    for n in range(1, N + 1):
        a1 = compute_general_coeff(prime_eigenvalues_1, n, weight)
        a2 = compute_general_coeff(prime_eigenvalues_2, n, weight)
        if a1 != a2:
            return (False, n)
    return (True, None)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Ramanujan tau eigenvalues (classical weight 12)
    tau_primes = {
        2: -24, 3: 252, 5: 4830, 7: -16744, 11: 534612,
        13: -577738, 17: -6905934, 19: 10661420, 23: 18643272,
    }

    print("=== Hecke Coefficient Propagation Algorithm ===")
    print()

    # Generate coefficients with weight-1 normalization
    print("Weight-1 normalized coefficients (first 20):")
    coeffs = generate_all_coefficients(tau_primes, 20, weight=1)
    for n in range(1, 21):
        print(f"  a({n:2d}) = {coeffs[n]}")
    print()

    # Verify Hecke relations
    print("Hecke relation checks:")
    a = lambda n: compute_general_coeff(tau_primes, n, weight=1)
    for m, n in [(2, 3), (4, 9), (6, 10)]:
        ok, lhs, rhs = verify_hecke_relation(a, m, n, weight=1)
        print(f"  a({m})*a({n}): {ok} (LHS={lhs}, RHS={rhs})")
    print()

    # Satake parameters
    print("Satake parameters (weight 1):")
    for p in [2, 3, 5, 7]:
        alpha, beta = euler_factor_poles(tau_primes[p], p, weight=1)
        print(f"  p={p}: α={alpha}, β={beta}")
        if isinstance(alpha, complex):
            print(f"    |α|={abs(alpha):.6f}, √p={sqrt(p):.6f}")
    print()

    # Ramanujan bound check (classical weight 12)
    print("Ramanujan bound check (|τ(p)| ≤ 2p^{11/2}):")
    results = check_ramanujan_bound(tau_primes, weight=12)
    for p, abs_ap, bound_val, ok in results:
        print(f"  p={p:2d}: |τ(p)|={abs_ap:>12.0f}, "
              f"bound={bound_val:>16.1f}, {'✓' if ok else '✗'}")
