#!/usr/bin/env python3
"""Numerical demonstrations for recurrence and observation in logistic dynamics.

The script uses only Python's standard library. Floating-point near returns are
illustrative and are explicitly distinguished from exact periodicity. Fixed-point
identities are checked with exact rational arithmetic.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isfinite
from typing import Callable, Iterable, Sequence


NumberMap = Callable[[float], float]
Observation = Callable[[float], str]


@dataclass(frozen=True)
class NearReturn:
    """A tolerance-based recurrence candidate in a sampled orbit."""

    index: int
    lag: int
    current: float
    previous: float
    error: float


def logistic(x: float, r: float = 3.83) -> float:
    """Evaluate the logistic transition x ↦ r*x*(1-x)."""
    return r * x * (1.0 - x)


def orbit(step: NumberMap, x0: float, steps: int) -> list[float]:
    """Return x_0,...,x_steps for a deterministic transition map."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    values = [x0]
    for _ in range(steps):
        nxt = step(values[-1])
        if not isfinite(nxt):
            raise ArithmeticError("the orbit left the finite floating-point range")
        values.append(nxt)
    return values


def detect_near_returns(
    values: Sequence[float], max_lag: int, tolerance: float
) -> list[NearReturn]:
    """Find pairs x_i,x_(i-lag) closer than a chosen tolerance.

    This tests numerical proximity only; it does not prove exact periodicity.
    Runtime is O(len(values) * max_lag), and output storage is proportional to
    the number of detected candidates.
    """
    if max_lag < 1:
        raise ValueError("max_lag must be positive")
    if tolerance < 0:
        raise ValueError("tolerance must be nonnegative")
    hits: list[NearReturn] = []
    for i in range(1, len(values)):
        for lag in range(1, min(max_lag, i) + 1):
            error = abs(values[i] - values[i - lag])
            if error <= tolerance:
                hits.append(NearReturn(i, lag, values[i], values[i - lag], error))
    return hits


def exact_fixed_point_residual(x: Fraction) -> Fraction:
    """Evaluate L(x)-x exactly for L(x)=(383/100)x(1-x)."""
    return Fraction(383, 100) * x * (1 - x) - x


def constant_observation(_: float) -> str:
    """A maximally lossy observation channel."""
    return "same report"


def quantized_observation(x: float, bins: int = 20) -> str:
    """Observe only a finite bin, illustrating resolution dependence."""
    if bins <= 0:
        raise ValueError("bins must be positive")
    index = min(bins - 1, max(0, int(x * bins)))
    return f"bin {index:02d}/{bins}"


def observation_changes(values: Iterable[float], observe: Observation) -> int:
    """Count changes between consecutive observed symbols."""
    symbols = [observe(x) for x in values]
    return sum(a != b for a, b in zip(symbols, symbols[1:]))


def demo_interval_and_fixed_points() -> None:
    """Sample interval invariance and verify both fixed points exactly."""
    grid = [i / 10_000 for i in range(10_001)]
    images = [logistic(x) for x in grid]
    print("DEMO 1 — invariant interval and exact fixed points")
    print(f"sampled image range: [{min(images):.12f}, {max(images):.12f}]")
    for point in (Fraction(0), Fraction(283, 383)):
        print(f"exact residual at x={point}: {exact_fixed_point_residual(point)}")
    print("The grid illustrates invariance; the rational residuals are exact.\n")


def demo_near_period_three() -> None:
    """Display late logistic iterates and tolerance-based lag-three returns."""
    values = orbit(logistic, 0.5, 220)
    tail = values[-12:]
    lag_three_errors = [abs(values[i] - values[i - 3]) for i in range(200, 221)]
    print("DEMO 2 — numerical near returns at lag three")
    for i, value in enumerate(tail, start=len(values) - len(tail)):
        print(f"x[{i:3d}] = {value:.15f}")
    print(f"largest late lag-three error: {max(lag_three_errors):.3e}")
    hits = [h for h in detect_near_returns(values[-30:], 6, 1e-10) if h.lag == 3]
    print(f"lag-three pairs within 1e-10 in final window: {len(hits)}")
    print("These are floating-point near returns, not an exact period certificate.\n")


def demo_observation_false_positive() -> None:
    """Contrast a changing hidden trajectory with lossy observations."""
    values = orbit(logistic, 0.123456789, 30)
    hidden_changes = sum(abs(a - b) > 1e-14 for a, b in zip(values, values[1:]))
    constant_changes = observation_changes(values, constant_observation)
    quantized_changes = observation_changes(values, quantized_observation)
    print("DEMO 3 — observation can manufacture apparent stability")
    print(f"numerically changing hidden transitions: {hidden_changes}")
    print(f"changes through constant observation: {constant_changes}")
    print(f"changes through 20-bin observation: {quantized_changes}")
    print("An unchanged report does not imply an unchanged hidden state.\n")


def main() -> None:
    """Run all demonstrations."""
    demo_interval_and_fixed_points()
    demo_near_period_three()
    demo_observation_false_positive()


if __name__ == "__main__":
    main()
