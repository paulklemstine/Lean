#!/usr/bin/env python3
"""Finite numerical illustrations of transfinite game-value constructions.

The calculations truncate every countable Black choice at a finite cutoff.
They illustrate nested delay patterns but do not prove transfinite bounds.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True, order=True)
class OmegaPower:
    """Symbolic signature for omega^exponent, with None denoting omega^omega."""

    exponent: int | None

    def __post_init__(self) -> None:
        if self.exponent is not None and self.exponent < 0:
            raise ValueError("exponent must be nonnegative")

    def __str__(self) -> str:
        if self.exponent is None:
            return "ω^ω"
        if self.exponent == 0:
            return "1"
        if self.exponent == 1:
            return "ω"
        return f"ω^{self.exponent}"


def truncated_delay(depth: int, cutoff: int) -> int:
    """Return T_depth(cutoff), where T_0=1 and T_(n+1)=cutoff*T_n+1."""
    if depth < 0 or cutoff < 0:
        raise ValueError("depth and cutoff must be nonnegative")
    value = 1
    for _ in range(depth):
        value = cutoff * value + 1
    return value


def delay_profile(max_depth: int, cutoff: int) -> list[int]:
    """List truncated maximum delays from depth zero through max_depth."""
    return [truncated_delay(depth, cutoff) for depth in range(max_depth + 1)]


def finite_countdown_values(cutoff: int) -> list[int]:
    """Values of finite countdown children available below a truncated choice."""
    if cutoff < 0:
        raise ValueError("cutoff must be nonnegative")
    return list(range(cutoff + 1))


def ordinal_hierarchy(levels: int) -> list[OmegaPower]:
    """Return symbolic values 1, omega, ..., omega^levels, followed by omega^omega."""
    if levels < 0:
        raise ValueError("levels must be nonnegative")
    return [OmegaPower(n) for n in range(levels + 1)] + [OmegaPower(None)]


def defeats_finite_budget(budget: int) -> int:
    """Choose a finite countdown strictly longer than a proposed finite budget."""
    if budget < 0:
        raise ValueError("budget must be nonnegative")
    return budget + 1


def render_table(rows: Iterable[tuple[int, int, int]]) -> str:
    """Render (cutoff, depth, delay) rows as an aligned plain-text table."""
    lines = ["cutoff | depth | truncated maximum", "-------+-------+------------------"]
    lines.extend(f"{k:6d} | {d:5d} | {v:17d}" for k, d, v in rows)
    return "\n".join(lines)


def main() -> None:
    print("TRANSFINITE GAME VALUES: FINITE SHADOWS\n")
    print("Countdown branches at cutoff 10:", finite_countdown_values(10))
    print("A proposed finite budget 10 is defeated by branch:", defeats_finite_budget(10))

    rows = [
        (cutoff, depth, truncated_delay(depth, cutoff))
        for cutoff in (2, 5, 10)
        for depth in range(1, 5)
    ]
    print("\nNested finite truncations")
    print(render_table(rows))

    print("\nSymbolic exact hierarchy")
    print(" < ".join(map(str, ordinal_hierarchy(6))))

    print("\nInterpretation:")
    print("  Increasing the cutoff exposes unbounded finite delay.")
    print("  Increasing depth exposes nested layers corresponding to ω^n.")
    print("  The final ω^ω marker dominates every displayed finite exponent.")
    print("  These finite calculations illustrate, but cannot certify, the suprema.")


if __name__ == "__main__":
    main()
