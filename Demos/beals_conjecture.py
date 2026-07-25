#!/usr/bin/env python3
"""Numerical demonstrations of structural reductions around Beal's conjecture.

The bounded search is evidence only; it does not decide the open conjecture.
All arithmetic is exact and uses only the Python standard library.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from fractions import Fraction
from math import gcd
from typing import DefaultDict, Iterable


@dataclass(frozen=True, order=True)
class Solution:
    """An exact generalized Fermat solution A^x + B^y = C^z."""

    a: int
    b: int
    c: int
    x: int
    y: int
    z: int

    def common_gcd(self) -> int:
        return gcd(gcd(self.a, self.b), self.c)

    def pairwise_gcds(self) -> tuple[int, int, int]:
        return gcd(self.a, self.b), gcd(self.a, self.c), gcd(self.b, self.c)

    def is_primitive(self) -> bool:
        return self.pairwise_gcds() == (1, 1, 1)

    def signature_weight(self) -> Fraction:
        return Fraction(1, self.x) + Fraction(1, self.y) + Fraction(1, self.z)


def bounded_solutions(base_bound: int, exponents: Iterable[int]) -> list[Solution]:
    """Find all ordered solutions in a finite box using a reverse power index."""
    exps = tuple(sorted(set(exponents)))
    if base_bound < 1 or not exps or min(exps) < 1:
        raise ValueError("Use positive bounds and positive exponents")
    right: DefaultDict[int, list[tuple[int, int]]] = defaultdict(list)
    powers: dict[tuple[int, int], int] = {}
    for base in range(1, base_bound + 1):
        for exponent in exps:
            value = base**exponent
            powers[(base, exponent)] = value
            right[value].append((base, exponent))
    found: list[Solution] = []
    for a in range(1, base_bound + 1):
        for x in exps:
            ax = powers[(a, x)]
            for b in range(1, base_bound + 1):
                for y in exps:
                    for c, z in right.get(ax + powers[(b, y)], []):
                        found.append(Solution(a, b, c, x, y, z))
    return sorted(found)


def prime_factors(n: int) -> set[int]:
    """Return the distinct prime factors of a positive integer."""
    if n < 1:
        raise ValueError("n must be positive")
    factors: set[int] = set()
    divisor = 2
    while divisor * divisor <= n:
        while n % divisor == 0:
            factors.add(divisor)
            n //= divisor
        divisor += 1 if divisor == 2 else 2
    if n > 1:
        factors.add(n)
    return factors


def radical(n: int) -> int:
    """Compute the product of the distinct prime factors of n."""
    result = 1
    for prime in prime_factors(n):
        result *= prime
    return result


def fibonacci(n: int) -> int:
    """Compute F_n with F_0 = 0 and F_1 = 1."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demonstrate_known_examples() -> None:
    examples = [
        Solution(2, 2, 2, 3, 3, 4),
        Solution(7, 7, 14, 3, 4, 3),
        Solution(3, 18, 9, 6, 3, 4),
    ]
    print("Representative exact solutions")
    for s in examples:
        assert s.a**s.x + s.b**s.y == s.c**s.z
        assert s.signature_weight() <= 1
        print(
            f"  {s.a}^{s.x} + {s.b}^{s.y} = {s.c}^{s.z}; "
            f"common gcd={s.common_gcd()}, pairwise gcds={s.pairwise_gcds()}, "
            f"signature weight={s.signature_weight()}"
        )


def demonstrate_bounded_search() -> None:
    solutions = bounded_solutions(40, range(3, 7))
    primitive = [s for s in solutions if s.is_primitive()]
    without_common_prime = [s for s in solutions if s.common_gcd() == 1]
    assert len(solutions) == 23
    assert not primitive and not without_common_prime
    assert all((s.common_gcd() == 1) == s.is_primitive() for s in solutions)
    assert all(s.signature_weight() <= 1 for s in solutions)
    print("\nBounded exhaustive search")
    print(f"  ordered solutions: {len(solutions)}")
    print(f"  primitive solutions: {len(primitive)}")
    print(f"  solutions without a common prime: {len(without_common_prime)}")
    print("  This finite result is not a proof of Beal's conjecture.")


def demonstrate_powered_triple_and_radical() -> None:
    # The map and radical identity are illustrated on a known nonprimitive solution.
    s = Solution(7, 7, 14, 3, 4, 3)
    powered = (s.a**s.x, s.b**s.y, s.c**s.z)
    assert powered[0] + powered[1] == powered[2]
    assert radical(powered[0] * powered[1] * powered[2]) == radical(s.a * s.b * s.c)
    print("\nPowered additive triple and prime support")
    print(f"  powered coordinates: {powered}")
    print(f"  radical of powered product: {radical(powered[0] * powered[1] * powered[2])}")
    print(f"  radical of base product:    {radical(s.a * s.b * s.c)}")


def demonstrate_fibonacci_constraint() -> None:
    pairs = [(8, 15), (10, 16), (12, 18), (21, 34)]
    print("\nFibonacci strong-divisibility screen")
    for m, n in pairs:
        g = gcd(m, n)
        lhs = gcd(fibonacci(m), fibonacci(n))
        rhs = fibonacci(g)
        assert lhs == rhs
        admissible = rhs == 1
        print(
            f"  (m,n)=({m},{n}): gcd={g}, gcd(F_m,F_n)=F_g={rhs}; "
            f"primitive-pair necessary condition: {admissible}"
        )


def main() -> None:
    demonstrate_known_examples()
    demonstrate_bounded_search()
    demonstrate_powered_triple_and_radical()
    demonstrate_fibonacci_constraint()


if __name__ == "__main__":
    main()
