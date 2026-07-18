#!/usr/bin/env python3
"""Numerical demonstrations of the root–fixed-point incidence bridge.

The polynomial routines work over prime fields F_p.  They enumerate monic
polynomials X^n + sum_i a_i X^i, count distinct roots in F_p, and compare the
total with p^n.  The permutation routines independently count fixed points.
"""

from __future__ import annotations

from collections import Counter
from itertools import permutations, product
from math import factorial
from typing import Dict, Iterable, Iterator, Sequence, Tuple

CoefficientVector = Tuple[int, ...]


def is_prime(p: int) -> bool:
    """Return whether p is prime by trial division."""
    if p < 2:
        return False
    d = 2
    while d * d <= p:
        if p % d == 0:
            return False
        d += 1
    return True


def coefficient_vectors(p: int, n: int) -> Iterator[CoefficientVector]:
    """Generate all lower-coefficient vectors for monic degree-n polynomials."""
    if not is_prime(p):
        raise ValueError("p must be prime")
    if n <= 0:
        raise ValueError("n must be positive")
    yield from product(range(p), repeat=n)


def monic_value(coefficients: Sequence[int], x: int, p: int) -> int:
    """Evaluate X^n + a_(n-1)X^(n-1) + ... + a_0 modulo p.

    Coefficients are supplied in ascending order (a_0, ..., a_(n-1)).
    Horner evaluation is used.
    """
    value = 1
    for coefficient in reversed(coefficients):
        value = (value * x + coefficient) % p
    return value


def roots_in_prime_field(coefficients: Sequence[int], p: int) -> Tuple[int, ...]:
    """Return all distinct roots of the represented monic polynomial in F_p."""
    return tuple(x for x in range(p) if monic_value(coefficients, x, p) == 0)


def polynomial_root_distribution(p: int, n: int) -> Dict[int, int]:
    """Map each possible root count to the number of monic polynomials having it."""
    counts = Counter(
        len(roots_in_prime_field(coefficients, p))
        for coefficients in coefficient_vectors(p, n)
    )
    return dict(sorted(counts.items()))


def total_root_incidences(p: int, n: int) -> int:
    """Count pairs (f, r) with f monic of degree n and f(r)=0 over F_p."""
    return sum(
        len(roots_in_prime_field(coefficients, p))
        for coefficients in coefficient_vectors(p, n)
    )


def fixed_points(permutation: Sequence[int]) -> int:
    """Count fixed positions of a permutation represented in one-line notation."""
    return sum(index == image for index, image in enumerate(permutation))


def permutation_fixed_point_distribution(n: int) -> Dict[int, int]:
    """Map each fixed-point count to the number of permutations having it."""
    if n <= 0:
        raise ValueError("n must be positive")
    counts = Counter(fixed_points(sigma) for sigma in permutations(range(n)))
    return dict(sorted(counts.items()))


def total_fixed_point_incidences(n: int) -> int:
    """Count pairs (sigma, i) for which the permutation sigma fixes i."""
    if n <= 0:
        raise ValueError("n must be positive")
    return sum(fixed_points(sigma) for sigma in permutations(range(n)))


def verify_bridge(p: int, n: int) -> bool:
    """Verify the cross-multiplied root–fixed-point identity numerically."""
    roots = total_root_incidences(p, n)
    fixed = total_fixed_point_incidences(n)
    return roots * factorial(n) == fixed * (p**n)


def prescribed_root_fiber_size(p: int, n: int, root: int) -> int:
    """Count monic degree-n polynomials taking value zero at a prescribed root."""
    if not 0 <= root < p:
        raise ValueError("root must represent an element of F_p")
    return sum(
        monic_value(coefficients, root, p) == 0
        for coefficients in coefficient_vectors(p, n)
    )


def print_report(cases: Iterable[Tuple[int, int]]) -> None:
    """Print a compact report for selected (prime, degree) cases."""
    for p, n in cases:
        root_total = total_root_incidences(p, n)
        fixed_total = total_fixed_point_incidences(n)
        print(f"F_{p}, degree {n}")
        print(f"  polynomials: {p**n}")
        print(f"  root-count distribution: {polynomial_root_distribution(p, n)}")
        print(f"  total root incidences: {root_total}; mean = {root_total / p**n:.6f}")
        print(f"  S_{n} fixed-point distribution: {permutation_fixed_point_distribution(n)}")
        print(f"  total fixed incidences: {fixed_total}; mean = {fixed_total / factorial(n):.6f}")
        print(f"  prescribed-root fibers: {[prescribed_root_fiber_size(p, n, r) for r in range(p)]}")
        print(f"  bridge verified: {verify_bridge(p, n)}")
        print()


def main() -> None:
    """Run representative quadratic and cubic demonstrations."""
    cases = ((2, 2), (3, 2), (3, 3), (5, 3))
    print_report(cases)
    for p, n in cases:
        assert total_root_incidences(p, n) == p**n
        assert total_fixed_point_incidences(n) == factorial(n)
        assert all(
            prescribed_root_fiber_size(p, n, r) == p ** (n - 1)
            for r in range(p)
        )
        assert verify_bridge(p, n)


if __name__ == "__main__":
    main()
