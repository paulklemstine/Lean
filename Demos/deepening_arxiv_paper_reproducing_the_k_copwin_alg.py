#!/usr/bin/env python3
"""Numerical demonstrations for compositional memory and algebraic forgetting."""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Callable, Dict, Hashable, Iterable, List, Mapping, Sequence, Set, Tuple, TypeVar

Symbol = TypeVar("Symbol", bound=Hashable)
State = TypeVar("State", bound=Hashable)
Word = Tuple[Symbol, ...]


def targeted_forgetting(word: Sequence[Symbol], retain: Callable[[Symbol], bool]) -> Word[Symbol]:
    """Delete unretained symbols while preserving the order of retained symbols."""
    return tuple(symbol for symbol in word if retain(symbol))


def parity_memory(word: Sequence[str], counted_symbol: str = "a") -> int:
    """Return the parity of the number of occurrences of a selected symbol."""
    return sum(symbol == counted_symbol for symbol in word) % 2


def first_unary_collision(
    generator: State,
    identity: State,
    multiply: Callable[[State, State], State],
    state_bound: int,
) -> Tuple[int, int, State]:
    """Find i < j <= state_bound with generator**i = generator**j."""
    first_seen: Dict[State, int] = {}
    current = identity
    for exponent in range(state_bound + 1):
        if current in first_seen:
            return first_seen[current], exponent, current
        first_seen[current] = exponent
        current = multiply(current, generator)
    raise ValueError("No collision found; state_bound is smaller than the reachable orbit")


def reachable_quotient_states(
    alphabet: Sequence[Symbol],
    letter_image: Mapping[Symbol, State],
    identity: State,
    multiply: Callable[[State, State], State],
) -> Tuple[Set[State], Dict[Tuple[State, Symbol], State]]:
    """Enumerate the reachable range and its right-action transition graph."""
    reached: Set[State] = {identity}
    transitions: Dict[Tuple[State, Symbol], State] = {}
    queue = deque([identity])
    while queue:
        state = queue.popleft()
        for symbol in alphabet:
            successor = multiply(state, letter_image[symbol])
            transitions[(state, symbol)] = successor
            if successor not in reached:
                reached.add(successor)
                queue.append(successor)
    return reached, transitions


def words_up_to(alphabet: Sequence[Symbol], max_length: int) -> Iterable[Word[Symbol]]:
    """Generate all words over an alphabet through a fixed length."""
    level: List[Word[Symbol]] = [tuple()]
    yield tuple()
    for _ in range(max_length):
        level = [word + (symbol,) for word in level for symbol in alphabet]
        yield from level


def demonstrate_parity_quotient() -> None:
    """Group short words by the parity memory and test erased-set closure."""
    alphabet = ("a", "b")
    classes: Dict[int, List[str]] = {0: [], 1: []}
    for word in words_up_to(alphabet, 3):
        classes[parity_memory(word)].append("".join(word) or "ε")

    erased = [word for word in words_up_to(alphabet, 3) if parity_memory(word) == 0]
    closure_ok = all(parity_memory(u + v) == 0 for u in erased for v in erased)
    print("Parity memory quotient classes (words of length at most 3):")
    print(f"  state 0: {classes[0]}")
    print(f"  state 1: {classes[1]}")
    print(f"  sampled erased-stream closure under concatenation: {closure_ok}\n")


def demonstrate_targeted_forgetting() -> None:
    """Filter a log and exhibit two histories in one observational class."""
    retain = lambda event: event in {"WARN", "ERROR"}
    log_1 = ("INFO", "WARN", "INFO", "ERROR", "WARN")
    log_2 = ("WARN", "ERROR", "WARN")
    filtered_1 = targeted_forgetting(log_1, retain)
    filtered_2 = targeted_forgetting(log_2, retain)
    print("Targeted event forgetting:")
    print(f"  raw log:       {' '.join(log_1)}")
    print(f"  filtered log:  {' '.join(filtered_1)}")
    print(f"  second log:    {' '.join(log_2)}")
    print(f"  indistinguishable after filtering: {filtered_1 == filtered_2}")
    print(f"  filtering is idempotent: {targeted_forgetting(filtered_1, retain) == filtered_1}\n")


def demonstrate_collision_and_quotient() -> None:
    """Find a finite-state collision and enumerate the corresponding quotient range."""
    modulus = 5
    multiply = lambda x, y: (x + y) % modulus
    i, j, state = first_unary_collision(2, 0, multiply, modulus)
    reached, transitions = reachable_quotient_states(
        ("x", "z"), {"x": 2, "z": 0}, 0, multiply
    )
    print("Finite cyclic memory modulo 5:")
    print(f"  first unary collision: M(x^{i}) = M(x^{j}) = {state}")
    print(f"  reachable quotient states: {sorted(reached)}")
    print("  transitions under x:", {s: transitions[(s, "x")] for s in sorted(reached)})
    print(f"  quotient size equals reachable-range size: {len(reached)}\n")


def main() -> None:
    demonstrate_parity_quotient()
    demonstrate_targeted_forgetting()
    demonstrate_collision_and_quotient()


if __name__ == "__main__":
    main()
