from typing import Dict, Tuple

Var = Tuple[int, int]

def counting_refutation(n: int, x: Dict[Var, int]) -> Tuple[int, int, int]:
    for p in range(n + 1):
        assert sum(x[(p, h)] for h in range(n)) >= 1
    for h in range(n):
        assert sum(x[(p, h)] for p in range(n + 1)) <= 1
    total = sum(x[(p, h)] for p in range(n + 1) for h in range(n))
    return n + 1, total, n
