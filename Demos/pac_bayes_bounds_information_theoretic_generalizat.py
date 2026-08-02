"""Numerical demonstrations of finite information-to-compression bounds."""
from __future__ import annotations

from dataclasses import dataclass
from math import isclose, log, sqrt
from typing import Sequence

Matrix = Sequence[Sequence[float]]


@dataclass(frozen=True)
class BoundReport:
    mutual_information: float
    expected_length: float
    maximum_length: float
    information_radius: float
    expected_length_radius: float
    maximum_length_radius: float


def validate_joint(joint: Matrix) -> None:
    """Check that a rectangular matrix is a strictly positive probability law."""
    if not joint or not joint[0]:
        raise ValueError("The joint table must be nonempty.")
    width = len(joint[0])
    if any(len(row) != width for row in joint):
        raise ValueError("The joint table must be rectangular.")
    if any(value <= 0.0 for row in joint for value in row):
        raise ValueError("Every joint probability must be strictly positive.")
    if not isclose(sum(map(sum, joint)), 1.0, rel_tol=1e-12, abs_tol=1e-12):
        raise ValueError("Joint probabilities must sum to one.")


def marginals(joint: Matrix) -> tuple[list[float], list[float]]:
    validate_joint(joint)
    sample = [sum(row) for row in joint]
    hypothesis = [sum(row[h] for row in joint) for h in range(len(joint[0]))]
    return sample, hypothesis


def information_density(joint: Matrix) -> list[list[float]]:
    sample, hypothesis = marginals(joint)
    return [
        [log(joint[s][h] / (sample[s] * hypothesis[h])) for h in range(len(hypothesis))]
        for s in range(len(sample))
    ]


def mutual_information(joint: Matrix) -> float:
    density = information_density(joint)
    return sum(joint[s][h] * density[s][h]
               for s in range(len(joint)) for h in range(len(joint[0])))


def dominating_lengths(joint: Matrix, margin: float = 0.10) -> list[float]:
    """Choose one length per hypothesis that dominates every local density."""
    if margin < 0.0:
        raise ValueError("The safety margin must be nonnegative.")
    density = information_density(joint)
    return [max(density[s][h] for s in range(len(joint))) + margin
            for h in range(len(joint[0]))]


def expected_description_length(joint: Matrix, lengths: Sequence[float]) -> float:
    _, hypothesis = marginals(joint)
    if len(lengths) != len(hypothesis):
        raise ValueError("There must be one length per hypothesis.")
    return sum(probability * length for probability, length in zip(hypothesis, lengths))


def radius(sample_size: int, complexity: float) -> float:
    if sample_size <= 0:
        raise ValueError("Sample size must be positive.")
    if complexity < 0.0:
        raise ValueError("This numerical demo requires nonnegative complexity.")
    return sqrt(complexity / (2.0 * sample_size))


def analyze(joint: Matrix, sample_size: int, delta: float, margin: float = 0.10) -> BoundReport:
    if not 0.0 < delta < 1.0:
        raise ValueError("Confidence parameter delta must lie in (0, 1).")
    lengths = dominating_lengths(joint, margin)
    density = information_density(joint)
    assert all(density[s][h] <= lengths[h] + 1e-12
               for s in range(len(joint)) for h in range(len(joint[0])))
    information = mutual_information(joint)
    expected = expected_description_length(joint, lengths)
    maximum = max(lengths)
    penalty = log(1.0 / delta)
    report = BoundReport(
        information,
        expected,
        maximum,
        radius(sample_size, information + penalty),
        radius(sample_size, expected + penalty),
        radius(sample_size, maximum + penalty),
    )
    assert report.mutual_information <= report.expected_length + 1e-12
    assert report.expected_length <= report.maximum_length + 1e-12
    assert report.information_radius <= report.expected_length_radius + 1e-12
    assert report.expected_length_radius <= report.maximum_length_radius + 1e-12
    return report


def print_report(report: BoundReport) -> None:
    print(f"Mutual information:          {report.mutual_information:.6f} nats")
    print(f"Expected description length: {report.expected_length:.6f} nats")
    print(f"Maximum description length:  {report.maximum_length:.6f} nats")
    print(f"Information radius:          {report.information_radius:.6f}")
    print(f"Expected-length radius:      {report.expected_length_radius:.6f}")
    print(f"Maximum-length radius:       {report.maximum_length_radius:.6f}")


def main() -> None:
    joint = [
        [0.24, 0.10, 0.06],
        [0.08, 0.20, 0.32],
    ]
    print("Finite PAC-Bayes information/compression example")
    print_report(analyze(joint, sample_size=200, delta=0.05))
    print("\nSample-size scaling with the same complexity:")
    for n in (50, 200, 800):
        report = analyze(joint, sample_size=n, delta=0.05)
        print(f"n={n:4d}: expected-length radius={report.expected_length_radius:.6f}")


if __name__ == "__main__":
    main()
