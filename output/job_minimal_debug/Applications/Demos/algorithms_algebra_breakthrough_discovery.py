#!/usr/bin/env python3
"""
algorithms.py — Algorithms for difference set analysis.

Implements efficient computation of difference sets and their structural
invariants: negation orbits, translation-reduced forms, and diameter bounds.
"""

from typing import FrozenSet


def difference_set(S: frozenset[int]) -> frozenset[int]:
    """
    Compute the difference set Δ(S) = {x - y : x, y ∈ S}.

    Time: O(|S|²)
    Space: O(|S|²)

    >>> difference_set(frozenset({1, 3, 7}))
    frozenset({-6, -4, -2, 0, 2, 4, 6})
    """
    return frozenset(x - y for x in S for y in S)


def nonzero_difference_set(S: frozenset[int]) -> frozenset[int]:
    """
    Compute Δ*(S) = Δ(S) \\ {0}.

    Time: O(|S|²)
    Space: O(|S|²)

    >>> nonzero_difference_set(frozenset({1, 3, 7}))
    frozenset({-6, -4, -2, 2, 4, 6})
    """
    return difference_set(S) - frozenset({0})


def positive_differences(S: frozenset[int]) -> frozenset[int]:
    """
    Compute the positive half Δ⁺(S) = {z ∈ Δ*(S) : z > 0}.

    By Theorem A, |Δ*(S)| = 2·|Δ⁺(S)|, so this is the canonical
    half-representation of the nonzero difference set.

    Time: O(|S|²)
    Space: O(|S|²)

    >>> sorted(positive_differences(frozenset({1, 3, 7})))
    [2, 4, 6]
    """
    return frozenset(z for z in nonzero_difference_set(S) if z > 0)


def translate(S: frozenset[int], a: int) -> frozenset[int]:
    """
    Translate S by a: S + a = {x + a : x ∈ S}.

    By Theorem B, Δ(S + a) = Δ(S).

    Time: O(|S|)
    Space: O(|S|)

    >>> translate(frozenset({1, 3, 7}), 10)
    frozenset({11, 13, 17})
    """
    return frozenset(x + a for x in S)


def canonical_form(S: frozenset[int]) -> frozenset[int]:
    """
    Translate S so that min(S) = 0.

    This is the canonical representative of S modulo translation.
    By Theorem B, Δ(canonical_form(S)) = Δ(S).

    Time: O(|S|)
    Space: O(|S|)

    >>> sorted(canonical_form(frozenset({5, 8, 12})))
    [0, 3, 7]
    """
    if not S:
        return S
    m = min(S)
    return frozenset(x - m for x in S)


def diameter(S: frozenset[int]) -> int:
    """
    Diameter D = max(S) - min(S).

    By Theorem C, all differences satisfy |z| ≤ D.

    Time: O(|S|)
    Space: O(1)

    >>> diameter(frozenset({1, 3, 7, 12}))
    11
    """
    return max(S) - min(S)


def representation_count(S: frozenset[int], d: int) -> int:
    """
    Compute r(d) = |{(x,y) ∈ S² : x - y = d}|.

    By Theorem A, r(d) = r(-d) (autocorrelation symmetry).

    Time: O(|S|)
    Space: O(1)

    >>> representation_count(frozenset({1, 3, 7, 12}), 2)
    1
    """
    return sum(1 for x in S if x - d in S)


def additive_energy(S: frozenset[int]) -> int:
    """
    Compute the additive energy E(S) = Σ_{d ∈ Δ(S)} r(d)².

    This equals |{(a,b,c,d) ∈ S⁴ : a-b = c-d}|.

    Time: O(|S|²)
    Space: O(|S|²)

    >>> additive_energy(frozenset({1, 3, 7, 12}))
    20
    """
    D = difference_set(S)
    return sum(representation_count(S, d) ** 2 for d in D)


