#!/usr/bin/env python3
"""
Algorithms for Surreal Number Arithmetic and Dyadic Rational Operations.

Type-hinted implementations of the core algorithms from the research paper.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class GameTree:
    """A combinatorial game tree {L | R}.

    Represents a PGame where left_options are Left's available moves
    and right_options are Right's available moves.
    """
    left_options: List['GameTree']
    right_options: List['GameTree']

    def __repr__(self) -> str:
        left_str = ", ".join(repr(o) for o in self.left_options)
        right_str = ", ".join(repr(o) for o in self.right_options)
        return f"{{{left_str} | {right_str}}}"


# ============================================================
# Core Algorithms
# ============================================================

def game_birthday(game: GameTree) -> int:
    """Compute the birthday of a game tree.

    Algorithm: birthday({L | R}) = max(max(birthday(l) + 1 for l in L),
                                       max(birthday(r) + 1 for r in R))

    Time complexity: O(|T|) where |T| is the number of nodes.
    """
    left_max = max((game_birthday(l) + 1 for l in game.left_options), default=0)
    right_max = max((game_birthday(r) + 1 for r in game.right_options), default=0)
    return max(left_max, right_max)


def game_depth(game: GameTree) -> int:
    """Compute the game depth (maximum play length).

    For numeric games, this equals the birthday.
    For non-numeric games, it can exceed the birthday.

    Time complexity: O(|T|)
    """
    left_max = max((game_depth(l) + 1 for l in game.left_options), default=0)
    right_max = max((game_depth(r) + 1 for r in game.right_options), default=0)
    return max(left_max, right_max)


def negate_game(game: GameTree) -> GameTree:
    """Negate a game: -{L | R} = {-R | -L}.

    Time complexity: O(|T|)
    """
    return GameTree(
        left_options=[negate_game(r) for r in game.right_options],
        right_options=[negate_game(l) for l in game.left_options]
    )


def dyadic_to_game(q: Fraction) -> GameTree:
    """Convert a dyadic rational to its canonical game tree representation.

    Algorithm (Conway's simplicity theorem):
    - 0 = {|}
    - n > 0 integer: {n-1 | }
    - n < 0 integer: { | n+1}
    - m/2^k with m odd, 0 < m/2^k < 1: {0 | nearest simpler dyadic above}
    - General: recursive construction based on the simplest number in (L, R)

    Time complexity: O(birthday(q))
    """
    if q == 0:
        return GameTree([], [])
    if q > 0 and q.denominator == 1:
        n = int(q)
        return GameTree([dyadic_to_game(Fraction(n - 1))], [])
    if q < 0 and q.denominator == 1:
        n = int(q)
        return GameTree([], [dyadic_to_game(Fraction(n + 1))])
    # Non-integer dyadic: find the simplest representation
    # Floor and ceiling in integers
    floor_q = Fraction(int(q), 1)
    if q < 0 and q != floor_q:
        floor_q = Fraction(int(q) - 1, 1)
    ceil_q = floor_q + 1
    # Find the simplest dyadic in (floor_q, ceil_q) that equals q
    # Use binary search on the dyadic tree
    lo, hi = floor_q, ceil_q
    left_opt = dyadic_to_game(lo)
    right_opt = dyadic_to_game(hi)
    mid = (lo + hi) / 2
    if mid == q:
        return GameTree([left_opt], [right_opt])
    elif q < mid:
        return GameTree([left_opt], [dyadic_to_game(mid)])
    else:
        return GameTree([dyadic_to_game(mid)], [right_opt])


def is_dyadic(q: Fraction) -> bool:
    """Check if a rational number is dyadic.

    Time complexity: O(log(denominator))
    """
    d = q.denominator
    while d > 1:
        if d % 2 != 0:
            return False
        d //= 2
    return True


def dyadic_valuation(q: Fraction) -> int:
    """Compute the 2-adic valuation of the denominator of q.

    This equals the surreal birthday minus 1 for non-integer dyadics.
    Returns the smallest n such that q * 2^n is an integer.

    Time complexity: O(log(denominator))
    """
    if q == 0:
        return 0
    d = q.denominator
    v = 0
    while d > 1:
        if d % 2 != 0:
            raise ValueError(f"{q} is not dyadic")
        d //= 2
        v += 1
    return v


def best_dyadic_approx(q: Fraction, n: int) -> Fraction:
    """Find the best dyadic approximation with denominator dividing 2^n.

    Returns d = floor(q * 2^n) / 2^n.

    Time complexity: O(1)
    """
    power = 2 ** n
    scaled = q * power
    floored = Fraction(int(scaled), 1)
    if scaled < 0 and scaled != floored:
        floored -= 1
    return floored / power


def surreals_by_day(n: int) -> List[Fraction]:
    """Generate all surreal numbers (dyadic rationals) born by day n.

    Uses the recursive construction:
    - Day 0: {0}
    - Day k+1: add midpoints of consecutive pairs and new extremes

    Time complexity: O(2^n)
    """
    if n == 0:
        return [Fraction(0)]
    prev = surreals_by_day(n - 1)
    prev.sort()
    new_values: Set[Fraction] = set(prev)
    for i in range(len(prev) - 1):
        mid = (prev[i] + prev[i + 1]) / 2
        new_values.add(mid)
    if prev:
        new_values.add(prev[0] - 1)
        new_values.add(prev[-1] + 1)
    return sorted(new_values)


def verify_subring_closure(dyadics: List[Fraction]) -> Tuple[bool, bool, bool]:
    """Verify that a set of dyadic rationals is closed under +, *, -.

    Returns (add_closed, mul_closed, neg_closed).
    """
    s = set(dyadics)
    add_ok = all(is_dyadic(a + b) for a in s for b in s)
    mul_ok = all(is_dyadic(a * b) for a in s for b in s)
    neg_ok = all(is_dyadic(-a) for a in s)
    return add_ok, mul_ok, neg_ok


def birthday_hierarchy_test(max_day: int = 6) -> bool:
    """Test the birthday hierarchy conjecture for small days.

    Verifies that all surreals born by day n are dyadic rationals
    with denominator dividing 2^(n-1).
    """
    for n in range(max_day + 1):
        surreals = surreals_by_day(n)
        for s in surreals:
            if not is_dyadic(s):
                return False
            # Check denominator bound
            if n > 0 and s.denominator > 2 ** (n - 1):
                return False
    return True


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Demo: construct game trees for small surreals
    print("Game tree representations:")
    for q in [Fraction(0), Fraction(1), Fraction(-1), Fraction(1, 2)]:
        tree = dyadic_to_game(q)
        birthday = game_birthday(tree)
        print(f"  {q} -> {tree}  (birthday={birthday})")

    print(f"\nBirthday hierarchy test: {'PASS' if birthday_hierarchy_test() else 'FAIL'}")

    print("\nDyadic valuations:")
    for q in [Fraction(1, 2), Fraction(3, 4), Fraction(7, 8), Fraction(1, 16)]:
        print(f"  v₂(den({q})) = {dyadic_valuation(q)}")

    print("\nBest dyadic approximations to 1/3:")
    for n in range(1, 8):
        d = best_dyadic_approx(Fraction(1, 3), n)
        err = abs(Fraction(1, 3) - d)
        print(f"  n={n}: d={float(d):.6f}, error={float(err):.8f}")
