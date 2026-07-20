#!/usr/bin/env python3
"""Numerical and symbolic demonstrations of survival clocks below omega squared."""
from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable

@dataclass(frozen=True, order=True)
class OrdinalBelowOmegaSquared:
    """The exact Cantor normal form omega * blocks + tail."""
    blocks: int
    tail: int

    def __post_init__(self) -> None:
        if self.blocks < 0 or self.tail < 0:
            raise ValueError("Ordinal coefficients must be nonnegative")

    def __str__(self) -> str:
        if self.blocks == 0:
            return str(self.tail)
        head = "ω" if self.blocks == 1 else f"ω·{self.blocks}"
        return head if self.tail == 0 else f"{head}+{self.tail}"

def finite_strategy(n: int) -> int:
    if n < 0:
        raise ValueError("A delay must be nonnegative")
    return n

def defeat_finite_cap(cap: int) -> int:
    """Return the canonical delay strictly exceeding a proposed finite cap."""
    if cap < 0:
        raise ValueError("A cap must be nonnegative")
    return cap + 1

def block_clock(k: int, n: int) -> OrdinalBelowOmegaSquared:
    return OrdinalBelowOmegaSquared(k, n)

def clock_window(blocks: int, tails: int) -> Iterable[OrdinalBelowOmegaSquared]:
    for k in range(blocks):
        for n in range(tails):
            yield block_clock(k, n)

def dyadic_birthday(n: int) -> tuple[Fraction, int, OrdinalBelowOmegaSquared]:
    """Return 2^-n, birthday n+1, and omega-weighted birthday."""
    if n < 0:
        raise ValueError("The exponent must be nonnegative")
    birthday = n + 1
    return Fraction(1, 2**n), birthday, OrdinalBelowOmegaSquared(birthday, 0)

def main() -> None:
    print("FINITE POSTPONEMENT")
    for cap in (7, 19, 100):
        choice = defeat_finite_cap(cap)
        print(f"cap={cap:3d}; choose {choice:3d}; survives {finite_strategy(choice)} rounds")

    print("\nTWO-LEVEL CLOCK (symbolic, exact)")
    for value in clock_window(3, 6):
        print(f"({value.blocks}, {value.tail}) -> {value}")
    print("At fixed k, finite tails approach but never attain ω·(k+1).")
    print("Unbounded finite k values make the family cofinal in ω².")

    a, b = block_clock(1, 1000), block_clock(2, 0)
    print(f"\nLexicographic comparison: {a} < {b} is {a < b}")

    print("\nDYADIC BIRTHDAYS")
    for n in range(8):
        value, birthday, weighted = dyadic_birthday(n)
        print(f"2^-{n} = {str(value):>5}; birthday={birthday}; weighted={weighted}")

if __name__ == "__main__":
    main()
