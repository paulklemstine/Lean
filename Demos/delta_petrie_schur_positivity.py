"""
Numerical demonstrations for the Petrie Divisibility Criterion.

Central objects:
  * The Petrie block          p_k(x) = 1 + x + x^2 + ... + x^{k-1}
  * The generating polynomial P(k, N; x) = p_k(x)^N

Central theorem (for k >= 2):
      p_k(x) divides (x^n - 1)   <==>   k divides n.

This script verifies the theorem, its structural identities, and the
word-count specialization P(k, N; 1) = k^N, using only exact integer
polynomial arithmetic (no floating point) plus a complex-root spectral check.
"""

from __future__ import annotations

import cmath
from typing import List, Tuple


# --------------------------------------------------------------------------
# Exact integer polynomials represented as coefficient lists (low degree first)
# --------------------------------------------------------------------------

def poly_trim(p: List[int]) -> List[int]:
    """Remove trailing (high-degree) zero coefficients."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    """Multiply two polynomials given as coefficient lists."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return poly_trim(result)


def petrie_block(k: int) -> List[int]:
    """The Petrie block p_k = 1 + x + ... + x^{k-1}."""
    if k <= 0:
        return [0]
    return [1] * k


def petrie_gf(k: int, n_power: int) -> List[int]:
    """The Petrie generating polynomial P(k, N; x) = p_k(x)^N."""
    result = [1]
    block = petrie_block(k)
    for _ in range(n_power):
        result = poly_mul(result, block)
    return result


def x_pow_minus_one(n: int) -> List[int]:
    """The polynomial x^n - 1."""
    coeffs = [0] * (n + 1)
    coeffs[n] = 1
    coeffs[0] = -1
    return poly_trim(coeffs)


def poly_divmod(num: List[int], den: List[int]) -> Tuple[List[int], List[int]]:
    """Polynomial division over the rationals; returns (quotient, remainder).

    Works exactly using Python's arbitrary-precision Fractions-free integer
    arithmetic because the divisors here are monic-up-to-leading-unit.
    """
    from fractions import Fraction

    num_f = [Fraction(c) for c in num]
    den_f = [Fraction(c) for c in poly_trim(den)]
    if den_f == [Fraction(0)]:
        raise ZeroDivisionError("division by zero polynomial")

    quotient = [Fraction(0)] * max(1, len(num_f) - len(den_f) + 1)
    rem = list(num_f)
    d_deg = len(den_f) - 1
    d_lead = den_f[-1]

    while len(poly_trim([int(c) if c.denominator == 1 else 1 for c in rem])) - 1 >= d_deg \
            and any(c != 0 for c in rem):
        r_deg = len(rem) - 1
        while r_deg > 0 and rem[r_deg] == 0:
            r_deg -= 1
        if r_deg < d_deg:
            break
        factor = rem[r_deg] / d_lead
        shift = r_deg - d_deg
        quotient[shift] = factor
        for i in range(len(den_f)):
            rem[shift + i] -= factor * den_f[i]

    remainder = [c for c in rem]
    # trim
    while len(remainder) > 1 and remainder[-1] == 0:
        remainder.pop()
    return quotient, remainder


def divides(den: List[int], num: List[int]) -> bool:
    """Return True iff `den` divides `num` exactly (zero remainder)."""
    _, rem = poly_divmod(num, den)
    return all(c == 0 for c in rem)


def poly_eval_complex(p: List[int], z: complex) -> complex:
    """Evaluate a polynomial at a complex point via Horner's method."""
    acc = 0j
    for c in reversed(p):
        acc = acc * z + c
    return acc


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_divisibility_criterion(k_max: int = 6, n_max: int = 18) -> None:
    """Verify p_k | (x^n - 1)  <==>  k | n for a grid of (k, n)."""
    print("=" * 68)
    print("DEMO 1: Petrie divisibility criterion  p_k | (x^n - 1) <=> k | n")
    print("=" * 68)
    mismatches = 0
    for k in range(2, k_max + 1):
        block = petrie_block(k)
        row = []
        for n in range(1, n_max + 1):
            poly_says = divides(block, x_pow_minus_one(n))
            arith_says = (n % k == 0)
            if poly_says != arith_says:
                mismatches += 1
            row.append("Y" if poly_says else ".")
        print(f"k={k}: " + " ".join(row))
    print(f"\nColumns are n = 1..{n_max}; 'Y' means p_k divides x^n - 1.")
    print(f"Mismatches with the arithmetic rule k|n: {mismatches}")
    assert mismatches == 0
    print("PASS: polynomial divisibility matches the divisibility of n by k.\n")


