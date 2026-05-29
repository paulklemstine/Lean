"""
algorithms.py — Enumeration and Analysis of Discrete L-Data

Implements the algorithmic census of finite-description L-data as formalized
in the Lean development. Provides encoding, decoding, enumeration, and
complexity analysis of discrete Euler product data.

Key concepts:
- DiscreteEulerFactor: A local polynomial factor with bounded-degree coefficients
- FiniteDescriptionLData: Global parameters + uniform template + finitely many exceptions
- Description length: A complexity measure bounding all global parameters
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Iterator
from itertools import product as cartesian_product
import math


@dataclass(frozen=True)
class DiscreteEulerFactor:
    """A local Euler factor of degree at most d with integer coefficients.

    Represents 1 + a_0 x + a_1 x^2 + ... + a_{d-1} x^d.

    Attributes:
        coeffs: Tuple of integer coefficients (a_0, ..., a_{d-1}).
    """
    coeffs: tuple[int, ...]

    @property
    def degree(self) -> int:
        return len(self.coeffs)

    def evaluate_polynomial(self, x: complex) -> complex:
        """Evaluate 1 + sum(a_i * x^(i+1))."""
        result = complex(1, 0)
        for i, a in enumerate(self.coeffs):
            result += a * x ** (i + 1)
        return result

    def __repr__(self) -> str:
        if not self.coeffs:
            return "EulerFactor(1)"
        terms = ["1"]
        for i, a in enumerate(self.coeffs):
            if a != 0:
                terms.append(f"{a}*x^{i+1}")
        return "EulerFactor(" + " + ".join(terms) + ")"


@dataclass(frozen=True)
class FiniteDescriptionLData:
    """Finite-description L-data: an arithmetically describable Euler product.

    This is the central object of the census theory. It consists of:
    - degree: the degree of the L-function
    - conductor: the conductor (a measure of arithmetic complexity)
    - root_number: an element of a finite set (e.g., +1 or -1)
    - unramified_template: the uniform Euler factor for good primes
    - bad_primes: list of exceptional primes
    - ramified_factors: Euler factors at each bad prime

    Attributes:
        degree: Non-negative integer degree.
        conductor: Non-negative integer conductor.
        root_number: Integer root number (typically +1 or -1).
        unramified_template: Euler factor template for unramified primes.
        bad_primes: Tuple of bad (ramified) prime numbers.
        ramified_factors: Tuple of Euler factors at bad primes.
    """
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple[int, ...]
    ramified_factors: tuple[DiscreteEulerFactor, ...]

    @property
    def num_bad_primes(self) -> int:
        return len(self.bad_primes)

    @property
    def max_bad_prime(self) -> int:
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self) -> int:
        """The description length: degree + conductor + num_bad_primes + max_bad_prime + 1."""
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1

    @property
    def arithmetic_complexity(self) -> int:
        """Arithmetic complexity: degree * (num_bad_primes + 1) + conductor."""
        return self.degree * (self.num_bad_primes + 1) + self.conductor

    @property
    def conductor_weight(self) -> int:
        return self.conductor + self.num_bad_primes

    def is_unramified_at(self, p: int) -> bool:
        return p not in self.bad_primes

    def local_factor_at(self, p: int) -> DiscreteEulerFactor:
        """Return the local Euler factor at prime p."""
        if p in self.bad_primes:
            idx = self.bad_primes.index(p)
            return self.ramified_factors[idx]
        return self.unramified_template

    def __repr__(self) -> str:
        return (f"LData(deg={self.degree}, N={self.conductor}, "
                f"ε={self.root_number}, bad={self.bad_primes}, "
                f"descLen={self.description_length})")


def enumerate_euler_factors(degree: int, coeff_range: range) -> Iterator[DiscreteEulerFactor]:
    """Enumerate all Euler factors of given degree with coefficients in coeff_range.

    Args:
        degree: The degree of the Euler factor.
        coeff_range: Range of allowed coefficient values.

    Yields:
        DiscreteEulerFactor objects.
    """
    if degree == 0:
        yield DiscreteEulerFactor(())
        return
    for coeffs in cartesian_product(coeff_range, repeat=degree):
        yield DiscreteEulerFactor(coeffs)


def enumerate_ldata(
    max_description_length: int,
    coeff_range: range = range(-2, 3),
    root_numbers: tuple[int, ...] = (-1, 1),
) -> Iterator[FiniteDescriptionLData]:
    """Enumerate all FiniteDescriptionLData with description length ≤ bound.

    The enumeration is ordered primarily by description length, then by
    (degree, conductor, num_bad_primes) lexicographically.

    Args:
        max_description_length: Upper bound B on description length.
        coeff_range: Range of coefficient values for Euler factors.
        root_numbers: Allowed root number values.

    Yields:
        FiniteDescriptionLData objects with descriptionLength ≤ max_description_length.
    """
    B = max_description_length
    # descriptionLength = degree + conductor + numBadPrimes + maxBadPrime + 1 ≤ B
    # So degree + conductor + numBadPrimes + maxBadPrime ≤ B - 1
    if B < 1:
        return

    for total in range(B):  # total = degree + conductor + numBadPrimes + maxBadPrime
        for degree in range(total + 1):
            for conductor in range(total - degree + 1):
                for num_bad in range(total - degree - conductor + 1):
                    max_bp = total - degree - conductor - num_bad
                    # Enumerate templates
                    for template in enumerate_euler_factors(degree, coeff_range):
                        # Enumerate root numbers
                        for rn in root_numbers:
                            if num_bad == 0:
                                yield FiniteDescriptionLData(
                                    degree=degree,
                                    conductor=conductor,
                                    root_number=rn,
                                    unramified_template=template,
                                    bad_primes=(),
                                    ramified_factors=(),
                                )
                            else:
                                # Enumerate bad prime lists with values ≤ max_bp
                                for bpl in cartesian_product(range(max_bp + 1), repeat=num_bad):
                                    # Enumerate ramified factors
                                    for rf_combo in cartesian_product(
                                        *[list(enumerate_euler_factors(degree, coeff_range))
                                          for _ in range(num_bad)]
                                    ):
                                        yield FiniteDescriptionLData(
                                            degree=degree,
                                            conductor=conductor,
                                            root_number=rn,
                                            unramified_template=template,
                                            bad_primes=tuple(bpl),
                                            ramified_factors=tuple(rf_combo),
                                        )


def count_ldata_by_description_length(
    max_B: int,
    coeff_range: range = range(-1, 2),
    root_numbers: tuple[int, ...] = (-1, 1),
) -> dict[int, int]:
    """Count L-data objects grouped by description length.

    Args:
        max_B: Maximum description length to count up to.
        coeff_range: Coefficient range for Euler factors.
        root_numbers: Allowed root numbers.

    Returns:
        Dictionary mapping description length to count.
    """
    counts: dict[int, int] = {}
    for x in enumerate_ldata(max_B, coeff_range, root_numbers):
        dl = x.description_length
        counts[dl] = counts.get(dl, 0) + 1
    return counts


def count_ldata_by_conductor(
    max_B: int,
    coeff_range: range = range(-1, 2),
    root_numbers: tuple[int, ...] = (-1, 1),
) -> dict[int, int]:
    """Count L-data objects grouped by conductor.

    Args:
        max_B: Maximum description length.
        coeff_range: Coefficient range.
        root_numbers: Allowed root numbers.

    Returns:
        Dictionary mapping conductor to count.
    """
    counts: dict[int, int] = {}
    for x in enumerate_ldata(max_B, coeff_range, root_numbers):
        c = x.conductor
        counts[c] = counts.get(c, 0) + 1
    return counts


def description_length_growth_rate(
    max_B: int,
    coeff_range: range = range(-1, 2),
    root_numbers: tuple[int, ...] = (-1, 1),
) -> list[tuple[int, int, float]]:
    """Compute cumulative counts and growth rates by description length.

    Returns:
        List of (B, cumulative_count, log_ratio) tuples.
    """
    counts = count_ldata_by_description_length(max_B, coeff_range, root_numbers)
    cumulative = 0
    results = []
    prev_cum = 0
    for b in range(1, max_B + 1):
        cumulative += counts.get(b, 0)
        ratio = math.log(cumulative / prev_cum) if prev_cum > 0 and cumulative > 0 else 0.0
        results.append((b, cumulative, ratio))
        prev_cum = max(cumulative, 1)
    return results


if __name__ == "__main__":
    print("=== Discrete L-Data Enumeration Algorithm ===\n")

    # Enumerate first objects
    print("First 20 L-data objects (coeff in {-1,0,1}, root numbers {-1,1}):")
    for i, x in enumerate(enumerate_ldata(4, range(-1, 2), (-1, 1))):
        if i >= 20:
            break
        print(f"  [{i}] {x}")

    print("\n--- Counts by description length ---")
    counts = count_ldata_by_description_length(5, range(-1, 2), (-1, 1))
    for b in sorted(counts):
        print(f"  descLen={b}: {counts[b]} objects")

    print("\n--- Cumulative growth ---")
    growth = description_length_growth_rate(5, range(-1, 2), (-1, 1))
    for b, cum, ratio in growth:
        print(f"  B={b}: cumulative={cum}, log_growth={ratio:.3f}")
