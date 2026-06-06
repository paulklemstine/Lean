from fractions import Fraction
def cond_prob(a: set, b: set) -> Fraction:
    return Fraction(len(a & b), len(b))