from fractions import Fraction

def padic_norm(p: int, x: Fraction) -> Fraction:
    if x == 0:
        return Fraction(0)
    v = int(padic_val_rat(p, x))
    return Fraction(1, p ** v) if v >= 0 else Fraction(p ** (-v), 1)

def hdist(p: int, x: Fraction, y: Fraction) -> Fraction:
    return padic_norm(p, x - y)
