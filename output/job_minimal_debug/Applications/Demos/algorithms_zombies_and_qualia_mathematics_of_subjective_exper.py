#!/usr/bin/env python3
"""
Algorithms for Zombie-Qualia Systems

Type-hinted implementations of the core algorithms for analyzing
zombie systems, measuring explanatory gaps, and detecting qualia.
"""

from typing import List, Set, Dict, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class ZombieSystem:
    """A zombie system with functional equivalence and qualia.

    Attributes:
        states: List of state identifiers
        equiv_classes: Mapping from state to equivalence class id
        qualia: Set of states with subjective experience
    """
    states: List[int]
    equiv_classes: Dict[int, int]
    qualia: Set[int]

    def func_equiv(self, x: int, y: int) -> bool:
        """Check if two states are functionally equivalent."""
        return self.equiv_classes[x] == self.equiv_classes[y]

    def has_qualia(self, x: int) -> bool:
        """Check if a state has subjective experience."""
        return x in self.qualia

    def validate(self) -> bool:
        """Verify the zombie hypothesis holds."""
        for x in self.states:
            if self.has_qualia(x):
                has_twin = any(
                    self.func_equiv(x, y) and not self.has_qualia(y)
                    for y in self.states
                )
                if not has_twin:
                    return False
        return True


def find_zombie_twin(system: ZombieSystem, x: int) -> Optional[int]:
    """Find a zombie twin for a conscious state.

    Args:
        system: The zombie system
        x: A state with qualia

    Returns:
        A functionally equivalent state without qualia, or None
    """
    if not system.has_qualia(x):
        return None
    for y in system.states:
        if system.func_equiv(x, y) and not system.has_qualia(y):
            return y
    return None


def check_respects(
    predicate: Callable[[int], bool],
    system: ZombieSystem
) -> bool:
    """Check if a predicate respects functional equivalence.

    A predicate P respects R iff R(x,y) implies P(x) = P(y).

    Args:
        predicate: Function from states to bool
        system: The zombie system

    Returns:
        True if the predicate respects functional equivalence
    """
    for x in system.states:
        for y in system.states:
            if system.func_equiv(x, y):
                if predicate(x) != predicate(y):
                    return False
    return True


def measure_explanatory_gap(system: ZombieSystem) -> float:
    """Measure the explanatory gap as a fraction.

    The gap is the fraction of equivalence classes that contain
    both conscious and zombie states.

    Args:
        system: The zombie system

    Returns:
        Gap measure in [0, 1]
    """
    classes: Dict[int, List[int]] = {}
    for state in system.states:
        cls = system.equiv_classes[state]
        if cls not in classes:
            classes[cls] = []
        classes[cls].append(state)

    mixed_count = 0
    for cls_states in classes.values():
        has_conscious = any(system.has_qualia(s) for s in cls_states)
        has_zombie = any(not system.has_qualia(s) for s in cls_states)
        if has_conscious and has_zombie:
            mixed_count += 1

    return mixed_count / len(classes) if classes else 0.0


def count_respecting_predicates(n_states: int, n_classes: int) -> Tuple[int, int, float]:
    """Count predicates respecting an equivalence relation.

    Args:
        n_states: Number of states
        n_classes: Number of equivalence classes

    Returns:
        (total_predicates, respecting_predicates, gap_fraction)
    """
    total = 2 ** n_states
    respecting = 2 ** n_classes
    gap = 1.0 - respecting / total
    return total, respecting, gap


@dataclass
class IncompletenessStructure:
    """Abstract incompleteness structure.

    Captures the common pattern between Gödel's incompleteness
    and the zombie argument.
    """
    elements: List[int]
    accessible: Set[int]
    actual: Set[int]

    def is_sound(self) -> bool:
        """Check soundness: accessible ⊆ actual."""
        return self.accessible.issubset(self.actual)

    def gap_set(self) -> Set[int]:
        """Return the gap: actual ∖ accessible."""
        return self.actual - self.accessible

    def gap_size(self) -> int:
        """Return the size of the gap."""
        return len(self.gap_set())

    def has_gap(self) -> bool:
        """Check if there is a non-empty gap."""
        return len(self.gap_set()) > 0


def zombie_to_incompleteness(system: ZombieSystem) -> IncompletenessStructure:
    """Convert a zombie system to an incompleteness structure.

    Maps:
      - accessible = zombie states (functionally "safe")
      - actual = all states

    Args:
        system: The zombie system

    Returns:
        The corresponding incompleteness structure
    """
    accessible = set(s for s in system.states if not system.has_qualia(s))
    actual = set(system.states)
    return IncompletenessStructure(
        elements=system.states,
        accessible=accessible,
        actual=actual
    )


def godel_to_incompleteness(
    sentences: List[int],
    provable: Set[int],
    true_sentences: Set[int]
) -> IncompletenessStructure:
    """Convert a Gödel-style formal system to an incompleteness structure.

    Args:
        sentences: List of sentence identifiers
        provable: Set of provable sentences
        true_sentences: Set of true sentences

    Returns:
        The corresponding incompleteness structure
    """
    return IncompletenessStructure(
        elements=sentences,
        accessible=provable,
        actual=true_sentences
    )


def product_zombie_system(
    sys1: ZombieSystem,
    sys2: ZombieSystem
) -> ZombieSystem:
    """Construct the product of two zombie systems.

    The product has states (s1, s2) with functional equivalence
    being componentwise and qualia determined by the first component.

    Args:
        sys1: First zombie system
        sys2: Second zombie system

    Returns:
        The product zombie system
    """
    states = []
    equiv_classes = {}
    qualia = set()

    n2 = len(sys2.states)
    for s1 in sys1.states:
        for s2 in sys2.states:
            state_id = s1 * n2 + s2
            states.append(state_id)
            # Product equivalence class
            c1 = sys1.equiv_classes[s1]
            c2 = sys2.equiv_classes[s2]
            n_classes_2 = len(set(sys2.equiv_classes.values()))
            equiv_classes[state_id] = c1 * n_classes_2 + c2
            # Qualia from first component
            if sys1.has_qualia(s1):
                qualia.add(state_id)

    return ZombieSystem(
        states=states,
        equiv_classes=equiv_classes,
        qualia=qualia
    )


if __name__ == "__main__":
    # Example usage
    system = ZombieSystem(
        states=[0, 1, 2, 3, 4, 5],
        equiv_classes={0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2},
        qualia={0, 2, 4}
    )

    print(f"System valid: {system.validate()}")
    print(f"Explanatory gap: {measure_explanatory_gap(system):.2f}")

    for s in system.states:
        if system.has_qualia(s):
            twin = find_zombie_twin(system, s)
            print(f"  State {s} → zombie twin: {twin}")

    inc = zombie_to_incompleteness(system)
    print(f"\nIncompleteness structure:")
    print(f"  Sound: {inc.is_sound()}")
    print(f"  Gap size: {inc.gap_size()}")
    print(f"  Gap elements: {inc.gap_set()}")

    # Counting
    total, resp, gap = count_respecting_predicates(6, 3)
    print(f"\nPredicate counting (n=6, k=3):")
    print(f"  Total: {total}, Respecting: {resp}, Gap: {gap:.4f}")
