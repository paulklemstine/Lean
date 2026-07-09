"""Minimal-Obstruction Detection via the Proper-Minor Down-Set.

Implements the dictionary test of `singleExcludedMinor_iff_obstructions_singleton`
and `obstructions_excl_singleton`: a minor-closed class C is a single-forbidden-minor
class iff it has exactly one minimal obstruction.
"""
from __future__ import annotations

from typing import Callable, Iterable, List, TypeVar

T = TypeVar("T")


def is_minimal_obstruction(
    m: T,
    in_C: Callable[[T], bool],
    proper_minors: Callable[[T], Iterable[T]],
) -> bool:
    """True iff m is a minimal obstruction of C: m not in C but every proper
    minor x < m is in C."""
    if in_C(m):
        return False
    return all(in_C(x) for x in proper_minors(m))


def obstruction_set(
    candidates: Iterable[T],
    in_C: Callable[[T], bool],
    proper_minors: Callable[[T], Iterable[T]],
) -> List[T]:
    return [m for m in candidates if is_minimal_obstruction(m, in_C, proper_minors)]


def is_single_forbidden_minor(
    candidates: Iterable[T],
    in_C: Callable[[T], bool],
    proper_minors: Callable[[T], Iterable[T]],
) -> bool:
    """C is defined by a single forbidden minor iff |obstructions(C)| == 1."""
    return len(obstruction_set(candidates, in_C, proper_minors)) == 1


if __name__ == "__main__":
    # Toy total order on {0,1,2,3} with C = excl({2}) = {x | not (2 <= x)} = {0,1}.
    universe = [0, 1, 2, 3]
    in_C = lambda x: x < 2
    proper_minors = lambda x: range(x)  # y < x
    print(obstruction_set(universe, in_C, proper_minors))      # [2]
    print(is_single_forbidden_minor(universe, in_C, proper_minors))  # True
