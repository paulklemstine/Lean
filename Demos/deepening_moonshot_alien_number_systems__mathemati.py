#!/usr/bin/env python3
"""Numerical demonstrations of canonical finite negabinary numeration."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Step:
    """One exact parity-extraction step in radix -2."""

    state: int
    digit: int
    next_state: int


def decode_negabinary(bits_lsf: Sequence[int]) -> int:
    """Evaluate least-significant-first binary digits in radix -2."""
    if any(bit not in (0, 1) for bit in bits_lsf):
        raise ValueError("every digit must be 0 or 1")
    value = 0
    for bit in reversed(bits_lsf):
        value = -2 * value + bit
    return value


def encode_negabinary(value: int) -> list[int]:
    """Return the unique canonical least-significant-first expansion of value."""
    bits: list[int] = []
    state = value
    while state != 0:
        digit = state % 2  # Python gives the Euclidean remainder 0 or 1.
        bits.append(digit)
        state = -(state - digit) // 2
    return bits


def extraction_trace(value: int) -> list[Step]:
    """Return every state, forced digit, and exact next state for value."""
    trace: list[Step] = []
    state = value
    while state != 0:
        digit = state % 2
        next_state = -(state - digit) // 2
        assert digit - 2 * next_state == state
        trace.append(Step(state, digit, next_state))
        state = next_state
    return trace


def is_canonical(bits_lsf: Sequence[int]) -> bool:
    """Test whether a finite bit sequence has no most-significant zero."""
    return all(bit in (0, 1) for bit in bits_lsf) and (
        not bits_lsf or bits_lsf[-1] == 1
    )


def displayed(bits_lsf: Sequence[int]) -> str:
    """Format a least-significant-first list in conventional display order."""
    return "0" if not bits_lsf else "".join(map(str, reversed(bits_lsf)))


def verify_interval(start: int, stop: int) -> None:
    """Check round trips and uniqueness by exhaustive enumeration on an interval."""
    encodings: dict[tuple[int, ...], int] = {}
    for value in range(start, stop + 1):
        bits = encode_negabinary(value)
        assert is_canonical(bits)
        assert decode_negabinary(bits) == value
        key = tuple(bits)
        assert key not in encodings
        encodings[key] = value

    max_length = max((len(bits) for bits in encodings), default=0)
    for length in range(max_length + 1):
        for mask in range(1 << length):
            bits = [(mask >> index) & 1 for index in range(length)]
            if is_canonical(bits):
                decoded = decode_negabinary(bits)
                if start <= decoded <= stop:
                    assert encode_negabinary(decoded) == bits


def place_value_terms(bits_lsf: Iterable[int]) -> list[int]:
    """Return the signed place-value contribution of every supplied digit."""
    return [bit * ((-2) ** index) for index, bit in enumerate(bits_lsf)]


def main() -> None:
    examples = [-19, -9, -2, -1, 0, 1, 2, 5, 19]
    print("Canonical negabinary examples (displayed most-significant first)\n")
    for value in examples:
        bits = encode_negabinary(value)
        terms = place_value_terms(bits)
        print(
            f"{value:>4} -> {displayed(bits):>7}  "
            f"LSF={bits!s:<18} terms={terms} sum={sum(terms)}"
        )

    target = -9
    print(f"\nDigit-extraction trace for {target}")
    print(" state | digit | next | reconstruction")
    for step in extraction_trace(target):
        print(
            f"{step.state:>6} | {step.digit:>5} | {step.next_state:>4} | "
            f"{step.digit} - 2*({step.next_state}) = {step.state}"
        )

    verify_interval(-10_000, 10_000)
    print("\nAll canonical round trips passed for every integer from -10,000 to 10,000.")


if __name__ == "__main__":
    main()
