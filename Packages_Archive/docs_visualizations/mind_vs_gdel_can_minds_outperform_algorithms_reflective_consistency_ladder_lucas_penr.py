from typing import List, Set

def reflection_tower(levels: int) -> List[Set[int]]:
    """
    Build the reflective extension ladder F_0 < F_1 < ... where
    F_{n+1} = F_n + Con(F_n).  Integer n encodes the consistency statement
    Con(F_n) -- the new theorem the mind gains at step n+1.
    """
    tower: List[Set[int]] = [set()]
    for n in range(levels):
        tower.append(tower[-1] | {n})
    return tower

def escapes_union(tower: List[Set[int]]) -> int:
    """
    Return a fresh diagonal sentence that is provable at no finite level,
    witnessing that the union of the whole ladder is still incomplete.
    """
    union: Set[int] = set().union(*tower) if tower else set()
    return (max(union) + 1) if union else 0
