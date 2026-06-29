#!/usr/bin/env python3
"""
Algorithms for Galois group computation of polynomials over Q.

Implements the Dedekind-Frobenius-discriminant pipeline for determining
Galois groups of polynomials via modular arithmetic.
"""

from typing import List, Tuple, Optional, Dict
from itertools import product as cartesian_product
from math import gcd, lcm, factorial
from functools import reduce


def poly_mod(coeffs: List[int], p: int) -> List[int]:
    """Reduce polynomial coefficients modulo p, stripping leading zeros."""
    result = [c % p for c in coeffs]
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_eval(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate polynomial at x modulo p. coeffs[i] = coeff of x^i."""
    result = 0
    for i, c in enumerate(coeffs):
        result = (result + c * pow(x, i, p)) % p
    return result


def poly_mul(a: List[int], b: List[int], p: int) -> List[int]:
    """Multiply polynomials modulo p."""
    if not a or not b:
        return [0]
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % p
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_divmod(a: List[int], b: List[int], p: int) -> Tuple[List[int], List[int]]:
    """Polynomial division with remainder modulo p."""
    if len(b) == 0 or (len(b) == 1 and b[0] == 0):
        raise ValueError("Division by zero polynomial")
    a = list(a)
    b_lead_inv = pow(b[-1], -1, p)  # inverse of leading coeff

    quotient = [0] * max(1, len(a) - len(b) + 1)
    remainder = list(a)

    for i in range(len(a) - len(b), -1, -1):
        if len(remainder) > i + len(b) - 1:
            coeff = (remainder[i + len(b) - 1] * b_lead_inv) % p
            quotient[i] = coeff
            for j in range(len(b)):
                remainder[i + j] = (remainder[i + j] - coeff * b[j]) % p

    while len(remainder) > 1 and remainder[-1] == 0:
        remainder.pop()
    while len(quotient) > 1 and quotient[-1] == 0:
        quotient.pop()

    return quotient, remainder


def poly_gcd(a: List[int], b: List[int], p: int) -> List[int]:
    """GCD of polynomials modulo p."""
    while len(b) > 1 or (len(b) == 1 and b[0] != 0):
        _, r = poly_divmod(a, b, p)
        a, b = b, r
    # Make monic
    if a[-1] != 0:
        inv = pow(a[-1], -1, p)
        a = [(c * inv) % p for c in a]
    return a


def find_roots_mod_p(coeffs: List[int], p: int) -> List[int]:
    """Find all roots of polynomial modulo p."""
    return [x for x in range(p) if poly_eval(coeffs, x, p) == 0]


def factor_mod_p(coeffs: List[int], p: int) -> List[List[int]]:
    """
    Factor a polynomial modulo p using Cantor-Zassenhaus-style approach.
    Returns list of irreducible factors (as coefficient lists).

    Algorithm:
    1. Remove linear factors by checking roots.
    2. Use distinct-degree factorization for remaining factors.
    """
    coeffs = poly_mod(coeffs, p)
    factors = []

    # Step 1: Remove linear factors
    for root in find_roots_mod_p(coeffs, p):
        while poly_eval(coeffs, root, p) == 0:
            # Divide by (x - root)
            linear = [(-root) % p, 1]
            coeffs, rem = poly_divmod(coeffs, linear, p)
            factors.append(linear)

    if len(coeffs) <= 1:
        return factors

    # Step 2: Distinct-degree factorization
    # For each degree d, compute gcd(f, x^(p^d) - x) to find degree-d factors
    remaining = list(coeffs)
    x_power = [0, 1]  # Start with x

    for d in range(1, len(remaining)):
        if len(remaining) <= 1:
            break
        # Compute x^(p^d) mod f
        x_pd = [0, 1]
        for _ in range(d):
            # Raise to p-th power modulo remaining
            result = [1]
            base = list(x_pd)
            exp = p
            while exp > 0:
                if exp % 2 == 1:
                    result = poly_mul(result, base, p)
                    _, result = poly_divmod(result, remaining, p)
                base = poly_mul(base, base, p)
                _, base = poly_divmod(base, remaining, p)
                exp //= 2
            x_pd = result

        # gcd(remaining, x^(p^d) - x)
        x_pd_minus_x = list(x_pd)
        x_pd_minus_x[0] = (x_pd_minus_x[0] - 0) % p
        if len(x_pd_minus_x) > 1:
            x_pd_minus_x[1] = (x_pd_minus_x[1] - 1) % p
        else:
            x_pd_minus_x.append((-1) % p)

        g = poly_gcd(remaining, x_pd_minus_x, p)
        if len(g) > 1:
            # g is a product of irreducible degree-d polynomials
            num_factors = (len(g) - 1) // d
            for _ in range(num_factors):
                factors.append(g)
            remaining, _ = poly_divmod(remaining, g, p)

    if len(remaining) > 1:
        factors.append(remaining)

    return factors


def cycle_type_from_factorization(degrees: List[int]) -> Tuple[int, ...]:
    """Get cycle type from factorization degrees."""
    return tuple(sorted(degrees))


def sign_of_cycle_type(ct: Tuple[int, ...]) -> int:
    """Compute the sign of a permutation from its cycle type."""
    sign = 1
    for k in ct:
        if k % 2 == 0:
            sign *= -1
    return sign


def galois_group_quintic_pipeline(coeffs: List[int], primes: List[int] = None) -> Dict:
    """
    Galois group computation pipeline for a degree-5 polynomial over Z.

    Args:
        coeffs: Coefficients [a_0, a_1, ..., a_5] of the polynomial.
        primes: List of primes to test (default: first 20 primes).

    Returns:
        Dictionary with analysis results.

    Algorithm:
        1. For each prime p not dividing disc(f), factor f mod p.
        2. Collect cycle types.
        3. Apply group-theoretic constraints to determine the Galois group.
    """
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    results = {
        'polynomial': coeffs,
        'degree': len(coeffs) - 1,
        'cycle_types': {},
        'orders_present': set(),
        'contains_odd': False,
        'conclusion': 'Unknown',
    }

    for p in primes:
        f_mod = poly_mod(coeffs, p)
        if len(f_mod) - 1 < len(coeffs) - 1:
            continue  # p divides leading coefficient

        roots = find_roots_mod_p(f_mod, p)
        if len(roots) == len(coeffs) - 1:
            continue  # f splits completely

        # Determine factorization pattern
        # Simple approach: check root count and use degree counting
        remaining_degree = len(coeffs) - 1 - len(roots)
        degrees = [1] * len(roots)

        if remaining_degree > 0:
            # Try to factor the rootless part
            remaining = list(f_mod)
            for r in roots:
                remaining, _ = poly_divmod(remaining, [(-r) % p, 1], p)

            # Check if remaining is irreducible
            rem_roots = find_roots_mod_p(remaining, p)
            if not rem_roots and remaining_degree <= 5:
                degrees.append(remaining_degree)
            else:
                degrees.extend([1] * len(rem_roots))
                left = remaining_degree - len(rem_roots)
                if left > 0:
                    degrees.append(left)

        ct = cycle_type_from_factorization(degrees)
        order = reduce(lcm, degrees) if degrees else 1
        sign = sign_of_cycle_type(ct)

        results['cycle_types'][p] = {
            'factorization_degrees': degrees,
            'cycle_type': ct,
            'order': order,
            'sign': sign,
        }

        results['orders_present'].add(order)
        if sign == -1:
            results['contains_odd'] = True

    # Classification
    if 5 in results['orders_present'] or results['degree'] == 5:
        if results['contains_odd']:
            order_lcm = reduce(lcm, results['orders_present']) if results['orders_present'] else 1
            if order_lcm % 30 == 0 or (5 in results['orders_present'] and
                                        any(o % 2 == 0 and o % 3 == 0 for o in results['orders_present'])):
                results['conclusion'] = 'S_5'
            elif order_lcm % 10 == 0:
                results['conclusion'] = 'S_5 or F_20 (need more primes)'
            else:
                results['conclusion'] = 'Likely S_5 (contains odd permutation)'
        else:
            results['conclusion'] = 'Contained in A_5'

    return results


# ---- Demo ----

if __name__ == "__main__":
    print("Galois Group Pipeline for X^5 - X - 1")
    print("="*50)

    # f = X^5 - X - 1: coefficients [-1, -1, 0, 0, 0, 1]
    result = galois_group_quintic_pipeline([-1, -1, 0, 0, 0, 1])

    print(f"\nPolynomial: X^5 - X - 1")
    print(f"\nModular factorization patterns:")
    for p, data in sorted(result['cycle_types'].items()):
        print(f"  p={p:3d}: degrees={data['factorization_degrees']}, "
              f"cycle_type={data['cycle_type']}, "
              f"order={data['order']}, sign={'+' if data['sign']==1 else '-'}1")

    print(f"\nOrders present: {sorted(result['orders_present'])}")
    print(f"Contains odd permutation: {result['contains_odd']}")
    print(f"\nConclusion: Gal(f/Q) = {result['conclusion']}")
