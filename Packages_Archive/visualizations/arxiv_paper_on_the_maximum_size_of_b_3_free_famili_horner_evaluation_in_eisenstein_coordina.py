from typing import Iterable
Eisenstein = tuple[int, int]
def mul(x: Eisenstein, y: Eisenstein) -> Eisenstein:
    a, b = x; c, d = y
    return a*c-b*d, a*d+b*c-b*d
def norm(x: Eisenstein) -> int:
    a, b = x
    return a*a-a*b+b*b
def evaluate(coefficients: Iterable[int]) -> tuple[Eisenstein, int]:
    z = (0, 0)
    for c in reversed(list(coefficients)):
        z = mul(z, (0, 1))
        z = (z[0] + c, z[1])
    return z, norm(z)
