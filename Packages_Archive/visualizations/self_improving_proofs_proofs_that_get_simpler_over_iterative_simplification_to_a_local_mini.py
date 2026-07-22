from typing import Callable, Hashable, List

def iterative_simplify(
    step: Callable[[Hashable], Hashable],
    complexity: Callable[[Hashable], int],
    start: Hashable,
    max_iters: int = 10 ** 6,
) -> Hashable:
    current: Hashable = start
    for _ in range(max_iters):
        nxt = step(current)
        if complexity(nxt) >= complexity(current):
            return current
        current = nxt
    return current
