#!/usr/bin/env python3
"""
L-Function Census: Core Algorithms

Type-hinted implementations of the combinatorial framework
for cataloging Selberg-class L-functions.
"""

from dataclasses import dataclass, field
from typing import Optional
from math import gcd
from functools import reduce


@dataclass(frozen=True)
class SpectralParam:
    """A spectral parameter (shift, parity) in a gamma factor."""
    shift: int
    parity: int  # 0 or 1

    @property
    def abs_shift(self) -> int:
        return abs(self.shift)


@dataclass(frozen=True)
class SelbergDatum:
    """Invariant data of a Selberg-class L-function.
    
    Encodes the degree, conductor, and spectral parameters
    that together determine an L-function up to finitely many choices.
    """
    degree: int
    conductor: int  # positive integer
    spectral_params: tuple[SpectralParam, ...]

    def __post_init__(self) -> None:
        assert self.conductor >= 1
        assert len(self.spectral_params) == self.degree

    @staticmethod
    def trivial() -> 'SelbergDatum':
        """The trivial datum (L(s) = 1)."""
        return SelbergDatum(degree=0, conductor=1, spectral_params=())

    def product(self, other: 'SelbergDatum') -> 'SelbergDatum':
        """Product of two data (Rankin-Selberg convolution)."""
        return SelbergDatum(
            degree=self.degree + other.degree,
            conductor=self.conductor * other.conductor,
            spectral_params=self.spectral_params + other.spectral_params,
        )

    @property
    def spectral_complexity(self) -> int:
        """Sum of absolute shifts (additive invariant)."""
        return sum(p.abs_shift for p in self.spectral_params)

    @property
    def spectral_weight(self) -> int:
        """Maximum absolute shift."""
        if not self.spectral_params:
            return 0
        return max(p.abs_shift for p in self.spectral_params)

    @property
    def spectral_entropy(self) -> int:
        """Number of distinct absolute shift values."""
        return len(set(p.abs_shift for p in self.spectral_params))

    @property
    def analytic_conductor(self) -> int:
        """Analytic conductor C(F) = q * prod(|mu_j| + 3)."""
        prod = 1
        for p in self.spectral_params:
            prod *= p.abs_shift + 3
        return self.conductor * prod

    def is_primitive(self) -> bool:
        """Check if this datum is primitive (cannot be nontrivially decomposed).
        
        A datum is primitive if degree >= 1 and for any decomposition
        d1 + d2 = degree with q1 * q2 = conductor, one of d1, d2 is 0.
        
        This is a necessary condition; checking spectral parameter
        decomposition would require more structure.
        """
        if self.degree < 1:
            return False
        # Check conductor factorizations
        for d1 in range(1, self.degree):
            d2 = self.degree - d1
            # Check if conductor can be factored correspondingly
            for q1 in range(1, self.conductor + 1):
                if self.conductor % q1 == 0:
                    return False  # Found a nontrivial factorization
        return True


@dataclass(frozen=True)
class DegreeConductor:
    """Simplified invariant: just degree and conductor."""
    degree: int
    conductor: int  # positive integer

    def __le__(self, other: 'DegreeConductor') -> bool:
        return self.degree <= other.degree and other.conductor % self.conductor == 0

    def __lt__(self, other: 'DegreeConductor') -> bool:
        return self <= other and not other <= self

    @staticmethod
    def unit() -> 'DegreeConductor':
        return DegreeConductor(degree=0, conductor=1)

    def product(self, other: 'DegreeConductor') -> 'DegreeConductor':
        return DegreeConductor(
            degree=self.degree + other.degree,
            conductor=self.conductor * other.conductor,
        )

    @property
    def size(self) -> int:
        return self.degree + self.conductor


@dataclass(frozen=True)
class SpectralType:
    """Spectral type: degree + sorted profile of absolute shifts."""
    degree: int
    profile: tuple[int, ...]  # sorted tuple of non-negative integers

    def __post_init__(self) -> None:
        assert len(self.profile) == self.degree
        assert all(self.profile[i] <= self.profile[i+1]
                    for i in range(len(self.profile) - 1))

    @staticmethod
    def unit() -> 'SpectralType':
        return SpectralType(degree=0, profile=())

    def product(self, other: 'SpectralType') -> 'SpectralType':
        merged = tuple(sorted(self.profile + other.profile))
        return SpectralType(
            degree=self.degree + other.degree,
            profile=merged,
        )

    @property
    def complexity(self) -> int:
        """Sum of profile entries."""
        return sum(self.profile)

    @property
    def entropy(self) -> int:
        """Number of distinct values in profile."""
        return len(set(self.profile))


def conductor_count(degree: int, Q: int, B: int) -> int:
    """Count Selberg data with given degree, conductor <= Q, shifts <= B.
    
    N_d(Q, B) = Q * (2*(2B+1))^d
    
    This is exact: Q choices for conductor, and for each of d spectral
    parameters, 2B+1 choices for shift and 2 for parity.
    """
    return Q * ((2 * (2 * B + 1)) ** degree)


def enumerate_data(degree: int, Q: int, B: int) -> list[SelbergDatum]:
    """Enumerate all Selberg data with given constraints.
    
    Warning: exponential in degree! Only use for small parameters.
    """
    if degree == 0:
        return [SelbergDatum.trivial()] * Q

    results: list[SelbergDatum] = []

    def backtrack(params: list[SpectralParam], remaining: int) -> None:
        if remaining == 0:
            for q in range(1, Q + 1):
                results.append(SelbergDatum(
                    degree=degree,
                    conductor=q,
                    spectral_params=tuple(params),
                ))
            return
        for shift in range(-B, B + 1):
            for parity in range(2):
                params.append(SpectralParam(shift=shift, parity=parity))
                backtrack(params, remaining - 1)
                params.pop()

    backtrack([], degree)
    return results


def moebius_function(n: int) -> int:
    """Classical Möbius function μ(n)."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    # Factor n
    result = 1
    temp = n
    for p in range(2, n + 1):
        if p * p > temp:
            break
        if temp % p == 0:
            temp //= p
            if temp % p == 0:
                return 0  # p^2 | n
            result *= -1
    if temp > 1:
        result *= -1
    return result


def primitive_count_estimate(degree: int, Q: int, B: int) -> float:
    """Estimate the number of primitive data using Möbius inversion.
    
    P_d(Q, B) = sum_{k|n, k<=d} μ(d/k) * N_k(Q, B)
    
    This is a rough estimate; the actual Möbius inversion on the
    factorization poset is more complex.
    """
    total = 0.0
    for k in range(1, degree + 1):
        if degree % k == 0:
            total += moebius_function(degree // k) * conductor_count(k, Q, B)
    return total


if __name__ == "__main__":
    # Quick self-test
    t = SelbergDatum.trivial()
    assert t.degree == 0
    assert t.spectral_complexity == 0

    d1 = SelbergDatum(
        degree=2,
        conductor=5,
        spectral_params=(SpectralParam(1, 0), SpectralParam(-2, 1)),
    )
    d2 = SelbergDatum(
        degree=1,
        conductor=3,
        spectral_params=(SpectralParam(0, 0),),
    )
    prod = d1.product(d2)
    assert prod.degree == 3
    assert prod.conductor == 15
    assert prod.spectral_complexity == d1.spectral_complexity + d2.spectral_complexity

    st1 = SpectralType(degree=2, profile=(1, 3))
    st2 = SpectralType(degree=1, profile=(2,))
    stp = st1.product(st2)
    assert stp.complexity == st1.complexity + st2.complexity
    assert stp.entropy <= st1.entropy + st2.entropy

    print("All self-tests passed.")
