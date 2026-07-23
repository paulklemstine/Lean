from typing import List, Sequence, Tuple

def weight_certificate(alpha: Sequence[int], f: Sequence[int],
                       k: int, p: int) -> Tuple[int, int, bool]:
    """Return (weight, n-k+1 bound, holds) for evalVec of f at alpha over GF(p)."""
    def horner(coeffs: Sequence[int], x: int) -> int:
        acc = 0
        for c in reversed(coeffs):
            acc = (acc * x + c) % p
        return acc
    n: int = len(alpha)
    z: int = sum(1 for a in alpha if horner(f, a) == 0)
    weight: int = n - z
    bound: int = n - k + 1
    return weight, bound, weight >= bound