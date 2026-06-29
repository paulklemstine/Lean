"""
Musical Counterpoint as Constraint Satisfaction — Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import List, Tuple, Callable, Optional
import itertools


# --- Core Types ---

Pitch = int  # Semitone value (C4 = 60 in MIDI convention)
VoiceMotion = Tuple[int, ...]  # Motion vector for n voices
Chord = Tuple[int, ...]  # n pitches


# --- Cost Function ---

def voice_leading_cost(motion: VoiceMotion) -> int:
    """L¹ norm: total absolute displacement of all voices."""
    return sum(abs(m) for m in motion)


def pitch_class(p: int) -> int:
    """Map pitch to pitch class (0-11)."""
    return p % 12


def chord_interval(chord: Chord, i: int, j: int) -> int:
    """Interval between voice j and voice i in a chord."""
    return chord[j] - chord[i]


# --- Consonance ---

CONSONANCE_SCORE = {
    0: 8, 7: 7, 5: 6, 4: 5, 3: 5, 9: 4, 8: 4,
    2: 2, 1: 1, 10: 1, 11: 1, 6: 0
}


def consonance_score(interval_class: int) -> int:
    """Consonance score for an interval class mod 12."""
    return CONSONANCE_SCORE.get(interval_class % 12, 0)


def is_consonant(ic: int) -> bool:
    return consonance_score(ic) >= 4


def is_perfect_consonance(ic: int) -> bool:
    return consonance_score(ic) >= 6


# --- Counterpoint Constraints ---

Constraint = Callable[[Chord, VoiceMotion], bool]


def no_parallel_fifths(source: Chord, motion: VoiceMotion) -> bool:
    """Check that no two voices in parallel fifths remain in parallel fifths."""
    n = len(source)
    for i in range(n):
        for j in range(i + 1, n):
            if pitch_class(chord_interval(source, i, j)) == 7:
                if motion[i] == motion[j]:
                    return False
    return True


def no_parallel_octaves(source: Chord, motion: VoiceMotion) -> bool:
    """Check that no two voices an octave apart move in parallel."""
    n = len(source)
    for i in range(n):
        for j in range(i + 1, n):
            interval = chord_interval(source, i, j)
            if pitch_class(interval) == 0 and interval != 0:
                if motion[i] == motion[j]:
                    return False
    return True


def stepwise_motion(bound: int) -> Constraint:
    """Each voice moves by at most `bound` semitones."""
    def check(_source: Chord, motion: VoiceMotion) -> bool:
        return all(abs(m) <= bound for m in motion)
    return check


# --- Counterpoint System ---

class CounterpointSystem:
    """Constraint satisfaction system for species counterpoint."""

    def __init__(self, source: Chord, constraints: List[Constraint]):
        self.source = source
        self.constraints = constraints

    def is_feasible(self, motion: VoiceMotion) -> bool:
        return all(c(self.source, motion) for c in self.constraints)

    def find_optimal(self, bound: int) -> Optional[VoiceMotion]:
        """Find the feasible motion with minimum cost within stepwise bound."""
        n = len(self.source)
        ranges = [range(-bound, bound + 1)] * n
        best: Optional[VoiceMotion] = None
        best_cost = float('inf')

        for motion_list in itertools.product(*ranges):
            motion = tuple(motion_list)
            if motion == (0,) * n:
                continue  # Skip identity unless it's the only option
            if self.is_feasible(motion):
                cost = voice_leading_cost(motion)
                if cost < best_cost:
                    best_cost = cost
                    best = motion

        # Include identity if nothing else works
        if best is None:
            identity = (0,) * n
            if self.is_feasible(identity):
                return identity
        return best

    def enumerate_feasible(self, bound: int) -> List[Tuple[VoiceMotion, int]]:
        """Enumerate all feasible motions within bound, sorted by cost."""
        n = len(self.source)
        ranges = [range(-bound, bound + 1)] * n
        feasible = []
        for motion_list in itertools.product(*ranges):
            motion = tuple(motion_list)
            if self.is_feasible(motion):
                feasible.append((motion, voice_leading_cost(motion)))
        feasible.sort(key=lambda x: x[1])
        return feasible


# --- Lattice Operations ---

def lattice_meet(m1: VoiceMotion, m2: VoiceMotion) -> VoiceMotion:
    """Componentwise minimum (lattice meet)."""
    return tuple(min(a, b) for a, b in zip(m1, m2))


def lattice_join(m1: VoiceMotion, m2: VoiceMotion) -> VoiceMotion:
    """Componentwise maximum (lattice join)."""
    return tuple(max(a, b) for a, b in zip(m1, m2))


def verify_lattice_cost_identity(m1: VoiceMotion, m2: VoiceMotion) -> bool:
    """Verify cost(meet) + cost(join) = cost(m1) + cost(m2)."""
    meet = lattice_meet(m1, m2)
    join = lattice_join(m1, m2)
    return (voice_leading_cost(meet) + voice_leading_cost(join) ==
            voice_leading_cost(m1) + voice_leading_cost(m2))


# --- Optimal Voice Leading Algorithm ---

def optimal_voice_leading(source: Chord, target: Chord,
                          constraints: List[Constraint],
                          max_motion: int = 12) -> Optional[VoiceMotion]:
    """
    Find the optimal (minimum cost) voice leading from source to target
    that satisfies all constraints.

    Uses the target chord to determine required motions, then checks
    if nearby motions (within max_motion of required) satisfy constraints.
    """
    n = len(source)
    required = tuple(target[i] - source[i] for i in range(n))

    # Check if direct motion is feasible
    if all(c(source, required) for c in constraints):
        return required

    # Search nearby motions
    best: Optional[VoiceMotion] = None
    best_cost = float('inf')

    for delta in itertools.product(range(-max_motion, max_motion + 1), repeat=n):
        motion = tuple(required[i] + delta[i] for i in range(n))
        # Target must match modulo octave transposition
        if all(c(source, motion) for c in constraints):
            cost = voice_leading_cost(motion)
            if cost < best_cost:
                best_cost = cost
                best = motion

    return best
