#!/usr/bin/env python3
"""Numerical demonstrations for eventual periodicity and component pruning.

The script uses only the Python standard library.  It demonstrates:
1. closure behavior for sample eventually periodic spectra;
2. saturated component-count addition;
3. arbitrary-tail encoding and the powers-of-two counterexample.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

Predicate = Callable[[int], bool]


@dataclass(frozen=True)
class PeriodicityCheck:
    """Result of checking a proposed period over a finite interval."""

    threshold: int
    period: int
    endpoint: int
    failures: tuple[int, ...]

    @property
    def passed(self) -> bool:
        return not self.failures


def check_period_window(
    predicate: Predicate, threshold: int, period: int, endpoint: int
) -> PeriodicityCheck:
    """Check S(n) = S(n + period) for threshold <= n <= endpoint."""
    if threshold < 0 or endpoint < threshold:
        raise ValueError("require 0 <= threshold <= endpoint")
    if period <= 0:
        raise ValueError("period must be positive")
    failures = tuple(
        n
        for n in range(threshold, endpoint + 1)
        if predicate(n) != predicate(n + period)
    )
    return PeriodicityCheck(threshold, period, endpoint, failures)


def saturated_count(count: int, threshold: int) -> int:
    """Return the canonical state min(count, threshold)."""
    if count < 0 or threshold < 0:
        raise ValueError("counts and thresholds must be nonnegative")
    return min(count, threshold)


def add_saturated_profiles(
    left: Sequence[int], right: Sequence[int], threshold: int
) -> tuple[int, ...]:
    """Add profiles coordinatewise and saturate every coordinate."""
    if len(left) != len(right):
        raise ValueError("profiles must have equal length")
    return tuple(
        saturated_count(a + b, threshold) for a, b in zip(left, right)
    )


def is_power_of_two(n: int) -> bool:
    """Return whether n is a positive integral power of two."""
    return n > 0 and (n & (n - 1)) == 0


def encoding_cutoff(n: int, target: Predicate) -> int:
    """Return n on the target and n - 1 off it (with truncation at zero)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return n if target(n) else max(n - 1, 0)


def shifted_singleton_membership(n: int, target: Predicate) -> bool:
    """Test whether n - f(n) belongs to the singleton spectrum {0}."""
    cutoff = encoding_cutoff(n, target)
    return n - cutoff == 0


def least_power_witness(threshold: int, period: int) -> tuple[int, int]:
    """Find 2^m > max(threshold, period), witnessing period failure."""
    if threshold < 0 or period <= 0:
        raise ValueError("require a nonnegative threshold and positive period")
    power = 1
    while power <= max(threshold, period):
        power *= 2
    return power, power + period


def periodic_residue_set(residues: Iterable[int], modulus: int) -> Predicate:
    """Create the predicate n mod modulus in residues."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    normalized = {r % modulus for r in residues}
    return lambda n: n >= 0 and n % modulus in normalized


def demonstrate_periodic_closure() -> None:
    """Display finite-window checks for intersection and union examples."""
    even = periodic_residue_set([0], 2)
    one_mod_three = periodic_residue_set([1], 3)
    intersection = lambda n: even(n) and one_mod_three(n)
    union = lambda n: even(n) or one_mod_three(n)
    print("1. PERIODIC SPECTRA AND BOOLEAN CLOSURE")
    for name, predicate, period in (
        ("even numbers", even, 2),
        ("numbers congruent to 1 mod 3", one_mod_three, 3),
        ("intersection", intersection, 6),
        ("union", union, 6),
    ):
        result = check_period_window(predicate, 0, period, 60)
        print(f"   {name:31s} period {period}: passed={result.passed}")
    print("   Intersection values:", [n for n in range(25) if intersection(n)])
    print()


def demonstrate_saturation() -> None:
    """Show that hidden large counts give the same saturated union profile."""
    q = 4
    a = (0, 2, 7, 4)
    b = (0, 2, 100, 9)
    c = (3, 1, 0, 8)
    d = (3, 1, 2, 40)
    sat_a = tuple(saturated_count(x, q) for x in a)
    sat_b = tuple(saturated_count(x, q) for x in b)
    result_ac = add_saturated_profiles(a, c, q)
    result_bd = add_saturated_profiles(b, d, q)
    print("2. SATURATED COMPONENT PROFILES")
    print(f"   threshold q = {q}")
    print(f"   sat(a)={sat_a}, sat(b)={sat_b}, equivalent={sat_a == sat_b}")
    print(f"   sat(a+c)={result_ac}")
    print(f"   sat(b+d)={result_bd}")
    print(f"   outputs agree={result_ac == result_bd}")
    print()


def demonstrate_adversarial_pruning(limit: int = 40) -> None:
    """Encode powers of two using a shift of the singleton spectrum."""
    target = [n for n in range(1, limit + 1) if is_power_of_two(n)]
    shifted = [
        n
        for n in range(1, limit + 1)
        if shifted_singleton_membership(n, is_power_of_two)
    ]
    print("3. TARGET ENCODING BY A VARIABLE CUTOFF")
    print("   powers of two:       ", target)
    print("   shifted {0} spectrum:", shifted)
    print("   exact agreement:", target == shifted)
    print()


def demonstrate_nonperiodicity_witnesses() -> None:
    """Produce explicit failures for several proposed eventual periods."""
    print("4. WITNESSES AGAINST PERIODICITY OF POWERS OF TWO")
    for threshold, period in ((0, 1), (10, 3), (100, 16), (1000, 127)):
        power, translated = least_power_witness(threshold, period)
        assert is_power_of_two(power)
        assert not is_power_of_two(translated)
        print(
            f"   N={threshold:4d}, q={period:3d}: "
            f"{power} is a power of two, but {power}+{period}={translated} is not"
        )


def main() -> None:
    """Run all demonstrations."""
    demonstrate_periodic_closure()
    demonstrate_saturation()
    demonstrate_adversarial_pruning()
    demonstrate_nonperiodicity_witnesses()


if __name__ == "__main__":
    main()
