from __future__ import annotations
from typing import Callable, Hashable, List, Optional

Label = Hashable

def tensor_power_label(unit: Label, tensor: Callable[[Label, Label], Label],
                       x: Label, n: int) -> Label:
    acc: Label = unit
    for _ in range(n):
        acc = tensor(x, acc)
    return acc

def period_set(unit: Label, tensor: Callable[[Label, Label], Label],
               x: Label, search: int) -> List[int]:
    """All positive d <= search such that some X^m ~= X^(m+d) with m <= search."""
    out: List[int] = []
    for d in range(1, search + 1):
        for m in range(search + 1):
            if (tensor_power_label(unit, tensor, x, m)
                    == tensor_power_label(unit, tensor, x, m + d)):
                out.append(d)
                break
    return out

def min_period(unit: Label, tensor: Callable[[Label, Label], Label],
               x: Label, search: int) -> Optional[int]:
    """Least positive period (the fundamental frequency), or None if none found.
    Implements the well-ordering principle behind `minPeriod` (Nat.find)."""
    ps = period_set(unit, tensor, x, search)
    return min(ps) if ps else None
