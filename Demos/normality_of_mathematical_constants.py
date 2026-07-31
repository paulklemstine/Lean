#!/usr/bin/env python3
"""Numerical illustrations of the orbit-to-digit-block correspondence.

The program uses exact integer and rational arithmetic.  Finite experiments do not
prove normality; they demonstrate the exact coding lemma and measure finite-sample
block discrepancies.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import floor
from random import Random
from typing import Iterable, Sequence


@dataclass(frozen=True)
class HistogramReport:
    """Summary of a block-frequency experiment."""

    base: int
    block_length: int
    samples: int
    counts: tuple[int, ...]
    maximum_discrepancy: float
    chi_square: float


def validate_parameters(base: int, block_length: int, samples: int) -> None:
    """Validate shared numerical parameters."""
    if base < 2:
        raise ValueError("base must be at least 2")
    if block_length < 1:
        raise ValueError("block_length must be positive")
    if samples < 1:
        raise ValueError("samples must be positive")


def exact_orbit_block_histogram(
    numerator: int,
    denominator: int,
    base: int,
    block_length: int,
    samples: int,
) -> HistogramReport:
    """Count equal-cell visits for x = numerator/denominator exactly.

    At step n, the remainder r represents fract(base**n * x) = r/denominator.
    The code floor(base**block_length * r / denominator) is simultaneously the
    equal-cell index and the extracted digit-block code.
    """
    validate_parameters(base, block_length, samples)
    if denominator <= 0:
        raise ValueError("denominator must be positive")
    cells = base**block_length
    counts = [0] * cells
    remainder = numerator % denominator
    for _ in range(samples):
        code = (cells * remainder) // denominator
        counts[code] += 1
        remainder = (base * remainder) % denominator
    return summarize_counts(counts, base, block_length, samples)


def verify_floor_interval_dictionary(
    numerator: int,
    denominator: int,
    base: int,
    block_length: int,
    samples: int,
) -> bool:
    """Check both sides of the floor--interval equivalence exactly."""
    validate_parameters(base, block_length, samples)
    if denominator <= 0:
        raise ValueError("denominator must be positive")
    cells = base**block_length
    remainder = numerator % denominator
    for _ in range(samples):
        floor_code = (cells * remainder) // denominator
        lower_holds = floor_code * denominator <= cells * remainder
        upper_holds = cells * remainder < (floor_code + 1) * denominator
        if not (lower_holds and upper_holds):
            return False
        remainder = (base * remainder) % denominator
    return True


def block_histogram_from_digits(
    digits: Sequence[int], base: int, block_length: int
) -> HistogramReport:
    """Count overlapping length-k blocks in a finite digit sequence."""
    samples = len(digits) - block_length + 1
    validate_parameters(base, block_length, samples)
    if any(digit < 0 or digit >= base for digit in digits):
        raise ValueError("every digit must lie between 0 and base - 1")
    cells = base**block_length
    counts = [0] * cells
    code = 0
    for digit in digits[:block_length]:
        code = base * code + digit
    counts[code] += 1
    leading_weight = base ** (block_length - 1)
    for start in range(1, samples):
        code -= digits[start - 1] * leading_weight
        code = base * code + digits[start + block_length - 1]
        counts[code] += 1
    return summarize_counts(counts, base, block_length, samples)


def summarize_counts(
    counts: Sequence[int], base: int, block_length: int, samples: int
) -> HistogramReport:
    """Compute maximum discrepancy and a descriptive chi-square statistic."""
    expected_frequency = 1.0 / len(counts)
    maximum_discrepancy = max(
        abs(count / samples - expected_frequency) for count in counts
    )
    expected_count = samples / len(counts)
    chi_square = sum(
        (count - expected_count) ** 2 / expected_count for count in counts
    )
    return HistogramReport(
        base=base,
        block_length=block_length,
        samples=samples,
        counts=tuple(counts),
        maximum_discrepancy=maximum_discrepancy,
        chi_square=chi_square,
    )


def seeded_uniform_digits(base: int, length: int, seed: int = 20260731) -> list[int]:
    """Generate a reproducible finite uniform digit sample for comparison."""
    if base < 2 or length < 1:
        raise ValueError("base must be at least 2 and length must be positive")
    generator = Random(seed)
    return [generator.randrange(base) for _ in range(length)]


def format_code(code: int, base: int, width: int) -> str:
    """Render a nonnegative code in base b, retaining leading zeroes."""
    alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if base > len(alphabet):
        return str(code).zfill(width)
    output: list[str] = []
    value = code
    for _ in range(width):
        output.append(alphabet[value % base])
        value //= base
    return "".join(reversed(output))


def print_report(title: str, report: HistogramReport, limit: int = 20) -> None:
    """Print a compact frequency table and discrepancy summary."""
    print(f"\n{title}")
    print("=" * len(title))
    expected = 1.0 / len(report.counts)
    for code, count in enumerate(report.counts[:limit]):
        observed = count / report.samples
        label = format_code(code, report.base, report.block_length)
        print(f"block {label}: count={count:6d}, frequency={observed:.6f}")
    if len(report.counts) > limit:
        print(f"... {len(report.counts) - limit} additional blocks omitted")
    print(f"expected frequency per block: {expected:.6f}")
    print(f"maximum discrepancy:          {report.maximum_discrepancy:.6f}")
    print(f"descriptive chi-square:       {report.chi_square:.3f}")


def main() -> None:
    """Run three demonstrations of the mathematical results."""
    dictionary_ok = verify_floor_interval_dictionary(
        numerator=3141592653589793,
        denominator=10**15,
        base=10,
        block_length=2,
        samples=500,
    )
    print("Exact floor--interval dictionary check:", dictionary_ok)

    periodic = exact_orbit_block_histogram(
        numerator=1,
        denominator=7,
        base=10,
        block_length=1,
        samples=600,
    )
    print_report("Periodic rational orbit: x = 1/7 in base 10", periodic)

    digits = seeded_uniform_digits(base=10, length=100_001)
    synthetic = block_histogram_from_digits(digits, base=10, block_length=2)
    print_report("Reproducible uniform digit sample: decimal pairs", synthetic)

    print(
        "\nInterpretation: the first check is an exact identity. The histograms are "
        "finite illustrations only; neither a small discrepancy nor a long sample "
        "proves normality of an infinite expansion."
    )


if __name__ == "__main__":
    main()
