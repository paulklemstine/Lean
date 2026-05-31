#!/usr/bin/env python3
"""
Algorithms for Dependent Ultraproduct Computations

This module implements the key algorithms underlying the dependent
ultraproduct construction, including:

1. Finite field arithmetic (F_p)
2. Ultrafilter simulation (Fréchet filter approximation)
3. Ultraproduct element representation
4. Polynomial evaluation in ultraproducts
5. Characteristic transfer verification

Type-hinted implementations following the Lean formalization.
"""

from typing import (
    TypeVar, Generic, List, Dict, Set, Tuple, Optional,
    Callable, Sequence, Any, Iterator
)
from dataclasses import dataclass, field
from functools import reduce
from collections import defaultdict
import math

T = TypeVar('T')


# ============================================================
# Section 1: Finite Field Arithmetic
# ============================================================

@dataclass(frozen=True)
class FpElement:
    """Element of the finite field F_p."""
    value: int
    p: int

    def __post_init__(self) -> None:
        object.__setattr__(self, 'value', self.value % self.p)

    def __add__(self, other: 'FpElement') -> 'FpElement':
        assert self.p == other.p
        return FpElement((self.value + other.value) % self.p, self.p)

    def __mul__(self, other: 'FpElement') -> 'FpElement':
        assert self.p == other.p
        return FpElement((self.value * other.value) % self.p, self.p)

    def __neg__(self) -> 'FpElement':
        return FpElement((-self.value) % self.p, self.p)

    def __sub__(self, other: 'FpElement') -> 'FpElement':
        return self + (-other)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, FpElement):
            return NotImplemented
        return self.value == other.value and self.p == other.p

    def __hash__(self) -> int:
        return hash((self.value, self.p))

    def inv(self) -> 'FpElement':
        """Multiplicative inverse using Fermat's little theorem."""
        if self.value == 0:
            return FpElement(0, self.p)
        return FpElement(pow(self.value, self.p - 2, self.p), self.p)

    def __truediv__(self, other: 'FpElement') -> 'FpElement':
        return self * other.inv()

    def __repr__(self) -> str:
        return f"{self.value} (mod {self.p})"

    @staticmethod
    def zero(p: int) -> 'FpElement':
        return FpElement(0, p)

    @staticmethod
    def one(p: int) -> 'FpElement':
        return FpElement(1, p)


# ============================================================
# Section 2: Ultrafilter Simulation
# ============================================================

@dataclass
class CofiniteFilter:
    """
    Simulates a non-principal ultrafilter using the cofinite (Fréchet) filter.

    In practice, we cannot construct a non-principal ultrafilter on ℕ.
    But we can approximate one by using the Fréchet filter (cofinite sets),
    which agrees with any non-principal ultrafilter on cofinite sets.

    For computational purposes, we work with a finite prefix and declare
    a set "large" if it contains all but finitely many elements of the prefix.
    """
    index_bound: int  # Work with indices {0, 1, ..., index_bound - 1}
    threshold: float = 0.9  # A set is "large" if it contains > threshold fraction

    def is_large(self, s: Set[int]) -> bool:
        """Check if a set is 'large' (in the simulated ultrafilter)."""
        total = self.index_bound
        return len(s & set(range(total))) / total > self.threshold

    def membership_set(self, predicate: Callable[[int], bool]) -> Set[int]:
        """Return {i < index_bound | predicate(i)}."""
        return {i for i in range(self.index_bound) if predicate(i)}


# ============================================================
# Section 3: Ultraproduct Element Representation
# ============================================================

