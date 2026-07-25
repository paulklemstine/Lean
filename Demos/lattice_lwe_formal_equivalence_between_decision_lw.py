#!/usr/bin/env python3
"""Numerical demonstrations of unit-affine rerandomization modulo q.

The script uses only the Python standard library.  It verifies the affine
bijection criterion, Euler-totient count, sum invariance, Chinese-remainder
factorization, and the finite advantage pigeonhole bound on concrete examples.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import gcd
from random import Random
from statistics import mean
from typing import Callable, Iterable, Sequence


@dataclass(frozen=True)
class AffineReport:
    """Summary of the affine map x -> a*x+b modulo q."""

    modulus: int
    multiplier: int
    shift: int
    is_unit: bool
    image_size: int
    outputs: tuple[int, ...]

    @property
    def is_bijection(self) -> bool:
        return self.image_size == self.modulus


def validate_modulus(q: int) -> None:
    """Raise ValueError unless q is a positive modulus."""
    if q <= 0:
        raise ValueError("the modulus q must be positive")


def affine_map(x: int, a: int, b: int, q: int) -> int:
    """Return a*x+b modulo q."""
    validate_modulus(q)
    return (a * x + b) % q


def units_mod(q: int) -> list[int]:
    """List all units in Z/qZ using the coprimality criterion."""
    validate_modulus(q)
    return [a for a in range(q) if gcd(a, q) == 1]


def euler_totient(q: int) -> int:
    """Compute Euler's totient by exact finite enumeration."""
    return len(units_mod(q))


def affine_report(q: int, a: int, b: int) -> AffineReport:
    """Evaluate an affine map on every residue and summarize its image."""
    outputs = tuple(affine_map(x, a, b, q) for x in range(q))
    return AffineReport(
        modulus=q,
        multiplier=a % q,
        shift=b % q,
        is_unit=gcd(a, q) == 1,
        image_size=len(set(outputs)),
        outputs=outputs,
    )


def verify_affine_criterion(q: int) -> bool:
    """Check for every a,b that bijectivity is equivalent to gcd(a,q)=1."""
    validate_modulus(q)
    return all(
        affine_report(q, a, b).is_bijection == (gcd(a, q) == 1)
        for a in range(q)
        for b in range(q)
    )


def transformed_sum(
    q: int, a: int, b: int, statistic: Callable[[int], float]
) -> float:
    """Sum a statistic after the affine transformation."""
    return sum(statistic(affine_map(x, a, b, q)) for x in range(q))


def verify_sum_invariance(
    q: int, a: int, b: int, statistic: Callable[[int], float]
) -> tuple[float, float, bool]:
    """Compare original and transformed finite sums."""
    original = sum(statistic(x) for x in range(q))
    transformed = transformed_sum(q, a, b, statistic)
    return original, transformed, abs(original - transformed) < 1e-12


def crt_pair(x: int, m: int, n: int) -> tuple[int, int]:
    """Return the Chinese-remainder components of x."""
    validate_modulus(m)
    validate_modulus(n)
    if gcd(m, n) != 1:
        raise ValueError("CRT components must be coprime")
    return x % m, x % n


def verify_crt_units(m: int, n: int) -> bool:
    """Check unit status modulo mn against both coprime components."""
    if gcd(m, n) != 1:
        raise ValueError("m and n must be coprime")
    return all(
        (gcd(a, m * n) == 1)
        == (gcd(a % m, m) == 1 and gcd(a % n, n) == 1)
        for a in range(m * n)
    )


def advantage_witness(delta: float, contributions: Sequence[float]) -> tuple[int, float]:
    """Return an index attaining the largest contribution.

    If delta <= sum(contributions), this index necessarily has contribution at
    least delta/len(contributions), which is checked before returning.
    """
    if not contributions:
        raise ValueError("the contribution family must be nonempty")
    if delta > sum(contributions) + 1e-12:
        raise ValueError("delta must not exceed the sum of contributions")
    index = max(range(len(contributions)), key=contributions.__getitem__)
    threshold = delta / len(contributions)
    if contributions[index] + 1e-12 < threshold:
        raise AssertionError("finite averaging bound unexpectedly failed")
    return index, threshold


def sample_units(q: int, count: int, seed: int = 20260725) -> tuple[list[int], int]:
    """Sample uniform units by rejection and return samples and proposal count."""
    validate_modulus(q)
    if count < 0:
        raise ValueError("count must be nonnegative")
    rng = Random(seed)
    accepted: list[int] = []
    proposals = 0
    while len(accepted) < count:
        proposals += 1
        candidate = rng.randrange(q)
        if gcd(candidate, q) == 1:
            accepted.append(candidate)
    return accepted, proposals


def histogram(values: Iterable[int]) -> dict[int, int]:
    """Return a sorted frequency table."""
    return dict(sorted(Counter(values).items()))


def main() -> None:
    """Run five self-contained numerical demonstrations."""
    print("UNIT-AFFINE RERANDOMIZATION: NUMERICAL DEMONSTRATIONS\n")

    q = 12
    print(f"1. Affine criterion modulo {q}")
    for a in (5, 4):
        report = affine_report(q, a, 3)
        print(
            f"   a={a:2d}, gcd(a,q)={gcd(a,q)}, unit={report.is_unit}, "
            f"image size={report.image_size}, outputs={report.outputs}"
        )
    print(f"   Exhaustive criterion check: {verify_affine_criterion(q)}\n")

    print("2. Totient count and unit density")
    for modulus in (8, 12, 15, 40):
        units = units_mod(modulus)
        print(
            f"   q={modulus:2d}: units={units}, phi(q)={len(units)}, "
            f"density={len(units)/modulus:.3f}"
        )
    print()

    print("3. Sum and average invariance")
    statistic = lambda x: float(x * x + 2 * x + 1)
    for a in (5, 4):
        original, transformed, equal = verify_sum_invariance(12, a, 3, statistic)
        print(
            f"   a={a}: original sum={original:.0f}, transformed sum={transformed:.0f}, "
            f"equal={equal}"
        )
    print("   The unit multiplier preserves the sum; the nonunit need not.\n")

    print("4. Chinese-remainder factorization")
    m, n = 5, 8
    print(f"   Componentwise unit check for {m}*{n}: {verify_crt_units(m, n)}")
    print(
        f"   phi({m*n})={euler_totient(m*n)} and "
        f"phi({m})*phi({n})={euler_totient(m)*euler_totient(n)}\n"
    )

    print("5. Hybrid advantage and rejection sampling")
    delta = 0.24
    contributions = [0.01, 0.02, 0.04, 0.03, 0.08, 0.02, 0.03, 0.01]
    witness, threshold = advantage_witness(delta, contributions)
    print(
        f"   delta={delta:.3f}, q={len(contributions)}, threshold={threshold:.3f}; "
        f"residue {witness} contributes {contributions[witness]:.3f}"
    )
    samples, proposals = sample_units(30, 10_000)
    empirical_trials = proposals / len(samples)
    theoretical_trials = 30 / euler_totient(30)
    print(
        f"   q=30 rejection sampler: empirical proposals/acceptance="
        f"{empirical_trials:.3f}, theory={theoretical_trials:.3f}"
    )
    frequencies = histogram(samples)
    expected_frequency = mean(frequencies.values())
    print(f"   accepted-unit frequencies={frequencies}")
    print(f"   mean frequency per unit={expected_frequency:.1f}")


if __name__ == "__main__":
    main()
