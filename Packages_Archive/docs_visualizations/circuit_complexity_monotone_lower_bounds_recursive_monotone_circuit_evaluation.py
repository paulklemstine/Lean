from dataclasses import dataclass
from typing import Dict, Optional

Assignment = Dict[int, bool]


@dataclass(frozen=True)
class MCircuit:
    kind: str  # 'var' | 'top' | 'bot' | 'and' | 'or'
    idx: Optional[int] = None
    left: Optional["MCircuit"] = None
    right: Optional["MCircuit"] = None


def eval_circuit(c: MCircuit, x: Assignment) -> bool:
    """Post-order evaluation of a monotone circuit; O(size(C)) time."""
    if c.kind == "var":
        assert c.idx is not None
        return x[c.idx]
    if c.kind == "top":
        return True
    if c.kind == "bot":
        return False
    assert c.left is not None and c.right is not None
    lv = eval_circuit(c.left, x)
    rv = eval_circuit(c.right, x)
    return (lv and rv) if c.kind == "and" else (lv or rv)
