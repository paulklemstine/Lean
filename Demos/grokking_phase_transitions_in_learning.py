#!/usr/bin/env python3
"""Numerical demonstrations of delayed ReLU activation and saddle-node branches."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, sqrt
from typing import Iterable


@dataclass(frozen=True)
class ScoreSample:
    time: float
    preactivation: float
    score: float
    generalizes: bool


def relu(value: float) -> float:
    """Return max(value, 0)."""
    return max(value, 0.0)


def two_layer_scalar(
    input_weight: float,
    hidden_bias: float,
    output_weight: float,
    output_bias: float,
    x: float,
) -> float:
    """Evaluate a scalar width-one, two-layer ReLU network."""
    return output_weight * relu(input_weight * x + hidden_bias) + output_bias


def grok_score(delay: float, time: float) -> float:
    """Evaluate G_d(t) = max(t-d, 0) through the network formula."""
    return two_layer_scalar(1.0, -delay, 1.0, 0.0, time)


def sample_transition(delay: float, times: Iterable[float]) -> list[ScoreSample]:
    """Sample latent preactivation, visible score, and positivity label."""
    return [
        ScoreSample(
            time=time,
            preactivation=time - delay,
            score=grok_score(delay, time),
            generalizes=grok_score(delay, time) > 0.0,
        )
        for time in times
    ]


def saddle_node_field(parameter: float, state: float) -> float:
    """Evaluate F_mu(x) = mu - x^2."""
    return parameter - state * state


def saddle_node_equilibria(parameter: float) -> tuple[float, ...]:
    """Return every real equilibrium of F_mu, in increasing order."""
    if parameter < 0.0:
        return ()
    if parameter == 0.0:
        return (0.0,)
    root = sqrt(parameter)
    return (-root, root)


def verify_examples(delay: float, times: Iterable[float], parameters: Iterable[float]) -> None:
    """Check the defining identities on the requested numerical samples."""
    for sample in sample_transition(delay, times):
        expected = 0.0 if sample.time <= delay else sample.time - delay
        assert isclose(sample.score, expected, rel_tol=1e-12, abs_tol=1e-12)
        assert sample.generalizes == (sample.time > delay)
    for parameter in parameters:
        equilibria = saddle_node_equilibria(parameter)
        expected_count = 0 if parameter < 0.0 else (1 if parameter == 0.0 else 2)
        assert len(equilibria) == expected_count
        for state in equilibria:
            assert isclose(
                saddle_node_field(parameter, state), 0.0,
                rel_tol=1e-12, abs_tol=1e-12,
            )


def main() -> None:
    delay = 3.0
    times = [0.0, 2.0, 2.9, 3.0, 3.1, 4.0, 5.0]
    parameters = [-4.0, -1.0, 0.0, 0.25, 1.0, 4.0]
    verify_examples(delay, times, parameters)

    print(f"Delayed score with d = {delay:g}")
    print(" time | latent t-d | score | generalizes")
    print("------+------------+-------+------------")
    for s in sample_transition(delay, times):
        print(f"{s.time:5.1f} | {s.preactivation:10.1f} | {s.score:5.1f} | {str(s.generalizes):>11}")

    print("\nSaddle-node equilibria for F_mu(x) = mu - x^2")
    for parameter in parameters:
        roots = saddle_node_equilibria(parameter)
        rendered = ", ".join(f"{x:g}" for x in roots) if roots else "none"
        print(f"mu = {parameter:5g}: {rendered}")

    print("\nAll sampled identities and equilibrium residuals passed.")


if __name__ == "__main__":
    main()
