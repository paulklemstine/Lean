#!/usr/bin/env python3
"""
Algorithms for Tropical Spectral Algebra of Selberg Data

Type-hinted implementations of the core algorithms from the research.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple, Iterator
import math


# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class SelbergDatum:
    """Invariant data of a Selberg-class L-function.

    Attributes:
        degree: Degree of the gamma factor (non-negative integer)
        conductor: Arithmetic conductor (positive integer)
        spectral_dim: Dimension of spectral parameter space
    """
    degree: int
    conductor: int
    spectral_dim: int

    def __post_init__(self) -> None:
        assert self.conductor > 0
        assert self.degree >= 0
        assert self.spectral_dim >= 0

    def product(self, other: SelbergDatum) -> SelbergDatum:
        """Rankin-Selberg product of Selberg data."""
        return SelbergDatum(
            degree=self.degree + other.degree,
            conductor=self.conductor * other.conductor,
            spectral_dim=self.spectral_dim + other.spectral_dim,
        )

    def spectral_complexity(self) -> int:
        """Spectral complexity (tropical valuation)."""
        return self.degree + self.spectral_dim

    def spectral_entropy(self) -> float:
        """Spectral entropy: log2(conductor) * degree + spectral_dim."""
        if self.conductor <= 1:
            return float(self.spectral_dim)
        return math.log2(self.conductor) * self.degree + self.spectral_dim


@dataclass(frozen=True)
class TropicalNat:
    """Element of the min-plus tropical semiring on ℕ∞.

    val = None represents ∞ (tropical zero).
    val = 0 represents the tropical multiplicative identity.
    """
    val: Optional[int]

    @staticmethod
    def zero() -> TropicalNat:
        """Tropical additive identity (∞)."""
        return TropicalNat(val=None)

    @staticmethod
    def one() -> TropicalNat:
        """Tropical multiplicative identity (0)."""
        return TropicalNat(val=0)

    def tadd(self, other: TropicalNat) -> TropicalNat:
        """Tropical addition: min."""
        if self.val is None:
            return other
        if other.val is None:
            return self
        return TropicalNat(val=min(self.val, other.val))

    def tmul(self, other: TropicalNat) -> TropicalNat:
        """Tropical multiplication: addition in ℕ∞."""
        if self.val is None or other.val is None:
            return TropicalNat.zero()
        return TropicalNat(val=self.val + other.val)

    def __repr__(self) -> str:
        return "∞" if self.val is None else str(self.val)


# ============================================================
# Algorithm 1: Counting Bound
# ============================================================

def counting_bound(d: int, Q: int, B: int) -> int:
    """Compute N_d(Q, B) = Q * (2*(2*B+1))^d.

    Counts the number of Selberg data with given degree d,
    conductor ≤ Q, and spectral parameters bounded by B.

    Time complexity: O(d) for exponentiation.
    """
    return Q * (2 * (2 * B + 1)) ** d


def counting_bound_factored(d1: int, d2: int, Q: int, B: int) -> Tuple[int, int]:
    """Compute the factored form of the counting bound.

    Returns (N_{d1}(1,B), N_{d2}(Q,B)) such that
    N_{d1+d2}(Q,B) = N_{d1}(1,B) * N_{d2}(Q,B).
    """
    return counting_bound(d1, 1, B), counting_bound(d2, Q, B)


# ============================================================
# Algorithm 2: Tropical Valuation
# ============================================================

def tropical_val(s: SelbergDatum) -> TropicalNat:
    """Map a Selberg datum to its tropical valuation.

    This is a monoid homomorphism from (SelbergData, ·) to (ℕ∞, ⊙).
    Satisfies: tropical_val(S1 · S2) = tropical_val(S1) ⊙ tropical_val(S2).
    """
    return TropicalNat(val=s.spectral_complexity())


# ============================================================
# Algorithm 3: Factorization Enumeration
# ============================================================

def divisors(n: int) -> List[int]:
    """Return sorted list of positive divisors of n."""
    divs: List[int] = []
    for i in range(1, int(math.isqrt(n)) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def enumerate_factorizations(
    s: SelbergDatum,
) -> Iterator[Tuple[SelbergDatum, SelbergDatum]]:
    """Enumerate all non-trivial factorizations S = S1 · S2.

    A factorization is non-trivial if both factors have degree > 0.

    Yields pairs (S1, S2) with S1.degree > 0, S2.degree > 0,
    and S1 · S2 = S (component-wise).

    Time complexity: O(d * tau(q) * k) where tau(q) is the number
    of divisors of the conductor.
    """
    for d1 in range(1, s.degree):
        d2 = s.degree - d1
        for q1 in divisors(s.conductor):
            q2 = s.conductor // q1
            for k1 in range(s.spectral_dim + 1):
                k2 = s.spectral_dim - k1
                yield (
                    SelbergDatum(d1, q1, k1),
                    SelbergDatum(d2, q2, k2),
                )


def is_irreducible(s: SelbergDatum) -> bool:
    """Check if a Selberg datum is irreducible.

    A datum is irreducible if it has degree > 0 and no non-trivial
    factorization. Degree-0 data are units, not irreducible.
    """
    if s.degree == 0:
        return False
    return not any(True for _ in enumerate_factorizations(s))


# ============================================================
# Algorithm 4: Irreducible Census
# ============================================================

def census_irreducible(
    max_degree: int, max_conductor: int, max_spectral: int
) -> List[SelbergDatum]:
    """Enumerate all irreducible Selberg data within bounds.

    Returns a list of all irreducible data with:
    - 1 ≤ degree ≤ max_degree
    - 1 ≤ conductor ≤ max_conductor
    - 0 ≤ spectral_dim ≤ max_spectral
    """
    result: List[SelbergDatum] = []
    for d in range(1, max_degree + 1):
        for q in range(1, max_conductor + 1):
            for k in range(max_spectral + 1):
                s = SelbergDatum(d, q, k)
                if is_irreducible(s):
                    result.append(s)
    return result


# ============================================================
# Algorithm 5: Realization Density Estimation
# ============================================================

def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(math.isqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def dim_S2_new_prime(p: int) -> int:
    """Dimension of S_2^new(Gamma_0(p)) for prime p.

    For prime level p, all forms are newforms, so
    dim S_2^new(Gamma_0(p)) = genus(X_0(p)).

    Uses the standard genus formula for Gamma_0(p).
    """
    if p <= 1:
        return 0

    def legendre(a: int, p: int) -> int:
        if a % p == 0:
            return 0
        ls = pow(a, (p - 1) // 2, p)
        return -1 if ls == p - 1 else ls

    # For prime p: genus = (p-1)/12 - corrections
    # g = floor((p-1)/12) for p ≡ 1 (mod 12)
    # with corrections for elliptic fixed points
    e2 = 1 + legendre(-1, p)  # 0 or 2
    e3 = 1 + legendre(-3, p)  # 0 or 2

    # Standard formula: g = 1 + (p+1)/12 - e2/4 - e3/3 - 1
    # = (p+1)/12 - e2/4 - e3/3
    # In integer arithmetic:
    g = (p + 1) // 12
    # Subtract elliptic corrections (these are 0 or 1 in practice)
    if e2 == 2:
        g -= 0  # floor adjustment already handles this
    if e3 == 2:
        g -= 0

    # More precise: use the exact formula
    # 12*g = p + 1 - 3*e2 - 4*e3 - 12*(c-1) where c=2 cusps
    # 12*g = p + 1 - 3*e2 - 4*e3 - 12
    # g = (p - 11 - 3*e2 - 4*e3) / 12
    # But this gives non-integer; use floor
    numerator = p - 11 - 3 * e2 - 4 * e3
    if numerator < 0:
        return 0
    return max(0, (p + 1 - 3 * e2 - 4 * e3) // 12)


def realization_density_degree2(Q: int) -> Tuple[int, int]:
    """Count realized vs total prime conductors up to Q for degree 2.

    Returns (realized, total) where realized is the number of primes
    p ≤ Q with dim S_2^new(Gamma_0(p)) > 0.
    """
    primes = sieve_primes(Q)
    realized = sum(1 for p in primes if dim_S2_new_prime(p) > 0)
    return realized, len(primes)


if __name__ == "__main__":
    # Quick verification
    s1 = SelbergDatum(1, 5, 0)
    s2 = SelbergDatum(2, 7, 1)
    s12 = s1.product(s2)
    assert s12 == SelbergDatum(3, 35, 1)
    assert s12.spectral_complexity() == s1.spectral_complexity() + s2.spectral_complexity()

    # Tropical valuation is multiplicative
    v1 = tropical_val(s1)
    v2 = tropical_val(s2)
    v12 = tropical_val(s12)
    assert v12.val == v1.tmul(v2).val

    # Counting bound factorization
    assert counting_bound(3, 10, 2) == counting_bound(1, 1, 2) * counting_bound(2, 10, 2)

    # Realization density
    r, t = realization_density_degree2(1000)
    print(f"Degree 2 realization: {r}/{t} primes up to 1000 ({100*r/t:.1f}%)")

    print("All algorithm tests passed.")
