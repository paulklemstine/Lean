from typing import Callable, List, Tuple, Optional


def collatz_step(n: int) -> int:
    """Collatz step map T: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def md_hash(f: Callable[[int, int], int], iv: int, msg: List[int]) -> int:
    """Merkle-Damgard hash: left-fold the compression function f over blocks."""
    state = iv
    for block in msg:
        state = f(state, block)
    return state


def extract_compression_collision(
    f: Callable[[int, int], int],
    iv: int,
    m1: List[int],
    m2: List[int],
) -> Optional[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Constructive Merkle-Damgard collision extraction (md_collision_extract).

    Given distinct equal-length messages that hash to the same value, return a
    compression-function collision ((s1, b1), (s2, b2)) with distinct inputs and
    equal image. Compare last blocks with their chaining states; if they differ
    that is the collision, otherwise recurse on the strictly shorter prefixes.
    """
    assert len(m1) == len(m2), "messages must have equal length"
    a, b = list(m1), list(m2)
    while a and b:
        p1, last1 = a[:-1], a[-1]
        p2, last2 = b[:-1], b[-1]
        s1 = md_hash(f, iv, p1)
        s2 = md_hash(f, iv, p2)
        if (s1, last1) != (s2, last2):
            assert f(s1, last1) == f(s2, last2)
            return (s1, last1), (s2, last2)
        a, b = p1, p2
    return None
