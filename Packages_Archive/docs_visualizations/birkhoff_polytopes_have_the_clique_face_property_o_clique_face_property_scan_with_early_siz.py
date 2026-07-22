from itertools import combinations, permutations
from typing import List, Tuple
Perm = Tuple[int, ...]

def has_clique_face_property(n: int, max_size: int = 3) -> Tuple[bool, List[Perm]]:
    """Search cliques up to size `max_size`; return (holds, witness_if_failed).

    The obstruction (a transposition triangle) always appears at size 3, so a cap
    of 3 certifies failure for every n >= 3, while n <= 2 has no larger cliques.
    Requires `adjacent` and `is_face_vertex_set` from the companion algorithms.
    """
    verts: List[Perm] = [tuple(p) for p in permutations(range(n))]
    upper = min(max_size, len(verts))
    for size in range(1, upper + 1):
        for subset in combinations(verts, size):
            clique = list(subset)
            if all(adjacent(a, b) for a, b in combinations(clique, 2)):
                if not is_face_vertex_set(n, clique):
                    return False, clique
    return True, []
