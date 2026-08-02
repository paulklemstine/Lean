#!/usr/bin/env python3
"""Numerical demonstrations of the normalized determinant functional.

The script uses only the Python standard library. It evaluates two-qubit
states, checks the complex Lagrange identity, demonstrates projective scale
invariance, samples the full Schmidt family, and diagnoses the sharp endpoint.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sin, sqrt
from random import Random
from typing import Iterable, Sequence


@dataclass(frozen=True)
class State:
    """Four complex amplitudes in coefficient-matrix row order."""

    a: complex
    b: complex
    c: complex
    d: complex

    def amplitudes(self) -> tuple[complex, complex, complex, complex]:
        return (self.a, self.b, self.c, self.d)


def norm_sq(z: complex) -> float:
    """Return the squared complex modulus."""

    return z.real * z.real + z.imag * z.imag


def state_norm_sq(state: State) -> float:
    """Return |a|^2 + |b|^2 + |c|^2 + |d|^2."""

    return sum(norm_sq(z) for z in state.amplitudes())


def determinant(state: State) -> complex:
    """Return the exterior-square coordinate ad - bc."""

    return state.a * state.d - state.b * state.c


def row_inner(state: State) -> complex:
    """Return the Hermitian inner product of the coefficient rows."""

    return state.a.conjugate() * state.c + state.b.conjugate() * state.d


def row_norms_sq(state: State) -> tuple[float, float]:
    """Return the squared norms of the first and second rows."""

    return (
        norm_sq(state.a) + norm_sq(state.b),
        norm_sq(state.c) + norm_sq(state.d),
    )


def hopf_functional(state: State) -> float:
    """Compute 2|ad-bc|/||state||^2, assigning zero to the zero vector."""

    total = state_norm_sq(state)
    return 0.0 if total == 0.0 else 2.0 * abs(determinant(state)) / total


def scale(state: State, scalar: complex) -> State:
    """Multiply all amplitudes by one complex scalar."""

    return State(*(scalar * z for z in state.amplitudes()))


def normalize(state: State) -> State:
    """Normalize a nonzero state."""

    total = state_norm_sq(state)
    if total == 0.0:
        raise ValueError("the zero vector cannot be normalized")
    return scale(state, 1.0 / sqrt(total))


def lagrange_residual(state: State) -> float:
    """Return the absolute numerical residual in the Lagrange identity."""

    x, y = row_norms_sq(state)
    lhs = norm_sq(determinant(state)) + norm_sq(row_inner(state))
    return abs(lhs - x * y)


def maximizer_residuals(state: State) -> tuple[float, float]:
    """For a normalized state, report orthogonality and row-balance errors."""

    x, y = row_norms_sq(state)
    return abs(row_inner(state)), abs(x - 0.5) + abs(y - 0.5)


def schmidt_state(t: float) -> State:
    """Return sqrt(t)|00> + sqrt(1-t)|11> for 0 <= t <= 1."""

    if not 0.0 <= t <= 1.0:
        raise ValueError("t must lie in [0, 1]")
    return State(complex(sqrt(t)), 0j, 0j, complex(sqrt(1.0 - t)))


def random_normalized_state(rng: Random) -> State:
    """Draw and normalize a state with independent Gaussian coordinates."""

    values = [complex(rng.gauss(0.0, 1.0), rng.gauss(0.0, 1.0)) for _ in range(4)]
    return normalize(State(*values))


def format_complex(z: complex) -> str:
    """Compact complex-number formatting for the report."""

    return f"{z.real:+.6f}{z.imag:+.6f}i"


def report_state(name: str, state: State) -> None:
    """Print all geometric diagnostics for one state."""

    x, y = row_norms_sq(state)
    orth_error, balance_error = maximizer_residuals(state)
    print(f"\n{name}")
    print("-" * len(name))
    print(f"norm squared       : {state_norm_sq(state):.12f}")
    print(f"determinant        : {format_complex(determinant(state))}")
    print(f"row inner product  : {format_complex(row_inner(state))}")
    print(f"row norm squares   : ({x:.12f}, {y:.12f})")
    print(f"H                  : {hopf_functional(state):.12f}")
    print(f"Lagrange residual  : {lagrange_residual(state):.3e}")
    print(f"orthogonality error: {orth_error:.3e}")
    print(f"balance error      : {balance_error:.3e}")


def demonstrate_examples() -> None:
    """Show product, interior, and maximally entangled examples."""

    product = State(1 + 0j, 0j, 0j, 0j)
    bell = State(1 / sqrt(2), 0j, 0j, 1 / sqrt(2))
    midpoint = State(sqrt(2 + sqrt(3)) / 2, 0j, 0j, sqrt(2 - sqrt(3)) / 2)
    report_state("Product state |00>", product)
    report_state("Interior state with H = 1/2", midpoint)
    report_state("Bell state with H = 1", bell)


def demonstrate_scale_invariance() -> None:
    """Verify invariance under a nonunit complex rescaling."""

    state = normalize(State(1 + 2j, -0.5 + 0.25j, 0.75 - 1j, 2 + 0.5j))
    scalar = 2.75 * complex(cos(pi / 3), sin(pi / 3))
    scaled = scale(state, scalar)
    before = hopf_functional(state)
    after = hopf_functional(scaled)
    print("\nProjective scale invariance")
    print("---------------------------")
    print(f"scalar             : {format_complex(scalar)}")
    print(f"H(state)           : {before:.12f}")
    print(f"H(scalar * state)  : {after:.12f}")
    print(f"absolute difference: {abs(before - after):.3e}")


def demonstrate_schmidt_curve(samples: int = 11) -> None:
    """Tabulate H = 2 sqrt(t(1-t)) along a normalized Schmidt family."""

    print("\nContinuous Schmidt-family curve")
    print("-------------------------------")
    print("    t       computed H      formula H")
    for index in range(samples):
        t = index / (samples - 1)
        state = schmidt_state(t)
        formula = 2.0 * sqrt(t * (1.0 - t))
        print(f"{t:7.3f}    {hopf_functional(state):.9f}    {formula:.9f}")


def demonstrate_random_bounds(count: int = 5000, seed: int = 20260802) -> None:
    """Sample normalized states and report numerical range and identity error."""

    rng = Random(seed)
    states = [random_normalized_state(rng) for _ in range(count)]
    values = [hopf_functional(state) for state in states]
    max_identity_error = max(lagrange_residual(state) for state in states)
    print("\nRandom normalized-state diagnostics")
    print("-----------------------------------")
    print(f"samples                    : {count}")
    print(f"minimum sampled H          : {min(values):.12f}")
    print(f"maximum sampled H          : {max(values):.12f}")
    print(f"largest Lagrange residual  : {max_identity_error:.3e}")
    print("The samples illustrate the theorem; they are not a substitute for its proof.")


def main() -> None:
    """Run the complete demonstration suite."""

    print("Normalized determinant functional for pure two-qubit states")
    demonstrate_examples()
    demonstrate_scale_invariance()
    demonstrate_schmidt_curve()
    demonstrate_random_bounds()


if __name__ == "__main__":
    main()
