#!/usr/bin/env python3
"""Numerical demonstrations of finite policy-gradient identities and exploration bounds.

The script uses only Python's standard library. Run it with ``python3 demo.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp
from typing import Callable, Sequence

Vector = Sequence[float]
Matrix = Sequence[Sequence[float]]


def dot(x: Vector, y: Vector) -> float:
    """Return the Euclidean dot product of equally sized vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have equal length")
    return sum(a * b for a, b in zip(x, y))


def expectation(probabilities: Vector, values: Vector) -> float:
    """Compute a finite weighted expectation."""
    return dot(probabilities, values)


def softmax(logits: Vector) -> list[float]:
    """Compute softmax probabilities stably."""
    if not logits:
        raise ValueError("softmax requires at least one logit")
    shift = max(logits)
    weights = [exp(x - shift) for x in logits]
    total = sum(weights)
    return [x / total for x in weights]


def softmax_score(probabilities: Vector, coordinate: int) -> list[float]:
    """Return the score with respect to one softmax logit."""
    if not 0 <= coordinate < len(probabilities):
        raise IndexError("coordinate outside action set")
    return [float(a == coordinate) - probabilities[coordinate]
            for a in range(len(probabilities))]


def policy_gradient(probabilities: Vector, score: Vector,
                    values: Vector, baseline: float = 0.0) -> float:
    """Evaluate E[score(A) (value(A) - baseline)]."""
    if not (len(probabilities) == len(score) == len(values)):
        raise ValueError("all action arrays must have equal length")
    return sum(p * s * (q - baseline)
               for p, s, q in zip(probabilities, score, values))


def finite_difference(function: Callable[[float], float], x: float,
                      step: float = 1e-6) -> float:
    """Return a centered finite-difference derivative."""
    return (function(x + step) - function(x - step)) / (2.0 * step)


def fisher_matrix(probabilities: Vector, scores: Matrix) -> list[list[float]]:
    """Compute F = E[psi(A) psi(A)^T]."""
    if len(probabilities) != len(scores) or not scores:
        raise ValueError("one score vector is required per action")
    dimension = len(scores[0])
    if any(len(row) != dimension for row in scores):
        raise ValueError("score vectors must have equal dimension")
    return [[sum(probabilities[a] * scores[a][j] * scores[a][k]
                 for a in range(len(probabilities)))
             for k in range(dimension)] for j in range(dimension)]


def matrix_vector(matrix: Matrix, vector: Vector) -> list[float]:
    """Multiply a matrix by a vector."""
    return [dot(row, vector) for row in matrix]


def compatible_gradient(probabilities: Vector, scores: Matrix,
                        weights: Vector) -> list[float]:
    """Compute E[psi(A) (psi(A)^T w)] directly."""
    dimension = len(weights)
    if len(probabilities) != len(scores):
        raise ValueError("one score vector is required per action")
    advantages = [dot(score, weights) for score in scores]
    return [sum(probabilities[a] * scores[a][j] * advantages[a]
                for a in range(len(probabilities)))
            for j in range(dimension)]


def importance_second_moment(behavior: Vector, target: Vector,
                             signal: Vector) -> float:
    """Compute E_behavior[(target/behavior * signal)^2]."""
    if not (len(behavior) == len(target) == len(signal)):
        raise ValueError("all action arrays must have equal length")
    if any(value <= 0.0 for value in behavior):
        raise ValueError("behavior probabilities must be positive")
    return sum(b * ((t / b) * g) ** 2
               for b, t, g in zip(behavior, target, signal))


def exploration_bound(target: Vector, signal: Vector, epsilon: float) -> float:
    """Compute epsilon^{-1} E_target[signal^2]."""
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive")
    return expectation(target, [g * g for g in signal]) / epsilon


def check_coverage(behavior: Vector, target: Vector, epsilon: float,
                   tolerance: float = 1e-12) -> bool:
    """Check behavior(a) >= epsilon * target(a) for every action."""
    return epsilon > 0.0 and all(
        b + tolerance >= epsilon * t for b, t in zip(behavior, target)
    )


