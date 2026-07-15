#!/usr/bin/env python3
"""Numerical demonstrations of coordinate-opening privacy and sparse-check soundness."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import ceil, log
from typing import Callable, Iterable, Sequence

Bit = int
Witness = tuple[Bit, ...]


@dataclass(frozen=True)
class SoundnessResult:
    checks: int
    repetitions: int
    false_acceptance: Fraction
    binary_benchmark: Fraction


def false_acceptance_probability(checks: int, repetitions: int) -> Fraction:
    """Return ((checks - 1) / checks)^repetitions exactly."""
    if checks <= 0:
        raise ValueError("checks must be positive")
    if repetitions < 0:
        raise ValueError("repetitions must be nonnegative")
    return Fraction(checks - 1, checks) ** repetitions


def soundness_comparison(checks: int, repetitions: int) -> SoundnessResult:
    """Compare sparse-error false acceptance with the 2^-k benchmark."""
    return SoundnessResult(
        checks=checks,
        repetitions=repetitions,
        false_acceptance=false_acceptance_probability(checks, repetitions),
        binary_benchmark=Fraction(1, 2) ** repetitions,
    )


def minimum_repetitions(checks: int, target: Fraction) -> int:
    """Find the least k for which sparse-error false acceptance is at most target."""
    if checks <= 1:
        return 1 if target < 1 else 0
    if not Fraction(0) < target < Fraction(1):
        raise ValueError("target must lie strictly between zero and one")
    estimate = max(0, ceil(log(float(target)) / log((checks - 1) / checks)))
    while estimate > 0 and false_acceptance_probability(checks, estimate - 1) <= target:
        estimate -= 1
    while false_acceptance_probability(checks, estimate) > target:
        estimate += 1
    return estimate


def coordinate_is_private(valid_witnesses: Sequence[Witness], index: int) -> bool:
    """Test the exact fixed-coordinate privacy criterion on a finite witness set."""
    if not valid_witnesses:
        return True
    if index < 0 or any(index >= len(witness) for witness in valid_witnesses):
        raise IndexError("index must be present in every witness")
    return len({witness[index] for witness in valid_witnesses}) <= 1


def all_openings_are_private(valid_witnesses: Sequence[Witness]) -> bool:
    """Test privacy of every coordinate; this is equivalent to witness uniqueness."""
    if not valid_witnesses:
        return True
    length = len(valid_witnesses[0])
    if any(len(witness) != length for witness in valid_witnesses):
        raise ValueError("all witnesses must have equal length")
    return all(coordinate_is_private(valid_witnesses, i) for i in range(length))


def mask(message: Bit, randomness: Bit) -> Bit:
    """Apply a Boolean one-time pad."""
    if message not in (0, 1) or randomness not in (0, 1):
        raise ValueError("message and randomness must be bits")
    return message ^ randomness


def open_mask(ciphertext: Bit, randomness: Bit) -> Bit:
    """Recover a Boolean message from its one-time-pad ciphertext."""
    return mask(ciphertext, randomness)


def mask_fiber(message: Bit, ciphertext: Bit) -> tuple[Bit, ...]:
    """List masks that map a fixed message to a fixed ciphertext."""
    return tuple(r for r in (0, 1) if mask(message, r) == ciphertext)


def audit_boolean_masking() -> bool:
    """Check unique fibers, message-independent counts, and correct opening."""
    unique_fibers = all(
        len(mask_fiber(message, ciphertext)) == 1
        for message in (0, 1)
        for ciphertext in (0, 1)
    )
    equal_counts = all(
        len(mask_fiber(0, ciphertext)) == len(mask_fiber(1, ciphertext))
        for ciphertext in (0, 1)
    )
    correct_opening = all(
        open_mask(mask(message, randomness), randomness) == message
        for message in (0, 1)
        for randomness in (0, 1)
    )
    return unique_fibers and equal_counts and correct_opening


def main() -> None:
    print("SPARSE-ERROR SOUNDNESS")
    for checks, repetitions in ((4, 10), (22, 10), (102, 50)):
        result = soundness_comparison(checks, repetitions)
        print(
            f"n={checks:3d}, k={repetitions:2d}: "
            f"false acceptance={float(result.false_acceptance):.8f}, "
            f"2^-k={float(result.binary_benchmark):.8f}"
        )

    target = Fraction(1, 1000)
    print("\nREPETITIONS NEEDED FOR ERROR AT MOST 0.001")
    for checks in (4, 10, 100):
        print(f"n={checks:3d}: k={minimum_repetitions(checks, target)}")

    print("\nRAW-OPENING PRIVACY")
    one_bit_witnesses: list[Witness] = [(0,), (1,)]
    unique_witness: list[Witness] = [(1, 0, 1)]
    print("both one-bit witnesses valid, coordinate 0 private:",
          coordinate_is_private(one_bit_witnesses, 0))
    print("one valid witness, all openings private:",
          all_openings_are_private(unique_witness))

    print("\nBOOLEAN MASKING")
    for message in (0, 1):
        for ciphertext in (0, 1):
            print(f"message={message}, ciphertext={ciphertext}, masks={mask_fiber(message, ciphertext)}")
    print("complete masking audit passed:", audit_boolean_masking())


if __name__ == "__main__":
    main()
