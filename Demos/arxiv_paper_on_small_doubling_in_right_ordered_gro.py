#!/usr/bin/env python3
"""Numerical demonstrations of finite memory, quotient classes, and filtering."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from itertools import product
from typing import Callable, DefaultDict, Dict, Hashable, Iterable, List, Sequence, Tuple, TypeVar

Symbol = TypeVar("Symbol", bound=Hashable)
State = TypeVar("State", bound=Hashable)
Word = Tuple[Symbol, ...]


def targeted_forgetting(word: Sequence[Symbol], retain: Callable[[Symbol], bool]) -> Word[Symbol]:
    """Return the order-preserving subsequence of retained symbols in O(len(word))."""
    return tuple(symbol for symbol in word if retain(symbol))


def words_up_to(alphabet: Sequence[Symbol], max_length: int) -> Iterable[Word[Symbol]]:
    """Generate every word over alphabet having length at most max_length."""
    if max_length < 0:
        raise ValueError("max_length must be nonnegative")
    for length in range(max_length + 1):
        yield from product(alphabet, repeat=length)


def quotient_classes(
    alphabet: Sequence[Symbol],
    max_length: int,
    memory: Callable[[Word[Symbol]], State],
) -> Dict[State, List[Word[Symbol]]]:
    """Group bounded-length words into observational classes by memory value."""
    classes: DefaultDict[State, List[Word[Symbol]]] = defaultdict(list)
    for word in words_up_to(alphabet, max_length):
        classes[memory(word)].append(word)
    return dict(classes)


def first_repeated_symbol_collision(
    symbol: Symbol,
    identity: State,
    step: Callable[[State, Symbol], State],
    state_count: int,
) -> Tuple[Word[Symbol], Word[Symbol], State]:
    """Find a collision among powers from exponent 0 through state_count."""
    if state_count < 1:
        raise ValueError("state_count must be positive")
    seen: Dict[State, int] = {identity: 0}
    state = identity
    for exponent in range(1, state_count + 1):
        state = step(state, symbol)
        if state in seen:
            earlier = seen[state]
            return ((symbol,) * earlier, (symbol,) * exponent, state)
        seen[state] = exponent
    raise RuntimeError("No collision found; declared state_count is inconsistent")


def format_word(word: Sequence[str]) -> str:
    """Render the empty word as epsilon and other words by concatenation."""
    return "ε" if not word else "".join(word)


def demonstrate_targeted_forgetting() -> None:
    alphabet = ("a", "b", "c")
    retain = lambda symbol: symbol != "b"
    source = tuple("abbcba")
    filtered = targeted_forgetting(source, retain)
    print("1. Targeted forgetting")
    print(f"   {format_word(source)} -> {format_word(filtered)} (retain a and c)")
    left, right = tuple("abb"), tuple("cba")
    law_holds = targeted_forgetting(left + right, retain) == (
        targeted_forgetting(left, retain) + targeted_forgetting(right, retain)
    )
    print(f"   Concatenation law on abb | cba: {law_holds}")
    print(f"   Forgotten generator b maps to: {format_word(targeted_forgetting(('b',), retain))}")


def demonstrate_finite_collision() -> None:
    modulus = 5
    step = lambda state, _symbol: (state + 1) % modulus
    u, v, state = first_repeated_symbol_collision("a", 0, step, modulus)
    print("\n2. Finite-memory collision")
    print(f"   Length modulo {modulus} sends {format_word(u)} and {format_word(v)} to {state}.")
    print(f"   The streams are distinct: {u != v}")


def demonstrate_quotient() -> None:
    alphabet = ("a", "b")
    memory = lambda word: len(word) % 2
    classes = quotient_classes(alphabet, 3, memory)
    print("\n3. Bounded observational quotient for parity memory")
    for state in sorted(classes):
        rendered = ", ".join(format_word(word) for word in classes[state])
        print(f"   State {state}: {rendered}")
    erased = classes[0]
    closure_examples = [u + v for u in erased for v in erased if len(u + v) <= 3]
    closure_ok = all(memory(word) == 0 for word in closure_examples)
    print(f"   Tested erased-stream closure within the length bound: {closure_ok}")


def main() -> None:
    demonstrate_targeted_forgetting()
    demonstrate_finite_collision()
    demonstrate_quotient()


if __name__ == "__main__":
    main()
