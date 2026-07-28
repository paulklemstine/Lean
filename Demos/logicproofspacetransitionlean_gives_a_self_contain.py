#!/usr/bin/env python3
"""Numerical illustrations of finite transition windows from block drift.

The examples are synthetic: they demonstrate universal finite theorems rather
than claim empirical evidence about any particular logical system.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence


@dataclass(frozen=True)
class TransitionReport:
    """Certificate for a first nonpositive sampled endpoint."""

    block_width: int
    threshold_block: int
    previous_endpoint: int | None
    crossing_endpoint: int
    values: tuple[int, ...]


def cumulative_imbalances(
    provable: Sequence[int], unresolved: Sequence[int]
) -> list[int]:
    """Return cumulative sums of shell differences provable[n]-unresolved[n]."""
    if len(provable) != len(unresolved):
        raise ValueError("The two shell-count sequences must have equal length.")
    if any(x < 0 for x in (*provable, *unresolved)):
        raise ValueError("Counts must be nonnegative integers.")
    total = 0
    cumulative: list[int] = []
    for p_count, u_count in zip(provable, unresolved):
        total += p_count - u_count
        cumulative.append(total)
    return cumulative


def first_sampled_threshold(values: Sequence[int], block_width: int) -> TransitionReport:
    """Validate strict descent and return the unique first nonpositive sample.

    ``values[k]`` represents the signal at endpoint ``k * block_width``.
    """
    if not values:
        raise ValueError("At least one sampled value is required.")
    if block_width <= 0:
        raise ValueError("The block width must be positive.")
    if any(values[k + 1] >= values[k] for k in range(len(values) - 1)):
        raise ValueError("Sampled values must be strictly decreasing.")
    try:
        threshold = next(k for k, value in enumerate(values) if value <= 0)
    except StopIteration as exc:
        raise ValueError("No nonpositive sampled endpoint exists.") from exc
    previous = (threshold - 1) * block_width if threshold > 0 else None
    return TransitionReport(
        block_width=block_width,
        threshold_block=threshold,
        previous_endpoint=previous,
        crossing_endpoint=threshold * block_width,
        values=tuple(values),
    )


def verify_linear_decay(values: Sequence[int]) -> list[tuple[int, int, bool]]:
    """Check the bound values[k] <= values[0]-k at every sampled block."""
    if not values:
        raise ValueError("At least one sampled value is required.")
    return [
        (k, values[0] - k, value <= values[0] - k)
        for k, value in enumerate(values)
    ]


def render_ascii(values: Sequence[int], block_width: int) -> str:
    """Render sampled values and mark the first nonpositive endpoint."""
    threshold = next((k for k, value in enumerate(values) if value <= 0), None)
    rows = ["endpoint | imbalance | status", "---------+-----------+----------------"]
    for k, value in enumerate(values):
        marker = "first threshold" if k == threshold else ("positive" if value > 0 else "negative")
        rows.append(f"{k * block_width:8d} | {value:9d} | {marker}")
    return "\n".join(rows)


def main() -> None:
    """Run three deterministic examples and print theorem checks."""
    print("EXAMPLE 1: Strict block drift and a one-block transition window")
    sampled = [7, 5, 2, 0, -3]
    report = first_sampled_threshold(sampled, block_width=4)
    print(render_ascii(sampled, 4))
    print(
        f"Unique first sampled threshold: block {report.threshold_block}, "
        f"endpoint {report.crossing_endpoint}."
    )
    print(
        f"Localized endpoint window: [{report.previous_endpoint}, "
        f"{report.crossing_endpoint}].\n"
    )

    print("EXAMPLE 2: Shell imbalances and cumulative descent")
    provable = [10, 4, 3, 5, 2]
    unresolved = [4, 5, 5, 6, 5]
    shells = [p - u for p, u in zip(provable, unresolved)]
    cumulative = cumulative_imbalances(provable, unresolved)
    print(f"shell imbalances:      {shells}")
    print(f"cumulative imbalance: {cumulative}")
    print(f"all incoming shells negative: {all(x < 0 for x in shells[1:])}")
    print(f"cumulative sequence strictly decreases: "
          f"{all(cumulative[k + 1] < cumulative[k] for k in range(len(cumulative) - 1))}\n")

    print("EXAMPLE 3: Integer linear-decay certificate")
    sharp = [5, 4, 3, 2, 1, 0]
    print(render_ascii(sharp, 3))
    for k, bound, valid in verify_linear_decay(sharp):
        print(f"block {k}: value={sharp[k]:2d}, bound={bound:2d}, valid={valid}")
    print("The crossing occurs after exactly the initial imbalance of five blocks.")


if __name__ == "__main__":
    main()
