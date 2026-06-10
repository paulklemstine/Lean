#!/usr/bin/env python3
"""
Algorithms for Birthday-Stratified Surreal Arithmetic

Type-hinted implementations of the core algorithms from the research.
"""

from fractions import Fraction
from typing import List, Optional, Tuple, Set
from dataclasses import dataclass
import math


def v2_nat(n: int) -> int:
    """
    2-adic valuation of a positive integer.
    Returns the largest k such that 2^k divides n.
    
    Algorithm: Repeated division by 2.
    Time complexity: O(log n)
    """
    if n <= 0:
        raise ValueError(f"v2_nat requires positive integer, got {n}")
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def v2_int(n: int) -> int:
    """
    2-adic valuation of a nonzero integer.
    Returns the largest k such that 2^k divides |n|.
    """
    if n == 0:
        return float('inf')  # type: ignore
    return v2_nat(abs(n))


def dyadic_valuation(q: Fraction) -> int:
    """
    Dyadic valuation: ν₂(q) = padicValNat(2, q.den).
    
    This is the 2-adic valuation of the denominator in lowest terms.
    For dyadic rationals, this equals the surreal birthday.
    
    Algorithm: Factor out powers of 2 from the denominator.
    Time complexity: O(log(den))
    """
    if q == 0:
        return 0
    return v2_nat(q.denominator)


def is_dyadic_rational(q: Fraction) -> bool:
    """
    Check if q is a dyadic rational (denominator is a power of 2).
    
    Algorithm: Verify denominator has no odd prime factors.
    Time complexity: O(log(den))
    """
    d = q.denominator
    while d % 2 == 0:
        d //= 2
    return d == 1


def birthday_filtration_level(q: Fraction) -> Optional[int]:
    """
    Compute the minimum birthday filtration level for q.
    Returns None if q is not a dyadic rational.
    
    For dyadic q, this equals dyadic_valuation(q).
    """
    if not is_dyadic_rational(q):
        return None
    return dyadic_valuation(q)


def in_birthday_filtration(q: Fraction, n: int) -> bool:
    """
    Check if q ∈ F_n (birthday filtration at level n).
    
    Equivalent to: q.den | 2^n
    """
    return q.denominator % (2 ** n) == 0 or (2 ** n) % q.denominator == 0


def birthday_distance(a: Fraction, b: Fraction) -> int:
    """
    Birthday distance: d(a, b) = ν₂(den(a - b)).
    
    This is an ultrametric on Q satisfying:
    d(a, c) ≤ max(d(a, b), d(b, c))
    """
    return dyadic_valuation(a - b)


@dataclass(frozen=True, order=True)
class ComplexityPair:
    """
    Two-dimensional complexity measure for rational numbers.
    Ordered lexicographically: birthday first, then numerator size.
    """
    birthday: int
    numerator_size: int


def complexity_measure(q: Fraction) -> ComplexityPair:
    """
    Compute the (birthday, |numerator|) complexity of q.
    """
    return ComplexityPair(
        birthday=dyadic_valuation(q),
        numerator_size=abs(q.numerator)
    )


def multiplication_defect(a: Fraction, b: Fraction) -> int:
    """
    Multiplication defect: δ(a, b) = (ν₂(a) + ν₂(b)) - ν₂(a·b).
    
    Measures how much the actual birthday of the product falls below
    the upper bound given by the sum of individual birthdays.
    """
    return dyadic_valuation(a) + dyadic_valuation(b) - dyadic_valuation(a * b)


def predicted_defect(a: Fraction, b: Fraction) -> int:
    """
    Predicted multiplication defect from the revised conjecture:
    δ(a, b) = min(ν₂(|a.num · b.num|), ν₂(a) + ν₂(b))
    
    The min accounts for the fact that cancellation is bounded
    by the total birthday budget.
    """
    num_product = a.numerator * b.numerator
    if num_product == 0:
        return 0
    return min(v2_int(num_product), dyadic_valuation(a) + dyadic_valuation(b))


def enumerate_dyadic_rationals(max_birthday: int,
                                max_numerator: int) -> List[Fraction]:
    """
    Enumerate all dyadic rationals with birthday ≤ max_birthday
    and |numerator| ≤ max_numerator.
    
    Returns a sorted list of distinct fractions.
    """
    result: Set[Fraction] = set()
    for k in range(max_birthday + 1):
        den = 2 ** k
        for num in range(-max_numerator, max_numerator + 1):
            if num == 0:
                continue
            q = Fraction(num, den)
            result.add(q)
    return sorted(result)


def verify_ultrametric_property(points: List[Fraction]) -> Tuple[int, int, List]:
    """
    Verify the ultrametric triangle inequality for all triples.
    
    Returns (total_triples, passing_triples, failing_triples).
    """
    total = 0
    passing = 0
    failures = []
    
    for i, a in enumerate(points):
        for j, b in enumerate(points):
            if j <= i:
                continue
            for k, c in enumerate(points):
                if k <= j:
                    continue
                total += 1
                dac = birthday_distance(a, c)
                dab = birthday_distance(a, b)
                dbc = birthday_distance(b, c)
                if dac <= max(dab, dbc):
                    passing += 1
                else:
                    failures.append((a, b, c, dac, dab, dbc))
    
    return total, passing, failures


def verify_multiplication_defect_conjecture(
    max_birthday: int = 4,
    max_numerator: int = 20
) -> Tuple[int, int, List]:
    """
    Verify the multiplication defect conjecture for a range of dyadics.
    
    Returns (total_pairs, matching_pairs, failures).
    """
    dyadics = enumerate_dyadic_rationals(max_birthday, max_numerator)
    total = 0
    matching = 0
    failures = []
    
    for a in dyadics:
        for b in dyadics:
            total += 1
            actual = multiplication_defect(a, b)
            predicted = predicted_defect(a, b)
            if actual == predicted:
                matching += 1
            else:
                failures.append((a, b, actual, predicted))
    
    return total, matching, failures


def count_dyadics_in_unit_interval(n: int) -> int:
    """
    Count distinct dyadic rationals in [0, 1] with denominator dividing 2^n.
    Formula: 2^n + 1
    """
    return 2 ** n + 1


def new_surreals_at_day(n: int) -> int:
    """
    Count new surreal values appearing at birthday exactly n.
    Formula: 1 if n=0, else 2^n
    """
    return 1 if n == 0 else 2 ** n


if __name__ == "__main__":
    # Quick self-test
    print("Self-tests:")
    
    assert dyadic_valuation(Fraction(0)) == 0
    assert dyadic_valuation(Fraction(1)) == 0
    assert dyadic_valuation(Fraction(1, 2)) == 1
    assert dyadic_valuation(Fraction(3, 8)) == 3
    assert dyadic_valuation(Fraction(5, 16)) == 4
    print("  ✓ Dyadic valuation")
    
    assert is_dyadic_rational(Fraction(3, 8))
    assert not is_dyadic_rational(Fraction(1, 3))
    print("  ✓ Dyadic test")
    
    assert birthday_distance(Fraction(0), Fraction(1, 4)) == 2
    assert birthday_distance(Fraction(1, 2), Fraction(3, 4)) == 2
    print("  ✓ Birthday distance")
    
    total, matching, failures = verify_multiplication_defect_conjecture(4, 20)
    assert len(failures) == 0, f"Conjecture failed: {failures[:3]}"
    print(f"  ✓ Multiplication defect conjecture ({total} pairs)")
    
    print("\nAll tests passed.")
