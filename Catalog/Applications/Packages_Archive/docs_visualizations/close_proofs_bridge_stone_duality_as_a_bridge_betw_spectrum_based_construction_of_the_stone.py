from typing import FrozenSet, List

def full_mask(n: int) -> int:
    return (1 << n) - 1

def stone_space(n: int) -> List[int]:
    # Points = prime ideals = atoms of the ground set.
    return list(range(n))

def basic_open(r: int, n: int) -> FrozenSet[int]:
    # D(r) = { points i : r not in m_i } = { i : i in r }.
    return frozenset(i for i in range(n) if (r >> i) & 1)
