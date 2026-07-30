#!/usr/bin/env python3
"""Numerical demonstrations of three-sample tropical median training.

The script uses only the Python standard library. It verifies the loss landscape
on finite grids, samples exact clipped trajectories, and checks fixed points and
the semigroup law numerically.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Sample:
    """One exact trajectory observation."""

    time: float
    state: float
    loss: float
    distance_to_median: float


def ordered_targets(targets: Sequence[float]) -> tuple[float, float, float]:
    """Return three targets in nondecreasing order."""
    if len(targets) != 3:
        raise ValueError("exactly three reduced targets are required")
    a, m, c = sorted(float(value) for value in targets)
    return a, m, c


def three_point_loss(a: float, m: float, c: float, x: float) -> float:
    """Compute |x-a| + |x-m| + |x-c| for ordered targets."""
    if not a <= m <= c:
        raise ValueError("targets must satisfy a <= m <= c")
    return abs(x - a) + abs(x - m) + abs(x - c)


def tropical_flow(m: float, t: float, x: float) -> float:
    """Evaluate the clipped unit-speed flow toward m at nonnegative time t."""
    if t < 0:
        raise ValueError("elapsed time must be nonnegative")
    return min(m, x + t) if x < m else max(m, x - t)


def exact_hitting_time(m: float, x: float) -> float:
    """Return the exact time at which the flow initialized at x reaches m."""
    return abs(x - m)


def trajectory(
    a: float, m: float, c: float, x0: float, times: Iterable[float]
) -> list[Sample]:
    """Sample the exact trajectory and its loss on a supplied time grid."""
    samples: list[Sample] = []
    for time in times:
        state = tropical_flow(m, float(time), x0)
        samples.append(
            Sample(
                time=float(time),
                state=state,
                loss=three_point_loss(a, m, c, state),
                distance_to_median=abs(state - m),
            )
        )
    return samples


def grid_minimizers(
    a: float, m: float, c: float, grid: Iterable[float], tolerance: float = 1e-12
) -> tuple[float, list[float]]:
    """Find the minimum loss and all minimizers on a finite numerical grid."""
    points = [float(x) for x in grid]
    if not points:
        raise ValueError("grid must be nonempty")
    values = [(x, three_point_loss(a, m, c, x)) for x in points]
    best = min(value for _, value in values)
    minimizers = [x for x, value in values if abs(value - best) <= tolerance]
    return best, minimizers


def print_trajectory(title: str, samples: Sequence[Sample]) -> None:
    """Print a trajectory table."""
    print(f"\n{title}")
    print(" time |   state |    loss | distance")
    print("------+---------+---------+---------")
    for sample in samples:
        print(
            f"{sample.time:5.1f} | {sample.state:7.2f} | "
            f"{sample.loss:7.2f} | {sample.distance_to_median:8.2f}"
        )


def run_demo() -> None:
    """Run representative checks for the median theorem and clipped flow."""
    a, m, c = ordered_targets((-2.0, 1.0, 5.0))
    print("Three-sample tropical training")
    print(f"Ordered reduced targets: a={a:g}, m={m:g}, c={c:g}")
    print(f"Loss at median: {three_point_loss(a, m, c, m):g}")
    print(f"Loss at x=-1:  {three_point_loss(a, m, c, -1.0):g}")
    print(f"Loss at x=4:   {three_point_loss(a, m, c, 4.0):g}")

    grid = [value / 4.0 for value in range(-16, 33)]
    best, minimizers = grid_minimizers(a, m, c, grid)
    print(f"Grid minimum loss: {best:g}; grid minimizers: {minimizers}")
    assert minimizers == [m]

    left = trajectory(a, m, c, -2.0, range(0, 6))
    right = trajectory(a, m, c, 5.0, range(0, 7))
    print_trajectory("Flow from the left (x0=-2)", left)
    print_trajectory("Flow from the right (x0=5)", right)

    for x0 in (-8.5, -2.0, 1.0, 5.0, 12.25):
        hit = exact_hitting_time(m, x0)
        assert tropical_flow(m, hit, x0) == m
        assert tropical_flow(m, hit + 10.0, x0) == m

    for x0 in (-3.0, 1.0, 7.0):
        for s, t in ((0.25, 0.5), (2.0, 3.0), (10.0, 4.0)):
            composed = tropical_flow(m, s, tropical_flow(m, t, x0))
            direct = tropical_flow(m, s + t, x0)
            assert abs(composed - direct) < 1e-12

    fixed_candidates = [x for x in grid if tropical_flow(m, 0.5, x) == x]
    print(f"\nFixed points on the grid for positive time 0.5: {fixed_candidates}")
    assert fixed_candidates == [m]
    print("All numerical checks passed.")


if __name__ == "__main__":
    run_demo()
