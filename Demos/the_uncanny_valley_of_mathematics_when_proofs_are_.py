#!/usr/bin/env python3
"""Numerical demonstrations for discrete confidence-valley theorems.

The script uses only Python's standard library. It certifies strict valleys,
computes margins and total variation, aggregates respondent profiles, and checks
the sharp half-margin robustness condition.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class ValleyCertificate:
    """Summary of the strict-valley and margin tests for one profile."""

    location: int
    is_strict_valley: bool
    is_unique_minimum: bool
    margin: float
    variation: float
    drop_plus_recovery: float


def strict_valley_at(profile: Sequence[float], valley: int) -> bool:
    """Return whether a finite profile strictly descends then strictly rises."""
    if not profile:
        raise ValueError("profile must be nonempty")
    if not 0 <= valley < len(profile):
        raise IndexError("valley index is outside the profile")
    descends = all(profile[k + 1] < profile[k] for k in range(valley))
    rises = all(profile[k] < profile[k + 1] for k in range(valley, len(profile) - 1))
    return descends and rises


def unique_minimum_at(profile: Sequence[float], valley: int) -> bool:
    """Return whether the candidate is strictly below every competing level."""
    if not profile:
        raise ValueError("profile must be nonempty")
    if not 0 <= valley < len(profile):
        raise IndexError("valley index is outside the profile")
    return all(profile[valley] < value for i, value in enumerate(profile) if i != valley)


def minimum_margin(profile: Sequence[float], valley: int) -> float:
    """Compute min_{i != valley}(profile[i] - profile[valley])."""
    if len(profile) < 2:
        raise ValueError("a margin requires at least two tested levels")
    if not 0 <= valley < len(profile):
        raise IndexError("valley index is outside the profile")
    return min(value - profile[valley] for i, value in enumerate(profile) if i != valley)


def path_variation(profile: Sequence[float]) -> float:
    """Compute the sum of absolute adjacent differences."""
    return sum(abs(right - left) for left, right in zip(profile, profile[1:]))


def valley_drop_plus_recovery(profile: Sequence[float], valley: int) -> float:
    """Compute the variation predicted for monotone descent and recovery."""
    if not profile:
        raise ValueError("profile must be nonempty")
    if not 0 <= valley < len(profile):
        raise IndexError("valley index is outside the profile")
    return (profile[0] - profile[valley]) + (profile[-1] - profile[valley])


def aggregate_profiles(profiles: Sequence[Sequence[float]]) -> list[float]:
    """Sum equally long respondent profiles level by level."""
    if not profiles:
        raise ValueError("at least one respondent is required")
    width = len(profiles[0])
    if width == 0 or any(len(profile) != width for profile in profiles):
        raise ValueError("all profiles must have the same positive length")
    return [sum(profile[i] for profile in profiles) for i in range(width)]


def max_uniform_error(reference: Sequence[float], observed: Sequence[float]) -> float:
    """Compute the maximum coordinatewise absolute error."""
    if len(reference) != len(observed) or not reference:
        raise ValueError("profiles must have the same positive length")
    return max(abs(x - y) for x, y in zip(reference, observed))


def half_margin_certifies(margin: float, epsilon: float) -> bool:
    """Test the sharp sufficient condition 2 epsilon < margin."""
    if epsilon < 0:
        raise ValueError("epsilon must be nonnegative")
    return 2.0 * epsilon < margin


def certify(profile: Sequence[float], valley: int) -> ValleyCertificate:
    """Build a complete numerical certificate for one candidate valley."""
    return ValleyCertificate(
        location=valley,
        is_strict_valley=strict_valley_at(profile, valley),
        is_unique_minimum=unique_minimum_at(profile, valley),
        margin=minimum_margin(profile, valley),
        variation=path_variation(profile),
        drop_plus_recovery=valley_drop_plus_recovery(profile, valley),
    )


def format_profile(profile: Iterable[float]) -> str:
    """Format a profile compactly for terminal output."""
    return "(" + ", ".join(f"{x:g}" for x in profile) + ")"


def main() -> None:
    """Run aggregation, robustness, variation, and sharpness demonstrations."""
    first = [8.0, 5.0, 1.0, 4.0, 7.0]
    second = [9.0, 6.0, 2.0, 3.0, 8.0]
    valley = 2
    aggregate = aggregate_profiles([first, second])

    print("COMMON-VALLEY AGGREGATION")
    for name, profile in (("Respondent A", first), ("Respondent B", second), ("Aggregate", aggregate)):
        certificate = certify(profile, valley)
        print(f"{name:12}: {format_profile(profile)}")
        print(f"  strict valley={certificate.is_strict_valley}, "
              f"unique minimum={certificate.is_unique_minimum}, "
              f"margin={certificate.margin:g}")
    margin_sum = minimum_margin(first, valley) + minimum_margin(second, valley)
    print(f"Individual margins add to {margin_sum:g}; aggregate margin is "
          f"{minimum_margin(aggregate, valley):g}.\n")

    print("EXACT VARIATION IDENTITY")
    certificate = certify(first, valley)
    print(f"Profile: {format_profile(first)}")
    print(f"Adjacent total variation: {certificate.variation:g}")
    print(f"Drop plus recovery:       {certificate.drop_plus_recovery:g}")
    print(f"Identity holds: {abs(certificate.variation - certificate.drop_plus_recovery) < 1e-12}\n")

    print("HALF-MARGIN ROBUSTNESS")
    observed = [7.6, 4.8, 1.4, 3.7, 6.8]
    margin = minimum_margin(first, valley)
    epsilon = max_uniform_error(first, observed)
    print(f"Reference: {format_profile(first)}")
    print(f"Observed:  {format_profile(observed)}")
    print(f"margin={margin:g}, epsilon={epsilon:g}, 2*epsilon={2 * epsilon:g}")
    print(f"Certified unchanged minimum: {half_margin_certifies(margin, epsilon)}")
    print(f"Observed minimum remains at index {valley}: {unique_minimum_at(observed, valley)}\n")

    print("SHARPNESS AT EQUALITY")
    two_level = [0.0, 3.0]
    equality_perturbation = [1.5, 1.5]
    equality_error = max_uniform_error(two_level, equality_perturbation)
    print(f"Reference: {format_profile(two_level)}, margin=3")
    print(f"Perturbed: {format_profile(equality_perturbation)}, epsilon={equality_error:g}")
    print("Here 2*epsilon equals the margin, and the two observed values tie.")


if __name__ == "__main__":
    main()
