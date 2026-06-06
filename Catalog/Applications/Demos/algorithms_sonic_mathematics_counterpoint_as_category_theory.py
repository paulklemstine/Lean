#!/usr/bin/env python3
"""
Counterpoint Category Theory — Algorithms

Type-hinted implementations of key algorithms for analyzing the
categorical structure of first-species counterpoint.
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
from enum import Enum, auto


class IntervalType(Enum):
    PERFECT = auto()
    IMPERFECT = auto()
    DISSONANT = auto()


class MotionType(Enum):
    CONTRARY = auto()
    OBLIQUE = auto()
    SIMILAR = auto()
    PARALLEL = auto()


@dataclass(frozen=True)
class ConsonantInterval:
    """A consonant interval in first-species counterpoint."""
    semitones: int  # 0-11
    name: str
    interval_type: IntervalType
    ratio: Tuple[int, int]  # frequency ratio (numerator, denominator)
    rank: int  # consonance rank (higher = more consonant)

    def __repr__(self) -> str:
        return self.name


# The six consonant intervals
UNISON = ConsonantInterval(0, "Unison", IntervalType.PERFECT, (1, 1), 6)
MIN3 = ConsonantInterval(3, "m3", IntervalType.IMPERFECT, (6, 5), 3)
MAJ3 = ConsonantInterval(4, "M3", IntervalType.IMPERFECT, (5, 4), 4)
FIFTH = ConsonantInterval(7, "P5", IntervalType.PERFECT, (3, 2), 5)
MIN6 = ConsonantInterval(8, "m6", IntervalType.IMPERFECT, (8, 5), 1)
MAJ6 = ConsonantInterval(9, "M6", IntervalType.IMPERFECT, (5, 3), 2)

ALL_CONSONANCES: List[ConsonantInterval] = [UNISON, MIN3, MAJ3, FIFTH, MIN6, MAJ6]
CONSONANT_SEMITONES: Set[int] = {c.semitones for c in ALL_CONSONANCES}


@dataclass(frozen=True)
class VoiceLeading:
    """A voice leading between two consonant intervals."""
    source: ConsonantInterval
    target: ConsonantInterval
    lower_step: int  # semitone motion of lower voice
    upper_step: int  # semitone motion of upper voice

    @property
    def motion_type(self) -> MotionType:
        """Classify the motion type of this voice leading."""
        return classify_motion(self.lower_step, self.upper_step)

    @property
    def is_valid(self) -> bool:
        """Check if this voice leading is valid in first-species counterpoint."""
        if self.target.interval_type == IntervalType.PERFECT:
            if self.motion_type == MotionType.PARALLEL:
                return False
        return True

    @property
    def net_motion(self) -> Tuple[int, int]:
        """Net motion as (lower, upper) pair."""
        return (self.lower_step, self.upper_step)


def classify_motion(lower: int, upper: int) -> MotionType:
    """Classify the motion type of a voice leading."""
    if lower == upper:
        if lower == 0:
            return MotionType.OBLIQUE
        return MotionType.PARALLEL
    if lower == 0 or upper == 0:
        return MotionType.OBLIQUE
    if lower * upper < 0:
        return MotionType.CONTRARY
    return MotionType.SIMILAR


def interval_inversion(semitones: int) -> int:
    """Compute the inversion of an interval (negation mod 12)."""
    return (12 - semitones) % 12


def is_consonant(semitones: int) -> bool:
    """Check if a semitone value is consonant."""
    return (semitones % 12) in CONSONANT_SEMITONES


def enumerate_voice_leadings(
    source: ConsonantInterval,
    target: ConsonantInterval,
    step_bound: int = 7
) -> List[VoiceLeading]:
    """Enumerate all valid voice leadings between two intervals within a step bound."""
    results: List[VoiceLeading] = []
    required_diff = (target.semitones - source.semitones) % 12

    for dl in range(-step_bound, step_bound + 1):
        for du in range(-step_bound, step_bound + 1):
            if (du - dl) % 12 == required_diff:
                vl = VoiceLeading(source, target, dl, du)
                if vl.is_valid:
                    results.append(vl)
    return results


def build_transition_matrix(step_bound: int = 7) -> Dict[Tuple[ConsonantInterval, ConsonantInterval], int]:
    """Build the transition count matrix for voice leadings."""
    matrix: Dict[Tuple[ConsonantInterval, ConsonantInterval], int] = {}
    for s in ALL_CONSONANCES:
        for t in ALL_CONSONANCES:
            vls = enumerate_voice_leadings(s, t, step_bound)
            matrix[(s, t)] = len(vls)
    return matrix


def oblique_voice_leading(source: ConsonantInterval, target: ConsonantInterval) -> VoiceLeading:
    """Construct a valid oblique voice leading (lower voice stays, upper moves)."""
    upper_step = target.semitones - source.semitones
    return VoiceLeading(source, target, 0, upper_step)


def verify_universal_reachability() -> bool:
    """Verify that every consonant interval can reach every other via valid voice leading."""
    for s in ALL_CONSONANCES:
        for t in ALL_CONSONANCES:
            vl = oblique_voice_leading(s, t)
            if not vl.is_valid:
                return False
    return True


def verify_non_subgroup() -> Optional[Tuple[int, int, int]]:
    """Find a closure failure witnessing that the consonant set is not a subgroup.
    Returns (a, b, a+b mod 12) where a, b are consonant but a+b is not."""
    for a in sorted(CONSONANT_SEMITONES):
        for b in sorted(CONSONANT_SEMITONES):
            s = (a + b) % 12
            if s not in CONSONANT_SEMITONES:
                return (a, b, s)
    return None


def verify_inversion_asymmetry() -> Optional[int]:
    """Find the consonant interval whose inversion is dissonant.
    Returns the semitone value, or None if all inversions are consonant."""
    for i in sorted(CONSONANT_SEMITONES):
        inv = interval_inversion(i)
        if inv not in CONSONANT_SEMITONES:
            return i
    return None


def consonant_sum_mod12() -> int:
    """Compute the sum of all consonant intervals mod 12."""
    return sum(CONSONANT_SEMITONES) % 12


def consonance_rank_ordering() -> List[ConsonantInterval]:
    """Return consonant intervals sorted by consonance rank (most consonant first)."""
    return sorted(ALL_CONSONANCES, key=lambda c: c.rank, reverse=True)


if __name__ == "__main__":
    print("Universal reachability:", verify_universal_reachability())
    print("Non-subgroup witness:", verify_non_subgroup())
    print("Inversion asymmetry at:", verify_inversion_asymmetry())
    print("Consonant sum mod 12:", consonant_sum_mod12())
    print("Consonance ranking:", consonance_rank_ordering())
    
    print("\nTransition matrix (step bound = 7):")
    matrix = build_transition_matrix(7)
    for s in ALL_CONSONANCES:
        row = [str(matrix[(s, t)]).rjust(3) for t in ALL_CONSONANCES]
        print(f"  {s.name:>6s}: {' '.join(row)}")
