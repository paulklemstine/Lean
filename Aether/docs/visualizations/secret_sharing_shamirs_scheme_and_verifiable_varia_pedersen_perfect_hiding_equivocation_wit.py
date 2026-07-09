from typing import List, Sequence

def modinv(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)

def pedersen_commit(coeffs: Sequence[int], blind: Sequence[int],
                    g: int, h: int, p: int) -> List[int]:
    """C_j = a_j * g + a'_j * h."""
    return [((a * g) + (b * h)) % p for a, b in zip(coeffs, blind)]

def equivocate(coeffs: Sequence[int], target: Sequence[int],
               g: int, h: int, p: int) -> List[int]:
    """Perfect-hiding witness: blinding b_j = (C_j - a_j*g)/h makes the
    Pedersen commitment of `coeffs` equal `target` (pedersen_perfect_hiding,
    requires h != 0). Hence any secret can explain any commitment vector."""
    return [((cj - a * g) * modinv(h, p)) % p for a, cj in zip(coeffs, target)]
