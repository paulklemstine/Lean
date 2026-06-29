from typing import Callable, List, Optional, Tuple, TypeVar

State = TypeVar('State')
Block = TypeVar('Block')

def md_hash(f, iv, msg):
    state = iv
    for block in msg:
        state = f(state, block)
    return state

def extract_compression_collision(
    f: Callable[[State, Block], State],
    iv: State,
    m1: List[Block],
    m2: List[Block],
) -> Optional[Tuple[Tuple[State, Block], Tuple[State, Block]]]:
    if len(m1) != len(m2) or m1 == m2:
        return None
    if md_hash(f, iv, m1) != md_hash(f, iv, m2):
        return None
    p1, p2 = m1[:], m2[:]
    while p1 and p2:
        b1, b2 = p1[-1], p2[-1]
        s1 = md_hash(f, iv, p1[:-1])
        s2 = md_hash(f, iv, p2[:-1])
        if (s1, b1) != (s2, b2):
            assert f(s1, b1) == f(s2, b2)
            return ((s1, b1), (s2, b2))
        p1, p2 = p1[:-1], p2[:-1]
    return None
