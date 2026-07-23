from dataclasses import dataclass
from itertools import product
from typing import Tuple, Literal

@dataclass(frozen=True)
class Barrier:
    techniques: Tuple[str, ...]
    strength: Tuple[int, ...]
    ceiling: int

def compose(B1: Barrier, B2: Barrier, op: Literal['join', 'meet']) -> Barrier:
    agg = max if op == 'join' else min
    ts, ss = [], []
    for (t1, s1), (t2, s2) in product(zip(B1.techniques, B1.strength), zip(B2.techniques, B2.strength)):
        ts.append(f'({t1},{t2})')
        ss.append(agg(s1, s2))
    return Barrier(tuple(ts), tuple(ss), agg(B1.ceiling, B2.ceiling))

def blocks_fast(B1: Barrier, B2: Barrier, op: Literal['join', 'meet'], target: int) -> bool:
    b1, b2 = B1.ceiling < target, B2.ceiling < target
    return (b1 and b2) if op == 'join' else (b1 or b2)

def compose_and_block(B1: Barrier, B2: Barrier, op: Literal['join', 'meet'], target: int) -> bool:
    C = compose(B1, B2, op)            # full audit object
    assert all(s <= C.ceiling for s in C.strength)  # barrier axiom
    return blocks_fast(B1, B2, op, target)