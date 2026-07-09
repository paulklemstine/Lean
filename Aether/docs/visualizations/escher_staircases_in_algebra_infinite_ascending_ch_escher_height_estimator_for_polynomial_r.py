from typing import List, Optional, Set, Tuple, Union

def escher_height(
    num_vars: Union[int, str],
    depth: int = 8,
) -> Tuple[str, Optional[List[Set[int]]]]:
    """Return (Escher height, optional certificate staircase of variable ideals).

    num_vars: a nonnegative int (finite) or 'infinity'.
    Finite  -> ('0', None) by the Hilbert Basis Theorem.
    Infinite-> ('infinite (>= omega)', [ {0..n-1} for n in 0..depth ]).
    """
    if num_vars == "infinity":
        chain = [set(range(n)) for n in range(depth + 1)]
        return ("infinite (>= omega)", chain)
    return ("0", None)
