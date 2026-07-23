from typing import Dict, Tuple

def counting_refutation(n: int,
                        x: Dict[Tuple[int, int], int]) -> Tuple[int, int, int]:
    pigeons = range(n + 1)
    holes = range(n)
    for p in pigeons:
        assert sum(x[(p, h)] for h in holes) >= 1   # pigeon lower bound
    for h in holes:
        assert sum(x[(p, h)] for p in pigeons) <= 1  # hole upper bound
    total = sum(x[(p, h)] for p in pigeons for h in holes)
    lower, upper = n + 1, n
    # The counting refutation: lower <= total <= upper, i.e. n+1 <= n.
    return lower, upper, total
