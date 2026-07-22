from typing import Callable, List, Tuple

State = int
Block = bool

def md_hash(f: Callable[[State, Block], State], iv: State,
            msg: List[Block]) -> State:
    """Merkle-Damgard iterated hash: left-fold f over msg (mdHash)."""
    s = iv
    for b in msg:
        s = f(s, b)
    return s

def extract_compression_collision(
    f: Callable[[State, Block], State], iv: State,
    m1: List[Block], m2: List[Block]
) -> Tuple[Tuple[State, Block], Tuple[State, Block]]:
    """Algorithm A (md_collision_extract): turn an equal-length MD collision
    into an explicit compression collision by scanning from the last block."""
    assert len(m1) == len(m2) and m1 != m2
    assert md_hash(f, iv, m1) == md_hash(f, iv, m2)
    a, b = list(m1), list(m2)
    while True:
        c1 = md_hash(f, iv, a[:-1])
        c2 = md_hash(f, iv, b[:-1])
        in1, in2 = (c1, a[-1]), (c2, b[-1])
        if in1 != in2:
            assert f(*in1) == f(*in2)
            return in1, in2
        a, b = a[:-1], b[:-1]
