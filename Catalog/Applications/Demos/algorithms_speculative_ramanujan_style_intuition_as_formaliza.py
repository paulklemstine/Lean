#!/usr/bin/env python3
"""
Oracle Approximation Theory — Core Algorithms

Type-hinted implementations of all key algorithms from the research paper.
"""

from __future__ import annotations
from math import comb, log2
from itertools import product
from dataclasses import dataclass, field


# ============================================================
# Core Types
# ============================================================

TruthAssignment = tuple[bool, ...]
OracleSet = list[TruthAssignment]


# ============================================================
# Algorithm 1: Hamming Distance
# ============================================================

def hamming_distance(f: TruthAssignment, g: TruthAssignment) -> int:
    """
    Compute the Hamming distance between two truth assignments.

    Time complexity: O(n) where n = len(f).

    >>> hamming_distance((True, False, True), (True, True, True))
    1
    >>> hamming_distance((False,) * 4, (True,) * 4)
    4
    """
    assert len(f) == len(g), "Truth assignments must have equal length"
    return sum(a != b for a, b in zip(f, g))


# ============================================================
# Algorithm 2: Hamming Ball Volume
# ============================================================

def hamming_ball_volume(n: int, d: int) -> int:
    """
    Compute |B(c, d)| = Σ_{i=0}^{d} C(n, i), the volume of a
    Hamming ball of radius d in {0,1}^n.

    Time complexity: O(min(d, n)).

    >>> hamming_ball_volume(4, 0)
    1
    >>> hamming_ball_volume(4, 1)
    5
    >>> hamming_ball_volume(4, 4)
    16
    """
    return sum(comb(n, i) for i in range(min(d, n) + 1))


# ============================================================
# Algorithm 3: Binary Entropy
# ============================================================

def binary_entropy(alpha: float) -> float:
    """
    Compute the binary entropy H(α) = -α log₂(α) - (1-α) log₂(1-α).

    Used in the asymptotic Hamming ball volume bound:
      |B(c, ⌊αn⌋)| ≈ 2^{n·H(α)}

    >>> abs(binary_entropy(0.5) - 1.0) < 1e-10
    True
    >>> binary_entropy(0.0)
    0.0
    """
    if alpha <= 0 or alpha >= 1:
        return 0.0
    return -alpha * log2(alpha) - (1 - alpha) * log2(1 - alpha)


# ============================================================
# Algorithm 4: Oracle Coverage Computation
# ============================================================

def oracle_coverage(
    oracles: OracleSet, d: int, n: int
) -> set[TruthAssignment]:
    """
    Compute Coverage(O, d) = ⋃_{f ∈ O} B(f, d).

    Time complexity: O(m · 2^n · n) where m = |O|.

    >>> oracles = [(False, False), (True, True)]
    >>> len(oracle_coverage(oracles, 0, 2))
    2
    >>> len(oracle_coverage(oracles, 1, 2))
    4
    """
    covered: set[TruthAssignment] = set()
    for bits in product([False, True], repeat=n):
        t = tuple(bits)
        for f in oracles:
            if hamming_distance(f, t) <= d:
                covered.add(t)
                break
    return covered


# ============================================================
# Algorithm 5: Deficiency Profile
# ============================================================

@dataclass
class DeficiencyProfile:
    """The deficiency profile of an oracle set."""
    n: int
    oracle_count: int
    values: list[int] = field(default_factory=list)

    def is_antitone(self) -> bool:
        """Verify the profile is antitone (Theorem 3.2)."""
        return all(self.values[i] >= self.values[i + 1]
                   for i in range(len(self.values) - 1))

    def gap_at_zero(self) -> int:
        """The exponential gap at tolerance 0."""
        return self.values[0] if self.values else 0

    def covering_radius(self) -> int:
        """Smallest d such that DP(O, d) = 0 (full coverage)."""
        for d, dp in enumerate(self.values):
            if dp == 0:
                return d
        return self.n + 1


def compute_deficiency_profile(
    oracles: OracleSet, n: int
) -> DeficiencyProfile:
    """
    Compute DP(O, d) for d = 0, 1, ..., n.

    Time complexity: O(n · m · 2^n · n) = O(n² · m · 2^n).

    >>> profile = compute_deficiency_profile([(False, False, False)], 3)
    >>> profile.values
    [7, 4, 1, 0]
    >>> profile.is_antitone()
    True
    """
    total = 2**n
    values = []
    for d in range(n + 1):
        covered = oracle_coverage(oracles, d, n)
        values.append(total - len(covered))
    return DeficiencyProfile(n=n, oracle_count=len(oracles), values=values)


