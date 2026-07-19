#!/usr/bin/env python3
"""Numerical demonstrations for finite derivation-search information bounds.

The program uses only Python's standard library.  It computes exact candidate
counts with arbitrary-precision integers and uses floating-point logarithms only
for presentation.  Run it directly with ``python demo.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import log2
from typing import Iterable, Sequence


@dataclass(frozen=True)
class SearchProfile:
    """Exact count and logarithmic information for a candidate family."""

    candidate_count: int
    information_bits: float | None
    worst_case_queries: int


def uniform_search_profile(alphabet_size: int, depth: int) -> SearchProfile:
    """Analyze words of a fixed depth over a uniform finite alphabet.

    For positive candidate count, information is log2(candidate_count).  When
    the family is empty, its finite logarithmic information is left undefined.
    """
    if alphabet_size < 0 or depth < 0:
        raise ValueError("alphabet_size and depth must be nonnegative")
    count = alphabet_size**depth
    bits = log2(count) if count > 0 else None
    return SearchProfile(count, bits, count)


def short_binary_description_count(bit_length: int) -> int:
    """Return the number of binary strings strictly shorter than bit_length."""
    if bit_length < 0:
        raise ValueError("bit_length must be nonnegative")
    return 2**bit_length - 1


def variable_branching_profile(branching_factors: Sequence[int]) -> SearchProfile:
    """Analyze a tree whose branching factor may vary from level to level."""
    if any(branch < 0 for branch in branching_factors):
        raise ValueError("branching factors must be nonnegative")
    count = 1
    for branch in branching_factors:
        count *= branch
    bits = sum(log2(branch) for branch in branching_factors) if count > 0 else None
    return SearchProfile(count, bits, count)


def composition_profile(
    first_alphabet: int,
    first_depth: int,
    second_alphabet: int,
    second_depth: int,
) -> tuple[SearchProfile, SearchProfile, SearchProfile]:
    """Compare two independent word families with their Cartesian product."""
    first = uniform_search_profile(first_alphabet, first_depth)
    second = uniform_search_profile(second_alphabet, second_depth)
    count = first.candidate_count * second.candidate_count
    combined = SearchProfile(count, log2(count) if count > 0 else None, count)
    return first, second, combined


def format_bits(bits: float | None) -> str:
    """Format an optional bit count for a compact report."""
    return "undefined (empty family)" if bits is None else f"{bits:.6f} bits"


def demonstrate_exact_counts() -> None:
    """Print the exact finite-word counts used in the main counting theorem."""
    print("1. Exact candidate counts")
    for alphabet, depth in ((2, 5), (4, 3), (3, 3), (10, 10)):
        profile = uniform_search_profile(alphabet, depth)
        print(
            f"   q={alphabet:>2}, L={depth:>2}: "
            f"q^L={profile.candidate_count:,}, "
            f"information={format_bits(profile.information_bits)}"
        )
    print()


def demonstrate_incompressibility(max_bits: int = 10) -> None:
    """Display the one-description deficit proving strict incompressibility."""
    if max_bits < 0:
        raise ValueError("max_bits must be nonnegative")
    print("2. Finite incompressibility table")
    print("   n | n-bit objects | descriptions shorter than n | deficit")
    for n in range(max_bits + 1):
        objects = 2**n
        shorter = short_binary_description_count(n)
        print(f"   {n:>2} | {objects:>13,} | {shorter:>27,} | {objects-shorter:>7}")
    print()


def demonstrate_composition_and_variable_branching() -> None:
    """Show multiplicative counts and additive logarithmic information."""
    print("3. Composition and variable branching")
    first, second, combined = composition_profile(2, 5, 4, 3)
    assert combined.candidate_count == first.candidate_count * second.candidate_count
    assert combined.information_bits is not None
    assert first.information_bits is not None and second.information_bits is not None
    print(
        f"   Independent families: {first.candidate_count} × "
        f"{second.candidate_count} = {combined.candidate_count} candidates"
    )
    print(
        f"   Information: {first.information_bits:.3f} + "
        f"{second.information_bits:.3f} = {combined.information_bits:.3f} bits"
    )

    branches = (2, 3, 4, 5)
    variable = variable_branching_profile(branches)
    print(
        f"   Branching levels {branches}: product={variable.candidate_count}, "
        f"sum of logarithms={format_bits(variable.information_bits)}"
    )
    print()


def verify_identities(samples: Iterable[tuple[int, int]]) -> None:
    """Assert the central finite identities on a supplied collection of samples."""
    for alphabet, depth in samples:
        profile = uniform_search_profile(alphabet, depth)
        assert profile.candidate_count == alphabet**depth
        if alphabet > 0:
            assert profile.information_bits is not None
            assert abs(profile.information_bits - depth * log2(alphabet)) < 1e-12
        assert short_binary_description_count(depth) == 2**depth - 1


def main() -> None:
    """Run all numerical demonstrations and internal consistency checks."""
    verify_identities((q, depth) for q in range(1, 9) for depth in range(0, 9))
    demonstrate_exact_counts()
    demonstrate_incompressibility(10)
    demonstrate_composition_and_variable_branching()
    print("All exact integer identities and numerical logarithmic checks passed.")


if __name__ == "__main__":
    main()
