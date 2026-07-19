#!/usr/bin/env python3
"""Numerical demonstrations of entropy and fiber information loss.

For a finite deterministic map represented by one output label per source state,
this program computes output entropy, expected logarithmic fiber size, and the
chain-rule residual. Natural logarithms are used, so values are in nats.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import isclose, log
from typing import Hashable, Iterable, Sequence, TypeVar

Label = TypeVar("Label", bound=Hashable)


@dataclass(frozen=True)
class EntropyReport:
    """Information decomposition for a nonempty finite deterministic map."""

    source_size: int
    fiber_sizes: dict[Hashable, int]
    output_entropy: float
    fiber_loss: float
    source_entropy: float

    @property
    def residual(self) -> float:
        """Numerical error in H(output) + loss = log(source size)."""
        return self.output_entropy + self.fiber_loss - self.source_entropy


def entropy_report(outputs: Iterable[Label]) -> EntropyReport:
    """Compute the entropy--loss decomposition from output labels.

    Each position in ``outputs`` represents one equally likely source object;
    equal labels belong to the same fiber.
    """
    labels = list(outputs)
    if not labels:
        raise ValueError("the source must be nonempty")

    counts: Counter[Label] = Counter(labels)
    n = len(labels)
    output_entropy = 0.0
    fiber_loss = 0.0
    for count in counts.values():
        probability = count / n
        output_entropy -= probability * log(probability)
        fiber_loss += probability * log(count)

    return EntropyReport(
        source_size=n,
        fiber_sizes=dict(counts),
        output_entropy=output_entropy,
        fiber_loss=fiber_loss,
        source_entropy=log(n),
    )


def is_uniform_on_image(outputs: Sequence[Label]) -> tuple[bool, int | None]:
    """Return whether all attained fibers have one size, and that size if so."""
    if not outputs:
        raise ValueError("the source must be nonempty")
    sizes = set(Counter(outputs).values())
    return (len(sizes) == 1, next(iter(sizes)) if len(sizes) == 1 else None)


def first_collision(outputs: Sequence[Label]) -> tuple[int, int] | None:
    """Return source indices identified by the map, or ``None`` if injective."""
    first_seen: dict[Label, int] = {}
    for index, label in enumerate(outputs):
        if label in first_seen:
            return first_seen[label], index
        first_seen[label] = index
    return None


def print_report(name: str, outputs: Sequence[Hashable]) -> None:
    """Print a readable report and assert the numerical chain rule."""
    report = entropy_report(outputs)
    uniform, fiber_size = is_uniform_on_image(outputs)
    collision = first_collision(outputs)

    print(f"\n{name}")
    print("-" * len(name))
    print(f"source size:        {report.source_size}")
    print(f"fiber sizes:        {list(report.fiber_sizes.values())}")
    print(f"output entropy:     {report.output_entropy:.12f} nats")
    print(f"fiber loss:         {report.fiber_loss:.12f} nats")
    print(f"log(source size):   {report.source_entropy:.12f} nats")
    print(f"chain residual:     {report.residual:.3e}")
    print(f"uniform fibers:     {uniform}" + (f" (k={fiber_size})" if uniform else ""))
    print(f"collision witness:  {collision}")

    assert isclose(
        report.output_entropy + report.fiber_loss,
        report.source_entropy,
        rel_tol=1e-12,
        abs_tol=1e-12,
    )
    if collision is None:
        assert isclose(report.fiber_loss, 0.0, abs_tol=1e-12)
    else:
        assert report.fiber_loss > 0.0


def main() -> None:
    """Run injective, constant, uniform, and nonuniform examples."""
    examples: list[tuple[str, Sequence[Hashable]]] = [
        ("Injective six-state channel", list(range(6))),
        ("Constant six-state channel", ["only"] * 6),
        ("Residues modulo three", [i % 3 for i in range(6)]),
        ("Nonuniform fibers of sizes 1, 2, and 3", ["A", "B", "B", "C", "C", "C"]),
    ]
    for name, outputs in examples:
        print_report(name, outputs)

    modulo_three = entropy_report([i % 3 for i in range(6)])
    assert isclose(modulo_three.output_entropy, log(3), rel_tol=1e-12)
    assert isclose(modulo_three.fiber_loss, log(2), rel_tol=1e-12)
    print("\nAll entropy identities passed.")


if __name__ == "__main__":
    main()
