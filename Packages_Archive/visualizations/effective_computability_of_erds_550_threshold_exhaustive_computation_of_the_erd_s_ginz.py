from typing import List
from itertools import combinations
from typing import Optional, Sequence, Tuple


def egz_constant_bruteforce(n: int) -> int:
    """Compute EGZ(n) = least m such that every length-m sequence over Z/nZ has
    a size-n zero-sum subset. Exhaustive; verifies the closed form 2n-1."""
    from itertools import product

    def has_property(m: int) -> bool:
        for seq in product(range(n), repeat=m):
            if not any(
                sum(seq[i] for i in c) % n == 0
                for c in combinations(range(m), n)
            ):
                return False
        return True

    m = n
    while not has_property(m):
        m += 1
    return m
