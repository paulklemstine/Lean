#!/usr/bin/env python3
"""Numerical demonstrations for bounded-fiber rectangle certificates.

The examples illustrate the certified counting implications. They do not claim
to provide endpoint coordinates for the proposed 64-rectangle realization.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from typing import Hashable, Iterable, Mapping, Sequence, TypeVar

T = TypeVar("T", bound=Hashable)


@dataclass(frozen=True)
class Rectangle:
    """A closed axis-parallel rectangle with rational-compatible coordinates."""

    left: float
    right: float
    bottom: float
    top: float

    def __post_init__(self) -> None:
        if self.left > self.right or self.bottom > self.top:
            raise ValueError("Rectangle endpoints are out of order")

    def intersects(self, other: "Rectangle") -> bool:
        """Return whether two closed rectangles have a common point."""
        return not (
            self.right < other.left
            or other.right < self.left
            or self.top < other.bottom
            or other.top < self.bottom
        )


def bounded_fiber_total(capacities: Mapping[T, int]) -> int:
    """Return the cardinality upper bound obtained by summing capacities."""
    if any(capacity < 0 for capacity in capacities.values()):
        raise ValueError("Capacities must be nonnegative")
    return sum(capacities.values())


def triangle_free_piercing_lower_bound(member_count: int) -> int:
    """Minimum forced transversal size when every point has depth at most two."""
    if member_count < 0:
        raise ValueError("Member count must be nonnegative")
    return (member_count + 1) // 2


def four_by_four_packing_bound() -> int:
    """Return the capacity of four blocks with four capacity-one slots each."""
    return bounded_fiber_total({(block, slot): 1 for block in range(4) for slot in range(4)})


def packing_scale(level: int) -> int:
    """Compute the closed form 4^(2^level) for the squaring recurrence."""
    if level < 0:
        raise ValueError("Level must be nonnegative")
    return 4 ** (2**level)


def packing_scale_iterative(level: int) -> int:
    """Compute the same scale by repeatedly squaring, for cross-checking."""
    if level < 0:
        raise ValueError("Level must be nonnegative")
    value = 4
    for _ in range(level):
        value *= value
    return value


def is_point_triangle_free(rectangles: Sequence[Rectangle]) -> bool:
    """Check that no triple of closed rectangles has a common point."""
    for first, second, third in combinations(rectangles, 3):
        common_left = max(first.left, second.left, third.left)
        common_right = min(first.right, second.right, third.right)
        common_bottom = max(first.bottom, second.bottom, third.bottom)
        common_top = min(first.top, second.top, third.top)
        if common_left <= common_right and common_bottom <= common_top:
            return False
    return True


def is_pairwise_disjoint(rectangles: Iterable[Rectangle]) -> bool:
    """Check pairwise disjointness of a finite rectangle collection."""
    items = list(rectangles)
    return all(not first.intersects(second) for first, second in combinations(items, 2))


def rational_gap_comparison() -> tuple[Fraction, Fraction, Fraction]:
    """Return the old ratio, 73/32, and their exact positive difference."""
    old = Fraction(17891, 8064)
    new = Fraction(73, 32)
    return old, new, new - old


def run_demo() -> None:
    """Print all numerical examples and assert their advertised relations."""
    piercing_bound = triangle_free_piercing_lower_bound(64)
    packing_bound = four_by_four_packing_bound()
    print("64-member depth-two piercing lower bound:", piercing_bound)
    print("Four-by-four packing upper bound:", packing_bound)
    print("Proposed ceiling at packing number 16:", 2 * packing_bound - 1)
    assert piercing_bound == 32
    assert packing_bound == 16
    assert 2 * packing_bound - 1 < piercing_bound

    scales = [packing_scale(level) for level in range(4)]
    iterative = [packing_scale_iterative(level) for level in range(4)]
    print("Recursive packing scales at levels 0 through 3:", scales)
    assert scales == iterative == [4, 16, 256, 65536]

    old, new, improvement = rational_gap_comparison()
    print(f"Ratio comparison: {old} < {new}")
    print(f"Exact improvement: {improvement} = {float(improvement):.8f}")
    assert old < new

    sample = [
        Rectangle(0, 2, 0, 1),
        Rectangle(1, 3, 0, 1),
        Rectangle(3.5, 4.5, 0, 1),
    ]
    print("Sample family is point-triangle-free:", is_point_triangle_free(sample))
    assert is_point_triangle_free(sample)


if __name__ == "__main__":
    run_demo()
