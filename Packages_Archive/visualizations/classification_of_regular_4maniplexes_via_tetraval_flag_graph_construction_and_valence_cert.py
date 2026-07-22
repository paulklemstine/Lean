from typing import Dict, Hashable, List, Set

Flag = Hashable
Involution = Dict[Flag, Flag]


def flag_graph_degrees(flags: List[Flag],
                       sigmas: List[Involution]) -> Dict[Flag, int]:
    """Build the flag graph N(v) = {sigma_i(v)} and return vertex degrees.

    By the regularity theorem every returned degree equals len(sigmas).
    Runs in O(len(sigmas) * |flags|).
    """
    nb: Dict[Flag, Set[Flag]] = {v: set() for v in flags}
    for v in flags:
        for s in sigmas:
            nb[v].add(s[v])
            nb[s[v]].add(v)
    return {v: len(nb[v]) for v in flags}


def is_regular_of_degree(flags, sigmas, d: int) -> bool:
    return all(deg == d for deg in flag_graph_degrees(flags, sigmas).values())
