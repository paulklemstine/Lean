from typing import List, Tuple

Cfg = Tuple[bool, ...]

def neighbours(a: Cfg) -> List[Cfg]:
    return [tuple(not x if j == i else x for j, x in enumerate(a))
            for i in range(len(a))]

def degree(a: Cfg) -> int:
    return len(neighbours(a))  # equals d (flipGraph_degree)
