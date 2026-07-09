from math import comb
from typing import List

def companion_pair(n_max: int) -> List[tuple]:
    """Build the coupled pair (A(n), B(n)) for n = 0..n_max using the Pascal
    recurrences B(n+1) = A(n) + B(n) and A(n+1) = A(n) + B(n+1).
    Returns A(n) = F_{2n+1} (even lower index) and B(n) = F_{2n} (odd lower index)."""
    pairs: List[tuple] = [(1, 0)]   # (A(0), B(0)) = (1, 0)
    for _ in range(n_max):
        a, b = pairs[-1]
        b_next = a + b              # B(n+1) = A(n) + B(n)
        a_next = a + b_next        # A(n+1) = A(n) + B(n+1)
        pairs.append((a_next, b_next))
    return pairs[: n_max + 1]

def verify_against_binomials(n_max: int) -> bool:
    """Cross-check the coupled iteration against direct binomial sums."""
    pairs = companion_pair(n_max)
    for n, (a, b) in enumerate(pairs):
        a_dir = sum(comb(n + k, 2 * k) for k in range(n + 1))
        b_dir = sum(comb(n + k, 2 * k + 1) for k in range(n + 1))
        if (a, b) != (a_dir, b_dir):
            return False
    return True
