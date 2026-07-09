from typing import Tuple

Vector = Tuple[int, ...]


def shatter(u: Vector, v: Vector) -> bool:
    """Binary qualitative-independence test in O(k) time, O(1) space.

    Maintain a 4-bit mask of observed patterns; bit (2*u_i + v_i) is set when
    that pattern occurs.  The pair shatters (== is good, for b = 2) iff all four
    bits are set after one scan.  By `shatter_containsCycle` this certifies a
    genuine 4-cycle in the pair graph.
    """
    mask = 0
    for ui, vi in zip(u, v):
        mask |= 1 << (2 * ui + vi)
    return mask == 0b1111
