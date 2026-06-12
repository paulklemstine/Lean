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

def evaluate(circuit: Circuit, assignment: list[float]) -> float:
    """Evaluate circuit on assignment. O(size) time, O(depth) stack."""
    match circuit:
        case Const(value=v): return v
        case Var(index=i): return assignment[i]
        case Add(left=l, right=r): return evaluate(l, assignment) + evaluate(r, assignment)
        case Mul(left=l, right=r): return evaluate(l, assignment) * evaluate(r, assignment)

# Example: f(x,y) = (x+y)*x
c = Mul(Add(Var(0), Var(1)), Var(0))
print(evaluate(c, [3.0, 2.0]))  # (3+2)*3 = 15.0