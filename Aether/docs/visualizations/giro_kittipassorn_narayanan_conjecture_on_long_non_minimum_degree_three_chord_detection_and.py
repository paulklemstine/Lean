from typing import Dict, List, Set

def arc_cycle_from_chord(n: int, a: int, b: int) -> List[int]:
    k: int = (b - a) % n
    return [(a + j) % n for j in range(k + 1)]

def longer_arc(n: int, a: int, b: int) -> List[int]:
    k_fwd, k_bwd = (b - a) % n, (a - b) % n
    return (arc_cycle_from_chord(n, a, b) if k_fwd >= k_bwd
            else arc_cycle_from_chord(n, b, a))

def long_cycle_through(n: int, adjacency: Dict[int, Set[int]], v: int) -> List[int]:
    """Long second cycle through v, assuming minimum degree three."""
    frame: Set[int] = {(v + 1) % n, (v - 1) % n}
    for w in adjacency[v]:
        if w not in frame and w != v:
            return longer_arc(n, v, w)
    raise ValueError("minimum degree three violated: no chord at v")
