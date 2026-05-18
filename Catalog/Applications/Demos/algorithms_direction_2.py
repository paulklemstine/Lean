#!/usr/bin/env python3
"""
Algorithms for Affine Distortion Complexity

Implements the core algorithms for computing affine encodability,
minimum bit budgets, and compression bounds.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
import math
from dataclasses import dataclass


@dataclass
class AffineEncoding:
    """Result of an affine encoding computation."""
    a: Fraction
    b: Fraction
    k: int
    quantized: List[int]
    code_length_bound: int
    entropy_bound: int

    def __repr__(self):
        return (f"AffineEncoding(a={float(self.a):.6f}, b={float(self.b):.6f}, "
                f"k={self.k}, quantized={self.quantized}, "
                f"code_length≤{self.code_length_bound}, entropy≤{self.entropy_bound})")


def compute_affine_encoding(
    xs: List[Fraction], k: int
) -> Optional[AffineEncoding]:
    """
    Compute an affine encoding of xs with bit budget k.

    Algorithm:
    1. Compute min and max of xs.
    2. Set a = (2^k - 1) / (max - min), b = -a * min.
    3. Check that all transformed values are exact non-negative integers < 2^k.

    Time complexity: O(n) where n = len(xs).
    Space complexity: O(n) for the quantized list.

    Args:
        xs: List of rational numbers to encode.
        k: Bit budget (quantized values must be in {0, ..., 2^k - 1}).

    Returns:
        AffineEncoding if successful, None otherwise.
    """
    n = len(xs)
    if n == 0:
        return AffineEncoding(Fraction(1), Fraction(0), k, [], k, 0)

    x_min = min(xs)
    x_max = max(xs)
    span = x_max - x_min

    if span == 0:
        # All values identical — map to 0
        a = Fraction(1)
        b = -x_min
        quantized = [0] * n
        return AffineEncoding(a, b, k, quantized, n * k + k, n * k)

    bound = 2**k - 1
    if bound == 0:
        # k = 0 means only value 0 allowed, need span = 0
        return None

    # Find GCD of all differences from x_min to ensure integrality
    sorted_unique = sorted(set(xs))
    diffs = [x - x_min for x in sorted_unique if x != x_min]

    if not diffs:
        # All values are the same (shouldn't reach here due to span check)
        a = Fraction(1)
        b = -x_min
        quantized = [0] * n
        return AffineEncoding(a, b, k, quantized, n * k + k, n * k)

    from math import gcd as int_gcd

    def fraction_gcd(a_frac: Fraction, b_frac: Fraction) -> Fraction:
        if a_frac == 0: return abs(b_frac)
        if b_frac == 0: return abs(a_frac)
        num = int_gcd(abs(a_frac.numerator) * b_frac.denominator,
                      abs(b_frac.numerator) * a_frac.denominator)
        den = a_frac.denominator * b_frac.denominator
        return Fraction(num, den)

    g = diffs[0]
    for d in diffs[1:]:
        g = fraction_gcd(g, d)

    # Number of distinct grid steps
    n_steps = int(span / g)
    if n_steps > bound:
        return None  # Need more bits

    # a = 1/g maps differences to integers
    a = Fraction(1) / g
    b = -a * x_min

    quantized = []
    for x in xs:
        val = a * x + b
        if val.denominator != 1:
            return None
        n_val = int(val)
        if n_val < 0 or n_val >= 2**k:
            return None
        quantized.append(n_val)

    return AffineEncoding(a, b, k, quantized, n * k + k, n * k)


def minimum_bit_budget(xs: List[Fraction]) -> int:
    """
    Find the minimum bit budget k such that xs is rationally affine encodable.

    Algorithm:
    - Binary search over k from 1 to ceil(log2(n_distinct)) + 1.
    - For each k, attempt compute_affine_encoding.

    Time complexity: O(n * log(n_distinct)) where n = len(xs).
    Space complexity: O(n).

    Args:
        xs: List of rational numbers.

    Returns:
        Minimum k ≥ 1 such that xs is affine encodable with budget k.
    """
    if not xs:
        return 1

    n_distinct = len(set(xs))
    lower_bound = max(1, math.ceil(math.log2(max(n_distinct, 1))))

    for k in range(lower_bound, lower_bound + 64):
        if compute_affine_encoding(xs, k) is not None:
            return k

    return lower_bound + 64


def affine_distortion_ratio(xs: List[Fraction]) -> Fraction:
    """
    Compute the affine distortion ratio of a dataset.

    The affine distortion ratio is defined as the ratio of the range
    of the data to the minimum step size, plus 1. This equals 2^k_min - 1
    for evenly spaced data, and is related to the minimum bit budget.

    Algorithm:
    1. Compute all pairwise differences.
    2. Find the GCD of all differences.
    3. Return (max - min) / gcd + 1.

    Time complexity: O(n^2) naive, O(n log n) with sorting.
    Space complexity: O(n).

    Args:
        xs: List of rational numbers.

    Returns:
        The affine distortion ratio as a Fraction.
    """
    if len(xs) <= 1:
        return Fraction(1)

    sorted_xs = sorted(set(xs))
    if len(sorted_xs) <= 1:
        return Fraction(1)

    # Compute differences
    diffs = [sorted_xs[i+1] - sorted_xs[i] for i in range(len(sorted_xs) - 1)]

    # GCD of all differences
    from math import gcd as int_gcd

    def fraction_gcd(a: Fraction, b: Fraction) -> Fraction:
        """GCD of two fractions: gcd(p/q, r/s) = gcd(p*s, r*q) / (q*s)."""
        if a == 0:
            return abs(b)
        if b == 0:
            return abs(a)
        num = int_gcd(a.numerator * b.denominator, b.numerator * a.denominator)
        den = a.denominator * b.denominator
        return Fraction(num, den)

    g = diffs[0]
    for d in diffs[1:]:
        g = fraction_gcd(g, d)

    span = sorted_xs[-1] - sorted_xs[0]
    return span / g + 1


def compression_certificate(xs: List[Fraction]) -> Dict:
    """
    Compute a full compression certificate for a dataset.

    Returns a dictionary containing:
    - encoding: The optimal affine encoding
    - k_min: Minimum bit budget
    - n_distinct: Number of distinct values
    - distortion_ratio: Affine distortion ratio
    - code_length: Upper bound on code length
    - entropy_bound: Upper bound on entropy
    - compression_ratio: Ratio vs naive encoding

    Args:
        xs: List of rational numbers.

    Returns:
        Dictionary with compression certificate.
    """
    n = len(xs)
    k_min = minimum_bit_budget(xs)
    encoding = compute_affine_encoding(xs, k_min)
    n_distinct = len(set(xs))
    dist_ratio = affine_distortion_ratio(xs)

    naive_bits = n * max(1, math.ceil(math.log2(
        max(abs(int(max(xs))) if xs else 0, 1) + 1
    ))) if xs else 0

    result = {
        "n": n,
        "k_min": k_min,
        "n_distinct": n_distinct,
        "distortion_ratio": float(dist_ratio),
        "code_length_bound": encoding.code_length_bound if encoding else None,
        "entropy_bound": encoding.entropy_bound if encoding else None,
        "naive_bits": naive_bits,
        "compression_ratio": (
            encoding.code_length_bound / max(naive_bits, 1)
            if encoding and naive_bits > 0 else None
        ),
        "encoding": encoding,
    }
    return result


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Evenly spaced data
    xs = [Fraction(i * 10) for i in range(8)]
    cert = compression_certificate(xs)
    print(f"Dataset: {[int(x) for x in xs]}")
    print(f"Certificate: k_min={cert['k_min']}, distortion={cert['distortion_ratio']}")
    print(f"Code length ≤ {cert['code_length_bound']} bits")
    print(f"Entropy ≤ {cert['entropy_bound']} bits")
    print(f"Encoding: {cert['encoding']}")
    print()

    # Example 2: Non-uniform spacing
    xs = [Fraction(i) for i in [1, 2, 4, 8, 16]]
    cert = compression_certificate(xs)
    print(f"Dataset: {[int(x) for x in xs]}")
    print(f"Certificate: k_min={cert['k_min']}, distortion={cert['distortion_ratio']}")
    print(f"Code length ≤ {cert['code_length_bound']} bits")
    print()

    # Example 3: Rational data
    xs = [Fraction(1, 3), Fraction(2, 3), Fraction(1), Fraction(4, 3)]
    cert = compression_certificate(xs)
    print(f"Dataset: {[str(x) for x in xs]}")
    print(f"Certificate: k_min={cert['k_min']}, distortion={cert['distortion_ratio']}")
    print(f"Encoding: {cert['encoding']}")
