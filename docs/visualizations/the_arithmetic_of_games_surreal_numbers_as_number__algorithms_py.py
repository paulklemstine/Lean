#!/usr/bin/env python3
"""
Algorithms for Surreal Number Arithmetic

Type-hinted implementations of key algorithms from the surreal number
birthday hierarchy theory. These algorithms compute surreal number
representations, dyadic rational operations, and birthday functions.
"""

from __future__ import annotations
from fractions import Fraction
from typing import FrozenSet, Tuple, Optional, List, Set
from dataclasses import dataclass, field


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass(frozen=True)
class SurrealForm:
    """A surreal number in Conway normal form {L | R}.
    
    A surreal number is defined by two sets of previously constructed
    surreal numbers: left options L and right options R, where every
    element of L is less than every element of R.
    """
    left: FrozenSet[Fraction]
    right: FrozenSet[Fraction]
    
    @property
    def value(self) -> Fraction:
        """Compute the numeric value of this surreal form.
        
        The value is the simplest number strictly between max(L) and min(R).
        """
        if not self.left and not self.right:
            return Fraction(0)
        
        lower = max(self.left) if self.left else None
        upper = min(self.right) if self.right else None
        
        return simplest_between(lower, upper)
    
    @property
    def birthday(self) -> int:
        """Compute the birthday of this surreal form.
        
        The birthday is 1 + max of the birthdays of all options,
        or 0 if there are no options.
        """
        if not self.left and not self.right:
            return 0
        
        max_birthday = 0
        for val in self.left | self.right:
            form = canonical_form(val)
            max_birthday = max(max_birthday, form.birthday)
        
        return max_birthday + 1


@dataclass
class DyadicRational:
    """A dyadic rational number a/2^n.
    
    Represented in normalized form where a is odd (or zero)
    and n is minimal.
    """
    numerator: int
    exponent: int  # denominator is 2^exponent
    
    def __post_init__(self) -> None:
        """Normalize the representation."""
        if self.numerator == 0:
            self.exponent = 0
            return
        while self.numerator % 2 == 0 and self.exponent > 0:
            self.numerator //= 2
            self.exponent -= 1
    
    @property
    def value(self) -> Fraction:
        """Convert to a Fraction."""
        return Fraction(self.numerator, 2 ** self.exponent)
    
    def __add__(self, other: DyadicRational) -> DyadicRational:
        """Add two dyadic rationals: a/2^m + b/2^n = (a·2^n + b·2^m)/2^(m+n)."""
        new_num = (self.numerator * (2 ** other.exponent) + 
                   other.numerator * (2 ** self.exponent))
        new_exp = self.exponent + other.exponent
        return DyadicRational(new_num, new_exp)
    
    def __neg__(self) -> DyadicRational:
        """Negate a dyadic rational."""
        return DyadicRational(-self.numerator, self.exponent)
    
    def __sub__(self, other: DyadicRational) -> DyadicRational:
        """Subtract dyadic rationals."""
        return self + (-other)
    
    def __mul__(self, other: DyadicRational) -> DyadicRational:
        """Multiply dyadic rationals: (a/2^m)·(b/2^n) = (a·b)/2^(m+n)."""
        return DyadicRational(
            self.numerator * other.numerator,
            self.exponent + other.exponent
        )
    
    def __repr__(self) -> str:
        if self.exponent == 0:
            return f"DyadicRational({self.numerator})"
        return f"DyadicRational({self.numerator}/2^{self.exponent})"
    
    @property
    def birthday(self) -> int:
        """Compute the surreal birthday of this dyadic rational.
        
        The birthday of a/2^n in surreal form depends on both the
        magnitude and the precision:
        - Integers n have birthday |n|
        - Half-integers have birthday |floor| + 1
        - In general, birthday = |integer part| + exponent
        """
        return compute_birthday(self.value)


# ============================================================================
# Core Algorithms
# ============================================================================

