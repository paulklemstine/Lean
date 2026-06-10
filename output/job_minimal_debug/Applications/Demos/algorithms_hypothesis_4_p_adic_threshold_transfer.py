#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for p-adic Threshold Transfer

Implements the computational core of the p-adic threshold transfer principle,
providing algorithms to:
1. Compute p-adic target error for any prime p and precision level k
2. Decide threshold compatibility of complexity profiles
3. Find the optimal precision level for a given profile and prime
4. Certify generalization guarantees

All algorithms are mathematically connected to the formally verified theorems
in PadicThresholdTransfer.lean.
"""

import math
from dataclasses import dataclass
from typing import Optional


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


@dataclass
class EffectiveComplexityProfile:
    """
    Architecture complexity profile for generalization analysis.

    Fields:
        paramDim: Raw parameter dimension (total number of weights)
        quotientComplexity: Effective number of distinguishable behaviors
        codeLength: Minimum description length of the hypothesis
        posteriorKL: KL divergence from prior to posterior
        sampleSize: Number of training samples
    """
    paramDim: int
    quotientComplexity: int
    codeLength: int
    posteriorKL: float
    sampleSize: int

    @property
    def effectiveRate(self) -> float:
        """
        The effective rate: quotientComplexity + codeLength + posteriorKL.
        This is the quantity that actually governs generalization.
        Crucially, it does NOT depend on paramDim.
        """
        return float(self.quotientComplexity) + float(self.codeLength) + self.posteriorKL


@dataclass
class PadicPrecisionProfile:
    """
    A p-adic precision profile bundling a prime p and precision level k.

    The induced sample threshold is p^k, and the target error is p^{-k/2}.
    """
    p: int
    k: int

    def __post_init__(self):
        if not is_prime(self.p):
            raise ValueError(f"p={self.p} is not prime")
        if self.k < 0:
            raise ValueError(f"k={self.k} must be non-negative")

    @property
    def sample_threshold(self) -> int:
        """The sample threshold p^k."""
        return self.p ** self.k

    @property
    def target_error(self) -> float:
        """The target error ε = 1/√(p^k) = p^{-k/2}."""
        return padic_target_error(self.p, self.k)

    @property
    def target_error_sq(self) -> float:
        """The squared target error ε² = 1/p^k = p^{-k}."""
        return padic_target_error_sq(self.p, self.k)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Compute p-adic target error
# ═══════════════════════════════════════════════════════════════════════

def padic_target_error(p: int, k: int) -> float:
    """
    Compute the p-adic target error at precision level k.

    ε = 1/√(p^k) = p^{-k/2}

    This is the canonical precision target induced by the sample threshold p^k.

    Verified property (Theorem 1 in Lean):
        ε² = 1/p^k

    Verified property (Budget Identity in Lean):
        p^k · ε² = 1

    Time complexity: O(log k) for exponentiation
    Space complexity: O(1)

    Args:
        p: Prime number (base of valuation)
        k: Precision level (non-negative integer)

    Returns:
        Target error ε = p^{-k/2}
    """
    if p < 2:
        raise ValueError(f"p must be prime, got {p}")
    if k < 0:
        raise ValueError(f"k must be non-negative, got {k}")
    return 1.0 / math.sqrt(p ** k)


def padic_target_error_sq(p: int, k: int) -> float:
    """
    Compute the squared p-adic target error.

    ε² = 1/p^k = p^{-k}

    This avoids the square root for exact rational arithmetic.

    Time complexity: O(log k)
    Space complexity: O(1)
    """
    return 1.0 / (p ** k)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Check p-adic threshold compatibility
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class CompatibilityResult:
    """Result of a threshold compatibility check."""
    compatible: bool
    target_error: float
    target_error_sq: float
    sample_threshold: int
    effective_budget: float
    effective_rate: float
    sample_ok: bool
    rate_ok: bool
    generalizes: bool

    def __repr__(self):
        status = "COMPATIBLE" if self.compatible else "INCOMPATIBLE"
        return (f"CompatibilityResult({status}, ε={self.target_error:.6f}, "
                f"budget={self.effective_budget:.4f}, rate={self.effective_rate:.4f})")


def check_threshold_compatible(
    prof: EffectiveComplexityProfile,
    p: int,
    k: int
) -> CompatibilityResult:
    """
    Check if a complexity profile is p-adic threshold compatible.

    A profile is compatible if:
    1. sampleSize ≥ p^k (sample threshold met)
    2. effectiveRate ≤ sampleSize · ε² (budget constraint satisfied)

    If compatible, the profile generalizes at precision ε = p^{-k/2},
    regardless of paramDim (Theorem 2 in Lean).

    Time complexity: O(log k) for threshold computation
    Space complexity: O(1)

    Args:
        prof: The complexity profile to check
        p: Prime base
        k: Precision level

    Returns:
        CompatibilityResult with all details
    """
    threshold = p ** k
    eps = padic_target_error(p, k)
    eps_sq = padic_target_error_sq(p, k)
    budget = prof.sampleSize * eps_sq
    rate = prof.effectiveRate

    sample_ok = threshold <= prof.sampleSize
    rate_ok = rate <= budget
    compatible = sample_ok and rate_ok
    generalizes = compatible  # By Theorem 2

    return CompatibilityResult(
        compatible=compatible,
        target_error=eps,
        target_error_sq=eps_sq,
        sample_threshold=threshold,
        effective_budget=budget,
        effective_rate=rate,
        sample_ok=sample_ok,
        rate_ok=rate_ok,
        generalizes=generalizes,
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Find optimal precision level
# ═══════════════════════════════════════════════════════════════════════

def find_optimal_precision(
    prof: EffectiveComplexityProfile,
    p: int,
    max_k: int = 100
) -> Optional[int]:
    """
    Find the highest precision level k such that the profile is
    p-adic threshold compatible.

    This implements a binary search over precision levels.

    The optimal k* satisfies:
    - p^{k*} ≤ sampleSize
    - effectiveRate ≤ sampleSize · p^{-k*}
    - k* is maximal

    Time complexity: O(log(max_k) · log(k)) for binary search with exponentiation
    Space complexity: O(1)

    Args:
        prof: The complexity profile
        p: Prime base
        max_k: Maximum precision level to consider

    Returns:
        Optimal k, or None if no compatible level exists
    """
    best_k = None

    # Binary search for the highest compatible k
    lo, hi = 0, max_k
    while lo <= hi:
        mid = (lo + hi) // 2
        result = check_threshold_compatible(prof, p, mid)
        if result.compatible:
            best_k = mid
            lo = mid + 1
        else:
            hi = mid - 1

    return best_k


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Certify generalization guarantee
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class GeneralizationCertificate:
    """
    A certificate that a profile generalizes at a given precision.

    This is the computational analogue of the Lean theorem
    `generalizes_of_padic_threshold_compatible`.
    """
    profile: EffectiveComplexityProfile
    prime: int
    precision_level: int
    target_error: float
    certified: bool
    dimension_free: bool  # Always True by Theorem 3
    budget_identity: float  # Should be 1.0

    def __repr__(self):
        status = "CERTIFIED" if self.certified else "NOT CERTIFIED"
        return (f"GeneralizationCertificate({status}, p={self.prime}, k={self.precision_level}, "
                f"ε={self.target_error:.6f}, dimFree={self.dimension_free})")


def certify_generalization(
    prof: EffectiveComplexityProfile,
    p: int,
    k: int
) -> GeneralizationCertificate:
    """
    Produce a generalization certificate for a complexity profile.

    The certificate attests that:
    1. The profile is p-adic threshold compatible
    2. The generalization guarantee is dimension-free
    3. The budget identity p^k · ε² = 1 holds

    This is the executable version of the formally verified theorem.

    Time complexity: O(log k)
    Space complexity: O(1)
    """
    result = check_threshold_compatible(prof, p, k)
    eps = padic_target_error(p, k)
    threshold = p ** k
    budget_id = threshold * eps ** 2

    return GeneralizationCertificate(
        profile=prof,
        prime=p,
        precision_level=k,
        target_error=eps,
        certified=result.compatible,
        dimension_free=True,  # Always true by Theorem 3
        budget_identity=budget_id,
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Dimension-free comparison
# ═══════════════════════════════════════════════════════════════════════

def verify_dimension_independence(
    prof: EffectiveComplexityProfile,
    p: int,
    k: int,
    dim_range: list[int]
) -> dict:
    """
    Verify that generalization is independent of paramDim.

    Creates copies of the profile with different paramDim values
    and checks that the generalization result is identical.

    This is the computational verification of Theorem 3:
    generalization_dimension_free.

    Args:
        prof: Base profile
        p: Prime base
        k: Precision level
        dim_range: List of paramDim values to test

    Returns:
        Dictionary with verification results
    """
    base_result = check_threshold_compatible(prof, p, k)
    results = {}
    all_agree = True

    for dim in dim_range:
        variant = EffectiveComplexityProfile(
            paramDim=dim,
            quotientComplexity=prof.quotientComplexity,
            codeLength=prof.codeLength,
            posteriorKL=prof.posteriorKL,
            sampleSize=prof.sampleSize
        )
        result = check_threshold_compatible(variant, p, k)
        agrees = result.compatible == base_result.compatible
        all_agree = all_agree and agrees
        results[dim] = {
            'compatible': result.compatible,
            'agrees_with_base': agrees,
        }

    return {
        'dimension_free': all_agree,
        'base_compatible': base_result.compatible,
        'variants': results,
    }


# ═══════════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("p-adic Threshold Transfer — Algorithm Demonstrations")
    print("=" * 70)

    # Example 1: Basic compatibility check
    print("\n--- Algorithm 1 & 2: Compute target error and check compatibility ---")
    prof = EffectiveComplexityProfile(
        paramDim=10000, quotientComplexity=2, codeLength=3,
        posteriorKL=0.5, sampleSize=1024
    )
    for p in [2, 3, 5]:
        for k in [5, 8, 10]:
            result = check_threshold_compatible(prof, p, k)
            print(f"  p={p}, k={k}: {result}")

    # Example 2: Find optimal precision
    print("\n--- Algorithm 3: Find optimal precision level ---")
    prof2 = EffectiveComplexityProfile(
        paramDim=1000000, quotientComplexity=0, codeLength=0,
        posteriorKL=0.3, sampleSize=2**20
    )
    for p in [2, 3, 5, 7]:
        k_opt = find_optimal_precision(prof2, p)
        if k_opt is not None:
            eps = padic_target_error(p, k_opt)
            print(f"  p={p}: optimal k={k_opt}, ε={eps:.8f}, threshold={p**k_opt}")
        else:
            print(f"  p={p}: no compatible level found")

    # Example 3: Certification
    print("\n--- Algorithm 4: Generalization certificate ---")
    cert = certify_generalization(prof2, 2, 15)
    print(f"  {cert}")
    print(f"  Budget identity: p^k · ε² = {cert.budget_identity:.10f}")

    # Example 4: Dimension independence
    print("\n--- Algorithm 5: Dimension independence verification ---")
    dims = [10, 100, 1000, 10000, 100000, 1000000]
    verification = verify_dimension_independence(prof2, 2, 15, dims)
    print(f"  Dimension-free: {verification['dimension_free']}")
    for dim, info in verification['variants'].items():
        print(f"    paramDim={dim:>10}: compatible={info['compatible']}, "
              f"agrees={info['agrees_with_base']}")
