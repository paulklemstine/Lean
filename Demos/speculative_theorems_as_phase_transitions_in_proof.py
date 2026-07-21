#!/usr/bin/env python3
"""Numerical demonstrations for counted proof spaces.

The script uses only Python's standard library. It computes exact ambient word
counts, density/entropy trajectories, level-critical indices, geometric length
ratios, and a finite mixture illustrating how heterogeneous exponential regimes
can approximate heavy-tailed behavior.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, Optional, Sequence


@dataclass(frozen=True)
class PhasePoint:
    """Density and ambient entropy at one positive cutoff."""

    cutoff: int
    ambient_count: int
    provable_count: int
    density: Fraction
    entropy_density: float


def statements_up_to(k: int, n: int) -> int:
    """Return S_k(n) = 1 + k + ... + k^n exactly."""
    if k < 2:
        raise ValueError("alphabet size k must be at least 2")
    if n < 0:
        raise ValueError("cutoff n must be nonnegative")
    return (k ** (n + 1) - 1) // (k - 1)


def phase_trajectory(k: int, provable: Callable[[int], int],
                     max_n: int) -> list[PhasePoint]:
    """Compute the phase trajectory for cutoffs 1 through max_n."""
    if max_n < 1:
        raise ValueError("max_n must be positive")
    points: list[PhasePoint] = []
    for n in range(1, max_n + 1):
        total = statements_up_to(k, n)
        count = provable(n)
        if not 0 <= count <= total:
            raise ValueError(f"P({n})={count} is outside [0, S_k({n})]")
        points.append(
            PhasePoint(
                cutoff=n,
                ambient_count=total,
                provable_count=count,
                density=Fraction(count, total),
                entropy_density=math.log(total) / n,
            )
        )
    return points


def is_antitone(values: Sequence[Fraction]) -> bool:
    """Return whether values are nonincreasing."""
    return all(right <= left for left, right in zip(values, values[1:]))


def critical_index(k: int, provable: Callable[[int], int], epsilon: Fraction,
                   max_n: int) -> Optional[int]:
    """Find the unique level crossing in a checked finite antitone trajectory.

    Returns c when rho(c) >= epsilon and rho(c+1) < epsilon. The finite table is
    required to be antitone; max_n must extend beyond the crossing.
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    densities = [Fraction(provable(n), statements_up_to(k, n))
                 for n in range(max_n + 1)]
    if not is_antitone(densities):
        raise ValueError("density is not antitone on the supplied range")
    if epsilon > densities[0]:
        raise ValueError("epsilon exceeds the initial density")
    for c in range(max_n):
        if densities[c] >= epsilon > densities[c + 1]:
            return c
    return None


def geometric_length_probability(k: float, n: int) -> float:
    """Return (1 - 1/k) exp(-n log k), the homogeneous length law."""
    if k <= 1.0:
        raise ValueError("k must exceed 1")
    if n < 0:
        raise ValueError("n must be nonnegative")
    return (1.0 - 1.0 / k) * math.exp(-n * math.log(k))


def mixed_geometric_survival(n: int, rates: Iterable[tuple[float, float]]) -> float:
    """Return a normalized finite mixture sum w exp(-rate*n)."""
    pairs = list(rates)
    if n < 0 or not pairs or any(rate <= 0 or weight < 0 for rate, weight in pairs):
        raise ValueError("use n >= 0, positive rates, and nonnegative weights")
    total_weight = sum(weight for _, weight in pairs)
    if total_weight <= 0:
        raise ValueError("total mixture weight must be positive")
    return sum(weight * math.exp(-rate * n) for rate, weight in pairs) / total_weight


def print_phase_demo(k: int, a: int, max_n: int) -> None:
    """Print P(n)=a^n trajectories, showing density decay and entropy growth."""
    if not 0 <= a < k:
        raise ValueError("the demonstration requires 0 <= a < k")
    points = phase_trajectory(k, lambda n: a ** n, max_n)
    print(f"\nPhase trajectory: k={k}, P(n)={a}^n")
    print(" n       S_k(n)       P(n)        density      entropy density")
    for point in points:
        print(
            f"{point.cutoff:2d} {point.ambient_count:12d} "
            f"{point.provable_count:10d} {float(point.density):14.8f} "
            f"{point.entropy_density:16.8f}"
        )
    print(f"Limits predicted: density -> 0, entropy density -> log(k) = {math.log(k):.8f}")


def print_crossing_demo() -> None:
    """Show the exact k=3, P(n)=2^n crossing at epsilon=1/4."""
    epsilon = Fraction(1, 4)
    c = critical_index(3, lambda n: 2 ** n, epsilon, 20)
    assert c == 2
    rho_c = Fraction(2 ** c, statements_up_to(3, c))
    rho_next = Fraction(2 ** (c + 1), statements_up_to(3, c + 1))
    print("\nExact critical-index demonstration")
    print(f"epsilon = {epsilon}; c = {c}")
    print(f"rho(c) = {rho_c} >= epsilon; rho(c+1) = {rho_next} < epsilon")


def print_length_demo(k: float, max_n: int) -> None:
    """Print probabilities and verify their constant successive ratio."""
    values = [geometric_length_probability(k, n) for n in range(max_n + 1)]
    print(f"\nGeometric length model for k={k:g}")
    print(" n       probability     successive ratio")
    for n, value in enumerate(values):
        ratio = "--" if n == 0 else f"{value / values[n - 1]:.8f}"
        print(f"{n:2d} {value:17.10f} {ratio:>20}")
    print(f"Predicted constant ratio: 1/k = {1.0 / k:.8f}")


def print_mixture_demo() -> None:
    """Compare one exponential rate with a heterogeneous finite mixture."""
    rates = [(0.01 * j, (0.01 * j) ** 0.5) for j in range(1, 101)]
    print("\nHeterogeneous exponential mixture (exploratory finite approximation)")
    print(" n     single exp(-0.2n)       mixture       local log-log slope")
    previous_n: Optional[int] = None
    previous_mix: Optional[float] = None
    for n in (5, 10, 20, 40, 80, 160):
        single = math.exp(-0.2 * n)
        mixture = mixed_geometric_survival(n, rates)
        slope = "--"
        if previous_n is not None and previous_mix is not None:
            alpha = -math.log(mixture / previous_mix) / math.log(n / previous_n)
            slope = f"{alpha:.5f}"
        print(f"{n:3d} {single:21.10e} {mixture:13.10e} {slope:>21}")
        previous_n, previous_mix = n, mixture
    print("The finite mixture decays more slowly than a single exponential; it is illustrative,")
    print("not a proof of an asymptotic power law for any deductive system.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--k", type=int, default=3, help="alphabet size for phase demo")
    parser.add_argument("--a", type=int, default=2, help="subfamily exponential base")
    parser.add_argument("--max-n", type=int, default=12, help="largest displayed cutoff")
    args = parser.parse_args()

    print("Counted Proof Spaces: Numerical Demonstrations")
    print(f"Binary boundary check: S_2(3) = {statements_up_to(2, 3)}")
    assert statements_up_to(2, 3) == 15
    print_phase_demo(args.k, args.a, args.max_n)
    print_crossing_demo()
    print_length_demo(float(args.k), min(args.max_n, 12))
    print_mixture_demo()


if __name__ == "__main__":
    main()
