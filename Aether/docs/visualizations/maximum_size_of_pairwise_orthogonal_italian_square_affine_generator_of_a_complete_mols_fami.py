from typing import Callable, Dict, List

def affine_mols(order: int,
                add: Callable[[int, int], int],
                mul: Callable[[int, int], int],
                zero: int = 0) -> Dict[int, List[List[int]]]:
    """Generate the n-1 affine MOLS S_a(i,j) = a*i + j over a field of given order.

    `add`, `mul` implement the field operations on the labels 0..order-1;
    `zero` is the additive identity. Returns a dict slope -> square.
    """
    family: Dict[int, List[List[int]]] = {}
    for a in range(order):
        if a == zero:
            continue
        family[a] = [[add(mul(a, i), j) for j in range(order)] for i in range(order)]
    return family
