#!/usr/bin/env python3
"""Numerical illustrations of consensus topology and one-sided collapse.

The finite example computes exact intersections of explicitly listed topologies.
The real-line example samples local neighborhoods to illustrate why [0, 1) is
lower-limit open but not Euclidean open. No third-party packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Iterable, Sequence, TypeVar

T = TypeVar("T")
FiniteSet = FrozenSet[T]
Topology = FrozenSet[FiniteSet[T]]


@dataclass(frozen=True)
class ProbeResult:
    """Result of testing a neighborhood around one sampled point."""

    point: float
    lower_neighborhood: tuple[float, float]
    lower_fits: bool
    symmetric_neighborhood: tuple[float, float]
    symmetric_fits: bool


def powerset(items: Sequence[T]) -> list[FiniteSet[T]]:
    """Return every subset of a short finite sequence as a frozenset."""
    result: list[FiniteSet[T]] = []
    for mask in range(1 << len(items)):
        result.append(
            frozenset(items[index] for index in range(len(items)) if mask & (1 << index))
        )
    return result


def is_topology(carrier: FiniteSet[T], family: Topology[T]) -> bool:
    """Check the topology axioms by exhaustive finite enumeration."""
    empty: FiniteSet[T] = frozenset()
    if empty not in family or carrier not in family:
        return False
    # On a finite family, closure under binary unions implies arbitrary-union closure.
    for left in family:
        for right in family:
            if (left | right) not in family or (left & right) not in family:
                return False
    return True


def consensus(topologies: Sequence[Topology[T]]) -> Topology[T]:
    """Intersect the open-set families of all channels."""
    if not topologies:
        raise ValueError("At least one channel is required")
    shared = set(topologies[0])
    for topology in topologies[1:]:
        shared.intersection_update(topology)
    return frozenset(shared)


def collapse_witness(old_consensus: Topology[T], new_channel: Topology[T]) -> FiniteSet[T] | None:
    """Find an old consensus-open set vetoed by a new channel, if one exists."""
    rejected = old_consensus.difference(new_channel)
    if not rejected:
        return None
    return min(rejected, key=lambda subset: (len(subset), tuple(sorted(map(str, subset)))))


def in_half_open_unit_interval(x: float) -> bool:
    """Membership predicate for [0, 1)."""
    return 0.0 <= x < 1.0


def probe_half_open_interval(points: Iterable[float], radius: float = 0.1) -> list[ProbeResult]:
    """Sample directional and symmetric neighborhoods inside [0, 1).

    For each point x, the lower-limit test uses [x, x + delta), while the
    Euclidean test uses (x - delta, x + delta). Endpoint containment is tested
    numerically using representative points just inside each neighborhood.
    """
    if radius <= 0.0:
        raise ValueError("radius must be positive")
    results: list[ProbeResult] = []
    for x in points:
        delta = min(radius, max((1.0 - x) / 2.0, radius / 1000.0))
        lower = (x, x + delta)
        symmetric = (x - delta, x + delta)
        lower_samples = (x, x + delta / 2.0, x + 0.999 * delta)
        symmetric_samples = (x - 0.999 * delta, x, x + 0.999 * delta)
        results.append(
            ProbeResult(
                point=x,
                lower_neighborhood=lower,
                lower_fits=all(in_half_open_unit_interval(y) for y in lower_samples),
                symmetric_neighborhood=symmetric,
                symmetric_fits=all(in_half_open_unit_interval(y) for y in symmetric_samples),
            )
        )
    return results


def format_subset(subset: FiniteSet[str]) -> str:
    """Format a finite subset deterministically."""
    return "{" + ", ".join(sorted(subset)) + "}"


def run_finite_example() -> None:
    """Compute an exact strict consensus collapse on a three-state carrier."""
    carrier: FiniteSet[str] = frozenset({"left", "center", "right"})
    empty: FiniteSet[str] = frozenset()
    left = frozenset({"left"})
    left_center = frozenset({"left", "center"})
    right = frozenset({"right"})
    center_right = frozenset({"center", "right"})

    lower_like: Topology[str] = frozenset({empty, left, left_center, carrier})
    upper_like: Topology[str] = frozenset({empty, right, center_right, carrier})

    assert is_topology(carrier, lower_like)
    assert is_topology(carrier, upper_like)

    one_channel = consensus([lower_like])
    two_channel = consensus([lower_like, upper_like])
    witness = collapse_witness(one_channel, upper_like)

    print("EXACT FINITE CONSENSUS EXAMPLE")
    print(f"  one-channel open sets: {len(one_channel)}")
    print(f"  two-channel open sets: {len(two_channel)}")
    print("  consensus after adding the opposite channel:")
    for subset in sorted(two_channel, key=lambda s: (len(s), tuple(sorted(s)))):
        print(f"    {format_subset(subset)}")
    print(f"  strict-collapse witness: {format_subset(witness or empty)}")
    print()


def run_real_line_probe() -> None:
    """Display sampled neighborhood certificates for the key interval."""
    print("SAMPLED REAL-LINE NEIGHBORHOOD TEST FOR [0, 1)")
    for result in probe_half_open_interval([0.0, 0.25, 0.75], radius=0.1):
        print(
            f"  x={result.point:>4.2f}: "
            f"lower [x,b) fits={str(result.lower_fits):5s}; "
            f"symmetric (a,b) fits={str(result.symmetric_fits):5s}"
        )
    print("  At x=0, every positive-radius symmetric neighborhood reaches below 0.")
    print("  Thus [0,1) has a lower-limit certificate there, but no Euclidean one.")


def main() -> None:
    """Run all demonstrations."""
    run_finite_example()
    run_real_line_probe()


if __name__ == "__main__":
    main()
