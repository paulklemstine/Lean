from typing import Callable, Dict, List, Optional
Assignment = Dict[int, bool]
BoolFn = Callable[[Assignment], bool]

class Node:
    def __init__(self, kind: str, idx: Optional[int] = None,
                 left: "Optional[Node]" = None, right: "Optional[Node]" = None) -> None:
        self.kind, self.idx, self.left, self.right = kind, idx, left, right

def num_gates(C: Node) -> int:
    if C.kind in ("var", "top", "bot"):
        return 0
    assert C.left and C.right
    return num_gates(C.left) + num_gates(C.right) + 1

def evaluate(C: Node, x: Assignment) -> bool:
    if C.kind == "var":
        assert C.idx is not None
        return x[C.idx]
    if C.kind == "top":
        return True
    if C.kind == "bot":
        return False
    assert C.left and C.right
    a, b = evaluate(C.left, x), evaluate(C.right, x)
    return (a and b) if C.kind == "and" else (a or b)

def approx_eval(R: Callable[[BoolFn], BoolFn], C: Node, x: Assignment) -> bool:
    if C.kind == "var":
        assert C.idx is not None
        return x[C.idx]
    if C.kind == "top":
        return True
    if C.kind == "bot":
        return False
    assert C.left and C.right
    if C.kind == "and":
        g: BoolFn = lambda z: approx_eval(R, C.left, z) and approx_eval(R, C.right, z)
    else:
        g = lambda z: approx_eval(R, C.left, z) or approx_eval(R, C.right, z)
    return R(g)(x)

def approximation_lower_bound(C: Node, R: Callable[[BoolFn], BoolFn],
                              T: List[Assignment], delta: int) -> float:
    """Return the proven size lower bound E / delta for circuit C under rounding R."""
    E = sum(1 for x in T if evaluate(C, x) != approx_eval(R, C, x))
    assert E <= num_gates(C) * delta, "error-accumulation invariant violated"
    return E / delta if delta else 0.0
