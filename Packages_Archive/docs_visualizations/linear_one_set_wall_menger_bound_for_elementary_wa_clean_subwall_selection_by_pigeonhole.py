from typing import List, Set

def clean_subwall(subwalls: List[Set[int]], X: Set[int],
                  endpoints: Set[int]) -> Set[int]:
    blocked = X | endpoints
    for w in subwalls:
        if not (w & blocked):
            return w
    raise RuntimeError('pigeonhole guarantees a clean subwall')