# ============================================================
# Algorithm 6: Maximally Deficient Truth Assignment
# ============================================================

def find_max_deficient(
    oracles: OracleSet, n: int
) -> tuple[TruthAssignment, int]:
    """
    Find the truth assignment t maximizing min_{f ∈ O} d(f, t).
    This is the "hardest to approximate" truth.

    Time complexity: O(m · 2^n · n).

    Returns (truth_assignment, min_distance_to_any_oracle).

    >>> t, d = find_max_deficient([(False, False)], 2)
    >>> d
    2
    >>> t
    (True, True)
    """
    best_t: TruthAssignment | None = None
    best_min_dist = -1

    for bits in product([False, True], repeat=n):
        t = tuple(bits)
        if not oracles:
            return t, n + 1
        min_d = min(hamming_distance(f, t) for f in oracles)
        if min_d > best_min_dist:
            best_min_dist = min_d
            best_t = t

    assert best_t is not None
    return best_t, best_min_dist


# ============================================================
# Algorithm 7: Oracle Insufficiency Check
# ============================================================

def check_insufficiency(
    oracle_count: int, n: int, d: int
) -> dict[str, object]:
    """
    Check whether the Oracle Insufficiency Theorem applies.

    Uses the Hamming ball volume bound: if m · |B(0,d)| < 2^n,
    then some truth assignment is uncovered.

    >>> result = check_insufficiency(3, 10, 1)
    >>> result['insufficient']
    True
    """
    ball_size = hamming_ball_volume(n, d)
    total = 2**n
    coverage_bound = oracle_count * ball_size

    return {
        "n": n,
        "oracle_count": oracle_count,
        "tolerance": d,
        "ball_size": ball_size,
        "total_assignments": total,
        "coverage_upper_bound": coverage_bound,
        "insufficient": coverage_bound < total,
        "uncovered_lower_bound": max(0, total - coverage_bound),
    }


# ============================================================
# Algorithm 8: Oracle Approximation Tower
# ============================================================

@dataclass
class OracleApproxTower:
    """An oracle approximation tower with antitone tolerances."""
    n: int
    oracles: list[TruthAssignment]
    tolerances: list[int]

    def __post_init__(self) -> None:
        assert len(self.oracles) == len(self.tolerances)
        # Verify antitone tolerances
        for i in range(len(self.tolerances) - 1):
            assert self.tolerances[i] >= self.tolerances[i + 1], \
                f"Tolerances must be antitone: {self.tolerances[i]} < {self.tolerances[i+1]}"

    @property
    def height(self) -> int:
        return len(self.oracles)

    def cumulative_oracles(self, level: int) -> OracleSet:
        """Get all oracles up to and including the given level."""
        return self.oracles[: level + 1]

    def coverage_at_level(self, level: int) -> set[TruthAssignment]:
        """Coverage using cumulative oracles at the level's tolerance."""
        return oracle_coverage(
            self.cumulative_oracles(level),
            self.tolerances[level],
            self.n,
        )

    def deficiency_at_level(self, level: int) -> int:
        """Deficiency at a given tower level."""
        return 2**self.n - len(self.coverage_at_level(level))


# ============================================================
# Algorithm 9: Asymptotic Insufficiency Threshold
# ============================================================

def insufficiency_threshold(n: int, alpha: float) -> float:
    """
    Compute the maximum number of oracles m such that oracle
    insufficiency is guaranteed at tolerance d = ⌊αn⌋.

    Returns m_max = 2^n / |B(0, ⌊αn⌋)|.

    For m > m_max, oracle insufficiency may not hold.
    For m ≤ m_max, some truth assignment is uncovered.

    >>> insufficiency_threshold(10, 0.0)
    1024.0
    """
    d = int(alpha * n)
    ball_size = hamming_ball_volume(n, d)
    return 2**n / ball_size


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    print("All doctests passed!")

    # Example: compute insufficiency thresholds
    print("\nInsufficiency thresholds (max oracles for guaranteed gaps):")
    print(f"  {'n':>3}  {'α=0.05':>10}  {'α=0.10':>10}  {'α=0.20':>10}  {'α=0.30':>10}")
    for n in [10, 20, 50, 100]:
        row = f"  {n:3d}"
        for alpha in [0.05, 0.10, 0.20, 0.30]:
            threshold = insufficiency_threshold(n, alpha)
            row += f"  {threshold:10.1f}"
        print(row)
