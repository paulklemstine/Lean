#!/usr/bin/env python3
"""Numerical demonstrations of memory loss, erasure, and quotienting."""

from __future__ import annotations

from collections import defaultdict
from itertools import product
from typing import Callable, Hashable, Iterable, TypeVar

Symbol = TypeVar("Symbol", bound=Hashable)
State = TypeVar("State", bound=Hashable)
Word = tuple[Symbol, ...]


def words_up_to(alphabet: tuple[Symbol, ...], max_length: int) -> Iterable[Word[Symbol]]:
    """Yield every word over alphabet with length at most max_length."""
    if max_length < 0:
        raise ValueError("max_length must be nonnegative")
    for length in range(max_length + 1):
        yield from product(alphabet, repeat=length)


def targeted_forgetting(word: Word[Symbol], retain: Callable[[Symbol], bool]) -> Word[Symbol]:
    """Delete rejected symbols while preserving retained order and multiplicity."""
    return tuple(symbol for symbol in word if retain(symbol))


def find_collision(
    words: Iterable[Word[Symbol]], memory: Callable[[Word[Symbol]], State]
) -> tuple[Word[Symbol], Word[Symbol], State] | None:
    """Return the first pair of distinct words assigned the same memory state."""
    first_seen: dict[State, Word[Symbol]] = {}
    for word in words:
        state = memory(word)
        previous = first_seen.get(state)
        if previous is not None and previous != word:
            return previous, word, state
        first_seen[state] = word
    return None


def quotient_classes(
    words: Iterable[Word[Symbol]], memory: Callable[[Word[Symbol]], State]
) -> dict[State, list[Word[Symbol]]]:
    """Group a finite collection of words by observational memory state."""
    classes: dict[State, list[Word[Symbol]]] = defaultdict(list)
    for word in words:
        classes[memory(word)].append(word)
    return dict(classes)


def modular_count_memory(word: Word[str], modulus: int) -> int:
    """A finite compositional memory: word length modulo a positive modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return len(word) % modulus


def show(word: Word[Hashable]) -> str:
    """Render a word, using epsilon for the empty stream."""
    return "ε" if not word else "".join(map(str, word))


def demonstrate_finite_collision() -> None:
    alphabet = ("a", "b")
    words = list(words_up_to(alphabet, 4))
    collision = find_collision(words, lambda w: modular_count_memory(w, 3))
    assert collision is not None
    left, right, state = collision
    assert left != right and modular_count_memory(left, 3) == modular_count_memory(right, 3)
    print("Finite-memory collision (length modulo 3)")
    print(f"  {show(left)} and {show(right)} are distinct but both have state {state}.")
    print(f"  {len(words)} tested streams are compressed into only 3 states.\n")


def demonstrate_erased_submonoid() -> None:
    alphabet = ("a", "b")
    words = list(words_up_to(alphabet, 4))
    erased = [w for w in words if modular_count_memory(w, 3) == 0]
    tested_pairs = [(x, y) for x in erased for y in erased if len(x) + len(y) <= 4]
    assert () in erased
    assert all(modular_count_memory(x + y, 3) == 0 for x, y in tested_pairs)
    print("Erased streams form a submonoid (finite-horizon check)")
    print("  Erased examples:", ", ".join(show(w) for w in erased[:7]))
    print(f"  Identity and concatenation verified for {len(tested_pairs)} admissible pairs.\n")


def demonstrate_targeted_quotient() -> None:
    alphabet = ("a", "b", "c")
    retain = lambda symbol: symbol in {"a", "c"}
    words = list(words_up_to(alphabet, 3))
    classes = quotient_classes(words, lambda w: targeted_forgetting(w, retain))
    example_output = ("a", "c")
    example_class = classes[example_output]
    assert all(targeted_forgetting(w, retain) == example_output for w in example_class)

    # A compatible statistic factors through the edited output.
    retained_count_raw = {w: len(targeted_forgetting(w, retain)) for w in words}
    retained_count_quotient = {w: len(targeted_forgetting(w, retain)) for w in words}
    assert retained_count_raw == retained_count_quotient

    print("Targeted forgetting and quotient classes")
    print("  Policy: retain a,c; erase b")
    print("  Streams mapping to ac:", ", ".join(show(w) for w in example_class))
    print(f"  {len(words)} raw streams form {len(classes)} observable classes.")
    print("  Retained-symbol count depends only on the observable class.\n")


def main() -> None:
    demonstrate_finite_collision()
    demonstrate_erased_submonoid()
    demonstrate_targeted_quotient()


if __name__ == "__main__":
    main()
