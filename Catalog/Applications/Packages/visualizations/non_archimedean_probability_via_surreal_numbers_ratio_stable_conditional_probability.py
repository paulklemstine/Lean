def nap_conditional(a, b, n):
    from fractions import Fraction
    return Fraction(len(a & b), len(b))