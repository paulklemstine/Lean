#!/usr/bin/env python3
"""Numerical demonstrations of finite tropical gradient descent.

The scalar model is f_theta(z) = z + theta.  For three ordered residual
targets a <= m <= c, absolute loss is uniquely minimized at the median m.
The clipped optimizer moves toward m by at most eta per update.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import ceil, isclose
from typing import Iterable, List


def relu(value: float) -> float:
    """Return max(0, value)."""
    return max(0.0, value)


def tropical_affine(theta: float, z: float) -> float:
    """Evaluate the tropical translation f_theta(z) = z + theta."""
    return z + theta


def three_point_loss(a: float, m: float, c: float, theta: float) -> float:
    """Return |theta-a| + |theta-m| + |theta-c|."""
    if not a <= m <= c:
        raise ValueError("Targets must satisfy a <= m <= c.")
    return abs(theta - a) + abs(theta - m) + abs(theta - c)


def tropical_flow(m: float, travel: float, x: float) -> float:
    """Move x toward m using a nonnegative travel budget, clipping at m."""
    if travel < 0.0:
        raise ValueError("The travel budget must be nonnegative.")
    return min(m, x + travel) if x < m else max(m, x - travel)


def gd_iterate(m: float, eta: float, x: float, n: int) -> float:
    """Evaluate the nth fixed-step clipped iterate in closed form."""
    if eta < 0.0:
        raise ValueError("The step size must be nonnegative.")
    if n < 0:
        raise ValueError("The iteration index must be nonnegative.")
    return tropical_flow(m, n * eta, x)


def two_relu_iterate(m: float, eta: float, x: float, n: int) -> float:
    """Evaluate the exact width-two ReLU representation of the nth iterate."""
    if eta < 0.0 or n < 0:
        raise ValueError("Require eta >= 0 and n >= 0.")
    travel = n * eta
    return m + relu(x - m - travel) - relu(m - x - travel)


def exact_distance(m: float, eta: float, x: float, n: int) -> float:
    """Return max(0, |x-m|-n*eta), the exact parameter error."""
    if eta < 0.0 or n < 0:
        raise ValueError("Require eta >= 0 and n >= 0.")
    return max(0.0, abs(x - m) - n * eta)


def stopping_time(m: float, eta: float, x: float) -> int:
    """Return ceil(|x-m|/eta), the exact finite stopping bound."""
    if eta <= 0.0:
        raise ValueError("Finite termination requires eta > 0.")
    return ceil(abs(x - m) / eta)


@dataclass(frozen=True)
class IterationRecord:
    """Diagnostics for one clipped-descent iterate."""

    n: int
    theta: float
    distance: float
    predicted_distance: float
    loss: float
    excess_loss: float
    loss_certificate: float
    relu_value: float


def training_trace(
    a: float, m: float, c: float, x: float, eta: float, iterations: int
) -> List[IterationRecord]:
    """Build a trace and all exact convergence diagnostics."""
    if not a <= m <= c:
        raise ValueError("Targets must satisfy a <= m <= c.")
    if eta <= 0.0:
        raise ValueError("The step size must be positive.")
    if iterations < 0:
        raise ValueError("The number of iterations must be nonnegative.")

    optimum_loss = three_point_loss(a, m, c, m)
    records: List[IterationRecord] = []
    for n in range(iterations + 1):
        theta = gd_iterate(m, eta, x, n)
        distance = abs(theta - m)
        predicted = exact_distance(m, eta, x, n)
        loss = three_point_loss(a, m, c, theta)
        records.append(
            IterationRecord(
                n=n,
                theta=theta,
                distance=distance,
                predicted_distance=predicted,
                loss=loss,
                excess_loss=loss - optimum_loss,
                loss_certificate=3.0 * predicted,
                relu_value=two_relu_iterate(m, eta, x, n),
            )
        )
    return records


def verify_trace(records: Iterable[IterationRecord], m: float) -> None:
    """Numerically check the distance, loss, and ReLU identities."""
    for row in records:
        assert isclose(row.distance, row.predicted_distance, abs_tol=1e-12)
        assert isclose(row.theta, row.relu_value, abs_tol=1e-12)
        assert row.excess_loss >= -1e-12
        assert row.excess_loss <= row.loss_certificate + 1e-12
        if isclose(row.predicted_distance, 0.0, abs_tol=1e-12):
            assert isclose(row.theta, m, abs_tol=1e-12)


def print_trace(records: Iterable[IterationRecord]) -> None:
    """Print a compact table of training diagnostics."""
    print(
        " n |   theta | distance | formula  | loss     | excess   | "
        "3*formula | two-ReLU"
    )
    print("-" * 88)
    for row in records:
        print(
            f"{row.n:2d} | {row.theta:7.3f} | {row.distance:8.3f} | "
            f"{row.predicted_distance:8.3f} | {row.loss:8.3f} | "
            f"{row.excess_loss:8.3f} | {row.loss_certificate:9.3f} | "
            f"{row.relu_value:8.3f}"
        )


def main() -> None:
    """Run representative trajectories from below and above the median."""
    examples = [
        ("Finite capture from below", -2.0, 1.0, 5.0, -4.0, 2.0, 5),
        ("Finite capture from above", -3.0, 0.0, 4.0, 5.5, 1.5, 6),
        ("One-step capture with a large step", -2.0, 1.0, 5.0, -4.0, 100.0, 2),
    ]

    for title, a, m, c, x, eta, iterations in examples:
        print(f"\n{title}")
        print(f"targets=({a:g}, {m:g}, {c:g}), x={x:g}, eta={eta:g}")
        print(f"predicted stopping time: {stopping_time(m, eta, x)}")
        records = training_trace(a, m, c, x, eta, iterations)
        verify_trace(records, m)
        print_trace(records)

        z = 7.0
        final_theta = records[-1].theta
        print(
            f"prediction at z={z:g}: f_theta(z)={tropical_affine(final_theta, z):g}; "
            f"optimal prediction={tropical_affine(m, z):g}"
        )

    print("\nAll numerical identities and inequalities passed.")


if __name__ == "__main__":
    main()
