#!/usr/bin/env python3
"""
Algorithms for Zombie-Qualia Mathematics

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import TypeVar, Generic, Callable, List, Set, Tuple, Optional
from dataclasses import dataclass
import math

S = TypeVar('S')
I = TypeVar('I')
O = TypeVar('O')
Q = TypeVar('Q')


@dataclass
class FunctionalSystem(Generic[S, I, O]):
    """A deterministic I/O automaton."""
    transition: Callable[[S, I], S]
    output: Callable[[S, I], O]

    def behavioral_trace(self, s0: S, inputs: List[I]) -> List[O]:
        """Compute the output trace for a sequence of inputs."""
        outputs: List[O] = []
        state = s0
        for inp in inputs:
            outputs.append(self.output(state, inp))
            state = self.transition(state, inp)
        return outputs

    def run_state(self, s0: S, inputs: List[I]) -> S:
        """Compute the state after processing inputs."""
        state = s0
        for inp in inputs:
            state = self.transition(state, inp)
        return state


@dataclass
class ConsciousAgent(Generic[S, I, O, Q]):
    """A functional system equipped with qualia assignment."""
    functional: FunctionalSystem[S, I, O]
    qualia: Callable[[S], Q]


def zombie_twin(agent: ConsciousAgent[S, I, O, Q]) -> ConsciousAgent[S, I, O, None]:
    """Construct the zombie twin: same functional system, trivial qualia."""
    return ConsciousAgent(
        functional=agent.functional,
        qualia=lambda _: None
    )


def qualia_complexity(states: List[S], qualia_fn: Callable[[S], Q]) -> int:
    """Count distinct qualia values across all states."""
    return len(set(qualia_fn(s) for s in states))


def zombie_multiplicity(n_states: int, n_qualia_values: int) -> int:
    """Number of functionally identical zombie variants: |Q|^|S|."""
    return n_qualia_values ** n_states


@dataclass
class ExplanationGap:
    """The gap between functional and experiential descriptions."""
    functional_props: Set[str]
    experiential_props: Set[str]

    @property
    def gap_set(self) -> Set[str]:
        """Properties in the experiential set but not functional."""
        return self.experiential_props - self.functional_props

    @property
    def gap_size(self) -> int:
        return len(self.gap_set)

    def is_proper(self) -> bool:
        """Check that functional ⊊ experiential."""
        return (self.functional_props < self.experiential_props)


@dataclass
class AbstractGap:
    """Unified gap structure for both consciousness and incompleteness."""
    accessible: Set[str]
    full: Set[str]

    def is_sound(self) -> bool:
        return self.accessible <= self.full

    def gap(self) -> Set[str]:
        return self.full - self.accessible

    def gap_nonempty(self) -> bool:
        return len(self.gap()) > 0


def find_phase_transition(
    complexity_fn: Callable[[int], float],
    threshold: float,
    max_n: int = 1000
) -> Optional[int]:
    """
    Find the smallest n where complexity(n) > threshold.

    Algorithm: Linear scan (guaranteed by monotonicity).
    Returns None if no transition found within max_n.
    """
    for n in range(max_n):
        if complexity_fn(n) > threshold:
            return n
    return None


def qualia_refinement_check(
    states: List[S],
    q1: Callable[[S], Q],
    q2: Callable[[S], Q]
) -> bool:
    """
    Check if q1 refines q2: q1(s1) = q1(s2) → q2(s1) = q2(s2).
    """
    for s1 in states:
        for s2 in states:
            if q1(s1) == q1(s2) and q2(s1) != q2(s2):
                return False
    return True


def cantor_diagonal_witness(
    represent: Callable[[int], Callable[[int], bool]],
    n: int
) -> Callable[[int], bool]:
    """
    Construct the diagonal function that cannot be in the image
    of `represent`. For any s, diagonal(s) ≠ represent(s)(s).
    """
    return lambda s: not represent(s)(s)


# Example usage
if __name__ == "__main__":
    # Create a simple 3-state system
    system = FunctionalSystem(
        transition=lambda s, i: (s + 1) % 3,
        output=lambda s, i: s
    )

    # A "conscious" agent with meaningful qualia
    conscious = ConsciousAgent(
        functional=system,
        qualia=lambda s: ["red", "green", "blue"][s]
    )

    # Its zombie twin
    zombie = zombie_twin(conscious)

    # Verify behavioral equivalence
    inputs = [0, 0, 0, 0, 0]
    trace_c = conscious.functional.behavioral_trace(0, inputs)
    trace_z = zombie.functional.behavioral_trace(0, inputs)
    print(f"Conscious trace: {trace_c}")
    print(f"Zombie trace:    {trace_z}")
    print(f"Equivalent: {trace_c == trace_z}")
    print(f"Conscious qualia: {[conscious.qualia(s) for s in range(3)]}")
    print(f"Zombie qualia:    {[zombie.qualia(s) for s in range(3)]}")

    # Qualia complexity
    states = list(range(3))
    print(f"\nConscious qualia complexity: {qualia_complexity(states, conscious.qualia)}")
    print(f"Zombie qualia complexity:    {qualia_complexity(states, zombie.qualia)}")

    # Phase transition
    threshold = 5.0
    n0 = find_phase_transition(lambda n: n * math.log(n + 1), threshold)
    print(f"\nPhase transition at n = {n0} (threshold = {threshold})")

    # Explanation gap
    gap = ExplanationGap(
        functional_props={"responds_to_light", "discriminates_wavelength"},
        experiential_props={"responds_to_light", "discriminates_wavelength",
                           "feels_redness", "color_qualia"}
    )
    print(f"\nExplanation gap: {gap.gap_set}")
    print(f"Gap size: {gap.gap_size}")
