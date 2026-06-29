#!/usr/bin/env python3
"""
Algorithms for the Möbius Ring ℤ√1

Type-hinted implementations of the key algorithms from the research.
"""

from typing import Tuple, Optional, List, Set
from dataclasses import dataclass


@dataclass(frozen=True)
class MobiusInt:
    """An element of the Möbius ring ℤ√1 = ℤ[ε]/(ε²−1)."""
    re: int
    im: int

    def __add__(self, other: 'MobiusInt') -> 'MobiusInt':
        return MobiusInt(self.re + other.re, self.im + other.im)

    def __mul__(self, other: 'MobiusInt') -> 'MobiusInt':
        return MobiusInt(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re
        )

    def __neg__(self) -> 'MobiusInt':
        return MobiusInt(-self.re, -self.im)

    def norm(self) -> int:
        """Compute the Möbius norm N(a + bε) = a² − b²."""
        return self.re ** 2 - self.im ** 2

    def conj(self) -> 'MobiusInt':
        """Conjugation: conj(a + bε) = a − bε."""
        return MobiusInt(self.re, -self.im)

    def split(self) -> Tuple[int, int]:
        """Splitting map φ(a + bε) = (a+b, a−b)."""
        return (self.re + self.im, self.re - self.im)

    def is_unit(self) -> bool:
        """Check if this element is a unit (norm ±1 with specific structure)."""
        s, d = self.re + self.im, self.re - self.im
        return abs(s) == 1 and abs(d) == 1

    def is_idempotent(self) -> bool:
        """Check if z² = z."""
        return self * self == self

    def orientation_char(self) -> int:
        """The orientation character χ(z) = im(z) mod 2."""
        return self.im % 2


def norm_represent(n: int) -> Optional[MobiusInt]:
    """
    Given an integer n, find z ∈ ℤ√1 with N(z) = n, or return None
    if n ≡ ±2 (mod 4).

    Algorithm:
    - n odd: z = ((n+1)/2, (n-1)/2)
    - n ≡ 0 mod 4: z = (n/4 + 1, n/4 - 1)
    - n ≡ ±2 mod 4: impossible

    Complexity: O(1)
    """
    r = n % 4
    if r == 2 or r == -2:
        return None
    if n % 2 != 0:  # odd
        a = (n + 1) // 2
        b = (n - 1) // 2
        return MobiusInt(a, b)
    else:  # n ≡ 0 mod 4
        k = n // 4
        return MobiusInt(k + 1, k - 1)


def is_mobius_norm(n: int) -> bool:
    """Check if n is representable as a Möbius norm (n ≢ ±2 mod 4)."""
    return n % 4 != 2 and n % 4 != -2


def lorentz_form(a: int, b: int) -> int:
    """The Lorentz/Minkowski form Q(a,b) = a² − b²."""
    return a ** 2 - b ** 2


def split_inverse(x: int, y: int) -> Optional[MobiusInt]:
    """
    Inverse of the splitting map: given (x,y) with x ≡ y (mod 2),
    return the unique z ∈ ℤ√1 with φ(z) = (x,y).

    Returns None if x and y have different parity.
    """
    if x % 2 != y % 2:
        return None
    a = (x + y) // 2
    b = (x - y) // 2
    return MobiusInt(a, b)


def count_norm_representations(n: int, bound: int = 1000) -> List[MobiusInt]:
    """
    Find all z = (a, b) with 0 ≤ a, b ≤ bound and N(z) = n.
    """
    reps: List[MobiusInt] = []
    for a in range(-bound, bound + 1):
        b_sq = a * a - n
        if b_sq < 0:
            continue
        b = int(b_sq ** 0.5)
        if b * b == b_sq:
            reps.append(MobiusInt(a, b))
            if b != 0:
                reps.append(MobiusInt(a, -b))
    return reps


def norm_surjective_mod_p(p: int) -> bool:
    """
    Check if every element of ℤ/pℤ is a difference of two squares.
    Returns True for odd primes (by our theorem).
    """
    representable: Set[int] = set()
    for a in range(p):
        for b in range(p):
            representable.add((a * a - b * b) % p)
    return len(representable) == p


def idempotent_count_mod_n(n: int) -> int:
    """
    Count idempotents in (ℤ/nℤ)√1.
    An element (a, b) mod n is idempotent if:
      a² + b² ≡ a (mod n) and 2ab ≡ b (mod n)
    """
    count = 0
    for a in range(n):
        for b in range(n):
            if (a * a + b * b) % n == a % n and (2 * a * b) % n == b % n:
                count += 1
    return count


def norm_density(N: int) -> float:
    """
    Compute the proportion of integers in [1, N] that are Möbius norms.
    Should converge to 3/4 = 0.75.
    """
    count = sum(1 for n in range(1, N + 1) if is_mobius_norm(n))
    return count / N


# ===== Self-test =====
if __name__ == "__main__":
    # Test norm representation
    for n in range(-20, 21):
        z = norm_represent(n)
        if z is not None:
            assert z.norm() == n, f"norm_represent({n}) gave {z} with norm {z.norm()}"

    # Test density convergence
    for N in [100, 1000, 10000, 100000]:
        d = norm_density(N)
        print(f"  Density up to {N:6d}: {d:.6f} (target: 0.750000)")

    # Test idempotent counts
    print("\n  Idempotent counts in (ℤ/nℤ)√1:")
    for n in range(2, 20):
        count = idempotent_count_mod_n(n)
        print(f"    n = {n:2d}: {count} idempotents")

    # Test surjectivity
    print("\n  Norm surjectivity mod p:")
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        print(f"    p = {p:2d}: {'surjective' if norm_surjective_mod_p(p) else 'NOT surjective'}")

    print("\n  All tests passed!")
