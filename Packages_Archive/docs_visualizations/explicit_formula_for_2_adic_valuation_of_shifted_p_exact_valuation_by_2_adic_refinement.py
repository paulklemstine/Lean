from __future__ import annotations


def perrin_mod(m: int, modulus: int) -> int:
    """R_m mod `modulus`, computed with the length-3 recurrence on residues."""
    if m == 0:
        return 3 % modulus
    if m == 1:
        return 0
    if m == 2:
        return 2 % modulus
    a, b, c = 3 % modulus, 0, 2 % modulus  # (R_0, R_1, R_2)
    for _ in range(3, m + 1):
        a, b, c = b, c, (b + a) % modulus  # R_i = R_{i-2}+R_{i-3}
    return c


def valuation_refine(m: int, max_level: int = 64) -> int:
    """
    Exact 2-adic valuation of R_m - 1 by 2-adic refinement.
    Uses periodicity: R mod 2^k has period 7 * 2^(k-1), so we reduce the index.
    """
    k = 0
    while k < max_level:
        modulus = 1 << (k + 1)          # 2^(k+1)
        period = 7 * (1 << k)           # 7 * 2^k  (period of R mod 2^(k+1))
        idx = m % period
        val = (perrin_mod(idx, modulus) - 1) % modulus
        if val != 0:                    # 2^(k+1) does not divide R_m - 1
            return k
        k += 1
    return max_level
