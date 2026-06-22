from itertools import product
from typing import Dict, List, Sequence, Tuple

def copeland_potential(profile: List[Sequence[int]], n: int
                       ) -> Tuple[Dict[int, int], bool]:
    """Compute the Copeland potential and a flatness certificate.

    Returns (f, ok): f[a] = (#beaten by a) - (#that beat a). If ok is True the
    majority tournament is transitive and  beats(a,b) <=> f[a] > f[b]  for all
    a != b  (a coboundary / 'social utility'); if ok is False a 3-cycle exists.
    """
    def support(a: int, b: int) -> int:
        return sum(1 for r in profile if r[a] < r[b])
    def beats(a: int, b: int) -> bool:
        return support(a, b) > support(b, a)
    f: Dict[int, int] = {}
    for a in range(n):
        wins = sum(1 for b in range(n) if b != a and beats(a, b))
        losses = sum(1 for b in range(n) if b != a and beats(b, a))
        f[a] = wins - losses
    ok = all(beats(a, b) == (f[a] > f[b])
             for a, b in product(range(n), repeat=2) if a != b)
    return f, ok
