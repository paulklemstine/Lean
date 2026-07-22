from typing import Dict, Hashable, List, Set, Tuple

Flag = Hashable
Involution = Dict[Flag, Flag]


def orbit_partition(flags: List[Flag],
                    sigma: Involution) -> List[Tuple[Flag, Flag]]:
    """Partition flags into the 2-element orbits of a fixed-point-free
    involution, witnessing that |flags| is even. Runs in O(|flags|)."""
    seen: Set[Flag] = set()
    orbits: List[Tuple[Flag, Flag]] = []
    for x in flags:
        if x not in seen:
            y = sigma[x]
            if y == x:
                raise ValueError("sigma has a fixed point; not a maniplex involution")
            orbits.append((x, y))
            seen.add(x)
            seen.add(y)
    return orbits
