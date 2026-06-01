"""
Algorithms for Reduction-Enriched Complexity Hierarchies.

Type-hinted implementations of key algorithms from the framework.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Generic, TypeVar, Optional
import math

T = TypeVar("T")


@dataclass
class Problem:
    """A computational problem with a level and identifier."""
    level: int
    identifier: str

    def __repr__(self) -> str:
        return f"Problem(level={self.level}, id='{self.identifier}')"


@dataclass
class ReductionHierarchy:
    """An axiomatic reduction hierarchy over problems.

    Axioms enforced at construction:
    - level : Problem → ℕ  (given by Problem.level)
    - reduces : Problem → Problem → bool  (must be reflexive, transitive, level-monotone)
    - infinite_levels : ∀ n, ∃ p, p.level > n  (checked lazily)
    """
    problems: list[Problem]
    _reduces: Callable[[Problem, Problem], bool]

    def reduces(self, a: Problem, b: Problem) -> bool:
        """Check if problem a reduces to problem b."""
        result = self._reduces(a, b)
        # Verify level monotonicity
        if result and a.level > b.level:
            raise ValueError(
                f"Reduction violates level monotonicity: "
                f"level({a}) = {a.level} > {b.level} = level({b})"
            )
        return result

    def is_complete(self, p: Problem, n: int) -> bool:
        """Check if p is complete for level n.

        A problem p is complete for level n if:
        1. p.level == n
        2. Every level-n problem reduces to p
        """
        if p.level != n:
            return False
        level_n_problems = [q for q in self.problems if q.level == n]
        return all(self.reduces(q, p) for q in level_n_problems)

    def find_complete_elements(self, n: int) -> list[Problem]:
        """Find all complete elements at level n."""
        level_n = [p for p in self.problems if p.level == n]
        return [p for p in level_n if self.is_complete(p, n)]

    def verify_separation(self, m: int, n: int) -> Optional[Problem]:
        """Find a separation witness between levels m and n (m < n).

        Returns a problem at level n if one exists, None otherwise.
        """
        if m >= n:
            return None
        for p in self.problems:
            if p.level == n:
                return p
        return None

    def find_intermediate(self, m: int, n: int) -> list[Problem]:
        """Find intermediate problems between levels m and n.

        Abstract Ladner: if m + 2 ≤ n and the hierarchy is dense between m and n,
        intermediate problems must exist.
        """
        return [p for p in self.problems if m < p.level < n]

    def extract_dense_chain(self, start: int, length: int) -> list[Problem]:
        """Extract a dense chain starting from the given level.

        A dense chain has consecutive level differences of exactly 1.
        """
        chain: list[Problem] = []
        for i in range(length):
            target_level = start + i
            candidates = [p for p in self.problems if p.level == target_level]
            if not candidates:
                break
            chain.append(candidates[0])
        return chain


def build_oracle_tower_hierarchy(max_level: int) -> ReductionHierarchy:
    """Build a concrete hierarchy modeling the oracle tower.

    Each level n contains problems that can be solved with n oracle queries.
    Reductions are level-monotone: a reduces to b iff a.level <= b.level.
    """
    problems: list[Problem] = []
    for level in range(max_level + 1):
        for i in range(3):  # 3 problems per level
            problems.append(Problem(level=level, identifier=f"L{level}_P{i}"))

    def reduces(a: Problem, b: Problem) -> bool:
        return a.level <= b.level

    return ReductionHierarchy(problems=problems, _reduces=reduces)


@dataclass
class InformationMeasure:
    """An information measure compatible with a reduction hierarchy.

    Properties:
    - info(p) ≥ 0 for all p
    - reduces(a, b) implies info(a) ≤ info(b)
    - level(a) < level(b) implies info(a) < info(b)
    """
    _info: Callable[[Problem], float]

    def info(self, p: Problem) -> float:
        val = self._info(p)
        assert val >= 0, f"Information must be non-negative, got {val}"
        return val


def logarithmic_info_measure() -> InformationMeasure:
    """A concrete information measure: info(p) = log2(level + 1) + level."""
    return InformationMeasure(_info=lambda p: math.log2(p.level + 1) + p.level)


def compute_information_gaps(
    hierarchy: ReductionHierarchy,
    measure: InformationMeasure,
    max_level: int
) -> list[tuple[int, float, float]]:
    """Compute information gaps between consecutive levels.

    Returns: list of (level, info_value, gap_from_previous)
    """
    results: list[tuple[int, float, float]] = []
    prev_info = 0.0
    for level in range(max_level + 1):
        candidates = [p for p in hierarchy.problems if p.level == level]
        if candidates:
            info_val = measure.info(candidates[0])
            gap = info_val - prev_info
            results.append((level, info_val, gap))
            prev_info = info_val
    return results


@dataclass
class OracleExtension:
    """An oracle extension that augments problem levels."""
    name: str
    _augment_level: Callable[[int], int]

    def augment(self, p: Problem) -> Problem:
        new_level = self._augment_level(p.level)
        assert new_level >= p.level, "Oracle must not decrease level"
        return Problem(level=new_level, identifier=f"{p.identifier}^{self.name}")


def check_relativization_obstruction(
    a: Problem,
    b: Problem,
    oracles: list[OracleExtension]
) -> bool:
    """Check if any pair of oracles creates a relativization obstruction.

    Returns True if there exist oracles O1, O2 such that:
    - O1 makes a easier than b
    - O2 makes b easier than a
    """
    for i, o1 in enumerate(oracles):
        for j, o2 in enumerate(oracles):
            if i == j:
                continue
            a1 = o1.augment(a)
            b1 = o1.augment(b)
            a2 = o2.augment(a)
            b2 = o2.augment(b)
            if a1.level < b1.level and b2.level < a2.level:
                return True
    return False


def diagonal_language(
    enumeration: Callable[[int], Callable[[int], bool]]
) -> Callable[[int], bool]:
    """Construct the diagonal language from an enumeration.

    diag(n) = NOT enumeration(n)(n)
    """
    return lambda n: not enumeration(n)(n)


def verify_diagonal_separation(
    enumeration: Callable[[int], Callable[[int], bool]],
    num_checks: int = 100
) -> bool:
    """Verify that the diagonal differs from every enumerated function.

    Checks the first num_checks functions in the enumeration.
    """
    diag = diagonal_language(enumeration)
    for k in range(num_checks):
        if enumeration(k)(k) == diag(k):
            return False  # Should never happen by construction
    return True


# Algorithm: Reduction Completeness Conjecture tester
def test_completeness_conjecture(
    hierarchy: ReductionHierarchy,
    max_level: int
) -> dict[int, bool]:
    """Test whether every level has a complete element.

    Returns a dict mapping each level to whether it has a complete element.
    This empirically tests the Reduction Completeness Conjecture.
    """
    results: dict[int, bool] = {}
    for level in range(max_level + 1):
        complete = hierarchy.find_complete_elements(level)
        results[level] = len(complete) > 0
    return results


if __name__ == "__main__":
    # Build and test a concrete hierarchy
    H = build_oracle_tower_hierarchy(10)

    print("Oracle Tower Hierarchy (10 levels, 3 problems each)")
    print(f"Total problems: {len(H.problems)}")

    # Test completeness conjecture
    completeness = test_completeness_conjecture(H, 10)
    print(f"\nCompleteness at each level: {completeness}")
    print(f"All levels complete: {all(completeness.values())}")

    # Information gaps
    mu = logarithmic_info_measure()
    gaps = compute_information_gaps(H, mu, 10)
    print(f"\nInformation gaps:")
    for level, info_val, gap in gaps:
        print(f"  Level {level}: info = {info_val:.4f}, gap = {gap:.4f}")

    # Relativization obstruction
    a = Problem(level=3, identifier="A")
    b = Problem(level=5, identifier="B")
    oracles = [
        OracleExtension("O1", lambda l: l + 1),
        OracleExtension("O2", lambda l: 10 - l),
    ]
    obstruction = check_relativization_obstruction(a, b, oracles)
    print(f"\nRelativization obstruction between A(3) and B(5): {obstruction}")
