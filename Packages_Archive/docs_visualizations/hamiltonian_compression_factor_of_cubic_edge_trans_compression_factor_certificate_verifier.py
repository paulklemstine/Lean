from typing import Callable, List

def verify_certificate(n: int,
                       adj: Callable[[int, int], bool],
                       order: List[int],
                       auto: Callable[[int], int]) -> bool:
    d: int = (n // 2) % n
    consecutive: bool = all(adj(order[i], order[(i + 1) % n]) for i in range(n))
    edges = [(a, b) for a in range(n) for b in range(n) if adj(a, b)]
    preserves: bool = all(adj(auto(a), auto(b)) for (a, b) in edges)
    involutive: bool = all(auto(auto(x)) == x for x in range(n))
    nontrivial: bool = any(auto(x) != x for x in range(n))
    rotation: bool = all(auto(order[i]) == order[(i + d) % n] for i in range(n))
    return consecutive and preserves and involutive and nontrivial and rotation
