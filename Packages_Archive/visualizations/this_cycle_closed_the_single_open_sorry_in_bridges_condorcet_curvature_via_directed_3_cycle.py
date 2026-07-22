from itertools import product
from typing import List, Sequence

def condorcet_curvature(profile: List[Sequence[int]], n: int) -> int:
    """Number of directed majority 3-cycles (the discrete curvature).

    profile[i][a] is the rank of alternative a for voter i (smaller=preferred).
    """
    def support(a: int, b: int) -> int:
        return sum(1 for r in profile if r[a] < r[b])
    def beats(a: int, b: int) -> bool:
        return support(a, b) > support(b, a)
    return sum(
        1 for a, b, c in product(range(n), repeat=3)
        if beats(a, b) and beats(b, c) and beats(c, a)
    )
