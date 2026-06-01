#!/usr/bin/env python3
"""
Birthday-Stratified Surreal Arithmetic — Core Algorithms

Type-hinted implementations of the key mathematical algorithms.
"""

from fractions import Fraction
from typing import Optional, Tuple, List
from dataclasses import dataclass


# ─── Algorithm 1: Dyadic Classification ───

def is_dyadic(q: Fraction) -> bool:
    """
    Determine if a rational number is dyadic.

    A rational q is dyadic if its denominator (in lowest terms) is a power of 2.

    Time complexity: O(log(q.denominator))
    """
    d = q.denominator
    while d > 1:
        if d % 2 != 0:
            return False
        d //= 2
    return True


def dyadic_valuation(q: Fraction) -> int:
    """
    Compute the dyadic valuation ν₂(q) = v₂(q.denominator).

    This equals the surreal birthday of q when q is dyadic.

    Time complexity: O(log(q.denominator))
    """
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


def dyadic_reduction(m: int, n: int) -> Tuple[int, int]:
    """
    Reduce m/2^n to lowest dyadic form (m', n') where m' is odd.

    Returns (m', n') such that m/2^n = m'/2^n' and m' is odd.

    This is the "birthday normalization" algorithm.
    """
    while n > 0 and m % 2 == 0:
        m //= 2
        n -= 1
    return (m, n)


# ─── Algorithm 2: Dyadic Approximation ───

def dyadic_approximation(q: Fraction, n: int) -> Fraction:
    """
    Best dyadic approximation of q with denominator dividing 2^n.

    Returns d such that |q - d| ≤ 1/2^n and d is dyadic.

    Uses the floor construction: d = ⌊q · 2^n⌋ / 2^n.
    """
    power = 2 ** n
    scaled = q * power
    # Integer floor
    floored = int(scaled)
    if Fraction(floored) > scaled:
        floored -= 1
    return Fraction(floored, power)


def find_dyadic_between(a: Fraction, b: Fraction) -> Optional[Fraction]:
    """
    Find a dyadic rational strictly between a and b.

    Returns the dyadic of smallest birthday (minimum denominator power)
    strictly between a and b, or None if a >= b.

    This implements the constructive density proof.
    """
    if a >= b:
        return None

    for n in range(100):
        power = 2 ** n
        # Check all dyadics k/2^n in (a, b)
        lo = int(a * power)
        hi = int(b * power)
        if b * power > hi:
            pass  # hi is already below b
        else:
            hi -= 1  # b*power is exact integer, exclude it

        for k in range(lo + 1, hi + 1):
            candidate = Fraction(k, power)
            if a < candidate < b:
                return candidate

    return None  # Should not happen for distinct rationals


# ─── Algorithm 3: Surreal Counting ───

def surreal_count(n: int) -> int:
    """Number of distinct surreal values born by day n."""
    return 2 ** (n + 1) - 1


def new_surreals_at_day(n: int) -> int:
    """Number of new surreal values born on exactly day n."""
    return 1 if n == 0 else 2 ** n


def surreal_count_from_sum(n: int) -> int:
    """Compute surreal count as a sum (verifying the geometric series identity)."""
    return sum(new_surreals_at_day(k) for k in range(n + 1))


# ─── Algorithm 4: Game Depth (for finite games) ───

