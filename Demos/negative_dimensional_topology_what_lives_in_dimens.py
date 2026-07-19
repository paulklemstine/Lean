#!/usr/bin/env python3
"""Numerical demonstrations of negative-dimensional Euler parity.

The model represents a pure cellular object by an integer degree and a
nonnegative component count.  It also supports finite mixed virtual cellular
ledgers and component-preserving negative pro-towers.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Sequence, Tuple


@dataclass(frozen=True)
class PureCellularObject:
    """A finite component multiplicity concentrated in one integer degree."""

    dimension: int
    components: int

    def __post_init__(self) -> None:
        if self.components < 0:
            raise ValueError("component count must be nonnegative")

    @property
    def euler(self) -> int:
        """Return (-1)^dimension times the component count."""
        return self.components if self.dimension % 2 == 0 else -self.components

    def suspend(self, steps: int = 1) -> "PureCellularObject":
        """Shift degree upward while retaining the component count."""
        if steps < 0:
            raise ValueError("suspension steps must be nonnegative")
        return PureCellularObject(self.dimension + steps, self.components)


def extended_euler(multiplicities: Dict[int, int]) -> int:
    """Evaluate a finite integer-graded virtual ledger by the parity character."""
    return sum(value if degree % 2 == 0 else -value
               for degree, value in multiplicities.items())


def stabilize_negative(depth: int, components: int) -> PureCellularObject:
    """Reflect degree -depth to +depth using 2*depth suspensions."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return PureCellularObject(-depth, components).suspend(2 * depth)


def negative_tower(base: int, components: int, stages: int) -> List[PureCellularObject]:
    """Generate a finite window of a component-preserving negative pro-tower."""
    if base < 0 or stages < 0:
        raise ValueError("base and number of stages must be nonnegative")
    return [PureCellularObject(-(base + k), components) for k in range(stages)]


def parity_corrected_euler(tower: Sequence[PureCellularObject]) -> List[int]:
    """Return (-1)^k chi(X_k), constant for a valid pure tower."""
    return [obj.euler if k % 2 == 0 else -obj.euler
            for k, obj in enumerate(tower)]


def print_negative_dimension_table(component_counts: Iterable[int], max_depth: int) -> None:
    """Display the signed Euler law over several depths and component counts."""
    print("DEMO 1 — Negative-dimensional Euler law")
    header = "components | " + " | ".join(f"dim {-n:>2}" for n in range(max_depth + 1))
    print(header)
    print("-" * len(header))
    for count in component_counts:
        values = [PureCellularObject(-n, count).euler for n in range(max_depth + 1)]
        print(f"{count:>10} | " + " | ".join(f"{value:>6}" for value in values))


def demonstrate_stabilization(examples: Iterable[Tuple[int, int]]) -> None:
    """Show that reflection stabilization preserves components and Euler value."""
    print("\nDEMO 2 — Euler-neutral reflection stabilization")
    for depth, count in examples:
        source = PureCellularObject(-depth, count)
        target = stabilize_negative(depth, count)
        assert target.dimension == depth
        assert target.components == source.components
        assert target.euler == source.euler
        print(
            f"depth {depth:>2}, components {count:>2}: "
            f"({source.dimension:>3}, chi={source.euler:>3}) "
            f"--{2 * depth} suspensions--> "
            f"({target.dimension:>3}, chi={target.euler:>3})"
        )


def demonstrate_pro_tower(base: int, components: int, stages: int) -> None:
    """Display exact alternation and its constant parity correction."""
    print("\nDEMO 3 — Component-preserving pro-Euler alternation")
    tower = negative_tower(base, components, stages)
    corrected = parity_corrected_euler(tower)
    initial = tower[0].euler if tower else 0
    for k, (obj, invariant) in enumerate(zip(tower, corrected)):
        predicted = (initial if k % 2 == 0 else -initial)
        assert obj.euler == predicted
        assert invariant == initial
        stable = stabilize_negative(base + k, components)
        assert stable.euler == obj.euler and stable.components == obj.components
        print(
            f"stage {k:>2}: dim={obj.dimension:>3}, chi={obj.euler:>3}, "
            f"(-1)^k chi={invariant:>3}, reflected_dim={stable.dimension:>3}"
        )


def demonstrate_purity_boundary() -> None:
    """Contrast a pure formula with cancellation in a mixed-degree ledger."""
    print("\nDEMO 4 — Why purity is necessary")
    ledger = {-1: 1, -2: 1}
    chi = extended_euler(ledger)
    total = sum(ledger.values())
    assert total == 2 and chi == 0
    print(f"mixed ledger {ledger} has total multiplicity {total} but Euler value {chi}")
    print("Adjacent odd and even degrees cancel, so no one-degree sign formula applies.")


def main() -> None:
    """Run all demonstrations."""
    print_negative_dimension_table(component_counts=range(1, 5), max_depth=4)
    demonstrate_stabilization([(0, 3), (1, 3), (2, 5), (5, 2)])
    demonstrate_pro_tower(base=2, components=4, stages=8)
    demonstrate_purity_boundary()


if __name__ == "__main__":
    main()
