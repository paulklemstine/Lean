#!/usr/bin/env python3
"""
Algorithms for the Zombies and Qualia Framework

Type-hinted implementations of the core algorithms from the formal proofs.
"""

from typing import TypeVar, Generic, Callable, List, Tuple, Optional, Set, FrozenSet
from dataclasses import dataclass
from itertools import product
import math

S = TypeVar('S')
I = TypeVar('I')  
O = TypeVar('O')
Q = TypeVar('Q')


@dataclass(frozen=True)
class FunctionalSystem(Generic[S, I, O]):
    """A functional system: states, transitions, outputs."""
    states: FrozenSet[S]
    inputs: FrozenSet[I]
    transition: Callable[[S, I], S]
    output: Callable[[S], O]


@dataclass(frozen=True)
class ConsciousSystem(Generic[S, I, O, Q]):
    """A conscious system: functional system + qualia assignment."""
    states: FrozenSet[S]
    inputs: FrozenSet[I]
    transition: Callable[[S, I], S]
    output: Callable[[S], O]
    quale: Callable[[S], Q]
    
    def functional(self) -> FunctionalSystem[S, I, O]:
        """Extract the functional part (forget qualia)."""
        return FunctionalSystem(
            states=self.states,
            inputs=self.inputs,
            transition=self.transition,
            output=self.output
        )


def zombie_twin(
    system: ConsciousSystem[S, I, O, Q],
    new_quale: Callable[[S], object]
) -> ConsciousSystem[S, I, O, object]:
    """
    Construct a zombie twin: same function, different qualia.
    
    Corresponds to: zombie_twin_exists
    """
    return ConsciousSystem(
        states=system.states,
        inputs=system.inputs,
        transition=system.transition,
        output=system.output,
        quale=new_quale
    )


def behavioral_trace(
    system: FunctionalSystem[S, I, O],
    s0: S,
    inputs: List[I]
) -> List[O]:
    """
    Compute the behavioral trace of a system.
    
    Corresponds to: behavioralTrace
    """
    trace: List[O] = []
    state = s0
    for inp in inputs:
        trace.append(system.output(state))
        state = system.transition(state, inp)
    return trace


def explanatory_gap_card(n_states: int, n_qualia: int) -> int:
    """
    Compute the explanatory gap cardinality: |Q|^|S|.
    
    Corresponds to: ExplanatoryGapCard
    """
    return n_qualia ** n_states


def info_gap(n_states: int, n_qualia: int) -> float:
    """
    Information-theoretic gap in bits: |S| * log2(|Q|).
    
    Corresponds to: infoGap
    """
    if n_qualia <= 1:
        return 0.0
    return n_states * math.log2(n_qualia)


def invert_spectrum(
    system: ConsciousSystem[S, I, O, Q],
    involution: Callable[[Q], Q]
) -> ConsciousSystem[S, I, O, Q]:
    """
    Apply a qualia involution to create an inverted-spectrum twin.
    
    Corresponds to: invertSpectrum
    """
    return ConsciousSystem(
        states=system.states,
        inputs=system.inputs,
        transition=system.transition,
        output=system.output,
        quale=lambda s: involution(system.quale(s))
    )


def enumerate_qualia_assignments(
    states: List[S],
    qualia: List[Q]
) -> List[Callable[[S], Q]]:
    """
    Enumerate all possible qualia assignments.
    Returns |Q|^|S| assignments.
    
    This demonstrates the explanatory gap computationally.
    """
    assignments = []
    for combo in product(qualia, repeat=len(states)):
        mapping = dict(zip(states, combo))
        assignments.append(lambda s, m=mapping: m[s])
    return assignments


def count_involutions(n: int) -> int:
    """
    Count involutions on {0, 1, ..., n-1}.
    
    Uses the recurrence: a(n) = a(n-1) + (n-1)*a(n-2)
    """
    if n <= 1:
        return 1
    a_prev2 = 1  # a(0)
    a_prev1 = 1  # a(1)
    for k in range(2, n + 1):
        a_curr = a_prev1 + (k - 1) * a_prev2
        a_prev2, a_prev1 = a_prev1, a_curr
    return a_prev1


def marys_room_demo(
    states: List[S],
    qualia: List[Q],
    functional: FunctionalSystem[S, I, O]
) -> Tuple[ConsciousSystem, ConsciousSystem]:
    """
    Demonstrate Mary's Room: construct two systems with identical function
    but different qualia.
    
    Corresponds to: marys_room theorem
    """
    assert len(qualia) >= 2, "Need at least 2 qualia"
    assert len(states) >= 1, "Need at least 1 state"
    
    q1, q2 = qualia[0], qualia[1]
    s0 = states[0]
    
    # System 1: constant qualia q1
    c1 = ConsciousSystem(
        states=frozenset(states),
        inputs=functional.inputs,
        transition=functional.transition,
        output=functional.output,
        quale=lambda s: q1
    )
    
    # System 2: qualia q1 everywhere except s0 where it's q2
    c2 = ConsciousSystem(
        states=frozenset(states),
        inputs=functional.inputs,
        transition=functional.transition,
        output=functional.output,
        quale=lambda s, _s0=s0, _q1=q1, _q2=q2: _q2 if s == _s0 else _q1
    )
    
    return c1, c2


def verify_zombie_indistinguishability(
    c1: ConsciousSystem[S, I, O, Q],
    c2: ConsciousSystem[S, I, O, object],
    s0: S,
    test_inputs: List[List[I]]
) -> bool:
    """
    Verify that two systems produce identical traces for all test inputs.
    
    Corresponds to: zombie_same_trace
    """
    f1 = c1.functional()
    f2 = c2.functional()
    
    for inputs in test_inputs:
        trace1 = behavioral_trace(f1, s0, inputs)
        trace2 = behavioral_trace(f2, s0, inputs)
        if trace1 != trace2:
            return False
    return True


# Example usage
if __name__ == "__main__":
    # Create a simple 3-state system
    states = [0, 1, 2]
    inputs_set = frozenset([0, 1])
    
    def transition(s: int, i: int) -> int:
        return (s + i) % 3
    
    def output(s: int) -> str:
        return ["A", "B", "C"][s]
    
    # Conscious system with "color" qualia
    system = ConsciousSystem(
        states=frozenset(states),
        inputs=inputs_set,
        transition=transition,
        output=output,
        quale=lambda s: ["red", "green", "blue"][s]
    )
    
    # Create zombie twin
    zombie = zombie_twin(system, lambda s: None)
    
    # Verify indistinguishability
    test_inputs = [[0, 1, 0], [1, 1, 1], [0, 0, 1]]
    indistinguishable = verify_zombie_indistinguishability(
        system, zombie, 0, test_inputs
    )
    print(f"Zombie indistinguishable: {indistinguishable}")
    
    # Explanatory gap
    gap = explanatory_gap_card(len(states), 3)
    print(f"Explanatory gap (3 states, 3 qualia): {gap}")
    
    # Information gap
    bits = info_gap(len(states), 3)
    print(f"Information gap: {bits:.2f} bits")
    
    # Involution count
    for n in range(1, 11):
        print(f"Involutions on {n} elements: {count_involutions(n)}")