@dataclass
class FiniteGame:
    """A finite combinatorial game {L | R}."""
    left_options: List['FiniteGame']
    right_options: List['FiniteGame']

    @staticmethod
    def zero() -> 'FiniteGame':
        return FiniteGame([], [])

    @staticmethod
    def one() -> 'FiniteGame':
        return FiniteGame([FiniteGame.zero()], [])

    @staticmethod
    def neg_one() -> 'FiniteGame':
        return FiniteGame([], [FiniteGame.zero()])

    @staticmethod
    def half() -> 'FiniteGame':
        return FiniteGame([FiniteGame.zero()], [FiniteGame.one()])

    def negate(self) -> 'FiniteGame':
        return FiniteGame(
            [r.negate() for r in self.right_options],
            [l.negate() for l in self.left_options]
        )

    def birthday(self) -> int:
        """Compute the birthday of this game."""
        if not self.left_options and not self.right_options:
            return 0
        max_b = 0
        for opt in self.left_options + self.right_options:
            max_b = max(max_b, opt.birthday() + 1)
        return max_b

    def depth(self) -> int:
        """Compute the game depth (longest play sequence)."""
        if not self.left_options and not self.right_options:
            return 0
        left_max = max((opt.depth() + 1 for opt in self.left_options), default=0)
        right_max = max((opt.depth() + 1 for opt in self.right_options), default=0)
        return max(left_max, right_max)

    def complexity(self) -> Tuple[int, int]:
        """Two-dimensional game complexity (birthday, depth)."""
        return (self.birthday(), self.depth())


# ─── Algorithm 5: Birthday–Denomination Verification ───

def verify_birthday_denomination(m: int, n: int) -> bool:
    """
    Verify the Birthday–Denomination Principle for m/2^n.

    If m is odd, checks that m/2^n ≠ a/2^k for all integers a and k < n.
    Returns True if the principle holds.
    """
    if m % 2 == 0:
        return True  # Principle only applies to odd numerators

    q = Fraction(m, 2 ** n)
    for k in range(n):
        # Check if q = a/2^k for any integer a
        a_val = q * (2 ** k)
        if a_val.denominator == 1:
            return False  # Found a simplification!
    return True


# ─── Algorithm 6: Valuation Subadditivity Verification ───

def verify_valuation_subadditivity(
    samples: List[Tuple[Fraction, Fraction]]
) -> Tuple[int, int]:
    """
    Verify ν₂(p+q) ≤ ν₂(p) + ν₂(q) for given pairs.

    Returns (passed, total) counts.
    """
    passed = 0
    total = len(samples)
    for p, q in samples:
        vp = dyadic_valuation(p)
        vq = dyadic_valuation(q)
        vpq = dyadic_valuation(p + q)
        if vpq <= vp + vq:
            passed += 1
    return (passed, total)


if __name__ == "__main__":
    # Quick verification
    print("Algorithm Verification:")

    # Dyadic classification
    assert is_dyadic(Fraction(3, 8))
    assert not is_dyadic(Fraction(1, 3))
    print("  ✓ Dyadic classification")

    # Dyadic valuation
    assert dyadic_valuation(Fraction(3, 8)) == 3
    assert dyadic_valuation(Fraction(5, 16)) == 4
    assert dyadic_valuation(Fraction(1, 1)) == 0
    print("  ✓ Dyadic valuation")

    # Reduction
    assert dyadic_reduction(6, 4) == (3, 3)
    assert dyadic_reduction(8, 5) == (1, 2)
    print("  ✓ Dyadic reduction")

    # Approximation
    d = dyadic_approximation(Fraction(1, 3), 5)
    assert abs(Fraction(1, 3) - d) <= Fraction(1, 32)
    print("  ✓ Dyadic approximation")

    # Density
    d = find_dyadic_between(Fraction(1, 3), Fraction(1, 2))
    assert d is not None and Fraction(1, 3) < d < Fraction(1, 2)
    print("  ✓ Dyadic density")

    # Game complexity
    zero = FiniteGame.zero()
    one = FiniteGame.one()
    half = FiniteGame.half()
    assert zero.complexity() == (0, 0)
    assert one.complexity() == (1, 1)
    assert half.complexity() == (2, 2)
    neg_one = one.negate()
    assert neg_one.complexity() == one.complexity()
    print("  ✓ Game complexity")

    # Birthday denomination
    for m in range(1, 20, 2):
        for n in range(1, 6):
            assert verify_birthday_denomination(m, n)
    print("  ✓ Birthday denomination principle")

    # Surreal counting
    for n in range(10):
        assert surreal_count(n) == surreal_count_from_sum(n)
    print("  ✓ Surreal counting")

    print("\nAll algorithms verified ✓")
