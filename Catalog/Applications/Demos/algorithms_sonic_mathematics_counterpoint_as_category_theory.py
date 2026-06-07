"""
Algorithms for the Fux Category: Counterpoint as Category Theory

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import List, Tuple, Set, Dict, Optional
from enum import Enum, auto
from dataclasses import dataclass
from itertools import product


class ConsonantInterval(Enum):
    """The six consonant interval classes in 12-TET."""
    UNISON = 0       # Perfect
    MIN_THIRD = 3    # Imperfect
    MAJ_THIRD = 4    # Imperfect
    PERF_FIFTH = 7   # Perfect
    MIN_SIXTH = 8    # Imperfect
    MAJ_SIXTH = 9    # Imperfect

    @property
    def is_perfect(self) -> bool:
        return self in (ConsonantInterval.UNISON, ConsonantInterval.PERF_FIFTH)

    @property
    def semitones(self) -> int:
        return self.value


class MotionType(Enum):
    """The four types of melodic motion."""
    CONTRARY = auto()
    OBLIQUE = auto()
    SIMILAR = auto()
    PARALLEL = auto()


@dataclass(frozen=True)
class FuxTransition:
    """A labeled transition in the Fux quiver."""
    source: ConsonantInterval
    target: ConsonantInterval
    motion: MotionType

    @property
    def is_valid(self) -> bool:
        """Fux's Golden Rule: no parallel motion to a perfect consonance."""
        return not (self.target.is_perfect and self.motion == MotionType.PARALLEL)


def motion_compose(m1: MotionType, m2: MotionType) -> MotionType:
    """Compose two motion types under sequential voice leading."""
    if m1 == MotionType.PARALLEL and m2 == MotionType.PARALLEL:
        return MotionType.PARALLEL
    if m1 == MotionType.PARALLEL:
        return m2
    if m2 == MotionType.PARALLEL:
        return m1
    if m1 == MotionType.CONTRARY and m2 == MotionType.CONTRARY:
        return MotionType.SIMILAR
    if m1 == MotionType.CONTRARY or m2 == MotionType.CONTRARY:
        return MotionType.CONTRARY
    if m1 == MotionType.OBLIQUE and m2 == MotionType.OBLIQUE:
        return MotionType.OBLIQUE
    return MotionType.SIMILAR


def enumerate_all_transitions() -> List[FuxTransition]:
    """Enumerate all 144 possible transitions."""
    return [
        FuxTransition(s, t, m)
        for s in ConsonantInterval
        for t in ConsonantInterval
        for m in MotionType
    ]


def enumerate_valid_transitions() -> List[FuxTransition]:
    """Enumerate all 132 valid transitions."""
    return [t for t in enumerate_all_transitions() if t.is_valid]


def enumerate_forbidden_transitions() -> List[FuxTransition]:
    """Enumerate all 12 forbidden transitions."""
    return [t for t in enumerate_all_transitions() if not t.is_valid]


def build_adjacency_matrix() -> Dict[Tuple[ConsonantInterval, ConsonantInterval], int]:
    """Build the adjacency matrix (transition counts)."""
    valid = enumerate_valid_transitions()
    matrix: Dict[Tuple[ConsonantInterval, ConsonantInterval], int] = {}
    for s in ConsonantInterval:
        for t in ConsonantInterval:
            matrix[(s, t)] = sum(1 for tr in valid if tr.source == s and tr.target == t)
    return matrix


def incoming_count(target: ConsonantInterval) -> int:
    """Count valid incoming transitions for a target."""
    return sum(1 for t in enumerate_valid_transitions() if t.target == target)


def outgoing_count(source: ConsonantInterval) -> int:
    """Count valid outgoing transitions for a source."""
    return sum(1 for t in enumerate_valid_transitions() if t.source == source)


def interval_inversion(n: int) -> int:
    """Interval inversion in Z/12Z."""
    return (12 - n) % 12


def consonant_set() -> Set[int]:
    """The consonant semitone values."""
    return {c.semitones for c in ConsonantInterval}


def difference_set(S: Set[int]) -> Set[int]:
    """Pairwise difference set mod 12."""
    return {(a - b) % 12 for a in S for b in S}


def verify_spectral_completeness() -> bool:
    """Verify that differences of the consonant set cover all of Z/12Z."""
    return difference_set(consonant_set()) == set(range(12))


def verify_composition_preservation() -> bool:
    """Verify that composing valid transitions yields valid transitions."""
    for t1 in enumerate_all_transitions():
        for t2 in enumerate_valid_transitions():
            composed = FuxTransition(
                t1.source, t2.target,
                motion_compose(t1.motion, t2.motion)
            )
            if not composed.is_valid:
                return False
    return True


def verify_inversion_asymmetry() -> Tuple[bool, Optional[int]]:
    """Check if consonant set is closed under inversion. Returns (closed, counterexample)."""
    cs = consonant_set()
    for n in cs:
        inv = interval_inversion(n)
        if inv not in cs:
            return (False, n)
    return (True, None)


if __name__ == "__main__":
    print("=== Fux Category Verification ===\n")

    print(f"Consonant intervals: {sorted(consonant_set())}")
    print(f"Total transitions: {len(enumerate_all_transitions())}")
    print(f"Valid transitions: {len(enumerate_valid_transitions())}")
    print(f"Forbidden transitions: {len(enumerate_forbidden_transitions())}")

    print(f"\nIncoming counts:")
    for c in ConsonantInterval:
        print(f"  {c.name}: {incoming_count(c)} ({'perfect' if c.is_perfect else 'imperfect'})")

    print(f"\nOutgoing counts:")
    for c in ConsonantInterval:
        print(f"  {c.name}: {outgoing_count(c)}")

    matrix = build_adjacency_matrix()
    print(f"\nAdjacency matrix values: {sorted(set(matrix.values()))}")

    print(f"\nSpectral completeness: {verify_spectral_completeness()}")
    print(f"Composition preservation: {verify_composition_preservation()}")

    closed, counter = verify_inversion_asymmetry()
    print(f"Inversion asymmetry: closed={closed}, counterexample={counter}")
