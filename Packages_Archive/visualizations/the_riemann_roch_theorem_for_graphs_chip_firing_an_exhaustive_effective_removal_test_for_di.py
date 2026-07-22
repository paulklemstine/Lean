from itertools import combinations_with_replacement
from typing import Callable, Iterator, Sequence

def effective_divisors(n: int, q: int) -> Iterator[tuple[int, ...]]:
    for positions in combinations_with_replacement(range(n), q):
        e = [0] * n
        for i in positions:
            e[i] += 1
        yield tuple(e)

def rank_at_least(
    divisor: Sequence[int], q: int,
    has_effective_representative: Callable[[Sequence[int]], bool]
) -> bool:
    n = len(divisor)
    return all(
        has_effective_representative([divisor[i] - e[i] for i in range(n)])
        for e in effective_divisors(n, q)
    )
