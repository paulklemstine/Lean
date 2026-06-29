#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Spectral Sparsity Analysis

Implements the algorithms from the research paper:
1. Additive energy computation via representation function
2. Strong liar set computation for Miller-Rabin
3. CRT fiber decomposition for semiprimes
4. Additive energy exponent estimation

All algorithms include complexity analysis and docstrings.
"""

import math
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Two-Adic Decomposition
# ═══════════════════════════════════════════════════════════════════════════

def two_adic_decomp(m: int) -> Tuple[int, int]:
    """
    Compute the 2-adic decomposition of m.

    Write m = 2^s * d where d is odd.

    Args:
        m: A positive integer.

    Returns:
        (s, d) where m = 2^s * d and d is odd.

    Time complexity: O(log m)
    Space complexity: O(1)

    Examples:
        >>> two_adic_decomp(12)
        (2, 3)
        >>> two_adic_decomp(7)
        (0, 7)
        >>> two_adic_decomp(16)
        (4, 1)
    """
    if m == 0:
        return (0, 0)
    s = 0
    d = m
    while d % 2 == 0:
        s += 1
        d //= 2
    return (s, d)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Miller-Rabin Strong Liar Detection
# ═══════════════════════════════════════════════════════════════════════════

def is_strong_liar(n: int, a: int) -> bool:
    """
    Determine if 'a' is a strong liar for 'n' in the Miller-Rabin test.

    A base a is a strong liar for odd composite n if:
    - gcd(a, n) = 1, AND
    - Either a^d ≡ 1 (mod n), OR
    - There exists 0 ≤ r < s such that a^(2^r · d) ≡ -1 (mod n)
    where n - 1 = 2^s · d with d odd.

    Args:
        n: The number being tested (should be odd composite, n ≥ 3).
        a: The base to test (1 < a < n).

    Returns:
        True if a is a strong liar for n, False otherwise.

    Time complexity: O(s · log(n)²) where s = v₂(n-1)
    Space complexity: O(log n)
    """
    if n <= 2 or a <= 0:
        return False
    if math.gcd(a, n) != 1:
        return False

    s, d = two_adic_decomp(n - 1)

    # Compute a^d mod n using fast exponentiation
    x = pow(a, d, n)

    # Check if a^d ≡ 1 (mod n)
    if x == 1 or x == n - 1:
        return True

    # Check if a^(2^r · d) ≡ -1 (mod n) for some r
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
        if x == 1:
            return False
    return False


def strong_liar_set(n: int) -> Set[int]:
    """
    Compute the complete strong liar set L(n) for Miller-Rabin.

    L(n) = {a ∈ {2, ..., n-2} : gcd(a,n) = 1 and a is a strong liar for n}

    Args:
        n: An odd composite number ≥ 9.

    Returns:
        The set of all strong liars for n.

    Time complexity: O(n · log(n)²)
    Space complexity: O(n)
    """
    if n <= 3:
        return set()
    return {a for a in range(2, n) if math.gcd(a, n) == 1 and is_strong_liar(n, a)}


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Additive Energy Computation
# ═══════════════════════════════════════════════════════════════════════════

def representation_count(S: Set[int], n: int) -> Dict[int, int]:
    """
    Compute the representation function r_S(x) for all x ∈ Z/nZ.

    r_S(x) = |{(a, b) ∈ S² : a + b ≡ x (mod n)}|

    Args:
        S: A subset of Z/nZ (represented as integers mod n).
        n: The modulus.

    Returns:
        Dictionary mapping x to r_S(x) for all x with r_S(x) > 0.

    Time complexity: O(|S|²)
    Space complexity: O(n)
    """
    r: Dict[int, int] = defaultdict(int)
    S_list = sorted(S)
    for a in S_list:
        for b in S_list:
            r[(a + b) % n] += 1
    return dict(r)


def additive_energy(S: Set[int], n: int) -> int:
    """
    Compute the additive energy E(S) of a subset S ⊆ Z/nZ.

    E(S) = |{(a,b,c,d) ∈ S⁴ : a + b ≡ c + d (mod n)}|
         = Σ_x r_S(x)²

    This identity (Parseval-type) is the fundamental connection between
    the quadruple-counting and representation-function formulations.

    Args:
        S: A subset of Z/nZ.
        n: The modulus.

    Returns:
        The additive energy E(S).

    Time complexity: O(|S|²)
    Space complexity: O(n)

    Formally verified bounds:
        |S|² ≤ E(S) ≤ |S|³  (proved in SpectralSparsity.lean)
    """
    r = representation_count(S, n)
    return sum(v * v for v in r.values())


def additive_energy_exponent(S: Set[int], n: int) -> float:
    """
    Compute the additive energy exponent α(n).

    α(n) = log(E(L(n))) / log(|L(n)|)

    By the formally verified bounds, 2 ≤ α(n) ≤ 3 for |S| ≥ 2.

    Args:
        S: A subset of Z/nZ (typically the strong liar set).
        n: The modulus.

    Returns:
        The energy exponent α, or 0 if |S| ≤ 1.
    """
    if len(S) <= 1:
        return 0.0
    E = additive_energy(S, n)
    if E <= 0:
        return 0.0
    return math.log(E) / math.log(len(S))


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: CRT Fiber Decomposition
# ═══════════════════════════════════════════════════════════════════════════

def crt_fiber(S: Set[int], n: int, p: int) -> Set[int]:
    """
    Compute the CRT fiber: projection of S ⊆ Z/nZ to Z/pZ.

    For n = pq and the CRT isomorphism Z/nZ ≅ Z/pZ × Z/qZ,
    this computes π_p(S) = {a mod p : a ∈ S}.

    Args:
        S: A subset of Z/nZ.
        n: The modulus (should be divisible by p).
        p: The prime factor to project onto.

    Returns:
        The p-fiber of S.

    Time complexity: O(|S|)
    Space complexity: O(p)
    """
    return {a % p for a in S}


def crt_fiber_analysis(n: int, p: int, q: int) -> Dict:
    """
    Perform full CRT fiber analysis of the strong liar set.

    Computes L(n) and its projections to Z/pZ and Z/qZ, along with
    fiber energies and cardinalities.

    Args:
        n: A semiprime n = p*q.
        p: First prime factor.
        q: Second prime factor.

    Returns:
        Dictionary with fiber analysis results.
    """
    assert n == p * q and p != q

    L = strong_liar_set(n)
    L_p = crt_fiber(L, n, p)
    L_q = crt_fiber(L, n, q)

    E_total = additive_energy(L, n)
    E_p = additive_energy(L_p, p)
    E_q = additive_energy(L_q, q)

    # Check product bound: E(L) vs E(L_p) * E(L_q)
    product_energy = E_p * E_q

    return {
        'n': n, 'p': p, 'q': q,
        'L_size': len(L),
        'L_p_size': len(L_p),
        'L_q_size': len(L_q),
        'E_total': E_total,
        'E_p': E_p,
        'E_q': E_q,
        'E_product': product_energy,
        'alpha': additive_energy_exponent(L, n),
        'alpha_p': additive_energy_exponent(L_p, p),
        'alpha_q': additive_energy_exponent(L_q, q),
        'subdirect_ratio': len(L) / (len(L_p) * len(L_q)) if L_p and L_q else 0,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Spectral Sparsity Test
# ═══════════════════════════════════════════════════════════════════════════

def spectral_sparsity_test(n: int, epsilon: float = 0.1) -> Dict:
    """
    Test the spectral sparsity conjecture for a specific n.

    Checks whether E(L(n)) ≤ C · |L(n)|^{3-ε} for the given ε,
    computing the optimal C.

    Args:
        n: An odd composite number.
        epsilon: The target diffuseness exponent.

    Returns:
        Dictionary with test results.
    """
    L = strong_liar_set(n)
    if len(L) < 2:
        return {'n': n, 'status': 'trivial', 'card': len(L)}

    E = additive_energy(L, n)
    alpha = additive_energy_exponent(L, n)
    target_exp = 3 - epsilon
    threshold = len(L) ** target_exp
    C_needed = E / threshold if threshold > 0 else float('inf')

    return {
        'n': n,
        'card': len(L),
        'energy': E,
        'alpha': alpha,
        'epsilon': epsilon,
        'C_needed': C_needed,
        'is_diffuse': alpha < 3 - epsilon,
        'status': 'diffuse' if alpha < 3 - epsilon else 'dense',
    }


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run examples
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  ALGORITHMS: Spectral Sparsity Analysis")
    print("=" * 60)

    # Example 1: Basic computation
    print("\n--- Example 1: Strong Liar Set for n = 561 (Carmichael) ---")
    n = 561  # = 3 * 11 * 17
    L = strong_liar_set(n)
    E = additive_energy(L, n)
    alpha = additive_energy_exponent(L, n)
    print(f"  n = {n}, |L(n)| = {len(L)}, E(L(n)) = {E}")
    print(f"  α(n) = {alpha:.4f}")
    print(f"  |L|² = {len(L)**2}, |L|³ = {len(L)**3}")
    print(f"  Bounds check: {len(L)**2} ≤ {E} ≤ {len(L)**3}: "
          f"{'✓' if len(L)**2 <= E <= len(L)**3 else '✗'}")

    # Example 2: CRT fiber analysis
    print("\n--- Example 2: CRT Fiber Analysis for n = 15 = 3 × 5 ---")
    result = crt_fiber_analysis(15, 3, 5)
    for k, v in result.items():
        if isinstance(v, float):
            print(f"  {k}: {v:.4f}")
        else:
            print(f"  {k}: {v}")

    # Example 3: Spectral sparsity test
    print("\n--- Example 3: Spectral Sparsity Test ---")
    test_values = [15, 21, 35, 77, 91, 105, 231, 341, 561, 1105]
    print(f"  {'n':>6} {'|L|':>5} {'E':>10} {'α':>7} {'status':>10}")
    print("  " + "-" * 42)
    for n in test_values:
        result = spectral_sparsity_test(n, epsilon=0.2)
        if result['status'] != 'trivial':
            print(f"  {n:>6} {result['card']:>5} {result['energy']:>10} "
                  f"{result['alpha']:>7.3f} {result['status']:>10}")
