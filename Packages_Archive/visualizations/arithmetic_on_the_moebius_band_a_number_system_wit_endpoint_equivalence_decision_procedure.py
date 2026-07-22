from dataclasses import dataclass
from fractions import Fraction

@dataclass(frozen=True)
class Point:
    x: Fraction
    y: Fraction

def equivalent(a: Point, b: Point) -> bool:
    return (a == b or
            (a.x == 0 and b.x == 1 and a.y == -b.y) or
            (a.x == 1 and b.x == 0 and a.y == -b.y))

a = Point(Fraction(0), Fraction(1))
a2 = Point(Fraction(1), Fraction(-1))
left = Point(a.x * a.x, a.y * a.y)
right = Point(a2.x * a2.x, a2.y * a2.y)
print(a, "~", a2, equivalent(a, a2))
print("Products:", left, right, "equivalent:", equivalent(left, right))
