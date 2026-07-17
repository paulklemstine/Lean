#!/usr/bin/env python3
"""Exact numerical experiments for determinant-one trace recurrences."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Tuple

Matrix = Tuple[Tuple[int, int], Tuple[int, int]]
Pair = Tuple[int, int]


def trace_sequence(t: int, count: int) -> List[int]:
    """Return u_0 through u_count for u_0=2, u_1=t."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    values = [2]
    if count == 0:
        return values
    values.append(t)
    for _ in range(count - 1):
        values.append(t * values[-1] - values[-2])
    return values


def trace_at(t: int, n: int) -> int:
    """Evaluate u_n using the sequential pair recurrence."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    x, y = 2, t
    for _ in range(n):
        x, y = y, t * y - x
    return x


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two 2-by-2 integer matrices."""
    return (
        (a[0][0] * b[0][0] + a[0][1] * b[1][0],
         a[0][0] * b[0][1] + a[0][1] * b[1][1]),
        (a[1][0] * b[0][0] + a[1][1] * b[1][0],
         a[1][0] * b[0][1] + a[1][1] * b[1][1]),
    )


def mat_pow(base: Matrix, exponent: int) -> Matrix:
    """Raise a 2-by-2 integer matrix to a nonnegative power."""
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    result: Matrix = ((1, 0), (0, 1))
    while exponent:
        if exponent & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        exponent //= 2
    return result


def witness_matrix(t: int) -> Matrix:
    """Return a determinant-one integer matrix of trace t."""
    return ((t - 1, 1), (t - 2, 1))


def trace_by_matrix(t: int, n: int) -> int:
    """Evaluate u_n as the trace of the nth witness-matrix power."""
    power = mat_pow(witness_matrix(t), n)
    return power[0][0] + power[1][1]


def pell_residual(t: int, x: int, y: int) -> int:
    """Return the residual in x^2-txy+y^2=4-t^2."""
    return x * x - t * x * y + y * y - (4 - t * t)


def modular_period(t: int, modulus: int) -> Tuple[int, List[Pair]]:
    """Return the pure period and states of the pair recurrence modulo q."""
    if modulus <= 1:
        raise ValueError("modulus must exceed one")
    start = (2 % modulus, t % modulus)
    state = start
    states: List[Pair] = []
    seen: Dict[Pair, int] = {}
    while state not in seen:
        seen[state] = len(states)
        states.append(state)
        x, y = state
        state = (y, (t * y - x) % modulus)
    if state != start:
        raise AssertionError("invertibility requires a purely periodic orbit")
    return len(states), states


@dataclass(frozen=True)
class IdentityCheck:
    t: int
    n: int
    value: int
    doubled: int
    tripled: int


def check_identities(t: int, n: int) -> IdentityCheck:
    """Compute and assert the doubling, tripling, conic, and matrix laws."""
    u_n = trace_at(t, n)
    u_2n = trace_at(t, 2 * n)
    u_3n = trace_at(t, 3 * n)
    assert u_2n == u_n * u_n - 2
    assert u_3n == u_n**3 - 3 * u_n
    assert u_2n**2 - 4 == (u_n**2 - 4) * u_n**2
    assert trace_by_matrix(t, n) == u_n
    assert pell_residual(t, u_n, trace_at(t, n + 1)) == 0
    return IdentityCheck(t, n, u_n, u_2n, u_3n)


def main() -> None:
    """Print representative exact experiments."""
    print("Trace-three sequence u_0,...,u_12:")
    print(trace_sequence(3, 12))
    print()

    for t, n in [(3, 5), (3, 4), (4, 6), (-2, 7)]:
        result = check_identities(t, n)
        print(
            f"t={t:2d}, n={n:2d}: u_n={result.value}, "
            f"u_{{2n}}={result.doubled}, u_{{3n}}={result.tripled}"
        )

    print("\nPower-of-two jumps from u_1(3)=3:")
    x, index = 3, 1
    for _ in range(5):
        print(f"u_{index}(3) = {x}")
        x, index = x * x - 2, 2 * index

    print("\nPure modular periods for t=3:")
    for q in [5, 7, 11, 16]:
        period, states = modular_period(3, q)
        preview = states[: min(6, len(states))]
        print(f"mod {q:2d}: period {period:2d}, first states {preview}")


if __name__ == "__main__":
    main()
