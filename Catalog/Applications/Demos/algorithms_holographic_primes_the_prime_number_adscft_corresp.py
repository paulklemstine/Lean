#!/usr/bin/env python3
"""
Holographic Spectral Algebra — Core Algorithms

Type-hinted implementations of the spectral decomposition algorithms
for prime factorizations, including:
- Prime factorization (trial division)
- Spectral weight, entropy, defect, interaction computations
- Depth filtration enumeration
- Holographic reconstruction verification
"""

import math
from typing import Dict, List, Set, Tuple, Optional
from functools import reduce
from operator import mul


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Returns a dictionary mapping each prime factor to its multiplicity.
    For n ≤ 1, returns empty dict.

    Algorithm: Trial division up to √n.
    Complexity: O(√n)
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


def spectral_weight(n: int) -> int:
    """
    Compute the spectral weight Ω(n) = Σ_p v_p(n).

    This is the total number of prime factors counted with multiplicity.
    In the holographic dictionary, this is the "total bulk depth."

    Properties:
    - Ω(1) = 0
    - Ω(p) = 1 for prime p
    - Ω(a·b) = Ω(a) + Ω(b) (completely additive)
    - Ω(n) ≤ log₂(n)
    """
    return sum(prime_factorization(n).values())


def distinct_prime_count(n: int) -> int:
    """
    Compute ω(n) = number of distinct prime factors.

    In the holographic dictionary, this is the number of
    "active boundary sectors."
    """
    return len(prime_factorization(n))


def spectral_entropy(n: int) -> float:
    """
    Compute the spectral entropy S(n) = Σ_p v_p(n) · log(p).

    By the Holographic Reconstruction Theorem, S(n) = log(n) for n ≥ 1.
    The reconstruction decomposes the "bulk observable" log(n) into
    contributions from each "boundary sector" (prime).
    """
    return sum(k * math.log(p) for p, k in prime_factorization(n).items())


def holographic_defect(n: int) -> int:
    """
    Compute the holographic defect δ(n) = Ω(n) - ω(n).

    Measures the departure from squarefreeness:
    - δ(n) = 0 iff n is squarefree
    - δ(n) > 0 iff n has a repeated prime factor

    In the holographic dictionary, this is the "information loss"
    when projecting from full bulk spectrum to boundary support.
    """
    f = prime_factorization(n)
    return sum(f.values()) - len(f)


def spectral_interaction(n: int) -> int:
    """
    Compute the spectral interaction energy
    I(n) = Ω(n)² - Σ_p v_p(n)².

    This equals 2 · Σ_{p<q} v_p(n) · v_q(n), measuring
    cross-prime correlations.

    Properties:
    - I(n) = 0 for prime powers (spectrally pure)
    - I(n) > 0 for multi-prime composites
    - I(n) = 2·Σ_{p<q} v_p·v_q (bilinear in the spectrum)
    """
    f = prime_factorization(n)
    omega = sum(f.values())
    sum_sq = sum(k ** 2 for k in f.values())
    return omega ** 2 - sum_sq


def depth_filtration(p: int, k: int, N: int) -> List[int]:
    """
    Enumerate F_k(p) ∩ [1, N]: all n ∈ [1, N] with v_p(n) ≥ k.

    The depth filtration layers form a decreasing chain:
    F_0 ⊇ F_1 ⊇ F_2 ⊇ ...

    Properties:
    - F_0(p) = ℕ (everything)
    - F_k(p) = {multiples of p^k}
    - F_k × F_j → F_{k+j} under multiplication
    """
    pk = p ** k
    return [n for n in range(pk, N + 1, pk)]


def spectral_decomposition(n: int) -> Dict[str, object]:
    """
    Compute the full spectral decomposition of n.

    Returns a dictionary with all holographic invariants:
    - factorization: prime factorization
    - weight: Ω(n)
    - distinct: ω(n)
    - defect: δ(n)
    - entropy: S(n)
    - interaction: I(n)
    - is_squarefree: whether δ(n) = 0
    - reconstruction_error: |S(n) - log(n)|
    """
    f = prime_factorization(n)
    omega = sum(f.values())
    omega_distinct = len(f)
    entropy = sum(k * math.log(p) for p, k in f.items())
    log_n = math.log(n) if n >= 1 else 0.0
    sum_sq = sum(k ** 2 for k in f.values())

    return {
        "n": n,
        "factorization": f,
        "weight": omega,
        "distinct": omega_distinct,
        "defect": omega - omega_distinct,
        "entropy": entropy,
        "interaction": omega ** 2 - sum_sq,
        "is_squarefree": all(v <= 1 for v in f.values()),
        "reconstruction_error": abs(entropy - log_n),
    }


def verify_holographic_reconstruction(N: int) -> Tuple[bool, float]:
    """
    Verify the Holographic Reconstruction Theorem S(n) = log(n)
    for all n in [1, N].

    Returns (all_passed, max_error).
    """
    max_error = 0.0
    all_passed = True
    for n in range(1, N + 1):
        S = spectral_entropy(n)
        log_n = math.log(n)
        error = abs(S - log_n)
        max_error = max(max_error, error)
        if error > 1e-10:
            all_passed = False
    return all_passed, max_error


def spectral_concentration(n: int) -> Optional[float]:
    """
    Compute the spectral concentration C(n) = max_p v_p(n) / Ω(n).

    This measures how "focused" the spectrum is on a single prime:
    - C = 1 for prime powers (maximally concentrated)
    - C → 1/k as n approaches a product of k equal-multiplicity primes
    - C is undefined (None) for n = 1
    """
    f = prime_factorization(n)
    if not f:
        return None
    omega = sum(f.values())
    max_v = max(f.values())
    return max_v / omega


def chebyshev_theta(n: int) -> float:
    """
    Compute the Chebyshev θ function: θ(n) = Σ_{p ≤ n, p prime} log(p).

    In the holographic framework, θ(n) = S(primorial(n)),
    where primorial(n) = ∏_{p ≤ n} p.
    """
    return sum(math.log(p) for p in range(2, n + 1) if all(p % d != 0 for d in range(2, int(p**0.5) + 1)))


if __name__ == "__main__":
    # Run verification
    passed, max_err = verify_holographic_reconstruction(10000)
    print(f"Holographic Reconstruction verified for n ∈ [1, 10000]: {passed}")
    print(f"Maximum numerical error: {max_err:.2e}")

    # Show some decompositions
    print("\nSpectral Decompositions:")
    for n in [12, 30, 60, 360, 2520]:
        d = spectral_decomposition(n)
        print(f"  n={n}: Ω={d['weight']}, ω={d['distinct']}, δ={d['defect']}, "
              f"I={d['interaction']}, sqfree={d['is_squarefree']}")
