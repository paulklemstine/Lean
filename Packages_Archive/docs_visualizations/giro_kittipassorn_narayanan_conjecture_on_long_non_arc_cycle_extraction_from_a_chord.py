from typing import List

def arc_cycle_from_chord(n: int, a: int, b: int) -> List[int]:
    """Return the arc cycle for chord {a, b}: [a, a+1, ..., b] (mod n)."""
    k: int = (b - a) % n
    return [(a + j) % n for j in range(k + 1)]
