from __future__ import annotations
from typing import Callable

def irrationality_form_test(
    a: Callable[[int], int],
    b: Callable[[int], int],
    x: float,
    n_max: int = 50,
    tol: float = 1e-9,
) -> dict[str, object]:
    """Empirically test the integer-linear-form irrationality criterion:
    x is irrational iff there exist integer sequences a_n, b_n with
    a_n + b_n*x != 0 for all n and a_n + b_n*x -> 0.

    Returns whether all sampled forms are nonzero and the trend of |a_n + b_n*x|."""
    values: list[float] = []
    all_nonzero: bool = True
    for n in range(1, n_max + 1):
        v = a(n) + b(n) * x
        if abs(v) < tol:
            all_nonzero = False
        values.append(abs(v))
    decaying: bool = values[-1] < values[0]
    return {"all_nonzero": all_nonzero, "first": values[0],
            "last": values[-1], "appears_to_decay": decaying}
