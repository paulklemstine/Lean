"""
Expansion Certificate Algebra: Core Algorithms

Type-hinted implementations of the key algorithms from the expansion
certificate lattice theory. These correspond to the formal Lean definitions
and can be used for numerical experiments.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class ExpansionCertificate:
    """An expansion certificate packaging spectral gap data."""
    gap: float
    size: int
    degree: int

    def __post_init__(self) -> None:
        assert 0 < self.gap <= 1, f"Gap must be in (0, 1], got {self.gap}"
        assert self.size > 0, f"Size must be positive, got {self.size}"
        assert self.degree > 0, f"Degree must be positive, got {self.degree}"

    @property
    def deficiency(self) -> float:
        """Spectral deficiency: 1 - gap."""
        return 1.0 - self.gap

    @property
    def expansion_entropy(self) -> float:
        """Expansion entropy: -log2(deficiency). Only defined for gap < 1."""
        if self.gap >= 1.0:
            return float('inf')
        return -math.log2(self.deficiency)


def tensor_gap(eps1: float, eps2: float) -> float:
    """
    Tensor product gap formula.

    For two certificates with gaps eps1, eps2, the tensor product
    has gap eps1 + eps2 - eps1*eps2 = 1 - (1-eps1)*(1-eps2).

    This exceeds both components when both are in (0, 1].
    """
    return eps1 + eps2 - eps1 * eps2


def k_fold_tensor_gap(eps: float, k: int) -> float:
    """
    k-fold self-tensor gap: 1 - (1-eps)^k.

    After k rounds of self-tensoring, the spectral gap approaches 1.
    """
    return 1.0 - (1.0 - eps) ** k


def amplification_steps_needed(eps: float, target_gap: float) -> int:
    """
    Compute the minimum k such that k-fold tensor gap exceeds target_gap.

    Uses the formula: k >= ceil(log(1-target_gap) / log(1-eps)).
    """
    if eps <= 0 or eps > 1:
        raise ValueError(f"Base gap must be in (0, 1], got {eps}")
    if target_gap <= 0 or target_gap >= 1:
        raise ValueError(f"Target gap must be in (0, 1), got {target_gap}")
    if eps >= target_gap:
        return 1
    deficiency_ratio = math.log(1 - target_gap) / math.log(1 - eps)
    return math.ceil(deficiency_ratio)


def gap_saturation_bound(eps: float, k: int) -> float:
    """
    The exponential upper bound on deficiency: exp(-k * eps).

    By the Gap Saturation Theorem: (1-eps)^k <= exp(-k*eps).
    """
    return math.exp(-k * eps)


def code_distance_bound(gap: float, inner_dist: float, block_length: int) -> float:
    """
    Code distance lower bound from expansion.

    For an expander code with spectral gap `gap`, inner code distance
    `inner_dist`, and block length `block_length`, the minimum distance
    is at least (inner_dist - (1 - gap)) * block_length.

    Returns positive value when in the expansion regime (1 - gap < inner_dist).
    """
    return (inner_dist - (1.0 - gap)) * block_length


def classify_gap(gap: float) -> str:
    """Classify a spectral gap into weak/moderate/strong regime."""
    if gap < 1/3:
        return "weak"
    elif gap < 2/3:
        return "moderate"
    else:
        return "strong"


def mixing_time(gap: float, target_error: float) -> int:
    """
    Compute mixing time: minimum k such that (1-gap)^k < target_error.

    Uses k >= ceil(log(target_error) / log(1-gap)).
    """
    if gap <= 0 or gap > 1:
        raise ValueError(f"Gap must be in (0, 1], got {gap}")
    if target_error <= 0:
        raise ValueError(f"Target error must be positive, got {target_error}")
    if gap == 1.0:
        return 1
    return math.ceil(math.log(target_error) / math.log(1 - gap))


def build_certificate_chain(
    base_gap: float,
    base_size: int,
    base_degree: int,
    num_steps: int,
    field_growth_factor: int = 2
) -> List[ExpansionCertificate]:
    """
    Build a certificate chain modeling Sp_2n(F_q) as q grows.

    The gap grows as 1 - C/q where C is determined by the base gap.
    """
    C = (1.0 - base_gap) * base_size  # Effective constant
    chain: List[ExpansionCertificate] = []
    for i in range(num_steps):
        q = base_size * (field_growth_factor ** i)
        gap_i = min(1.0 - C / q, 0.999) if q > C else base_gap
        chain.append(ExpansionCertificate(
            gap=gap_i,
            size=q,
            degree=base_degree
        ))
    return chain


def amplification_trajectory(
    eps: float, max_k: int
) -> List[Tuple[int, float, float, str]]:
    """
    Compute the amplification trajectory.

    Returns list of (k, gap, deficiency, regime) tuples.
    """
    trajectory: List[Tuple[int, float, float, str]] = []
    for k in range(max_k + 1):
        gap = k_fold_tensor_gap(eps, k)
        deficiency = 1.0 - gap
        regime = classify_gap(gap)
        trajectory.append((k, gap, deficiency, regime))
    return trajectory


def verify_saturation_conjecture(
    eps_values: List[float],
    max_k: int
) -> List[Tuple[float, int, float, float, bool]]:
    """
    Verify the Gap Saturation Conjecture for given parameters.

    Returns list of (eps, k, actual_deficiency, bound, satisfied) tuples.
    """
    results: List[Tuple[float, int, float, float, bool]] = []
    for eps in eps_values:
        for k in range(max_k + 1):
            actual = (1.0 - eps) ** k
            bound = gap_saturation_bound(eps, k)
            satisfied = actual <= bound + 1e-15  # numerical tolerance
            results.append((eps, k, actual, bound, satisfied))
    return results
