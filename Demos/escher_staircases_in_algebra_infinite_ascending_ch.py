#!/usr/bin/env python3
"""Finite numerical illustrations of Escher staircases and divisibility chains.

The computations model finite windows of the infinite constructions. They display
explicit strictness witnesses and audit chain orientation; the mathematical
proofs in the accompanying paper establish the corresponding infinite results.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

Vector = tuple[int, ...]


def in_initial_support_ideal(vector: Sequence[int], n: int) -> bool:
    """Return whether a finite vector vanishes at every index k >= n."""
    if not 0 <= n <= len(vector):
        raise ValueError("n must lie between 0 and the vector length")
    return all(value == 0 for value in vector[n:])


def coordinate_witness(n: int, length: int) -> Vector:
    """Construct e_n, which belongs to rung n+1 but not rung n."""
    if not 0 <= n < length:
        raise ValueError("n must be a valid coordinate")
    return tuple(1 if k == n else 0 for k in range(length))


def in_power_divisibility_ideal(values: Iterable[int], n: int, base: int = 2) -> bool:
    """Test whether every sampled value is divisible by base**n."""
    if n < 0 or base < 2:
        raise ValueError("n must be nonnegative and base must be at least 2")
    modulus = base**n
    return all(value % modulus == 0 for value in values)


def constant_divisibility_witness(n: int, sample_count: int, base: int = 2) -> Vector:
    """Values of the constant base**n, separating divisibility levels n and n+1."""
    if n < 0 or sample_count < 1 or base < 2:
        raise ValueError("invalid exponent, sample count, or base")
    return (base**n,) * sample_count


def variable_prefix_membership(monomial_variables: Iterable[int], n: int) -> bool:
    """Test monomial membership in (x_0,...,x_{n-1}) by variable occurrence."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return any(0 <= index < n for index in monomial_variables)


@dataclass(frozen=True)
class AuditResult:
    """Orientation summary for a finite sequence of sets."""

    orientation: str
    ascending_witnesses: tuple[int | None, ...]
    descending_witnesses: tuple[int | None, ...]


def audit_chain(sets: Sequence[set[int]]) -> AuditResult:
    """Classify adjacent finite sets and retain strict-difference witnesses."""
    if len(sets) < 2:
        raise ValueError("at least two sets are required")
    ascending = all(left <= right for left, right in zip(sets, sets[1:]))
    descending = all(right <= left for left, right in zip(sets, sets[1:]))
    if ascending and not descending:
        orientation = "ascending"
    elif descending and not ascending:
        orientation = "descending"
    elif ascending and descending:
        orientation = "constant"
    else:
        orientation = "mixed"
    up = tuple(next(iter(right - left), None) for left, right in zip(sets, sets[1:]))
    down = tuple(next(iter(left - right), None) for left, right in zip(sets, sets[1:]))
    return AuditResult(orientation, up, down)


def show_initial_support_staircase(length: int = 7) -> None:
    """Print adjacent witnesses for the finite-window initial-support chain."""
    print("\n1. Initial-support ideals in an integer-sequence window")
    for n in range(length):
        witness = coordinate_witness(n, length)
        lower = in_initial_support_ideal(witness, n)
        upper = in_initial_support_ideal(witness, n + 1)
        print(f"S_{n} < S_{n+1}: e_{n}={witness}, in lower={lower}, in upper={upper}")
    assert all(
        not in_initial_support_ideal(coordinate_witness(n, length), n)
        and in_initial_support_ideal(coordinate_witness(n, length), n + 1)
        for n in range(length)
    )


def show_divisibility_descent(levels: int = 7, samples: int = 5) -> None:
    """Print constant witnesses proving that divisibility levels descend."""
    print("\n2. Pointwise power-of-two divisibility ideals")
    for n in range(levels):
        witness = constant_divisibility_witness(n, samples)
        at_n = in_power_divisibility_ideal(witness, n)
        at_next = in_power_divisibility_ideal(witness, n + 1)
        print(f"D_{n+1} < D_{n}: constant 2^{n}={2**n}, in D_{n}={at_n}, in D_{n+1}={at_next}")
    assert all(
        in_power_divisibility_ideal(constant_divisibility_witness(n, samples), n)
        and not in_power_divisibility_ideal(constant_divisibility_witness(n, samples), n + 1)
        for n in range(levels)
    )


def show_polynomial_prefix_witnesses(levels: int = 7) -> None:
    """Model why x_n enters (x_0,...,x_n) but not (x_0,...,x_{n-1})."""
    print("\n3. Variable-prefix ideals in a countable polynomial ring")
    for n in range(levels):
        monomial = (n,)  # the monomial x_n
        lower = variable_prefix_membership(monomial, n)
        upper = variable_prefix_membership(monomial, n + 1)
        print(f"J_{n} < J_{n+1}: x_{n}, in lower={lower}, in upper={upper}")
        assert not lower and upper


def show_orientation_audit(bound: int = 6) -> None:
    """Audit finite set models of the ascending and descending families."""
    print("\n4. Automated orientation audit")
    support_sets = [set(range(n)) for n in range(bound + 1)]
    # Multiples of 2^n in a symmetric finite universe.
    universe = range(-(2**bound), 2**bound + 1)
    divisibility_sets = [{x for x in universe if x % (2**n) == 0} for n in range(bound + 1)]
    support_audit = audit_chain(support_sets)
    divisibility_audit = audit_chain(divisibility_sets)
    print("Initial-support coordinate sets:", support_audit)
    print("Power-divisibility value sets:", divisibility_audit)
    assert support_audit.orientation == "ascending"
    assert divisibility_audit.orientation == "descending"


def main() -> None:
    """Run all demonstrations."""
    print("ESCHER STAIRCASES: FINITE NUMERICAL DEMONSTRATIONS")
    show_initial_support_staircase()
    show_divisibility_descent()
    show_polynomial_prefix_witnesses()
    show_orientation_audit()
    print("\nAll finite witness checks passed.")


if __name__ == "__main__":
    main()
