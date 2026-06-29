from dataclasses import dataclass
from typing import Union
import random

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

def evaluate(c: Circuit, v: list[float]) -> float:
    match c:
        case Const(value=val): return val
        case Var(index=i): return v[i]
        case Add(left=l, right=r): return evaluate(l, v) + evaluate(r, v)
        case Mul(left=l, right=r): return evaluate(l, v) * evaluate(r, v)

def degree_bound(c: Circuit) -> int:
    match c:
        case Const(): return 0
        case Var(): return 1
        case Add(left=l, right=r): return max(degree_bound(l), degree_bound(r))
        case Mul(left=l, right=r): return degree_bound(l) + degree_bound(r)

def pit_test(circuit: Circuit, n_vars: int, trials: int = 100, field_size: int = 10000) -> bool:
    """Returns True if circuit is likely non-zero, False if likely zero.
    Error probability ≤ (degree_bound / field_size)^trials."""
    for _ in range(trials):
        v = [random.randint(-field_size, field_size) for _ in range(n_vars)]
        if abs(evaluate(circuit, [float(x) for x in v])) > 1e-10:
            return True  # Definitely non-zero
    return False  # Likely zero

# Test: (x+y)^2 - x^2 - 2xy - y^2 = 0
x, y = Var(0), Var(1)
c = Add(Mul(Add(x,y), Add(x,y)), Mul(Const(-1), Add(Add(Mul(x,x), Mul(Const(2), Mul(x,y))), Mul(y,y))))
print(f'Is non-zero: {pit_test(c, 2)}')  # False (it's zero)
print(f'x^2+1 is non-zero: {pit_test(Add(Mul(x,x), Const(1)), 2)}')  # True