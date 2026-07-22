from typing import Optional


def rank_of_apparition(p: int, limit: int = 100_000) -> Optional[int]:
    """Least k > 0 with p | F(k), computed modulo p.

    By the descent step (Theorem 3.5) the set {k : p | F(k)} is closed under
    gcd, hence equals the multiples of its least positive element -- the rank.
    Reducing modulo p keeps all intermediates below p.
    Complexity: O(period) iterations, bounded by the Pisano period (O(p)).
    """
    a, b = 0, 1  # F(0), F(1)
    for k in range(1, limit + 1):
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
    return None
