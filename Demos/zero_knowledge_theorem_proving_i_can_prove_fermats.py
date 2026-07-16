#!/usr/bin/env python3
"""Numerical demonstrations of truth-table soundness and additive hiding.

The script uses only the Python standard library. It computes exact acceptance
counts for a small implication-based formula, evaluates the sharp worst-case
repetition law, and exhaustively confirms uniform additive masking modulo q.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from math import ceil, exp, log, log1p
from typing import Callable, Iterable, Sequence

Valuation = tuple[bool, ...]
FormulaEvaluator = Callable[[Valuation], bool]


def implication(left: bool, right: bool) -> bool:
    """Return the Boolean implication left -> right."""
    return (not left) or right


def all_valuations(variable_count: int) -> Iterable[Valuation]:
    """Generate all Boolean valuations in lexicographic order."""
    if variable_count < 0:
        raise ValueError("variable_count must be nonnegative")
    return product((False, True), repeat=variable_count)


@dataclass(frozen=True)
class AcceptanceProfile:
    """Exact acceptance statistics for a propositional formula."""

    variable_count: int
    accepting_count: int
    total_count: int

    @property
    def one_round_probability(self) -> Fraction:
        return Fraction(self.accepting_count, self.total_count)

    def repeated_probability(self, rounds: int) -> Fraction:
        if rounds < 0:
            raise ValueError("rounds must be nonnegative")
        return self.one_round_probability**rounds


def profile_formula(variable_count: int, formula: FormulaEvaluator) -> AcceptanceProfile:
    """Exhaustively count the valuations accepted by formula."""
    accepting = sum(1 for valuation in all_valuations(variable_count) if formula(valuation))
    return AcceptanceProfile(variable_count, accepting, 2**variable_count)


def unique_rejection_probability(variable_count: int, rounds: int) -> float:
    """Return (1 - 2^-m)^k, evaluated stably in floating-point arithmetic."""
    if variable_count <= 0:
        raise ValueError("variable_count must be positive")
    if rounds < 0:
        raise ValueError("rounds must be nonnegative")
    rejection_density = 2.0 ** (-variable_count)
    return exp(rounds * log1p(-rejection_density))


def rounds_for_target_error(variable_count: int, target_error: float) -> int:
    """Find the least k for which (1 - 2^-m)^k <= target_error."""
    if variable_count <= 0:
        raise ValueError("variable_count must be positive")
    if not 0.0 < target_error < 1.0:
        raise ValueError("target_error must lie strictly between zero and one")
    base_log = log1p(-(2.0 ** (-variable_count)))
    candidate = max(0, ceil(log(target_error) / base_log))
    # Correct any floating-point boundary error.
    while candidate > 0 and unique_rejection_probability(variable_count, candidate - 1) <= target_error:
        candidate -= 1
    while unique_rejection_probability(variable_count, candidate) > target_error:
        candidate += 1
    return candidate


def masking_histogram(modulus: int, secret: int) -> list[int]:
    """Enumerate the output frequency of secret + mask modulo modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    counts = [0] * modulus
    for mask in range(modulus):
        counts[(secret + mask) % modulus] += 1
    return counts


def verify_perfect_hiding(modulus: int) -> bool:
    """Exhaustively check that all secrets induce the same uniform histogram."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    expected = [1] * modulus
    return all(masking_histogram(modulus, secret) == expected for secret in range(modulus))


def print_truth_table_demo() -> None:
    """Profile a tautology and a formula with one rejecting valuation."""
    tautology = lambda v: implication(v[0], v[0])
    disjunction = lambda v: v[0] or v[1] or v[2]
    tautology_profile = profile_formula(1, tautology)
    sparse_profile = profile_formula(3, disjunction)

    print("1. Exact truth-table profiles")
    print(f"   p -> p accepts {tautology_profile.accepting_count}/{tautology_profile.total_count} valuations.")
    print(f"   x0 OR x1 OR x2 accepts {sparse_profile.accepting_count}/{sparse_profile.total_count} valuations.")
    probability = sparse_profile.repeated_probability(10)
    print(f"   Its exact 10-round survival probability is {probability} = {float(probability):.6f}.")


def print_amplification_demo() -> None:
    """Display how the sharp soundness bound scales with m and k."""
    print("\n2. Sharp repeated-challenge bound for a uniquely falsified formula")
    print("   variables   rounds   survival probability")
    for variables, rounds in ((3, 10), (10, 1000), (20, 1000)):
        survival = unique_rejection_probability(variables, rounds)
        print(f"   {variables:9d}   {rounds:6d}   {survival:.12f}")
    variables = 10
    target = 0.01
    needed = rounds_for_target_error(variables, target)
    print(f"   For m={variables}, reaching error at most {target} requires {needed} rounds.")


def print_hiding_demo() -> None:
    """Show exact uniformity for every secret modulo a small modulus."""
    modulus = 7
    print(f"\n3. Additive masking modulo {modulus}")
    for secret in range(modulus):
        observations: Sequence[int] = tuple((secret + mask) % modulus for mask in range(modulus))
        print(f"   secret {secret}: observations {observations}; histogram {masking_histogram(modulus, secret)}")
    print(f"   Perfect-hiding audit passed: {verify_perfect_hiding(modulus)}")


def main() -> None:
    print("Random-Valuation Soundness and Perfect Additive Hiding\n")
    print_truth_table_demo()
    print_amplification_demo()
    print_hiding_demo()


if __name__ == "__main__":
    main()
