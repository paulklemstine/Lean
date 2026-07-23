from dataclasses import dataclass
from typing import Dict, Optional, Tuple

Assignment = Dict[int, bool]


@dataclass(frozen=True)
class MCircuit:
    kind: str
    idx: Optional[int] = None
    left: Optional["MCircuit"] = None
    right: Optional["MCircuit"] = None


def _eval(c: MCircuit, x: Assignment) -> bool:
    if c.kind == "var":
        return x[c.idx]  # type: ignore[index]
    if c.kind == "top":
        return True
    if c.kind == "bot":
        return False
    lv, rv = _eval(c.left, x), _eval(c.right, x)  # type: ignore[arg-type]
    return (lv and rv) if c.kind == "and" else (lv or rv)


def kw_find(c: MCircuit, x: Assignment, y: Assignment) -> Tuple[int, int]:
    """KW descent: precondition eval(C,x)=True, eval(C,y)=False.
    Returns (separating coordinate i with x_i=True, y_i=False; bits exchanged).
    The bit count never exceeds depth(C), proving kwCost_le_depth."""
    bits, node = 0, c
    while node.kind != "var":
        bits += 1
        if node.kind == "or":   # Alice names a child true on x
            node = node.left if _eval(node.left, x) else node.right  # type: ignore[assignment]
        else:                   # AND: Bob names a child false on y
            node = node.left if not _eval(node.left, y) else node.right  # type: ignore[assignment]
    return node.idx, bits  # type: ignore[return-value]
