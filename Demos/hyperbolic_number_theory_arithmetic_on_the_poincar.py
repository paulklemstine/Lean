#!/usr/bin/env python3
"""Numerical demonstrations of modular trace recurrences and Pell invariants."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterator


Pair = tuple[int, int]
Matrix2 = tuple[tuple[int, int], tuple[int, int]]


def pell_form(t: int, x: int, y: int) -> int:
    """Return Q_t(x,y) = x^2 - txy + y^2."""
    return x * x - t * x * y + y * y


def trace_terms(t: int, count: int) -> list[int]:
    """Return u_0,...,u_(count-1) for u_0=2, u_1=t."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    if count == 0:
        return []
    terms = [2]
    if count == 1:
        return terms
    terms.append(t)
    while len(terms) < count:
        terms.append(t * terms[-1] - terms[-2])
    return terms


def trace_pairs(t: int, steps: int) -> Iterator[Pair]:
    """Yield (u_n,u_(n+1)) for n=0,...,steps-1."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    x, y = 2, t
    for _ in range(steps):
        yield x, y
        x, y = y, t * y - x


def mat_mul(a: Matrix2, b: Matrix2, modulus: int | None = None) -> Matrix2:
    """Multiply two 2-by-2 integer matrices, optionally modulo a modulus."""
    values = tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )
    result: Matrix2 = (values[0], values[1])  # type: ignore[assignment]
    if modulus is None:
        return result
    return tuple(tuple(v % modulus for v in row) for row in result)  # type: ignore[return-value]


def mat_pow(base: Matrix2, exponent: int, modulus: int | None = None) -> Matrix2:
    """Compute a nonnegative matrix power by binary exponentiation."""
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    result: Matrix2 = ((1, 0), (0, 1))
    while exponent:
        if exponent & 1:
            result = mat_mul(result, base, modulus)
        base = mat_mul(base, base, modulus)
        exponent //= 2
    return result


def trace_pair_fast(t: int, n: int, modulus: int | None = None) -> Pair:
    """Compute (u_n,u_(n+1)) in O(log n) matrix multiplications."""
    if modulus is not None and modulus <= 0:
        raise ValueError("modulus must be positive")
    transition: Matrix2 = ((0, 1), (-1, t))
    power = mat_pow(transition, n, modulus)
    x = power[0][0] * 2 + power[0][1] * t
    y = power[1][0] * 2 + power[1][1] * t
    return (x, y) if modulus is None else (x % modulus, y % modulus)


def modular_period(t: int, modulus: int) -> int:
    """Return the state period of the trace recurrence modulo modulus."""
    if modulus <= 1:
        raise ValueError("modulus must exceed one")
    start = (2 % modulus, t % modulus)
    state = start
    for period in range(1, modulus * modulus + 1):
        x, y = state
        state = (y, (t * y - x) % modulus)
        if state == start:
            return period
    raise RuntimeError("unimodular orbit failed to return within state-space bound")


def verify_invariant(t: int, steps: int) -> bool:
    """Check Q_t(u_n,u_(n+1)) = 4-t^2 for the requested states."""
    target = 4 - t * t
    return all(pell_form(t, x, y) == target for x, y in trace_pairs(t, steps))


def main() -> None:
    """Print three reproducible demonstrations of the main results."""
    t = 3
    terms = trace_terms(t, 10)
    print("Trace-three sequence:")
    print(terms)
    print("\nPell-conic audit Q_3(x,y) = -5:")
    for n, (x, y) in enumerate(trace_pairs(t, 6)):
        print(f"n={n:2d}: ({x:4d}, {y:4d}), Q={pell_form(t, x, y):3d}")
    assert terms[:6] == [2, 3, 7, 18, 47, 123]
    assert verify_invariant(t, 10)

    n, modulus = 10**18, 1009
    pair = trace_pair_fast(t, n, modulus)
    residue = pell_form(t, *pair) % modulus
    print(f"\nFast modular state at n={n}: {pair} modulo {modulus}")
    print(f"Invariant residue: {residue}; target: {(4-t*t) % modulus}")
    assert residue == (4 - t * t) % modulus

    print("\nState periods modulo selected moduli:")
    for m in (5, 7, 11, 25):
        print(f"mod {m:2d}: period {modular_period(t, m)}")


if __name__ == "__main__":
    main()