def simplest_between(lower: Optional[Fraction], 
                     upper: Optional[Fraction]) -> Fraction:
    """Find the simplest number strictly between lower and upper.
    
    The simplest number is the one with the smallest birthday, which
    corresponds to the one with the simplest dyadic representation.
    
    Algorithm:
    1. If 0 is in the interval, return 0 (birthday 0)
    2. If an integer is in the interval, return the smallest such integer
    3. Otherwise, binary search: find the midpoint and recurse
    
    Args:
        lower: Lower bound (None for -infinity)
        upper: Upper bound (None for +infinity)
    
    Returns:
        The simplest number in the open interval (lower, upper)
    """
    # Handle unbounded cases
    if lower is None and upper is None:
        return Fraction(0)
    if lower is None:
        # (-∞, upper): return floor(upper) if upper is not an integer,
        # else upper - 1
        if upper > 0:
            return Fraction(0)
        n = int(upper)
        if Fraction(n) < upper:
            return Fraction(n)
        return Fraction(n - 1)
    if upper is None:
        # (lower, +∞): return ceil(lower) if lower is not an integer,
        # else lower + 1
        if lower < 0:
            return Fraction(0)
        n = int(lower) + 1
        if Fraction(n) > lower:
            return Fraction(n)
        return Fraction(n + 1)
    
    # Both bounds finite
    assert lower < upper, f"Invalid interval: ({lower}, {upper})"
    
    # Check if 0 is in the interval
    if lower < 0 < upper:
        return Fraction(0)
    
    # Check for integers in the interval
    if lower >= 0:
        n = int(lower) + 1
        if Fraction(n) < upper:
            return Fraction(n)
    else:
        n = int(upper)
        if Fraction(n) < upper and Fraction(n) > lower:
            return Fraction(n)
        n -= 1
        if Fraction(n) > lower:
            return Fraction(n)
    
    # Binary search: midpoint
    mid = (lower + upper) / 2
    return mid


def canonical_form(q: Fraction) -> SurrealForm:
    """Compute the canonical surreal form of a rational number.
    
    The canonical form {L | R} has the property that:
    - Every element of L is the largest surreal < q with birthday < birthday(q)
    - Every element of R is the smallest surreal > q with birthday < birthday(q)
    
    For dyadic rationals, this produces a finite form.
    """
    if q == 0:
        return SurrealForm(frozenset(), frozenset())
    
    if q > 0:
        if q == int(q):
            # Integer n > 0: {n-1 | }
            return SurrealForm(
                frozenset({Fraction(int(q) - 1)}),
                frozenset()
            )
        else:
            # Fractional: find the canonical left and right options
            # For a/2^n, left = floor(a/2^n) or the next smaller dyadic
            lower = Fraction(int(q))
            upper = Fraction(int(q) + 1)
            
            # Binary search for tightest bounds
            while True:
                mid = (lower + upper) / 2
                if mid == q:
                    return SurrealForm(
                        frozenset({lower}),
                        frozenset({upper})
                    )
                elif mid < q:
                    lower = mid
                elif mid > q:
                    upper = mid
    
    # q < 0: use symmetry
    pos_form = canonical_form(-q)
    return SurrealForm(
        frozenset({-r for r in pos_form.right}),
        frozenset({-l for l in pos_form.left})
    )


def compute_birthday(q: Fraction) -> int:
    """Compute the surreal birthday of a dyadic rational.
    
    The birthday of q is defined recursively:
    - birthday(0) = 0
    - birthday({L | R}) = 1 + max(max birthday of L, max birthday of R)
    
    For dyadic rationals, this equals the depth in the Stern-Brocot tree.
    """
    if q == 0:
        return 0
    
    form = canonical_form(q)
    max_b = 0
    for v in form.left | form.right:
        max_b = max(max_b, compute_birthday(v))
    return max_b + 1