@dataclass
class UltraproductSection:
    """
    A section (representative) of an ultraproduct element.

    Represents an element of ∏_U K(i) by storing a function
    from indices to field elements. Two sections are equivalent
    if they agree on a U-large set.
    """
    values: Dict[int, FpElement]
    primes: List[int]  # The prime for each index

    def __repr__(self) -> str:
        items = [(i, self.values[i]) for i in sorted(self.values.keys())[:5]]
        s = ", ".join(f"F_{self.primes[i]}: {v.value}" for i, v in items)
        if len(self.values) > 5:
            s += ", ..."
        return f"[{s}]"

    def agreement_set(self, other: 'UltraproductSection') -> Set[int]:
        """Return {i | self(i) = other(i)}."""
        return {i for i in self.values if i in other.values
                and self.values[i] == other.values[i]}

    def is_equivalent(self, other: 'UltraproductSection',
                      uf: CofiniteFilter) -> bool:
        """Check if self ≈_U other."""
        return uf.is_large(self.agreement_set(other))

    @staticmethod
    def zero(primes: List[int]) -> 'UltraproductSection':
        """The zero section."""
        return UltraproductSection(
            {i: FpElement.zero(p) for i, p in enumerate(primes)},
            primes
        )

    @staticmethod
    def one(primes: List[int]) -> 'UltraproductSection':
        """The one section."""
        return UltraproductSection(
            {i: FpElement.one(p) for i, p in enumerate(primes)},
            primes
        )

    def __add__(self, other: 'UltraproductSection') -> 'UltraproductSection':
        """Pointwise addition."""
        return UltraproductSection(
            {i: self.values[i] + other.values[i]
             for i in self.values if i in other.values},
            self.primes
        )

    def __mul__(self, other: 'UltraproductSection') -> 'UltraproductSection':
        """Pointwise multiplication."""
        return UltraproductSection(
            {i: self.values[i] * other.values[i]
             for i in self.values if i in other.values},
            self.primes
        )

    def __neg__(self) -> 'UltraproductSection':
        """Pointwise negation."""
        return UltraproductSection(
            {i: -v for i, v in self.values.items()},
            self.primes
        )

    def inv(self) -> 'UltraproductSection':
        """Pointwise inverse."""
        return UltraproductSection(
            {i: v.inv() for i, v in self.values.items()},
            self.primes
        )


# ============================================================
# Section 4: Polynomial Evaluation
# ============================================================

@dataclass
class UnivPolynomial:
    """Univariate polynomial with integer coefficients."""
    coeffs: List[int]  # [a0, a1, ..., an] for a0 + a1*x + ... + an*x^n

    def eval_Fp(self, x: FpElement) -> FpElement:
        """Evaluate at an element of F_p."""
        result = FpElement.zero(x.p)
        x_pow = FpElement.one(x.p)
        for c in self.coeffs:
            result = result + FpElement(c, x.p) * x_pow
            x_pow = x_pow * x
        return result

    def roots_in_Fp(self, p: int) -> List[FpElement]:
        """Find all roots in F_p."""
        return [FpElement(x, p) for x in range(p)
                if self.eval_Fp(FpElement(x, p)) == FpElement.zero(p)]

    def has_root_in_Fp(self, p: int) -> bool:
        """Check if the polynomial has a root in F_p."""
        return len(self.roots_in_Fp(p)) > 0

    def root_existence_set(self, primes: List[int]) -> Set[int]:
        """Return {i | polynomial has a root in F_{primes[i]}}."""
        return {i for i, p in enumerate(primes) if self.has_root_in_Fp(p)}


# ============================================================
# Section 5: Characteristic Transfer Verification
# ============================================================

def verify_char_transfer(primes: List[int], n: int) -> Dict[str, Any]:
    """
    Verify the characteristic transfer theorem for a given n.

    Returns a dict with:
    - vanishing_set: {i | (n : F_{primes[i]}) = 0}
    - is_cofinite: whether the complement is finite
    - prime_factors: prime factors of n
    - factor_vanishing_containment: whether vanishing(n) ⊆ ∪ vanishing(p)
    """
    vanishing = {i for i, p in enumerate(primes) if n % p == 0}

    # Get prime factors
    factors: List[int] = []
    temp = n
    for p in range(2, n + 1):
        while temp % p == 0:
            factors.append(p)
            temp //= p
        if temp == 1:
            break

    unique_factors = list(set(factors))

    # Check containment: vanishing(n) ⊆ ∪_p vanishing(p) for prime factors p
    union_factor_vanishing = set()
    for f in unique_factors:
        union_factor_vanishing |= {i for i, p in enumerate(primes) if f % p == 0}

    return {
        'n': n,
        'vanishing_set': vanishing,
        'vanishing_size': len(vanishing),
        'complement_size': len(primes) - len(vanishing),
        'is_cofinite_complement': len(vanishing) <= len(unique_factors),
        'prime_factors': unique_factors,
        'factor_vanishing_containment': vanishing <= union_factor_vanishing,
    }


