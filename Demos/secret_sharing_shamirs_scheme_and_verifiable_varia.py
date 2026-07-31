#!/usr/bin/env python3
"""Numerical demonstrations of Shamir sharing and additive Feldman verification.

The examples use prime fields and small transparent parameters.  They are
educational: production systems require authenticated channels, secure random
coefficient generation, robust group encodings, and larger parameters.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Share:
    """A polynomial evaluation at a nonzero field location."""

    x: int
    y: int


def require_prime(p: int) -> None:
    """Reject a non-prime modulus using trial division (adequate for demos)."""
    if p < 2 or any(p % d == 0 for d in range(2, int(p**0.5) + 1)):
        raise ValueError("the modulus must be prime")


def mod_inverse(a: int, p: int) -> int:
    """Return the inverse of nonzero ``a`` in the prime field F_p."""
    a %= p
    if a == 0:
        raise ZeroDivisionError("zero has no multiplicative inverse")
    return pow(a, p - 2, p)


def evaluate_polynomial(coefficients: Sequence[int], x: int, p: int) -> int:
    """Evaluate low-to-high coefficients at ``x`` modulo ``p`` by Horner's rule."""
    value = 0
    for coefficient in reversed(coefficients):
        value = (value * x + coefficient) % p
    return value


def generate_shares(
    secret: int,
    random_coefficients: Sequence[int],
    locations: Iterable[int],
    p: int,
) -> list[Share]:
    """Generate shares for p(X)=secret+sum(a_j X^j) over F_p."""
    require_prime(p)
    xs = [x % p for x in locations]
    if 0 in xs or len(xs) != len(set(xs)):
        raise ValueError("locations must be distinct and nonzero modulo p")
    coefficients = [secret % p, *(a % p for a in random_coefficients)]
    return [Share(x, evaluate_polynomial(coefficients, x, p)) for x in xs]


def reconstruct_secret(shares: Sequence[Share], p: int) -> int:
    """Evaluate the Lagrange interpolant of distinct shares at zero."""
    require_prime(p)
    xs = [share.x % p for share in shares]
    if not shares or len(xs) != len(set(xs)):
        raise ValueError("at least one share with distinct locations is required")
    secret = 0
    for i, share_i in enumerate(shares):
        numerator = 1
        denominator = 1
        for j, share_j in enumerate(shares):
            if i != j:
                numerator = numerator * (-share_j.x) % p
                denominator = denominator * (share_i.x - share_j.x) % p
        weight = numerator * mod_inverse(denominator, p) % p
        secret = (secret + share_i.y * weight) % p
    return secret


def poly_add(a: Sequence[int], b: Sequence[int], p: int) -> list[int]:
    """Add coefficient vectors modulo p."""
    size = max(len(a), len(b))
    result = [0] * size
    for i in range(size):
        result[i] = ((a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)) % p
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_multiply(a: Sequence[int], b: Sequence[int], p: int) -> list[int]:
    """Multiply coefficient vectors modulo p."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % p
    return result


def interpolate_coefficients(points: Sequence[Share], p: int) -> list[int]:
    """Return low-to-high coefficients of the unique interpolating polynomial."""
    require_prime(p)
    xs = [point.x % p for point in points]
    if not points or len(xs) != len(set(xs)):
        raise ValueError("interpolation points must have distinct locations")
    result = [0]
    for i, point_i in enumerate(points):
        basis = [1]
        denominator = 1
        for j, point_j in enumerate(points):
            if i != j:
                basis = poly_multiply(basis, [(-point_j.x) % p, 1], p)
                denominator = denominator * (point_i.x - point_j.x) % p
        scale = point_i.y * mod_inverse(denominator, p) % p
        result = poly_add(result, [(scale * c) % p for c in basis], p)
    return result


def privacy_extensions(
    observed: Sequence[Share], threshold: int, p: int
) -> dict[int, list[int]]:
    """Construct the unique compatible degree-<threshold polynomial for each secret."""
    if threshold < 1 or len(observed) != threshold - 1:
        raise ValueError("exactly threshold-1 observations are required")
    if any(share.x % p == 0 for share in observed):
        raise ValueError("observed locations must be nonzero")
    return {
        secret: interpolate_coefficients([Share(0, secret), *observed], p)
        for secret in range(p)
    }


def additive_commit(value: int, multiplier: int, p: int) -> int:
    """Toy injective additive commitment C(a)=multiplier*a in F_p."""
    if multiplier % p == 0:
        raise ValueError("the multiplier must be nonzero for injectivity")
    return multiplier * value % p


def feldman_verify_additive(
    coefficients: Sequence[int],
    x: int,
    claimed: int,
    multiplier: int,
    p: int,
) -> bool:
    """Check C(claimed)=sum_i C(a_i*x^i) in the additive model."""
    left = additive_commit(claimed, multiplier, p)
    right = sum(
        additive_commit(coefficient * pow(x, i, p), multiplier, p)
        for i, coefficient in enumerate(coefficients)
    ) % p
    return left == right


def main() -> None:
    """Run reconstruction, privacy, exact-threshold, and verification examples."""
    modulus = 17
    threshold = 3
    coefficients = [5, 7, 3]
    shares = generate_shares(coefficients[0], coefficients[1:], range(1, 6), modulus)

    print("Shamir sharing over F_17")
    print(f"Polynomial coefficients: {coefficients}; secret: {coefficients[0]}")
    print("Shares:", shares)
    for subset in combinations(shares, threshold):
        recovered = reconstruct_secret(subset, modulus)
        assert recovered == coefficients[0]
    print("Every 3-share subset reconstructs secret 5.")

    observed = shares[: threshold - 1]
    extensions = privacy_extensions(observed, threshold, modulus)
    assert set(extensions) == set(range(modulus))
    assert all(
        polynomial[0] == secret
        and all(evaluate_polynomial(polynomial, s.x, modulus) == s.y for s in observed)
        for secret, polynomial in extensions.items()
    )
    print(f"Observed shares {observed} are compatible with all {modulus} secrets.")
    print("Example compatible coefficient vectors:")
    for secret in (0, 5, 16):
        print(f"  secret {secret:2d}: {extensions[secret]}")

    vanishing = poly_multiply([(-observed[0].x) % modulus, 1],
                              [(-observed[1].x) % modulus, 1], modulus)
    assert all(evaluate_polynomial(vanishing, s.x, modulus) == 0 for s in observed)
    assert evaluate_polynomial(vanishing, 0, modulus) != 0
    print("A degree-2 vanishing polynomial proves that 2 shares need not reconstruct:",
          vanishing)

    multiplier = 4
    x = 2
    honest = evaluate_polynomial(coefficients, x, modulus)
    assert feldman_verify_additive(coefficients, x, honest, multiplier, modulus)
    assert not feldman_verify_additive(coefficients, x, honest + 1, multiplier, modulus)
    print(f"At x={x}, honest claim {honest} passes; altered claim {honest + 1} fails.")


if __name__ == "__main__":
    main()
