#!/usr/bin/env python3
"""
Saturating Arithmetic: Algorithms and Data Structures

Type-hinted implementations of saturating arithmetic operations,
the saturation map, and analysis tools.
"""

from typing import Tuple, List, Optional
from dataclasses import dataclass
from math import gcd


@dataclass
class SatNat:
    """A natural number bounded by a capacity N."""
    val: int
    bound: int

    def __post_init__(self):
        assert 0 <= self.val <= self.bound, f"val={self.val} not in [0, {self.bound}]"

    def __repr__(self) -> str:
        return f"SatNat({self.val}, N={self.bound})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SatNat):
            return NotImplemented
        return self.val == other.val and self.bound == other.bound

    def __add__(self, other: 'SatNat') -> 'SatNat':
        assert self.bound == other.bound
        return SatNat(min(self.val + other.val, self.bound), self.bound)

    def __mul__(self, other: 'SatNat') -> 'SatNat':
        assert self.bound == other.bound
        return SatNat(min(self.val * other.val, self.bound), self.bound)

    def is_absorbing(self) -> bool:
        """Check if this element is the absorbing element N."""
        return self.val == self.bound

    def is_additive_idempotent(self) -> bool:
        """Check if x + x = x in saturating arithmetic."""
        result = self + self
        return result.val == self.val

    def is_multiplicative_idempotent(self) -> bool:
        """Check if x * x = x in saturating arithmetic."""
        result = self * self
        return result.val == self.val


def saturating_add(N: int, a: int, b: int) -> int:
    """
    Saturating addition: min(a + b, N).

    Algorithm: O(1) time and space.
    Pseudocode:
        return min(a + b, N)
    """
    return min(a + b, N)


def saturating_mul(N: int, a: int, b: int) -> int:
    """
    Saturating multiplication: min(a * b, N).

    Algorithm: O(1) time and space.
    Pseudocode:
        return min(a * b, N)
    """
    return min(a * b, N)


def saturation_map(N: int, x: int) -> int:
    """
    The saturation map σ_N: ℕ → SatNat N.
    σ_N(x) = min(x, N).

    This is a semiring homomorphism: σ(a+b) = σ(a) ⊕ σ(b)
    and σ(a·b) = σ(a) ⊗ σ(b).
    """
    return min(x, N)


def safe_region_count_add(N: int) -> int:
    """
    Count the number of pairs (a, b) ∈ [0, N]² where
    saturating addition agrees with standard addition.

    The safe region is {(a,b) : a + b ≤ N}, which has
    exactly (N+1)(N+2)/2 elements.

    Algorithm: O(1) by formula.
    """
    return (N + 1) * (N + 2) // 2


def safe_region_density_add(N: int) -> float:
    """
    Density of the safe region for addition.
    Approaches 1/2 as N → ∞.
    """
    return safe_region_count_add(N) / (N + 1) ** 2


def saturation_depth_add(a: int, b: int) -> int:
    """
    Minimum N such that sat_add(N, a, b) = a + b.
    This is the 'arithmetic depth' of the addition a + b.
    """
    return a + b


def saturation_depth_mul(a: int, b: int) -> int:
    """
    Minimum N such that sat_mul(N, a, b) = a * b.
    """
    return a * b


def find_additive_idempotents(N: int) -> List[int]:
    """
    Find all additive idempotents: elements x with sat_add(N, x, x) = x.
    By our theorem, these are exactly {0, N}.

    Algorithm: O(1) by theorem.
    """
    if N == 0:
        return [0]
    return [0, N]


def find_multiplicative_idempotents(N: int) -> List[int]:
    """
    Find all multiplicative idempotents: elements x with sat_mul(N, x, x) = x.
    By our theorem:
    - N = 0: {0}
    - N = 1: {0, 1}
    - N ≥ 2: {0, 1, N}

    Algorithm: O(1) by theorem.
    """
    if N == 0:
        return [0]
    elif N == 1:
        return [0, 1]
    else:
        return [0, 1, N]


def verify_distributivity(N: int) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """
    Exhaustively verify distributivity for SatNat N.
    Returns (True, None) if it holds for all triples, or
    (False, (a, b, c)) for a counterexample.

    Our theorem proves this always returns (True, None),
    but this function serves as a computational sanity check.
    """
    for a in range(N + 1):
        for b in range(N + 1):
            for c in range(N + 1):
                lhs = saturating_mul(N, a, saturating_add(N, b, c))
                rhs = saturating_add(N, saturating_mul(N, a, b), saturating_mul(N, a, c))
                if lhs != rhs:
                    return False, (a, b, c)
    return True, None


def polynomial_safe_bound(coefficients: List[int], degree: int, num_vars: int) -> int:
    """
    Estimate the minimum N such that evaluating a polynomial
    of given degree and coefficients on inputs in [0, K]
    stays within the safe region.

    For a polynomial of degree d with coefficient sum C evaluated
    on inputs ≤ K, the output is ≤ C · K^d. So we need N ≥ C · K^d.
    """
    coeff_sum = sum(abs(c) for c in coefficients)
    # For the polynomial identity to transfer, we need the max evaluation ≤ N
    return coeff_sum  # Base bound; multiply by K^d for inputs in [0, K]


if __name__ == "__main__":
    # Quick self-tests
    N = 10

    # Test SatNat class
    x = SatNat(3, N)
    y = SatNat(4, N)
    z = x + y
    assert z.val == 7, f"Expected 7, got {z.val}"

    x = SatNat(8, N)
    y = SatNat(5, N)
    z = x + y
    assert z.val == N, f"Expected {N}, got {z.val}"

    # Test idempotent classification
    assert find_additive_idempotents(10) == [0, 10]
    assert find_multiplicative_idempotents(10) == [0, 1, 10]

    # Test safe region
    assert safe_region_count_add(10) == 66  # (11)(12)/2

    # Verify distributivity for small N
    for n in range(8):
        ok, _ = verify_distributivity(n)
        assert ok, f"Distributivity failed for N={n}"

    print("All self-tests passed.")