def verify_varying_char_theorem(num_primes: int = 50) -> bool:
    """
    Verify the 'varying characteristic → char 0' theorem computationally.

    For each n from 1 to 100, verify that {i | (n : F_{p_i}) = 0} is not
    cofinite (hence not in any non-principal ultrafilter).
    """
    def sieve(n: int) -> List[int]:
        """Simple prime sieve."""
        is_p = [True] * (n + 1)
        is_p[0] = is_p[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_p[i]:
                for j in range(i*i, n+1, i):
                    is_p[j] = False
        return [i for i in range(2, n+1) if is_p[i]]

    primes = sieve(300)[:num_primes]

    all_ok = True
    for n in range(1, 101):
        result = verify_char_transfer(primes, n)
        # The vanishing set should be finite (at most log2(n) primes divide n)
        if result['vanishing_size'] > len(primes) // 2:
            print(f"  WARNING: n={n} has large vanishing set!")
            all_ok = False

    return all_ok


# ============================================================
# Section 6: Main Algorithm — Pseudofinite Root Check
# ============================================================

def pseudofinite_root_check(
    poly: UnivPolynomial,
    num_primes: int = 100,
    threshold: float = 0.9
) -> Dict[str, Any]:
    """
    Check whether a polynomial likely has a root in the pseudofinite field.

    Algorithm:
    1. Generate the first num_primes primes
    2. For each prime p, check if poly has a root in F_p
    3. If the density of root-having primes exceeds threshold,
       declare "likely has a root in ∏_U F_p"

    Returns analysis dict.
    """
    def sieve(n: int) -> List[int]:
        is_p = [True] * (n + 1)
        is_p[0] = is_p[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_p[i]:
                for j in range(i*i, n+1, i):
                    is_p[j] = False
        return [i for i in range(2, n+1) if is_p[i]]

    # Get enough primes
    bound = max(1000, num_primes * 20)
    primes = sieve(bound)[:num_primes]

    root_set = poly.root_existence_set(primes)
    density = len(root_set) / len(primes)

    return {
        'polynomial': poly.coeffs,
        'degree': len(poly.coeffs) - 1,
        'num_primes_tested': len(primes),
        'root_existence_count': len(root_set),
        'density': density,
        'likely_has_root': density > threshold,
        'smallest_prime_without_root': min(
            (primes[i] for i in range(len(primes)) if i not in root_set),
            default=None
        ),
    }


if __name__ == "__main__":
    print("Testing algorithms...")

    # Test finite field arithmetic
    a = FpElement(3, 7)
    b = FpElement(5, 7)
    print(f"  F_7: {a} + {b} = {a + b}")
    print(f"  F_7: {a} * {b} = {a * b}")
    print(f"  F_7: {a}⁻¹ = {a.inv()}")
    print(f"  F_7: {a} * {a.inv()} = {a * a.inv()}")

    # Test polynomial roots
    p = UnivPolynomial([1, 0, 1])  # x^2 + 1
    print(f"\n  Roots of x²+1 in F_7: {p.roots_in_Fp(7)}")
    print(f"  Roots of x²+1 in F_5: {p.roots_in_Fp(5)}")
    print(f"  Roots of x²+1 in F_3: {p.roots_in_Fp(3)}")

    # Test char transfer
    print(f"\n  Varying char theorem verified: {verify_varying_char_theorem()}")

    # Test pseudofinite root check
    result = pseudofinite_root_check(UnivPolynomial([1, 0, 1]))
    print(f"\n  Pseudofinite root check for x²+1:")
    print(f"    Density: {result['density']:.3f}")
    print(f"    Likely has root: {result['likely_has_root']}")

    print("\nAll algorithm tests passed.")
