from __future__ import annotations
from typing import Callable, Tuple, TypeVar

T = TypeVar("T")


def terminates_of_measure(
    step: Callable[[T], "Ordinal"],
    mu: Callable[[T], "Ordinal"],
    x0: T,
    max_steps: int = 10_000_000,
) -> Tuple[int, T]:
    """Executable form of Theorem 2 (Termination by Ordinal Measure).

    Iterate `step` from `x0`, recomputing the ordinal measure `mu` each round,
    until the measure reaches 0. The strict-decrease hypothesis
    `mu(x) != 0 => mu(step x) < mu(x)` guarantees the loop halts; each iteration
    asserts the measure strictly decreased.
    """
    x = x0
    n = 0
    while not mu(x).is_zero():
        nxt = step(x)
        assert mu(nxt) < mu(x), "monovariant failed to strictly decrease"
        x, n = nxt, n + 1
        if n > max_steps:
            raise RuntimeError("exceeded max_steps (should be impossible)")
    return n, x
