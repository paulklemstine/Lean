from typing import List, Optional, Sequence, Tuple
from itertools import combinations


def is_prime(p: int) -> bool:
    if p < 2:
        return False
    i = 2
    while i * i <= p:
        if p % i == 0:
            return False
        i += 1
    return True


def find_zero_sum_subset_prime(seq: Sequence[int], p: int) -> Tuple[int, ...]:
    """O(p log p) extraction of a size-p zero-sum subset for a PRIME modulus p.

    Requires len(seq) >= 2p - 1. Sort the residues; if some window of p equal
    consecutive sorted values exists, return it (their sum is p * value == 0
    mod p); otherwise a pigeonhole on the p-1 gaps selects one element from each
    consecutive pair so the total vanishes mod p.
    """
    assert is_prime(p)
    assert len(seq) >= 2 * p - 1
    indexed = sorted(range(len(seq)), key=lambda i: seq[i] % p)
    b = [seq[i] % p for i in indexed]
    for i in range(0, len(b) - p + 1):
        if b[i] == b[i + p - 1]:
            return tuple(sorted(indexed[i:i + p]))
    chosen = [indexed[0]]
    running = b[0] % p
    for i in range(1, p):
        lo, hi = b[i], b[i + p - 1]
        if (running + lo) % p <= (running + hi) % p:
            chosen.append(indexed[i]); running = (running + lo) % p
        else:
            chosen.append(indexed[i + p - 1]); running = (running + hi) % p
    if running % p == 0:
        return tuple(sorted(chosen))
    for combo in combinations(range(len(seq)), p):
        if sum(seq[j] for j in combo) % p == 0:
            return combo
    raise AssertionError("EGZ guarantees a subset exists")
