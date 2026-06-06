#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of the counterpoint category algorithms.

Provides:
  1. CounterpointCategory: enumeration and classification of transitions
  2. PathEnumerator: counting and generating valid counterpoint paths
  3. SymmetryAnalyzer: complement involution and order analysis
  4. DiatonicSpecializer: diatonic scale consonance analysis
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import List, Tuple, Set, Dict, Iterator


class ConsInterval(Enum):
    """The six consonant interval classes (mod octave)."""
    P1 = 0   # Perfect unison
    m3 = 3   # Minor third
    M3 = 4   # Major third
    P5 = 7   # Perfect fifth
    m6 = 8   # Minor sixth
    M6 = 9   # Major sixth

    @property
    def is_perfect(self) -> bool:
        return self in (ConsInterval.P1, ConsInterval.P5)

    @property
    def is_imperfect(self) -> bool:
        return not self.is_perfect

    @property
    def complement(self) -> 'ConsInterval':
        """The octave complement involution."""
        return {
            ConsInterval.P1: ConsInterval.P1,
            ConsInterval.m3: ConsInterval.M6,
            ConsInterval.M3: ConsInterval.m6,
            ConsInterval.P5: ConsInterval.P5,
            ConsInterval.m6: ConsInterval.M3,
            ConsInterval.M6: ConsInterval.m3,
        }[self]

    @property
    def consonance_rank(self) -> int:
        """Higher = more consonant."""
        return {
            ConsInterval.m6: 0, ConsInterval.M6: 1,
            ConsInterval.m3: 2, ConsInterval.M3: 3,
            ConsInterval.P5: 4, ConsInterval.P1: 5,
        }[self]


class MotionType(Enum):
    """The four types of contrapuntal motion."""
    PARALLEL = auto()
    SIMILAR = auto()
    CONTRARY = auto()
    OBLIQUE = auto()


@dataclass(frozen=True)
class CPTransition:
    """A counterpoint transition: (source, target, motion)."""
    source: ConsInterval
    target: ConsInterval
    motion: MotionType

    def is_permitted(self) -> bool:
        """Standard rule: no parallel motion to perfect consonances."""
        return not (self.motion == MotionType.PARALLEL and self.target.is_perfect)

    def is_strictly_permitted(self) -> bool:
        """Strict rule: no parallel/similar to perfect consonances."""
        return not (
            self.motion in (MotionType.PARALLEL, MotionType.SIMILAR)
            and self.target.is_perfect
        )


class CounterpointCategory:
    """The finite category of first-species counterpoint transitions."""

    def __init__(self, strict: bool = False) -> None:
        self.strict = strict
        self._transitions: List[CPTransition] = []
        self._permitted: List[CPTransition] = []
        self._forbidden: List[CPTransition] = []
        self._build()

    def _build(self) -> None:
        for s in ConsInterval:
            for t in ConsInterval:
                for m in MotionType:
                    tr = CPTransition(s, t, m)
                    self._transitions.append(tr)
                    check = tr.is_strictly_permitted() if self.strict else tr.is_permitted()
                    if check:
                        self._permitted.append(tr)
                    else:
                        self._forbidden.append(tr)

    @property
    def total_count(self) -> int:
        return len(self._transitions)

    @property
    def permitted_count(self) -> int:
        return len(self._permitted)

    @property
    def forbidden_count(self) -> int:
        return len(self._forbidden)

    def permitted_transitions(self) -> List[CPTransition]:
        return list(self._permitted)

    def forbidden_transitions(self) -> List[CPTransition]:
        return list(self._forbidden)

    def fiber_size(self, target: ConsInterval) -> int:
        """Number of permitted motion types for a given target."""
        return sum(
            1 for m in MotionType
            if (CPTransition(ConsInterval.P1, target, m).is_strictly_permitted()
                if self.strict
                else CPTransition(ConsInterval.P1, target, m).is_permitted())
        )

    def adjacency_matrix(self, motion: MotionType) -> Dict[Tuple[ConsInterval, ConsInterval], bool]:
        """Which source-target pairs are reachable via a specific motion type."""
        result: Dict[Tuple[ConsInterval, ConsInterval], bool] = {}
        for s in ConsInterval:
            for t in ConsInterval:
                tr = CPTransition(s, t, motion)
                check = tr.is_strictly_permitted() if self.strict else tr.is_permitted()
                result[(s, t)] = check
        return result


