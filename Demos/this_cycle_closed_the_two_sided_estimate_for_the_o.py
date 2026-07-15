#!/usr/bin/env python3
"""Numerical demonstrations for cubic spectral gaps on the unit path.

The normalization is
    edge_energy(f) = sum_k (f[k+1] - f[k])**2,
    dirichlet(f)   = 2 * edge_energy(f),
    variation(f)   = sum_{i,j} (f[i] - f[j])**2,
    rayleigh(f)    = dirichlet(f) / variation(f).

Only the Python standard library is required.
"""

from __future__ import annotations

import argparse
import math
import random
from typing import Iterable, List, Sequence, Tuple


def edge_energy(values: Sequence[float]) -> float:
    """Return the unoriented adjacent-increment energy in O(n) time."""
    return sum((values[k + 1] - values[k]) ** 2 for k in range(len(values) - 1))


def dirichlet_energy(values: Sequence[float]) -> float:
    """Return the oriented unit-path Dirichlet energy."""
    return 2.0 * edge_energy(values)


def pairwise_variation_fast(values: Sequence[float]) -> float:
    """Return ordered-pair variation in O(n) time using centered squares."""
    n = len(values)
    if n == 0:
        return 0.0
    mean = math.fsum(values) / n
    return 2.0 * n * math.fsum((x - mean) ** 2 for x in values)


def pairwise_variation_direct(values: Sequence[float]) -> float:
    """Return ordered-pair variation directly in O(n^2) time."""
    return math.fsum((x - y) ** 2 for x in values for y in values)


def rayleigh_quotient(values: Sequence[float]) -> float:
    """Return the normalized Rayleigh quotient of a nonconstant profile."""
    variation = pairwise_variation_fast(values)
    if variation <= 0.0:
        raise ValueError("Rayleigh quotient requires a nonconstant profile")
    return dirichlet_energy(values) / variation