@dataclass(frozen=True)
class ExplorationReport:
    """Computed statistics for one importance-weighting instance."""

    second_moment: float
    upper_bound: float
    ratio: float
    coverage_holds: bool


def audit_exploration(behavior: Vector, target: Vector, signal: Vector,
                      epsilon: float) -> ExplorationReport:
    """Calculate the second moment, theorem bound, and tightness ratio."""
    moment = importance_second_moment(behavior, target, signal)
    bound = exploration_bound(target, signal, epsilon)
    ratio = moment / bound if bound else 0.0
    return ExplorationReport(moment, bound, ratio,
                             check_coverage(behavior, target, epsilon))


def demonstrate_policy_gradient() -> None:
    """Compare the score identity, finite differences, and baselines."""
    logits = [0.2, -0.4, 0.7]
    values = [1.5, -0.5, 2.0]
    coordinate = 0
    probabilities = softmax(logits)
    score = softmax_score(probabilities, coordinate)
    analytic = policy_gradient(probabilities, score, values)

    def objective(delta: float) -> float:
        shifted = list(logits)
        shifted[coordinate] += delta
        return expectation(softmax(shifted), values)

    numeric = finite_difference(objective, 0.0)
    print("\n1. Policy-gradient and baseline demonstration")
    print(f"   probabilities: {probabilities}")
    print(f"   expected score: {expectation(probabilities, score): .3e}")
    print(f"   score gradient: {analytic: .10f}")
    print(f"   finite difference: {numeric: .10f}")
    for baseline in (0.0, 1.0, 10.0):
        estimate = policy_gradient(probabilities, score, values, baseline)
        print(f"   baseline {baseline:>4.1f}: gradient {estimate: .10f}")
    assert abs(analytic - numeric) < 1e-8


def demonstrate_compatibility() -> None:
    """Compare E[psi psi^T w] with Fw."""
    probabilities = [0.2, 0.5, 0.3]
    scores = [[1.0, -0.5], [-0.4, 0.8], [0.0, -1.0]]
    weights = [1.25, -0.75]
    direct = compatible_gradient(probabilities, scores, weights)
    fisher = fisher_matrix(probabilities, scores)
    product = matrix_vector(fisher, weights)
    print("\n2. Compatible function approximation")
    print(f"   Fisher-type matrix: {fisher}")
    print(f"   direct expectation: {direct}")
    print(f"   matrix product Fw:  {product}")
    assert max(abs(x - y) for x, y in zip(direct, product)) < 1e-12


def demonstrate_exploration() -> None:
    """Audit a general instance and the sharp two-action construction."""
    epsilon = 0.2
    target = [0.6, 0.3, 0.1]
    auxiliary = [0.1, 0.4, 0.5]
    behavior = [epsilon * t + (1.0 - epsilon) * u
                for t, u in zip(target, auxiliary)]
    signal = [2.0, -1.0, 3.0]
    report = audit_exploration(behavior, target, signal, epsilon)
    print("\n3. Importance-weighted exploration bound")
    print(f"   behavior: {behavior}")
    print(f"   coverage holds: {report.coverage_holds}")
    print(f"   second moment: {report.second_moment: .10f}")
    print(f"   theorem bound: {report.upper_bound: .10f}")
    print(f"   tightness ratio: {report.ratio: .6f}")
    assert report.coverage_holds
    assert report.second_moment <= report.upper_bound + 1e-12

    sharp = audit_exploration([epsilon, 1.0 - epsilon], [1.0, 0.0],
                             [1.0, 0.0], epsilon)
    print("\n4. Sharp two-action example")
    print(f"   second moment: {sharp.second_moment: .10f}")
    print(f"   1/epsilon: {1.0 / epsilon: .10f}")
    print(f"   tightness ratio: {sharp.ratio: .6f}")
    assert abs(sharp.second_moment - 1.0 / epsilon) < 1e-12


def main() -> None:
    """Run all numerical demonstrations."""
    print("Finite Policy Gradients and Exploration Bounds")
    demonstrate_policy_gradient()
    demonstrate_compatibility()
    demonstrate_exploration()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
