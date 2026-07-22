from math import gcd
from typing import List, Tuple

def diag_graph(n: int, b: int) -> List[Tuple[int, int]]:
    """Full slope-2 n-queens solution; valid iff gcd(n, 6) == 1."""
    assert gcd(n, 6) == 1, 'requires gcd(n,6)=1'
    return [(x, (2 * x + b) % n) for x in range(n)]
