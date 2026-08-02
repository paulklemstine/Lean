#!/usr/bin/env python3
"""Numerical demonstrations of unique polynomial reconstruction with errors.

The examples use prime fields and exhaustive search, deliberately favoring
clarity over cryptographic-scale performance. No third-party packages are
required.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Candidate:
    """A polynomial candidate and the locations where it disagrees."""

    coefficients: tuple[int, ...]
    disagreements: tuple[int, ...]

    @property
    def secret(self) -> int:
        """Return the constant coefficient."""
        return self.coefficients[0]


def evaluate_polynomial(coefficients: Sequence[int], x: int, prime: int) -> int:
    """Evaluate a low-to-high coefficient polynomial in the field F_prime."""
    value = 0
    for coefficient in reversed(coefficients):
        value = (value * x + coefficient) % prime
    return value


def received_word(
    coefficients: Sequence[int], locations: Sequence[int], prime: int
) -> list[int]:
    """Evaluate a polynomial at all supplied locations."""
    return [evaluate_polynomial(coefficients, x, prime) for x in locations]


def disagreement_indices(
    coefficients: Sequence[int],
    locations: Sequence[int],
    received: Sequence[int],
    prime: int,
) -> tuple[int, ...]:
    """Return indices at which a candidate differs from the received word."""
    if len(locations) != len(received):
        raise ValueError("locations and received values must have equal length")
    return tuple(
        index
        for index, (x, observed) in enumerate(zip(locations, received))
        if evaluate_polynomial(coefficients, x, prime) != observed % prime
    )


def exhaustive_candidates(
    prime: int,
    degree_bound: int,
    locations: Sequence[int],
    received: Sequence[int],
    error_budget: int,
) -> list[Candidate]:
    """Enumerate every degree-at-most-bound candidate within the error budget."""
    if prime < 2:
        raise ValueError("prime must be at least 2")
    if degree_bound < 0 or error_budget < 0:
        raise ValueError("degree and error bounds must be nonnegative")
    if len(set(x % prime for x in locations)) != len(locations):
        raise ValueError("locations must be distinct modulo the prime")

    result: list[Candidate] = []
    for coefficients in product(range(prime), repeat=degree_bound + 1):
        bad = disagreement_indices(coefficients, locations, received, prime)
        if len(bad) <= error_budget:
            result.append(Candidate(coefficients, bad))
    return result


def corrupt(
    values: Sequence[int], changes: Iterable[tuple[int, int]], prime: int
) -> list[int]:
    """Return a copy with selected zero-based positions replaced modulo prime."""
    result = [value % prime for value in values]
    for index, replacement in changes:
        result[index] = replacement % prime
    return result


def demonstrate_unique_reconstruction() -> None:
    """Show a quadratic uniquely recovered from five shares with one error."""
    prime = 17
    polynomial = (5, 3, 2)  # 5 + 3x + 2x^2
    locations = [1, 2, 3, 4, 5]
    honest = received_word(polynomial, locations, prime)
    received = corrupt(honest, [(2, 4)], prime)
    candidates = exhaustive_candidates(prime, 2, locations, received, 1)

    print("=== Unique reconstruction at n = d + 2e + 1 ===")
    print(f"Field: F_{prime}")
    print(f"Locations: {locations}")
    print(f"Honest values: {honest}")
    print(f"Received values: {received}")
    print(f"Candidates within one error: {len(candidates)}")
    for candidate in candidates:
        bad_locations = [locations[i] for i in candidate.disagreements]
        print(
            f"  coefficients={candidate.coefficients}, "
            f"secret={candidate.secret}, disagreements={bad_locations}"
        )
    assert candidates == [Candidate(polynomial, (2,))]


def demonstrate_ambiguity_below_threshold() -> None:
    """Construct two nearby quadratics when only four shares are supplied."""
    prime = 17
    locations = [1, 2, 3, 4]
    first = (0, 0, 0)  # p(x) = 0
    # q(x) = (x-1)(x-2) = x^2 - 3x + 2, agreeing with p at 1 and 2.
    second = (2, 14, 1)
    first_values = received_word(first, locations, prime)
    second_values = received_word(second, locations, prime)
    # At x=3 use q's value; at x=4 use p's value.
    received = [first_values[0], first_values[1], second_values[2], first_values[3]]
    candidates = exhaustive_candidates(prime, 2, locations, received, 1)

    print("\n=== Ambiguity below the threshold ===")
    print("Parameters: n=4, d=2, e=1; required threshold is 5")
    print(f"Received values: {received}")
    print(f"Candidates within one error: {len(candidates)}")
    for candidate in candidates:
        bad_locations = [locations[i] for i in candidate.disagreements]
        print(
            f"  coefficients={candidate.coefficients}, "
            f"secret={candidate.secret}, disagreements={bad_locations}"
        )
    assert Candidate(first, (2,)) in candidates
    assert Candidate(second, (3,)) in candidates
    assert len(candidates) >= 2


def verify_small_parameter_family() -> None:
    """Exhaustively check uniqueness for every received word in a tiny case."""
    prime = 3
    degree_bound = 1
    error_budget = 1
    locations = [0, 1, 2]
    # Here n=3 and d+2e+1=4, so the theorem does not apply. Instead use e=0
    # for a complete positive check at n=d+1=2 on the first two locations.
    positive_locations = locations[:2]
    checked = 0
    for received in product(range(prime), repeat=len(positive_locations)):
        candidates = exhaustive_candidates(
            prime, degree_bound, positive_locations, received, 0
        )
        assert len(candidates) == 1
        checked += 1
    print("\n=== Exhaustive interpolation sanity check ===")
    print(
        f"Checked all {checked} received words over F_{prime} at "
        "n=d+1=2 with e=0; every word has exactly one linear candidate."
    )


def main() -> None:
    """Run all demonstrations."""
    demonstrate_unique_reconstruction()
    demonstrate_ambiguity_below_threshold()
    verify_small_parameter_family()


if __name__ == "__main__":
    main()
