from typing import Optional

def entry_point(p: int, search_limit: int = 10_000) -> Optional[int]:
    """Least k > 0 with p | F_k (rank of apparition), or None if not found.

    Works on residues mod p only, so arithmetic stays bounded. Terminates within
    the Pisano period (<= 6p by Wall's bound)."""
    if p == 1:
        return 1
    a, b = 0, 1  # a = F_0 mod p, b = F_1 mod p
    for k in range(1, search_limit + 1):
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
    return None
