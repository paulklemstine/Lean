from typing import List, Sequence

def feldman_commit(coeffs: Sequence[int], g: int, p: int) -> List[int]:
    """Public coefficient commitments C_j = a_j * g (additive group model)."""
    return [(c * g) % p for c in coeffs]

def feldman_verify(commitments: Sequence[int], x: int, s: int, g: int, p: int) -> bool:
    """Accept the claimed share (x, s) iff s*g == sum_j x^j C_j (mod p)."""
    lhs = (s * g) % p
    rhs, xpow = 0, 1
    for cj in commitments:
        rhs = (rhs + xpow * cj) % p
        xpow = (xpow * x) % p
    return lhs == rhs
