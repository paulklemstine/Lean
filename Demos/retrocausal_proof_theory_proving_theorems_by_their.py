#!/usr/bin/env python3
"""Numerical demonstrations of consequence-guided finite search.

The program illustrates contraction, strict reduction, target retention,
unique isolation, and information gain. It uses only the Python standard
library and can be run directly with ``python3 demo.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import log2
from typing import Callable, Generic, Iterable, Sequence, TypeVar

T = TypeVar("T")
Check = Callable[[T], bool]


@dataclass(frozen=True)
class CheckSpec(Generic[T]):
    """A named deterministic predicate used to filter candidates."""

    name: str
    predicate: Check[T]


@dataclass(frozen=True)
class FilterResult(Generic[T]):
    """The survivors and cardinality statistics of one filtering run."""

    initial: tuple[T, ...]
    survivors: tuple[T, ...]
    evaluations: int

    @property
    def compression_ratio(self) -> float:
        """Return |survivors| / |initial|, with 0 for an empty input."""
        return len(self.survivors) / len(self.initial) if self.initial else 0.0

    @property
    def information_gain_bits(self) -> float | None:
        """Return log2(|initial| / |survivors|), undefined if none survive."""
        if not self.initial or not self.survivors:
            return None
        return log2(len(self.initial) / len(self.survivors))


def filter_candidates(
    candidates: Iterable[T], checks: Sequence[CheckSpec[T]]
) -> FilterResult[T]:
    """Retain exactly the candidates passing every check.

    Checks are short-circuited at the first failure. With N candidates and M
    checks, the worst-case running time is O(NM), and output storage is O(|S|).
    """
    initial = tuple(candidates)
    survivors: list[T] = []
    evaluations = 0
    for candidate in initial:
        passes = True
        for check in checks:
            evaluations += 1
            if not check.predicate(candidate):
                passes = False
                break
        if passes:
            survivors.append(candidate)
    return FilterResult(initial, tuple(survivors), evaluations)


def passing_matrix(
    candidates: Sequence[T], checks: Sequence[CheckSpec[T]]
) -> list[list[bool]]:
    """Evaluate every candidate/check pair for an explanatory table."""
    return [[check.predicate(candidate) for check in checks] for candidate in candidates]


def unique_survivor_certificate(
    candidate: T, target: T, checks: Sequence[CheckSpec[T]]
) -> bool:
    """Numerically test the implication 'all checks pass => candidate=target'."""
    return not all(check.predicate(candidate) for check in checks) or candidate == target


def print_six_demo() -> None:
    """Show how three arithmetic checks isolate 6 below 8."""
    candidates = tuple(range(8))
    checks = (
        CheckSpec[int]("n > 0", lambda n: n > 0),
        CheckSpec[int]("2 divides n", lambda n: n % 2 == 0),
        CheckSpec[int]("3 divides n", lambda n: n % 3 == 0),
    )
    matrix = passing_matrix(candidates, checks)
    result = filter_candidates(candidates, checks)

    print("Arithmetic calibration: isolate 6 among 0,...,7")
    print("n | " + " | ".join(f"{check.name:^11}" for check in checks) + " | survives")
    print("--+" + "+".join("-" * 13 for _ in checks) + "+---------")
    for n, row in zip(candidates, matrix):
        marks = " | ".join(f"{'yes' if value else 'no':^11}" for value in row)
        print(f"{n} | {marks} | {'yes' if all(row) else 'no'}")

    print(f"\nInitial candidates: {result.initial}")
    print(f"Survivors:          {result.survivors}")
    print(f"Cardinalities:      {len(result.initial)} -> {len(result.survivors)}")
    print(f"Survivor ratio:     {result.compression_ratio:.3f} = 1/8")
    print(f"Information gain:   {result.information_gain_bits:.1f} bits")
    print(f"Short-circuit predicate evaluations: {result.evaluations}")

    assert result.survivors == (6,)
    assert all(unique_survivor_certificate(n, 6, checks) for n in candidates)


def print_boundary_demo() -> None:
    """Display the uninformative always-true control on Boolean candidates."""
    candidates = (False, True)
    true_control = (CheckSpec[bool]("always true", lambda _p: True),)
    result = filter_candidates(candidates, true_control)
    print("\nAlways-true control")
    print(f"Candidates representing false and true propositions: {candidates}")
    print(f"Both pass the verified coherent control:             {result.survivors}")
    print("Therefore the control cannot recover which candidate is true.")
    assert result.survivors == candidates


def main() -> None:
    print_boundary_demo()
    print_six_demo()


if __name__ == "__main__":
    main()