def demo_telescoping_identity(k_max: int = 8) -> None:
    """Verify (x - 1) * p_k = x^k - 1."""
    print("=" * 68)
    print("DEMO 2: Telescoping identity  (x - 1) * p_k = x^k - 1")
    print("=" * 68)
    for k in range(1, k_max + 1):
        lhs = poly_mul([-1, 1], petrie_block(k))  # (x - 1) * p_k
        rhs = x_pow_minus_one(k)
        status = "OK" if poly_trim(lhs) == poly_trim(rhs) else "FAIL"
        print(f"k={k}: (x-1)*p_k = {poly_trim(lhs)}  vs  x^{k}-1 = {rhs}  [{status}]")
        assert poly_trim(lhs) == poly_trim(rhs)
    print("PASS: telescoping identity holds for all tested k.\n")


def demo_word_count(k_max: int = 5, n_power_max: int = 5) -> None:
    """Verify P(k, N; 1) = k^N and the coefficient sum."""
    print("=" * 68)
    print("DEMO 3: Word-count specialization  P(k, N; 1) = k^N")
    print("=" * 68)
    for k in range(2, k_max + 1):
        for N in range(1, n_power_max + 1):
            gf = petrie_gf(k, N)
            coeff_sum = sum(gf)  # equals evaluation at x = 1
            expected = k ** N
            status = "OK" if coeff_sum == expected else "FAIL"
            print(f"k={k}, N={N}: sum of coeffs = {coeff_sum}, k^N = {expected} [{status}]")
            assert coeff_sum == expected
    print("PASS: the coefficients of p_k^N sum to k^N (word count).\n")


def demo_spectral_check(k_max: int = 6, n_max: int = 12) -> None:
    """Verify the roots-of-unity mechanism: p_k(zeta)=0 at primitive k-th root,
    and p_k | (x^n - 1) iff zeta^n = 1."""
    print("=" * 68)
    print("DEMO 4: Spectral certificate at a primitive k-th root of unity")
    print("=" * 68)
    tol = 1e-9
    for k in range(2, k_max + 1):
        zeta = cmath.exp(2j * cmath.pi / k)  # primitive k-th root of unity
        block_val = poly_eval_complex(petrie_block(k), zeta)
        assert abs(block_val) < tol, f"p_{k}(zeta) should vanish, got {block_val}"
        divisible_n = [n for n in range(1, n_max + 1)
                       if abs(zeta ** n - 1) < tol]
        print(f"k={k}: p_k(zeta)={block_val:.2e}  ;  zeta^n=1 for n in {divisible_n}")
        assert divisible_n == [n for n in range(1, n_max + 1) if n % k == 0]
    print("PASS: the block vanishes at primitive roots; zeta^n=1 iff k|n.\n")


def demo_coefficient_table(k: int = 3, N: int = 4) -> None:
    """Display the coefficients c(k, N, n) of P(k, N; x) = p_k^N."""
    print("=" * 68)
    print(f"DEMO 5: Coefficient table of P(k={k}, N={N}; x) = p_{k}^{N}")
    print("=" * 68)
    gf = petrie_gf(k, N)
    for n, c in enumerate(gf):
        print(f"  c({k},{N},{n}) = {c}  (words of length {N}, digit sum {n})")
    print(f"  total = {sum(gf)} = {k}^{N} = {k ** N}\n")


if __name__ == "__main__":
    demo_telescoping_identity()
    demo_divisibility_criterion()
    demo_word_count()
    demo_spectral_check()
    demo_coefficient_table()
    print("All demonstrations passed.")
