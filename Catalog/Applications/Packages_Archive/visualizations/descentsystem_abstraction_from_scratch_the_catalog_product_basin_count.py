from typing import Callable, Hashable, List, Sequence, Tuple

State = Hashable
System = Tuple[Sequence[State], Callable[[State], State], Callable[[State], int]]

def product_basin_count(systems: List[System]) -> int:
    """Number of basins of the synchronous product = product of factor counts."""
    total = 1
    for states, step, _energy in systems:
        fixed = sum(1 for s in states if step(s) == s)
        total *= fixed
    return total