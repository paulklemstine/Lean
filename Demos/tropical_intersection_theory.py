#!/usr/bin/env python3
"""Numerical demonstrations for finite tropical intersection theory.

The script uses only the Python standard library.  It enumerates the transverse
plane model, audits arbitrary positive multiplicities, and checks a labeled
support- and multiplicity-preserving correspondence.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, Iterable, List, Mapping, Sequence, Tuple, TypeVar

Point = Tuple[int, int]
A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


@dataclass(frozen=True)
class IntersectionAudit:
    """Summary of a finite supported multiplicity list."""

    support_size: int
    intersection_number: int
    all_positive: bool
    support_bound_holds: bool
    equality_holds: bool


def transverse_plane_intersection(d: int, e: int) -> Dict[Point, int]:
    """Return all degree-direction pairs, each with multiplicity one.

    The output has exactly d*e entries.  Negative degrees are rejected.
    """
    if d < 0 or e < 0:
        raise ValueError("degrees must be nonnegative")
    return {(i, j): 1 for i in range(d) for j in range(e)}


def weighted_intersection_number(multiplicities: Iterable[int]) -> int:
    """Sum nonnegative local multiplicities."""
    values = list(multiplicities)
    if any(not isinstance(value, int) or isinstance(value, bool) or value < 0
           for value in values):
        raise ValueError("multiplicities must be nonnegative integers")
    return sum(values)


def audit_intersection(multiplicities: Sequence[int]) -> IntersectionAudit:
    """Check positivity, the support bound, and its equality case."""
    if any(not isinstance(value, int) or isinstance(value, bool) or value < 0
           for value in multiplicities):
        raise ValueError("multiplicities must be nonnegative integers")
    support_size = len(multiplicities)
    total = sum(multiplicities)
    all_positive = all(value > 0 for value in multiplicities)
    bound_holds = all_positive and support_size <= total
    equality_holds = all_positive and support_size == total
    return IntersectionAudit(
        support_size=support_size,
        intersection_number=total,
        all_positive=all_positive,
        support_bound_holds=bound_holds,
        equality_holds=equality_holds,
    )


def correspondence_preserves_number(
    classical: Mapping[A, int],
    tropical: Mapping[B, int],
    point_map: Callable[[A], B],
) -> bool:
    """Audit a bijective, multiplicity-preserving map of supported points.

    The dictionaries represent finite supports and their local multiplicities.
    The function returns True exactly when mapped support labels are distinct,
    fill the tropical support, preserve every multiplicity, and hence have equal
    weighted totals.
    """
    if any(value < 0 for value in classical.values()):
        raise ValueError("classical multiplicities must be nonnegative")
    if any(value < 0 for value in tropical.values()):
        raise ValueError("tropical multiplicities must be nonnegative")

    mapped: List[B] = [point_map(point) for point in classical]
    support_bijection = (
        len(set(mapped)) == len(mapped)
        and set(mapped) == set(tropical)
    )
    if not support_bijection:
        return False
    local_weights_match = all(
        classical[point] == tropical[point_map(point)] for point in classical
    )
    return local_weights_match and sum(classical.values()) == sum(tropical.values())


def format_grid(d: int, e: int) -> str:
    """Create a compact text grid of the d-by-e transverse cells."""
    model = transverse_plane_intersection(d, e)
    if not model:
        return "(empty transverse intersection)"
    return "\n".join(
        "  ".join(f"({i},{j}):{model[(i, j)]}" for j in range(e))
        for i in range(d)
    )


def run_examples() -> None:
    """Print representative computations and assert all stated identities."""
    print("FINITE TROPICAL INTERSECTION DEMONSTRATION")
    print("=" * 48)

    for d, e in [(3, 4), (2, 5), (0, 7)]:
        model = transverse_plane_intersection(d, e)
        total = weighted_intersection_number(model.values())
        assert len(model) == d * e
        assert total == d * e
        print(f"\nDegrees ({d}, {e}):")
        print(format_grid(d, e))
        print(f"support cells = {len(model)}, weighted total = {total}, d*e = {d * e}")

    print("\nPositive-multiplicity support bound:")
    for values in ([1, 1, 1, 1], [1, 2, 3, 4], [2, 5, 1]):
        audit = audit_intersection(values)
        assert audit.support_bound_holds
        assert audit.equality_holds == all(value == 1 for value in values)
        print(f"multiplicities={list(values)} -> {audit}")

    # Relabel the 2-by-3 tropical cells as six ordinary point names.
    tropical = transverse_plane_intersection(2, 3)
    names = ["P", "Q", "R", "S", "T", "U"]
    cells = sorted(tropical)
    relabel = dict(zip(names, cells))
    classical = {name: tropical[relabel[name]] for name in names}
    preserved = correspondence_preserves_number(
        classical, tropical, lambda name: relabel[name]
    )
    assert preserved
    assert sum(classical.values()) == 2 * 3
    print("\nMultiplicity-preserving correspondence:")
    print(f"ordinary labels -> tropical cells: {relabel}")
    print(f"preserves weighted number: {preserved}; total = {sum(classical.values())}")


if __name__ == "__main__":
    run_examples()
