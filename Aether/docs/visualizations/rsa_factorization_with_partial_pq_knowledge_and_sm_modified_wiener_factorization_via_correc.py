"""Algorithm: Modified Wiener Factorization with partial p+q knowledge.

Given the RSA public key (n, e) and an estimate s of p+q (with residual bound
delta such that |p+q - s| <= delta), recover the prime factorization of n by
testing the continued-fraction convergents of e/n_tilde, where n_tilde = n+1-s.
"""

from __future__ import annotations

from math import isqrt
from typing import List, Optional, Tuple


def _continued_fraction(num: int, den: int) -> List[int]:
    coeffs: List[int] = []
    while den != 0:
        a = num // den
        coeffs.append(a)
        num, den = den, num - a * den
    return coeffs


def _convergents(coeffs: List[int]) -> List[Tuple[int, int]]:
    result: List[Tuple[int, int]] = []
    h_prev, h_cur = 1, coeffs[0] if coeffs else 0
    k_prev, k_cur = 0, 1
    result.append((h_cur, k_cur))
    for a in coeffs[1:]:
        h_prev, h_cur = h_cur, a * h_cur + h_prev
        k_prev, k_cur = k_cur, a * k_cur + k_prev
        result.append((h_cur, k_cur))
    return result


def modified_wiener_factor(n: int, e: int, s: int, delta: int = 0
                           ) -> Optional[Tuple[int, int]]:
    """Return (p, q) with p > q and p*q = n, or None if the attack fails.

    Complexity: the continued fraction of e/n_tilde has O(log n) convergents;
    each test costs one modular reduction and one integer square root, so the
    total running time is polynomial in log n.
    """
    n_tilde: int = n + 1 - s
    if n_tilde <= 0:
        return None
    for k_cand, d_cand in _convergents(_continued_fraction(e, n_tilde)):
        if k_cand <= 0 or d_cand <= 0:
            continue
        if (e * d_cand - 1) % k_cand != 0:
            continue
        phi: int = (e * d_cand - 1) // k_cand          # totient_from_key
        s_sum: int = n - phi + 1                        # n_sub_phi: S = p+q
        disc: int = s_sum * s_sum - 4 * n               # discriminant_eq: (p-q)^2
        if disc < 0:
            continue
        root: int = isqrt(disc)
        if root * root != disc:                         # perfect-square test
            continue
        p: int = (s_sum + root) // 2                    # factor_from_sum_prod
        q: int = (s_sum - root) // 2
        if p > q and p * q == n:
            return p, q
    return None
