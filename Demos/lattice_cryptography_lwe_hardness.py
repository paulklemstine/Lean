#!/usr/bin/env python3
"""Numerical demonstrations of finite statistical security and affine uniformity.

The program uses only the Python standard library.  It checks probability mass
functions, computes unnormalized l1 gaps and bounded-test advantages, verifies a
common-ideal hybrid bound, and contrasts unit and nonunit affine maps modulo q.
"""

from __future__ import annotations

from collections import Counter
from math import gcd, isclose
from typing import Callable, Iterable, Sequence

Mass = Sequence[float]


def validate_pmf(p: Mass, *, tolerance: float = 1e-12) -> None:
    """Raise ValueError unless p is a nonnegative probability mass function."""
    if not p:
        raise ValueError("a probability mass function must be nonempty")
    if any(value < -tolerance for value in p):
        raise ValueError("probability masses must be nonnegative")
    if not isclose(sum(p), 1.0, abs_tol=tolerance, rel_tol=0.0):
        raise ValueError(f"probability masses sum to {sum(p)!r}, not 1")


def l1_gap(p: Mass, q: Mass) -> float:
    """Return sum_i |p_i-q_i| after validating compatible PMFs."""
    validate_pmf(p)
    validate_pmf(q)
    if len(p) != len(q):
        raise ValueError("the distributions must have the same finite space")
    return sum(abs(px - qx) for px, qx in zip(p, q))


def expectation(p: Mass, test: Sequence[float]) -> float:
    """Return the expectation of a test whose values lie in [0, 1]."""
    validate_pmf(p)
    if len(p) != len(test):
        raise ValueError("the test and distribution must have equal lengths")
    if any(value < 0.0 or value > 1.0 for value in test):
        raise ValueError("every test value must lie in [0, 1]")
    return sum(px * tx for px, tx in zip(p, test))


def bounded_test_advantage(p: Mass, q: Mass, test: Sequence[float]) -> float:
    """Return |E_p[test]-E_q[test]|."""
    return abs(expectation(p, test) - expectation(q, test))


def common_ideal_report(
    challenge_zero: Mass,
    challenge_one: Mass,
    ideal: Mass,
    test: Sequence[float],
) -> dict[str, float]:
    """Compute both hybrid errors, their sum, and one test's advantage."""
    epsilon_zero = l1_gap(challenge_zero, ideal)
    epsilon_one = l1_gap(challenge_one, ideal)
    challenge_gap = l1_gap(challenge_zero, challenge_one)
    advantage = bounded_test_advantage(challenge_zero, challenge_one, test)
    assert challenge_gap <= epsilon_zero + epsilon_one + 1e-12
    assert advantage <= challenge_gap + 1e-12
    return {
        "epsilon_zero": epsilon_zero,
        "epsilon_one": epsilon_one,
        "hybrid_bound": epsilon_zero + epsilon_one,
        "challenge_gap": challenge_gap,
        "test_advantage": advantage,
    }


def affine_outputs(modulus: int, multiplier: int, error: int) -> list[int]:
    """Enumerate (multiplier*s+error) mod modulus for all residues s."""
    if modulus <= 1:
        raise ValueError("the modulus must exceed 1")
    return [
        (multiplier * secret + error) % modulus
        for secret in range(modulus)
    ]


def is_affine_permutation(modulus: int, multiplier: int, error: int) -> bool:
    """Decide by enumeration whether the affine residue map is a permutation."""
    return len(set(affine_outputs(modulus, multiplier, error))) == modulus


def affine_histogram(modulus: int, multiplier: int, error: int) -> Counter[int]:
    """Count each output of the affine residue map."""
    return Counter(affine_outputs(modulus, multiplier, error))


def statistic_sum(
    modulus: int,
    multiplier: int,
    error: int,
    statistic: Callable[[int], float],
) -> tuple[float, float]:
    """Compare sum_s f(a*s+e) with sum_y f(y) modulo modulus."""
    transformed = sum(
        statistic(y) for y in affine_outputs(modulus, multiplier, error)
    )
    baseline = sum(statistic(y) for y in range(modulus))
    return transformed, baseline


def format_histogram(histogram: Counter[int], modulus: int) -> str:
    """Format counts in residue order."""
    return " ".join(f"{residue}:{histogram[residue]}" for residue in range(modulus))


def run_statistical_demo() -> None:
    """Demonstrate the common-ideal and bounded-test inequalities."""
    challenge_zero = [0.27, 0.23, 0.25, 0.25]
    ideal = [0.25, 0.25, 0.25, 0.25]
    challenge_one = [0.24, 0.26, 0.23, 0.27]
    boolean_test = [1.0, 0.0, 1.0, 0.0]
    report = common_ideal_report(
        challenge_zero, challenge_one, ideal, boolean_test
    )

    print("COMMON-IDEAL STATISTICAL SECURITY")
    for name, value in report.items():
        print(f"  {name:>18}: {value:.6f}")
    print("  verified inequalities:")
    print("    challenge_gap <= epsilon_zero + epsilon_one")
    print("    test_advantage <= challenge_gap")


def run_ring_demo() -> None:
    """Contrast affine maps induced by a unit and a nonunit modulo eight."""
    modulus = 8
    error = 2
    statistic = lambda residue: float(residue * residue + 3 * residue + 1)

    print("\nAFFINE UNIFORMITY MODULO 8")
    for multiplier in (3, 2):
        outputs = affine_outputs(modulus, multiplier, error)
        histogram = affine_histogram(modulus, multiplier, error)
        transformed, baseline = statistic_sum(
            modulus, multiplier, error, statistic
        )
        unit = gcd(multiplier, modulus) == 1
        permutation = is_affine_permutation(modulus, multiplier, error)
        print(f"  multiplier={multiplier}, error={error}")
        print(f"    gcd(multiplier, modulus)={gcd(multiplier, modulus)}")
        print(f"    unit={unit}, permutation={permutation}")
        print(f"    outputs={outputs}")
        print(f"    histogram={format_histogram(histogram, modulus)}")
        print(f"    transformed statistic sum={transformed:.1f}")
        print(f"    baseline statistic sum={baseline:.1f}")
        assert unit == permutation
        if unit:
            assert isclose(transformed, baseline)


def scan_multipliers(modulus: int, error: int = 0) -> Iterable[tuple[int, bool]]:
    """Yield each multiplier and whether its affine map is a permutation."""
    for multiplier in range(modulus):
        yield multiplier, is_affine_permutation(modulus, multiplier, error)


def run_unit_scan() -> None:
    """Check that affine permutations modulo fifteen are exactly the units."""
    modulus = 15
    print("\nUNIT/PERMUTATION CORRESPONDENCE MODULO 15")
    rows = list(scan_multipliers(modulus, error=7))
    for multiplier, permutation in rows:
        unit = gcd(multiplier, modulus) == 1
        assert unit == permutation
        print(
            f"  a={multiplier:2d}: gcd(a,15)={gcd(multiplier, modulus):2d}, "
            f"permutation={permutation}"
        )


def main() -> None:
    run_statistical_demo()
    run_ring_demo()
    run_unit_scan()


if __name__ == "__main__":
    main()
