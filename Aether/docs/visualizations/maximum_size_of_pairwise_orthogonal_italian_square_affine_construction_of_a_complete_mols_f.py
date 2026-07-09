from typing import Callable, List

Square = List[List[int]]

def affine_mols_family(
    elems: List[int],
    add: Callable[[int, int], int],
    mul: Callable[[int, int], int],
) -> List[Square]:
    """Return the n-1 affine squares S_a(i,j) = a*i + j for nonzero slopes a."""
    n = len(elems)
    family: List[Square] = []
    for a in elems:
        if a == 0:
            continue
        square: Square = [[add(mul(a, i), j) for j in range(n)] for i in range(n)]
        family.append(square)
    return family
