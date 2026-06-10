#!/usr/bin/env python3
"""
Universal Affine Σ-Protocol Extraction — Core Algorithms

This module implements the extraction algorithms for affine Σ-protocols
over finite fields, with complete type annotations and documentation.

Algorithms implemented:
1. 1D affine extractor
2. Vector affine extractor (coordinatewise)
3. Matrix affine extractor (with left-inverse recovery)
4. Extraction rank checker
5. Kernel computation for obstruction certificates
"""

from typing import List, Tuple, Optional
from dataclasses import dataclass


def mod_inverse(a: int, p: int) -> int:
    """
    Compute the modular inverse of a modulo p using Fermat's little theorem.

    Requires p prime and a not divisible by p.

    Time complexity: O(log p) via fast exponentiation.
    Space complexity: O(1).

    >>> mod_inverse(3, 7)
    5
    >>> (3 * 5) % 7
    1
    """
    if a % p == 0:
        raise ValueError(f"{a} is not invertible mod {p}")
    return pow(a, p - 2, p)


def affine_extract_1d(z1: int, z2: int, c1: int, c2: int, q: int) -> int:
    """
    1-Dimensional Affine Extractor.

    Given:
        z₁ = r + c₁·w (mod q)
        z₂ = r + c₂·w (mod q)
    with c₁ ≠ c₂ and q prime, computes:
        w = (z₁ - z₂) · (c₁ - c₂)⁻¹ (mod q)

    This is the fundamental building block. All higher-dimensional
    extractors reduce to this operation coordinatewise.

    Time complexity: O(log q) for the modular inverse.
    Space complexity: O(1).

    Args:
        z1: First response
        z2: Second response
        c1: First challenge
        c2: Second challenge (must differ from c1)
        q: Prime field modulus

    Returns:
        The extracted witness w (mod q)

    Example:
        >>> affine_extract_1d(z1=8, z2=5, c1=4, c2=23, q=31)  # Schnorr example
        8
    """
    diff_z = (z1 - z2) % q
    diff_c = (c1 - c2) % q
    return (diff_z * mod_inverse(diff_c, q)) % q


def affine_extract_vec(z1: List[int], z2: List[int],
                       c1: int, c2: int, q: int) -> List[int]:
    """
    Vector Affine Extractor (coordinatewise).

    Given:
        z₁[i] = r[i] + c₁·w[i] (mod q)  for all i
        z₂[i] = r[i] + c₂·w[i] (mod q)  for all i
    computes w[i] for each coordinate independently.

    Time complexity: O(n·log q) where n = len(z1).
    Space complexity: O(n).

    Args:
        z1: First response vector (length n)
        z2: Second response vector (length n)
        c1: First challenge
        c2: Second challenge
        q: Prime field modulus

    Returns:
        Extracted witness vector w (length n)
    """
    assert len(z1) == len(z2), "Response vectors must have equal length"
    return [affine_extract_1d(z1[i], z2[i], c1, c2, q)
            for i in range(len(z1))]


def matrix_mul_vec(M: List[List[int]], v: List[int], q: int) -> List[int]:
    """
    Matrix-vector multiplication over GF(q).

    Computes M·v (mod q).

    Time complexity: O(m·n) where M is m×n.
    Space complexity: O(m).
    """
    m = len(M)
    n = len(v) if v else 0
    result = [0] * m
    for i in range(m):
        s = 0
        for j in range(n):
            s += M[i][j] * v[j]
        result[i] = s % q
    return result


def matrix_inverse_2x2(M: List[List[int]], q: int) -> Optional[List[List[int]]]:
    """
    Compute the inverse of a 2×2 matrix over GF(q).

    Returns None if the matrix is singular.

    Time complexity: O(log q).
    Space complexity: O(1).
    """
    det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
    if det == 0:
        return None
    det_inv = mod_inverse(det, q)
    return [
        [(M[1][1] * det_inv) % q, ((-M[0][1]) * det_inv) % q],
        [((-M[1][0]) * det_inv) % q, (M[0][0] * det_inv) % q]
    ]


def matrix_affine_extract(M: List[List[int]],
                          z1: List[int], z2: List[int],
                          c1: int, c2: int, q: int,
                          M_left_inv: Optional[List[List[int]]] = None
                          ) -> Optional[List[int]]:
    """
    Matrix Affine Extractor.

    Given the acceptance equation z = t + c·M·w, and two transcripts
    (c₁, z₁) and (c₂, z₂) with the same commitment (same t), extracts
    the witness w.

    Algorithm:
    1. Recover M·w = (z₁ - z₂)·(c₁ - c₂)⁻¹ coordinatewise
    2. Apply left inverse L of M: w = L·(M·w)

    If no left inverse is provided, attempts to compute one for square
    matrices of dimension ≤ 2.

    Time complexity: O(m·log q + m·n) where M is m×n.
    Space complexity: O(m + n).

    Args:
        M: Protocol coefficient matrix (m×n)
        z1, z2: Response vectors
        c1, c2: Distinct challenges
        q: Prime field modulus
        M_left_inv: Optional precomputed left inverse of M

    Returns:
        Extracted witness vector, or None if M is non-invertible
    """
    m = len(M)
    n = len(M[0]) if M else 0

    # Step 1: Recover M·w
    Mw = affine_extract_vec(z1, z2, c1, c2, q)

    # Step 2: Solve M·w = Mw for w
    if M_left_inv is not None:
        return matrix_mul_vec(M_left_inv, Mw, q)

    # Auto-compute left inverse for square matrices up to 2×2
    if m == n == 2:
        inv = matrix_inverse_2x2(M, q)
        if inv is None:
            return None
        return matrix_mul_vec(inv, Mw, q)
    elif m == n == 1:
        if M[0][0] % q == 0:
            return None
        return [(Mw[0] * mod_inverse(M[0][0], q)) % q]

    return None  # General case requires user-provided left inverse


