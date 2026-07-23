from typing import Callable, List, Optional, Tuple

Compress = Callable[[int, int], int]
Pair = Tuple[int, int]

def extract_compress_collision(
    f: Compress, iv: int, m1: List[int], m2: List[int]
) -> Optional[Tuple[Pair, Pair]]:
    """From an equal-length MD collision, extract a compression collision."""
    assert len(m1) == len(m2)
    s1: int = iv
    s2: int = iv
    for b1, b2 in zip(m1, m2):
        o1, o2 = f(s1, b1), f(s2, b2)
        if (s1, b1) != (s2, b2) and o1 == o2:
            return (s1, b1), (s2, b2)
        s1, s2 = o1, o2
    return None
