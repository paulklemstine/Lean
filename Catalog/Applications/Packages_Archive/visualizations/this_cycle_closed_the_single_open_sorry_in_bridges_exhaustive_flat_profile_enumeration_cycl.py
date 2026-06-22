from itertools import permutations, product
from typing import List, Tuple

def flat_fraction(n: int, k: int) -> Tuple[int, int]:
    """Exhaustively enumerate all (n!)^k profiles and count flat ones.

    Returns (num_flat, num_total). 'Flat' means Condorcet curvature 0
    (transitive majority). This is the curvature-language version of the
    classic 'probability of a Condorcet cycle' computation.
    """
    rankings: List[Tuple[int, ...]] = []
    for p in permutations(range(n)):
        rank = [0] * n
        for pos, alt in enumerate(p):
            rank[alt] = pos
        rankings.append(tuple(rank))

    def support(profile, a, b):
        return sum(1 for r in profile if r[a] < r[b])
    def beats(profile, a, b):
        return support(profile, a, b) > support(profile, b, a)
    def curvature(profile):
        return sum(1 for a, b, c in product(range(n), repeat=3)
                   if beats(profile, a, b) and beats(profile, b, c)
                   and beats(profile, c, a))

    flat = total = 0
    for prof in product(rankings, repeat=k):
        total += 1
        if curvature(list(prof)) == 0:
            flat += 1
    return flat, total
