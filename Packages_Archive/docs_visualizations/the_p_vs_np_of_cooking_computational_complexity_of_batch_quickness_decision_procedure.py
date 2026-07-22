from dataclasses import dataclass
from typing import List

@dataclass(frozen=True)
class Recipe:
    cook: int
    verify: int

def is_physical(r: Recipe) -> bool:
    return r.verify <= r.cook

def batch_speedup(menu: List[Recipe]) -> int:
    """Total slack of a menu of physical recipes: sum of C - V over dishes.
    By the Batch Quickness Theorem this is 0 iff every dish is quick."""
    assert all(is_physical(r) for r in menu), "all dishes must be physical"
    return sum(r.cook - r.verify for r in menu)

def batch_is_quick(menu: List[Recipe]) -> bool:
    """Decide whether a physical menu is globally quick (total C == total V).
    Equivalent to: every dish is quick (Batch Quickness Theorem)."""
    return batch_speedup(menu) == 0
