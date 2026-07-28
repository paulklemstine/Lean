#!/usr/bin/env python3
"""Numerical demonstrations for Cauchy attention on the unit sphere.

The script uses only Python's standard library. It checks the sharp antipodal
weight, samples random spherical keys, audits fixed-threshold activity, and
compares the unscaled kernel with bandwidth-scaled alternatives.
"""

from __future__ import annotations

import argparse
import math
import random
from dataclasses import dataclass
from typing import Iterable, Sequence

Vector = tuple[float, ...]


@dataclass(frozen=True)
class ExperimentSummary:
    dimension: int
    key_count: int
    threshold: float
    beta: float
    minimum_weight: float
    maximum_weight: float
    mean_weight: float
    active_count: int


def squared_distance(x: Sequence[float], y: Sequence[float]) -> float:
    """Return the squared Euclidean distance between equal-length vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have the same dimension")
    return math.fsum((a - b) ** 2 for a, b in zip(x, y))


def normalize(x: Sequence[float]) -> Vector:
    """Normalize a nonzero vector to Euclidean norm one."""
    norm = math.sqrt(math.fsum(value * value for value in x))
    if norm == 0.0:
        raise ValueError("the zero vector cannot be normalized")
    return tuple(value / norm for value in x)


def random_unit_vector(dimension: int, rng: random.Random) -> Vector:
    """Sample a uniform point on the Euclidean unit sphere."""
    if dimension < 1:
        raise ValueError("dimension must be positive")
    return normalize(tuple(rng.gauss(0.0, 1.0) for _ in range(dimension)))


def cauchy_weight(q: Sequence[float], k: Sequence[float], beta: float = 1.0) -> float:
    """Evaluate (1 + beta * ||q-k||^2)^(-1) for positive beta."""
    if beta <= 0.0:
        raise ValueError("beta must be positive")
    return 1.0 / (1.0 + beta * squared_distance(q, k))


def active_count(
    q: Sequence[float], keys: Iterable[Sequence[float]], threshold: float, beta: float = 1.0
) -> int:
    """Count keys whose bandwidth-scaled Cauchy weight is at least threshold."""
    return sum(cauchy_weight(q, key, beta) >= threshold for key in keys)


def run_experiment(
    dimension: int,
    key_count: int,
    threshold: float,
    beta: float,
    seed: int,
) -> ExperimentSummary:
    """Sample one query and many keys and summarize their Cauchy weights."""
    if key_count < 1:
        raise ValueError("key_count must be positive")
    rng = random.Random(seed)
    query = random_unit_vector(dimension, rng)
    keys = [random_unit_vector(dimension, rng) for _ in range(key_count)]
    weights = [cauchy_weight(query, key, beta) for key in keys]
    return ExperimentSummary(
        dimension=dimension,
        key_count=key_count,
        threshold=threshold,
        beta=beta,
        minimum_weight=min(weights),
        maximum_weight=max(weights),
        mean_weight=math.fsum(weights) / key_count,
        active_count=sum(weight >= threshold for weight in weights),
    )


def print_summary(summary: ExperimentSummary) -> None:
    """Print a compact report for an experiment."""
    theoretical_floor = 1.0 / (1.0 + 4.0 * summary.beta)
    print(
        f"beta={summary.beta:g}, d={summary.dimension}, N={summary.key_count}, "
        f"threshold={summary.threshold:g}"
    )
    print(f"  theoretical spherical floor: {theoretical_floor:.9f}")
    print(f"  observed weight range:       [{summary.minimum_weight:.9f}, "
          f"{summary.maximum_weight:.9f}]")
    print(f"  observed mean weight:        {summary.mean_weight:.9f}")
    print(f"  active keys:                 {summary.active_count}/{summary.key_count}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dimension", type=int, default=32)
    parser.add_argument("--keys", type=int, default=4096)
    parser.add_argument("--threshold", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=20260728)
    args = parser.parse_args()

    query = normalize((1.0, 0.0, 0.0))
    antipode = tuple(-value for value in query)
    endpoint = cauchy_weight(query, antipode)
    print("Sharp antipodal example")
    print(f"  ||q-(-q)||^2 = {squared_distance(query, antipode):.1f}")
    print(f"  K(q,-q)       = {endpoint:.9f} (exact value: 1/5)\n")
    assert math.isclose(endpoint, 0.2, rel_tol=0.0, abs_tol=1e-15)

    print("Random spherical audit")
    unscaled = run_experiment(
        args.dimension, args.keys, args.threshold, beta=1.0, seed=args.seed
    )
    print_summary(unscaled)
    if args.threshold <= 0.2:
        assert unscaled.active_count == args.keys
        assert unscaled.minimum_weight >= 0.2 - 1e-12
        print("  confirmed: every key is active at threshold <= 1/5\n")

    print("Bandwidth comparison at threshold 0.2")
    for beta in (1.0, 4.0, 16.0):
        print_summary(
            run_experiment(args.dimension, args.keys, 0.2, beta, args.seed)
        )

    print("\nSquare-root benchmark")
    integer_root = math.isqrt(args.keys)
    print(f"  floor(sqrt(N)) = {integer_root}")
    print(f"  unscaled active count = {unscaled.active_count}")
    if args.keys > 1 and args.threshold <= 0.2:
        assert integer_root < unscaled.active_count
        print("  confirmed: active count is strictly larger than floor(sqrt(N))")


if __name__ == "__main__":
    main()
