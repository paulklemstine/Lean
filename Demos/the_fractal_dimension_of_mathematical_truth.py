#!/usr/bin/env python3
"""Numerical demonstrations for prefix geometry and half-dimensional truth languages."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Iterable, Iterator, Sequence

Bit = int


def validate_bits(bits: Sequence[Bit]) -> None:
    """Raise ValueError unless every entry is 0 or 1."""
    if any(bit not in (0, 1) for bit in bits):
        raise ValueError("bits must contain only 0 and 1")


def paired_prefixes(n: int) -> Iterator[tuple[Bit, ...]]:
    """Generate all length-2n prefixes whose even-indexed bits are 1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    for free_bits in product((0, 1), repeat=n):
        yield tuple(value for bit in free_bits for value in (1, bit))


def paired_count(n: int) -> int:
    """Return the exact paired-prefix count 2^n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return 1 << n


def ambient_count(length: int) -> int:
    """Return the number 2^length of unrestricted binary prefixes."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    return 1 << length


def symbolic_dimension_even_scale(n: int) -> Fraction:
    """Return log_2(A_n)/(2n), represented exactly for n > 0."""
    if n <= 0:
        raise ValueError("n must be positive")
    return Fraction(n, 2 * n)


def prefix_distance(x: Sequence[Bit], y: Sequence[Bit]) -> Fraction:
    """Compute weighted disagreement for finite streams, padding by zeros."""
    validate_bits(x)
    validate_bits(y)
    length = max(len(x), len(y))
    total = Fraction(0)
    for index in range(length):
        xb = x[index] if index < len(x) else 0
        yb = y[index] if index < len(y) else 0
        if xb != yb:
            total += Fraction(1, 2 ** (index + 1))
    return total


def binary_truncation(bits: Sequence[Bit], n: int | None = None) -> Fraction:
    """Return the exact dyadic sum of the first n supplied bits."""
    validate_bits(bits)
    count = len(bits) if n is None else n
    if count < 0 or count > len(bits):
        raise ValueError("n must lie between 0 and the number of supplied bits")
    return sum(
        (Fraction(bits[index], 2 ** (index + 1)) for index in range(count)),
        start=Fraction(0),
    )


@dataclass(frozen=True)
class CertifiedInterval:
    """A rigorous interval determined by a finite binary prefix."""

    lower: Fraction
    upper: Fraction

    @property
    def width(self) -> Fraction:
        return self.upper - self.lower


def certified_interval(prefix: Sequence[Bit]) -> CertifiedInterval:
    """Enclose every infinite continuation of prefix in an interval of width 2^-N."""
    lower = binary_truncation(prefix)
    error = Fraction(1, 2 ** len(prefix))
    return CertifiedInterval(lower, lower + error)


def common_prefix_length(x: Sequence[Bit], y: Sequence[Bit]) -> int:
    """Return the number of equal leading bits in two finite streams."""
    validate_bits(x)
    validate_bits(y)
    for index, (xb, yb) in enumerate(zip(x, y)):
        if xb != yb:
            return index
    return min(len(x), len(y))


def print_count_table(max_n: int = 8) -> None:
    """Print exact paired and ambient counts and verify the square identity."""
    print("Exact paired-prefix growth")
    print(" n | paired A_n | ambient B_2n | A_n^2 = B_2n")
    print("---+------------+--------------+----------------")
    for n in range(max_n + 1):
        paired = paired_count(n)
        ambient = ambient_count(2 * n)
        print(f"{n:2d} | {paired:10d} | {ambient:12d} | {paired * paired == ambient}")


def demonstrate_completion(n: int = 3) -> None:
    """Enumerate paired prefixes and show that all fixed coordinates equal 1."""
    prefixes = list(paired_prefixes(n))
    valid = all(all(prefix[2 * k] == 1 for k in range(n)) for prefix in prefixes)
    print(f"\nThere are {len(prefixes)} paired prefixes at scale n={n}:")
    print(" ".join("".join(map(str, prefix)) for prefix in prefixes))
    print(f"Every even-indexed coordinate is fixed to 1: {valid}")


def demonstrate_real_bounds() -> None:
    """Show certified convergence and common-prefix stability."""
    x = (1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1)
    y = (1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0)
    print("\nCertified binary-real intervals")
    for n in (2, 4, 6, 8):
        interval = certified_interval(x[:n])
        print(
            f"N={n:2d}: [{float(interval.lower):.6f}, "
            f"{float(interval.upper):.6f}], width={float(interval.width):.6f}"
        )
    shared = common_prefix_length(x, y)
    rx = binary_truncation(x)
    ry = binary_truncation(y)
    bound = Fraction(1, 2 ** shared)
    print(f"\nTwo samples share {shared} initial bits.")
    print(f"Observed finite-value gap: {float(abs(rx - ry)):.6f}")
    print(f"Certified infinite-continuation bound: 2^-{shared} = {float(bound):.6f}")


def demonstrate_triangle_inequality() -> None:
    """Numerically check a representative metric triangle."""
    x = (1, 0, 1, 0, 1, 0)
    y = (1, 1, 1, 0, 0, 0)
    z = (0, 1, 1, 1, 0, 1)
    dxz = prefix_distance(x, z)
    dxy = prefix_distance(x, y)
    dyz = prefix_distance(y, z)
    print("\nRepresentative prefix-metric triangle")
    print(f"d(x,z) = {dxz} = {float(dxz):.6f}")
    print(f"d(x,y) + d(y,z) = {dxy + dyz} = {float(dxy + dyz):.6f}")
    print(f"Triangle inequality holds: {dxz <= dxy + dyz}")


def main() -> None:
    print_count_table()
    demonstrate_completion()
    demonstrate_real_bounds()
    demonstrate_triangle_inequality()
    print(f"\nExact symbolic dimension at every positive even scale: {symbolic_dimension_even_scale(7)}")


if __name__ == "__main__":
    main()
