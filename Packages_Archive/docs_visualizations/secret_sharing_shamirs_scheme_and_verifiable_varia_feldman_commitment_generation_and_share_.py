from typing import List, Sequence

def feldman_commit(coeffs: Sequence[int], g: int, p: int) -> List[int]:
    """C_j = a_j * g  (additive-group convention)."""
    return [(a * g) % p for a in coeffs]

def feldman_verify(commit: Sequence[int], g: int, x: int, s: int, p: int) -> bool:
    """Accept the claimed share s at node x iff s*g == sum_j x^j * C_j.
    By feldman_verify_iff this holds iff s equals the committed evaluation,
    so any forged share is rejected (feldman_catches_cheater)."""
    rhs = sum(pow(x, j, p) * c for j, c in enumerate(commit)) % p
    return (s * g) % p == rhs
