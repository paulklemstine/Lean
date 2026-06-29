"""Cyclotomic block quotient: compute S_{6r} / Phi_6 in linear time."""

from __future__ import annotations

from typing import List


def cyclotomic_block_quotient(r: int) -> List[int]:
    """
    Return the coefficient list of P = S_{6r} / Phi_6, where
    S_{6r} = x + x^2 + ... + x^{6r} and Phi_6 = x^2 - x + 1.

    The quotient is the sum of r shifted copies of the fixed weight pattern
    (1, 2, 2, 1):  block(j) = x^{6j+1} + 2x^{6j+2} + 2x^{6j+3} + x^{6j+4}.
    Because Phi_6 * (x + 2x^2 + 2x^3 + x^4) = x + x^2 + ... + x^6, the shifted
    blocks tile the exponents 1..6r, so Phi_6 * P = S_{6r}.

    Runs in O(r) time and space.
    """
    if r <= 0:
        raise ValueError("r must be a positive integer")
    coeffs: List[int] = [0] * (6 * r - 1)  # degrees 0 .. 6r-2
    for j in range(r):
        base = 6 * j
        coeffs[base + 1] += 1
        coeffs[base + 2] += 2
        coeffs[base + 3] += 2
        coeffs[base + 4] += 1
    return coeffs


def verify(r: int) -> bool:
    """Check Phi_6 * P == S_{6r} for the computed quotient P."""
    p = cyclotomic_block_quotient(r)
    phi6 = [1, -1, 1]
    prod = [0] * (len(p) + 2)
    for i, pi in enumerate(p):
        for j, fj in enumerate(phi6):
            prod[i + j] += pi * fj
    while len(prod) > 1 and prod[-1] == 0:
        prod.pop()
    target = [0] + [1] * (6 * r)
    return prod == target


if __name__ == "__main__":
    for r in (1, 2, 6, 10):
        print(f"r={r:>2}  verified: {verify(r)}")
    print("P for r=6 (= S_36/Phi_6):", cyclotomic_block_quotient(6))
