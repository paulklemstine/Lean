#!/usr/bin/env python3
"""Numerical demonstrations of recurrence and tropical spectral drift.

The calculations illustrate exact finite formulas and tolerance-based logistic
experiments. Numerical proximity is reported as approximate, never as a proof
of exact periodicity.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Callable, Iterable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


def iterate_map(f: Callable[[float], float], x0: float, steps: int) -> List[float]:
    """Return x_0 through x_steps for a scalar discrete dynamical system."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    orbit = [x0]
    for _ in range(steps):
        orbit.append(f(orbit[-1]))
    return orbit


def logistic(r: float, x: float) -> float:
    """One update of L_r(x) = r*x*(1-x)."""
    return r * x * (1.0 - x)


def logistic_period_three_report(
    r: float = 3.83, starts: Sequence[float] = (0.1, 0.2, 0.41, 0.73),
    burn_in: int = 1200
) -> List[Tuple[float, Tuple[float, float, float], float]]:
    """Estimate attracting phase triples and their lag-three residuals."""
    report: List[Tuple[float, Tuple[float, float, float], float]] = []
    f = lambda x: logistic(r, x)
    for start in starts:
        orbit = iterate_map(f, start, burn_in + 3)
        triple = (orbit[burn_in], orbit[burn_in + 1], orbit[burn_in + 2])
        residual = abs(orbit[burn_in + 3] - orbit[burn_in])
        report.append((start, triple, residual))
    return report


def half_map_return_table(x0: float, steps: int = 10) -> List[Tuple[int, float, float]]:
    """Compare iterates of x/2 with the exact formula x/2**n."""
    orbit = iterate_map(lambda x: x / 2.0, x0, steps)
    return [(n, value, x0 / (2.0**n)) for n, value in enumerate(orbit)]


def min_plus_matvec(matrix: Matrix, vector: Sequence[float]) -> Vector:
    """Compute (A tensor v)_i = min_j(A_ij + v_j)."""
    if not matrix or not vector:
        raise ValueError("matrix and vector must be nonempty")
    width = len(vector)
    if any(len(row) != width for row in matrix):
        raise ValueError("each matrix row must match the vector length")
    return [min(a + b for a, b in zip(row, vector)) for row in matrix]


def min_plus_iterate(matrix: Matrix, vector: Sequence[float], steps: int) -> Vector:
    """Apply a min-plus matrix action repeatedly."""
    state = list(vector)
    for _ in range(steps):
        state = min_plus_matvec(matrix, state)
    return state


def tropical_drift_report(
    matrix: Matrix, vector: Sequence[float], eigenvalue: float, max_steps: int = 6
) -> List[Tuple[int, Vector, Vector, float]]:
    """Compare direct min-plus iterates with v + k*lambda*1."""
    rows: List[Tuple[int, Vector, Vector, float]] = []
    for k in range(max_steps + 1):
        direct = min_plus_iterate(matrix, vector, k)
        predicted = [x + k * eigenvalue for x in vector]
        error = max(abs(a - b) for a, b in zip(direct, predicted))
        rows.append((k, direct, predicted, error))
    return rows


def print_demo() -> None:
    """Run all demonstrations and print readable tables."""
    print("LOGISTIC MAP AT r = 3.83: APPROXIMATE PERIOD-THREE PHASES")
    for start, triple, residual in logistic_period_three_report():
        values = ", ".join(f"{x:.12f}" for x in triple)
        print(f"start={start:.2f}  phases=({values})  lag-3 residual={residual:.3e}")

    print("\nCONTRACTION C(x)=x/2: ITERATES MATCH x/2^n")
    for n, observed, formula in half_map_return_table(1.0, 8):
        print(f"n={n:2d}  iterate={observed:.8f}  formula={formula:.8f}")
    print("Only x=0 can equal x/2^n for a positive n.")

    print("\nZERO TROPICAL EIGENVALUE: FIXED MIN-PLUS STATE")
    matrix = [[0.0, 2.0], [1.0, 0.0]]
    vector = [0.0, 0.0]
    for k, direct, predicted, error in tropical_drift_report(matrix, vector, 0.0):
        print(f"k={k}  direct={direct}  predicted={predicted}  max error={error:.1e}")

    print("\nNONZERO TROPICAL DRIFT")
    drifting_matrix = [[2.0, 4.0], [3.0, 2.0]]
    for k, direct, predicted, error in tropical_drift_report(
        drifting_matrix, vector, 2.0
    ):
        print(f"k={k}  direct={direct}  predicted={predicted}  max error={error:.1e}")


if __name__ == "__main__":
    print_demo()
