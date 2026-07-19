#!/usr/bin/env python3
"""Numerical demonstrations of functional fibers, integrated information, and forgetting."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, product
from typing import Callable, Dict, Hashable, Iterable, List, Mapping, Sequence, Tuple, TypeVar

T = TypeVar("T", bound=Hashable)
State = TypeVar("State", bound=Hashable)


@dataclass(frozen=True)
class SheetWorld:
    """A profile together with a hidden experience-presence bit."""

    profile: str
    present: bool

    @property
    def behavior(self) -> str:
        return self.profile

    @property
    def experience(self) -> str | None:
        return f"experience({self.profile})" if self.present else None


@dataclass(frozen=True)
class GapPair:
    """Canonical experiential and semantic witnesses over one profile."""

    alive: SheetWorld
    zombie: SheetWorld
    true_unaccepted_code: Tuple[str, bool]


def canonical_gap_pairs(profiles: Sequence[str]) -> List[GapPair]:
    """Construct the unique canonical zombie and semantic witness per profile."""
    return [
        GapPair(SheetWorld(x, True), SheetWorld(x, False), (x, False))
        for x in profiles
    ]


def nontrivial_cuts(n: int) -> Iterable[Tuple[int, ...]]:
    """Enumerate all nonempty proper subsets of range(n)."""
    if n < 2:
        return
    for size in range(1, n):
        yield from combinations(range(n), size)


def minimum_information_partition(
    n: int, effective_information: Callable[[Tuple[int, ...]], float]
) -> Tuple[Tuple[int, ...], float]:
    """Return an attaining cut and the minimum effective-information value."""
    if n < 2:
        raise ValueError("A nontrivial cut requires at least two components")
    cut = min(nontrivial_cuts(n), key=effective_information)
    return cut, effective_information(cut)


def targeted_forget(stream: Sequence[T], retained: set[T]) -> Tuple[T, ...]:
    """Delete exactly the symbols not included in retained."""
    return tuple(symbol for symbol in stream if symbol in retained)


def memory_collision(
    streams: Iterable[Tuple[T, ...]], memory: Callable[[Tuple[T, ...]], State]
) -> Tuple[Tuple[T, ...], Tuple[T, ...], State] | None:
    """Find the first two distinct streams mapped to the same memory state."""
    seen: Dict[State, Tuple[T, ...]] = {}
    for stream in streams:
        state = memory(stream)
        previous = seen.get(state)
        if previous is not None and previous != stream:
            return previous, stream, state
        seen[state] = stream
    return None


def quotient_classes(
    streams: Iterable[Tuple[T, ...]], memory: Callable[[Tuple[T, ...]], State]
) -> Mapping[State, List[Tuple[T, ...]]]:
    """Group finite sample streams into observational equivalence classes."""
    classes: Dict[State, List[Tuple[T, ...]]] = {}
    for stream in streams:
        classes.setdefault(memory(stream), []).append(stream)
    return classes


def all_binary_streams(max_length: int) -> List[Tuple[str, ...]]:
    """Enumerate binary streams through a chosen length."""
    alphabet = ("a", "b")
    return [word for length in range(max_length + 1) for word in product(alphabet, repeat=length)]


def run_demo() -> None:
    """Run all numerical examples and assert their defining properties."""
    print("=== 1. Canonical functional and semantic fibers ===")
    pairs = canonical_gap_pairs(["red-report", "pain-avoidance", "self-model"])
    for pair in pairs:
        assert pair.alive.behavior == pair.zombie.behavior
        assert pair.alive.experience != pair.zombie.experience
        code_profile, accepted = pair.true_unaccepted_code
        truth = True
        assert code_profile == pair.alive.profile and truth and not accepted
        print(
            f"profile={pair.alive.profile:14s} behavior equal=True, "
            f"experience contrast=True, semantic gap=True"
        )

    print("\n=== 2. Minimum-information partition ===")
    weights = (0.7, 1.1, 1.8, 2.4)

    def information(cut: Tuple[int, ...]) -> float:
        # A symmetric toy landscape: separation cost plus a small balance penalty.
        left = sum(weights[i] for i in cut)
        right = sum(weights) - left
        return round(abs(left - right) + 0.15 * len(cut) * (len(weights) - len(cut)), 6)

    cut, phi = minimum_information_partition(len(weights), information)
    values = [information(candidate) for candidate in nontrivial_cuts(len(weights))]
    assert phi == min(values) and phi >= 0.0
    print(f"evaluated cuts={len(values)}, minimizing cut={cut}, Phi={phi:.3f}")
    shifted_cut, shifted_phi = minimum_information_partition(
        len(weights), lambda candidate: information(candidate) + 0.5
    )
    assert shifted_phi >= phi
    print(f"after pointwise +0.5 shift: cut={shifted_cut}, Phi={shifted_phi:.3f}")

    print("\n=== 3. Finite memory and quotient classes ===")
    streams = all_binary_streams(4)

    def two_bit_memory(stream: Tuple[str, ...]) -> Tuple[int, int]:
        # A four-state compositional memory: parity of each symbol count.
        return (stream.count("a") % 2, stream.count("b") % 2)

    collision = memory_collision(streams, two_bit_memory)
    assert collision is not None
    first, second, state = collision
    print(f"{len(streams)} streams mapped into 4 states")
    print(f"collision: {first} and {second} both map to {state}")
    classes = quotient_classes(streams, two_bit_memory)
    assert len(classes) == 4
    print("sample quotient class sizes:", {key: len(value) for key, value in classes.items()})

    print("\n=== 4. Targeted forgetting ===")
    stream = ("keep", "erase", "keep", "erase", "keep")
    output = targeted_forget(stream, {"keep"})
    assert output == ("keep", "keep", "keep")
    assert targeted_forget(("erase",), {"keep"}) == ()
    print(f"input={stream}")
    print(f"retained output={output}; forgotten singleton maps to the empty stream")


if __name__ == "__main__":
    run_demo()
