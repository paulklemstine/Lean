from typing import List

def quadratic_sidon(p: int) -> List[int]:
    """Quadratic Sidon construction Q_p = {2p*i + (i^2 mod p) : 0 <= i < p},
    living inside {1, ..., 2p^2}. For prime p this attains order sqrt(N).
    Runs in O(p) time."""
    return [2 * p * i + (i * i) % p for i in range(p)]
