from math import gcd
from typing import Dict, List, Tuple

def reconstruct_divisibility_lattice(eigenvalues: List[int], c: int) -> Dict[Tuple[int, int], bool]:
    """Given public leaked eigenvalues a(t_j) = c * t_j and the public scale c,
    reconstruct the divisibility relations among the secret exponents t_j.

    By the strong-divisibility property, t_i | t_j  <=>  a(t_i) | a(t_j),
    so divisibility can be read off the eigenvalues directly (or after dividing by c).
    Returns a map (i, j) -> whether secret_i divides secret_j."""
    secrets = [e // c for e in eigenvalues]
    relations: Dict[Tuple[int, int], bool] = {}
    for i, si in enumerate(secrets):
        for j, sj in enumerate(secrets):
            relations[(i, j)] = (sj % si == 0)
    return relations
