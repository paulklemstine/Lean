from __future__ import annotations
from typing import Callable, Dict, List, Sequence, Tuple


def clog(base: int, n: int) -> int:
    if base <= 1 or n <= 1:
        return 0
    k, power = 0, 1
    while power < n:
        power *= base
        k += 1
    return k


def bit_predicate(i: int) -> Callable[[int], bool]:
    return lambda a: bool((a >> i) & 1)


def optimal_static_system(card: int) -> List[Callable[[int], bool]]:
    d: int = clog(2, card)
    return [bit_predicate(i) for i in range(d)]


def distinguishes(preds: Sequence[Callable[[int], bool]],
                  elements: Sequence[int]) -> bool:
    seen: Dict[Tuple[bool, ...], int] = {}
    for a in elements:
        prof = tuple(p(a) for p in preds)
        if prof in seen:
            return False
        seen[prof] = a
    return True