def position_profile(n: int) -> List[float]:
    """Return the linear position witness (0, 1, ..., n-1)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return [float(k) for k in range(n)]


def first_cosine_profile(n: int) -> List[float]:
    """Return the first nonconstant shifted discrete-cosine path mode."""
    if n < 2:
        raise ValueError("n must be at least 2")
    return [math.cos(math.pi * (k + 0.5) / n) for k in range(n)]


def exact_position_quotient(n: int) -> float:
    """Return 12 / (n^2(n+1)), the exact position-witness quotient."""
    if n < 2:
        raise ValueError("n must be at least 2")
    return 12.0 / (n * n * (n + 1))


def cosine_candidate_gap(n: int) -> float:
    """Return the spectral value (2 - 2 cos(pi/n)) / n."""
    if n < 2:
        raise ValueError("n must be at least 2")
    return (2.0 - 2.0 * math.cos(math.pi / n)) / n


def cubic_bounds(n: int) -> Tuple[float, float]:
    """Return the proved lower and upper bounds (2/n^3, 12/n^3)."""
    if n < 2:
        raise ValueError("n must be at least 2")
    return 2.0 / n**3, 12.0 / n**3


def poincare_ratio(values: Sequence[float]) -> float:
    """Return V(f)/(n^3 E_edge(f)); the theorem bounds this by one."""
    n = len(values)
    energy = edge_energy(values)
    if n < 2 or energy <= 0.0:
        raise ValueError("profile must be nonconstant and have at least two sites")
    return pairwise_variation_fast(values) / (n**3 * energy)


def random_profile(n: int, rng: random.Random) -> List[float]:
    """Generate a reproducible centered Gaussian profile."""
    raw = [rng.gauss(0.0, 1.0) for _ in range(n)]
    mean = math.fsum(raw) / n
    return [x - mean for x in raw]


def position_witness_table(sizes: Iterable[int]) -> str:
    """Build a table comparing computed and exact position quotients."""
    rows = [
        "n    computed R       exact R          n^3 R      lower <= R <= upper",
        "-" * 76,
    ]
    for n in sizes:
        profile = position_profile(n)
        computed = rayleigh_quotient(profile)
        exact = exact_position_quotient(n)
        lower, upper = cubic_bounds(n)
        valid = lower <= computed * (1.0 + 1e-12) and computed <= upper * (1.0 + 1e-12)
        rows.append(
            f"{n:3d}  {computed: .8e}  {exact: .8e}  "
            f"{n**3 * computed:9.6f}      {str(valid):>5s}"
        )
    return "\n".join(rows)


def cosine_comparison_table(sizes: Iterable[int]) -> str:
    """Compare the ramp with the discrete cosine spectral candidate."""
    rows = [
        "n    n^3 ramp R    n^3 cosine R  formula value   pi^2",
        "-" * 68,
    ]
    for n in sizes:
        ramp = rayleigh_quotient(position_profile(n))
        cosine = rayleigh_quotient(first_cosine_profile(n))
        formula = cosine_candidate_gap(n)
        rows.append(
            f"{n:3d}   {n**3 * ramp:11.7f}   {n**3 * cosine:12.7f}  "
            f"{n**3 * formula:12.7f}  {math.pi**2:9.7f}"
        )
    return "\n".join(rows)


def random_poincare_experiment(n: int, samples: int, seed: int) -> Tuple[float, float, float]:
    """Return the minimum, mean, and maximum sampled Poincare ratios."""
    if n < 2 or samples < 1:
        raise ValueError("n must be at least 2 and samples must be positive")
    rng = random.Random(seed)
    ratios = [poincare_ratio(random_profile(n, rng)) for _ in range(samples)]
    return min(ratios), math.fsum(ratios) / samples, max(ratios)


def verify_identities(n: int) -> None:
    """Check core finite identities numerically and raise on failure."""
    profile = position_profile(n)
    direct = pairwise_variation_direct(profile)
    fast = pairwise_variation_fast(profile)
    closed = n * n * (n * n - 1) / 6.0
    expected_energy = 2.0 * (n - 1)
    assert math.isclose(direct, fast, rel_tol=1e-12, abs_tol=1e-12)
    assert math.isclose(fast, closed, rel_tol=1e-12, abs_tol=1e-12)
    assert math.isclose(dirichlet_energy(profile), expected_energy, rel_tol=1e-12)
    assert math.isclose(rayleigh_quotient(profile), exact_position_quotient(n), rel_tol=1e-12)
    assert poincare_ratio(profile) <= 1.0 + 1e-12


def main() -> None:
    """Run three demonstrations: witness scaling, cosine mode, and random tests."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-n", type=int, default=64, help="largest power-of-two path size")
    parser.add_argument("--samples", type=int, default=1000, help="number of random profiles")
    parser.add_argument("--seed", type=int, default=20260715, help="random seed")
    args = parser.parse_args()
    if args.max_n < 2:
        parser.error("--max-n must be at least 2")

    sizes: List[int] = []
    n = 2
    while n <= args.max_n:
        sizes.append(n)
        n *= 2
    if sizes[-1] != args.max_n and args.max_n not in sizes:
        sizes.append(args.max_n)

    for size in sizes:
        verify_identities(size)

    print("DEMO 1: Exact linear witness and proved cubic window")
    print(position_witness_table(sizes))
    print()

    print("DEMO 2: Linear witness versus first discrete cosine mode")
    print(cosine_comparison_table(sizes))
    print()

    print("DEMO 3: Random-profile test of V(f) <= n^3 E_edge(f)")
    minimum, mean, maximum = random_poincare_experiment(
        args.max_n, args.samples, args.seed
    )
    print(f"n={args.max_n}, samples={args.samples}, seed={args.seed}")
    print(f"minimum ratio: {minimum:.8f}")
    print(f"mean ratio:    {mean:.8f}")
    print(f"maximum ratio: {maximum:.8f}")
    print("the theorem requires every ratio to be at most 1")


if __name__ == "__main__":
    main()
