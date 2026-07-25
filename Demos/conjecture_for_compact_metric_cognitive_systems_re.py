#!/usr/bin/env python3
"""Numerical demonstrations of period transport under semiconjugacy."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Callable, Iterable, TypeVar

T = TypeVar("T")
U = TypeVar("U")


@dataclass(frozen=True)
class PeriodAudit:
    """The result of checking one source state and its observation."""

    source_period: int
    observed_period: int
    divides: bool
    orbit_injective: bool


def iterate(function: Callable[[T], T], value: T, steps: int) -> T:
    """Apply ``function`` exactly ``steps`` times."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    result = value
    for _ in range(steps):
        result = function(result)
    return result


def minimal_period(function: Callable[[T], T], start: T, limit: int) -> int:
    """Return the least positive return time, searching up to ``limit``."""
    if limit < 1:
        raise ValueError("limit must be positive")
    current = start
    for period in range(1, limit + 1):
        current = function(current)
        if current == start:
            return period
    raise ValueError(f"no return to the initial state within {limit} steps")


def is_semiconjugacy(
    source_states: Iterable[T],
    source_update: Callable[[T], T],
    observed_update: Callable[[U], U],
    observe: Callable[[T], U],
) -> bool:
    """Check h(f(x)) = g(h(x)) on a finite collection of source states."""
    return all(
        observe(source_update(state)) == observed_update(observe(state))
        for state in source_states
    )


def audit_period_transport(
    source_states: list[T],
    source_update: Callable[[T], T],
    observed_update: Callable[[U], U],
    observe: Callable[[T], U],
    start: T,
) -> PeriodAudit:
    """Compute periods and test divisibility and injectivity on one orbit."""
    if not is_semiconjugacy(source_states, source_update, observed_update, observe):
        raise ValueError("the proposed observation is not a semiconjugacy")
    source_period = minimal_period(source_update, start, len(source_states))
    observed_start = observe(start)
    observed_period = minimal_period(observed_update, observed_start, source_period)
    orbit = [iterate(source_update, start, k) for k in range(source_period)]
    labels = [observe(state) for state in orbit]
    return PeriodAudit(
        source_period=source_period,
        observed_period=observed_period,
        divides=source_period % observed_period == 0,
        orbit_injective=len(set(labels)) == len(labels),
    )


def divisors(n: int) -> list[int]:
    """List the positive divisors of ``n`` in increasing order."""
    if n < 1:
        raise ValueError("n must be positive")
    low: list[int] = []
    high: list[int] = []
    for candidate in range(1, isqrt(n) + 1):
        if n % candidate == 0:
            low.append(candidate)
            if candidate * candidate != n:
                high.append(n // candidate)
    return low + list(reversed(high))


def residue_cycle_audit(n: int, d: int) -> PeriodAudit:
    """Audit reduction from an n-cycle to a d-cycle, where d divides n."""
    if n < 1 or d < 1 or n % d != 0:
        raise ValueError("n and d must be positive with d dividing n")
    source_update = lambda state: (state + 1) % n
    observed_update = lambda label: (label + 1) % d
    observe = lambda state: state % d
    return audit_period_transport(
        list(range(n)), source_update, observed_update, observe, 0
    )


def demonstrate_all_divisors(n: int) -> None:
    """Print the sharp quotient-cycle realization for every divisor of n."""
    print(f"\nAll dynamically realizable quotient periods of an exact {n}-cycle")
    print("observed period | fiber size | divides | orbit observation injective")
    for d in divisors(n):
        audit = residue_cycle_audit(n, d)
        print(f"{d:15d} | {n // d:10d} | {str(audit.divides):7s} | {audit.orbit_injective}")


def demonstrate_faithful_relabeling(n: int) -> None:
    """Show that a bijective relabeling preserves exact period."""
    permutation = [(3 * state + 1) % n for state in range(n)]
    if len(set(permutation)) != n:
        # Multiplication by 3 is not invertible for every n; use reversal instead.
        permutation = [n - 1 - state for state in range(n)]
    inverse = {label: state for state, label in enumerate(permutation)}
    source_update = lambda state: (state + 1) % n
    observe = lambda state: permutation[state]
    observed_update = lambda label: observe((inverse[label] + 1) % n)
    audit = audit_period_transport(
        list(range(n)), source_update, observed_update, observe, 0
    )
    print(f"\nFaithful relabeling of an exact {n}-cycle: {audit}")


def demonstrate_prime_dichotomy(primes: Iterable[int]) -> None:
    """Display the only divisor-cycle observations available for prime periods."""
    print("\nPrime-period dichotomy")
    for prime in primes:
        outcomes = [residue_cycle_audit(prime, d).observed_period for d in divisors(prime)]
        print(f"source period {prime}: possible quotient periods {outcomes}")


def main() -> None:
    """Run all examples and assert the mathematical predictions."""
    for n in (6, 12):
        demonstrate_all_divisors(n)
        for d in divisors(n):
            audit = residue_cycle_audit(n, d)
            assert audit.source_period == n
            assert audit.observed_period == d
            assert audit.divides
            assert audit.orbit_injective == (d == n)

    demonstrate_faithful_relabeling(7)
    demonstrate_prime_dichotomy((2, 3, 5, 7, 11))

    for prime in (2, 3, 5, 7, 11):
        assert divisors(prime) == [1, prime]

    print("\nAll recurrence audits passed.")


if __name__ == "__main__":
    main()
