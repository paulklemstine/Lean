#!/usr/bin/env python3
"""Numerical demonstrations of idealized Coulomb and oscillator shell models."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, Sequence


def angular_count(n: int) -> int:
    """Return sum_{l=0}^{n-1} (2l+1), after validating n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return sum(2 * l + 1 for l in range(n))


def coulomb_degeneracy(n: int) -> int:
    """Return the spin-inclusive capacity 2n^2 of positive shell n."""
    if n < 1:
        raise ValueError("Coulomb shell n must be positive")
    return 2 * n * n


def coulomb_closure(n: int) -> int:
    """Return the particles required to fill Coulomb shells 1 through n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return n * (n + 1) * (2 * n + 1) // 3


def oscillator_degeneracy(level: int) -> int:
    """Return the spin-inclusive 3D oscillator degeneracy (N+1)(N+2)."""
    if level < 0:
        raise ValueError("oscillator level must be nonnegative")
    return (level + 1) * (level + 2)


def oscillator_closure(level: int) -> int:
    """Return the particles required to fill oscillator levels 0 through N."""
    if level < 0:
        raise ValueError("oscillator level must be nonnegative")
    return (level + 1) * (level + 2) * (level + 3) // 3


def shell_energy(index: int) -> Fraction:
    """Return the exact ideal energy -1/(index+1)^2."""
    if index < 0:
        raise ValueError("energy index must be nonnegative")
    return Fraction(-1, (index + 1) ** 2)


def diagonal_mul_vector(diagonal: Sequence[Fraction], vector: Sequence[Fraction]) -> list[Fraction]:
    """Multiply a diagonal matrix, stored by its diagonal, by a vector."""
    if len(diagonal) != len(vector):
        raise ValueError("diagonal and vector dimensions differ")
    return [entry * coordinate for entry, coordinate in zip(diagonal, vector)]


def first_mismatch(predicted: Sequence[int], observed: Sequence[int]) -> tuple[int, int, int] | None:
    """Return (index, prediction, observation) at the first mismatch."""
    for index, (prediction, observation) in enumerate(zip(predicted, observed)):
        if prediction != observation:
            return index, prediction, observation
    return None


@dataclass(frozen=True)
class ShellRow:
    model: str
    index: int
    degeneracy: int
    cumulative: int


def build_rows(model: str, count: int) -> list[ShellRow]:
    """Enumerate shell capacities and cumulative fillings for one model."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    rows: list[ShellRow] = []
    total = 0
    for offset in range(count):
        index = offset + 1 if model == "Coulomb" else offset
        degeneracy = (
            coulomb_degeneracy(index)
            if model == "Coulomb"
            else oscillator_degeneracy(index)
        )
        total += degeneracy
        rows.append(ShellRow(model, index, degeneracy, total))
    return rows


def print_table(rows: Iterable[ShellRow]) -> None:
    """Print aligned shell data."""
    print(f"{'model':<12} {'index':>5} {'degeneracy':>12} {'closure':>9}")
    print("-" * 43)
    for row in rows:
        print(f"{row.model:<12} {row.index:>5} {row.degeneracy:>12} {row.cumulative:>9}")


def verify_identities(limit: int = 20) -> None:
    """Check direct sums against all closed forms through a finite limit."""
    for n in range(limit + 1):
        assert angular_count(n) == n * n
        direct_coulomb = sum(coulomb_degeneracy(k) for k in range(1, n + 1))
        assert direct_coulomb == coulomb_closure(n)
        direct_oscillator = sum(oscillator_degeneracy(k) for k in range(n + 1))
        assert direct_oscillator == oscillator_closure(n)


def demonstrate_eigenvectors(dimension: int = 5) -> None:
    """Check H e_i = E_i e_i and trace equality for a diagonal Hamiltonian."""
    diagonal = [shell_energy(i) for i in range(dimension)]
    for i, energy in enumerate(diagonal):
        basis = [Fraction(int(j == i), 1) for j in range(dimension)]
        product = diagonal_mul_vector(diagonal, basis)
        expected = [energy * coordinate for coordinate in basis]
        assert product == expected
    print("Diagonal energies:", [str(value) for value in diagonal])
    print("Trace:", sum(diagonal, start=Fraction(0, 1)))
    print(f"Verified H e_i = E_i e_i for all {dimension} standard basis vectors.")


def main() -> None:
    verify_identities()
    print("COULOMB SHELLS")
    print_table(build_rows("Coulomb", 5))
    print("\nOSCILLATOR LEVELS")
    print_table(build_rows("Oscillator", 6))

    observed_noble = [2, 10, 18, 36, 54, 86]
    observed_magic = [2, 8, 20, 28, 50, 82]
    coulomb = [coulomb_closure(n) for n in range(1, 7)]
    oscillator = [oscillator_closure(n) for n in range(6)]
    print("\nFirst Coulomb/observed mismatch:", first_mismatch(coulomb, observed_noble))
    print("First oscillator/observed mismatch:", first_mismatch(oscillator, observed_magic))
    print("\nDIAGONAL SPECTRAL CHECK")
    demonstrate_eigenvectors()


if __name__ == "__main__":
    main()
