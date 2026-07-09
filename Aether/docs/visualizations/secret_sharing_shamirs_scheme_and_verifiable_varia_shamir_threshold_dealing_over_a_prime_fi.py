from typing import List, Sequence
import random

def deal_secret(secret: int, t: int, nodes: Sequence[int], p: int,
                rng: random.Random) -> List[int]:
    """Shamir dealing: encode `secret` as the constant term of a random
    degree-(t-1) polynomial over F_p and output one evaluation per node."""
    coeffs: List[int] = [secret % p] + [rng.randrange(p) for _ in range(t - 1)]
    shares: List[int] = []
    for x in nodes:
        acc = 0
        for c in reversed(coeffs):       # Horner evaluation
            acc = (acc * x + c) % p
        shares.append(acc)
    return shares
