from typing import Dict, List, Sequence

def poly_eval(coeffs: Sequence[int], x: int, p: int) -> int:
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % p
    return acc

def shamir_share(secret: int, threshold: int, xs: Sequence[int], p: int,
                 randomness: Sequence[int]) -> Dict[int, int]:
    """Deal (t, n) Shamir shares: f(X) = secret + sum_k randomness[k-1] X^k."""
    assert len(randomness) == threshold - 1
    coeffs: List[int] = [secret % p] + [r % p for r in randomness]
    return {x: poly_eval(coeffs, x, p) for x in xs}
