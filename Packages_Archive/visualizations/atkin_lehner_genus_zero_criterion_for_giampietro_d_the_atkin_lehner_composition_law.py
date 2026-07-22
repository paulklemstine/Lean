from math import gcd

def al_mul(d: int, e: int) -> int:
    """Atkin-Lehner composition law  d * e = d*e / gcd(d,e)^2.

    On divisors of a squarefree N this returns the index of the composed
    involution w_d o w_e = w_{d*e}. The division is always exact because
    gcd(d,e)^2 divides d*e for divisors of a squarefree integer.
    """
    g = gcd(d, e)
    return d * e // (g * g)
