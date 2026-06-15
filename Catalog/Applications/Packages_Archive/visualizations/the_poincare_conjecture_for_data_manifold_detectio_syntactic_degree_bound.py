from dataclasses import dataclass
from typing import Union

@dataclass
class Const:
    value: float
@dataclass
class Var:
    index: int
@dataclass
class Add:
    left: 'Circuit'
    right: 'Circuit'
@dataclass
class Mul:
    left: 'Circuit'
    right: 'Circuit'
Circuit = Union[Const, Var, Add, Mul]

def degree_bound(circuit: Circuit) -> int:
    """Syntactic degree bound. O(size) time."""
    match circuit:
        case Const(): return 0
        case Var(): return 1
        case Add(left=l, right=r): return max(degree_bound(l), degree_bound(r))
        case Mul(left=l, right=r): return degree_bound(l) + degree_bound(r)

def depth(circuit: Circuit) -> int:
    match circuit:
        case Const() | Var(): return 0
        case Add(left=l, right=r) | Mul(left=l, right=r): return 1 + max(depth(l), depth(r))

# Iterated squaring: degree doubles each step
c = Var(0)
for _ in range(5):
    print(f'depth={depth(c)}, degree_bound={degree_bound(c)}, 2^depth={2**depth(c)}')
    c = Mul(c, c)