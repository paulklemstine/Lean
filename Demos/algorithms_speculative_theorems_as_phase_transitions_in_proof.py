"""
Algorithms for Proof Density Phase Transition Analysis

Type-hinted implementations of the core algorithms from the
ProofDensitySpace framework.
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional
import math


@dataclass
class ProofDensitySpace:
    """A proof density space capturing the counting structure of a formal system.

    Attributes:
        b: Alphabet size (≥ 2)
        stmt_count: Function mapping length n to number of statements
        provable_count: Function mapping length n to number of provable statements
        proof_bound: Function mapping length n to maximum proof length
    """
    b: int
    stmt_count: Callable[[int], int]
    provable_count: Callable[[int], int]
    proof_bound: Callable[[int], int]

    def __post_init__(self) -> None:
        assert self.b >= 2, f"Alphabet size must be ≥ 2, got {self.b}"


def unprovability_gap(pds: ProofDensitySpace, n: int) -> int:
    """Compute the unprovability gap: stmtCount(n) - provableCount(n)."""
    return max(0, pds.stmt_count(n) - pds.provable_count(n))


def provability_density(pds: ProofDensitySpace, n: int) -> float:
    """Compute the provability density ρ(n) = provableCount(n) / stmtCount(n)."""
    sc = pds.stmt_count(n)
    if sc == 0:
        return 1.0
    return pds.provable_count(n) / sc


def provability_ratio(pds: ProofDensitySpace, n: int) -> float:
    """Compute the provability ratio: provableCount(n) / b^n."""
    denom = pds.b ** n
    if denom == 0:
        return 1.0
    return pds.provable_count(n) / denom


def proof_dimension(pds: ProofDensitySpace, n: int) -> float:
    """Compute the proof dimension at scale n: proofBound(n) / n."""
    if n == 0:
        return 1.0
    return pds.proof_bound(n) / n


def find_completeness_threshold(
    pds: ProofDensitySpace,
    max_n: int = 1000
) -> Optional[int]:
    """Find the completeness threshold n_c.

    Returns the largest n such that provableCount(k) = stmtCount(k)
    for all k ≤ n, or None if no threshold found within max_n.

    Algorithm:
        1. Scan from n=0 upward
        2. At each n, check if provableCount(n) < stmtCount(n)
        3. If so, n-1 is the threshold (if n > 0)
    """
    for n in range(max_n + 1):
        if pds.provable_count(n) < pds.stmt_count(n):
            return max(0, n - 1)
    return None


def compute_gap_cascade(
    pds: ProofDensitySpace,
    start_n: int,
    num_levels: int
) -> List[Tuple[int, int]]:
    """Compute the gap amplification cascade.

    Returns list of (n, lower_bound_on_gap) pairs showing
    how the unprovability gap grows level by level.

    Algorithm:
        For each level k from 0 to num_levels:
            gap_lower_bound(n + k) ≥ b^k * gap(n)
    """
    initial_gap = unprovability_gap(pds, start_n)
    result: List[Tuple[int, int]] = []
    for k in range(num_levels + 1):
        n = start_n + k
        theoretical_lower = pds.b ** k * initial_gap
        actual_gap = unprovability_gap(pds, n)
        result.append((n, max(theoretical_lower, actual_gap)))
    return result


def detect_phase_transition(
    pds: ProofDensitySpace,
    max_n: int = 100,
    threshold: float = 0.01
) -> List[int]:
    """Detect phase transitions as points where density drops sharply.

    Returns list of n values where |ρ(n) - ρ(n-1)| > threshold.

    Algorithm:
        Scan through lengths, compute density changes,
        flag those exceeding the threshold.
    """
    transitions: List[int] = []
    prev_density = provability_density(pds, 0)
    for n in range(1, max_n + 1):
        curr_density = provability_density(pds, n)
        if abs(curr_density - prev_density) > threshold:
            transitions.append(n)
        prev_density = curr_density
    return transitions


def estimate_hausdorff_dimension(
    pds: ProofDensitySpace,
    scales: List[int]
) -> float:
    """Estimate the Hausdorff dimension of the set of provable statements.

    Uses the box-counting method:
        d_H ≈ lim_{n→∞} log(provableCount(n)) / (n * log(b))

    The proof dimension proofBound(n)/n gives an upper bound on d_H.
    """
    if not scales:
        return 0.0
    log_b = math.log(pds.b)
    dimensions = []
    for n in scales:
        pc = pds.provable_count(n)
        if pc > 0 and n > 0:
            d = math.log(pc) / (n * log_b)
            dimensions.append(d)
    return sum(dimensions) / len(dimensions) if dimensions else 0.0


def verify_counting_incompleteness(
    pds: ProofDensitySpace,
    n: int
) -> Tuple[bool, str]:
    """Verify the counting incompleteness theorem at scale n.

    Checks whether b^proofBound(n) < stmtCount(n), which implies
    the existence of unprovable statements.

    Returns (is_incomplete, explanation).
    """
    proof_space = pds.b ** pds.proof_bound(n)
    stmt_space = pds.stmt_count(n)

    if proof_space < stmt_space:
        gap = stmt_space - proof_space
        return True, (
            f"INCOMPLETE at n={n}: "
            f"proof space ({proof_space:,}) < statement space ({stmt_space:,}), "
            f"gap = {gap:,} unprovable statements"
        )
    else:
        return False, (
            f"Cannot certify incompleteness at n={n}: "
            f"proof space ({proof_space:,}) ≥ statement space ({stmt_space:,})"
        )


if __name__ == "__main__":
    # Example: A formal system where proofs grow sublinearly
    pds = ProofDensitySpace(
        b=2,
        stmt_count=lambda n: 2 ** n,
        provable_count=lambda n: min(2 ** n, 2 ** (n // 2 + 3)),
        proof_bound=lambda n: n // 2 + 3
    )

    print("=== Proof Density Space Analysis ===\n")

    nc = find_completeness_threshold(pds)
    print(f"Completeness threshold: n_c = {nc}")

    print("\nPhase transition detection:")
    transitions = detect_phase_transition(pds, max_n=30)
    print(f"  Transitions at: {transitions}")

    print("\nCounting incompleteness verification:")
    for n in [5, 10, 15, 20]:
        incomplete, explanation = verify_counting_incompleteness(pds, n)
        print(f"  {explanation}")

    print("\nHausdorff dimension estimate:")
    scales = list(range(10, 101, 10))
    d_H = estimate_hausdorff_dimension(pds, scales)
    print(f"  d_H ≈ {d_H:.4f}")

    print("\nGap cascade from n=10:")
    cascade = compute_gap_cascade(pds, 10, 10)
    for n, gap in cascade:
        print(f"  n={n:>3}: gap ≥ {gap:>12,}")