class PathEnumerator:
    """Enumerate and count valid counterpoint paths of given length."""

    def __init__(self, strict: bool = False) -> None:
        self.strict = strict

    def is_valid_step(self, s: ConsInterval, t: ConsInterval, m: MotionType) -> bool:
        tr = CPTransition(s, t, m)
        return tr.is_strictly_permitted() if self.strict else tr.is_permitted()

    def count_paths(self, length: int) -> int:
        """Count valid paths of given length (number of transitions)."""
        if length == 0:
            return len(ConsInterval)
        intervals = list(ConsInterval)
        motions = list(MotionType)
        count = 0
        # For length 1, count valid single transitions
        if length == 1:
            for s in intervals:
                for t in intervals:
                    for m in motions:
                        if self.is_valid_step(s, t, m):
                            count += 1
            return count
        # For length 2
        if length == 2:
            for i1 in intervals:
                for i2 in intervals:
                    for i3 in intervals:
                        for m1 in motions:
                            for m2 in motions:
                                if (self.is_valid_step(i1, i2, m1) and
                                    self.is_valid_step(i2, i3, m2)):
                                    count += 1
            return count
        raise ValueError(f"Length {length} not efficiently supported")

    def passage_rate(self, length: int) -> float:
        """Fraction of potential paths that are valid."""
        valid = self.count_paths(length)
        total = len(ConsInterval) ** (length + 1) * len(MotionType) ** length
        return valid / total


class SymmetryAnalyzer:
    """Analyze symmetries of the counterpoint transition system."""

    @staticmethod
    def fixed_points() -> List[ConsInterval]:
        """Intervals fixed by the complement involution."""
        return [i for i in ConsInterval if i.complement == i]

    @staticmethod
    def orbits() -> List[Tuple[ConsInterval, ConsInterval]]:
        """Non-trivial orbits of the complement involution."""
        seen: Set[ConsInterval] = set()
        orbits = []
        for i in ConsInterval:
            if i not in seen and i.complement != i:
                orbits.append((i, i.complement))
                seen.add(i)
                seen.add(i.complement)
        return orbits

    @staticmethod
    def verify_order_reversing() -> bool:
        """Check complement reverses order on imperfect consonances."""
        imperfect = [i for i in ConsInterval if i.is_imperfect]
        for i in imperfect:
            for j in imperfect:
                if i.consonance_rank <= j.consonance_rank:
                    if not (j.complement.consonance_rank <= i.complement.consonance_rank):
                        return False
        return True


class DiatonicSpecializer:
    """Analyze consonance in specific diatonic scales."""

    SCALES: Dict[str, List[int]] = {
        "C_major": [0, 2, 4, 5, 7, 9, 11],
        "A_minor": [9, 11, 0, 2, 4, 5, 7],
        "G_major": [7, 9, 11, 0, 2, 4, 6],
    }

    CONSONANT_SEMITONES = {i.value for i in ConsInterval}

    @classmethod
    def consonant_pairs(cls, scale_name: str) -> List[Tuple[int, int]]:
        """Find all consonant pairs in a given scale."""
        scale = cls.SCALES[scale_name]
        pairs = []
        for i, d1 in enumerate(scale):
            for j, d2 in enumerate(scale):
                interval = (d2 - d1) % 12
                if interval in cls.CONSONANT_SEMITONES:
                    pairs.append((i, j))
        return pairs

    @classmethod
    def consonance_density(cls, scale_name: str) -> float:
        """Fraction of dyads that are consonant."""
        pairs = cls.consonant_pairs(scale_name)
        total = len(cls.SCALES[scale_name]) ** 2
        return len(pairs) / total


if __name__ == "__main__":
    # Demo
    cat = CounterpointCategory(strict=False)
    print(f"Standard: {cat.permitted_count} permitted, {cat.forbidden_count} forbidden")

    cat_strict = CounterpointCategory(strict=True)
    print(f"Strict:   {cat_strict.permitted_count} permitted, {cat_strict.forbidden_count} forbidden")

    pe = PathEnumerator()
    print(f"Length-2 paths: {pe.count_paths(2)}")
    print(f"Passage rate:   {pe.passage_rate(2):.4f}")

    sa = SymmetryAnalyzer()
    print(f"Fixed points:   {[i.name for i in sa.fixed_points()]}")
    print(f"Orbits:         {[(a.name, b.name) for a, b in sa.orbits()]}")
    print(f"Order-reversing: {sa.verify_order_reversing()}")

    ds = DiatonicSpecializer()
    for scale in ["C_major", "A_minor"]:
        density = ds.consonance_density(scale)
        pairs = len(ds.consonant_pairs(scale))
        print(f"{scale}: {pairs}/49 consonant pairs ({density:.1%})")