def negation_orbits(S: frozenset[int]) -> list[tuple[int, int]]:
    """
    Decompose Δ*(S) into {z, -z} orbits under the C₂ negation action.

    By Theorem A, every nonzero difference pairs with its negative.

    Returns list of (positive, negative) pairs sorted by positive element.

    Time: O(|S|²)
    Space: O(|S|²)

    >>> negation_orbits(frozenset({1, 3, 7}))
    [(2, -2), (4, -4), (6, -6)]
    """
    pos = sorted(positive_differences(S))
    return [(z, -z) for z in pos]


def is_sidon_set(S: frozenset[int]) -> bool:
    """
    Check if S is a Sidon set (all nonzero differences have representation count 1).

    For a Sidon set of size n, |Δ*(S)| = n(n-1) (maximum possible).

    Time: O(|S|²)
    Space: O(|S|²)

    >>> is_sidon_set(frozenset({1, 3, 7}))
    True
    >>> is_sidon_set(frozenset({1, 3, 5, 7}))
    False
    """
    D_star = nonzero_difference_set(S)
    return all(representation_count(S, d) <= 1 for d in D_star)


def difference_set_summary(S: frozenset[int]) -> dict:
    """
    Compute a complete structural summary of the difference set of S.

    Returns dict with all key invariants.

    >>> s = difference_set_summary(frozenset({1, 3, 7, 12}))
    >>> s['card_S'], s['card_diff'], s['card_nonzero_diff'], s['diameter']
    (4, 13, 12, 11)
    """
    D = difference_set(S)
    D_star = nonzero_difference_set(S)
    pos = positive_differences(S)
    diam = diameter(S) if S else 0

    return {
        'S': sorted(S),
        'card_S': len(S),
        'diff_set': sorted(D),
        'card_diff': len(D),
        'nonzero_diff_set': sorted(D_star),
        'card_nonzero_diff': len(D_star),
        'card_nonzero_diff_is_even': len(D_star) % 2 == 0,
        'positive_diffs': sorted(pos),
        'card_positive_diffs': len(pos),
        'two_times_positive_equals_nonzero': 2 * len(pos) == len(D_star),
        'diameter': diam,
        'max_abs_diff': max(abs(z) for z in D) if D else 0,
        'diameter_bound_holds': all(abs(z) <= diam for z in D),
        'cardinality_bound_holds': len(D) <= 2 * diam + 1 if S else True,
        'is_sidon': is_sidon_set(S),
        'additive_energy': additive_energy(S),
        'canonical_form': sorted(canonical_form(S)),
    }


if __name__ == '__main__':
    print("=== Difference Set Structural Analysis ===\n")

    examples = [
        frozenset({1, 3, 7}),
        frozenset({1, 3, 7, 12}),
        frozenset({0, 1, 3, 7, 12, 20}),
        frozenset({1, 2, 3, 4, 5}),  # arithmetic progression
    ]

    for S in examples:
        summary = difference_set_summary(S)
        print(f"S = {summary['S']}")
        print(f"  |S| = {summary['card_S']}")
        print(f"  Δ(S) = {summary['diff_set']}")
        print(f"  |Δ(S)| = {summary['card_diff']}, |Δ*(S)| = {summary['card_nonzero_diff']} (even: {summary['card_nonzero_diff_is_even']})")
        print(f"  Δ⁺(S) = {summary['positive_diffs']}, |Δ⁺| = {summary['card_positive_diffs']}")
        print(f"  2·|Δ⁺| = |Δ*|: {summary['two_times_positive_equals_nonzero']}")
        print(f"  Diameter D = {summary['diameter']}, max|z| = {summary['max_abs_diff']} ≤ D: {summary['diameter_bound_holds']}")
        print(f"  |Δ(S)| ≤ 2D+1 = {2*summary['diameter']+1}: {summary['cardinality_bound_holds']}")
        print(f"  Sidon: {summary['is_sidon']}, Energy: {summary['additive_energy']}")
        print(f"  Canonical: {summary['canonical_form']}")
        print()
