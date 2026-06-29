from __future__ import annotations
from typing import Callable, Hashable

Label = Hashable

def tensor_power_label(unit: Label, tensor: Callable[[Label, Label], Label],
                       x: Label, n: int) -> Label:
    acc: Label = unit
    for _ in range(n):
        acc = tensor(x, acc)
    return acc

def additive_law_holds(unit: Label, tensor: Callable[[Label, Label], Label],
                       x: Label, bound: int) -> bool:
    """Verify the additive comparison law X^(m+n) ~= X^m (x) X^n on labels for
    all m, n <= bound. O(bound^2) tensor evaluations."""
    for m in range(bound + 1):
        xm = tensor_power_label(unit, tensor, x, m)
        for n in range(bound + 1):
            lhs = tensor_power_label(unit, tensor, x, m + n)
            rhs = tensor(xm, tensor_power_label(unit, tensor, x, n))
            if lhs != rhs:
                return False
    return True
