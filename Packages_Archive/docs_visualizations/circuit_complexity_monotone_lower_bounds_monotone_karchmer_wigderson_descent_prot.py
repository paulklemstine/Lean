from typing import Dict, Optional
Assignment = Dict[int, bool]

class Node:
    def __init__(self, kind: str, idx: Optional[int] = None,
                 left: "Optional[Node]" = None, right: "Optional[Node]" = None) -> None:
        self.kind, self.idx, self.left, self.right = kind, idx, left, right

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

def kw_find(C: Node, x: Assignment, y: Assignment) -> Optional[int]:
    """Descend a monotone circuit with C(x)=true, C(y)=false to a separating index."""
    if C.kind == "var":
        return C.idx
    if C.kind in ("top", "bot"):
        return None
    assert C.left and C.right
    if C.kind == "and":
        return kw_find(C.left, x, y) if not evaluate(C.left, y) else kw_find(C.right, x, y)
    return kw_find(C.left, x, y) if evaluate(C.left, x) else kw_find(C.right, x, y)

def kw_cost(C: Node, x: Assignment, y: Assignment) -> int:
    if C.kind in ("var", "top", "bot"):
        return 0
    assert C.left and C.right
    if C.kind == "and":
        child = C.left if not evaluate(C.left, y) else C.right
    else:
        child = C.left if evaluate(C.left, x) else C.right
    return kw_cost(child, x, y) + 1