def surreals_born_by_day(n: int) -> List[Fraction]:
    """Compute all surreal numbers born by day n.
    
    Returns a sorted list of all surreal number values with birthday ≤ n.
    
    The algorithm constructs surreals day by day:
    - Day 0: {0}
    - Day k+1: Add midpoints between all consecutive pairs from day k,
      plus new extremes at the boundaries.
    """
    if n == 0:
        return [Fraction(0)]
    
    prev = surreals_born_by_day(n - 1)
    result = set(prev)
    
    # Boundaries: extend by 1 in each direction
    result.add(prev[0] - 1)
    result.add(prev[-1] + 1)
    
    # Midpoints
    for i in range(len(prev) - 1):
        result.add((prev[i] + prev[i + 1]) / 2)
    
    return sorted(result)


def dyadic_valuation(n: int) -> int:
    """Compute the 2-adic valuation of a nonzero integer.
    
    The 2-adic valuation v_2(n) is the largest power of 2 dividing n.
    """
    if n == 0:
        return float('inf')  # type: ignore
    
    v = 0
    n = abs(n)
    while n % 2 == 0:
        v += 1
        n //= 2
    return v


def is_dyadic_rational(q: Fraction) -> bool:
    """Check if a rational number is a dyadic rational (denominator is a power of 2)."""
    d = q.denominator
    while d > 1:
        if d % 2 != 0:
            return False
        d //= 2
    return True


def dyadic_resolution_at_day(n: int) -> Fraction:
    """Compute the dyadic resolution at birthday level n.
    
    At day n, the finest grid spacing between consecutive surreals is 1/2^(n-1).
    """
    if n == 0:
        return Fraction(0)
    return Fraction(1, 2 ** (n - 1))


# ============================================================================
# Verification Functions
# ============================================================================

def verify_birthday_hierarchy(max_day: int = 6) -> bool:
    """Verify the birthday hierarchy conjecture for small cases.
    
    Checks that:
    1. All surreals born by day n are dyadic rationals
    2. The count matches 2^(n+1) - 1
    3. The resolution matches 1/2^(n-1)
    """
    all_pass = True
    
    for n in range(max_day + 1):
        surreals = surreals_born_by_day(n)
        
        # Check count
        expected_count = 2 ** (n + 1) - 1
        if len(surreals) != expected_count:
            print(f"FAIL: Day {n} has {len(surreals)} surreals, expected {expected_count}")
            all_pass = False
        
        # Check all dyadic
        for q in surreals:
            if not is_dyadic_rational(q):
                print(f"FAIL: {q} at day {n} is not dyadic")
                all_pass = False
        
        # Check resolution
        if n > 0 and len(surreals) > 1:
            min_gap = min(surreals[i+1] - surreals[i] for i in range(len(surreals) - 1))
            expected_res = dyadic_resolution_at_day(n)
            if min_gap != expected_res:
                print(f"FAIL: Day {n} resolution is {min_gap}, expected {expected_res}")
                all_pass = False
    
    return all_pass


if __name__ == "__main__":
    # Demonstrate dyadic rational arithmetic
    print("Dyadic Rational Arithmetic:")
    a = DyadicRational(3, 2)  # 3/4
    b = DyadicRational(5, 3)  # 5/8
    print(f"  a = {a} = {a.value}")
    print(f"  b = {b} = {b.value}")
    print(f"  a + b = {a + b} = {(a + b).value}")
    print(f"  a * b = {a * b} = {(a * b).value}")
    print(f"  a - b = {a - b} = {(a - b).value}")
    print()
    
    # Verify hierarchy
    print("Birthday Hierarchy Verification:")
    result = verify_birthday_hierarchy()
    print(f"Overall: {'PASS' if result else 'FAIL'}")
    print()
    
    # Show canonical forms
    print("Canonical Surreal Forms:")
    for q in [Fraction(0), Fraction(1), Fraction(-1), Fraction(1, 2),
              Fraction(3, 4), Fraction(2)]:
        form = canonical_form(q)
        bday = compute_birthday(q)
        print(f"  {q} = {{{set(form.left)} | {set(form.right)}}}, birthday = {bday}")
