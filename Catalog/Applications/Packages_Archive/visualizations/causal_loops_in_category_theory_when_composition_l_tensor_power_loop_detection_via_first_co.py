from __future__ import annotations
from typing import Callable, Dict, Hashable, Optional, Tuple

Label = Hashable

def tensor_power_label(unit: Label, tensor: Callable[[Label, Label], Label],
                       x: Label, n: int) -> Label:
    """Label (iso class) of X^n with X^0 = unit, X^(k+1) = x (x) X^k."""
    acc: Label = unit
    for _ in range(n):
        acc = tensor(x, acc)
    return acc

def detect_period(unit: Label, tensor: Callable[[Label, Label], Label],
                  x: Label, search: int) -> Optional[Tuple[int, int, int]]:
    """First collision X^m ~= X^n (m < n <= search). Returns (m, n, n - m)
    certifying periodicity with period n - m, or None within the window.
    O(search) tensor evaluations and O(search) memory."""
    seen: Dict[Label, int] = {}
    for n in range(search + 1):
        lbl = tensor_power_label(unit, tensor, x, n)
        if lbl in seen:
            m = seen[lbl]
            return (m, n, n - m)
        seen[lbl] = n
    return None
