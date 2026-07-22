from itertools import product, permutations
from typing import List

def neighborhood_rotation() -> List[int]:
    """Permutation of the 8 neighborhoods induced by (l,m,r) -> (m,r,l)."""
    perm = [0] * 8
    for l, m, r in product((0, 1), repeat=3):
        src = (l << 2) | (m << 1) | r
        dst = (m << 2) | (r << 1) | l
        perm[src] = dst
    return perm

def centralizer_size(perm: List[int]) -> int:
    """Order of the centralizer of perm in the symmetric group S_len(perm)."""
    k = len(perm)
    return sum(
        1 for g in permutations(range(k))
        if all(g[perm[x]] == perm[g[x]] for x in range(k))
    )

def debunk_conjecture() -> int:
    """Return the true centralizer order (36), refuting the 10080 claim."""
    return centralizer_size(neighborhood_rotation())
