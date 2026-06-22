from typing import Callable, List

def is_bijection_by_fibers(f: Callable[[int], int],
                           domain: List[int], codomain: List[int]) -> bool:
    for y in codomain:
        fiber = [x for x in domain if f(x) == y]
        if len(fiber) != 1:
            return False
    return True