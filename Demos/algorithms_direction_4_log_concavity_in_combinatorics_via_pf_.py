#!/usr/bin/env python3
"""
PF₂ Log-Concavity Algorithms

Implements the core algorithms from the PF₂ combinatorial log-concavity theory:

1. Product polynomial coefficient computation (Route B: convolution)
2. Log-concavity verification
3. PF₂ (ratio-decreasing) verification
4. PF₂ certificate construction and validation
5. Elementary symmetric polynomial computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
from functools import reduce
from itertools import combinations
import math


@dataclass
class PF2Certificate:
    """A PF₂ certificate for a finite nonneg sequence.

    The certificate consists of weights w_0, ..., w_{m-1} ≥ 0 such that
    the sequence equals the coefficients of ∏_{i<m} (1 + w_i · X).

    Attributes:
        weights: List of nonneg weights for the linear factors.
        coefficients: The certified coefficient sequence.
        is_valid: Whether the certificate passes all PF₂ checks.
    """
    weights: List[float]
    coefficients: List[float]
    is_valid: bool
    log_concavity_margins: List[float]
    ratio_decreasing_margins: List[float]


def compute_product_polynomial(weights: List[float]) -> List[float]:
    """Compute coefficients of ∏ᵢ(1 + wᵢ · X) by sequential convolution.

    This implements the inductive construction:
        P_0 = 1
        P_{i+1} = P_i · (1 + w_i · X)

    At each step, the new coefficient b[k] = a[k] + w · a[k-1],
    which is exactly the formula used in the formal proof of
    `ratioDecreasing_mul_linear`.

    Args:
        weights: List of nonneg real weights [w_0, ..., w_{m-1}].

    Returns:
        Coefficient list [a_0, a_1, ..., a_m] where a_k = e_k(w_0,...,w_{m-1}).

    Time complexity: O(m²) where m = len(weights).
    Space complexity: O(m).

    Example:
        >>> compute_product_polynomial([1, 1, 1])
        [1.0, 3.0, 3.0, 1.0]  # = coefficients of (1+X)³
    """
    coeffs = [1.0]
    for w in weights:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for k in range(len(coeffs)):
            new_coeffs[k] += coeffs[k]           # contribution from "1" factor
            new_coeffs[k + 1] += w * coeffs[k]   # contribution from "w·X" factor
        coeffs = new_coeffs
    return coeffs


def verify_log_concavity(seq: List[float], tol: float = 1e-10) -> Tuple[bool, List[float]]:
    """Verify log-concavity of a sequence: a[k]² ≥ a[k-1]·a[k+1] for all 1 ≤ k ≤ n-2.

    Args:
        seq: The sequence to check.
        tol: Numerical tolerance for the inequality.

    Returns:
        Tuple of (is_log_concave, margins) where margins[i] = a[i+1]² - a[i]·a[i+2].

    Time complexity: O(n) where n = len(seq).
    """
    margins = []
    for k in range(1, len(seq) - 1):
        margin = seq[k] ** 2 - seq[k - 1] * seq[k + 1]
        margins.append(margin)
    is_lc = all(m >= -tol for m in margins)
    return is_lc, margins


def verify_ratio_decreasing(seq: List[float], tol: float = 1e-10) -> Tuple[bool, List[float]]:
    """Verify the ratio-decreasing (PF₂) property:
    a[j+1]·a[k+1] ≥ a[j]·a[k+2] for all 0 ≤ j ≤ k.

    This is the stronger PF₂ condition used in the formal proof as
    `IsRatioDecreasing`. It implies log-concavity (take j = k).

    Args:
        seq: The sequence to check.
        tol: Numerical tolerance.

    Returns:
        Tuple of (is_ratio_decreasing, margins).

    Time complexity: O(n²) where n = len(seq).
    """
    margins = []
    n = len(seq)
    for j in range(n - 2):
        for k in range(j, n - 2):
            if j + 1 < n and k + 1 < n and k + 2 < n:
                margin = seq[j + 1] * seq[k + 1] - seq[j] * seq[k + 2]
                margins.append(margin)
    is_rd = all(m >= -tol for m in margins)
    return is_rd, margins


def construct_pf2_certificate(weights: List[float]) -> PF2Certificate:
    """Construct a PF₂ certificate from a list of nonneg weights.

    Given weights w_0, ..., w_{m-1} ≥ 0, computes the coefficients of
    ∏(1 + w_i · X) and verifies both log-concavity and the stronger
    ratio-decreasing property.

    This mirrors the formal construction `PF2CertifiedSeq.ofWeights`.

    Args:
        weights: List of nonneg weights.

    Returns:
        PF2Certificate with all verification results.

    Time complexity: O(m² + m²) = O(m²) for coefficient computation + verification.
    """
    coeffs = compute_product_polynomial(weights)
    lc_ok, lc_margins = verify_log_concavity(coeffs)
    rd_ok, rd_margins = verify_ratio_decreasing(coeffs)

    return PF2Certificate(
        weights=weights,
        coefficients=coeffs,
        is_valid=lc_ok and rd_ok and all(w >= 0 for w in weights),
        log_concavity_margins=lc_margins,
        ratio_decreasing_margins=rd_margins,
    )


def elementary_symmetric_polynomial(weights: List[float], k: int) -> float:
    """Compute the k-th elementary symmetric polynomial e_k(w_1, ..., w_m).

    e_k = ∑_{|S|=k} ∏_{i∈S} w_i

    This is the direct combinatorial computation. For large m and k,
    use `compute_product_polynomial` instead (same result, faster).

    Args:
        weights: The variables w_1, ..., w_m.
        k: The degree (number of terms in each product).

    Returns:
        The value of e_k(w_1, ..., w_m).

    Time complexity: O(C(m, k) · k) where C(m, k) is the binomial coefficient.
    """
    if k < 0 or k > len(weights):
        return 0.0
    if k == 0:
        return 1.0
    return sum(
        reduce(lambda a, b: a * b, (weights[i] for i in S))
        for S in combinations(range(len(weights)), k)
    )


def partition_matroid_independence_numbers(
    block_sizes: List[int],
) -> List[float]:
    """Compute independence numbers for a partition matroid with capacity 1.

    A partition matroid with blocks of sizes b_1, ..., b_m and capacity 1
    per block has independence number I_k = e_k(b_1, ..., b_m), the k-th
    elementary symmetric polynomial in the block sizes.

    The independence polynomial is ∏(1 + b_i · X).

    Args:
        block_sizes: Sizes of the partition blocks.

    Returns:
        List [I_0, I_1, ..., I_m] of independence numbers.
    """
    return compute_product_polynomial([float(b) for b in block_sizes])


def fermion_partition_function(
    activities: List[float],
) -> Dict[str, object]:
    """Compute the fermionic partition function and particle statistics.

    For a noninteracting fermionic system with m modes and single-particle
    activities w_0, ..., w_{m-1}, the grand canonical partition function is
    Z(x) = ∏(1 + w_i · x), and the probability of k particles is
    p_k = Z_k / Z(1), where Z_k is the coefficient of x^k.

    Args:
        activities: Single-particle activities (nonneg reals).

    Returns:
        Dictionary with partition function data:
        - 'coefficients': Weighted degeneracies Z_k
        - 'probabilities': Particle number probabilities p_k
        - 'mean': Expected particle number
        - 'variance': Variance of particle number
        - 'is_log_concave': Whether the distribution is log-concave
    """
    coeffs = compute_product_polynomial(activities)
    total = sum(coeffs)
    probs = [c / total for c in coeffs] if total > 0 else coeffs

    mean = sum(k * p for k, p in enumerate(probs))
    variance = sum(k ** 2 * p for k, p in enumerate(probs)) - mean ** 2

    lc_ok, _ = verify_log_concavity(coeffs)

    return {
        'coefficients': coeffs,
        'probabilities': probs,
        'mean': mean,
        'variance': variance,
        'is_log_concave': lc_ok,
        'total': total,
    }


def test_truncation_conjecture(
    weights: List[float], max_rank: int, tol: float = 1e-10
) -> Tuple[bool, Optional[Tuple[int, float]]]:
    """Test the PF₂ truncation conjecture:
    If a is PF₂, is the truncation a|_{k ≤ r} also PF₂?

    Args:
        weights: Weights defining the PF₂ sequence.
        max_rank: Truncation rank r.
        tol: Numerical tolerance.

    Returns:
        (is_pf2_truncated, counterexample_or_none)
    """
    coeffs = compute_product_polynomial(weights)
    truncated = coeffs[:max_rank + 1] + [0.0] * max(0, len(coeffs) - max_rank - 1)
    truncated = truncated[:len(coeffs)]

    rd_ok, margins = verify_ratio_decreasing(truncated, tol)
    if not rd_ok:
        worst = min(range(len(margins)), key=lambda i: margins[i])
        return False, (worst, margins[worst])
    return True, None


# Example usage
if __name__ == "__main__":
    print("=== PF₂ Certificate Construction ===")

    # Binomial coefficients C(6, k)
    cert = construct_pf2_certificate([1.0] * 6)
    print(f"Binomial C(6,k): {cert.coefficients}")
    print(f"Valid PF₂ certificate: {cert.is_valid}")

    # Weighted product
    cert2 = construct_pf2_certificate([1, 2, 3, 4, 5])
    print(f"\nWeighted [1,2,3,4,5]: {cert2.coefficients}")
    print(f"Valid PF₂ certificate: {cert2.is_valid}")

    # Partition matroid
    indep = partition_matroid_independence_numbers([3, 4, 5, 6])
    print(f"\nPartition matroid [3,4,5,6]: {indep}")
    lc, _ = verify_log_concavity(indep)
    print(f"Log-concave: {lc}")

    # Fermionic partition function
    stats = fermion_partition_function([1.0, 0.5, 0.3, 0.8, 1.2])
    print(f"\nFermion system activities [1.0, 0.5, 0.3, 0.8, 1.2]:")
    print(f"  Mean particles: {stats['mean']:.4f}")
    print(f"  Variance: {stats['variance']:.4f}")
    print(f"  Log-concave: {stats['is_log_concave']}")

    # Truncation conjecture test
    print(f"\n=== Truncation Conjecture Test ===")
    for r in range(1, 6):
        ok, cx = test_truncation_conjecture([1, 2, 3, 4, 5], r)
        print(f"  Truncation at r={r}: PF₂ = {ok}" +
              (f"  (counterexample at index {cx[0]}, margin {cx[1]:.6f})" if cx else ""))
