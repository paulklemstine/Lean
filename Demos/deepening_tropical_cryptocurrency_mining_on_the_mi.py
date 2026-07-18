#!/usr/bin/env python3
"""Numerical demonstrations of universal collision rays for min-plus digests."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Iterable, Sequence

Vector = list[float]
KeyFamily = list[Vector]


def tropical_component(message: Sequence[float], key: Sequence[float]) -> float:
    """Return min_i(message[i] + key[i])."""
    if not message or len(message) != len(key):
        raise ValueError("message and key must have the same positive length")
    return min(x + h for x, h in zip(message, key))


def tropical_digest(message: Sequence[float], keys: Sequence[Sequence[float]]) -> Vector:
    """Evaluate every key on a message."""
    return [tropical_component(message, key) for key in keys]


def active_indices(message: Sequence[float], key: Sequence[float]) -> list[int]:
    """Return every coordinate attaining a component minimum."""
    value = tropical_component(message, key)
    return [i for i, (x, h) in enumerate(zip(message, key)) if isclose(x + h, value)]


def selected_witnesses(message: Sequence[float], keys: Sequence[Sequence[float]]) -> list[int]:
    """Choose the first active minimizing coordinate for each key."""
    return [active_indices(message, key)[0] for key in keys]


def find_escape_coordinate(message: Sequence[float], keys: Sequence[Sequence[float]]) -> int:
    """Find a coordinate outside one selected minimizer per component."""
    if not message:
        raise ValueError("the message must have at least one coordinate")
    if len(keys) >= len(message):
        raise ValueError("the universal guarantee requires fewer keys than coordinates")
    if any(len(key) != len(message) for key in keys):
        raise ValueError("every key must match the message dimension")
    occupied = set(selected_witnesses(message, keys))
    return next(i for i in range(len(message)) if i not in occupied)


def update_coordinate(message: Sequence[float], coordinate: int, increment: float) -> Vector:
    """Copy a message and add a nonnegative increment at one coordinate."""
    if increment < 0:
        raise ValueError("the collision-ray theorem requires a nonnegative increment")
    result = list(message)
    result[coordinate] += increment
    return result


@dataclass(frozen=True)
class CollisionSample:
    increment: float
    message: Vector
    digest: Vector


def sample_collision_ray(
    message: Sequence[float], keys: Sequence[Sequence[float]], increments: Iterable[float]
) -> tuple[int, list[CollisionSample]]:
    """Construct and verify points along the guaranteed collision ray."""
    q = find_escape_coordinate(message, keys)
    baseline = tropical_digest(message, keys)
    samples: list[CollisionSample] = []
    for increment in increments:
        altered = update_coordinate(message, q, increment)
        digest = tropical_digest(altered, keys)
        if len(digest) != len(baseline) or any(
            not isclose(a, b) for a, b in zip(digest, baseline)
        ):
            raise AssertionError("constructed point unexpectedly changed the digest")
        samples.append(CollisionSample(increment, altered, digest))
    return q, samples


def demo_explicit_ray() -> None:
    """Reproduce a two-output, four-coordinate unbounded collision ray."""
    message = [3.0, 1.0, 4.0, 2.0]
    keys = [[0.0, 2.0, -1.0, 3.0], [4.0, 0.0, 2.0, -2.0]]
    q, samples = sample_collision_ray(message, keys, [0.0, 1.0, 10.0, 1000.0])
    print("\nDEMO 1 — Explicit unbounded collision ray")
    print(f"base message: {message}")
    print(f"base digest:  {tropical_digest(message, keys)}")
    print(f"selected witnesses (1-based): {[i + 1 for i in selected_witnesses(message, keys)]}")
    print(f"escape coordinate (1-based): {q + 1}")
    for sample in samples:
        print(f"d={sample.increment:7g}  message={sample.message}  digest={sample.digest}")


def demo_injectivity() -> None:
    """Check that distinct positive parameters produce distinct colliding messages."""
    message = [2.5, -1.0, 7.0, 0.0, 3.0]
    keys = [[1.0, 4.0, -2.0, 2.0, 0.0], [0.0, 3.0, 1.0, -1.0, 2.0]]
    parameters = [0.25, 0.5, 2.0, 8.0]
    q, samples = sample_collision_ray(message, keys, parameters)
    encoded = {tuple(sample.message) for sample in samples}
    assert len(encoded) == len(parameters)
    print("\nDEMO 2 — Injective parameterization of one fiber")
    print(f"escape coordinate (1-based): {q + 1}")
    print(f"all {len(samples)} messages are distinct: {len(encoded) == len(samples)}")
    print(f"common digest: {samples[0].digest}")
    for sample in samples:
        print(f"d={sample.increment:4g} -> {sample.message}")


def demo_active_set_geometry() -> None:
    """Show how repeated and tied minimizers expose several safe directions."""
    message = [0.0, 5.0, 4.0, 3.0, 2.0]
    keys = [[0.0, 0.0, 0.0, 0.0, 0.0], [1.0, 2.0, 3.0, 4.0, 5.0], [0.0, -5.0, 8.0, 9.0, 10.0]]
    baseline = tropical_digest(message, keys)
    active = [active_indices(message, key) for key in keys]
    witnesses = selected_witnesses(message, keys)
    unused = [i for i in range(len(message)) if i not in set(witnesses)]
    print("\nDEMO 3 — Active sets and multiple candidate directions")
    print(f"active sets (1-based): {[[i + 1 for i in group] for group in active]}")
    print(f"chosen witnesses (1-based): {[i + 1 for i in witnesses]}")
    print(f"coordinates outside those witnesses: {[i + 1 for i in unused]}")
    for q in unused:
        altered = update_coordinate(message, q, 6.0)
        unchanged = tropical_digest(altered, keys) == baseline
        print(f"increase coordinate {q + 1}: digest unchanged = {unchanged}")


def main() -> None:
    demo_explicit_ray()
    demo_injectivity()
    demo_active_set_geometry()


if __name__ == "__main__":
    main()
