#!/usr/bin/env python3
"""
Algorithms for Counterpoint Category Theory.
Type-hinted implementations of the core mathematical structures.
"""

from typing import List, Set, Tuple, Optional, Dict
from enum import Enum, auto
from dataclasses import dataclass


class ConsInterval(Enum):
    """Consonant interval classes in first-species counterpoint."""
    UNISON = 0   # Perfect
    MIN3 = 3     # Imperfect
    MAJ3 = 4     # Imperfect
    FIFTH = 7    # Perfect
    MIN6 = 8     # Imperfect
    MAJ6 = 9     # Imperfect

    @property
    def is_perfect(self) -> bool:
        return self in (ConsInterval.UNISON, ConsInterval.FIFTH)

    @property
    def is_imperfect(self) -> bool:
        return not self.is_perfect

    @property
    def complement(self) -> 'ConsInterval':
        """The complement involution: swaps m3↔M6, M3↔m6."""
        mapping = {
            ConsInterval.UNISON: ConsInterval.UNISON,
            ConsInterval.MIN3: ConsInterval.MAJ6,
            ConsInterval.MAJ3: ConsInterval.MIN6,
            ConsInterval.FIFTH: ConsInterval.FIFTH,
            ConsInterval.MIN6: ConsInterval.MAJ3,
            ConsInterval.MAJ6: ConsInterval.MIN3,
        }
        return mapping[self]

    @property
    def name_short(self) -> str:
        names = {0: "U", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
        return names[self.value]


class MotionType(Enum):
    """Types of relative motion between two voices."""
    PARALLEL = auto()
    SIMILAR = auto()
    CONTRARY = auto()
    OBLIQUE = auto()


@dataclass(frozen=True)
class VLTransition:
    """A voice leading transition."""
    source: ConsInterval
    target: ConsInterval
    motion: MotionType

    @property
    def is_valid(self) -> bool:
        """Check first-species validity."""
        if self.target.is_perfect and self.motion in (MotionType.PARALLEL, MotionType.SIMILAR):
            return False
        return True


def all_consonant_intervals() -> List[ConsInterval]:
    """Return all 6 consonant interval classes."""
    return list(ConsInterval)


def all_motion_types() -> List[MotionType]:
    """Return all 4 motion types."""
    return list(MotionType)


def counterpoint_hom(src: ConsInterval, tgt: ConsInterval) -> List[MotionType]:
    """Compute the hom-set from src to tgt: valid motion types."""
    return [m for m in MotionType if VLTransition(src, tgt, m).is_valid]


def receptivity(interval: ConsInterval) -> int:
    """Number of valid approach motions to this interval."""
    return len(counterpoint_hom(ConsInterval.UNISON, interval))


def interval_distance(i: ConsInterval, j: ConsInterval) -> int:
    """Minimum semitone distance between two consonant intervals (mod 12)."""
    return min((j.value - i.value) % 12, (i.value - j.value) % 12)


def consonant_add(i: ConsInterval, j: ConsInterval) -> Optional[ConsInterval]:
    """Add two consonant intervals mod 12; return result if consonant."""
    result = (i.value + j.value) % 12
    consonant_values = {c.value for c in ConsInterval}
    if result in consonant_values:
        return ConsInterval(result)
    return None


def consonance_adjacent(i: ConsInterval, j: ConsInterval) -> bool:
    """Check if two intervals sum (mod 12) to a consonance."""
    return consonant_add(i, j) is not None


def enumerate_valid_transitions() -> List[VLTransition]:
    """Enumerate all valid first-species transitions."""
    result = []
    for src in ConsInterval:
        for tgt in ConsInterval:
            for m in MotionType:
                t = VLTransition(src, tgt, m)
                if t.is_valid:
                    result.append(t)
    return result


def restriction_factor() -> Tuple[int, int]:
    """Compute the restriction factor as (valid, total)."""
    valid = len(enumerate_valid_transitions())
    total = len(ConsInterval) ** 2 * len(MotionType)
    return valid, total


def consonant_closure_ratio() -> Tuple[int, int]:
    """Fraction of ordered pairs summing to a consonance."""
    count = sum(1 for i in ConsInterval for j in ConsInterval
                if consonance_adjacent(i, j))
    total = len(ConsInterval) ** 2
    return count, total


def is_consonance_preserving(t: int) -> bool:
    """Check if transposition by t preserves the consonance set."""
    consonant_values = {c.value for c in ConsInterval}
    return all((s + t) % 12 in consonant_values for s in consonant_values)


def stabilizer() -> List[int]:
    """Compute the stabilizer of the consonance set under transposition."""
    return [t for t in range(12) if is_consonance_preserving(t)]


def adjacency_matrix() -> List[List[int]]:
    """Compute the consonance adjacency matrix."""
    intervals = list(ConsInterval)
    n = len(intervals)
    matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if consonance_adjacent(intervals[i], intervals[j]):
                matrix[i][j] = 1
    return matrix


def transition_matrix() -> Dict[str, List[List[int]]]:
    """Compute the transition count matrix (how many valid motions from i to j)."""
    intervals = list(ConsInterval)
    n = len(intervals)
    matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            matrix[i][j] = len(counterpoint_hom(intervals[i], intervals[j]))
    return {
        "labels": [c.name_short for c in intervals],
        "matrix": matrix
    }


if __name__ == "__main__":
    # Verify key theorems computationally
    print("Verifying theorems...")

    # Target-only dependence
    for tgt in ConsInterval:
        homs = [frozenset(counterpoint_hom(src, tgt)) for src in ConsInterval]
        assert len(set(homs)) == 1, f"Target-only dependence fails for {tgt}"
    print("✓ Target-only dependence verified")

    # Complement involution
    for i in ConsInterval:
        assert i.complement.complement == i
    print("✓ Complement involution verified")

    # Exact counting
    v, t = restriction_factor()
    assert v == 120 and t == 144
    print(f"✓ Restriction factor: {v}/{t} = 5/6")

    # Ramsey property
    from itertools import combinations
    for a, b, c in combinations(ConsInterval, 3):
        assert (consonance_adjacent(a, b) or
                consonance_adjacent(b, c) or
                consonance_adjacent(a, c))
    print("✓ Ramsey property verified")

    # Rigidity
    assert stabilizer() == [0]
    print("✓ Trivial stabilizer verified")

    # Closure ratio
    cn, ct = consonant_closure_ratio()
    assert cn == 23
    print(f"✓ Consonant closure ratio: {cn}/{ct}")

    print("\nAll theorems verified!")
