#!/usr/bin/env python3
"""Numerical demonstrations of finite-state behavioral identity.

The script uses only the Python standard library.  It compares three Moore
machines, computes their greatest bisimulation, finds shortest distinguishing
words, and verifies the fixed-length identity count on small bit budgets.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from itertools import product
from typing import Callable, Generic, Hashable, Iterable, Optional, Sequence, TypeVar

I = TypeVar("I", bound=Hashable)
S = TypeVar("S", bound=Hashable)
T = TypeVar("T", bound=Hashable)
O = TypeVar("O", bound=Hashable)


@dataclass(frozen=True)
class MooreMachine(Generic[I, S, O]):
    """A deterministic finite Moore machine."""

    inputs: tuple[I, ...]
    states: tuple[S, ...]
    step: Callable[[S, I], S]
    observe: Callable[[S], O]

    def run(self, initial: S, word: Iterable[I]) -> S:
        state = initial
        for symbol in word:
            state = self.step(state, symbol)
        return state

    def output(self, initial: S, word: Iterable[I]) -> O:
        return self.observe(self.run(initial, word))


def greatest_bisimulation(
    left: MooreMachine[I, S, O], right: MooreMachine[I, T, O]
) -> set[tuple[S, T]]:
    """Compute the greatest cross-machine bisimulation by deletion."""
    if left.inputs != right.inputs:
        raise ValueError("machines must use the same ordered input alphabet")
    relation = {
        (s, t)
        for s in left.states
        for t in right.states
        if left.observe(s) == right.observe(t)
    }
    changed = True
    while changed:
        changed = False
        invalid = {
            (s, t)
            for (s, t) in relation
            if any((left.step(s, a), right.step(t, a)) not in relation for a in left.inputs)
        }
        if invalid:
            relation.difference_update(invalid)
            changed = True
    return relation


def shortest_distinguishing_word(
    left: MooreMachine[I, S, O],
    right: MooreMachine[I, T, O],
    left_initial: S,
    right_initial: T,
) -> Optional[tuple[I, ...]]:
    """Return a shortest history with different outputs, or None if equivalent."""
    if left.inputs != right.inputs:
        raise ValueError("machines must use the same ordered input alphabet")
    queue: deque[tuple[S, T, tuple[I, ...]]] = deque(
        [(left_initial, right_initial, ())]
    )
    visited: set[tuple[S, T]] = {(left_initial, right_initial)}
    while queue:
        s, t, word = queue.popleft()
        if left.observe(s) != right.observe(t):
            return word
        for symbol in left.inputs:
            pair = (left.step(s, symbol), right.step(t, symbol))
            if pair not in visited:
                visited.add(pair)
                queue.append((pair[0], pair[1], word + (symbol,)))
    return None


def enumerate_words(alphabet: Sequence[I], max_length: int) -> Iterable[tuple[I, ...]]:
    """Enumerate all words up to a chosen length."""
    for length in range(max_length + 1):
        yield from product(alphabet, repeat=length)


def identity_descriptions(bits: int) -> list[str]:
    """Enumerate all fixed-length bit descriptions for a small bit budget."""
    if bits < 0:
        raise ValueError("bits must be nonnegative")
    return ["".join(map(str, word)) for word in product((0, 1), repeat=bits)]


def main() -> None:
    alphabet = (False, True)
    parity = MooreMachine(
        inputs=alphabet,
        states=(False, True),
        step=lambda state, symbol: state ^ symbol,
        observe=lambda state: state,
    )
    silent = MooreMachine(
        inputs=alphabet,
        states=(None,),
        step=lambda _state, _symbol: None,
        observe=lambda _state: False,
    )
    redundant_silent = MooreMachine(
        inputs=alphabet,
        states=(False, True),
        step=lambda state, symbol: state ^ symbol,
        observe=lambda _state: False,
    )

    histories = [(), (True,), (True, True), (True, False, True)]
    outputs = [parity.output(False, word) for word in histories]
    print("Parity outputs on representative histories:", outputs)

    witness = shortest_distinguishing_word(parity, silent, False, None)
    print("Shortest parity/silent distinguishing history:", witness)

    relation = greatest_bisimulation(redundant_silent, silent)
    print("Greatest redundant-silent/silent bisimulation:", relation)
    print("Initial states equivalent:", (False, None) in relation)

    print("\nAll words through length 4 for the two silent implementations:")
    for word in enumerate_words(alphabet, 4):
        left_output = redundant_silent.output(False, word)
        right_output = silent.output(None, word)
        assert left_output == right_output
    print("Every tested output agrees; the bisimulation proves agreement for all lengths.")

    bits = 4
    descriptions = identity_descriptions(bits)
    print(f"\n{bits}-bit descriptions ({len(descriptions)} = 2^{bits}):")
    print(descriptions)
    assert len(descriptions) == 2**bits


if __name__ == "__main__":
    main()
