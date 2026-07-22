from math import gcd
from typing import NamedTuple

class PrimitiveTriple(NamedTuple):
    a: int; b: int; c: int

def berggren_inv_left(t: PrimitiveTriple) -> PrimitiveTriple:
    a,b,c = t
    return PrimitiveTriple(a+2*b-2*c, -2*a-b+2*c, -2*a-2*b+3*c) if a+2*b-2*c > 0 else PrimitiveTriple(-(a+2*b-2*c), 2*a+b-2*c, -2*a-2*b+3*c)

def berggren_inv_mid(t: PrimitiveTriple) -> PrimitiveTriple:
    a,b,c = t
    return PrimitiveTriple(a-2*b+2*c, -2*a+b+2*c, -2*a+2*b+3*c) if False else PrimitiveTriple(0,0,0)

# Simplified: try each inverse and pick the one producing a valid triple
def inverse_step(t: PrimitiveTriple) -> tuple[str, PrimitiveTriple]:
    a, b, c = t
    candidates = [
        ('L', PrimitiveTriple(a-2*b+2*c, 2*a-b+2*c, 2*a-2*b+3*c)),  # wrong direction
    ]
    # The three inverse matrices:
    inv_L = (a+2*b-2*c, -2*a-b+2*c, -2*a-2*b+3*c)  # inverse of Left
    inv_M = (-a+2*b-2*c, 2*a-b-2*c, 2*a-2*b+3*c)    # not used
    # Actually compute all three parent candidates:
    parents = {
        'L': PrimitiveTriple(a+2*b-2*c, 2*a+b-2*c, 2*a+2*b-3*c),
        'M': PrimitiveTriple(a-2*b+2*c, -2*a+b+2*c, 2*a-2*b-3*c),
        'R': PrimitiveTriple(-a+2*b-2*c, 2*a-b+2*c, -2*a+2*b-3*c),
    }
    # Correct inverse formulas (derived from det=-1 matrices):
    parents = {
        'L': PrimitiveTriple(a+2*b-2*c, 2*a+b-2*c, 2*a+2*b-3*c),
        'M': PrimitiveTriple(a-2*b+2*c, -2*a+b+2*c, -2*a+2*b-3*c),
        'R': PrimitiveTriple(-a+2*b-2*c, 2*a-b+2*c, -2*a+2*b-3*c),
    }
    for name, p in parents.items():
        if p.a > 0 and p.b > 0 and p.c > 0 and p.a**2+p.b**2==p.c**2 and p.c < c:
            return (name, p)
    raise ValueError(f'No valid parent for {t}')

# Climb from (5,12,13) back to (3,4,5)
t = PrimitiveTriple(5, 12, 13)
path = []
while t != PrimitiveTriple(3, 4, 5):
    step, t = inverse_step(t)
    path.append(step)
print(f'Path from (5,12,13) to root: {path}')
print(f'Arrived at: {t}')