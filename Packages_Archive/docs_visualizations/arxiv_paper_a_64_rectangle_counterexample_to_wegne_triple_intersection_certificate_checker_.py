from __future__ import annotations
from dataclasses import dataclass
from itertools import combinations
from collections.abc import Sequence
@dataclass(frozen=True)
class Rectangle:
    left: float; right: float; bottom: float; top: float

def point_triangle_free(rs: Sequence[Rectangle]) -> bool:
    for a, b, c in combinations(rs, 3):
        if (max(a.left,b.left,c.left) <= min(a.right,b.right,c.right) and
            max(a.bottom,b.bottom,c.bottom) <= min(a.top,b.top,c.top)):
            return False
    return True

if __name__ == "__main__":
    print(point_triangle_free([Rectangle(0,2,0,1), Rectangle(1,3,0,1), Rectangle(4,5,0,1)]))
