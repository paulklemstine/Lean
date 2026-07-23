from typing import Callable, List, Tuple

def synthesize_two_symmetric(n: int) -> Tuple[List[int], Callable[[int], int]]:
    assert n % 2 == 0 and n >= 4, 'need even n >= 4'
    d: int = (n // 2) % n
    order: List[int] = list(range(n))
    auto: Callable[[int], int] = lambda x: (x + d) % n
    return order, auto
