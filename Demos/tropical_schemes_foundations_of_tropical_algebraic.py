#!/usr/bin/env python3
"""Numerical demonstrations of corner loci, bend equations, and sheaf gluing.

The script uses only the Python standard library.  It verifies on finite sample
sets that a point has two minimizing terms exactly when every term has a
replacement of no larger value, prints the standard tropical line on an ASCII
grid, and glues compatible local semiring-valued functions.
"""

from __future__ import annotations

from collections.abc import Callable, Hashable, Iterable, Mapping, Sequence
from typing import TypeVar

Point = TypeVar("Point")
Value = TypeVar("Value")
Key = TypeVar("Key", bound=Hashable)


def minimizing_indices(values: Sequence[float], tolerance: float = 1e-9) -> list[int]:
    """Return all indices attaining the minimum, up to a numerical tolerance."""
    if not values:
        raise ValueError("a tropical polynomial must have at least one term")
    minimum = min(values)
    return [i for i, value in enumerate(values) if abs(value - minimum) <= tolerance]


def is_corner(values: Sequence[float], tolerance: float = 1e-9) -> bool:
    """Decide whether at least two terms attain the minimum."""
    return len(minimizing_indices(values, tolerance)) >= 2


def bend_witnesses(values: Sequence[float], tolerance: float = 1e-9) -> list[int] | None:
    """Find a distinct no-larger replacement for every term, or return None."""
    witnesses: list[int] = []
    for i, value_i in enumerate(values):
        witness = next(
            (j for j, value_j in enumerate(values)
             if j != i and value_j <= value_i + tolerance),
            None,
        )
        if witness is None:
            return None
        witnesses.append(witness)
    return witnesses


def all_bend_equations_hold(values: Sequence[float], tolerance: float = 1e-9) -> bool:
    """Decide simultaneous satisfaction of all term-deletion bend equations."""
    return bend_witnesses(values, tolerance) is not None


def evaluate_terms(
    terms: Sequence[Callable[[Point], float]], point: Point
) -> list[float]:
    """Evaluate every tropical term at a point."""
    return [term(point) for term in terms]


def glue_sections(sections: Iterable[Mapping[Key, Value]]) -> dict[Key, Value]:
    """Glue compatible partial functions; reject disagreement on an overlap."""
    glued: dict[Key, Value] = {}
    for section in sections:
        for point, value in section.items():
            if point in glued and glued[point] != value:
                raise ValueError(
                    f"incompatible local values at {point!r}: "
                    f"{glued[point]!r} and {value!r}"
                )
            glued[point] = value
    return glued


def demonstrate_two_term_crossing() -> None:
    """Show that min(0,x) has bend support exactly at x=0."""
    terms: list[Callable[[int], float]] = [lambda _x: 0.0, lambda x: float(x)]
    print("Two-term polynomial F(x) = min(0, x)")
    print(" x | values   | minimizers | corner | all bends | witnesses")
    print("---+----------+------------+--------+-----------+----------")
    selected: list[int] = []
    for x in range(-4, 5):
        values = evaluate_terms(terms, x)
        mins = minimizing_indices(values)
        corner = is_corner(values)
        bends = all_bend_equations_hold(values)
        witnesses = bend_witnesses(values)
        assert corner == bends
        if bends:
            selected.append(x)
        print(f"{x:2d} | {str(values):8s} | {str(mins):10s} | {str(corner):6s} "
              f"| {str(bends):9s} | {witnesses}")
    assert selected == [0]
    print(f"Bend support = corner locus = {selected}\n")


def demonstrate_tropical_line() -> None:
    """Render a sampled corner locus of min(0,x,y) as an ASCII diagram."""
    terms: list[Callable[[tuple[int, int]], float]] = [
        lambda _point: 0.0,
        lambda point: float(point[0]),
        lambda point: float(point[1]),
    ]
    print("Standard tropical line F(x,y) = min(0, x, y)")
    print("# marks points with at least two minimizing terms.\n")
    for y in range(4, -5, -1):
        row = []
        for x in range(-4, 5):
            values = evaluate_terms(terms, (x, y))
            assert is_corner(values) == all_bend_equations_hold(values)
            row.append("#" if is_corner(values) else ".")
        print(f"{y:2d}  {' '.join(row)}")
    print("    " + " ".join(f"{x:+d}" for x in range(-4, 5)))
    print()


def demonstrate_gluing() -> None:
    """Glue compatible local sections and expose an incompatible overlap."""
    left = {"a": 2, "b": -1}
    right = {"b": -1, "c": 4}
    glued = glue_sections([left, right])
    assert glued == {"a": 2, "b": -1, "c": 4}
    print("Compatible local sections:")
    print(f"  {left} and {right}")
    print(f"Unique gluing: {glued}")

    incompatible = {"b": 3, "c": 4}
    try:
        glue_sections([left, incompatible])
    except ValueError as error:
        print(f"Expected overlap conflict: {error}")
    else:
        raise AssertionError("incompatible sections were incorrectly glued")


def main() -> None:
    demonstrate_two_term_crossing()
    demonstrate_tropical_line()
    demonstrate_gluing()
    print("All sampled corner–bend equivalences and gluing checks passed.")


if __name__ == "__main__":
    main()
