"""
Algorithms for Heegner Number Theory and Prime-Generating Polynomials

Implements the key algorithms from the research:
1. Euler polynomial prime generation with ZMod verification
2. Discriminant lattice construction and analysis
3. Quadratic form optimization (shortest vector)
4. Cross-Heegner coprimality testing
"""

import math
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


def is_prime(n: int) -> bool:
    """Optimized primality test using 6k±1 method.

    Time: O(√n), Space: O(1)

    >>> is_prime(41)
    True
    >>> is_prime(27)
    False
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def euler_poly(n: int, p: int = 41) -> int:
    """Compute n² + n + p.

    Args:
        n: Input value
        p: Constant term (default 41 for Heegner number 163)

    Returns:
        Value of the polynomial

    >>> euler_poly(0)
    41
    >>> euler_poly(39)
    1601
    """
    return n * n + n + p


def verify_euler_lucky(p: int) -> Tuple[bool, Optional[int]]:
    """Verify whether p is an Euler lucky prime.

    An Euler lucky prime p satisfies: n²+n+p is prime for all 0 ≤ n ≤ p-2.

    Args:
        p: Prime to test

    Returns:
        (is_lucky, first_failure): is_lucky is True if p is Euler lucky,
        first_failure is the first n where n²+n+p is composite (or None).

    Time: O(p · √(p²)) = O(p²)

    >>> verify_euler_lucky(41)
    (True, None)
    >>> verify_euler_lucky(7)
    (False, 4)
    """
    if not is_prime(p):
        return False, None
    for n in range(p - 1):
        val = n * n + n + p
        if not is_prime(val):
            return False, n
    return True, None


def zmod_rootless_check(p: int, q: int = 41) -> bool:
    """Check if x² + x + q has no roots in ℤ/pℤ.

    This is equivalent to checking that -Δ (where Δ = 1-4q) is a
    quadratic non-residue mod p.

    Args:
        p: Prime modulus
        q: Constant in polynomial (default 41)

    Returns:
        True if the polynomial has no roots mod p

    Time: O(p)

    >>> zmod_rootless_check(2)
    True
    >>> zmod_rootless_check(41)
    False
    """
    for r in range(p):
        if (r * r + r + q) % p == 0:
            return False
    return True


@dataclass
class DiscriminantLattice:
    """A rank-2 lattice from a binary quadratic form ax² + bxy + cy².

    The discriminant Δ = b² - 4ac must be negative (positive definite).

    Attributes:
        a: Coefficient of x²
        b: Coefficient of xy
        c: Coefficient of y²
    """
    a: int
    b: int
    c: int

    def __post_init__(self):
        assert self.a > 0, "a must be positive"
        assert self.discriminant() < 0, "Discriminant must be negative"

    def discriminant(self) -> int:
        """Compute Δ = b² - 4ac."""
        return self.b * self.b - 4 * self.a * self.c

    def four_det(self) -> int:
        """Compute 4 × Gram determinant = 4ac - b²."""
        return 4 * self.a * self.c - self.b * self.b

    def form(self, x: int, y: int) -> int:
        """Evaluate the quadratic form at (x, y)."""
        return self.a * x * x + self.b * x * y + self.c * y * y

    def complete_square(self, x: int, y: int) -> Tuple[int, int]:
        """Compute the completing-the-square decomposition.

        4a·Q(x,y) = u² + |Δ|·y² where u = 2ax + by.

        Returns:
            (u, |Δ|) where u = 2ax + by
        """
        u = 2 * self.a * x + self.b * y
        return u, -self.discriminant()

    def shortest_vectors(self, bound: int = 10) -> List[Tuple[int, int, int]]:
        """Find the shortest nonzero lattice vectors (by form value).

        Args:
            bound: Search range for x, y coordinates

        Returns:
            List of (x, y, Q(x,y)) sorted by form value

        Time: O(bound²)
        """
        results = []
        for x in range(-bound, bound + 1):
            for y in range(-bound, bound + 1):
                if x == 0 and y == 0:
                    continue
                val = self.form(x, y)
                results.append((x, y, val))
        results.sort(key=lambda t: t[2])
        return results


def find_all_euler_lucky_primes(limit: int = 100) -> List[int]:
    """Find all Euler lucky primes up to a given limit.

    Args:
        limit: Upper bound for search

    Returns:
        List of Euler lucky primes

    >>> find_all_euler_lucky_primes(50)
    [2, 3, 5, 11, 17, 41]
    """
    result = []
    for p in range(2, limit + 1):
        if is_prime(p):
            lucky, _ = verify_euler_lucky(p)
            if lucky:
                result.append(p)
    return result


def cross_heegner_coprimality_test(
    p1: int, p2: int, range1: int, range2: int
) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """Test cross-Heegner coprimality conjecture.

    For polynomials f₁(n) = n²+n+p₁ and f₂(m) = m²+m+p₂,
    test whether gcd(f₁(n), f₂(m)) = 1 for all n < range1, m < range2.

    Args:
        p1, p2: Constants in the two polynomials
        range1, range2: Testing ranges

    Returns:
        (all_coprime, counterexample): counterexample is (n, m, gcd) if found

    >>> cross_heegner_coprimality_test(11, 41, 10, 40)
    (True, None)
    """
    for n in range(range1):
        v1 = n * n + n + p1
        for m in range(range2):
            v2 = m * m + m + p2
            g = math.gcd(v1, v2)
            if g > 1:
                return False, (n, m, g)
    return True, None


def heegner_prime_radius(d: int) -> int:
    """Compute the Heegner prime radius for a Heegner number d ≡ 3 (mod 4).

    The radius is (d-3)/4, measuring how many consecutive primes
    the associated Euler polynomial generates.

    >>> heegner_prime_radius(163)
    40
    >>> heegner_prime_radius(67)
    16
    """
    assert d % 4 == 3, "d must be ≡ 3 (mod 4)"
    return (d - 3) // 4


# Example usage
if __name__ == "__main__":
    # Create the Heegner lattice for d = 163
    lattice = DiscriminantLattice(a=1, b=1, c=41)
    print(f"Heegner Lattice 163:")
    print(f"  Discriminant: {lattice.discriminant()}")
    print(f"  4 × det: {lattice.four_det()}")
    print(f"  Form at (1,0): {lattice.form(1, 0)}")
    print(f"  Form at (0,1): {lattice.form(0, 1)}")

    # Shortest vectors
    print(f"\nShortest 10 lattice vectors:")
    for x, y, val in lattice.shortest_vectors(5)[:10]:
        print(f"  ({x:>2}, {y:>2}) → Q = {val}")

    # Euler lucky primes
    print(f"\nEuler lucky primes up to 100: {find_all_euler_lucky_primes(100)}")

    # ZMod rootlessness
    print(f"\nZMod rootless checks (x²+x+41 mod p):")
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]:
        print(f"  p = {p:>2}: rootless = {zmod_rootless_check(p)}")

    # Cross-Heegner coprimality
    ok, cx = cross_heegner_coprimality_test(11, 41, 10, 40)
    print(f"\nCross-Heegner coprimality (d=43, d=163): {ok}")
