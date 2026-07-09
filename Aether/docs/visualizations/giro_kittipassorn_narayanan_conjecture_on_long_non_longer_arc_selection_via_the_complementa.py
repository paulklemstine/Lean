from typing import List

def arc_cycle_from_chord(n: int, a: int, b: int) -> List[int]:
    k: int = (b - a) % n
    return [(a + j) % n for j in range(k + 1)]

def longer_arc(n: int, a: int, b: int) -> List[int]:
    """Return the longer of the two arc cycles of chord {a, b}."""
    k_fwd: int = (b - a) % n
    k_bwd: int = (a - b) % n
    return (arc_cycle_from_chord(n, a, b) if k_fwd >= k_bwd
            else arc_cycle_from_chord(n, b, a))
