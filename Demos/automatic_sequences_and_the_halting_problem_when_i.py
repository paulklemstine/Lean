#!/usr/bin/env python3
"""Numerical demonstrations of bounded witnesses for finite output automata.

The program uses only the Python standard library. It demonstrates:
1. shortest zero-witness search by breadth-first traversal;
2. finite versus infinite accepted languages;
3. Thue--Morse recurrences and the first terms;
4. one hundred distinct output automata with explicit zero witnesses.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Callable, Generic, Hashable, Iterable, Optional, Sequence, TypeVar

State = TypeVar("State", bound=Hashable)
Symbol = TypeVar("Symbol", bound=Hashable)
Output = TypeVar("Output")


@dataclass(frozen=True)
class OutputAutomaton(Generic[State, Symbol, Output]):
    states: tuple[State, ...]
    alphabet: tuple[Symbol, ...]
    start: State
    step: Callable[[State, Symbol], State]
    output: Callable[[State], Output]

    def evaluate(self, word: Iterable[Symbol]) -> Output:
        state = self.start
        for symbol in word:
            state = self.step(state, symbol)
        return self.output(state)


def shortest_output_witness(
    automaton: OutputAutomaton[State, Symbol, Output], target: Output
) -> Optional[tuple[Symbol, ...]]:
    """Return a shortest word producing target, or None if none exists.

    At most one path to each state is retained, so a returned witness has
    length strictly below the number of states.
    """
    queue: deque[tuple[State, tuple[Symbol, ...]]] = deque([(automaton.start, ())])
    seen: set[State] = {automaton.start}
    while queue:
        state, word = queue.popleft()
        if automaton.output(state) == target:
            return word
        for symbol in automaton.alphabet:
            nxt = automaton.step(state, symbol)
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, word + (symbol,)))
    return None


def productive_cycle_exists(
    automaton: OutputAutomaton[State, Symbol, Output], target: Output
) -> bool:
    """Decide whether infinitely many words produce target.

    The language is infinite exactly when a reachable directed cycle can reach
    a target-output state. The implementation computes reachability, reverse
    reachability, and then detects a cycle in their intersection.
    """
    adjacency: dict[State, set[State]] = {q: set() for q in automaton.states}
    reverse: dict[State, set[State]] = {q: set() for q in automaton.states}
    for q in automaton.states:
        for symbol in automaton.alphabet:
            nxt = automaton.step(q, symbol)
            adjacency[q].add(nxt)
            reverse[nxt].add(q)

    reachable: set[State] = set()
    stack = [automaton.start]
    while stack:
        q = stack.pop()
        if q not in reachable:
            reachable.add(q)
            stack.extend(adjacency[q] - reachable)

    can_reach_target: set[State] = set()
    stack = [q for q in automaton.states if automaton.output(q) == target]
    while stack:
        q = stack.pop()
        if q not in can_reach_target:
            can_reach_target.add(q)
            stack.extend(reverse[q] - can_reach_target)

    useful = reachable & can_reach_target
    color: dict[State, int] = {q: 0 for q in useful}

    def has_cycle(q: State) -> bool:
        color[q] = 1
        for nxt in adjacency[q] & useful:
            if color[nxt] == 1:
                return True
            if color[nxt] == 0 and has_cycle(nxt):
                return True
        color[q] = 2
        return False

    return any(color[q] == 0 and has_cycle(q) for q in useful)


def bits(n: int) -> tuple[int, ...]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    return (0,) if n == 0 else tuple(int(c) for c in bin(n)[2:])


def thue_morse(n: int) -> int:
    return sum(bits(n)) % 2


def parity_automaton() -> OutputAutomaton[int, int, int]:
    return OutputAutomaton(
        states=(0, 1), alphabet=(0, 1), start=0,
        step=lambda parity, digit: parity ^ digit,
        output=lambda parity: parity,
    )


def singleton_empty_word_automaton() -> OutputAutomaton[int, int, int]:
    """Output zero only on the empty word; all nonempty words output one."""
    return OutputAutomaton(
        states=(0, 1), alphabet=(0, 1), start=0,
        step=lambda _state, _digit: 1,
        output=lambda state: 0 if state == 0 else 1,
    )


def hundred_test_automaton(index: int) -> OutputAutomaton[int, int, int]:
    if not 0 <= index < 100:
        raise ValueError("index must lie in 0,...,99")
    return OutputAutomaton(
        states=tuple(range(100)), alphabet=(0, 1), start=0,
        step=lambda _state, digit: index if digit == 1 else 0,
        output=lambda state: 0 if state == index else 1,
    )


def run_demo() -> None:
    parity = parity_automaton()
    first = [thue_morse(n) for n in range(32)]
    print("First 32 Thue--Morse terms:")
    print("".join(map(str, first)))
    assert all(thue_morse(2 * n) == thue_morse(n) for n in range(1000))
    assert all(thue_morse(2 * n + 1) == 1 - thue_morse(n) for n in range(1000))
    print("Binary recurrences checked numerically for n = 0,...,999.")

    zero_word = shortest_output_witness(parity, 0)
    one_word = shortest_output_witness(parity, 1)
    print(f"Shortest parity-0 word: {zero_word}; shortest parity-1 word: {one_word}")
    assert zero_word is not None and len(zero_word) < len(parity.states)
    assert one_word is not None and len(one_word) < len(parity.states)
    assert productive_cycle_exists(parity, 0)
    assert productive_cycle_exists(parity, 1)

    singleton = singleton_empty_word_automaton()
    assert shortest_output_witness(singleton, 0) == ()
    assert not productive_cycle_exists(singleton, 0)
    print("Singleton example: zero occurs, but only on the empty word.")

    witnesses: list[tuple[int, ...]] = []
    signatures: set[tuple[int, ...]] = set()
    for i in range(100):
        machine = hundred_test_automaton(i)
        assert machine.evaluate((1,)) == 0
        witness = shortest_output_witness(machine, 0)
        assert witness is not None and len(witness) < 100
        witnesses.append(witness)
        signatures.add(tuple(machine.output(q) for q in machine.states))
    assert len(signatures) == 100
    print("All 100 distinct test automata have a zero witness of length below 100.")
    print(f"Observed shortest-witness lengths: {sorted(set(map(len, witnesses)))}")


if __name__ == "__main__":
    run_demo()
