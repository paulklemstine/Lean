#!/usr/bin/env python3
"""Numerical demonstrations for dream logic and algebraic forgetting.

The script uses only the Python standard library.  It demonstrates local
non-explosion, non-monotone and order-sensitive revision, consistency versus
conflict-freedom, the growth behind the arbitrary-union obstruction, targeted
forgetting, and collisions in a finite compositional memory.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, Iterator, List, Sequence, Tuple, TypeVar

Atom = str
Sign = bool
Literal = Tuple[Atom, Sign]
State = FrozenSet[Literal]
Symbol = TypeVar("Symbol")


def opposite(literal: Literal) -> Literal:
    """Return the complementary literal over the same atom."""
    atom, sign = literal
    return atom, not sign


def revise(state: State, literal: Literal) -> State:
    """Insert ``literal`` and retract its opposite."""
    return frozenset((set(state) - {opposite(literal)}) | {literal})


def contradictions(state: State) -> FrozenSet[Atom]:
    """Return exactly the atoms whose positive and negative signs both occur."""
    atoms = {atom for atom, _ in state}
    return frozenset(
        atom for atom in atoms if (atom, True) in state and (atom, False) in state
    )


def is_consistent(state: State) -> bool:
    """Test semantic consistency."""
    return not contradictions(state)


def is_conflict_free(state: State) -> bool:
    """Test conflict-freedom for complementary attack."""
    return all(opposite(literal) not in state for literal in state)


def format_literal(literal: Literal) -> str:
    atom, sign = literal
    return atom if sign else f"¬{atom}"


def format_state(state: State) -> str:
    return "{" + ", ".join(sorted(format_literal(item) for item in state)) + "}"


def all_states(atoms: Sequence[Atom]) -> Iterator[State]:
    """Enumerate all signed states over a finite list of atoms."""
    literals = [(atom, sign) for atom in atoms for sign in (False, True)]
    for mask in product((False, True), repeat=len(literals)):
        yield frozenset(lit for lit, chosen in zip(literals, mask) if chosen)


def targeted_forgetting(stream: Sequence[Symbol], retain: Callable[[Symbol], bool]) -> Tuple[Symbol, ...]:
    """Delete unretained symbols while preserving retained order."""
    return tuple(symbol for symbol in stream if retain(symbol))


def words(alphabet: Sequence[Symbol], max_length: int) -> Iterator[Tuple[Symbol, ...]]:
    """Enumerate words in nondecreasing length."""
    for length in range(max_length + 1):
        yield from product(alphabet, repeat=length)


def finite_memory_collision(
    alphabet: Sequence[Symbol],
    max_length: int,
    memory: Callable[[Tuple[Symbol, ...]], int],
) -> Tuple[Tuple[Symbol, ...], Tuple[Symbol, ...], int]:
    """Find the first collision among words up to ``max_length``."""
    seen: Dict[int, Tuple[Symbol, ...]] = {}
    for word in words(alphabet, max_length):
        value = memory(word)
        if value in seen and seen[value] != word:
            return seen[value], word, value
        seen[value] = word
    raise ValueError("No collision found in the requested finite search region")


def demo_non_explosion_and_revision() -> None:
    print("\n1. LOCAL CONTRADICTION AND REVISION")
    state: State = frozenset({("door_open", True), ("door_open", False)})
    unrelated = ("train_arrived", True)
    print("Initial state:", format_state(state))
    print("Contradictory atoms:", sorted(contradictions(state)))
    print("Entails unrelated train claim:", unrelated in state)

    positive = revise(state, ("door_open", True))
    negative_then = revise(positive, ("door_open", False))
    negative = revise(state, ("door_open", False))
    positive_then = revise(negative, ("door_open", True))
    print("Revise by door_open:", format_state(positive))
    print("Then revise by ¬door_open:", format_state(negative_then))
    print("Reverse update order:", format_state(positive_then))
    print("Contrary revisions commute:", negative_then == positive_then)


def demo_bridge_exhaustively() -> None:
    print("\n2. CONSISTENCY–CONFLICT BRIDGE (FINITE EXHAUSTION)")
    atoms = ["a", "b", "c"]
    states = list(all_states(atoms))
    equivalence_holds = all(is_consistent(s) == is_conflict_free(s) for s in states)
    consistent_states = [s for s in states if is_consistent(s)]
    preservation_holds = all(
        is_consistent(revise(s, literal))
        for s in consistent_states
        for literal in [(a, sign) for a in atoms for sign in (False, True)]
    )
    print(f"All signed states checked: {len(states)} = 4^{len(atoms)}")
    print(f"Consistent states: {len(consistent_states)} = 3^{len(atoms)}")
    print("Consistency equals conflict-freedom:", equivalence_holds)
    print("Every one-step revision preserves consistency:", preservation_holds)


def demo_finitary_boundary() -> None:
    print("\n3. FINITARY-UNION GROWTH")
    for n in (1, 2, 5, 10, 100):
        union = set().union(*(set([k]) for k in range(n)))
        print(f"Union of first {n:>3} singletons has size {len(union):>3}")
    print("Every displayed stage is finite, while sizes are unbounded;")
    print("the union over all natural-number singletons is infinite.")


def demo_targeted_forgetting() -> None:
    print("\n4. TARGETED FORGETTING")
    retained = {"red", "blue"}
    first = ("red", "noise", "blue")
    second = ("red", "blue")
    memory1 = targeted_forgetting(first, retained.__contains__)
    memory2 = targeted_forgetting(second, retained.__contains__)
    print("First stream:", first, "->", memory1)
    print("Second stream:", second, "->", memory2)
    print("Distinct streams are observationally indistinguishable:", first != second and memory1 == memory2)


def demo_finite_memory() -> None:
    print("\n5. FINITE COMPOSITIONAL MEMORY")
    modulus = 5
    memory = lambda word: len(word) % modulus
    first, second, value = finite_memory_collision(("x",), modulus, memory)
    print(f"Memory records length modulo {modulus}.")
    print("Collision:", first, "and", second, "both map to", value)
    erased_lengths = [n for n in range(21) if n % modulus == 0]
    closure_examples = [(a, b, a + b) for a in erased_lengths[:3] for b in erased_lengths[:3]]
    print("Erased lengths through 20:", erased_lengths)
    print("Sample closure under concatenation (length addition):", closure_examples[:5])


def main() -> None:
    print("DREAM LOGIC AND ALGEBRAIC FORGETTING — NUMERICAL DEMONSTRATIONS")
    demo_non_explosion_and_revision()
    demo_bridge_exhaustively()
    demo_finitary_boundary()
    demo_targeted_forgetting()
    demo_finite_memory()


if __name__ == "__main__":
    main()
