from itertools import combinations
from typing import FrozenSet

def is_three_ap_free(subset: FrozenSet[int]) -> bool:
    for b in subset:
        for a in subset:
            if a == b:
                continue
            c = 2 * b - a
            if c in subset and c != b:
                return False
    return True

def roth_number(n: int) -> int:
    for size in range(n, 0, -1):
        for combo in combinations(range(n), size):
            if is_three_ap_free(frozenset(combo)):
                return size
    return 0