@dataclass
class ExtractionResult:
    """Result of an extraction attempt."""
    success: bool
    witness: Optional[List[int]]
    Mw_recovered: List[int]
    has_extraction_rank: bool
    obstruction: Optional[str]


def check_extraction_rank_2x2(M: List[List[int]], q: int) -> Tuple[bool, Optional[List[int]]]:
    """
    Check if a 2×2 matrix has extraction rank (trivial kernel) over GF(q).

    Returns (has_rank, kernel_vector) where kernel_vector is a nonzero
    element of ker(M) if has_rank is False.

    Time complexity: O(log q).
    """
    det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % q
    if det != 0:
        return True, None

    # Find kernel vector
    if M[0][0] != 0 or M[0][1] != 0:
        # Use first row: a·k₁ + b·k₂ = 0
        a, b = M[0][0] % q, M[0][1] % q
        if b != 0:
            k = [1, (-a * mod_inverse(b, q)) % q]
        else:
            k = [0, 1]
    elif M[1][0] != 0 or M[1][1] != 0:
        a, b = M[1][0] % q, M[1][1] % q
        if b != 0:
            k = [1, (-a * mod_inverse(b, q)) % q]
        else:
            k = [0, 1]
    else:
        k = [1, 0]  # Zero matrix

    return False, k


def full_extraction_pipeline(M: List[List[int]],
                             z1: List[int], z2: List[int],
                             c1: int, c2: int, q: int) -> ExtractionResult:
    """
    Complete extraction pipeline with diagnostics.

    Checks extraction rank, attempts extraction, and produces
    obstruction certificates when extraction fails.

    Args:
        M: Protocol coefficient matrix
        z1, z2: Response vectors from two transcripts
        c1, c2: Distinct challenges
        q: Prime field modulus

    Returns:
        ExtractionResult with full diagnostics
    """
    m = len(M)
    n = len(M[0]) if M else 0

    # Recover M·w
    Mw = affine_extract_vec(z1, z2, c1, c2, q)

    # Check extraction rank
    if m == n == 2:
        has_rank, kernel = check_extraction_rank_2x2(M, q)
    else:
        has_rank = True  # Conservative default
        kernel = None

    if not has_rank:
        return ExtractionResult(
            success=False,
            witness=None,
            Mw_recovered=Mw,
            has_extraction_rank=False,
            obstruction=f"Kernel vector: {kernel}. "
                       f"Multiple witnesses produce the same transcript."
        )

    w = matrix_affine_extract(M, z1, z2, c1, c2, q)
    if w is None:
        return ExtractionResult(
            success=False,
            witness=None,
            Mw_recovered=Mw,
            has_extraction_rank=has_rank,
            obstruction="Could not compute left inverse of M"
        )

    return ExtractionResult(
        success=True,
        witness=w,
        Mw_recovered=Mw,
        has_extraction_rank=True,
        obstruction=None
    )


# ═══════════════════════════════════════════════════════
# Protocol-specific extractors
# ═══════════════════════════════════════════════════════

def schnorr_extract(z1: int, z2: int, c1: int, c2: int, q: int) -> int:
    """Schnorr protocol witness extractor."""
    return affine_extract_1d(z1, z2, c1, c2, q)


def chaum_pedersen_extract(z1: int, z2: int, c1: int, c2: int, q: int) -> int:
    """Chaum–Pedersen protocol witness extractor (identical to Schnorr at scalar level)."""
    return affine_extract_1d(z1, z2, c1, c2, q)


def okamoto_extract(z11: int, z12: int, z21: int, z22: int,
                    c1: int, c2: int, q: int) -> Tuple[int, int]:
    """
    Okamoto protocol witness extractor.

    Given two transcripts (c₁, z₁₁, z₁₂) and (c₂, z₂₁, z₂₂),
    extracts (w₁, w₂) where z_i1 = r₁ + c_i·w₁ and z_i2 = r₂ + c_i·w₂.
    """
    w1 = affine_extract_1d(z11, z21, c1, c2, q)
    w2 = affine_extract_1d(z12, z22, c1, c2, q)
    return w1, w2


if __name__ == "__main__":
    # Quick self-test
    q = 31
    w = 8
    r = 7
    c1, c2 = 4, 23

    z1 = (r + c1 * w) % q
    z2 = (r + c2 * w) % q

    w_ext = schnorr_extract(z1, z2, c1, c2, q)
    print(f"Schnorr self-test: w={w}, extracted={w_ext}, match={w==w_ext}")

    # Matrix extraction test
    M = [[2, 3], [5, 7]]
    witness = [4, 9]
    t = [1, 6]
    Mw = matrix_mul_vec(M, witness, q)
    z1_v = [(t[i] + c1 * Mw[i]) % q for i in range(2)]
    z2_v = [(t[i] + c2 * Mw[i]) % q for i in range(2)]

    result = full_extraction_pipeline(M, z1_v, z2_v, c1, c2, q)
    print(f"Matrix self-test: w={witness}, extracted={result.witness}, "
          f"match={witness==result.witness}")
