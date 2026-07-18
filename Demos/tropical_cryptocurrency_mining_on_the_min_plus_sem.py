#!/usr/bin/env python3
"""Numerical demonstrations for min-plus tropical hashing.

The examples use integer-valued data so that all displayed equalities are exact.
No third-party packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from random import Random
from time import perf_counter
from typing import Iterable, Sequence

Number = int | float


@dataclass(frozen=True)
class MinimumCertificate:
    """A minimum together with every coordinate that attains it."""

    value: Number
    witnesses: tuple[int, ...]


def _same_length(*vectors: Sequence[Number]) -> int:
    """Validate nonempty equal-length vectors and return their length."""
    if not vectors or not vectors[0]:
        raise ValueError("vectors must be nonempty")
    k = len(vectors[0])
    if any(len(vector) != k for vector in vectors):
        raise ValueError("all vectors must have the same length")
    return k


def tropical_hash(message: Sequence[Number], key: Sequence[Number]) -> Number:
    """Return min_i(message[i] + key[i]) in O(k) time."""
    _same_length(message, key)
    return min(x + a for x, a in zip(message, key))


def tropical_hash_certificate(
    message: Sequence[Number], key: Sequence[Number]
) -> MinimumCertificate:
    """Evaluate the scalar hash and return all minimizing coordinates."""
    _same_length(message, key)
    sums = [x + a for x, a in zip(message, key)]
    value = min(sums)
    return MinimumCertificate(value, tuple(i for i, total in enumerate(sums) if total == value))


def tropical_hash_two(
    message: Sequence[Number],
    first_key: Sequence[Number],
    second_key: Sequence[Number],
) -> tuple[Number, Number]:
    """Return the ordered pair of independently keyed min-plus hashes."""
    _same_length(message, first_key, second_key)
    return tropical_hash(message, first_key), tropical_hash(message, second_key)


def canonical_preimage(key: Sequence[Number], target: Number) -> list[Number]:
    """Construct message[i] = target - key[i], an exact preimage of target."""
    if not key:
        raise ValueError("key must be nonempty")
    return [target - a for a in key]


def fiber_certificate(
    message: Sequence[Number], key: Sequence[Number], target: Number
) -> bool:
    """Check all sums >= target and at least one sum == target."""
    _same_length(message, key)
    sums = [x + a for x, a in zip(message, key)]
    return all(target <= total for total in sums) and any(
        total == target for total in sums
    )


def construct_two_key_collision(
    message: Sequence[Number],
    first_key: Sequence[Number],
    second_key: Sequence[Number],
    increment: Number = 1,
) -> tuple[list[Number], int]:
    """Construct a deterministic collision when k >= 3.

    One minimizing witness is retained for each key. A coordinate outside the
    two-witness set is increased by a positive amount. The result lies on an
    unbounded collision ray.
    """
    k = _same_length(message, first_key, second_key)
    if k < 3:
        raise ValueError("the universal construction requires at least 3 coordinates")
    if increment <= 0:
        raise ValueError("increment must be positive")
    first_witness = tropical_hash_certificate(message, first_key).witnesses[0]
    second_witness = tropical_hash_certificate(message, second_key).witnesses[0]
    free_coordinate = next(
        i for i in range(k) if i not in {first_witness, second_witness}
    )
    collision = list(message)
    collision[free_coordinate] += increment
    return collision, free_coordinate


def concavity_gap(
    v: Sequence[Number], w: Sequence[Number], t: float
) -> float:
    """Return the nonnegative gap in concavity of min(x_0, x_1)."""
    if len(v) != 2 or len(w) != 2:
        raise ValueError("v and w must each have two coordinates")
    if not 0.0 <= t <= 1.0:
        raise ValueError("t must lie in [0, 1]")
    left = min((1.0 - t) * v[0] + t * w[0], (1.0 - t) * v[1] + t * w[1])
    right = (1.0 - t) * min(v) + t * min(w)
    return left - right


def demonstrate_exact_fiber() -> None:
    """Print a canonical inverse and verify the exact fiber certificate."""
    key = [7, -2, 11, 4]
    target = 23
    message = canonical_preimage(key, target)
    print("\n1. Exact fiber and canonical preimage")
    print(f"   key:                 {key}")
    print(f"   requested target:    {target}")
    print(f"   canonical preimage:  {message}")
    print(f"   coordinate sums:     {[x + a for x, a in zip(message, key)]}")
    print(f"   hash output:         {tropical_hash(message, key)}")
    print(f"   fiber certificate:   {fiber_certificate(message, key, target)}")
    assert tropical_hash(message, key) == target
    assert fiber_certificate(message, key, target)


def demonstrate_collision_ray() -> None:
    """Print several points on a deterministic two-key collision ray."""
    message = [8, 1, 6, 3, 10]
    first_key = [0, 7, 2, 9, 4]
    second_key = [6, 3, 8, 0, 5]
    original = tropical_hash_two(message, first_key, second_key)
    collision, coordinate = construct_two_key_collision(
        message, first_key, second_key
    )
    print("\n2. Universal two-key collision ray")
    print(f"   message:              {message}")
    print(f"   two-key output:       {original}")
    print(f"   free coordinate:      {coordinate}")
    print(f"   first collision:      {collision}")
    for increment in (1, 10, 100, 10_000):
        candidate = list(message)
        candidate[coordinate] += increment
        output = tropical_hash_two(candidate, first_key, second_key)
        print(f"   increment {increment:>5}: output {output}")
        assert candidate != message and output == original


def demonstrate_concavity() -> None:
    """Sample line segments and print their nonnegative concavity gaps."""
    pairs = [([0, 5], [7, 1]), ([-3, 4], [2, 9]), ([8, 2], [-1, 6])]
    print("\n3. Concavity of the two-coordinate minimum")
    for v, w in pairs:
        gaps = [concavity_gap(v, w, step / 10.0) for step in range(11)]
        print(f"   v={v}, w={w}, minimum sampled gap={min(gaps):.6g}")
        assert min(gaps) >= -1e-12


def sampled_collision_experiment(k: int, trials: int, seed: int = 20260718) -> int:
    """Count successful theorem-guided collisions in random integer examples."""
    if k < 3 or trials < 0:
        raise ValueError("require k >= 3 and trials >= 0")
    rng = Random(seed)
    successes = 0
    for _ in range(trials):
        message = [rng.randint(-100, 100) for _ in range(k)]
        first_key = [rng.randint(-100, 100) for _ in range(k)]
        second_key = [rng.randint(-100, 100) for _ in range(k)]
        collision, _ = construct_two_key_collision(message, first_key, second_key)
        if collision != message and tropical_hash_two(
            collision, first_key, second_key
        ) == tropical_hash_two(message, first_key, second_key):
            successes += 1
    return successes


def benchmark(block_sizes: Iterable[int] = (32, 64, 128), repeats: int = 2_000) -> None:
    """Illustrate evaluation costs; timings are not a security comparison."""
    rng = Random(7)
    print("\n4. Illustrative evaluation timings")
    print("   (Platform-dependent timings; security properties are not comparable.)")
    for k in block_sizes:
        message = [rng.randrange(256) for _ in range(k)]
        key = [rng.randrange(256) for _ in range(k)]
        payload = bytes(message)
        start = perf_counter()
        for _ in range(repeats):
            tropical_hash(message, key)
        tropical_seconds = perf_counter() - start
        start = perf_counter()
        for _ in range(repeats):
            sha256(payload).digest()
        sha_seconds = perf_counter() - start
        print(
            f"   k={k:3d}: min-plus={tropical_seconds:.6f}s, "
            f"SHA-256 library call={sha_seconds:.6f}s"
        )


def main() -> None:
    demonstrate_exact_fiber()
    demonstrate_collision_ray()
    demonstrate_concavity()
    successes = sampled_collision_experiment(k=32, trials=500)
    print(f"\nRandom illustrations: {successes}/500 constructed collisions succeeded exactly.")
    assert successes == 500
    benchmark()


if __name__ == "__main__":
    main()
