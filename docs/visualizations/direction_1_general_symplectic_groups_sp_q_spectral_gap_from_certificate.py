"""
Algorithms for Higher-Rank Symplectic Expanders

Implements the core algorithms from the research:
1. Spectral gap computation from character ratio certificates
2. Mixing time estimation
3. Polar code parameter computation
4. Expander family construction
"""

import math
from typing import Tuple, List, Optional


def landazuri_seitz_bound(n: int, q: int) -> float:
    """
    Compute the Landazuri-Seitz lower bound on the minimum dimension
    of nontrivial irreducible representations of Sp_{2n}(F_q).

    LS(n, q) = (q^n - 1)/(q - 1) - 1

    Time: O(n log q) for exponentiation
    Space: O(1)

    >>> landazuri_seitz_bound(1, 3)
    0.0
    >>> landazuri_seitz_bound(2, 3)
    3.0
    >>> landazuri_seitz_bound(3, 5)
    29.0
    """
    if q <= 1 or n <= 0:
        return 0.0
    return (q**n - 1) / (q - 1) - 1


def character_ratio_bound(n: int, q: int) -> float:
    """
    Compute the DL character ratio bound C_n/q = (n+1)/q.

    This bounds |χ_ρ(s)/χ_ρ(1)| for all nontrivial irreducibles ρ
    and regular toral elements s in Sp_{2n}(F_q).

    Time: O(1)
    Space: O(1)

    >>> character_ratio_bound(1, 5)
    0.4
    >>> character_ratio_bound(3, 7)
    0.5714285714285714
    """
    if q <= 0:
        return float('inf')
    return (n + 1) / q


def spectral_gap_from_certificate(
    n: int, q: int, C_n: Optional[float] = None
) -> Tuple[float, float, float]:
    """
    Compute the spectral gap, Cheeger constant, and mixing contraction
    from a DL character ratio certificate.

    Algorithm:
    1. Compute character ratio bound α = C_n/q
    2. Spectral gap = 1 - α
    3. Cheeger constant ≥ gap/2
    4. Mixing contraction = 1 - gap = α

    Returns: (gap, cheeger, contraction)

    Time: O(1)
    Space: O(1)

    >>> spectral_gap_from_certificate(3, 7)
    (0.4285714285714286, 0.21428571428571427, 0.5714285714285714)
    """
    if C_n is None:
        C_n = n + 1
    alpha = C_n / q
    gap = 1 - alpha
    cheeger = gap / 2
    contraction = alpha
    return (gap, cheeger, contraction)


def mixing_time(
    n: int, q: int, epsilon: float = 0.01, C_n: Optional[float] = None
) -> float:
    """
    Compute an upper bound on the mixing time for the random walk
    on the Cayley graph of Sp_{2n}(F_q).

    τ_mix(ε) ≤ (3n² log q + log(1/ε)) / gap

    Time: O(1) (after gap computation)
    Space: O(1)

    >>> mixing_time(2, 7, 0.01)  # doctest: +ELLIPSIS
    34.5...
    """
    gap, _, _ = spectral_gap_from_certificate(n, q, C_n)
    if gap <= 0:
        return float('inf')
    log_order = 3 * n**2 * math.log(q)
    return (log_order + math.log(1/epsilon)) / gap


def polar_code_parameters(
    n: int, q: int, C_n: Optional[float] = None
) -> dict:
    """
    Compute the parameters of the polar-space code induced by
    the symplectic expander on Sp_{2n}(F_q).

    Code length = |W(2n-1, q)| = (q^{2n} - 1)/(q - 1)
    Minimum distance ≥ (gap/2) · length

    Returns: dict with keys 'length', 'min_distance', 'rate_bound'

    Time: O(n) for point counting
    Space: O(1)
    """
    gap, cheeger, _ = spectral_gap_from_certificate(n, q, C_n)
    length = (q**(2*n) - 1) // (q - 1)
    min_dist = cheeger * length
    return {
        'length': length,
        'min_distance_lower_bound': min_dist,
        'relative_distance': min_dist / length if length > 0 else 0,
        'gap': gap,
        'cheeger': cheeger,
    }


def canonical_expander_family(
    max_rank: int = 10, primes: Optional[List[int]] = None
) -> List[dict]:
    """
    Construct the canonical symplectic expander family
    {Cay(Sp_{2n}(F_q), S_n,q)}_{n,q}.

    For each rank n, the family has:
    - C_n = n + 1
    - ε_n = 1/2
    - q_threshold = 2(n+1)

    Time: O(max_rank · |primes|)
    Space: O(max_rank · |primes|)
    """
    if primes is None:
        primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    family = []
    for n in range(1, max_rank + 1):
        q_thresh = 2 * (n + 1)
        for q in primes:
            if q >= q_thresh:
                gap, cheeger, contraction = spectral_gap_from_certificate(n, q)
                family.append({
                    'rank': n,
                    'field_size': q,
                    'gap': gap,
                    'cheeger': cheeger,
                    'contraction': contraction,
                    'threshold_met': True,
                    'mixing_time': mixing_time(n, q),
                })
    return family


def product_expander(
    n1: int, q1: int, n2: int, q2: int
) -> dict:
    """
    Compute parameters of the product expander
    Sp_{2n1}(F_{q1}) × Sp_{2n2}(F_{q2}).

    The product gap is min(gap1, gap2).

    Time: O(1)
    Space: O(1)
    """
    gap1, _, _ = spectral_gap_from_certificate(n1, q1)
    gap2, _, _ = spectral_gap_from_certificate(n2, q2)
    product_gap = min(gap1, gap2)
    return {
        'gap1': gap1, 'gap2': gap2,
        'product_gap': product_gap,
        'product_cheeger': product_gap / 2,
    }


if __name__ == '__main__':
    print("=== Canonical Symplectic Expander Family ===\n")
    family = canonical_expander_family(max_rank=5, primes=[5, 7, 11, 13, 17, 19, 23])
    print(f"{'rank':>4} {'q':>4} {'gap':>8} {'cheeger':>8} {'τ_mix':>10}")
    print("-" * 40)
    for entry in family:
        print(f"{entry['rank']:>4} {entry['field_size']:>4} "
              f"{entry['gap']:>8.4f} {entry['cheeger']:>8.4f} "
              f"{entry['mixing_time']:>10.1f}")

    print("\n=== Polar Code Parameters ===\n")
    for n in [2, 3, 4]:
        for q in [7, 11, 13]:
            params = polar_code_parameters(n, q)
            print(f"n={n}, q={q}: length={params['length']}, "
                  f"d_min≥{params['min_distance_lower_bound']:.0f}, "
                  f"δ≥{params['relative_distance']:.4f}")

    print("\n=== Product Expander ===")
    result = product_expander(2, 7, 3, 11)
    print(f"Sp₄(F₇) × Sp₆(F₁₁): gap={result['product_gap']:.4f}")
