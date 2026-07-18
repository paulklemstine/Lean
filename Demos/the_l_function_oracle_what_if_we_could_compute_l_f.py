#!/usr/bin/env python3
"""Numerical demonstrations for exact-evaluation oracle principles.

The examples illustrate three rigorous ideas: finite samples permit arbitrary
fresh values through a vanishing polynomial, a known bound makes the first
nonzero jet coefficient discoverable, and a factor decoder is useful only when
its output passes a proper-divisor certificate.
"""

from __future__ import annotations

import cmath
from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

ComplexFunction = Callable[[complex], complex]


def vanishing_polynomial(sample: Sequence[complex], w: complex) -> complex:
    """Return the product of (w-a) over all sampled points a."""
    value = 1.0 + 0.0j
    for a in sample:
        value *= w - a
    return value


def interpolation_perturbation(
    f: ComplexFunction,
    sample: Sequence[complex],
    fresh: complex,
    target: complex,
) -> ComplexFunction:
    """Construct g agreeing with f on sample and satisfying g(fresh)=target."""
    denominator = vanishing_polynomial(sample, fresh)
    if abs(denominator) < 1e-14:
        raise ValueError("The fresh point must not belong to the sample.")
    scale = (target - f(fresh)) / denominator

    def g(w: complex) -> complex:
        return f(w) + scale * vanishing_polynomial(sample, w)

    return g


def first_nonzero_jet(
    jet: Callable[[int], complex], bound: int, tolerance: float = 1e-12
) -> int:
    """Return the first numerically nonzero jet coefficient through bound."""
    if bound < 0:
        raise ValueError("The bound must be nonnegative.")
    for k in range(bound + 1):
        if abs(jet(k)) > tolerance:
            return k
    raise ValueError("No nonzero coefficient was found within the supplied bound.")


def proper_factor_certificate(n: int, candidate: int) -> bool:
    """Check that candidate is a proper nontrivial divisor of n."""
    return n >= 2 and 1 < candidate < n and n % candidate == 0


def trial_decoder(n: int) -> int:
    """A transparent stand-in decoder returning a least trial divisor."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


@dataclass(frozen=True)
class DemoReport:
    title: str
    details: tuple[str, ...]


def demonstrate_interpolation() -> DemoReport:
    """Show that four exact observations cannot exclude a fresh zero."""
    f: ComplexFunction = lambda z: cmath.exp(z) + z * z
    sample = [0j, 1 + 0j, 1j, 1 + 1j]
    fresh = 0.4 + 0.7j
    g = interpolation_perturbation(f, sample, fresh, 0j)
    max_sample_error = max(abs(g(w) - f(w)) for w in sample)
    return DemoReport(
        "Finite observations permit a hidden fresh zero",
        (
            f"sample size: {len(sample)}",
            f"maximum agreement error: {max_sample_error:.3e}",
            f"absolute value at fresh point: {abs(g(fresh)):.3e}",
        ),
    )


def demonstrate_bounded_jet() -> DemoReport:
    """Recover the order five of t^5 exp(t) from its coefficient sequence."""
    # The coefficient of t^k in t^5 exp(t) is zero below five and 1/(k-5)! after.
    def jet(k: int) -> complex:
        if k < 5:
            return 0j
        factorial = 1
        for j in range(2, k - 5 + 1):
            factorial *= j
        return complex(1.0 / factorial)

    found = first_nonzero_jet(jet, bound=12)
    return DemoReport(
        "Bounded jet search recovers a finite vanishing order",
        (
            "function model: t^5 exp(t)",
            "certified search bound: 12",
            f"first nonzero coefficient index: {found}",
        ),
    )


def demonstrate_factor_certificates() -> DemoReport:
    """Decode candidates and independently certify proper divisors."""
    integers = [91, 143, 221, 437, 97]
    lines: list[str] = []
    for n in integers:
        candidate = trial_decoder(n)
        valid = proper_factor_certificate(n, candidate)
        lines.append(f"n={n}, candidate={candidate}, certified={valid}")
    return DemoReport(
        "Decoded factors must pass arithmetic certificates",
        tuple(lines),
    )


def main() -> None:
    """Run all numerical demonstrations and print concise reports."""
    reports: Iterable[DemoReport] = (
        demonstrate_interpolation(),
        demonstrate_bounded_jet(),
        demonstrate_factor_certificates(),
    )
    for report in reports:
        print(f"\n=== {report.title} ===")
        for line in report.details:
            print(line)


if __name__ == "__main__":
    main()
